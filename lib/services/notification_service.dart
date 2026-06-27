import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// ==========================================================
/// NOTIFICATION SERVICE
/// - Firebase Cloud Messaging (FCM)
/// - Local notifications
/// - Chat message alerts
/// ==========================================================
class NotificationService {
  NotificationService._();

  static final NotificationService instance =
      NotificationService._();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  String get currentUid => _auth.currentUser!.uid;

  /// ==========================================================
  /// INIT NOTIFICATIONS
  /// Call in main.dart
  /// ==========================================================
  Future<void> init() async {
    await _requestPermission();
    await _initLocalNotifications();
    await _initFCMListeners();
    await _saveFcmToken();
  }

  /// ==========================================================
  /// REQUEST PERMISSION
  /// ==========================================================
  Future<void> _requestPermission() async {
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  /// ==========================================================
  /// INIT LOCAL NOTIFICATIONS (Android/iOS)
  /// ==========================================================
  Future<void> _initLocalNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');

    const ios = DarwinInitializationSettings();

    const settings = InitializationSettings(
      android: android,
      iOS: ios,
    );

    await _localNotifications.initialize(settings);
  }

  /// ==========================================================
  /// INIT FCM LISTENERS
  /// ==========================================================
  Future<void> _initFCMListeners() async {
    // When app is in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showLocalNotification(message);
    });

    // When user taps notification
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      // You can navigate to chat page here
    });
  }

  /// ==========================================================
  /// SAVE FCM TOKEN TO FIRESTORE
  /// ==========================================================
  Future<void> _saveFcmToken() async {
    final token = await _fcm.getToken();

    if (token != null) {
      await _firestore.collection("users").doc(currentUid).set({
        "fcmToken": token,
      }, SetOptions(merge: true));
    }

    // refresh token listener
    _fcm.onTokenRefresh.listen((newToken) async {
      await _firestore.collection("users").doc(currentUid).set({
        "fcmToken": newToken,
      }, SetOptions(merge: true));
    });
  }

  /// ==========================================================
  /// SHOW LOCAL NOTIFICATION
  /// ==========================================================
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;

    if (notification == null) return;

    const androidDetails = AndroidNotificationDetails(
      "chat_channel",
      "Chat Notifications",
      importance: Importance.max,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      details,
      payload: jsonEncode(message.data),
    );
  }

  /// ==========================================================
  /// SEND NOTIFICATION TO USER (via Firestore FCM token)
  /// ==========================================================
  Future<void> sendPushNotification({
    required String receiverId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    final userDoc =
        await _firestore.collection("users").doc(receiverId).get();

    final token = userDoc.data()?["fcmToken"];

    if (token == null) return;

    // NOTE:
    // In production, this should be done via Cloud Functions
    // NOT directly from Flutter app.

    await _firestore.collection("notifications").add({
      "to": receiverId,
      "title": title,
      "body": body,
      "data": data ?? {},
      "createdAt": FieldValue.serverTimestamp(),
      "seen": false,
    });
  }

  /// ==========================================================
  /// MARK NOTIFICATION AS READ
  /// ==========================================================
  Future<void> markAsRead(String notificationId) async {
    await _firestore
        .collection("notifications")
        .doc(notificationId)
        .update({
      "seen": true,
    });
  }
}