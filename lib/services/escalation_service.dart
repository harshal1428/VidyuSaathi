import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ticket_model.dart';
import '../models/user_model.dart';
import '../core/constants.dart';

class EscalationService {
  static final Map<String, List<Map<String, dynamic>>> _hierarchyCache = {};

  static Future<List<Map<String, dynamic>>> getDeptHierarchy(String departmentId) async {
    if (_hierarchyCache.containsKey(departmentId)) {
      return _hierarchyCache[departmentId]!;
    }
    final doc = await FirebaseFirestore.instance
        .collection('DEPARTMENTS')
        .doc(departmentId)
        .get();
    if (!doc.exists || doc.data() == null) return [];
    
    final list = List<Map<String, dynamic>>.from(doc.data()!['hierarchy'] as List);
    _hierarchyCache[departmentId] = list;
    return list;
  }
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Timer? _timer;

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

  // Start Background Monitoring (Simulated)
  void startMonitoring() {
    _timer?.cancel();
    // Run immediately
    runEscalationJob();
    // Then every 60 seconds
    _timer = Timer.periodic(const Duration(seconds: 60), (timer) {
      runEscalationJob();
    });
  }

  void stopMonitoring() {
    _timer?.cancel();
  }

  // Manual Trigger to simulate Scheduler
  Future<void> runEscalationJob() async {
    print("Running Escalation Job...");
    
    // 1. Fetch ALL unresolved tickets
    // In a real system, you'd use a collection group query or index active tickets.
    final snapshot = await _firestore.collection('TICKETS')
        .where('status', whereNotIn: [
          AppConstants.statusResolved, 
          AppConstants.statusClosed,
          'Rejected'
        ])
        .get();

    for (var doc in snapshot.docs) {
      try {
        final ticket = TicketModel.fromMap(doc.data());
        await _checkAndEscalateTicket(ticket);
      } catch (e) {
        print("Error processing ticket ${doc.id}: $e");
      }
    }
  }

  Future<void> _checkAndEscalateTicket(TicketModel ticket) async {
    // RESOLUTION RULE: If resolved, ensure no escalation (Double check)
    if (ticket.status == AppConstants.statusResolved || ticket.status == AppConstants.statusClosed || ticket.status == 'Rejected') {
      return;
    }

    if (ticket.assignedAt == null) return;

    // CHECK TIME
    final now = DateTime.now();
    final elapsed = now.difference(ticket.assignedAt!);
    
    // Determine SLA Threshold (in Minutes)
    // Priority: Ticket specific Minutes -> Ticket specific Hours -> Default Role based
    int slaThresholdMinutes;
    if (ticket.slaMinutes != null && ticket.slaMinutes! > 0) {
      slaThresholdMinutes = ticket.slaMinutes!;
    } else if (ticket.adjustedSlaHours > 0) {
      slaThresholdMinutes = ticket.adjustedSlaHours * 60;
    } else if (ticket.slaHours != null) {
      slaThresholdMinutes = ticket.slaHours! * 60;
    } else {
      slaThresholdMinutes = _getSLAForRole(ticket.currentOwnerRole) * 60;
    }
    
    // Check if breached
    if (elapsed.inMinutes >= slaThresholdMinutes) {
       // TRIGGER ESCALATION
       await _escalateToNextLevel(ticket);
    }
  }
  
  int _getSLAForRole(String? role) {
    if (role == null) return 24;
    role = role.toUpperCase();
    
    if (role.contains('FIELD') || role == 'FE') return 4; 
    if (role.contains('JUNIOR') || role == 'JE') return 8; 
    if (role.contains('ASSISTANT') || role == 'AE') return 12; 
    if (role.contains('DEPUTY') || role == 'DYEE') return 24; 
    
    return 24; // Default
  }

  Future<void> _escalateToNextLevel(TicketModel ticket) async {
    String? currentRole = ticket.currentOwnerRole;
    if (currentRole == null) return;

    final hier = await getDeptHierarchy(ticket.departmentId);
    if (hier.isEmpty) return;

    int currentLevel = 1;
    try {
      final node = hier.firstWhere((h) => _roleMatches('${h['role']}', currentRole));
      currentLevel = (node['level'] as num).toInt();
    } catch (e) {
      print("Could not parse level for role: $currentRole");
      if (ticket.escalationLevel > 0) {
        currentLevel = ticket.escalationLevel;
      }
    }

    int nextLevel = currentLevel + 1;
    if (nextLevel > 7) return; // Top of chain

    var nextNode = hier.firstWhere((h) => h['level'] == nextLevel, orElse: () => hier.last);
    String nextRole = nextNode['role'];
    String nextTitle = nextNode['title'];

    String? targetUserId;
    if (nextLevel <= 3) {
      targetUserId = await _findUserInOffice(ticket.officeId, nextRole);
    } else if (nextLevel <= 5) {
      targetUserId = await _findUserInRegion(ticket.regionId, nextRole);
    } else if (nextLevel == 6) {
      targetUserId = await _findUserInCircle(ticket.circleId, nextRole);
    } else {
      targetUserId = await _findUserInDivision(ticket.divisionId, nextRole);
    }

    if (targetUserId != null && targetUserId != ticket.currentOwnerId) {
      print("ESCALATING Ticket ${ticket.ticketId} from $currentRole to $nextRole ($targetUserId)");
      
      await _firestore.collection('TICKETS').doc(ticket.ticketId).update({
        'currentOwnerId': targetUserId,
        'currentOwnerRole': nextRole,
        'status': 'Escalated', 
        'escalationLevel': FieldValue.increment(1),
        'assignedAt': FieldValue.serverTimestamp(), // Reset timer for new owner
        'generatedVia': 'System Escalation',
      });
      
      // Log
      await _firestore.collection('ESCALATION_LOGS').add({
        'ticketId': ticket.ticketId,
        'fromUser': ticket.currentOwnerId,
        'toUser': targetUserId,
        'timestamp': FieldValue.serverTimestamp(),
        'reason': 'SLA Breach',
        'officeId': ticket.officeId,
        'regionId': ticket.regionId,
        'circleId': ticket.circleId,
        'divisionId': ticket.divisionId,
        'departmentId': ticket.departmentId,
      });
      
      // NOTIFICATIONS
      final now = DateTime.now();
      String dateStr = "${now.day}/${now.month}/${now.year}";
      String timeStr = "${now.hour}:${now.minute.toString().padLeft(2, '0')}";

      // 1. Notify NEW Owner (Target)
      final targetEmail = await _resolveUserEmail(targetUserId);
      await _sendNotification(
        userId: targetUserId,
        recipientEmail: targetEmail,
        title: 'Ticket Escalation Alert',
        body: 'You have received an ESCALATED report "${ticket.title}" on "$dateStr" at "$timeStr" from ${ticket.currentOwnerRole}.',
        type: 'escalation_received', // Distinct type if needed
        ticketId: ticket.ticketId,
      );

      // 2. Notify OLD Owner (Source)
      if (ticket.currentOwnerId != null) {
        final sourceEmail = await _resolveUserEmail(ticket.currentOwnerId);
        await _sendNotification(
          userId: ticket.currentOwnerId!,
          recipientEmail: sourceEmail,
          title: 'Ticket Escalated',
          body: 'Your ticket "${ticket.title}" has been ESCALATED to $nextRole due to SLA breach.',
          type: 'escalation_sent',
          ticketId: ticket.ticketId,
        );
      }

      // 3. CHANGE 4 - Downward Disqualification Notification if nextLevel >= 4
      if (nextLevel >= 4) {
         Map<String, dynamic>? l2Node;
         try { l2Node = hier.firstWhere((h) => h['level'] == 2); } catch (e) {}
         
         String originalOfficeName = ticket.officeId ?? 'Local Office'; // Typically fetch office doc to get human name, simplified here.
         String msg = "⚠️ Ticket ${ticket.ticketId} escalated to $nextTitle due to SLA breach. Original assignment: $originalOfficeName";
         
         // In CivicCore model, we use supervisingJEId if original is missing.
         // Let's assume originalAssigneeId defaults to supervisingJEId if left unset by ticket model implementation limit.
         String? originalAssignee = ticket.supervisingJEId; // Ideally ticket.originalAssigneeId if injected
         if (originalAssignee != null) {
          final originalEmail = await _resolveUserEmail(originalAssignee);
          await _sendNotification(userId: originalAssignee, recipientEmail: originalEmail, title: 'Escalation Alert', body: msg, type: 'escalation_warning', ticketId: ticket.ticketId);
         }
         
         if (l2Node != null) {
            String? l2UserId = await _findUserInOffice(ticket.officeId, l2Node['role']);
            if (l2UserId != null && l2UserId != originalAssignee) {
              final l2Email = await _resolveUserEmail(l2UserId);
              await _sendNotification(userId: l2UserId, recipientEmail: l2Email, title: 'Escalation Alert', body: msg, type: 'escalation_warning', ticketId: ticket.ticketId);
            }
         }
      }

    } else {
       print("Could not find escalation target for ${ticket.ticketId} ($currentRole)");
    }
  }

  Future<void> _sendNotification({
    required String userId,
    String? recipientEmail,
    required String title,
    required String body,
    required String type,
    required String ticketId,
  }) async {
    try {
      await FirebaseFirestore.instance.collection('NOTIFICATIONS').add({
        'title': title,
        'body': body,
        'type': type,
        'userId': userId,
        'recipientEmail': recipientEmail,
        'ticketId': ticketId,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Notification Failed: $e");
    }
  }

  // Helpers
  String? _pickBestUserId(QuerySnapshot q) {
      if (q.docs.isEmpty) return null;
      
      // Prefer canonical USERS doc id when it is a Firebase Auth UID.
      final firstDocId = q.docs.first.id;
      String bestId = firstDocId;
      if (bestId.length != 28) {
        bestId = (q.docs.first.data() as Map<String, dynamic>)['userId'] ?? '';
      }
      
      // Look for better match (Auth UID)
      for (var doc in q.docs) {
         final docId = doc.id;
         if (docId.length == 28) {
            return docId;
         }

         String uid = (doc.data() as Map<String, dynamic>)['userId'] ?? '';
         if (uid.length == 28 &&
             !uid.startsWith('je_') &&
             !uid.startsWith('ae_') &&
             !uid.startsWith('dyee_') &&
             !uid.startsWith('ee_') &&
             !uid.startsWith('se_') &&
             !uid.startsWith('ce_')) {
            return uid;
         }
      }
      return bestId;
  }

  bool _roleMatches(String expectedRole, String actualRole) {
    final expected = expectedRole.trim().toUpperCase();
    final actual = actualRole.trim().toUpperCase();
    if (expected == actual) return true;
    return actual.startsWith('${expected}_') || expected.startsWith('${actual}_');
  }

  Future<String?> _findUserByScope(String scopeField, String? scopeValue, String shortRole) async {
    if (scopeValue == null) return null;

    final exact = await _firestore
        .collection('USERS')
        .where(scopeField, isEqualTo: scopeValue)
        .where('role', isEqualTo: shortRole)
        .limit(10)
        .get();
    final exactPicked = _pickBestUserId(exact);
    if (exactPicked != null && exactPicked.isNotEmpty) return exactPicked;

    // Fallback for department-specific role codes like je_electricity, ae_water, etc.
    final broad = await _firestore
        .collection('USERS')
        .where(scopeField, isEqualTo: scopeValue)
        .limit(50)
        .get();

    final filtered = broad.docs.where((doc) {
      final role = (doc.data()['role'] ?? '').toString();
      return _roleMatches(shortRole, role);
    }).toList();

    if (filtered.isEmpty) return null;

    for (final doc in filtered) {
      if (doc.id.length == 28) return doc.id;
    }

    for (final doc in filtered) {
      final uid = (doc.data()['userId'] ?? '').toString();
      if (uid.length == 28) return uid;
    }

    final first = filtered.first;
    final firstUid = (first.data()['userId'] ?? '').toString();
    return firstUid.isNotEmpty ? firstUid : first.id;
  }

  Future<String?> _findUserInOffice(String? officeId, String shortRole) async {
    return _findUserByScope('officeId', officeId, shortRole);
  }

  Future<String?> _findUserInRegion(String? regionId, String shortRole) async {
    return _findUserByScope('regionId', regionId, shortRole);
  }

  Future<String?> _findUserInCircle(String? circleId, String shortRole) async {
    return _findUserByScope('circleId', circleId, shortRole);
  }
  
  Future<String?> _findUserInDivision(String? divisionId, String shortRole) async {
    String div = divisionId ?? 'zone_pune';
    return _findUserByScope('divisionId', div, shortRole);
  }
}
