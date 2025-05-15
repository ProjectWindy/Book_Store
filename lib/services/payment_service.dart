import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/order_model.dart' as models;
import 'notification_service.dart';

class PaymentService {
  static final PaymentService _instance = PaymentService._internal();
  factory PaymentService() => _instance;
  PaymentService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationService _notificationService = NotificationService();

  static const String _ordersCollection = 'orders';
  static const String _vouchersCollection = 'vouchers';

  Future<void> initialize() async {
    try {
      // Initialize any necessary setup for payment service
    } catch (e) {
      print('Error initializing PaymentService: $e');
      throw Exception('Không thể khởi tạo dịch vụ thanh toán: $e');
    }
  }

  Future<models.Order?> getOrderById(String orderId) async {
    try {
      final doc =
          await _firestore.collection(_ordersCollection).doc(orderId).get();
      return doc.exists ? _mapDocumentToOrder(doc) : null;
    } catch (e) {
      throw Exception('Không thể lấy thông tin đơn hàng: $e');
    }
  }

  Future<List<models.Order>> getUserOrders(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_ordersCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map(_mapDocumentToOrder).toList();
    } catch (e) {
      throw Exception('Không thể lấy danh sách đơn hàng: $e');
    }
  }

  Future<void> updatePaymentStatus(String orderId, String status) async {
    try {
      await _firestore.collection(_ordersCollection).doc(orderId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Không thể cập nhật trạng thái thanh toán: $e');
    }
  }

  Future<models.Order> createOrder(models.Order order) async {
    try {
      await _firestore
          .collection(_ordersCollection)
          .doc(order.id)
          .set(order.toMap());
      return order;
    } catch (e) {
      throw Exception('Không thể tạo đơn hàng: $e');
    }
  }

  Stream<models.Order?> watchOrderStatus(String orderId) {
    return _firestore
        .collection(_ordersCollection)
        .doc(orderId)
        .snapshots()
        .map((doc) => doc.exists ? _mapDocumentToOrder(doc) : null);
  }

  Future<bool> isOrderPaid(String orderId) async {
    try {
      final order = await getOrderById(orderId);
      return order?.status == 'paid';
    } catch (e) {
      throw Exception('Không thể kiểm tra trạng thái thanh toán: $e');
    }
  }

  Stream<List<models.Order>> getOrdersByStatus(String status) {
    return _firestore
        .collection(_ordersCollection)
        .where('status', isEqualTo: status)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_mapDocumentToOrder).toList());
  }

  Future<Map<String, dynamic>> applyVoucher(
      String voucherCode, double totalAmount) async {
    try {
      final voucherDoc = await _getVoucherDocument(voucherCode);
      if (voucherDoc == null) {
        return _createVoucherResponse(
          success: false,
          message: 'Mã giảm giá không hợp lệ',
        );
      }

      final voucher = voucherDoc.data()! as Map<String, dynamic>;
      if (!_isVoucherValid(voucher)) {
        return _createVoucherResponse(
          success: false,
          message: 'Mã giảm giá đã hết hạn',
        );
      }

      final discountAmount = _calculateDiscountAmount(voucher, totalAmount);
      return _createVoucherResponse(
        success: true,
        message: 'Áp dụng mã giảm giá thành công',
        discountAmount: discountAmount,
        voucherCode: voucherCode,
      );
    } catch (e) {
      print('Error applying voucher: $e');
      return _createVoucherResponse(
        success: false,
        message: 'Có lỗi xảy ra khi áp dụng mã giảm giá',
      );
    }
  }

  Future<DocumentSnapshot?> _getVoucherDocument(String voucherCode) async {
    final voucherDoc = await _firestore
        .collection(_vouchersCollection)
        .where('code', isEqualTo: voucherCode)
        .where('isActive', isEqualTo: true)
        .get();
    return voucherDoc.docs.isNotEmpty ? voucherDoc.docs.first : null;
  }

  bool _isVoucherValid(Map<String, dynamic> voucher) {
    final now = DateTime.now();
    final startDate = (voucher['startDate'] as Timestamp).toDate();
    final endDate = (voucher['endDate'] as Timestamp).toDate();
    return now.isAfter(startDate) && now.isBefore(endDate);
  }

  double _calculateDiscountAmount(
      Map<String, dynamic> voucher, double totalAmount) {
    double discountAmount = voucher['type'] == 'percentage'
        ? totalAmount * (voucher['value'] / 100)
        : voucher['value'].toDouble();

    if (voucher['maxDiscount'] != null) {
      discountAmount = discountAmount > voucher['maxDiscount']
          ? voucher['maxDiscount'].toDouble()
          : discountAmount;
    }

    return discountAmount;
  }

  Map<String, dynamic> _createVoucherResponse({
    required bool success,
    required String message,
    double discountAmount = 0.0,
    String? voucherCode,
  }) {
    return {
      'success': success,
      'message': message,
      'discountAmount': discountAmount,
      if (voucherCode != null) 'voucherCode': voucherCode,
    };
  }

  models.Order _mapDocumentToOrder(DocumentSnapshot doc) {
    return models.Order.fromMap({
      'id': doc.id,
      ...(doc.data() as Map<String, dynamic>),
    });
  }
}
