import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../models/user_model.dart';

class NotificationService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Create Notification
  Future<void> sendNotification({
    required String title,
    required String body,
    required String userId,
    required String type,
    String? ticketId,
  }) async {
    try {
      await _firestore.collection('NOTIFICATIONS').add({
        'title': title,
        'body': body,
        'type': type,
        'userId': userId,
        'ticketId': ticketId,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error sending notification: $e");
    }
  }

  // Stream Notifications for User
  Stream<List<NotificationModel>> getUserNotifications(String userId) {
    return _firestore
        .collection('NOTIFICATIONS')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(20)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NotificationModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Mark Read
  Future<void> markAsRead(String notificationId) async {
    await _firestore.collection('NOTIFICATIONS').doc(notificationId).update({'isRead': true});
  }

  // Get Unread Count
  Stream<int> getUnreadCount(String userId) {
    return _firestore
        .collection('NOTIFICATIONS')
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }
}
