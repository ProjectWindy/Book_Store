import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';

import '../models/notification_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'notifications';

  static const String _channelId = 'bookstore_channel';
  static const String _channelName = 'Thông báo đặt sách';
  static const String _channelDescription =
      'Thông báo về đơn hàng sách và giao dịch';

  Future<void> initialize() async {
    try {
      await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings();
      const InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      await _localNotifications.initialize(initializationSettings);

      FirebaseMessaging.onMessage.listen(_handleIncomingMessage);
    } catch (e) {
      print('Error initializing notification service: $e');
    }
  }

  void _handleIncomingMessage(RemoteMessage message) {
    _showNotification(
      message.notification?.title ?? 'Thông báo mới',
      message.notification?.body ?? '',
    );
  }

  Future<void> _showNotification(String title, String body) async {
    try {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.max,
        priority: Priority.high,
      );

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
      );

      await _localNotifications.show(
        DateTime.now().millisecondsSinceEpoch.hashCode,
        title,
        body,
        platformChannelSpecifics,
      );
    } catch (e) {
      print('Error showing notification: $e');
    }
  }

  Future<bool> createNotification({
    required String userId,
    required String title,
    required String message,
    required String type,
    String? orderId,
    String? imageUrl,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final notification = {
        'userId': userId,
        'title': title,
        'message': message,
        'type': type,
        'orderId': orderId,
        'imageUrl': imageUrl,
        'isRead': false,
        'createdAt': Timestamp.now(),
        if (additionalData != null) ...additionalData,
      };

      await _firestore.collection(_collection).add(notification);
      return true;
    } catch (e) {
      print('Error creating notification: $e');
      return false;
    }
  }

  Future<bool> createOrderNotification({
    required String userId,
    required String orderId,
    required String orderStatus,
    required double orderAmount,
    required List<String> sellerIds,
  }) async {
    try {
      final formattedAmount = NumberFormat.currency(
        locale: 'vi_VN',
        symbol: '',
        decimalDigits: 0,
      ).format(orderAmount * 1000);

      final notifications = <Future<bool>>[];

      // User notification
      final userNotification = _getOrderNotificationContent(
        orderId,
        orderStatus,
        formattedAmount,
        isUser: true,
      );
      notifications.add(createNotification(
        userId: userId,
        title: userNotification['title']!,
        message: userNotification['message']!,
        type: 'order',
        orderId: orderId,
      ));

      // Seller notifications
      for (final sellerId in sellerIds) {
        final sellerNotification = _getOrderNotificationContent(
          orderId,
          orderStatus,
          formattedAmount,
          isUser: false,
        );
        notifications.add(createNotification(
          userId: sellerId,
          title: sellerNotification['title']!,
          message: sellerNotification['message']!,
          type: 'order',
          orderId: orderId,
        ));
      }

      await Future.wait(notifications);
      return true;
    } catch (e) {
      print('Error creating order notification: $e');
      return false;
    }
  }

  Map<String, String> _getOrderNotificationContent(
    String orderId,
    String orderStatus,
    String formattedAmount, {
    required bool isUser,
  }) {
    if (isUser) {
      switch (orderStatus) {
        case 'pending':
          return {
            'title': 'Đơn hàng đã được tạo',
            'message':
                'Đơn hàng #$orderId của bạn đã được tạo thành công. Tổng giá trị: $formattedAmountđ',
          };
        case 'processing':
          return {
            'title': 'Đơn hàng đang được xử lý',
            'message': 'Đơn hàng #$orderId của bạn đang được chuẩn bị.',
          };
        case 'shipped':
          return {
            'title': 'Đơn hàng đang được giao',
            'message': 'Đơn hàng #$orderId của bạn đang được giao đến bạn.',
          };
        case 'delivered':
          return {
            'title': 'Đơn hàng đã được giao',
            'message': 'Đơn hàng #$orderId của bạn đã được giao thành công.',
          };
        case 'cancelled':
          return {
            'title': 'Đơn hàng đã bị hủy',
            'message': 'Đơn hàng #$orderId của bạn đã bị hủy.',
          };
        default:
          return {
            'title': 'Cập nhật đơn hàng',
            'message': 'Đơn hàng #$orderId của bạn đã được cập nhật.',
          };
      }
    } else {
      if (orderStatus == 'pending') {
        return {
          'title': 'Đơn hàng mới!',
          'message':
              'Bạn có đơn hàng mới #$orderId với giá trị $formattedAmountđ',
        };
      }
      return {
        'title': 'Cập nhật đơn hàng',
        'message': 'Đơn hàng #$orderId đã được cập nhật thành $orderStatus',
      };
    }
  }

  Stream<QuerySnapshot> getUserNotifications(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(notificationId)
          .update({'isRead': true});
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  Future<void> updateUserFCMToken(String userId, String token) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'fcmToken': token,
      });
    } catch (e) {
      print('Error updating FCM token: $e');
    }
  }

  // Tạo thông báo sách sắp ra mắt
  Future<bool> createUpcomingBookNotification({
    required String bookId,
    required String bookTitle,
    required String releaseDate,
  }) async {
    try {
      final notification = Notification(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: 'upcoming_book',
        title: 'Sách sắp ra mắt',
        message: 'Sách "$bookTitle" sẽ ra mắt vào ngày $releaseDate',
        createdAt: DateTime.now(),
        data: {
          'bookId': bookId,
          'releaseDate': releaseDate,
        },
      );

      await _firestore
          .collection(_collection)
          .doc(notification.id)
          .set(notification.toMap());
      return true;
    } catch (e) {
      print('Error creating upcoming book notification: $e');
      return false;
    }
  }

  // Get admin notifications (order notifications)
  Stream<QuerySnapshot> getAdminNotifications() {
    return _firestore
        .collection('notifications')
        .where('isAdminNotification', isEqualTo: true)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Get unread notification count
  Future<int> getUnreadCount(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      return snapshot.docs.length;
    } catch (e) {
      print('Error getting unread count: $e');
      return 0;
    }
  }

  // Mark all notifications as read
  Future<bool> markAllAsRead(String userId) async {
    try {
      final batch = _firestore.batch();
      final notifications = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      for (var doc in notifications.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      await batch.commit();
      return true;
    } catch (e) {
      print('Error marking all notifications as read: $e');
      return false;
    }
  }

  // Delete notification
  Future<bool> deleteNotification(String notificationId) async {
    try {
      await _firestore.collection(_collection).doc(notificationId).delete();
      return true;
    } catch (e) {
      print('Error deleting notification: $e');
      return false;
    }
  }

  // Delete all notifications
  Future<bool> deleteAllNotifications(String userId) async {
    try {
      final batch = _firestore.batch();
      final notifications = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .get();

      for (var doc in notifications.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      return true;
    } catch (e) {
      print('Error deleting all notifications: $e');
      return false;
    }
  }

  // Get a single notification by ID
  Future<DocumentSnapshot?> getNotification(String notificationId) async {
    try {
      final doc =
          await _firestore.collection(_collection).doc(notificationId).get();
      return doc.exists ? doc : null;
    } catch (e) {
      print('Error getting notification: $e');
      return null;
    }
  }
}
