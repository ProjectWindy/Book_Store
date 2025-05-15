import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:uuid/uuid.dart';
import '../models/order.dart';
import '../models/cart.dart';

class OrderService {
  final firestore.FirebaseFirestore _firestore =
      firestore.FirebaseFirestore.instance;
  final _uuid = const Uuid();

  // Tạo đơn hàng mới
  Future<Order> createOrder({
    required String userId,
    required List<CartItem> items,
    required double totalAmount,
    required String address,
    required String phone,
    PaymentMethod? paymentMethod,
    double deliveryFee = 2.0,
    required double subtotal,
    String? voucherCode,
    double discountAmount = 0.0,
  }) async {
    final orderId = _uuid.v4();

    final order = Order(
      id: orderId,
      userId: userId,
      items: items,
      totalAmount: totalAmount,
      address: address,
      phone: phone,
      paymentMethod: paymentMethod,
      deliveryFee: deliveryFee,
      subtotal: subtotal,
      voucherCode: voucherCode,
      discountAmount: discountAmount,
    );

    await _firestore.collection('orders').doc(orderId).set(order.toMap());

    return order;
  }

  // Lấy danh sách đơn hàng của user
  Stream<List<Order>> getUserOrders(String userId) {
    // Merge streams from both collections
    return firestore.FirebaseFirestore.instance
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Order.fromMap(doc.data());
      }).toList();
    });
  }

  // Lấy tất cả đơn hàng không lọc theo user
  Stream<List<Order>> getAllOrders() {
    return firestore.FirebaseFirestore.instance
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Order.fromMap(doc.data());
      }).toList();
    });
  }

  // Lấy đơn hàng theo trạng thái
  Stream<List<Order>> getOrdersByStatus(OrderStatus status) {
    final statusString = status.toString();

    return firestore.FirebaseFirestore.instance
        .collection('orders')
        .where('status', isEqualTo: statusString)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Order.fromMap(doc.data());
      }).toList();
    });
  }

  // Cập nhật trạng thái đơn hàng
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    await _firestore.collection('orders').doc(orderId).update({
      'status': status.toString(),
    });
  }

  // Lấy chi tiết đơn hàng
  Future<Order?> getOrderDetails(String orderId) async {
    final doc = await _firestore.collection('orders').doc(orderId).get();
    if (doc.exists) {
      return Order.fromMap(doc.data()!);
    }
    return null;
  }

  // Thêm phương thức lấy đơn hàng theo ID
  Future<Order?> getOrderById(String orderId) async {
    try {
      final doc = await _firestore.collection('orders').doc(orderId).get();

      if (!doc.exists) {
        return null;
      }

      final data = doc.data() as Map<String, dynamic>;
      return Order.fromMap(data);
    } catch (e) {
      print('Error getting order by ID: $e');
      throw Exception('Không thể tải thông tin đơn hàng');
    }
  }
}
