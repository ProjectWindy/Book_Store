// import 'package:flutter/material.dart';

// class Cart with ChangeNotifier {
//   List<Map<String, dynamic>> _items = [];

//   List<Map<String, dynamic>> get items => _items;

//   /// Thêm sản phẩm vào giỏ hàng (nếu đã có thì tăng số lượng)

//   void addItem(Map<String, dynamic> item) {
//     _items.add(item);
//     notifyListeners();
//   }

//   /// Tính tổng tiền giỏ hàng

//   double getTotal() {
//     double total = 0.0;
//     for (var item in _items) {
//       double price = item['price'] != null
//           ? double.tryParse(item['price'].toString()) ?? 0.0
//           : 0.0;
//       int qty = item['qty'] != null ? item['qty'] as int : 1;
//       total += price * qty;
//     }
//     return total;
//   }

//   /// Xóa toàn bộ giỏ hàng

//   void clear() {
//     _items.clear();
//     notifyListeners();
//   }

//   /// Xử lý thanh toán

//   Future<void> checkout() async {
//     clear();
//   }
// }
