import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uuid/uuid.dart';
import '../models/ticket_model.dart';
import '../models/cluster_model.dart';
import '../core/constants.dart';

class ClusteringService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  // Config: Clustering Thresholds
  static const double CLUSTER_RADIUS_METERS = 200.0; // 200m radius
  static const int TIME_WINDOW_HOURS = 24; // Cluster tickets within 24h

  /// Main entry point to process a new ticket for clustering
  Future<void> processTicketForClustering(TicketModel ticket) async {
    if (ticket.latitude == null || ticket.longitude == null) return;

    try {
      // 1. Fetch potential Active Clusters
      // Optimization: In real app, use GeoQuery. For prototype, fetch Active clusters and filter in memory.
      final query = await _firestore.collection('CLUSTERS')
          .where('status', isEqualTo: 'Active')
          .get();

      final clusters = query.docs
          .map((doc) => ComplaintClusterModel.fromMap(doc.data()))
          .toList();

      ComplaintClusterModel? bestMatch;
      double minDistance = double.infinity;

      for (var cluster in clusters) {
        // A. Title Similarity Check (Title only, NO Category)
        if (!_isTitleSimilar(cluster.title, ticket.title)) continue;

        // B. Time Window Check
        // Ensure the ticket is within the time window of the cluster's creation
        Duration timeDiff = ticket.createdAt.difference(cluster.createdAt).abs();
        if (timeDiff.inHours > TIME_WINDOW_HOURS) continue;

        // C. Distance Check
        double distance = Geolocator.distanceBetween(
          ticket.latitude!,
          ticket.longitude!,
          cluster.centroidLatitude,
          cluster.centroidLongitude,
        );

        if (distance <= CLUSTER_RADIUS_METERS) {
          if (distance < minDistance) {
            minDistance = distance;
            bestMatch = cluster;
          }
        }
      }

      if (bestMatch != null) {
        await _addToCluster(bestMatch, ticket);
      } else {
        await _createNewCluster(ticket);
      }
    } catch (e) {
      print("Error in Clustering Service: $e");
    }
  }

  bool _isTitleSimilar(String clusterTitle, String ticketTitle) {
    // Normalize
    String cTitle = clusterTitle.toLowerCase().trim();
    String tTitle = ticketTitle.toLowerCase().trim();

    // 1. Exact Match
    if (cTitle == tTitle) return true;

    // 2. Simple containment
    if (tTitle.contains(cTitle) || cTitle.contains(tTitle)) return true;
    
    return false; 
  }

  Future<void> _addToCluster(ComplaintClusterModel cluster, TicketModel ticket) async {
    print("Adding Ticket ${ticket.ticketId} to Cluster ${cluster.clusterId}");

    // 1. Recalculate Centroid
    int newCount = cluster.ticketCount + 1;
    double newLat = ((cluster.centroidLatitude * cluster.ticketCount) + ticket.latitude!) / newCount;
    double newLong = ((cluster.centroidLongitude * cluster.ticketCount) + ticket.longitude!) / newCount;

    // 2. Update Cluster
    await _firestore.collection('CLUSTERS').doc(cluster.clusterId).update({
      'ticketIds': FieldValue.arrayUnion([ticket.ticketId]),
      'ticketCount': newCount,
      'centroidLatitude': newLat,
      'centroidLongitude': newLong,
      'lastUpdatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _createNewCluster(TicketModel ticket) async {
    print("Creating New Cluster for Ticket ${ticket.ticketId}");
    
    String id = "CLS-${_uuid.v4().substring(0, 8).toUpperCase()}";
    
    // Use Ticket Title as Cluster Title (Explicit user requirement: Not Category)
    String clusterTitle = ticket.title; 

    ComplaintClusterModel newCluster = ComplaintClusterModel(
      clusterId: id,
      centroidLatitude: ticket.latitude!,
      centroidLongitude: ticket.longitude!,
      radiusMeters: CLUSTER_RADIUS_METERS,
      title: clusterTitle,
      ticketIds: [ticket.ticketId],
      createdAt: DateTime.now(),
      lastUpdatedAt: DateTime.now(),
      status: 'Active',
      ticketCount: 1,
    );

    await _firestore.collection('CLUSTERS').doc(id).set(newCluster.toMap());
  }

  // Sync Status: If a ticket in a cluster is updated, update the cluster and siblings
  Future<void> syncClusterStatus(String ticketId, String newStatus, String officerId) async {
    try {
      // 1. Find Cluster containing this ticket
      final query = await _firestore.collection('CLUSTERS')
          .where('ticketIds', arrayContains: ticketId)
          .limit(1)
          .get();

      if (query.docs.isEmpty) return; // Not in a cluster (or purely single ticket)

      final clusterDoc = query.docs.first;
      final cluster = ComplaintClusterModel.fromMap(clusterDoc.data());
      
      // 2. Determine Action based on Status
      bool shouldPropagate = false;
      String clusterStatus = cluster.status;

      if (newStatus == AppConstants.statusResolved || newStatus == AppConstants.statusClosed) {
        // Resolve Cluster and ALL siblings
        clusterStatus = 'Resolved';
        shouldPropagate = true;
      } else if (newStatus == AppConstants.statusInProgress) {
        // Mark Cluster In Progress and siblings
        // clusterStatus = 'In Progress'; // Updating single ticket shouldn't necessarily update cluster status unless all are in progress, but for simplicity let's keep it sync
        // shouldPropagate = true;
      }
      
      // Explicitly handle "Resolved" propagation as per user request
      if (clusterStatus == 'Resolved') {
         shouldPropagate = true;
      }

      if (shouldPropagate) {
        // Update Cluster Status
        await _firestore.collection('CLUSTERS').doc(cluster.clusterId).update({
          'status': clusterStatus,
          'lastUpdatedAt': FieldValue.serverTimestamp(),
        });

        // Update All Siblings (Batch write for atomicity/efficiency)
        // Batches are limited to 500. Assuming clusters are small (< 20).
        WriteBatch batch = _firestore.batch();
        
        for (String tid in cluster.ticketIds) {
          if (tid == ticketId) continue; // Already updated by caller
          
          DocumentReference ticketRef = _firestore.collection('TICKETS').doc(tid);
          batch.update(ticketRef, {
            'status': newStatus,
            'updatedAt': FieldValue.serverTimestamp(),
            'resolvedAt': (newStatus == AppConstants.statusResolved) ? FieldValue.serverTimestamp() : null,
          });
        }
        await batch.commit();
        print("Synced Cluster ${cluster.clusterId} to $newStatus along with ${cluster.ticketIds.length} tickets.");

        // Notify Siblings
        if (newStatus == AppConstants.statusResolved) {
           for (String tid in cluster.ticketIds) {
             if (tid == ticketId) continue;
             _notifyCitizenOfResolvedCluster(tid);
           }
        }
      }
    } catch (e) {
      print("Error syncing cluster status: $e");
    }
  }

  Future<void> _notifyCitizenOfResolvedCluster(String ticketId) async {
     try {
       final doc = await _firestore.collection('TICKETS').doc(ticketId).get();
       if (!doc.exists) return;
       final data = doc.data();
       final citizenId = data?['citizenId'];
       if (citizenId != null) {
          // Direct Notification Write
          await _firestore.collection('NOTIFICATIONS').add({
            'title': 'Complaint Resolved',
            'body': 'Your complaint has been resolved as part of a cluster resolution.',
            'type': 'ticket_status',
            'userId': citizenId,
            'ticketId': ticketId,
            'isRead': false,
            'createdAt': FieldValue.serverTimestamp(),
          });
       }
     } catch (e) {
       print("Failed to notify sibling $ticketId: $e");
     }
  }
}
