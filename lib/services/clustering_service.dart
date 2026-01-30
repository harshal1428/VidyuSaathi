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
  static const int TIME_WINDOW_HOURS = 24; // Recent tickets only

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
        // A. Title Similarity Check (Category + Simple string match)
        /* 
           Simple Logic: Same Category or Contains same keywords.
           Refined: If Cluster Title is "Power Failure" and Ticket is "Power Failure at street 2", match.
        */
        if (!_isTitleSimilar(cluster.title, ticket.title, ticket.category)) continue;

        // B. Time Window Check (Optional - if cluster is too old but still active, maybe start new?)
        // Let's assume if it is 'Active', it is valid for matching.

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

  bool _isTitleSimilar(String clusterTitle, String ticketTitle, String ticketCategory) {
    // 1. Category Match (Strongest Signal)
    // If we stored category in cluster, better. For now, assume cluster title represents the 'Main Issue'.
    
    // Normalize
    String cTitle = clusterTitle.toLowerCase();
    String tTitle = ticketTitle.toLowerCase();
    String tCat = ticketCategory.toLowerCase();

    // If Ticket Category is in Cluster Title (e.g. Cluster: "Power Failure Area X", Category: "Power Failure") => Match
    if (cTitle.contains(tCat)) return true;

    // If very similar words
    if (cTitle == tTitle) return true;

    // Simple containment
    if (tTitle.contains(cTitle) || cTitle.contains(tTitle)) return true;
    
    // If ticket has "No Power" and Cluster has "Power Outage" -> needs NLP. 
    // Fallback: If distance is VERY close (< 50m), assume same issue regardless of title? 
    // User requirement: "titile" is criterion 1. So we enforced it above.
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
    
    // Use Ticket Title or Category as Cluster Title
    // e.g., "Power Failure Cluster - <Timestamp>"
    String clusterTitle = ticket.category; 

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
        clusterStatus = 'In Progress';
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
          
          // Log status change (Optional - skipping for batch limit/simplicity, strict audit needs it)
        }
        await batch.commit();
        print("Synced Cluster ${cluster.clusterId} to $newStatus along with ${cluster.ticketIds.length} tickets.");
      }
    } catch (e) {
      print("Error syncing cluster status: $e");
    }
  }
}
