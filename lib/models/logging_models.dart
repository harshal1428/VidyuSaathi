import 'package:cloud_firestore/cloud_firestore.dart';

class TicketStatusLog {
  final String logId;
  final String ticketId;
  final String status;
  final String updatedBy;
  final String? note;
  final DateTime timestamp;

  TicketStatusLog({
    required this.logId,
    required this.ticketId,
    required this.status,
    required this.updatedBy,
    this.note,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'logId': logId,
      'ticketId': ticketId,
      'status': status,
      'updatedBy': updatedBy,
      'note': note,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}

class EscalationLog {
  final String escalationId;
  final String ticketId;
  final String fromRole;
  final String toRole;
  final String reason;
  final DateTime escalatedAt;

  EscalationLog({
    required this.escalationId,
    required this.ticketId,
    required this.fromRole,
    required this.toRole,
    required this.reason,
    required this.escalatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'escalationId': escalationId,
      'ticketId': ticketId,
      'fromRole': fromRole,
      'toRole': toRole,
      'reason': reason,
      'escalatedAt': Timestamp.fromDate(escalatedAt),
    };
  }
}

class NotificationModel {
  final String notificationId;
  final String userId;
  final String ticketId;
  final String type;
  final String message;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.notificationId,
    required this.userId,
    required this.ticketId,
    required this.type,
    required this.message,
    required this.isRead,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'notificationId': notificationId,
      'userId': userId,
      'ticketId': ticketId,
      'type': type,
      'message': message,
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

class ClusterTicket {
  final String clusterId;
  final String ticketId;

  ClusterTicket({required this.clusterId, required this.ticketId});

  Map<String, dynamic> toMap() {
    return {
      'clusterId': clusterId,
      'ticketId': ticketId,
    };
  }
}
