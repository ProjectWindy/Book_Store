import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class OrderHistoryService {
  // Khởi tạo Firestore và FirebaseAuth
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Định dạng tiền tệ theo chuẩn US (ví dụ: 1,234.56)
  final NumberFormat currencyFormatter = NumberFormat("#,##0.00", "en_US");

  /// Lấy danh sách đơn hàng của người dùng dưới dạng Stream
  /// Dữ liệu sẽ được sắp xếp theo `timestamp` (mới nhất trước)
  Stream<QuerySnapshot> getUserOrdersStream() {
    User? user = _auth.currentUser;
    if (user == null) {
      throw Exception(
          "User not logged in"); // Báo lỗi nếu người dùng chưa đăng nhập
    }

    return _firestore
        .collection('payments') // Truy vấn collection 'payments'
        .where('userId', isEqualTo: user.uid) // Lọc theo ID người dùng
        .orderBy('timestamp',
            descending: true) // Sắp xếp theo thời gian giảm dần
        .snapshots(); // Lấy dữ liệu dạng stream để cập nhật theo thời gian thực
  }

  /// Chuyển đổi timestamp từ Firestore thành chuỗi ngày tháng có định dạng
  /// Định dạng: MM/dd/yyyy HH:mm (Ví dụ: 10/25/2023 14:30)
  String formatDateTime(dynamic timestamp) {
    if (timestamp == null) return 'N/A'; // Trả về 'N/A' nếu không có giá trị

    DateTime dateTime;
    if (timestamp is Timestamp) {
      dateTime = timestamp.toDate(); // Chuyển từ Firestore Timestamp
    } else if (timestamp is String) {
      dateTime = DateTime.parse(timestamp); // Chuyển từ chuỗi dạng ISO 8601
    } else {
      return 'N/A';
    }

    return DateFormat('MM/dd/yyyy HH:mm').format(dateTime);
  }

  /// Định dạng số tiền theo đơn vị tiền tệ
  /// Ví dụ: 1234.5 -> "$1,234.50"
  String formatCurrency(num? amount) {
    return '\$${currencyFormatter.format(amount ?? 0)}';
  }
}
