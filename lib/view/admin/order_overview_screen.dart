import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:intl/intl.dart';
import 'dart:math' show min;

import '../../models/order.dart';
import '../../screens/order_detail_screen.dart';

class OrderOverviewScreen extends StatefulWidget {
  const OrderOverviewScreen({super.key});

  @override
  State<OrderOverviewScreen> createState() => _OrderOverviewScreenState();
}

class _OrderOverviewScreenState extends State<OrderOverviewScreen> {
  String _selectedStatus = 'all';
  final _searchController = TextEditingController();
  bool _isLoading = false;

  final Map<String, String> _statusMapping = {
    'all': 'all',
    'pending': 'OrderStatus.pending',
    'processing': 'OrderStatus.processing',
    'shipped': 'OrderStatus.shipped',
    'cancelled': 'OrderStatus.cancelled',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Tổng Quan Đơn Hàng',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.grey[800],
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        shadowColor: Colors.black.withOpacity(0.1),
        actions: [
          IconButton(
            onPressed: () => setState(() {}),
            icon: Icon(
              Icons.refresh_rounded,
              color: Colors.grey[700],
            ),
            tooltip: 'Làm mới',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: _buildOrderList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            offset: const Offset(0, 2),
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tìm Kiếm & Lọc',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Tìm kiếm đơn hàng...',
              prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                    color: const Color.fromARGB(221, 202, 159, 159),
                    width: 1.5),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            ),
            style: GoogleFonts.poppins(
              fontSize: 14,
            ),
            onChanged: (value) {
              setState(() {});
            },
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildStatusFilter('Tất Cả', 'all'),
                _buildStatusFilter('Chờ Xử Lý', 'pending'),
                _buildStatusFilter('Đang Xử Lý', 'processing'),
                _buildStatusFilter('Đã Giao', 'shipped'),
                _buildStatusFilter('Đã Hủy', 'cancelled'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusFilter(String label, String status) {
    final isSelected = _selectedStatus == status;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedStatus = status;
          });
        },
        backgroundColor: Colors.white,
        selectedColor:
            const Color.fromARGB(221, 202, 159, 159).withOpacity(0.2),
        checkmarkColor: const Color.fromARGB(221, 202, 159, 159),
        labelStyle: GoogleFonts.poppins(
          color: isSelected
              ? const Color.fromARGB(221, 202, 159, 159)
              : Colors.grey[700],
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          fontSize: 14,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: isSelected
                ? const Color.fromARGB(221, 202, 159, 159)
                : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        elevation: isSelected ? 1 : 0,
        shadowColor: isSelected
            ? const Color.fromARGB(221, 202, 159, 159).withOpacity(0.3)
            : Colors.transparent,
      ),
    );
  }

  Widget _buildOrderList() {
    return StreamBuilder<List<firestore.QueryDocumentSnapshot>>(
      stream: _buildOrderQuery(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }

        if (snapshot.hasError) {
          return _buildErrorState(snapshot.error.toString());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState();
        }

        final docs = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;
            return _buildOrderCard(Order.fromMap(data));
          },
        );
      },
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            'Đã xảy ra lỗi',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => setState(() {}),
            icon: const Icon(Icons.refresh),
            label: const Text('Thử Lại'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(221, 202, 159, 159),
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
            valueColor: AlwaysStoppedAnimation<Color>(
                const Color.fromARGB(221, 202, 159, 159)),
          ),
          const SizedBox(height: 16),
          Text(
            'Đang tải đơn hàng...',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final statusText = _selectedStatus == 'all'
        ? 'đơn hàng'
        : _selectedStatus == 'pending'
            ? 'đơn hàng chờ xử lý'
            : _selectedStatus == 'processing'
                ? 'đơn hàng đang xử lý'
                : _selectedStatus == 'shipped'
                    ? 'đơn hàng đã giao'
                    : 'đơn hàng đã hủy';

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 72, color: Colors.grey[300]),
          const SizedBox(height: 24),
          Text(
            'Không tìm thấy $statusText',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Đơn hàng phù hợp với bộ lọc sẽ xuất hiện ở đây',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    final timestamp = order.createdAt;
    final dateString = DateFormat('dd/MM/yyyy').format(timestamp);
    final timeString = DateFormat('HH:mm').format(timestamp);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderDetailScreen(orderId: order.id),
            ),
          );
        },
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            childrenPadding: EdgeInsets.zero,
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            backgroundColor: Colors.white,
            collapsedBackgroundColor: Colors.white,
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(221, 202, 159, 159)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.receipt_long,
                    color: const Color.fromARGB(221, 202, 159, 159),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Đơn #${order.id.substring(0, min(8, order.id.length))}',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 12,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            dateString,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.access_time,
                            size: 12,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            timeString,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatusBadge(order.status),
                    Text(
                      '${NumberFormat.currency(locale: 'vi_VN', symbol: '', decimalDigits: 0).format(order.totalAmount)}₫',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color.fromARGB(221, 202, 159, 159),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.grey[700],
                  size: 22,
                ),
              ),
            ),
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Chi Tiết Đơn Hàng',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildOrderDetailRow(
                      Icons.person_outline,
                      'Khách Hàng',
                      order.userId,
                    ),
                    _buildOrderDetailRow(
                      Icons.location_on_outlined,
                      'Địa Chỉ',
                      order.address,
                    ),
                    _buildOrderDetailRow(
                      Icons.phone_outlined,
                      'Điện Thoại',
                      order.phone,
                    ),
                    _buildOrderDetailRow(
                      Icons.shopping_bag_outlined,
                      'Số Lượng Sản Phẩm',
                      '${order.items.length} sản phẩm',
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildPriceRow(
                            'Tạm Tính',
                            '${NumberFormat.currency(locale: 'vi_VN', symbol: '', decimalDigits: 0).format(order.subtotal)}₫',
                            isTotal: false,
                          ),
                          const SizedBox(height: 8),
                          _buildPriceRow(
                            'Phí Vận Chuyển',
                            '${NumberFormat.currency(locale: 'vi_VN', symbol: '', decimalDigits: 0).format(order.deliveryFee)}₫',
                            isTotal: false,
                          ),
                          if (order.discountAmount > 0) ...[
                            const SizedBox(height: 8),
                            _buildPriceRow(
                              'Giảm Giá',
                              '-${NumberFormat.currency(locale: 'vi_VN', symbol: '', decimalDigits: 0).format(order.discountAmount)}₫',
                              isDiscount: true,
                            ),
                          ],
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Divider(),
                          ),
                          _buildPriceRow(
                            'Tổng Cộng',
                            '${NumberFormat.currency(locale: 'vi_VN', symbol: '', decimalDigits: 0).format(order.totalAmount)}₫',
                            isTotal: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.visibility),
                            label: const Text('Xem chi tiết'),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      OrderDetailScreen(orderId: order.id),
                                ),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: const Color.fromARGB(221, 202, 159, 159),
                              ),
                              foregroundColor:
                                  const Color.fromARGB(221, 202, 159, 159),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.check_circle_outline),
                            label: const Text('Xử lý đơn hàng'),
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(221, 202, 159, 159),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(OrderStatus status) {
    String label;
    Color backgroundColor;
    Color textColor;
    IconData icon;

    switch (status) {
      case OrderStatus.pending:
        label = 'CHỜ XỬ LÝ';
        backgroundColor = Colors.orange[50]!;
        textColor = Colors.orange[700]!;
        icon = Icons.access_time;
        break;
      case OrderStatus.processing:
        label = 'ĐANG XỬ LÝ';
        backgroundColor = Colors.blue[50]!;
        textColor = Colors.blue[700]!;
        icon = Icons.sync;
        break;
      case OrderStatus.shipped:
        label = 'ĐÃ GIAO';
        backgroundColor = Colors.green[50]!;
        textColor = Colors.green[700]!;
        icon = Icons.local_shipping;
        break;
      case OrderStatus.cancelled:
        label = 'ĐÃ HỦY';
        backgroundColor = Colors.red[50]!;
        textColor = Colors.red[700]!;
        icon = Icons.cancel;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: textColor.withOpacity(0.5),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: textColor,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderDetailRow(IconData icon, String label, String value) {
    final isMissing = value.isEmpty;
    final displayValue = isMissing ? 'Chưa cập nhật' : value;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isMissing ? Colors.grey[100] : Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 16,
              color: isMissing ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  displayValue,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: isMissing ? Colors.grey[400] : Colors.grey[800],
                    fontStyle: isMissing ? FontStyle.italic : FontStyle.normal,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String price,
      {bool isTotal = false, bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: isTotal ? 15 : 14,
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.w500,
            color: isTotal ? Colors.grey[800] : Colors.grey[600],
          ),
        ),
        Text(
          price,
          style: GoogleFonts.poppins(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.w500,
            color: isDiscount
                ? Colors.green[700]
                : isTotal
                    ? const Color.fromARGB(221, 202, 159, 159)
                    : Colors.grey[800],
          ),
        ),
      ],
    );
  }

  Stream<List<firestore.QueryDocumentSnapshot>> _buildOrderQuery() {
    firestore.Query query =
        firestore.FirebaseFirestore.instance.collection('orders');

    if (_selectedStatus != 'all') {
      // Fix the status filtering by using the proper string format
      query =
          query.where('status', isEqualTo: 'OrderStatus.${_selectedStatus}');
    }

    if (_searchController.text.isNotEmpty) {
      // Search by ID substring
      String searchText = _searchController.text.toLowerCase();

      // Since we can't do substring search directly in Firestore, we'll filter in the app
      return query
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        // Client-side filtering
        return snapshot.docs.where((doc) {
          final id = doc.id.toLowerCase();
          final data = doc.data() as Map<String, dynamic>;
          final userId = (data['userId'] ?? '').toString().toLowerCase();
          final phone = (data['phone'] ?? '').toString().toLowerCase();

          return id.contains(searchText) ||
              userId.contains(searchText) ||
              phone.contains(searchText);
        }).toList();
      });
    }

    return query
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs);
  }
}
