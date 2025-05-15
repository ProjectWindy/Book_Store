import 'package:flutter/material.dart';
import '../models/notification_model.dart' as models;
import '../services/notification_service.dart';
import '../widgets/notification_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationsScreen extends StatefulWidget {
  final bool isAdmin;
  final String userId;

  const NotificationsScreen({
    super.key,
    required this.userId,
    this.isAdmin = false,
  });

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationService _notificationService = NotificationService();
  bool _isDeleting = false;

  Future<void> _deleteAllNotifications() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa tất cả thông báo'),
        content: const Text('Bạn có chắc chắn muốn xóa tất cả thông báo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isDeleting = true);

    try {
      await _notificationService.deleteAllNotifications(widget.userId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã xóa tất cả thông báo')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
  }

  void _navigateToOrderDetail(String orderId) {
    Navigator.pushNamed(
      context,
      '/order-detail',
      arguments: orderId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isAdmin ? 'Thông báo đơn hàng' : 'Thông báo'),
        actions: [
          if (!_isDeleting)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _deleteAllNotifications,
            )
          else
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              ),
            ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: widget.isAdmin
            ? _notificationService.getAdminNotifications()
            : _notificationService.getUserNotifications(widget.userId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Đã xảy ra lỗi: ${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.notifications_none,
                    size: 48,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Chưa có thông báo nào',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final notification = models.Notification.fromMap({
                'id': doc.id,
                ...data,
              });

              return NotificationCard(
                notification: notification,
                isAdmin: widget.isAdmin,
                onTap: () async {
                  if (!notification.isRead) {
                    await _notificationService
                        .markNotificationAsRead(notification.id);
                  }

                  if (notification.type == 'order') {
                    final orderId = notification.data?['orderId'];
                    if (orderId != null) {
                      _navigateToOrderDetail(orderId);
                    }
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
