import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../common/color_extension.dart';
import '../../services/notification_service.dart';

class NotificationView extends StatefulWidget {
  const NotificationView({Key? key}) : super(key: key);

  @override
  State<NotificationView> createState() => _NotificationViewState();
}

class _NotificationViewState extends State<NotificationView> {
  final NotificationService _notificationService = NotificationService();
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return const Scaffold(
        body: Center(
          child: Text('Vui lòng đăng nhập để xem thông báo'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Text(
          "Thông báo",
          style: TextStyle(
            color: TColor.primaryText,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            color: TColor.primary,
            onPressed: _markAllAsRead,
            tooltip: 'Đánh dấu tất cả là đã đọc',
          ),
          // IconButton(
          //   icon: const Icon(Icons.delete_sweep),
          //   color: TColor.primary,
          //   onPressed: _confirmDeleteAll,
          //   tooltip: 'Xóa tất cả thông báo',
          // ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _notificationService.getUserNotifications(_currentUser.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Đã xảy ra lỗi khi tải thông báo',
                style: TextStyle(color: TColor.secondaryText),
              ),
            );
          }

          final notifications = snapshot.data?.docs ?? [];

          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Bạn chưa có thông báo nào',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {});
            },
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                final data = notification.data() as Map<String, dynamic>;
                final notificationId = notification.id;
                final isRead = data['isRead'] ?? false;
                final createdAt = (data['createdAt'] as Timestamp).toDate();
                final type = data['type'] ?? 'system';
                final imageUrl = data['imageUrl'];

                return Dismissible(
                  key: Key(notificationId),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) {
                    _deleteNotification(notificationId);
                  },
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: isRead ? Colors.white : Colors.blue[50],
                    child: InkWell(
                      onTap: () =>
                          _markAsRead(notificationId, type, data['orderId']),
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildNotificationIcon(type, imageUrl),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          data['title'] ?? 'Thông báo',
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight: isRead
                                                ? FontWeight.w500
                                                : FontWeight.bold,
                                            color: TColor.primaryText,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        _formatDate(createdAt),
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: TColor.secondaryText,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    data['message'] ?? '',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: TColor.secondaryText,
                                    ),
                                  ),
                                  if (type == 'order' &&
                                      data['orderId'] != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: InkWell(
                                        onTap: () {
                                          // Đánh dấu đã đọc và điều hướng đến trang chi tiết đơn hàng
                                          _notificationService
                                              .markNotificationAsRead(
                                                  notificationId);

                                          // Lấy orderId từ thông báo
                                          final orderId = data['orderId'];

                                          // Điều hướng đến trang chi tiết đơn hàng
                                          Navigator.pushNamed(
                                              context, 'order_detail',
                                              arguments: {'orderId': orderId});
                                        },
                                        child: Text(
                                          'Xem chi tiết đơn hàng',
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            color: TColor.primary,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotificationIcon(String type, String? imageUrl) {
    IconData icon;
    Color color;

    switch (type) {
      case 'order':
        icon = Icons.shopping_bag;
        color = Colors.orange;
        break;
      case 'promotion':
        icon = Icons.local_offer;
        color = Colors.purple;
        break;
      case 'system':
        icon = Icons.notifications;
        color = Colors.blue;
        break;
      default:
        icon = Icons.notifications;
        color = Colors.blue;
    }

    if (imageUrl != null && imageUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Image.network(
          imageUrl,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            );
          },
        ),
      );
    }

    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Icon(
        icon,
        color: color,
        size: 24,
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Vừa xong';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else {
      return DateFormat('dd/MM/yyyy').format(date);
    }
  }

  void _markAsRead(String notificationId, String type, String? orderId) async {
    await _notificationService.markNotificationAsRead(notificationId);

    // Navigate to order details if it's an order notification
    if (type == 'order' && orderId != null) {
      if (mounted) {
        // Lấy thông tin route từ notification data
        final notification =
            await _notificationService.getNotification(notificationId);
        if (notification != null) {
          final data = notification.data() as Map<String, dynamic>;
          final additionalData =
              data['additionalData'] as Map<String, dynamic>?;

          if (additionalData != null && additionalData.containsKey('route')) {
            final route = additionalData['route'] as String;

            // Điều hướng đến trang chi tiết đơn hàng
            if (route == '/order-detail') {
              Navigator.pushNamed(context, 'order_detail',
                  arguments: {'orderId': orderId});
            }
          } else {
            // Fallback nếu không có thông tin route
            Navigator.pushNamed(context, 'order_detail',
                arguments: {'orderId': orderId});
          }
        }
      }
    }
  }

  void _markAllAsRead() async {
    if (_currentUser == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _notificationService.markAllAsRead(_currentUser.uid);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tất cả thông báo đã được đánh dấu là đã đọc'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _deleteNotification(String notificationId) async {
    try {
      await _notificationService.deleteNotification(notificationId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã xóa thông báo')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    }
  }

  void _confirmDeleteAll() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Xóa tất cả thông báo',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: TColor.primaryText,
            ),
          ),
          content: Text(
            'Bạn có chắc chắn muốn xóa tất cả thông báo không?',
            style: GoogleFonts.poppins(
              color: TColor.primaryText,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Hủy',
                style: GoogleFonts.poppins(
                  color: TColor.primaryText,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteAllNotifications();
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.red,
              ),
              child: Text(
                'Xóa tất cả',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _deleteAllNotifications() async {
    if (_currentUser == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _notificationService.deleteAllNotifications(_currentUser.uid);
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
      setState(() {
        _isLoading = false;
      });
    }
  }
}
