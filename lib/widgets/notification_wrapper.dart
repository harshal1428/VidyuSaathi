import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';
import '../models/notification_model.dart';
import '../services/sound_service.dart';
import '../services/local_notification_service.dart';

class NotificationWrapper extends StatefulWidget {
  final Widget child;

  const NotificationWrapper({Key? key, required this.child}) : super(key: key);

  @override
  State<NotificationWrapper> createState() => _NotificationWrapperState();
}

class _NotificationWrapperState extends State<NotificationWrapper> {
  // Keep track of the latest notification ID we've shown to avoid duplicate popups
  // In a real app, this might persist to local storage, but in-memory is okay for session
  String? _lastShownNotificationId;

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final notificationService = Provider.of<NotificationService>(context);
    final user = authService.currentUser;

    if (user == null) {
      return widget.child;
    }

    // We use a StreamBuilder just to listen, but we don't want to rebuild the entire app tree usually.
    // However, StreamBuilder is the cleanest way to react to stream changes.
    // To avoid rebuilding 'widget.child' unnecessarily, we can use the `builder` to just trigger side effects
    // or overlay simple things, but showing a SnackBar requires a ScaffoldMessenger context.
    
    return StreamBuilder<List<NotificationModel>>(
      stream: notificationService.getUserNotifications(user.userId),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          final latest = snapshot.data!.first;
          
          // Check if we should show this notification
          // Logic: It's new (not same as last shown) AND it is unread (optional, but good UX)
          // Also check if it's recent (created in last 5 mins) to avoid spamming old notifs on login
          
          final isRecent = DateTime.now().difference(latest.createdAt).inMinutes < 5;
          
          if (latest.id != _lastShownNotificationId && !latest.isRead && isRecent) {
             // Defer the snackbar to the next frame to avoid build conflicts
             WidgetsBinding.instance.addPostFrameCallback((_) {
               if (mounted) {
                  _lastShownNotificationId = latest.id;
                  
                  // Play Sound
                  SoundService.playNotificationSound();
                  
                  // Show System Notification (Notification Bar)
                  LocalNotificationService.showNotification(
                    id: latest.id.hashCode,
                    title: latest.title,
                    body: latest.body,
                    payload: latest.ticketId,
                  );
                  
                  // We removed the MaterialBanner/multimedia banner as requested ("not as the top of app... still it is there")
                  // The user specifically wanted "notification bar".
                  // However, if we want an in-app indicator that is less intrusive, a SnackBar is better, 
                  // but standard SnackBar is bottom. User wanted "upper top". 
                  // But standard system notification IS "upper top" via status bar. 
                  // So LocalNotificationService satisfies "notification bar" and "upper top".
                  // Removing the in-app overlay cleans up the "still it is there" issue.
               }
             });
          }
        }
        
        return widget.child;
      },
    );
  }
}
