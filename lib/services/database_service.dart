import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:geolocator/geolocator.dart';
import '../models/ticket_model.dart';
import '../models/user_model.dart';
import '../models/cluster_model.dart';
import '../models/dashboard_stats_model.dart';
import '../models/structure_models.dart';
import '../core/constants.dart';
import 'clustering_service.dart';
import 'notification_service.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();
  final ClusteringService _clusteringService = ClusteringService();
  final NotificationService _notificationService = NotificationService();

  // Create Ticket
  Future<void> createTicket(TicketModel ticket) async {
    TicketModel newTicket = ticket;
    
    // Geospatial Assignment Logic
    if (ticket.latitude != null && ticket.longitude != null) {
      try {
        // 1. Fetch all offices (Optimization: In a real app, use GeoFlutterFire or similar)
        // Since we have < 100 offices, fetching all is acceptable for this prototype.
        final officeSnaps = await _firestore.collection('OFFICES').get();
        final offices = officeSnaps.docs.map((doc) => OfficeModel(
          officeId: doc['officeId'],
          regionId: doc['regionId'],
          name: doc['name'],
          latitude: (doc['latitude'] as num).toDouble(),
          longitude: (doc['longitude'] as num).toDouble(),
          radiusKm: (doc['radiusKm'] as num).toDouble(),
        )).toList();

        OfficeModel? nearestOffice;
        double minDistance = double.infinity;

        // 2. Find nearest office
        for (var office in offices) {
          double distanceMeters = Geolocator.distanceBetween(
            ticket.latitude!, 
            ticket.longitude!, 
            office.latitude, 
            office.longitude
          );
          
          // Track absolute nearest for fallback
          if (distanceMeters < minDistance) {
            minDistance = distanceMeters;
            nearestOffice = office;
          }
        }
        
        // LOGIC: If we found ANY office, nearestOffice will be set to the absolute closest.
        // We accept this even if > radius, as we MUST assign to someone.
        if (nearestOffice != null) {
           double radiusMeters = nearestOffice.radiusKm * 1000;
           String matchType = minDistance <= radiusMeters ? "Within Radius" : "Fallback (Nearest)";
           
           print("Geospatial Assignment: $matchType. Assigned to ${nearestOffice.name} (Dist: ${(minDistance/1000).toStringAsFixed(2)} km)");
        }

        if (nearestOffice != null) {
          print("Geospatial Match: Assigned to Office ${nearestOffice.name} (${nearestOffice.officeId})");
          
          // 3. Fetch Hierarchy Details
          String? regionId = nearestOffice.regionId;
          String? circleId;
          String? divisionId;

          // Fetch Region to get Circle
          final regionSnap = await _firestore.collection('REGIONS').doc(regionId).get();
          if (regionSnap.exists) {
            circleId = regionSnap.data()?['circleId'];
             // Fetch Circle to get Division
             if (circleId != null) {
                final circleSnap = await _firestore.collection('CIRCLES').doc(circleId).get();
                if (circleSnap.exists) {
                  divisionId = circleSnap.data()?['divisionId'];
                }
             }
          }

          // 4. Find JE for this Office to Assign
          // We look for a user with role 'JE' in this office.
          final jeQuery = await _firestore.collection('USERS')
              .where('officeId', isEqualTo: nearestOffice.officeId)
              .where('role', isEqualTo: 'JE')
              .limit(1)
              .get();
          
          String? assigneeId;
          String? assigneeRole;
          
          if (jeQuery.docs.isNotEmpty) {
             assigneeId = jeQuery.docs.first['userId'];
             assigneeRole = 'JE';
          }

          // 5. Update Ticket Object
          newTicket = TicketModel(
            ticketId: ticket.ticketId,
            title: ticket.title,
            description: ticket.description,
            category: ticket.category,
            priority: ticket.priority,
            status: assigneeId != null ? AppConstants.statusAssigned : AppConstants.statusCreated,
            citizenId: ticket.citizenId,
            createdAt: ticket.createdAt,
            latitude: ticket.latitude,
            longitude: ticket.longitude,
            imageUrls: ticket.imageUrls,
            slaHours: ticket.slaHours,
            escalationLevel: ticket.escalationLevel,
            generatedVia: ticket.generatedVia,
            
            // Assigned Fields
            officeId: nearestOffice.officeId,
            regionId: regionId,
            circleId: circleId,
            divisionId: divisionId,
            currentOwnerId: assigneeId,    // Assign to JE
            currentOwnerRole: assigneeRole,
            supervisingJEId: assigneeId,   // JE is the supervisor
            assignedAt: assigneeId != null ? DateTime.now() : null,
          );
        }
      } catch (e) {
        print("Error during geospatial assignment: $e");
        // Fallback: Proceed with creating ticket without assignment
      }
    }

    await _firestore.collection('TICKETS').doc(newTicket.ticketId).set(newTicket.toMap());
    
    // Trigger Clustering (Async - Fire and Forget)
    if (newTicket.latitude != null && newTicket.longitude != null) {
       _clusteringService.processTicketForClustering(newTicket);
    }
    
    // Notify Citizen of Creation
    if (newTicket.citizenId.isNotEmpty) {
      _notificationService.sendNotification(
        title: 'Complaint Registered',
        body: 'Your complaint about ${newTicket.category} has been received and assigned to the concerned office on ${_formatDate(DateTime.now())}.',
        userId: newTicket.citizenId,
        type: 'ticket_status',
        ticketId: newTicket.ticketId,
      );
    }
    // Notify Officer if assigned immediately
    if (newTicket.currentOwnerId != null) {
       _notificationService.sendNotification(
        title: 'New Complaint Assignment',
        body: 'Complaint "${newTicket.title}" received at ${_formatDate(DateTime.now())}.',
        userId: newTicket.currentOwnerId!,
        type: 'assignment',
        ticketId: newTicket.ticketId,
      );
    }
    
    // Notify Admins (System Admins)
    try {
      final adminSnaps = await _firestore.collection('USERS').where('role', isEqualTo: AppConstants.roleAdmin).get();
      for (var doc in adminSnaps.docs) {
         _notificationService.sendNotification(
          title: 'New Complaint Logged',
          body: 'Complaint "${newTicket.title}" logged by citizen at ${_formatDate(DateTime.now())}.',
          userId: doc.id,
          type: 'admin_alert',
          ticketId: newTicket.ticketId,
        );
      }
    } catch (e) {
      print("Error notifying admins: $e");
    }
  }

  // Get Tickets for Citizen
  Stream<List<TicketModel>> getCitizenTickets(String citizenId) {
    return _firestore
        .collection('TICKETS')
        .where('citizenId', isEqualTo: citizenId)
        .snapshots() // Removed orderBy to avoid index requirement
        .map((snapshot) {
      final tickets = snapshot.docs.map((doc) => TicketModel.fromMap(doc.data() as Map<String, dynamic>)).toList();
      tickets.sort((a, b) => b.createdAt.compareTo(a.createdAt)); // Client-side sort
      return tickets;
    });
  }

  // Get All Tickets (For Admin)
  Stream<List<TicketModel>> getAllTickets() {
    return _firestore
        .collection('TICKETS')
        .snapshots() // Removed orderBy
        .map((snapshot) {
      final tickets = snapshot.docs.map((doc) => TicketModel.fromMap(doc.data() as Map<String, dynamic>)).toList();
      tickets.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return tickets;
    });
  }

  // Get Tickets for Officer (Task Management)
  Stream<List<TicketModel>> getOfficerTickets(UserModel user, {String? status}) {
    Query query = _firestore.collection('TICKETS');

    if (status != null) {
        query = query.where('status', isEqualTo: status);
    }
    
    // Hierarchical Querying
    // We assume the user model has the ids populated.
    
    // Check Role from Designation or Role field
    String desig = (user.designation ?? '').toUpperCase();
    String currentRole = (user.role ?? '').toUpperCase();
    
    if (currentRole == 'ADMIN') {
      // Admin sees all
    } else if (desig.contains('CHIEF') || currentRole == 'CE') {
       // CE -> Region Head
       if (user.regionId != null) {
         query = query.where('regionId', isEqualTo: user.regionId);
       }
    } else if (desig.contains('SUPERINTEND') || currentRole == 'SE') {
       // SE -> Circle Head
       if (user.circleId != null) {
         query = query.where('circleId', isEqualTo: user.circleId);
       }
    } else if (desig.contains('DEPUTY') || currentRole == 'DYEE' || desig.contains('DE') || currentRole == 'DE') {
       // DyEE -> Subdivision (Approximated as Division level visibility for now, or filtered by subdivision if available)
       // Since we track divisionId, let's allow visibility of Division or fallback to Office
       if (user.divisionId != null) {
         query = query.where('divisionId', isEqualTo: user.divisionId);
       } else if (user.officeId != null) {
          query = query.where('officeId', isEqualTo: user.officeId);
       }
    } else if (desig.contains('EXECUTIVE') || currentRole == 'EE') {
       // EE -> Division Head
       if (user.divisionId != null) {
         query = query.where('divisionId', isEqualTo: user.divisionId);
       }
    } else if (desig.contains('JUNIOR') || currentRole == 'JE' || desig.contains('ASSISTANT') || currentRole == 'AE') {
       if (user.officeId != null) {
         query = query.where('officeId', isEqualTo: user.officeId);
       }
    } else if (currentRole == 'OFFICE_ADMIN' || desig == 'Admin') {
       if (user.officeId != null) {
         // Office Admin sees all tickets in their office
         query = query.where('officeId', isEqualTo: user.officeId);
       }
    } else {
       // Field Staff or Default
       query = query.where('currentOwnerId', isEqualTo: user.userId);
    }

    // Sort by recent (Client-side to avoid composite index issues)
    // query = query.orderBy('createdAt', descending: true);

    return query.snapshots().map((snapshot) {
      final tickets = snapshot.docs.map((doc) => TicketModel.fromMap(doc.data() as Map<String, dynamic>)).toList();
      tickets.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return tickets;
    });
  }

  // Dashboard Stats
  Stream<DashboardStats> getTicketStats(UserModel user) {
    // Reuse the query logic from getOfficerTickets to ensure consistency
    // Note: In a real app, use Aggregation Queries to avoid reading all documents.
    // For this prototype, we read and count client side.
    
    return getOfficerTickets(user).map((tickets) {
      int total = tickets.length;
      int pending = 0;
      int inProgress = 0;
      int resolved = 0;
      int escalated = 0;
      int critical = 0;
      int high = 0;
      int medium = 0;
      int low = 0;

      for (var t in tickets) {
        // Status Counts
        if (t.status == AppConstants.statusCreated || t.status == AppConstants.statusAssigned) {
          pending++;
        } else if (t.status == AppConstants.statusInProgress) {
          inProgress++;
        } else if (t.status == AppConstants.statusResolved || t.status == AppConstants.statusClosed) {
          resolved++;
        } else if (t.status == AppConstants.statusSupervisorReview) {
             // Treat as resolved or in progress?
             inProgress++; 
        }

        // Priority Counts
        String p = t.priority.toLowerCase();
        if (p.contains('critical')) critical++;
        else if (p.contains('high')) high++;
        else if (p.contains('medium')) medium++;
        else if (p.contains('low')) low++;
        
        // Escalated flag check (if exists in model) or Status check
        if (t.escalationLevel > 0) escalated++;
      }

      return DashboardStats(
        total: total,
        pending: pending,
        inProgress: inProgress,
        resolved: resolved,
        escalated: escalated,
        critical: critical,
        high: high,
        medium: medium,
        low: low,
      );
    });
  }

  // Recent Tickets
  Stream<List<TicketModel>> getRecentTickets(UserModel user, {int limit = 5}) {
    return getOfficerTickets(user).map((tickets) {
       // getOfficerTickets is already sorted by createdAt descending
       return tickets.take(limit).toList();
    });
  }

  // Get Subordinate Staff
  Stream<List<UserModel>> getSubordinateStaff(UserModel user) {
    Query query = _firestore.collection('USERS');
    
    String desig = (user.designation ?? '').toUpperCase();
    String role = (user.role ?? '').toUpperCase();
    
    if (desig.contains('CHIEF') || role == 'CE') {
       // CE (Region) -> SE (Circle)
       if (user.regionId != null) {
          query = query.where('regionId', isEqualTo: user.regionId)
                       .where('role', whereIn: ['Superintending Engineer', 'SE']); 
       }
    } else if (desig.contains('SUPERINTEND') || role == 'SE') {
       // SE (Circle) -> EE (Division)
       if (user.circleId != null) {
          query = query.where('circleId', isEqualTo: user.circleId)
                       .where('role', whereIn: ['Executive Engineer', 'EE']); 
       }
    } else if (desig.contains('EXECUTIVE') && !desig.contains('DEPUTY') || role == 'EE') {
       // EE (Division) -> DyEE, AE, JE
       if (user.divisionId != null) {
          query = query.where('divisionId', isEqualTo: user.divisionId)
                       .where('role', whereIn: ['Deputy Executive Engineer', 'DyEE', 'Assistant Engineer', 'AE', 'Junior Engineer', 'JE']);
       }
    } else if (desig.contains('DEPUTY') || role == 'DYEE' || desig.contains('DE') || role == 'DE') {
        // DyEE -> AE, JE
        if (user.divisionId != null) {
            query = query.where('divisionId', isEqualTo: user.divisionId)
                         .where('role', whereIn: ['Assistant Engineer', 'AE', 'Junior Engineer', 'JE']);
        }
    } else if (desig.contains('ASSISTANT') || role == 'AE') {
       // AE -> JE, Field
       if (user.officeId != null) {
           query = query.where('officeId', isEqualTo: user.officeId)
                        .where('role', whereIn: ['Junior Engineer', 'JE', 'Field Officer', 'FE', 'Technician']);
       }
    } else if (desig.contains('JUNIOR') || role == 'JE') {
       // JE -> Field Staff
       if (user.officeId != null) {
         query = query.where('officeId', isEqualTo: user.officeId)
                      .where('role', whereIn: ['Field Officer', 'FieldOfficer', 'FE', 'Technician']);
       }
    } else {
        return Stream.value([]);
    }
    
    return query.snapshots().map((s) => 
        s.docs.map((d) => UserModel.fromMap(d.data() as Map<String, dynamic>))
        .where((u) => u.userId != user.userId) // Exclude self
        .toList()
    );
  }
  
  // Update Ticket Status
  Future<void> updateTicketStatus(String ticketId, String newStatus, {String? officerId}) async {
    Map<String, dynamic> updates = {
      'status': newStatus,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    
    if (newStatus == AppConstants.statusResolved) {
      updates['resolvedAt'] = FieldValue.serverTimestamp();
      updates['escalationLevel'] = 0; // De-escalate upon resolution
    } else if (newStatus == 'Closed') {
      updates['escalationLevel'] = 0;
    }

    await _firestore.collection('TICKETS').doc(ticketId).update(updates);
    
    // Log status change
    await _firestore.collection('TICKET_STATUS_LOGS').add({
      'ticketId': ticketId,
      'status': newStatus,
      'changedBy': officerId,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // NOTIFICATIONS
    try {
      // Fetch ticket to get involved parties
      final ticketDoc = await _firestore.collection('TICKETS').doc(ticketId).get();
      if (ticketDoc.exists) {
        final data = ticketDoc.data()!;
        final citizenId = data['citizenId'];
        final currentOwnerId = data['currentOwnerId'];

        // 1. Notify Citizen
        if (citizenId != null) {
          String notifTitle = 'Ticket Updated';
          if (newStatus == 'In Progress') notifTitle = 'Complaint In Progress';
          else if (newStatus == 'Resolved') notifTitle = 'Complaint Resolved';
          
          await _notificationService.sendNotification(
            title: notifTitle,
            body: 'Your complaint ${ticketId} is now $newStatus.',
            userId: citizenId,
            type: 'ticket_status',
            ticketId: ticketId,
          );
        }

        // 2. Notify Current Owner (if different from changer) - simplified, notify owner always
        if (currentOwnerId != null && currentOwnerId != officerId) {
           await _notificationService.sendNotification(
            title: 'Ticket Updated',
            body: 'Ticket ${ticketId} status changed to $newStatus.',
            userId: currentOwnerId,
            type: 'ticket_assignment',
            ticketId: ticketId,
          );
        }
      }
    } catch (e) {
      print("Notification Error: $e");
    }

    // CLUSTERING SYNC
    // If ticket is part of a cluster, sync status to all members
    if (officerId != null) {
       await _clusteringService.syncClusterStatus(ticketId, newStatus, officerId);
    }
  }

  // Get All Staff (For Admin)
  Stream<List<UserModel>> getAllStaff() {
    return _firestore
        .collection('USERS')
        .where('role', isNotEqualTo: AppConstants.roleCitizen)
        .snapshots()
        .map((s) => s.docs.map((d) => UserModel.fromMap(d.data())).toList());
  }
  String _formatDate(DateTime date) {
    // Simple formatting: 27 Jan 2026 at 09:54 PM
    // Manual since intl might not be ready or we want custom
    List<String> months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    String month = months[date.month - 1];
    String hour = date.hour > 12 ? (date.hour - 12).toString().padLeft(2, '0') : (date.hour == 0 ? '12' : date.hour.toString().padLeft(2, '0'));
    String ampm = date.hour >= 12 ? 'PM' : 'AM';
    String min = date.minute.toString().padLeft(2, '0');
    return "${date.day} $month ${date.year} at $hour:$min $ampm";
  }

  // Get Clusters for Officer (Filtered by Jurisdiction)
  Future<List<ComplaintClusterModel>> getClustersForOfficer(UserModel user) async {
    try {
      // 1. Fetch recent active clusters
      final snapshot = await _firestore.collection('CLUSTERS')
          .where('status', isEqualTo: 'Active')
          .orderBy('lastUpdatedAt', descending: true)
          .limit(50)
          .get();

      final allClusters = snapshot.docs.map((d) => ComplaintClusterModel.fromMap(d.data() as Map<String, dynamic>)).toList();
      final List<ComplaintClusterModel> validClusters = [];

      // 2. Filter by Jurisdiction (Expensive check: Fetch 1 ticket per cluster)
      // Optimization: Batch fetch the 'representative' tickets (first ticketId of each cluster)
      if (allClusters.isEmpty) return [];

      List<String> representativeTicketIds = allClusters
          .where((c) => c.ticketIds.isNotEmpty)
          .map<String>((c) => c.ticketIds.first)
          .toList();

      // Chunk into 10s for whereIn query
      List<TicketModel> repTickets = [];
      for (var i = 0; i < representativeTicketIds.length; i += 10) {
          var end = (i + 10 < representativeTicketIds.length) ? i + 10 : representativeTicketIds.length;
          var subList = representativeTicketIds.sublist(i, end);
          if (subList.isEmpty) continue;
          
          final tSnap = await _firestore.collection('TICKETS').where(FieldPath.documentId, whereIn: subList).get();
          repTickets.addAll(tSnap.docs.map((d) => TicketModel.fromMap(d.data())));
      }

      // Map TicketId -> Ticket
      Map<String, TicketModel> ticketMap = { for (var t in repTickets) t.ticketId : t };

      String desig = (user.designation ?? '').toUpperCase();
      String role = (user.role ?? '').toUpperCase();

      for (var cluster in allClusters) {
         if (cluster.ticketIds.isEmpty) continue;
         final repTicket = ticketMap[cluster.ticketIds.first];
         if (repTicket == null) continue; // Ticket not found, maybe deleted? Skip.

         bool isValid = false;
         
         if (role == 'ADMIN') {
            isValid = true;
         } else if (desig.contains('CHIEF') || role == 'CE') {
             // CE -> Region + Escalated
             if (repTicket.regionId == user.regionId) {
                isValid = repTicket.escalationLevel > 0;
             }
         } else if (desig.contains('SUPERINTEND') || role == 'SE') {
             // SE -> Circle + Escalated
             if (repTicket.circleId == user.circleId) {
                isValid = repTicket.escalationLevel > 0;
             }
         } else if (desig.contains('EXECUTIVE') && !desig.contains('DEPUTY') || role == 'EE') {
             // EE -> Division + Escalated
             if (repTicket.divisionId == user.divisionId) {
                isValid = repTicket.escalationLevel > 0;
             }
         } else if (desig.contains('DEPUTY') || role == 'DYEE' || desig.contains('DE') || role == 'DE') {
             // DyEE -> Division + Escalated
             if (repTicket.divisionId == user.divisionId || (repTicket.divisionId == null && repTicket.officeId == user.officeId)) {
                isValid = repTicket.escalationLevel > 0;
             }
         } else {
             // JE/AE/Field -> Office (Show ALL, not just escalated)
             isValid = (repTicket.officeId == user.officeId);
         }

         if (isValid) {
           validClusters.add(cluster);
         }
      }

      return validClusters;

    } catch (e) {
      print("Error fetching clusters: $e");
      return [];
    }
  }
}


