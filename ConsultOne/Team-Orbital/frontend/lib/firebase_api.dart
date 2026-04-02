import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  print('Handling a background message: ${message.messageId}');
  if (message.data['type'] == 'video_call' && message.data.containsKey('meetLink')) {
    // Note: We cannot easily launch URL from a pure isolate background context in Android without a plugin like android_intent_plus,
    // but when the user taps the system tray notification, it will open the app and trigger onMessageOpenedApp.
  }
}

class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotifications(BuildContext context) async {
    // Request permission
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Get the FCM token for this device
    final fcmToken = await _firebaseMessaging.getToken();
    print('FCM Token: $fcmToken'); // Backend should save this token upon login/signup!

    // Initialize Push Notification handlers
    initPushNotifications(context);
  }

  void handleVideoCallNotification(BuildContext context, RemoteMessage message) {
    if (message.data['type'] == 'video_call') {
      final meetLink = message.data['meetLink'];
      final callerName = message.data['callerName'] ?? 'A Patient';

      // Show Dialog in Foreground
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Incoming Video Call 📹'),
          content: Text('$callerName is requesting a video consultation.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Decline', style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () async {
                Navigator.pop(context); // close dialog
                if (meetLink != null) {
                  final Uri url = Uri.parse(meetLink);
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  }
                }
              },
              child: const Text('Join Call', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }
  }

  Future<void> initPushNotifications(BuildContext context) async {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');
      
      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }

      handleVideoCallNotification(context, message);
    });

    // Handle background/terminated message taps
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      print('Message clicked from background state!');
      if (message.data['type'] == 'video_call') {
        final meetLink = message.data['meetLink'];
        if (meetLink != null) {
          final Uri url = Uri.parse(meetLink);
          if (await canLaunchUrl(url)) {
            await launchUrl(url, mode: LaunchMode.externalApplication);
          }
        }
      }
    });

    // Handle initial message if app was terminated and opened via notification
    final RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      if (initialMessage.data['type'] == 'video_call') {
        final meetLink = initialMessage.data['meetLink'];
        if (meetLink != null) {
           WidgetsBinding.instance.addPostFrameCallback((_) async {
               final Uri url = Uri.parse(meetLink);
               if (await canLaunchUrl(url)) {
                 await launchUrl(url, mode: LaunchMode.externalApplication);
               }
           });
        }
      }
    }
  }
}
