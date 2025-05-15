import 'package:flutter/material.dart';
import '../models/notification_model.dart' as models;

class NotificationCard extends StatelessWidget {
  final models.Notification notification;
  final VoidCallback? onTap;
  final bool isAdmin;

  const NotificationCard({
    Key? key,
    required this.notification,
    this.onTap,
    this.isAdmin = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: notification.isRead ? Colors.white : Colors.blue.shade50,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _getIcon(),
                    color: _getIconColor(),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      notification.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (!notification.isRead)
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                notification.message,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                _formatDate(notification.createdAt),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              if (isAdmin && notification.type == 'order') ...[
                const SizedBox(height: 8),
                Text(
                  'Mã đơn hàng: ${notification.data?['orderId']}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIcon() {
    switch (notification.type) {
      case 'upcoming_book':
        return Icons.book_outlined;
      case 'order':
        return Icons.shopping_cart_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color _getIconColor() {
    switch (notification.type) {
      case 'upcoming_book':
        return Colors.orange;
      case 'order':
        return Colors.green;
      default:
        return Colors.blue;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} phút trước';
    } else {
      return 'Vừa xong';
    }
  }
}
