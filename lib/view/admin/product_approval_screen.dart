import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProductApprovalScreen extends StatefulWidget {
  const ProductApprovalScreen({super.key});

  @override
  State<ProductApprovalScreen> createState() => _ProductApprovalScreenState();
}

class _ProductApprovalScreenState extends State<ProductApprovalScreen> {
  String _selectedStatus = 'OrderStatus.pending';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Quản Lý Đơn Hàng',
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
          _buildStatusFilter(),
          Expanded(
            child: _buildOrderList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusFilter() {
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
            'Lọc Đơn Hàng',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildFilterChip('Tất Cả', 'all'),
              _buildFilterChip('Chờ Xử Lý', 'OrderStatus.pending'),
              _buildFilterChip('Đang Xử Lý', 'OrderStatus.processing'),
              _buildFilterChip('Đã Giao', 'OrderStatus.shipped'),
              _buildFilterChip('Đã Hủy', 'OrderStatus.cancelled'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String status) {
    final isSelected = _selectedStatus == status;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedStatus = status;
        });
      },
      backgroundColor: Colors.white,
      selectedColor: const Color.fromARGB(221, 202, 159, 159).withOpacity(0.2),
      checkmarkColor: const Color.fromARGB(221, 202, 159, 159),
      labelStyle: GoogleFonts.poppins(
        color: isSelected
            ? const Color.fromARGB(221, 202, 159, 159)
            : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        fontSize: 14,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
    );
  }

  Widget _buildOrderList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _selectedStatus == 'all'
          ? FirebaseFirestore.instance
              .collection('orders')
              .orderBy('createdAt', descending: true)
              .snapshots()
          : FirebaseFirestore.instance
              .collection('orders')
              .where('status', isEqualTo: _selectedStatus)
              .orderBy('createdAt', descending: true)
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildErrorState(snapshot.error.toString());
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }

        final orders = snapshot.data?.docs ?? [];
        if (orders.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          itemCount: orders.length,
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, index) {
            final orderData = orders[index].data() as Map<String, dynamic>;
            final orderId = orders[index].id;
            final items = (orderData['items'] as List?) ?? [];

            return _buildOrderCard(orderId, orderData, items);
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
        : _selectedStatus == 'OrderStatus.pending'
            ? 'đơn hàng chờ xử lý'
            : _selectedStatus == 'OrderStatus.processing'
                ? 'đơn hàng đang xử lý'
                : _selectedStatus == 'OrderStatus.shipped'
                    ? 'đơn hàng đã giao'
                    : 'đơn hàng đã hủy';

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 72, color: Colors.grey[300]),
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

  Widget _buildOrderCard(
      String orderId, Map<String, dynamic> orderData, List items) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      elevation: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildOrderHeader(orderId, orderData),
          _buildOrderContent(orderData, items),
          if (_selectedStatus == 'OrderStatus.pending')
            _buildOrderPendingActions(orderId),
          if (_selectedStatus == 'OrderStatus.processing')
            _buildOrderProcessingActions(orderId),
          _buildOrderDetails(orderData),
        ],
      ),
    );
  }

  Widget _buildOrderHeader(String orderId, Map<String, dynamic> orderData) {
    final timestamp = orderData['createdAt'] as Timestamp?;
    final dateString = timestamp != null
        ? DateFormat('dd/MM/yyyy').format(timestamp.toDate())
        : 'Chưa có ngày';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Icon(Icons.receipt_long,
                    color: const Color.fromARGB(221, 202, 159, 159), size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Đơn Hàng #${orderId.substring(0, 8)}',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Colors.grey[800],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Ngày đặt: $dateString',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _buildStatusBadge(orderData['status']),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    String label = status == 'OrderStatus.pending'
        ? 'CHỜ XỬ LÝ'
        : status == 'OrderStatus.processing'
            ? 'ĐANG XỬ LÝ'
            : status == 'OrderStatus.shipped'
                ? 'ĐÃ GIAO'
                : 'ĐÃ HỦY';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getStatusBackgroundColor(status),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _getStatusColor(status).withOpacity(0.5),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getStatusIcon(status),
            size: 14,
            color: _getStatusColor(status),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _getStatusColor(status),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'OrderStatus.shipped':
        return Icons.local_shipping;
      case 'OrderStatus.cancelled':
        return Icons.cancel;
      case 'OrderStatus.processing':
        return Icons.sync;
      case 'OrderStatus.pending':
        return Icons.access_time;
      default:
        return Icons.help_outline;
    }
  }

  Widget _buildOrderContent(Map<String, dynamic> orderData, List items) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: items.isNotEmpty
                ? _buildProductImage(items[0]['showImage'] ?? '')
                : _buildPlaceholderImage(),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(
                  Icons.person_outline,
                  'ID Khách Hàng: ${_formatMissingInfo(orderData['userId'])}',
                  Colors.grey[700]!,
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  Icons.attach_money,
                  '${NumberFormat.currency(locale: 'vi_VN', symbol: '', decimalDigits: 0).format((orderData['totalAmount'] ?? 0.0) * 1000)}đ',
                  const Color.fromARGB(221, 202, 159, 159),
                  isMoney: true,
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  Icons.shopping_bag_outlined,
                  '${items.length} sản phẩm',
                  Colors.grey[700]!,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage(String imagePath) {
    // Check if image is empty
    if (imagePath.isEmpty) {
      return _buildPlaceholderImage();
    }

    // Handle asset images
    if (imagePath.startsWith('assets/')) {
      return Image.asset(
        imagePath,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholderImage();
        },
      );
    }

    // Handle network images with caching
    if (imagePath.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: imagePath,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          width: 80,
          height: 80,
          color: Colors.grey[200],
          child: Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                const Color.fromARGB(221, 202, 159, 159),
              ),
            ),
          ),
        ),
        errorWidget: (context, url, error) => _buildPlaceholderImage(),
      );
    }

    // Fallback for any other case
    return _buildPlaceholderImage();
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Icon(Icons.image, color: Colors.grey[400], size: 30),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, Color color,
      {bool isMoney = false}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: isMoney ? 16 : 14,
              fontWeight: isMoney ? FontWeight.w600 : FontWeight.w500,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildOrderPendingActions(String orderId) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey.shade200),
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          OutlinedButton.icon(
            onPressed: () => _showRejectDialog(orderId),
            icon: const Icon(Icons.cancel_outlined, size: 18),
            label: const Text('Hủy Đơn'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red[700],
              side: BorderSide(color: Colors.red[300]!),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: () => _processOrder(orderId),
            icon: const Icon(Icons.sync, size: 18),
            label: const Text('Xử Lý Đơn'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber[700],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderProcessingActions(String orderId) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey.shade200),
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          OutlinedButton.icon(
            onPressed: () => _showRejectDialog(orderId),
            icon: const Icon(Icons.cancel_outlined, size: 18),
            label: const Text('Hủy Đơn'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red[700],
              side: BorderSide(color: Colors.red[300]!),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: () => _approveOrder(orderId),
            icon: const Icon(Icons.local_shipping_outlined, size: 18),
            label: const Text('Giao Hàng'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(221, 202, 159, 159),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderDetails(Map<String, dynamic> orderData) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      padding: const EdgeInsets.all(16),
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
          _buildDetailRow(
            Icons.calendar_today_outlined,
            'Ngày Tạo',
            _formatDate(orderData['createdAt']),
          ),
          const SizedBox(height: 8),
          _buildDetailRow(
            Icons.location_on_outlined,
            'Địa Chỉ Giao Hàng',
            _formatMissingInfo(orderData['address']),
          ),
          if (orderData['updatedAt'] != null) ...[
            const SizedBox(height: 8),
            _buildDetailRow(
              Icons.update,
              'Cập Nhật Lần Cuối',
              _formatDate(orderData['updatedAt']),
            ),
          ],
          if (orderData['cancellationReason'] != null) ...[
            const SizedBox(height: 8),
            _buildDetailRow(
              Icons.comment_outlined,
              'Lý Do Hủy',
              orderData['cancellationReason'],
            ),
          ],
        ],
      ),
    );
  }

  String _formatMissingInfo(dynamic value) {
    if (value == null || value.toString().trim().isEmpty) {
      return 'Chưa cập nhật';
    }
    return value.toString();
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    final isMissing = value == 'Chưa cập nhật';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon,
              size: 16, color: isMissing ? Colors.grey[400] : Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: isMissing ? Colors.grey[400] : Colors.grey[800],
                    fontStyle: isMissing ? FontStyle.italic : FontStyle.normal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusBackgroundColor(String status) {
    switch (status) {
      case 'OrderStatus.shipped':
        return Colors.green[50]!;
      case 'OrderStatus.cancelled':
        return Colors.red[50]!;
      case 'OrderStatus.processing':
        return Colors.amber[50]!;
      case 'OrderStatus.pending':
        return Colors.orange[50]!;
      default:
        return Colors.grey[50]!;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'OrderStatus.shipped':
        return Colors.green[700]!;
      case 'OrderStatus.cancelled':
        return Colors.red[700]!;
      case 'OrderStatus.processing':
        return Colors.amber[700]!;
      case 'OrderStatus.pending':
        return Colors.orange[700]!;
      default:
        return Colors.grey[700]!;
    }
  }

  Future<void> _processOrder(String orderId) async {
    try {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .update({
        'status': 'OrderStatus.processing',
        'updatedAt': FieldValue.serverTimestamp(),
      });
      _showSuccessSnackBar(
          'Đơn hàng đã được chuyển sang trạng thái Đang Xử Lý');
    } catch (e) {
      _showErrorSnackBar('Lỗi khi cập nhật đơn hàng: $e');
    }
  }

  Future<void> _approveOrder(String orderId) async {
    try {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .update({
        'status': 'OrderStatus.shipped',
        'updatedAt': FieldValue.serverTimestamp(),
      });
      _showSuccessSnackBar('Đơn hàng đã được chuyển sang trạng thái Đã Giao');
    } catch (e) {
      _showErrorSnackBar('Lỗi khi cập nhật đơn hàng: $e');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Future<void> _showRejectDialog(String orderId) async {
    final reasonController = TextEditingController();
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Hủy Đơn Hàng',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vui lòng cung cấp lý do hủy đơn:',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                hintText: 'Nhập lý do hủy đơn',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                      color: const Color.fromARGB(221, 202, 159, 159),
                      width: 2),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
              maxLines: 3,
            ),
          ],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Quay Lại',
              style: GoogleFonts.poppins(
                color: Colors.grey[700],
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              if (reasonController.text.isNotEmpty) {
                _cancelOrder(orderId, reasonController.text);
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Vui lòng nhập lý do hủy đơn'),
                  ),
                );
              }
            },
            icon: const Icon(Icons.cancel_outlined, size: 18),
            label: const Text('Hủy Đơn Hàng'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[700],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelOrder(String orderId, String reason) async {
    try {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .update({
        'status': 'OrderStatus.cancelled',
        'updatedAt': FieldValue.serverTimestamp(),
        'cancellationReason': reason,
      });
      _showSuccessSnackBar('Đơn hàng đã được hủy thành công');
    } catch (e) {
      _showErrorSnackBar('Lỗi khi hủy đơn hàng: $e');
    }
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'Chưa cập nhật';
    if (timestamp is Timestamp) {
      final date = timestamp.toDate();
      return DateFormat('dd/MM/yyyy, HH:mm').format(date);
    }
    return 'Ngày không hợp lệ';
  }
}
