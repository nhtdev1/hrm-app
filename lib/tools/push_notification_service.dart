import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../schedule/view_schedule.dart';

enum NotificationType{
  post,
  calendar,
}

const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', 'High Impotance Notification',
    importance: Importance.high, playSound: true);
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class PushNotificationService {
  static final PushNotificationService _singleton = PushNotificationService._internal();

  factory PushNotificationService() => _singleton;

  PushNotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  Future initialize() async {
  }


  void addNotification(String title, String notification_content) {
    flutterLocalNotificationsPlugin.show(
        0,
        title,
        notification_content,
        NotificationDetails(
            android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          importance: Importance.high,
          color: Colors.blueGrey,
          playSound: true,
        )));
  }
}
