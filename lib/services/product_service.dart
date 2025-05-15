import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';

class ProductService {
  // Khởi tạo Firestore để thao tác với dữ liệu trên Firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Lấy danh sách các món ăn từ Firestore
  /// Trả về danh sách dạng `List<Map<String, dynamic>>`
  Future<List<Map<String, dynamic>>> fetchMenuItems() async {
    try {
      // Lấy toàn bộ dữ liệu từ collection "menu_items"
      QuerySnapshot snapshot = await _firestore.collection("menu_items").get();

      // Chuyển đổi dữ liệu từ Firestore thành danh sách Map
      List<Map<String, dynamic>> menu = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        return {
          'image': data['image'], // Hình ảnh món ăn
          'name': data['name'] ?? 'Unknown', // Tên món ăn
          'rate': data['rate'] ?? '0.0', // Điểm đánh giá
          'rating': data['rating'] ?? '0', // Số lượng đánh giá
          'type': data['type'] ?? 'Unknown',
          'food_type': data['food_type'] ?? 'Other',
        };
      }).toList();

      return menu;
    } catch (e) {
      return [];
    }
  }

  /// Kiểm tra xem dữ liệu menu đã tồn tại trong Firebase Realtime Database chưa.
  /// Nếu chưa tồn tại, có thể tải lên dữ liệu.
  Future<void> uploadMenuItems() async {
    final DatabaseReference database = FirebaseDatabase.instance.ref();
    final DataSnapshot snapshot = await database.child('menu_items').get();

    if (snapshot.exists) {
      return;
    }
  }

  /// Bộ lọc tìm kiếm món ăn dựa trên từ khóa nhập vào.
  /// `menuItems`: Danh sách tất cả các món ăn.
  /// `query`: Chuỗi tìm kiếm.
  /// Trả về danh sách các món ăn có chứa `query` trong tên món.
  List<Map<String, dynamic>> filterMenuItems(
      List<Map<String, dynamic>> menuItems, String query) {
    return menuItems.where((item) {
      return item['name']
          .toString()
          .toLowerCase()
          .contains(query.toLowerCase());
    }).toList();
  }

  /// Lấy tất cả các sản phẩm từ Firestore
  /// Trả về `QuerySnapshot` chứa danh sách sản phẩm
  Future<QuerySnapshot> getAllProducts() async {
    return await _firestore.collection('menu_items').get();
  }

  /// Tìm kiếm sản phẩm dựa trên từ khóa
  /// Trả về danh sách các DocumentSnapshot chứa sản phẩm phù hợp
  Future<List<DocumentSnapshot>> searchProducts(String searchQuery) async {
    QuerySnapshot snapshot = await getAllProducts();

    return snapshot.docs.where((doc) {
      var product = doc.data() as Map<String, dynamic>;
      return product['name']
          .toString()
          .toLowerCase()
          .contains(searchQuery.toLowerCase());
    }).toList();
  }
}
