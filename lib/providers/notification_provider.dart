import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../services/firestore_service.dart';
import 'auth_provider.dart';

class NotificationProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  AppAuthProvider _auth;

  NotificationProvider(this._auth) {
    _listenToNotifications();
  }

  List<NotificationModel> _notifications = [];

  List<NotificationModel> get notifications => _notifications;

  int get unreadCount =>
      _notifications.where((n) => !n.isRead).length;

  void updateAuth(AppAuthProvider auth) {
    _auth = auth;
    _listenToNotifications();
    notifyListeners();
  }

  void _listenToNotifications() {
    final uid = _auth.currentUser?.uid;

    if (uid == null) return;

    _firestoreService.getNotifications(uid).listen((snapshot) {
     // Nan metòd kote w ap chaje notifikasyon yo:
_notifications = snapshot.docs.map((doc) => NotificationModel.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();

      notifyListeners();
    });
  }
// Nan lib/providers/notification_provider.dart

Stream<List<NotificationModel>> getNotifications(String uid) {
  return _firestoreService.getNotifications(uid).map((snapshot) {
    return snapshot.docs.map((doc) => 
      NotificationModel.fromMap(doc.data() as Map<String, dynamic>, doc.id)
    ).toList();
  });
}
  Future<void> markAsRead(String notificationId) async {
    final uid = _auth.currentUser?.uid;

    if (uid != null) {
      await _firestoreService.updateNotificationStatus(
        uid,
        notificationId,
        true,
      );
    }
  }
}