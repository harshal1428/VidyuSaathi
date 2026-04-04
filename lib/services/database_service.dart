import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
import 'escalation_service.dart';
import 'nlp_classification_service.dart';

class DatabaseService {
  static const String DEPARTMENTS = 'DEPARTMENTS';
  static const String COMPLAINT_TYPES = 'COMPLAINT_TYPES';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();
  final ClusteringService _clusteringService = ClusteringService();
  final NotificationService _notificationService = NotificationService();

  bool _isOfficeAdminUser(UserModel user) {
    final role = user.role.toUpperCase();
    final designation = user.designation.toUpperCase();
    return role == 'OFFICE_ADMIN' || designation == 'ADMIN';
  }

  bool _isOpenEscalatedTicket(TicketModel t) {
    final isClosed = t.status == AppConstants.statusResolved ||
        t.status == AppConstants.statusClosed ||
        t.status == 'Rejected';
    final escalatedNow = t.status == 'Escalated' || t.escalationLevel > 0;
    return !isClosed && escalatedNow;
  }

  Future<String?> _resolveUserEmail(String? userId) async {
    if (userId == null || userId.trim().isEmpty) return null;
    final normalized = userId.trim();

    final byDoc = await _firestore.collection('USERS').doc(normalized).get();
    if (byDoc.exists) {
      final email = byDoc.data()?['email']?.toString();
      if (email != null && email.isNotEmpty) return email;
    }

    final byUserId = await _firestore
        .collection('USERS')
        .where('userId', isEqualTo: normalized)
        .limit(1)
        .get();
    if (byUserId.docs.isNotEmpty) {
      final email = byUserId.docs.first.data()['email']?.toString();
      if (email != null && email.isNotEmpty) return email;
    }
    return null;
  }

  // Create Ticket
  Future<void> createTicket(TicketModel ticket, NlpResult nlpResult) async {
    TicketModel newTicket = ticket;
    String? previousTicketId;
    int clusterSize = 1;
    String clusterId = '';

    // Step 2 & 3
    if (ticket.latitude != null && ticket.longitude != null) {
      previousTicketId = await _clusteringService.checkRecurrence(
          ticket.latitude!, ticket.longitude!, nlpResult.departmentId);

      Map<String, dynamic> pt = ticket.toMap();
      pt['departmentId'] = nlpResult.departmentId;
      pt['title'] = nlpResult.title;
      pt['ticketId'] = ticket.ticketId;
      var cRes = await _clusteringService.checkAndCluster(pt);
      clusterSize = cRes['clusterSize'] ?? 1;
      clusterId = cRes['clusterId'] ?? '';
    }

    // Step 4
    bool isRecurrence = previousTicketId != null;
    int escalationStartLevel = _clusteringService.getEscalationStartLevel(clusterSize, isRecurrence);
    int adjustedSlaHours = (nlpResult.slaHours * _clusteringService.getSlaReductionFactor(clusterSize)).round();

    String? assigneeId;
    String? assigneeRole;
    String? officeId;
    String? regionId;
    String? circleId;
    String? divisionId;

    if (ticket.latitude != null && ticket.longitude != null) {
      try {
        // Step 5: geospatial logic WITH department filter
        final officeSnaps = await _firestore.collection('OFFICES')
              .where('departmentId', isEqualTo: nlpResult.departmentId)
              .get();
              
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
        for (var office in offices) {
          double distanceMeters = Geolocator.distanceBetween(
            ticket.latitude!, ticket.longitude!, office.latitude, office.longitude
          );
          if (distanceMeters < minDistance) {
            minDistance = distanceMeters;
            nearestOffice = office;
          }
        }

        if (nearestOffice != null) {
          officeId = nearestOffice.officeId;
          regionId = nearestOffice.regionId;
          
          final regionSnap = await _firestore.collection('REGIONS').doc(regionId).get();
          if (regionSnap.exists) {
             circleId = regionSnap.data()?['circleId'];
             if (circleId != null) {
                final circleSnap = await _firestore.collection('CIRCLES').doc(circleId).get();
                if (circleSnap.exists) {
                  divisionId = circleSnap.data()?['divisionId'];
                }
             }
          }
          
          // Step 6: Find Officer at L{escalationStartLevel}
          final hier = await EscalationService.getDeptHierarchy(nlpResult.departmentId);
          var node = hier.firstWhere((h) => h['level'] == escalationStartLevel, orElse: () => hier.isNotEmpty ? hier.first : {'role': 'JE'});
          String targetRole = node['role'];
          
          Query q = _firestore.collection('USERS').where('role', isEqualTo: targetRole).limit(10);
          if (escalationStartLevel <= 3) {
             q = q.where('officeId', isEqualTo: officeId);
          } else if (escalationStartLevel <= 5) {
             q = q.where('regionId', isEqualTo: regionId);
          } else if (escalationStartLevel == 6) {
             q = q.where('circleId', isEqualTo: circleId);
          } else {
             q = q.where('divisionId', isEqualTo: divisionId ?? 'zone_pune');
          }
          
          final officerQuery = await q.get();
          if (officerQuery.docs.isNotEmpty) {
             for (var doc in officerQuery.docs) {
               final data = doc.data() as Map<String, dynamic>;
               final docId = doc.id;
               String uid = data['userId'] ?? '';

               if (docId.length == 28) {
                 assigneeId = docId;
                 assigneeRole = targetRole;
                 break;
               }

               if (uid.length == 28 && !uid.startsWith('je_') && !uid.startsWith('field_')) {
                 assigneeId = uid;
                 assigneeRole = targetRole;
                 break;
               }
             }

             assigneeId ??= officerQuery.docs.first.id;
             assigneeRole ??= targetRole;
          }
        }
      } catch(e) {
        print("Geo Error: $e");
      }
    }

    // Step 7: Build ticket document
    newTicket = TicketModel(
      ticketId: ticket.ticketId,
      title: nlpResult.title,
      description: ticket.description,
      category: nlpResult.category,
      priority: nlpResult.priority,
      status: assigneeId != null ? AppConstants.statusAssigned : AppConstants.statusCreated,
      citizenId: ticket.citizenId,
      createdAt: ticket.createdAt,
      latitude: ticket.latitude,
      longitude: ticket.longitude,
      imageUrls: ticket.imageUrls,
      slaHours: nlpResult.slaHours,
      escalationLevel: nlpResult.isCriticalOverride ? 3 : escalationStartLevel,
      generatedVia: ticket.generatedVia,
      
      officeId: officeId,
      regionId: regionId,
      circleId: circleId,
      divisionId: divisionId,
      currentOwnerId: assigneeId,
      currentOwnerRole: assigneeRole,
      supervisingJEId: assigneeId,
      assignedAt: assigneeId != null ? DateTime.now() : null,
      slaMinutes: ticket.slaMinutes,
      
      departmentId: nlpResult.departmentId,
      rawInputText: ticket.description, // The raw input text
      nlpClassification: nlpResult.toMap(),
      escalationStartLevel: escalationStartLevel,
      adjustedSlaHours: adjustedSlaHours,
      isRecurrence: isRecurrence,
      previousTicketId: previousTicketId ?? '',
      linkedTicketIds: [],
    );

    // Step 8: Write to Firestore
    await _firestore.collection('TICKETS').doc(newTicket.ticketId).set(newTicket.toMap());

    if (newTicket.citizenId.isNotEmpty) {
      await _notificationService.sendNotification(
        title: 'Complaint Registered',
        body: 'Your complaint about ${newTicket.category} has been received.',
        userId: newTicket.citizenId,
        recipientEmail: null,
        type: 'ticket_create',
        ticketId: newTicket.ticketId,
      );
    }
    
    // Step 9: Call NotificationService to notify assigned officer
    if (assigneeId != null) {
      final assigneeEmail = await _resolveUserEmail(assigneeId);
      await _notificationService.sendNotification(
        title: 'New Assignment',
        body: 'A new ${newTicket.priority} priority ticket has been assigned to you.',
        userId: assigneeId,
        recipientEmail: assigneeEmail,
        type: 'ticket_assignment',
        ticketId: newTicket.ticketId,
      );
    }
    
    // Step 10: If isRecurrence: also notify the L3+ officer of the office
    if (isRecurrence && officeId != null && escalationStartLevel < 3) {
       try {
         final hier = await EscalationService.getDeptHierarchy(nlpResult.departmentId);
         var nodeL3 = hier.firstWhere((h) => h['level'] == 3, orElse: () => {'role': 'DyEE'});
         final qL3 = await _firestore.collection('USERS')
             .where('role', isEqualTo: nodeL3['role'])
             .where('officeId', isEqualTo: officeId)
             .limit(1)
             .get();
             
         if (qL3.docs.isNotEmpty) {
           final first = qL3.docs.first;
           final data = first.data() as Map<String, dynamic>;
           String uidL3 = first.id.length == 28 ? first.id : (data['userId'] ?? first.id);
           final l3Email = await _resolveUserEmail(uidL3);
             await _notificationService.sendNotification(
                title: 'Recurring Issue Alert',
                body: 'A recurring issue was just reported in your jurisdiction.',
                userId: uidL3,
                recipientEmail: l3Email,
                type: 'escalation_alert',
                ticketId: newTicket.ticketId,
             );
         }
       } catch (e) {
         print("Failed L3 recurrence notification: $e");
       }
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

  Stream<List<TicketModel>> getTicketsForAdmin(UserModel user, {String? status}) {
    Query query = _firestore.collection('TICKETS');

    if (status != null && status.trim().isNotEmpty) {
      query = query.where('status', isEqualTo: status.trim());
    }

    if (_isOfficeAdminUser(user) && (user.officeId ?? '').trim().isNotEmpty) {
      query = query.where('officeId', isEqualTo: user.officeId!.trim());
    }

    return query.snapshots().map((snapshot) {
      final tickets = snapshot.docs
          .map((doc) => TicketModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
      tickets.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return tickets;
    });
  }

  Stream<List<Map<String, dynamic>>> getEscalationLogsForAdmin(UserModel user) {
    Query query = _firestore.collection('ESCALATION_LOGS');

    if (_isOfficeAdminUser(user) && (user.officeId ?? '').trim().isNotEmpty) {
      query = query.where('officeId', isEqualTo: user.officeId!.trim());
    }

    return query.snapshots().map((snapshot) {
      final logs = snapshot.docs
          .map((doc) {
            final data = (doc.data() as Map<String, dynamic>);
            data['id'] = doc.id;
            return data;
          })
          .toList();

      logs.sort((a, b) {
        final aTs = a['timestamp'];
        final bTs = b['timestamp'];
        final aMillis = aTs is Timestamp ? aTs.millisecondsSinceEpoch : 0;
        final bMillis = bTs is Timestamp ? bTs.millisecondsSinceEpoch : 0;
        return bMillis.compareTo(aMillis);
      });
      return logs;
    });
  }

  Future<List<OfficeModel>> getAllOffices() async {
    final snapshot = await _firestore.collection('OFFICES').get();
    final offices = <OfficeModel>[];

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final latitude = (data['latitude'] as num?)?.toDouble();
      final longitude = (data['longitude'] as num?)?.toDouble();
      if (latitude == null || longitude == null) {
        continue;
      }

      offices.add(
        OfficeModel(
          officeId: (data['officeId'] ?? doc.id).toString(),
          regionId: (data['regionId'] ?? '').toString(),
          name: (data['name'] ?? (data['officeId'] ?? doc.id)).toString(),
          latitude: latitude,
          longitude: longitude,
          radiusKm: (data['radiusKm'] as num?)?.toDouble() ?? 1.0,
          capacity: (data['capacity'] as num?)?.toInt() ?? 10,
        ),
      );
    }

    return offices;
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
       final ownerIds = <String>{};
       final currentUid = FirebaseAuth.instance.currentUser?.uid;
       if (currentUid != null && currentUid.trim().isNotEmpty) {
         ownerIds.add(currentUid.trim());
       }
       if (user.userId.trim().isNotEmpty) {
         ownerIds.add(user.userId.trim());
       }

       if (ownerIds.length == 1) {
         query = query.where('currentOwnerId', isEqualTo: ownerIds.first);
       } else if (ownerIds.length > 1) {
         query = query.where('currentOwnerId', whereIn: ownerIds.toList());
       } else {
         query = query.where('currentOwnerId', isEqualTo: '__none__');
       }
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
        
        // Count only open escalations to keep dashboard numbers accurate.
        if (_isOpenEscalatedTicket(t)) escalated++;
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

  // Recent Tickets (Open / Active Only)
  Stream<List<TicketModel>> getRecentTickets(UserModel user, {int limit = 5}) {
    return getOfficerTickets(user).map((tickets) {
       // Filter Active: Exclude Resolved, Closed, Rejected
       final activeTickets = tickets.where((t) => 
          t.status != 'Resolved' && 
          t.status != 'Closed' && 
          t.status != 'Rejected'
       ).toList();
       return activeTickets.take(limit).toList();
    });
  }

  Stream<List<TicketModel>> getOpenEscalatedTickets(UserModel user, {int? limit}) {
    return getOfficerTickets(user).map((tickets) {
      final escalated = tickets.where(_isOpenEscalatedTicket).toList();
      escalated.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      if (limit != null && limit > 0 && escalated.length > limit) {
        return escalated.take(limit).toList();
      }
      return escalated;
    });
  }

  // Get Subordinate Staff
  Stream<List<UserModel>> getSubordinateStaff(UserModel user) {
    String desig = (user.designation ?? '').toUpperCase();
    String role = (user.role ?? '').toUpperCase();

    String? scopeField;
    String? scopeValue;

    if (desig.contains('CHIEF') || role == 'CE' || role.startsWith('ce_')) {
      scopeField = 'regionId';
      scopeValue = user.regionId;
    } else if (desig.contains('SUPERINTEND') || role == 'SE' || role.startsWith('se_')) {
      scopeField = 'circleId';
      scopeValue = user.circleId;
    } else if (desig.contains('EXECUTIVE') && !desig.contains('DEPUTY') || role == 'EE' || role.startsWith('ee_')) {
      scopeField = 'divisionId';
      scopeValue = user.divisionId;
    } else if (desig.contains('DEPUTY') || role == 'DYEE' || desig.contains('DE') || role == 'DE' || role.startsWith('dee_')) {
      scopeField = 'divisionId';
      scopeValue = user.divisionId;
    } else if (desig.contains('ASSISTANT') || role == 'AE' || role.startsWith('ae_')) {
      scopeField = 'officeId';
      scopeValue = user.officeId;
    } else if (desig.contains('JUNIOR') || role == 'JE' || role.startsWith('je_')) {
      scopeField = 'officeId';
      scopeValue = user.officeId;
    } else {
      return Stream.value([]);
    }

    if (scopeValue == null) {
      return Stream.value([]);
    }

    return _firestore.collection('USERS').where(scopeField, isEqualTo: scopeValue).snapshots().map((s) {
      final staff = s.docs.map((d) => UserModel.fromMap(d.data() as Map<String, dynamic>))
          .where((u) => u.userId != user.userId)
          .where((u) => _isSubordinateForUser(u, user))
          .toList();
      staff.sort((a, b) => a.designation.compareTo(b.designation));
      return staff;
    });
  }

  bool _isSubordinateForUser(UserModel candidate, UserModel user) {
    final candidateRole = candidate.role.toUpperCase();
    final candidateDesignation = candidate.designation.toUpperCase();
    final userRole = user.role.toUpperCase();
    final userDesignation = user.designation.toUpperCase();

    bool isFieldStaff(String roleValue, String designationValue) {
      return roleValue.startsWith('LINEMAN') ||
          roleValue.startsWith('PLUMBER') ||
          roleValue.startsWith('ROAD_WORKER') ||
          roleValue.startsWith('SANITATION_WORKER') ||
          roleValue.startsWith('SANITARY_INSPECTOR') ||
          roleValue.startsWith('MUKADAM') ||
          roleValue.startsWith('HEALTH_WORKER') ||
          roleValue.startsWith('TECHNICIAN') ||
          designationValue.contains('WORKER') ||
          designationValue.contains('TECHNICIAN') ||
          designationValue.contains('INSPECTOR') ||
          designationValue.contains('SUPERVISOR');
    }

    if (userDesignation.contains('CHIEF') || userRole == 'CE' || userRole.startsWith('ce_')) {
      return candidateDesignation.contains('SUPERINTEND') || candidateRole.startsWith('se_');
    }

    if (userDesignation.contains('SUPERINTEND') || userRole == 'SE' || userRole.startsWith('se_')) {
      return candidateDesignation.contains('EXECUTIVE') || candidateRole.startsWith('ee_');
    }

    if (userDesignation.contains('EXECUTIVE') && !userDesignation.contains('DEPUTY') || userRole == 'EE' || userRole.startsWith('ee_')) {
      return candidateDesignation.contains('DEPUTY') ||
          candidateDesignation.contains('ASSISTANT') ||
          candidateDesignation.contains('JUNIOR') ||
          candidateRole.startsWith('dee_') ||
          candidateRole.startsWith('ae_') ||
          candidateRole.startsWith('je_') ||
          isFieldStaff(candidateRole, candidateDesignation);
    }

    if (userDesignation.contains('DEPUTY') || userRole == 'DYEE' || userRole == 'DE' || userRole.startsWith('dee_')) {
      return candidateDesignation.contains('ASSISTANT') ||
          candidateDesignation.contains('JUNIOR') ||
          candidateRole.startsWith('ae_') ||
          candidateRole.startsWith('je_') ||
          isFieldStaff(candidateRole, candidateDesignation);
    }

    if (userDesignation.contains('ASSISTANT') || userRole == 'AE' || userRole.startsWith('ae_')) {
      return candidateDesignation.contains('JUNIOR') ||
          candidateRole.startsWith('je_') ||
          isFieldStaff(candidateRole, candidateDesignation);
    }

    if (userDesignation.contains('JUNIOR') || userRole == 'JE' || userRole.startsWith('je_')) {
      return isFieldStaff(candidateRole, candidateDesignation);
    }

    return false;
  }
  
  // Update Ticket Status
  Future<void> updateTicketStatus(String ticketId, String newStatus, {String? officerId, String? rejectionReason}) async {
    Map<String, dynamic> updates = {
      'status': newStatus,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    
    if (newStatus == AppConstants.statusResolved) {
      updates['resolvedAt'] = FieldValue.serverTimestamp();
      updates['escalationLevel'] = 0; // De-escalate upon resolution
    } else if (newStatus == 'Closed') {
      updates['escalationLevel'] = 0;
    } else if (newStatus == 'Rejected') {
      updates['escalationLevel'] = 0;
      if (rejectionReason != null) {
        updates['rejectionReason'] = rejectionReason;
      }
    }

    await _firestore.collection('TICKETS').doc(ticketId).update(updates);
    
    // Log status change
    await _firestore.collection('TICKET_STATUS_LOGS').add({
      'ticketId': ticketId,
      'status': newStatus,
      'changedBy': officerId,
      'timestamp': FieldValue.serverTimestamp(),
      'note': rejectionReason,
    });

    // NOTIFICATIONS
    try {
      // Fetch ticket to get involved parties
      final ticketDoc = await _firestore.collection('TICKETS').doc(ticketId).get();
      if (ticketDoc.exists) {
        final data = ticketDoc.data()!;
        final citizenId = data['citizenId'];
        final currentOwnerId = data['currentOwnerId'];
        final title = data['title'] ?? 'Complaint';

        // 1. Notify Citizen
        if (citizenId != null) {
          String notifTitle = 'Ticket Updated';
          String notifBody = 'Your complaint ${ticketId} is now $newStatus.';

          if (newStatus == 'In Progress') {
             notifTitle = 'Complaint In Progress';
          } else if (newStatus == 'Resolved') {
             notifTitle = 'Complaint Resolved';
          } else if (newStatus == 'Rejected') {
             notifTitle = 'Complaint Rejected';
             notifBody = 'Your complaint "$title" has been rejected.\nReason: ${rejectionReason ?? "Invalid Details"}';
          }
          
          await _notificationService.sendNotification(
            title: notifTitle,
            body: notifBody,
            userId: citizenId,
            recipientEmail: null,
            type: 'ticket_status',
            ticketId: ticketId,
          );
        }

        // 2. Notify Current Owner (if different from changer) - simplified, notify owner always
        if (currentOwnerId != null && currentOwnerId != officerId) {
           final ownerEmail = await _resolveUserEmail(currentOwnerId);
           await _notificationService.sendNotification(
            title: 'Ticket Updated',
            body: 'Ticket ${ticketId} status changed to $newStatus.',
            userId: currentOwnerId,
            recipientEmail: ownerEmail,
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

  Future<void> submitResolutionForVerification({
    required String ticketId,
    required String officerId,
    required String resolutionDescription,
    required List<String> resolutionImageUrls,
  }) async {
    final cleanDescription = resolutionDescription.trim();
    if (cleanDescription.isEmpty) {
      throw Exception('Resolution description is required.');
    }
    if (resolutionImageUrls.isEmpty) {
      throw Exception('At least one resolution image is required.');
    }

    await _firestore.collection('TICKETS').doc(ticketId).update({
      'status': AppConstants.statusResolved,
      'updatedAt': FieldValue.serverTimestamp(),
      'resolvedAt': FieldValue.serverTimestamp(),
      'escalationLevel': 0,
      'resolutionDescription': cleanDescription,
      'resolutionImageUrls': resolutionImageUrls,
      'resolutionSubmittedAt': FieldValue.serverTimestamp(),
      'resolutionSubmittedBy': officerId,
    });

    await _firestore.collection('TICKET_STATUS_LOGS').add({
      'ticketId': ticketId,
      'status': AppConstants.statusResolved,
      'changedBy': officerId,
      'timestamp': FieldValue.serverTimestamp(),
      'note': cleanDescription,
    });

    final ticketDoc = await _firestore.collection('TICKETS').doc(ticketId).get();
    if (!ticketDoc.exists) return;
    final data = ticketDoc.data()!;
    final citizenId = data['citizenId']?.toString();
    if (citizenId == null || citizenId.isEmpty) return;

    await _notificationService.sendNotification(
      title: 'Complaint Resolved',
      body: 'Your complaint has been resolved. Officer uploaded solved-site image(s) and work description.',
      userId: citizenId,
      recipientEmail: null,
      type: 'ticket_resolved',
      ticketId: ticketId,
    );
  }

  Future<List<TicketModel>> getPreviouslySolvedComplaints({
    required TicketModel sourceTicket,
    int limit = 8,
  }) async {
    if (sourceTicket.latitude == null || sourceTicket.longitude == null) {
      return [];
    }

    final normalizedSourceTitle = _normalizeTitle(sourceTicket.title);
    final sourceTokens = _tokenizeTitle(normalizedSourceTitle);
    if (normalizedSourceTitle.isEmpty) {
      return [];
    }

    Query query = _firestore.collection('TICKETS');

    // Keep query scope narrow to avoid heavy reads and stay aligned with officer jurisdiction.
    if (sourceTicket.officeId != null && sourceTicket.officeId!.isNotEmpty) {
      query = query.where('officeId', isEqualTo: sourceTicket.officeId);
    } else if (sourceTicket.regionId != null && sourceTicket.regionId!.isNotEmpty) {
      query = query.where('regionId', isEqualTo: sourceTicket.regionId);
    } else if (sourceTicket.circleId != null && sourceTicket.circleId!.isNotEmpty) {
      query = query.where('circleId', isEqualTo: sourceTicket.circleId);
    } else if (sourceTicket.divisionId != null && sourceTicket.divisionId!.isNotEmpty) {
      query = query.where('divisionId', isEqualTo: sourceTicket.divisionId);
    }

    final snapshot = await query.get();
    final matches = <TicketModel>[];

    for (final doc in snapshot.docs) {
      final ticket = TicketModel.fromMap(doc.data() as Map<String, dynamic>);

      if (ticket.ticketId == sourceTicket.ticketId) continue;

      final isSolved = ticket.status == AppConstants.statusResolved ||
          ticket.status == AppConstants.statusClosed;
      if (!isSolved) continue;

      if (sourceTicket.departmentId.isNotEmpty &&
          ticket.departmentId != sourceTicket.departmentId) {
        continue;
      }

      final normalizedCandidateTitle = _normalizeTitle(ticket.title);
      final candidateTokens = _tokenizeTitle(normalizedCandidateTitle);
      if (!_isTitleMatch(
        sourceTitle: normalizedSourceTitle,
        candidateTitle: normalizedCandidateTitle,
        sourceTokens: sourceTokens,
        candidateTokens: candidateTokens,
      )) {
        continue;
      }

      if (ticket.latitude == null || ticket.longitude == null) continue;

      final distanceMeters = Geolocator.distanceBetween(
        sourceTicket.latitude!,
        sourceTicket.longitude!,
        ticket.latitude!,
        ticket.longitude!,
      );
      if (distanceMeters > 100) continue;

        final hasResolutionProof =
          (ticket.resolutionDescription != null &&
              ticket.resolutionDescription!.trim().isNotEmpty) ||
          ticket.resolutionImageUrls.isNotEmpty;
      if (!hasResolutionProof) continue;

      matches.add(ticket);
    }

    // If no strict scoped result is found, run a global strict fallback.
    if (matches.isEmpty) {
      final globalSnapshot = await _firestore.collection('TICKETS').get();
      for (final doc in globalSnapshot.docs) {
        final ticket = TicketModel.fromMap(doc.data() as Map<String, dynamic>);
        if (_isStrictHistoricalMatch(sourceTicket, ticket, normalizedSourceTitle, sourceTokens)) {
          matches.add(ticket);
        }
      }
    }

    matches.sort((a, b) {
      final left = a.resolvedAt ?? a.createdAt;
      final right = b.resolvedAt ?? b.createdAt;
      return right.compareTo(left);
    });

    return matches.take(limit).toList();
  }

  bool _isStrictHistoricalMatch(
    TicketModel sourceTicket,
    TicketModel ticket,
    String normalizedSourceTitle,
    Set<String> sourceTokens,
  ) {
    if (ticket.ticketId == sourceTicket.ticketId) return false;

    final isSolved = ticket.status == AppConstants.statusResolved ||
        ticket.status == AppConstants.statusClosed;
    if (!isSolved) return false;

    if (sourceTicket.departmentId.isNotEmpty &&
        ticket.departmentId != sourceTicket.departmentId) {
      return false;
    }

    final normalizedCandidateTitle = _normalizeTitle(ticket.title);
    final candidateTokens = _tokenizeTitle(normalizedCandidateTitle);
    if (!_isTitleMatch(
      sourceTitle: normalizedSourceTitle,
      candidateTitle: normalizedCandidateTitle,
      sourceTokens: sourceTokens,
      candidateTokens: candidateTokens,
    )) {
      return false;
    }

    if (ticket.latitude == null || ticket.longitude == null) return false;

    final distanceMeters = Geolocator.distanceBetween(
      sourceTicket.latitude!,
      sourceTicket.longitude!,
      ticket.latitude!,
      ticket.longitude!,
    );
    if (distanceMeters > 100) return false;

    final hasResolutionProof =
        (ticket.resolutionDescription != null &&
            ticket.resolutionDescription!.trim().isNotEmpty) ||
        ticket.resolutionImageUrls.isNotEmpty;
    if (!hasResolutionProof) return false;

    return true;
  }

  String _normalizeTitle(String input) {
    return input
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
        .trim()
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  Set<String> _tokenizeTitle(String normalizedTitle) {
    final stopwords = <String>{
      'the', 'and', 'for', 'with', 'from', 'this', 'that', 'near', 'road',
      'area', 'issue', 'problem', 'complaint', 'new', 'old', 'not', 'is', 'are', 'to'
    };

    return normalizedTitle
        .split(' ')
        .where((w) => w.length >= 3 && !stopwords.contains(w))
        .toSet();
  }

  bool _isTitleMatch({
    required String sourceTitle,
    required String candidateTitle,
    required Set<String> sourceTokens,
    required Set<String> candidateTokens,
  }) {
    if (sourceTitle == candidateTitle) return true;

    // Accept minor phrasing differences such as prefixes/suffixes.
    if (sourceTitle.length >= 6 &&
        candidateTitle.length >= 6 &&
        (sourceTitle.contains(candidateTitle) || candidateTitle.contains(sourceTitle))) {
      return true;
    }

    if (sourceTokens.isEmpty || candidateTokens.isEmpty) return false;

    final overlap = sourceTokens.intersection(candidateTokens);
    if (overlap.isEmpty) return false;

    final smaller = sourceTokens.length < candidateTokens.length
        ? sourceTokens.length
        : candidateTokens.length;
    final ratio = overlap.length / smaller;

    // Require strong lexical match while allowing small wording differences.
    return overlap.length >= 2 || ratio >= 0.6;
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
      // 1. Fetch recent active clusters (Active OR In Progress)
      final snapshot = await _firestore.collection('CLUSTERS')
          .where('status', whereIn: ['Active', 'In Progress'])
          .orderBy('lastUpdatedAt', descending: true)
          .limit(50)
          .get();

      final allClusters = snapshot.docs.map((d) => ComplaintClusterModel.fromMap(d.data() as Map<String, dynamic>)).toList();
      final List<ComplaintClusterModel> validClusters = [];

      // 2. Filter by Jurisdiction (Strict - restored as per user request)
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
                isValid = true; // Show all in region for now, or filter escalated if preferred
             }
         } else if (desig.contains('SUPERINTEND') || role == 'SE') {
             // SE -> Circle + Escalated
             if (repTicket.circleId == user.circleId) {
                isValid = true;
             }
         } else if (desig.contains('EXECUTIVE') && !desig.contains('DEPUTY') || role == 'EE') {
             // EE -> Division + Escalated
             if (repTicket.divisionId == user.divisionId) {
                isValid = true;
             }
         } else if (desig.contains('DEPUTY') || role == 'DYEE' || desig.contains('DE') || role == 'DE') {
             // DyEE -> Division/Region subset
             if (repTicket.divisionId == user.divisionId || (repTicket.divisionId == null && repTicket.officeId == user.officeId)) {
                isValid = true;
             }
         } else {
             // JE/AE/Field -> Office Strict
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



