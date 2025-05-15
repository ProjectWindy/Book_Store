import 'package:cloud_firestore/cloud_firestore.dart';

class Notification {
  final String id;
  final String type; // 'upcoming_book' or 'order'
  final String title;
  final String message;
  final DateTime createdAt;
  final bool isRead;
  final Map<String, dynamic>?
      data; // Additional data like bookId, orderId, etc.

  Notification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.createdAt,
    this.isRead = false,
    this.data,
  });

  factory Notification.fromMap(Map<String, dynamic> map) {
    return Notification(
      id: map['id'] ?? '',
      type: map['type'] ?? '',
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      isRead: map['isRead'] ?? false,
      data: map['data'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'message': message,
      'createdAt': Timestamp.fromDate(createdAt),
      'isRead': isRead,
      'data': data,
    };
  }
}
