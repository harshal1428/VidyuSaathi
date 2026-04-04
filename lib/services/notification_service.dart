import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/notification_model.dart';

class NotificationService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _resolveRecipientEmail() {
    final authUser = FirebaseAuth.instance.currentUser;
    final email = authUser?.email?.trim();
    if (email == null || email.isEmpty) return null;
    return email;
  }

  List<String> _resolveRecipientIds(String userId) {
    final ids = <String>{};
    final authUid = FirebaseAuth.instance.currentUser?.uid;
    if (authUid != null && authUid.trim().isNotEmpty) ids.add(authUid.trim());
    if (userId.trim().isNotEmpty) {
      ids.add(userId.trim());
    }
    return ids.toList();
  }

  List<NotificationModel> _parseNotifications(QuerySnapshot snapshot) {
    return snapshot.docs
        .map((doc) => NotificationModel.fromMap(
            doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  List<NotificationModel> _mergeAndSortNotifications(
    List<NotificationModel> byId,
    List<NotificationModel> byEmail,
  ) {
    final map = <String, NotificationModel>{};
    for (final n in byId) {
      map[n.id] = n;
    }
    for (final n in byEmail) {
      map[n.id] = n;
    }

    final merged = map.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return merged.length > 20 ? merged.take(20).toList() : merged;
  }

  Stream<List<NotificationModel>> _buildNotificationStream({
    required List<String> ids,
    required String? recipientEmail,
  }) {
    final byIdQuery = ids.isNotEmpty
        ? _firestore
            .collection('NOTIFICATIONS')
            .where('userId', whereIn: ids)
            .snapshots()
        : null;
    final byEmailQuery = recipientEmail != null && recipientEmail.isNotEmpty
        ? _firestore
            .collection('NOTIFICATIONS')
            .where('recipientEmail', isEqualTo: recipientEmail)
            .snapshots()
        : null;

    if (byIdQuery == null && byEmailQuery == null) {
      return Stream.value(<NotificationModel>[]);
    }

    if (byIdQuery != null && byEmailQuery == null) {
      return byIdQuery.map((snapshot) {
        final notifications = _parseNotifications(snapshot);
        notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return notifications.length > 20
            ? notifications.take(20).toList()
            : notifications;
      });
    }

    if (byIdQuery == null && byEmailQuery != null) {
      return byEmailQuery.map((snapshot) {
        final notifications = _parseNotifications(snapshot);
        notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return notifications.length > 20
            ? notifications.take(20).toList()
            : notifications;
      });
    }

    return Stream.multi((controller) {
      List<NotificationModel> latestById = [];
      List<NotificationModel> latestByEmail = [];

      void emit() {
        controller
            .add(_mergeAndSortNotifications(latestById, latestByEmail));
      }

      final sub1 = byIdQuery!.listen(
        (snapshot) {
          latestById = _parseNotifications(snapshot);
          emit();
        },
        onError: controller.addError,
      );

      final sub2 = byEmailQuery!.listen(
        (snapshot) {
          latestByEmail = _parseNotifications(snapshot);
          emit();
        },
        onError: controller.addError,
      );

      controller.onCancel = () async {
        await sub1.cancel();
        await sub2.cancel();
      };
    });
  }
  
  // Create Notification
  Future<void> sendNotification({
    required String title,
    required String body,
    required String userId,
    required String type,
    String? ticketId,
    String? recipientEmail,
  }) async {
    try {
      await _firestore.collection('NOTIFICATIONS').add({
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
      debugPrint("Error sending notification: $e");
    }
  }

  // Stream Notifications for User
  Stream<List<NotificationModel>> getUserNotifications(String userId) {
    final ids = _resolveRecipientIds(userId);
    final recipientEmail = _resolveRecipientEmail();
    return _buildNotificationStream(ids: ids, recipientEmail: recipientEmail);
  }

  // Mark Read
  Future<void> markAsRead(String notificationId) async {
    await _firestore.collection('NOTIFICATIONS').doc(notificationId).update({'isRead': true});
  }

  // Get Unread Count
  Stream<int> getUnreadCount(String userId) {
    return getUserNotifications(userId)
        .map((notifications) => notifications.where((n) => !n.isRead).length);
  }
}
