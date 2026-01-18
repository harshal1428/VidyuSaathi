import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/ticket_model.dart';
import '../core/constants.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  // Create Ticket
  Future<void> createTicket(TicketModel ticket) async {
    await _firestore.collection('TICKETS').doc(ticket.ticketId).set(ticket.toMap());
  }

  // Get Tickets for Citizen
  Stream<List<TicketModel>> getCitizenTickets(String citizenId) {
    return _firestore
        .collection('TICKETS')
        .where('citizenId', isEqualTo: citizenId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => TicketModel.fromMap(doc.data() as Map<String, dynamic>)).toList();
    });
  }

  // Get Tickets for Officer (Task Management)
  Stream<List<TicketModel>> getOfficerTickets(String officerId, String role, {String? status}) {
    Query query = _firestore.collection('TICKETS');

    // Logic for fetching tickets based on role/assignment
    // If assigned directly to officer
    if (status != null) {
        query = query.where('status', isEqualTo: status);
    }
    
    // This is a simplified query. In reality, officers might see tickets based on Region/Office.
    // For "My Tasks", it's usually tickets assigned to them.
    query = query.where('assignedOfficerId', isEqualTo: officerId);

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => TicketModel.fromMap(doc.data() as Map<String, dynamic>)).toList();
    });
  }
  
  // Update Ticket Status
  Future<void> updateTicketStatus(String ticketId, String newStatus, {String? officerId}) async {
    Map<String, dynamic> updates = {
      'status': newStatus,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    
    if (newStatus == AppConstants.statusResolved) {
      updates['resolvedAt'] = FieldValue.serverTimestamp();
    }

    await _firestore.collection('TICKETS').doc(ticketId).update(updates);
    
    // Log status change (Optional but good practice)
    await _firestore.collection('TICKET_STATUS_LOGS').add({
      'ticketId': ticketId,
      'status': newStatus,
      'changedBy': officerId,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
