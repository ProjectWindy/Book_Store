import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book_model.dart';
import '../widgets/upcoming_book_card.dart';

class UpcomingBooksScreen extends StatefulWidget {
  const UpcomingBooksScreen({super.key});

  @override
  State<UpcomingBooksScreen> createState() => _UpcomingBooksScreenState();
}

class _UpcomingBooksScreenState extends State<UpcomingBooksScreen> {
  final _refreshKey = GlobalKey<RefreshIndicatorState>();

  Future<void> _refreshBooks() async {
    // Force refresh the stream
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sách sắp ra mắt'),
      ),
      body: RefreshIndicator(
        key: _refreshKey,
        onRefresh: _refreshBooks,
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('books')
              .where('isUpcoming', isEqualTo: true)
              .orderBy('releaseDate')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Đã xảy ra lỗi: ${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _refreshBooks,
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            final books = snapshot.data?.docs.map((doc) {
                  return Book.fromMap({
                    'id': doc.id,
                    ...doc.data() as Map<String, dynamic>,
                  });
                }).toList() ??
                [];

            if (books.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.book_outlined,
                      size: 48,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Chưa có sách sắp ra mắt',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _refreshBooks,
                      child: const Text('Làm mới'),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: books.length,
              itemBuilder: (context, index) {
                final book = books[index];
                return UpcomingBookCard(
                  book: book,
                  releaseDate: book.releaseDate ?? 'Sắp ra mắt',
                );
              },
            );
          },
        ),
      ),
    );
  }
}
