import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String type; // 'ticket_status', 'assignment', 'escalation'
  final String userId; // Target user
  final String? recipientEmail;
  final String? ticketId;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.userId,
    this.recipientEmail,
    this.ticketId,
    required this.isRead,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'type': type,
      'userId': userId,
      'recipientEmail': recipientEmail,
      'ticketId': ticketId,
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map, String docId) {
    return NotificationModel(
      id: docId,
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      type: map['type'] ?? 'general',
      userId: map['userId'] ?? '',
      recipientEmail: map['recipientEmail'],
      ticketId: map['ticketId'],
      isRead: map['isRead'] ?? false,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}
