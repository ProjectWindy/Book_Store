import 'package:cloud_firestore/cloud_firestore.dart';

class Voucher {
  final String id;
  final String code;
  final String type; // percentage or fixed
  final double value;
  final double? maxDiscount;
  final int quantity;
  final DateTime startDate;
  final DateTime expiryDate;
  final bool isActive;
  final int usedCount;

  const Voucher({
    required this.id,
    required this.code,
    required this.type,
    required this.value,
    this.maxDiscount,
    required this.quantity,
    required this.startDate,
    required this.expiryDate,
    required this.isActive,
    this.usedCount = 0,
  });

  factory Voucher.fromMap(Map<String, dynamic> map) {
    print('Creating Voucher from map: $map');

    // Handle different field names
    final double voucherValue = map.containsKey('value')
        ? (map['value'] ?? 0).toDouble()
        : map.containsKey('discount')
            ? (map['discount'] ?? 0).toDouble()
            : 0.0;

    // Check if we have startDate/expiryDate or createdAt/expiryDate
    DateTime startDateValue;
    if (map.containsKey('startDate')) {
      startDateValue =
          (map['startDate'] as Timestamp?)?.toDate() ?? DateTime.now();
    } else if (map.containsKey('createdAt')) {
      startDateValue =
          (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
    } else {
      startDateValue = DateTime.now();
    }

    // Get expiryDate
    DateTime expiryDateValue;
    if (map.containsKey('expiryDate')) {
      expiryDateValue = (map['expiryDate'] as Timestamp?)?.toDate() ??
          DateTime.now().add(const Duration(days: 30));
    } else if (map.containsKey('endDate')) {
      expiryDateValue = (map['endDate'] as Timestamp?)?.toDate() ??
          DateTime.now().add(const Duration(days: 30));
    } else {
      expiryDateValue = DateTime.now().add(const Duration(days: 30));
    }

    // Handle quantity field with proper type conversion
    int quantityValue;
    if (map.containsKey('quantity')) {
      // If quantity exists, convert to int
      final rawQuantity = map['quantity'];
      if (rawQuantity is int) {
        quantityValue = rawQuantity;
      } else if (rawQuantity is double) {
        quantityValue = rawQuantity.toInt();
      } else {
        quantityValue = 0;
      }
    } else if (map.containsKey('minPurchase')) {
      // If using minPurchase field, convert to int
      final rawMinPurchase = map['minPurchase'];
      if (rawMinPurchase is int) {
        quantityValue = rawMinPurchase;
      } else if (rawMinPurchase is double) {
        quantityValue = rawMinPurchase.toInt();
      } else {
        quantityValue = 0;
      }
    } else {
      quantityValue = 100; // Default to 100 if neither field exists
    }

    return Voucher(
      id: map['id'] ?? '',
      code: map['code'] ?? '',
      type: map['type'] ?? 'percentage',
      value: voucherValue,
      maxDiscount: map['maxDiscount']?.toDouble(),
      quantity: quantityValue,
      startDate: startDateValue,
      expiryDate: expiryDateValue,
      isActive: map['isActive'] ?? true,
      usedCount: map['usedCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'code': code,
      'type': type,
      'value': value,
      'maxDiscount': maxDiscount,
      'quantity': quantity,
      'startDate': Timestamp.fromDate(startDate),
      'expiryDate': Timestamp.fromDate(expiryDate),
      'isActive': isActive,
      'usedCount': usedCount,
    };
  }

  bool get isValid {
    final now = DateTime.now();
    return isActive &&
        now.isAfter(startDate) &&
        now.isBefore(expiryDate) &&
        usedCount < quantity;
  }
}
