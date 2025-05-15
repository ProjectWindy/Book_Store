import 'package:books_store/common/extension.dart';
import 'package:books_store/common/locator.dart';
import 'package:books_store/common/globs.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final NavigationService _navigationService = locator<NavigationService>();

  static const String _usersCollection = 'users';
  static const String _defaultRole = 'users';

  /// Đăng nhập bằng email và mật khẩu
  /// Trả về một `Map` chứa kết quả `success` và thông tin người dùng (nếu thành công)
  Future<Map<String, dynamic>> loginWithEmailPassword(
      String email, String password) async {
    try {
      // Kiểm tra email có hợp lệ không (sử dụng extension)
      if (!email.isEmail) {
        return {'success': false, 'message': MSG.enterEmail};
      }

      // Kiểm tra mật khẩu có đủ độ dài không
      if (password.length < 6) {
        return {'success': false, 'message': MSG.enterPassword};
      }

      // Đăng nhập với email và mật khẩu
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Lấy thông tin người dùng từ Firestore
      final userDoc = await _getUserDocument(userCredential.user?.uid);

      return {'success': true, 'user': userDoc?.data()};
    } on FirebaseAuthException catch (e) {
      // Xử lý các lỗi phổ biến khi đăng nhập
      return {
        'success': false,
        'message': _getAuthErrorMessage(e),
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Đăng nhập bằng tài khoản Google
  Future<Map<String, dynamic>> loginWithGoogle() async {
    try {
      // Mở hộp thoại đăng nhập Google
      final googleUser = await _googleSignIn.signIn();

      // Nếu người dùng hủy đăng nhập
      if (googleUser == null) {
        return {'success': false, 'message': "Google sign-in aborted"};
      }

      // Lấy thông tin xác thực từ Google
      final googleAuth = await googleUser.authentication;

      // Tạo credential (chứng thực) để đăng nhập vào Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Đăng nhập vào Firebase bằng Google
      final userCredential = await _auth.signInWithCredential(credential);

      // Kiểm tra xem user đã có trong Firestore chưa
      final userDoc = await _getUserDocument(userCredential.user?.uid);

      // Nếu user chưa tồn tại, lưu thông tin vào Firestore
      if (userDoc == null || !userDoc.exists) {
        await _createUserDocument(
          userCredential.user?.uid,
          {
            'email': userCredential.user?.email,
            'name': userCredential.user?.displayName,
            'address': '',
            'role': _defaultRole,
          },
        );
      }

      return {'success': true, 'user': userDoc?.data()};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Đăng ký tài khoản mới
  /// Trả về `UserCredential` nếu thành công
  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String name,
    required String mobile,
    required String address,
  }) async {
    try {
      // Tạo tài khoản Firebase bằng email và mật khẩu
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Lưu thông tin người dùng vào Firestore
      await _createUserDocument(
        userCredential.user?.uid,
        {
          'name': name,
          'mobile': mobile,
          'address': address,
          'role': _defaultRole,
        },
      );

      return userCredential;
    } catch (e) {
      rethrow; // Ném lại lỗi để UI có thể xử lý
    }
  }

  /// Lấy vai trò của người dùng từ Firestore
  Future<String> getUserRole() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return _defaultRole;

      final userDoc = await _getUserDocument(user.uid);
      return userDoc?.get('role') ?? _defaultRole;
    } catch (e) {
      return _defaultRole;
    }
  }

  /// Đăng xuất người dùng
  Future<void> logout() async {
    try {
      _navigationService.navigateTo("welcome");
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      throw Exception('Logout failed: ${e.toString()}');
    }
  }

  Future<DocumentSnapshot?> _getUserDocument(String? uid) async {
    if (uid == null) return null;
    return await _firestore.collection(_usersCollection).doc(uid).get();
  }

  Future<void> _createUserDocument(String? uid, Map<String, dynamic> data) async {
    if (uid == null) return;
    await _firestore.collection(_usersCollection).doc(uid).set(data);
  }

  String _getAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return MSG.userNotFound;
      case 'wrong-password':
        return MSG.wrongPassword;
      default:
        return e.message ?? MSG.fail;
    }
  }

  Future<void> createDefaultAdminAccount() async {
    const email = "admin@test.com";
    const password = "123456";

    try {
      // Check if admin account already exists
      final userDoc = await _firestore.collection('users').doc('admin').get();
      if (!userDoc.exists) {
        // Create auth account
        final userCredential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Create admin document in Firestore
        await _firestore.collection('users').doc('admin').set({
          'uid': userCredential.user!.uid,
          'email': email,
          'role': 'admin',
          'name': 'Admin',
          'status': 'active',
          'createdAt': FieldValue.serverTimestamp(),
        });

       } else {
       }
    } catch (e) {
       try {
        final userCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        await _firestore.collection('users').doc('admin').set({
          'uid': userCredential.user!.uid,
          'email': email,
          'role': 'admin',
          'name': 'Admin',
          'status': 'active',
          'createdAt': FieldValue.serverTimestamp(),
        });
      // ignore: empty_catches
      } catch (e) {
       }
    }
  }
}
