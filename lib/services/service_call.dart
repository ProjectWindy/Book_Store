import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book.dart';

class FirestoreService {
  final CollectionReference booksCollection =
      FirebaseFirestore.instance.collection('menu_items');

  // Get all books
  Stream<List<Book>> getBooks() {
    return booksCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Book(
          id: doc.id,
          title: data['name'] ?? '',
          author: data['author'] ?? '',
          authorImg: data['author_img'] ?? '',
          cover: data['image'] ?? '',
          showImage: data['image'] ?? '',
          age: data['age'] ?? '',
          genre: data['category'] ?? '',
          lanugage: data['language'] ?? '',
          price: double.parse(data['rate']?.toString() ?? '0'),
          rating: double.parse(data['rating']?.toString() ?? '0'),
          seller: data['seller'] ?? false,
          summary: data['description'] ?? '',
          category: data['type'] ?? '',
        );
      }).toList();
    });
  }

  // Add a new book
  Future<void> addBook(Book book) {
    return booksCollection.add({
      'name': book.title,
      'author': book.author,
      'author_img': book.authorImg,
      'image': book.cover,
      'age': book.age,
      'category': book.genre,
      'language': book.lanugage,
      'rate': book.price.toString(),
      'rating': book.rating.toString(),
      'seller': book.seller,
      'description': book.summary,
      'type': book.category,
    });
  }

  // Update a book
  Future<void> updateBook(String documentId, Book book) {
    return booksCollection.doc(documentId).update({
      'name': book.title,
      'author': book.author,
      'author_img': book.authorImg,
      'image': book.cover,
      'age': book.age,
      'category': book.genre,
      'language': book.lanugage,
      'rate': book.price.toString(),
      'rating': book.rating.toString(),
      'seller': book.seller,
      'description': book.summary,
      'type': book.category,
    });
  }

  // Delete a book
  Future<void> deleteBook(String documentId) {
    return booksCollection.doc(documentId).delete();
  }
}
