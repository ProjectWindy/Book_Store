import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:intl/intl.dart';
import '../models/order.dart';
import 'package:google_fonts/google_fonts.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailScreen({
    super.key,
    required this.orderId,
  });

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen>
    with SingleTickerProviderStateMixin {
  // Modern color palette 2025
  static const Color primaryColor = Color(0xFF4A6FFF);
  static const Color secondaryColor = Color(0xFFAE71FF);
  static const Color accentColor = Color(0xFFFF5690);
  static const Color successColor = Color(0xFF1ED696);
  static const Color dangerColor = Color(0xFFFF6C6C);
  static const Color warningColor = Color(0xFFFFD166);
  static const Color infoColor = Color(0xFF58CDFF);
  static const Color backgroundColor = Color(0xFFF6F8FE);
  static const Color darkColor = Color(0xFF2D3748);
  static const Color cardColor = Color(0xFFFFFFFF);

  // Animation controller for subtle animations
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Chi tiết đơn hàng',
          style: GoogleFonts.montserrat(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: darkColor,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: darkColor),
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.7),
                    Colors.white.withOpacity(0.5),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: StreamBuilder<firestore.DocumentSnapshot>(
        stream: firestore.FirebaseFirestore.instance
            .collection('orders')
            .doc(widget.orderId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _buildErrorState('Đã xảy ra lỗi: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingState();
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return _buildEmptyState();
          }

          // Get the order data from Firestore
          final orderData = snapshot.data!.data() as Map<String, dynamic>;
          orderData['id'] = widget.orderId;
          final Order order = Order.fromMap(orderData);

          return _buildOrderDetail(order);
        },
      ),
    );
  }

  Widget _buildErrorState(String errorMessage) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        margin: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline,
                size: 80, color: dangerColor.withOpacity(0.7)),
            const SizedBox(height: 24),
            Text(
              errorMessage,
              style: GoogleFonts.montserrat(
                fontSize: 16,
                color: darkColor,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                'Quay lại',
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: primaryColor,
            strokeWidth: 3,
          ),
          const SizedBox(height: 24),
          Text(
            'Đang tải thông tin đơn hàng...',
            style: GoogleFonts.montserrat(
              fontSize: 16,
              color: darkColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        margin: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.assignment_late_outlined,
                size: 80, color: Colors.grey[400]),
            const SizedBox(height: 24),
            Text(
              'Không tìm thấy đơn hàng',
              style: GoogleFonts.montserrat(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: darkColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Đơn hàng không tồn tại hoặc đã bị xóa',
              style: GoogleFonts.montserrat(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                'Quay lại',
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderDetail(Order order) {
    return Stack(
      children: [
        // Background patterns
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  backgroundColor,
                  backgroundColor.withBlue(backgroundColor.blue - 10),
                ],
              ),
            ),
          ),
        ),

        // Order content
        SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.1),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          )),
          child: FadeTransition(
            opacity: _animationController,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Padding for app bar
                SliverToBoxAdapter(
                  child:
                      SizedBox(height: MediaQuery.of(context).padding.top + 60),
                ),

                // Order ID and status
                SliverToBoxAdapter(
                  child: _buildHeaderSection(order),
                ),

                // Order sections
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        _buildCustomerInfoSection(order),
                        const SizedBox(height: 24),
                        _buildProductsSection(order),
                        const SizedBox(height: 24),
                        _buildSummarySection(order),
                        const SizedBox(height: 32),
                        // _buildActionButtons(order),
                        // Extra space at the bottom
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderSection(Order order) {
    String statusText = '';
    Color statusColor = Colors.grey;
    IconData statusIcon = Icons.help_outline;

    switch (order.status) {
      case OrderStatus.pending:
        statusText = 'Chờ xử lý';
        statusColor = warningColor;
        statusIcon = Icons.access_time;
        break;
      case OrderStatus.processing:
        statusText = 'Đang xử lý';
        statusColor = infoColor;
        statusIcon = Icons.sync;
        break;
      case OrderStatus.shipped:
        statusText = 'Đã giao hàng';
        statusColor = successColor;
        statusIcon = Icons.local_shipping;
        break;
      case OrderStatus.cancelled:
        statusText = 'Đã hủy';
        statusColor = dangerColor;
        statusIcon = Icons.cancel;
        break;
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.7),
                      Colors.white.withOpacity(0.5),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.5),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Order ID with copy button
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.receipt_long_rounded,
                                color: primaryColor,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Mã đơn hàng',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Text(
                                      '#${order.id.substring(0, 8)}',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: darkColor,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    InkWell(
                                      onTap: () {},
                                      borderRadius: BorderRadius.circular(12),
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        child: Icon(
                                          Icons.copy,
                                          size: 16,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        // Status badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: statusColor.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                statusIcon,
                                size: 16,
                                color: statusColor,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                statusText,
                                style: GoogleFonts.montserrat(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: statusColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 1, color: Colors.black12),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Order date
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ngày đặt',
                              style: GoogleFonts.montserrat(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('dd/MM/yyyy HH:mm')
                                  .format(order.createdAt),
                              style: GoogleFonts.montserrat(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: darkColor,
                              ),
                            ),
                          ],
                        ),
                        // Order total
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Tổng cộng',
                              style: GoogleFonts.montserrat(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${NumberFormat.currency(locale: 'vi_VN', symbol: '', decimalDigits: 0).format(order.totalAmount)}₫',
                              style: GoogleFonts.montserrat(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerInfoSection(Order order) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.7),
                Colors.white.withOpacity(0.5),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.5),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: infoColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.person_outlined,
                      color: infoColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Thông tin khách hàng',
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: darkColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildContactInfoItem(
                Icons.phone_outlined,
                'Số điện thoại',
                order.phone,
                infoColor,
              ),
              const SizedBox(height: 16),
              _buildContactInfoItem(
                Icons.location_on_outlined,
                'Địa chỉ giao hàng',
                order.address,
                infoColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductsSection(Order order) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.7),
                Colors.white.withOpacity(0.5),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.5),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: accentColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.shopping_bag_outlined,
                          color: accentColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Sản phẩm',
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: darkColor,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${order.items.length} sản phẩm',
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: accentColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: order.items.length,
                separatorBuilder: (context, index) => Divider(
                  height: 24,
                  color: Colors.grey.withOpacity(0.2),
                ),
                itemBuilder: (context, index) {
                  final item = order.items[index];
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product image with glass effect
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: SizedBox(
                            width: 70,
                            height: 90,
                            child: _buildBookImage(item.book.cover),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.book.title,
                              style: GoogleFonts.montserrat(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: darkColor,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Tác giả: ${item.book.author}',
                              style: GoogleFonts.montserrat(
                                color: Colors.grey[600],
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${NumberFormat.currency(locale: 'vi_VN', symbol: '', decimalDigits: 0).format(item.book.price)}₫',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: primaryColor,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'x${item.quantity}',
                                    style: GoogleFonts.montserrat(
                                      fontWeight: FontWeight.w600,
                                      color: darkColor,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummarySection(Order order) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.7),
                Colors.white.withOpacity(0.5),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.5),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: secondaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.receipt_outlined,
                      color: secondaryColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Tổng quan đơn hàng',
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: darkColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildSummaryRow(
                'Tạm tính',
                '${NumberFormat.currency(locale: 'vi_VN', symbol: '', decimalDigits: 0).format(order.subtotal)}₫',
              ),
              const SizedBox(height: 12),
              _buildSummaryRow(
                'Phí vận chuyển',
                '${NumberFormat.currency(locale: 'vi_VN', symbol: '', decimalDigits: 0).format(order.deliveryFee)}₫',
              ),
              if (order.discountAmount > 0) ...[
                const SizedBox(height: 12),
                _buildSummaryRow(
                  'Giảm giá',
                  '-${NumberFormat.currency(locale: 'vi_VN', symbol: '', decimalDigits: 0).format(order.discountAmount)}₫',
                  valueColor: successColor,
                ),
              ],
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Divider(height: 1, color: Colors.black12),
              ),
              _buildSummaryRow(
                'Tổng cộng',
                '${NumberFormat.currency(locale: 'vi_VN', symbol: '', decimalDigits: 0).format(order.totalAmount)}₫',
                isBold: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget _buildActionButtons(Order order) {
  //   bool canCancel = order.status == OrderStatus.pending;
  //   bool canProcess = order.status == OrderStatus.pending;
  //   bool canShip = order.status == OrderStatus.processing;

  //   return Row(
  //     children: [
  //       if (canCancel)
  //         Expanded(
  //           child: OutlinedButton(
  //             onPressed: () {
  //               // Handle cancel order
  //             },
  //             style: OutlinedButton.styleFrom(
  //               padding: const EdgeInsets.symmetric(vertical: 16),
  //               side: BorderSide(color: dangerColor, width: 1.5),
  //               shape: RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.circular(16),
  //               ),
  //             ),
  //             child: Text(
  //               'Hủy đơn hàng',
  //               style: GoogleFonts.montserrat(
  //                 fontSize: 15,
  //                 fontWeight: FontWeight.w600,
  //                 color: dangerColor,
  //               ),
  //             ),
  //           ),
  //         ),
  //       if (canCancel) const SizedBox(width: 16),
  //       if (canProcess)
  //         Expanded(
  //           child: ElevatedButton(
  //             onPressed: () {
  //               // Handle process order
  //             },
  //             style: ElevatedButton.styleFrom(
  //               padding: const EdgeInsets.symmetric(vertical: 16),
  //               backgroundColor: primaryColor,
  //               elevation: 0,
  //               shadowColor: Colors.transparent,
  //               shape: RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.circular(16),
  //               ),
  //             ),
  //             child: Text(
  //               'Xử lý đơn hàng',
  //               style: GoogleFonts.montserrat(
  //                 fontSize: 15,
  //                 fontWeight: FontWeight.w600,
  //                 color: Colors.white,
  //               ),
  //             ),
  //           ),
  //         ),
  //       if (canShip)
  //         Expanded(
  //           child: ElevatedButton(
  //             onPressed: () {
  //               // Handle ship order
  //             },
  //             style: ElevatedButton.styleFrom(
  //               padding: const EdgeInsets.symmetric(vertical: 16),
  //               backgroundColor: primaryColor,
  //               elevation: 0,
  //               shadowColor: Colors.transparent,
  //               shape: RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.circular(16),
  //               ),
  //             ),
  //             child: Text(
  //               'Giao hàng',
  //               style: GoogleFonts.montserrat(
  //                 fontSize: 15,
  //                 fontWeight: FontWeight.w600,
  //                 color: Colors.white,
  //               ),
  //             ),
  //           ),
  //         ),
  //     ],
  //   );
  // }

  Widget _buildContactInfoItem(
    IconData icon,
    String label,
    String value,
    Color iconColor,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            size: 20,
            color: iconColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value.isEmpty ? 'Không có thông tin' : value,
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: value.isEmpty ? Colors.grey : darkColor,
                  fontStyle:
                      value.isEmpty ? FontStyle.italic : FontStyle.normal,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(
    String label,
    String price, {
    Color? valueColor,
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            color: isBold ? darkColor : Colors.grey[600],
          ),
        ),
        Text(
          price,
          style: GoogleFonts.montserrat(
            fontSize: isBold ? 18 : 14,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
            color: valueColor ?? (isBold ? primaryColor : darkColor),
          ),
        ),
      ],
    );
  }

  Widget _buildBookImage(String imageUrl) {
    // Kiểm tra nếu là đường dẫn network hay asset
    final bool isNetworkImage = imageUrl.startsWith('http');
    final bool isAssetImage = imageUrl.startsWith('assets/');

    if (isNetworkImage) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return _buildImagePlaceholder();
        },
      );
    } else if (isAssetImage) {
      return Image.asset(
        imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return _buildImagePlaceholder();
        },
      );
    } else {
      // Try as asset if not clearly specified
      return Image.asset(
        'assets/img/book_placeholder.png',
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return _buildImagePlaceholder();
        },
      );
    }
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Icon(Icons.menu_book_rounded, size: 32, color: Colors.grey[400]),
      ),
    );
  }
}
