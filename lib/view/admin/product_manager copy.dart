import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/book.dart';
import '../../services/service_call.dart';
import 'edit_book_screen.dart';
import 'add_book_screen.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class BookListScreen extends StatelessWidget {
  final FirestoreService firestoreService = FirestoreService();

  BookListScreen({super.key});

  void _showToast(BuildContext context, String message, bool isSuccess) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.error,
              color: Colors.white,
            ),
            SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          "Quản lý sách",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<List<Book>>(
        stream: firestoreService.getBooks(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final books = snapshot.data!;

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                margin: EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Book Cover Image with proper handling
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: _buildBookCover(book.cover),
                      ),
                      SizedBox(width: 16),
                      // Book Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              book.title,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Tác giả: ${book.author}",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Thể loại: ${book.genre}",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Giá: ${NumberFormat.currency(locale: 'vi_VN', symbol: '', decimalDigits: 0).format(book.price)}đ",
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue[700],
                              ),
                            ),
                            SizedBox(height: 12),
                            // Action Buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                _buildActionButton(
                                  context: context,
                                  onTap: () {
                                    if (book.id.isNotEmpty) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => EditBookScreen(
                                            book: {
                                              'name': book.title,
                                              'author': book.author,
                                              'rate': book.price.toString(),
                                              'description': book.summary,
                                              'image': book.cover,
                                              'category': book.genre,
                                              'author_img': book.authorImg,
                                              'type': book.genre,
                                            },
                                            documentId: book.id,
                                          ),
                                        ),
                                      ).then((_) {
                                        _showToast(context,
                                            'Cập nhật sách thành công', true);
                                      });
                                    } else {
                                      _showToast(context,
                                          'Lỗi: ID sách không hợp lệ', false);
                                    }
                                  },
                                  icon: Icons.edit_outlined,
                                  label: "Sửa",
                                  color: Colors.blue[700]!,
                                ),
                                SizedBox(width: 8),
                                _buildActionButton(
                                  context: context,
                                  onTap: () {
                                    _showDeleteDialog(context, book);
                                  },
                                  icon: Icons.delete_outline,
                                  label: "Xóa",
                                  color: Colors.red[700]!,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddBookScreen(),
            ),
          ).then((_) {
            _showToast(context, 'Thêm sách thành công', true);
          });
        },
        icon: Icon(Icons.add),
        label: Text("Thêm sách mới"),
        backgroundColor: Colors.blue[700],
      ),
    );
  }

  Widget _buildBookCover(String imagePath) {
    if (imagePath.startsWith('http')) {
      // Network image
      return CachedNetworkImage(
        imageUrl: imagePath,
        width: 100,
        height: 140,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          width: 100,
          height: 140,
          color: Colors.grey[200],
          child: Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
          ),
        ),
        errorWidget: (context, url, error) {
          // Try to load placeholder from assets if network image fails
          return Image.asset(
            'assets/img/book_placeholder.png',
            width: 100,
            height: 140,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              // If asset fails, show container with icon
              return Container(
                width: 100,
                height: 140,
                color: Colors.grey[200],
                child: Center(
                  child: Icon(
                    Icons.book,
                    size: 40,
                    color: Colors.grey[500],
                  ),
                ),
              );
            },
          );
        },
      );
    } else {
      // Asset image
      return Image.asset(
        imagePath,
        width: 100,
        height: 140,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          // If asset fails, show container with icon
          return Container(
            width: 100,
            height: 140,
            color: Colors.grey[200],
            child: Center(
              child: Icon(
                Icons.book,
                size: 40,
                color: Colors.grey[500],
              ),
            ),
          );
        },
      );
    }
  }

  Widget _buildActionButton({
    required BuildContext context,
    required VoidCallback onTap,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color),
            SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Book book) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Xác nhận xóa sách"),
          content: Text("Bạn có chắc chắn muốn xóa cuốn sách này?"),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Hủy bỏ"),
            ),
            TextButton(
              onPressed: () {
                firestoreService.deleteBook(book.id).then((_) {
                  Navigator.of(context).pop();
                  _showToast(context, 'Xóa sách thành công', true);
                }).catchError((error) {
                  Navigator.of(context).pop();
                  _showToast(context, 'Lỗi khi xóa sách', false);
                });
              },
              child: Text(
                "Xóa",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
