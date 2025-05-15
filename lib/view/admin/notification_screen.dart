import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import '../../models/order.dart';
import '../../screens/order_detail_screen.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  int _limit = 20;
  final Color _primaryColor = const Color.fromARGB(221, 202, 159, 159);

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !_isLoading) {
      setState(() {
        _limit += 20;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          'Thông Báo',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.grey.shade800,
        elevation: 0,
        shadowColor: Colors.black12,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
            tooltip: 'Làm mới',
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .orderBy('createdAt', descending: true)
            .limit(_limit)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _buildErrorState(snapshot.error.toString());
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingState();
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyState();
          }

          final docs = snapshot.data!.docs;

          // Group notifications by date
          final Map<String, List<QueryDocumentSnapshot>> groupedNotifications =
              {};

          for (var doc in docs) {
            final timestamp = doc['createdAt'] as Timestamp?;
            final dateTime = timestamp?.toDate() ?? DateTime.now();
            final dateString = DateFormat('dd/MM/yyyy').format(dateTime);

            if (!groupedNotifications.containsKey(dateString)) {
              groupedNotifications[dateString] = [];
            }

            groupedNotifications[dateString]!.add(doc);
          }

          // Sort dates newest first
          final sortedDates = groupedNotifications.keys.toList()
            ..sort((a, b) => DateFormat('dd/MM/yyyy')
                .parse(b)
                .compareTo(DateFormat('dd/MM/yyyy').parse(a)));

          return ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.only(top: 8, bottom: 16),
            itemCount: sortedDates.length,
            itemBuilder: (context, dateIndex) {
              final date = sortedDates[dateIndex];
              final notificationsForDate = groupedNotifications[date]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDateHeader(date),
                  ...notificationsForDate
                      .map((orderDoc) => _buildNotificationCard(orderDoc))
                      .toList(),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildDateHeader(String date) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _primaryColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              _formatDateHeader(date),
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _primaryColor,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Divider(
              color: Colors.grey.shade200,
              thickness: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateHeader(String date) {
    final DateTime dateTime = DateFormat('dd/MM/yyyy').parse(date);
    final DateTime now = DateTime.now();
    final DateTime yesterday = DateTime.now().subtract(const Duration(days: 1));

    if (dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day) {
      return 'Hôm nay';
    } else if (dateTime.year == yesterday.year &&
        dateTime.month == yesterday.month &&
        dateTime.day == yesterday.day) {
      return 'Hôm qua';
    } else {
      return date;
    }
  }

  Widget _buildNotificationCard(QueryDocumentSnapshot orderDoc) {
    final orderData = orderDoc.data() as Map<String, dynamic>;

    // Get order status and handle missing data
    String statusString = orderData['status'] ?? 'OrderStatus.pending';
    OrderStatus status = OrderStatus.pending;

    // Extract order status from string
    if (statusString.contains('OrderStatus.')) {
      String statusValue = statusString.split('.').last.replaceAll(')', '');
      status = OrderStatus.values.firstWhere(
          (e) => e.toString().split('.').last == statusValue,
          orElse: () => OrderStatus.pending);
    } else {
      try {
        status = OrderStatus.values.firstWhere(
            (e) => e.toString() == statusString,
            orElse: () => OrderStatus.pending);
      } catch (e) {
        // Default to pending if status can't be determined
        status = OrderStatus.pending;
      }
    }

    // Format timestamp
    final timestamp = orderData['createdAt'] as Timestamp?;
    final dateTime = timestamp?.toDate() ?? DateTime.now();
    final formattedTime = DateFormat('HH:mm').format(dateTime);
    final formattedDate = DateFormat('dd/MM/yyyy').format(dateTime);

    final orderId = orderData['id'] ?? orderDoc.id;
    final userId = orderData['userId'] ?? 'Unknown';
    final totalAmount = orderData['totalAmount'] ?? 0.0;
    final items = orderData['items'] as List<dynamic>? ?? [];
    final address = orderData['address'] as String? ?? '';
    final phone = orderData['phone'] as String? ?? '';

    // Get the appropriate color and text for the order status
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (status) {
      case OrderStatus.pending:
        statusColor = Colors.orange;
        statusText = "Đơn hàng mới";
        statusIcon = Icons.fiber_new;
        break;
      case OrderStatus.processing:
        statusColor = Colors.blue;
        statusText = "Đang xử lý";
        statusIcon = Icons.sync;
        break;
      case OrderStatus.shipped:
        statusColor = Colors.green;
        statusText = "Đã giao hàng";
        statusIcon = Icons.local_shipping;
        break;
      case OrderStatus.cancelled:
        statusColor = Colors.red;
        statusText = "Đã hủy";
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.grey;
        statusText = "Không xác định";
        statusIcon = Icons.help_outline;
    }

    return Card(
      elevation: 1.0,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderDetailScreen(orderId: orderId),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with status and time
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          statusIcon,
                          color: statusColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        statusText,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        formattedTime,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Order Info
              _buildInfoItem(
                Icons.receipt_long,
                'Đơn hàng',
                '#${orderId.substring(0, math.min<int>(8, orderId.length))}',
              ),

              _buildInfoItem(
                Icons.person_outline,
                'Khách hàng',
                userId,
              ),

              _buildInfoItem(
                Icons.shopping_bag_outlined,
                'Số lượng sản phẩm',
                '${items.length} sản phẩm',
              ),

              const SizedBox(height: 12),

              // Price and view button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tổng cộng',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        NumberFormat.currency(
                          locale: 'vi_VN',
                          symbol: '₫',
                          decimalDigits: 0,
                        ).format(totalAmount),
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: _primaryColor,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              OrderDetailScreen(orderId: orderId),
                        ),
                      );
                    },
                    icon: const Icon(Icons.visibility_outlined, size: 16),
                    label: const Text('Xem chi tiết'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      textStyle: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.grey.shade600,
          ),
          const SizedBox(width: 8),
          Text(
            "$label: ",
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade900,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red.shade300,
            size: 60,
          ),
          const SizedBox(height: 16),
          Text(
            'Đã xảy ra lỗi',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 18,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              error,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => setState(() {}),
            icon: const Icon(Icons.refresh),
            label: const Text('Thử lại'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(_primaryColor),
          ),
          const SizedBox(height: 16),
          Text(
            'Đang tải thông báo...',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 72,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 24),
          Text(
            'Không có thông báo nào',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Thông báo mới sẽ xuất hiện ở đây',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
