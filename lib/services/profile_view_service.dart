import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileViewService {
  // Khởi tạo các instance Firebase
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  // Lấy thông tin user hiện tại
  User? get currentUser => _auth.currentUser;

  /// Lấy dữ liệu hồ sơ người dùng từ Firestore
  /// Trả về một `Map<String, dynamic>` chứa thông tin người dùng
  Future<Map<String, dynamic>?> getUserData() async {
    User? user = currentUser;
    if (user != null) {
      // Truy vấn thông tin user từ Firestore dựa trên UID
      DocumentSnapshot snapshot =
          await _firestore.collection('users').doc(user.uid).get();
      if (snapshot.exists) {
        return snapshot.data() as Map<String, dynamic>?;
      }
    }
    return null;
  }

  /// Lấy ảnh đại diện người dùng từ Firebase Realtime Database
  /// Trả về đường dẫn ảnh dạng `String`
  Future<String?> getProfileImage() async {
    User? user = currentUser;
    if (user != null) {
      DataSnapshot snapshot =
          await _database.child('users/${user.uid}/profile_image').get();
      if (snapshot.exists) {
        return snapshot.value as String?;
      }
    }
    return null;
  }

  /// Cập nhật thông tin hồ sơ người dùng trên Firestore
  /// Nếu có ảnh mới, ảnh sẽ được lưu dưới dạng base64 vào Firebase Realtime Database
  Future<void> saveUserData({
    required String name,
    required String mobile,
    required String address,
    File? imageFile,
  }) async {
    User? user = currentUser;
    if (user != null) {
      // Cập nhật thông tin người dùng trên Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'name': name,
        'mobile': mobile,
        'address': address,
      });

      // Nếu có ảnh đại diện, mã hóa ảnh và lưu vào Firebase Realtime Database
      if (imageFile != null) {
        List<int> imageBytes = await imageFile.readAsBytes();
        String base64Image = base64Encode(imageBytes);
        await _database
            .child('users/${user.uid}/profile_image')
            .set(base64Image);
      }
    }
  }
}
