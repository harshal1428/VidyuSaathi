import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../domain/models/citizen/ticket_model.dart';
import '../../../core/constants/app_constants.dart';

/// Database service for citizen-related Firestore operations
class CitizenDatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Create a new ticket
  Future<void> createTicket(TicketModel ticket) async {
    await _firestore
        .collection('TICKETS')
        .doc(ticket.ticketId)
        .set(ticket.toMap());
  }

  /// Get tickets for a specific citizen
  Stream<List<TicketModel>> getCitizenTickets(String citizenId) {
    return _firestore
        .collection('TICKETS')
        .where('citizenId', isEqualTo: citizenId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => TicketModel.fromMap(doc.data()))
          .toList();
    });
  }

  /// Get a single ticket by ID
  Future<TicketModel?> getTicketById(String ticketId) async {
    final doc = await _firestore.collection('TICKETS').doc(ticketId).get();
    if (doc.exists) {
      return TicketModel.fromMap(doc.data()!);
    }
    return null;
  }

  /// Get tickets stream for real-time updates
  Stream<TicketModel?> getTicketStream(String ticketId) {
    return _firestore
        .collection('TICKETS')
        .doc(ticketId)
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        return TicketModel.fromMap(doc.data()!);
      }
      return null;
    });
  }

  /// Get tickets for officer based on role and assignment
  Stream<List<TicketModel>> getOfficerTickets(
    String officerId,
    String role, {
    String? status,
  }) {
    Query<Map<String, dynamic>> query = _firestore.collection('TICKETS');

    if (status != null) {
      query = query.where('status', isEqualTo: status);
    }

    // Filter by assigned officer
    query = query.where('assignedOfficerId', isEqualTo: officerId);

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => TicketModel.fromMap(doc.data()))
          .toList();
    });
  }

  /// Update ticket status
  Future<void> updateTicketStatus(
    String ticketId,
    String newStatus, {
    String? officerId,
  }) async {
    Map<String, dynamic> updates = {
      'status': newStatus,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (newStatus == AppConstants.statusResolved) {
      updates['resolvedAt'] = FieldValue.serverTimestamp();
    }

    await _firestore.collection('TICKETS').doc(ticketId).update(updates);

    // Log status change
    await _firestore.collection('TICKET_STATUS_LOGS').add({
      'ticketId': ticketId,
      'status': newStatus,
      'changedBy': officerId,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  /// Add a comment to a ticket
  Future<void> addTicketComment({
    required String ticketId,
    required String userId,
    required String userName,
    required String comment,
  }) async {
    await _firestore
        .collection('TICKETS')
        .doc(ticketId)
        .collection('comments')
        .add({
      'userId': userId,
      'userName': userName,
      'comment': comment,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Get comments for a ticket
  Stream<List<Map<String, dynamic>>> getTicketComments(String ticketId) {
    return _firestore
        .collection('TICKETS')
        .doc(ticketId)
        .collection('comments')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  /// Get ticket count by status for a citizen
  Future<Map<String, int>> getCitizenTicketCounts(String citizenId) async {
    final snapshot = await _firestore
        .collection('TICKETS')
        .where('citizenId', isEqualTo: citizenId)
        .get();

    Map<String, int> counts = {
      'total': snapshot.docs.length,
      AppConstants.statusCreated: 0,
      AppConstants.statusAssigned: 0,
      AppConstants.statusInProgress: 0,
      AppConstants.statusResolved: 0,
      AppConstants.statusClosed: 0,
    };

    for (var doc in snapshot.docs) {
      final status = doc.data()['status'] as String? ?? '';
      if (counts.containsKey(status)) {
        counts[status] = (counts[status] ?? 0) + 1;
      }
    }

    return counts;
  }
}
