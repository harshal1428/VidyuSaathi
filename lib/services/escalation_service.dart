import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ticket_model.dart';
import '../models/user_model.dart';
import '../core/constants.dart';

class EscalationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Timer? _timer;

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
    if (ticket.slaMinutes != null) {
      slaThresholdMinutes = ticket.slaMinutes!;
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
    String? currentRole = ticket.currentOwnerRole?.toUpperCase();
    if (currentRole == null) return;
    
    String? nextRole;
    String? targetUserId;
    
    // ESCALATION CHAIN
    if (currentRole.contains('FIELD') || currentRole == 'FE') {
      // FE -> JE
      nextRole = 'Junior Engineer';
      targetUserId = await _findUserInOffice(ticket.officeId, 'JE');
      
    } else if (currentRole.contains('JUNIOR') || currentRole == 'JE') {
      // JE -> AE
      nextRole = 'Assistant Engineer';
      targetUserId = await _findUserInOffice(ticket.officeId, 'AE');
      
    } else if (currentRole.contains('ASSISTANT') || currentRole == 'AE') {
      // AE -> DyEE
      nextRole = 'Deputy Executive Engineer';
      targetUserId = await _findUserInRegion(ticket.regionId, 'DyEE');
      
    } else if (currentRole.contains('DEPUTY') || currentRole == 'DYEE') {
      // DyEE -> EE
      nextRole = 'Executive Engineer';
      targetUserId = await _findUserInRegion(ticket.regionId, 'EE'); 
      
    } else if (currentRole == 'EE' || currentRole.contains('EXECUTIVE')) {
      // EE -> SE
      nextRole = 'Superintending Engineer';
      targetUserId = await _findUserInCircle(ticket.circleId, 'SE');
      
    } else if (currentRole == 'SE' || currentRole.contains('SUPERINTEND')) {
      // SE -> CE
      nextRole = 'Chief Engineer';
      targetUserId = await _findUserInDivision(ticket.divisionId, 'CE');
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
        'reason': 'SLA Breach'
      });
      
      // NOTIFICATIONS
      final now = DateTime.now();
      String dateStr = "${now.day}/${now.month}/${now.year}";
      String timeStr = "${now.hour}:${now.minute.toString().padLeft(2, '0')}";

      // 1. Notify NEW Owner (Target)
      await _sendNotification(
        userId: targetUserId,
        title: 'Ticket Escalation Alert',
        body: 'You have received an ESCALATED report "${ticket.title}" on "$dateStr" at "$timeStr" from ${ticket.currentOwnerRole}.',
        type: 'escalation_received', // Distinct type if needed
        ticketId: ticket.ticketId,
      );

      // 2. Notify OLD Owner (Source)
      if (ticket.currentOwnerId != null) {
        await _sendNotification(
          userId: ticket.currentOwnerId!,
          title: 'Ticket Escalated',
          body: 'Your ticket "${ticket.title}" has been ESCALATED to $nextRole due to SLA breach.',
          type: 'escalation_sent',
          ticketId: ticket.ticketId,
        );
      }

    } else {
       print("Could not find escalation target for ${ticket.ticketId} ($currentRole)");
    }
  }

  Future<void> _sendNotification({
    required String userId,
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
      
      // Default info
      String bestId = q.docs.first['userId'];
      
      // Look for better match (Auth UID)
      for (var doc in q.docs) {
         String uid = doc['userId'] ?? '';
         if (uid.length == 28 && !uid.startsWith('je_') && !uid.startsWith('ae_') && !uid.startsWith('dyee_') && !uid.startsWith('ee_') && !uid.startsWith('se_') && !uid.startsWith('ce_')) {
            return uid;
         }
      }
      return bestId;
  }

  Future<String?> _findUserInOffice(String? officeId, String shortRole) async {
    if (officeId == null) return null;
    final q = await _firestore.collection('USERS')
        .where('officeId', isEqualTo: officeId)
        .where('role', isEqualTo: shortRole).limit(10).get(); // Limit 10 for better searching
    return _pickBestUserId(q);
  }

  Future<String?> _findUserInRegion(String? regionId, String shortRole) async {
    if (regionId == null) return null;
    final q = await _firestore.collection('USERS')
        .where('regionId', isEqualTo: regionId)
        .where('role', isEqualTo: shortRole).limit(10).get();
    return _pickBestUserId(q);
  }

  Future<String?> _findUserInCircle(String? circleId, String shortRole) async {
    if (circleId == null) return null;
    final q = await _firestore.collection('USERS')
        .where('circleId', isEqualTo: circleId)
        .where('role', isEqualTo: shortRole).limit(10).get();
    return _pickBestUserId(q);
  }
  
  Future<String?> _findUserInDivision(String? divisionId, String shortRole) async {
    // If divisionId is missing/null (e.g. from seeded data), fallback to 'zone_pune'
    String div = divisionId ?? 'zone_pune';
    final q = await _firestore.collection('USERS')
        .where('divisionId', isEqualTo: div)
        .where('role', isEqualTo: shortRole).limit(10).get();
     return _pickBestUserId(q);
  }
}
