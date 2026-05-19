import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get_rx/src/rx_typedefs/rx_typedefs.dart';
import 'package:metube/database/database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class LocalNotificationServices {
  static Callback callback = () {};

     static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static const AndroidInitializationSettings _androidInitializationSettings = AndroidInitializationSettings('logo');
 static DarwinInitializationSettings get initializationSettingsDarwin =>   const DarwinInitializationSettings(
    requestSoundPermission: false,
    requestBadgePermission: false,
    requestAlertPermission: false,

  );
  static Future<void> initNotification() async {
    InitializationSettings initializationSettings =
          InitializationSettings(android: _androidInitializationSettings,iOS:initializationSettingsDarwin);
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: (details) {
      callback.call();
      _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
        alert: false,
        badge: true,
        sound: true,
      );
    });

  }

  static int notificationId = 0;

  static void onSendNotification(String title, String body, Callback function) {
    // type >>> 0 => upload : 1 => download
    if (Database.showNotification) {
      callback = function;
      AndroidNotificationDetails androidNotificationDetails = const AndroidNotificationDetails(
          'channelId', 'channelName',
          importance: Importance.max, priority: Priority.high);
      NotificationDetails notificationDetails = NotificationDetails(android: androidNotificationDetails);
      _flutterLocalNotificationsPlugin.show(notificationId, title, body, notificationDetails);
      notificationId++;
    }
  }
}

class NotificationServices {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    var androidInitializationSettings = const AndroidInitializationSettings('@mipmap/ic_launcher');

    var iosInitializeSettings = const DarwinInitializationSettings();

    final initializationSettings =
        InitializationSettings(android: androidInitializationSettings, iOS: iosInitializeSettings);

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (payload) {},
    );
  }

  Future<void> showNotification(RemoteMessage message) async {    
    AndroidNotificationChannel channel = AndroidNotificationChannel(
      Random.secure().nextInt(100000).toString(),
      "High Importance Notification",
      importance: Importance.max,
    );

    AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      playSound: true,
      channel.id,
      channel.name,
      channelDescription: "your channel description",
      importance: Importance.high,
      priority: Priority.high,
      ticker: "ticker",
    );

    DarwinNotificationDetails darwinNotificationDetails = const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: darwinNotificationDetails,
    );

    _flutterLocalNotificationsPlugin.show(
      0,
      message.notification?.title.toString(),
      message.notification?.body.toString(),
      notificationDetails,
    );
  }

  void firebaseInit() async {
    FirebaseMessaging.onMessage.listen(
      (message) {
        debugPrint(message.notification!.title.toString());
        debugPrint(message.notification!.body.toString());
        showNotification(message);
      },
    );
  }
}
