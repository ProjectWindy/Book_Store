import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/order.dart';
import '../../services/order_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final orderService = OrderService();
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildPaymentMethodIcon(String? icon) {
    if (icon == null || icon.isEmpty) {
      return const Icon(Icons.payment, size: 40, color: Colors.grey);
    }

    // Use Material icons based on payment method instead of assets
    if (icon.contains("qr_code")) {
      return const Icon(Icons.qr_code_scanner, size: 40, color: Colors.blue);
    } else if (icon.contains("cod")) {
      return const Icon(Icons.money, size: 40, color: Colors.green);
    } else if (icon.contains("visa") || icon.contains("card")) {
      return const Icon(Icons.credit_card, size: 40, color: Colors.indigo);
    } else if (icon.contains("paypal")) {
      return const Icon(Icons.account_balance_wallet,
          size: 40, color: Colors.deepPurple);
    } else {
      // Fallback for any other payment methods
      return const Icon(Icons.payment, size: 40, color: Colors.grey);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          "Đơn hàng",
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.grey[50],
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.blue[700],
          unselectedLabelColor: Colors.grey[600],
          indicatorColor: Colors.blue[700],
          labelStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          tabs: const [
            Tab(
              icon: Icon(Icons.payment, size: 20),
              text: "Thanh toán",
            ),
            Tab(
              icon: Icon(Icons.local_shipping, size: 20),
              text: "Đang giao",
            ),
            Tab(
              icon: Icon(Icons.history, size: 20),
              text: "Tất cả",
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOrderList([OrderStatus.pending]),
          _buildOrderList([OrderStatus.processing, OrderStatus.shipped]),
          _buildOrderList([
            OrderStatus.pending,
            OrderStatus.processing,
            OrderStatus.shipped,
            OrderStatus.cancelled
          ]),
        ],
      ),
    );
  }

  Widget _buildOrderList(List<OrderStatus> statuses) {
    if (user == null) {
      return const Center(
        child: Text('Bạn cần đăng nhập để xem đơn hàng'),
      );
    }

    // Cần đảm bảo rằng chúng ta lấy đúng đơn hàng của người dùng hiện tại
    return StreamBuilder<List<Order>>(
      stream: orderService.getAllOrders(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Lỗi: ${snapshot.error}',
              style: GoogleFonts.poppins(color: Colors.red),
            ),
          );
        }

        // Lọc đơn hàng theo userId của người dùng đăng nhập
        final allOrders = snapshot.data ?? [];
        final orders = allOrders
            .where((order) =>
                order.userId == user?.uid && statuses.contains(order.status))
            .toList();

        if (orders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                    statuses.contains(OrderStatus.pending)
                        ? Icons.payment_outlined
                        : Icons.local_shipping_outlined,
                    size: 60,
                    color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  statuses.contains(OrderStatus.pending)
                      ? 'Không có đơn cần thanh toán'
                      : statuses.length > 2
                          ? 'Không có đơn hàng nào'
                          : 'Không có đơn đang giao',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildOrderHeader(order),
                  const Divider(height: 1),
                  _buildOrderItems(order),
                  const Divider(height: 1),
                  _buildOrderFooter(order),
                  _buildOrderStatus(order),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildOrderHeader(Order order) {
    // Ensure the order ID is displayed correctly and not truncated
    String displayId =
        order.id.length > 10 ? order.id.substring(0, 8) + "..." : order.id;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _buildPaymentMethodIcon(order.paymentMethod?.icon),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Đơn hàng #$displayId",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  "Đặt ngày ${_formatDate(order.createdAt)}",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: order.statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getStatusIcon(order.status),
                  size: 16,
                  color: order.statusColor,
                ),
                const SizedBox(width: 4),
                Text(
                  order.statusText,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: order.statusColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItems(Order order) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: order.items
            .map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          item.book.cover,
                          width: 60,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            // Try to load from assets if network image fails
                            if (item.book.cover.startsWith('http')) {
                              // If it was a network URL that failed, try using a fallback image
                              return Image.asset(
                                'assets/img/book_placeholder.png',
                                width: 60,
                                height: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  // If even the asset fails, show a colored container with book icon
                                  return Container(
                                    width: 60,
                                    height: 80,
                                    color: Colors.grey[200],
                                    child: Center(
                                      child: Icon(
                                        Icons.book,
                                        size: 30,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                  );
                                },
                              );
                            } else {
                              // If it's already an asset path, load it directly
                              return Image.asset(
                                item.book.cover,
                                width: 60,
                                height: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  // If the asset fails, show a colored container with book icon
                                  return Container(
                                    width: 60,
                                    height: 80,
                                    color: Colors.grey[200],
                                    child: Center(
                                      child: Icon(
                                        Icons.book,
                                        size: 30,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                  );
                                },
                              );
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.book.title,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Số lượng: ${item.quantity}",
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${NumberFormat.currency(locale: 'vi_VN', symbol: '', decimalDigits: 0).format(item.totalPrice)}đ",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildOrderFooter(Order order) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Địa chỉ giao hàng",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              Flexible(
                child: Text(
                  order.address,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.end,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Điện thoại",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                order.phone,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Phí vận chuyển",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                "${NumberFormat('#,###', 'vi_VN').format(order.deliveryFee)}đ",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Tạm tính",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                "${NumberFormat('#,###', 'vi_VN').format(order.subtotal)}đ",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ],
          ),

          // Add discount information if voucher was applied
          if (order.discountAmount > 0) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.discount_outlined,
                        size: 16, color: Colors.green[600]),
                    const SizedBox(width: 4),
                    Text(
                      order.voucherCode != null
                          ? "Giảm giá (${order.voucherCode})"
                          : "Giảm giá",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.green[600],
                      ),
                    ),
                  ],
                ),
                Text(
                  "-${NumberFormat('#,###', 'vi_VN').format(order.discountAmount)}đ",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.green[600],
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Thành tiền",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Text(
                "${NumberFormat('#,###', 'vi_VN').format(order.totalAmount)}đ",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderStatus(Order order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: order.statusColor.withOpacity(0.05),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _getStatusIcon(order.status),
            color: order.statusColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _getStatusMessage(order.status),
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: order.statusColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Icons.pending;
      case OrderStatus.processing:
        return Icons.refresh;
      case OrderStatus.shipped:
        return Icons.local_shipping;
      case OrderStatus.cancelled:
        return Icons.cancel;
    }
  }

  String _getStatusMessage(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return "Đơn hàng đang chờ xử lý";
      case OrderStatus.processing:
        return "Đơn hàng đang được xử lý";
      case OrderStatus.shipped:
        return "Đơn hàng đã được giao";
      case OrderStatus.cancelled:
        return "Đơn hàng đã bị hủy";
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }
}
