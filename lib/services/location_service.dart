import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LocationService {
  // Khởi tạo Firestore và FirebaseAuth
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Hàm lấy địa chỉ hiện tại của người dùng từ Firestore
  Future<String?> getCurrentAddress() async {
    try {
      // Lấy thông tin người dùng hiện tại
      User? user = _auth.currentUser;
      if (user != null) {
        // Truy vấn Firestore để lấy document của người dùng theo UID
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(user.uid).get();

        if (userDoc.exists) {
          // Ép kiểu dữ liệu sang Map để truy cập các trường dữ liệu
          Map<String, dynamic>? userData =
              userDoc.data() as Map<String, dynamic>?;
          // Trả về địa chỉ nếu có, nếu không thì trả về null
          return userData?['address'] as String?;
        }
      }
      return null; // Trả về null nếu không tìm thấy địa chỉ
    } catch (e) {
       rethrow; // Ném lỗi để xử lý bên ngoài
    }
  }

  /// Hàm cập nhật địa chỉ mới của người dùng lên Firestore
  Future<void> updateAddress(String newAddress) async {
    try {
      // Kiểm tra xem người dùng đã đăng nhập chưa
      User? user = _auth.currentUser;
      if (user != null) {
        // Cập nhật địa chỉ mới trong Firestore
        await _firestore
            .collection('users')
            .doc(user.uid)
            .update({'address': newAddress});
      } else {
        throw Exception('User not authenticated'); // Báo lỗi nếu chưa đăng nhập
      }
    } catch (e) {
       rethrow; // Ném lỗi để xử lý bên ngoài
    }
  }
}
