import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ticket_model.dart';
import '../models/user_model.dart';
import '../core/constants.dart';

class EscalationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Manual Trigger to simulate Scheduler
  Future<void> runEscalationJob() async {
    print("Running Escalation Job...");
    
    // 1. Fetch ALL unresolved tickets
    // In a real system, you'd use a collection group query or index active tickets.
    final snapshot = await _firestore.collection('TICKETS')
        .where('status', isNotEqualTo: AppConstants.statusResolved)
        .where('status', isNotEqualTo: AppConstants.statusClosed)
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
    if (ticket.status == AppConstants.statusResolved || ticket.status == AppConstants.statusClosed) {
      return;
    }

    if (ticket.assignedAt == null) return;

    // CHECK TIME
    final now = DateTime.now();
    final elapsed = now.difference(ticket.assignedAt!);
    
    // Determine SLA for current level
    // Logic: 
    // FE = Level 0
    // JE = Level 1
    // AE = Level 2
    // DyEE = Level 3
    // EE = Level 4
    // SE = Level 5
    // CE = Level 6
    
    // Default SLA (e.g., 24 hours per level for Prototype, or shorter for demo)
    // For demo: Use shorter times or the ticket's base SLA logic?
    // User asked: "now - assignedAt > SLA(currentOwnerRole)"
    
    // Let's look up current Role SLA
    int slaHours = _getSLAForRole(ticket.currentOwnerRole);
    
    if (elapsed.inHours >= slaHours) {
       // TRIGGER ESCALATION
       await _escalateToNextLevel(ticket);
    }
  }
  
  int _getSLAForRole(String? role) {
    if (role == null) return 24;
    role = role.toUpperCase();
    
    if (role.contains('FIELD') || role == 'FE') return 4; // 4 Hours for Field
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
      // FE -> JE (Same Office)
      nextRole = 'Junior Engineer';
      targetUserId = await _findUserInOffice(ticket.officeId, 'JE');
      
    } else if (currentRole.contains('JUNIOR') || currentRole == 'JE') {
      // JE -> AE (Same Office)
      nextRole = 'Assistant Engineer';
      targetUserId = await _findUserInOffice(ticket.officeId, 'AE');
      
    } else if (currentRole.contains('ASSISTANT') || currentRole == 'AE') {
      // AE -> DyEE (Same Region - Parent of Office)
      nextRole = 'Deputy Executive Engineer';
      targetUserId = await _findUserInRegion(ticket.regionId, 'DyEE');
      
    } else if (currentRole.contains('DEPUTY') || currentRole == 'DYEE') {
      // DyEE -> EE (Same Region/Division - EE is Head of Region usually or Division)
      // Per User: DyEE -> EE
      nextRole = 'Executive Engineer';
      targetUserId = await _findUserInRegion(ticket.regionId, 'EE'); // Assuming EE is also tagged with Region
      
    } else if (currentRole == 'EE' || currentRole.contains('EXECUTIVE')) {
      // EE -> SE (Same Circle)
      nextRole = 'Superintending Engineer';
      targetUserId = await _findUserInCircle(ticket.circleId, 'SE');
      
    } else if (currentRole == 'SE' || currentRole.contains('SUPERINTEND')) {
      // SE -> CE (Same Division/Zone)
      nextRole = 'Chief Engineer';
      targetUserId = await _findUserInDivision(ticket.divisionId, 'CE');
    }

    if (targetUserId != null && targetUserId != ticket.currentOwnerId) {
      print("ESCALATING Ticket ${ticket.ticketId} from $currentRole to $nextRole ($targetUserId)");
      
      await _firestore.collection('TICKETS').doc(ticket.ticketId).update({
        'currentOwnerId': targetUserId,
        'currentOwnerRole': nextRole,
        'status': 'Escalated', // Or keep as In Progress but with 'Escalated' tag? User implies status might change.
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
    } else {
       print("Could not find escalation target for ${ticket.ticketId} ($currentRole)");
    }
  }

  // Helpers
  Future<String?> _findUserInOffice(String? officeId, String shortRole) async {
    if (officeId == null) return null;
    final q = await _firestore.collection('USERS')
        .where('officeId', isEqualTo: officeId)
        .where('role', isEqualTo: shortRole).limit(1).get();
    if (q.docs.isNotEmpty) return q.docs.first['userId'];
    return null;
  }

  Future<String?> _findUserInRegion(String? regionId, String shortRole) async {
    if (regionId == null) return null;
    final q = await _firestore.collection('USERS')
        .where('regionId', isEqualTo: regionId)
        .where('role', isEqualTo: shortRole).limit(1).get();
    if (q.docs.isNotEmpty) return q.docs.first['userId'];
    return null;
  }

  Future<String?> _findUserInCircle(String? circleId, String shortRole) async {
    if (circleId == null) return null;
    final q = await _firestore.collection('USERS')
        .where('circleId', isEqualTo: circleId)
        .where('role', isEqualTo: shortRole).limit(1).get();
    if (q.docs.isNotEmpty) return q.docs.first['userId'];
    return null;
  }
  
  Future<String?> _findUserInDivision(String? divisionId, String shortRole) async {
    // If divisionId is missing/null (e.g. from seeded data), fallback to 'zone_pune'
    String div = divisionId ?? 'zone_pune';
    final q = await _firestore.collection('USERS')
        .where('divisionId', isEqualTo: div)
        .where('role', isEqualTo: shortRole).limit(1).get();
    if (q.docs.isNotEmpty) return q.docs.first['userId'];
    return null;
  }
}
