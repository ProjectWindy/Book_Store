import 'package:cloud_firestore/cloud_firestore.dart';

class Order {
  final String id;
  final String userId;
  final List<Map<String, dynamic>> items;
  final double totalAmount;
  final String status; // pending, paid, cancelled, delivered
  final String paymentMethod;
  final String? paymentId;
  final DateTime createdAt;
  final DateTime? paidAt;
  final String? voucherCode;
  final double? discountAmount;
  final String shippingAddress;
  final String? trackingNumber;
  final String? note;

  const Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.paymentMethod,
    this.paymentId,
    required this.createdAt,
    this.paidAt,
    this.voucherCode,
    this.discountAmount = 0.0,
    required this.shippingAddress,
    this.trackingNumber,
    this.note,
  });

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      items: List<Map<String, dynamic>>.from(map['items'] ?? []),
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
      status: map['status'] ?? 'pending',
      paymentMethod: map['paymentMethod'] ?? '',
      paymentId: map['paymentId'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      paidAt:
          map['paidAt'] != null ? (map['paidAt'] as Timestamp).toDate() : null,
      voucherCode: map['voucherCode'],
      discountAmount: map['discountAmount']?.toDouble(),
      shippingAddress: map['shippingAddress'] ?? '',
      trackingNumber: map['trackingNumber'],
      note: map['note'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'items': items,
      'totalAmount': totalAmount,
      'status': status,
      'paymentMethod': paymentMethod,
      'paymentId': paymentId,
      'createdAt': Timestamp.fromDate(createdAt),
      'paidAt': paidAt != null ? Timestamp.fromDate(paidAt!) : null,
      'voucherCode': voucherCode,
      'discountAmount': discountAmount,
      'shippingAddress': shippingAddress,
      'trackingNumber': trackingNumber,
      'note': note,
    };
  }

  bool get isPaid => status == 'paid';
  bool get isPending => status == 'pending';
  bool get isCancelled => status == 'cancelled';
  bool get isDelivered => status == 'delivered';
}
