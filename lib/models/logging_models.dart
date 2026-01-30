import 'package:cloud_firestore/cloud_firestore.dart';

class TicketGenerationLog {
  final String generationId;
  final String ticketId;
  final String generatedBy;
  final String generatedVia;
  final DateTime generatedAt;
  final String initialOfficeId;
  final String initialRegionId;
  final String initialCircleId;

  TicketGenerationLog({
    required this.generationId,
    required this.ticketId,
    required this.generatedBy,
    required this.generatedVia,
    required this.generatedAt,
    required this.initialOfficeId,
    required this.initialRegionId,
    required this.initialCircleId,
  });

  Map<String, dynamic> toMap() => {
    'generationId': generationId,
    'ticketId': ticketId,
    'generatedBy': generatedBy,
    'generatedVia': generatedVia,
    'generatedAt': Timestamp.fromDate(generatedAt),
    'initialOfficeId': initialOfficeId,
    'initialRegionId': initialRegionId,
    'initialCircleId': initialCircleId,
  };
}

class TicketStatusLog {
  final String logId;
  final String ticketId;
  final String updatedBy;
  final String role;
  final String status;
  final String remark;
  final DateTime timestamp;

  TicketStatusLog({
    required this.logId,
    required this.ticketId,
    required this.updatedBy,
    required this.role,
    required this.status,
    required this.remark,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() => {
    'logId': logId,
    'ticketId': ticketId,
    'updatedBy': updatedBy,
    'role': role,
    'status': status,
    'remark': remark,
    'timestamp': Timestamp.fromDate(timestamp),
  };
}

class EscalationLog {
  final String escalationId;
  final String ticketId;
  final String fromRole;
  final String toRole;
  final String fromUserId;
  final String toUserId;
  final String reason;
  final DateTime escalatedAt;

  EscalationLog({
    required this.escalationId,
    required this.ticketId,
    required this.fromRole,
    required this.toRole,
    required this.fromUserId,
    required this.toUserId,
    required this.reason,
    required this.escalatedAt,
  });

  Map<String, dynamic> toMap() => {
    'escalationId': escalationId,
    'ticketId': ticketId,
    'fromRole': fromRole,
    'toRole': toRole,
    'fromUserId': fromUserId,
    'toUserId': toUserId,
    'reason': reason,
    'escalatedAt': Timestamp.fromDate(escalatedAt),
  };
}

class ClusterTicket {
  final String clusterTicketId;
  final String clusterId;
  final String ticketId;
  final DateTime addedAt;

  ClusterTicket({
    required this.clusterTicketId,
    required this.clusterId,
    required this.ticketId,
    required this.addedAt,
  });

  Map<String, dynamic> toMap() => {
    'clusterTicketId': clusterTicketId,
    'clusterId': clusterId,
    'ticketId': ticketId,
    'addedAt': Timestamp.fromDate(addedAt),
  };
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

  Map<String, dynamic> toMap() => {
    'notificationId': notificationId,
    'userId': userId,
    'ticketId': ticketId,
    'type': type,
    'message': message,
    'isRead': isRead,
    'createdAt': Timestamp.fromDate(createdAt),
  };
  
  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      notificationId: map['notificationId'] ?? '',
      userId: map['userId'] ?? '',
      ticketId: map['ticketId'] ?? '',
      type: map['type'] ?? '',
      message: map['message'] ?? '',
      isRead: map['isRead'] ?? false,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}


