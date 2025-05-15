import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/voucher_model.dart';

class VoucherService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'vouchers';

  Future<Voucher?> getVoucherByCode(String code) async {
    try {
      print('Fetching voucher with code: $code');
      final snapshot = await _firestore
          .collection(_collection)
          .where('code', isEqualTo: code)
          .get();

      print('Found ${snapshot.docs.length} vouchers with code: $code');
      if (snapshot.docs.isEmpty) return null;

      final data = snapshot.docs.first.data();
      print('Voucher data: $data');

      return Voucher.fromMap({
        'id': snapshot.docs.first.id,
        ...data,
      });
    } catch (e) {
      print('Error fetching voucher by code: $e');
      return null;
    }
  }

  Future<bool> createVoucher({
    required String code,
    required String type,
    required double value,
    double? maxDiscount,
    required int quantity,
    required DateTime startDate,
    required DateTime endDate,
    required bool isActive,
  }) async {
    try {
      final voucher = Voucher(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        code: code,
        type: type,
        value: value,
        maxDiscount: maxDiscount,
        quantity: quantity,
        startDate: startDate,
        expiryDate: endDate,
        isActive: isActive,
      );

      await _firestore.collection(_collection).add(voucher.toMap());
      return true;
    } catch (e) {
      print('Error creating voucher: $e');
      return false;
    }
  }

  Future<bool> updateVoucherUsage(String voucherId) async {
    try {
      await _firestore.collection(_collection).doc(voucherId).update({
        'usedCount': FieldValue.increment(1),
      });
      return true;
    } catch (e) {
      print('Error updating voucher usage: $e');
      return false;
    }
  }

  Future<List<Voucher>> getSellerVouchers(String sellerId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('sellerId', isEqualTo: sellerId)
          .get();

      return snapshot.docs
          .map((doc) => Voucher.fromMap({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();
    } catch (e) {
      print('Error fetching seller vouchers: $e');
      return [];
    }
  }

  Future<bool> validateVoucher(Voucher voucher, double totalAmount) async {
    if (!voucher.isValid) {
      return false;
    }

    if (voucher.type == 'percentage' && voucher.maxDiscount != null) {
      final discount = totalAmount * (voucher.value / 100);
      if (discount > voucher.maxDiscount!) {
        return false;
      }
    }

    return true;
  }

  double calculateDiscount(Voucher voucher, double totalAmount) {
    if (voucher.type == 'percentage') {
      final discount = totalAmount * (voucher.value / 100);
      if (voucher.maxDiscount != null && discount > voucher.maxDiscount!) {
        return voucher.maxDiscount!;
      }
      return discount;
    } else {
      return voucher.value;
    }
  }

  Future<List<Voucher>> getActiveVouchers() async {
    try {
      print('Fetching active vouchers...');

      // Get all vouchers without filtering to examine their structure
      final allVouchersSnapshot =
          await _firestore.collection(_collection).get();

      print('Found ${allVouchersSnapshot.docs.length} total vouchers');

      // Print each voucher's data for debugging
      for (var doc in allVouchersSnapshot.docs) {
        print('Voucher ID: ${doc.id}, Data: ${doc.data()}');
      }

      // Try fetching with adjusted query
      final snapshot = await _firestore
          .collection(_collection)
          .where('isActive', isEqualTo: true)
          // Remove expiry date filter for testing
          // .where('expiryDate', isGreaterThan: Timestamp.now())
          .get();

      print('Found ${snapshot.docs.length} active vouchers');
      if (snapshot.docs.isEmpty) {
        print('No active vouchers found');
        return [];
      }

      final vouchers = snapshot.docs.map((doc) {
        final data = doc.data();
        print('Processing voucher: ${doc.id}');
        print('Data: $data');

        // Handle field name conversions if needed (e.g., discount -> value)
        if (data.containsKey('discount') && !data.containsKey('value')) {
          data['value'] = data['discount'];
        }

        return Voucher.fromMap({
          'id': doc.id,
          ...data,
        });
      }).toList();

      print('Processed ${vouchers.length} vouchers');
      return vouchers;
    } catch (e) {
      print('Error fetching active vouchers: $e');
      return [];
    }
  }
}
