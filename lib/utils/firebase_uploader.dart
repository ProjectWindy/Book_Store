import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/firebase_upload_data.dart';

class FirebaseUploader {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Tải tất cả sách lên Firestore
  Future<void> uploadAllBooks() async {
    try {
      CollectionReference books = _firestore.collection('books');

      for (var book in firebaseBooks) {
        await books.add(book);
        print("Đã thêm sách: ${book['name']}");
      }

      print("Hoàn tất việc tải sách lên Firebase!");
    } catch (e) {
      print("Lỗi khi tải sách: $e");
    }
  }

  // Tải sách theo danh mục
  Future<void> uploadBooksByCategory(String category) async {
    try {
      CollectionReference books = _firestore.collection('books');
      final filteredBooks = getBooksByCategory(category);

      for (var book in filteredBooks) {
        await books.add(book);
        print("Đã thêm sách: ${book['name']}");
      }

      print("Hoàn tất việc tải sách danh mục $category lên Firebase!");
    } catch (e) {
      print("Lỗi khi tải sách: $e");
    }
  }

  // Kiểm tra xem sách đã tồn tại trên Firebase chưa
  Future<bool> isBookExist(String bookId) async {
    try {
      final query = await _firestore
          .collection('books')
          .where('id', isEqualTo: bookId)
          .get();

      return query.docs.isNotEmpty;
    } catch (e) {
      print("Lỗi khi kiểm tra sách: $e");
      return false;
    }
  }
}
