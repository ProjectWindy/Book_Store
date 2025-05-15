import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/firebase_uploader.dart';
import 'add_book_screen.dart';
import 'edit_book_screen.dart';
import 'user_management_screen.dart';

class DataManagementScreen extends StatefulWidget {
  const DataManagementScreen({Key? key}) : super(key: key);

  @override
  State<DataManagementScreen> createState() => _DataManagementScreenState();
}

class _DataManagementScreenState extends State<DataManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isUploading = false;
  String _uploadStatus = '';
  final FirebaseUploader _uploader = FirebaseUploader();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _books = [];
  bool _isLoading = true;
  bool _showSuccessMessage = false;
  String _selectedCategory = 'All';
  List<String> _categories = [
    'All',
    'Fiction',
    'Non-Fiction',
    'Bestseller',
    'Promotions',
    'Cooking',
    'Self-Help',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchBooks();
  }

  Future<void> _fetchBooks() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final querySnapshot = await _firestore.collection('menu_items').get();

      setState(() {
        _books = querySnapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  ...doc.data() as Map<String, dynamic>,
                })
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _uploadStatus = 'Lỗi: $e';
      });
    }
  }

  Future<void> _uploadAllData() async {
    setState(() {
      _isUploading = true;
      _uploadStatus = 'Đang tải dữ liệu lên Firebase...';
      _showSuccessMessage = false;
    });

    try {
      await _uploader.uploadAllBooks();
      setState(() {
        _isUploading = false;
        _uploadStatus = 'Tải lên thành công tất cả dữ liệu!';
        _showSuccessMessage = true;
      });
      _fetchBooks();
    } catch (e) {
      setState(() {
        _isUploading = false;
        _uploadStatus = 'Lỗi khi tải dữ liệu: $e';
      });
    }
  }

  Future<void> _uploadByCategory(String category) async {
    setState(() {
      _isUploading = true;
      _uploadStatus = 'Đang tải dữ liệu danh mục $category lên Firebase...';
      _showSuccessMessage = false;
    });

    try {
      await _uploader.uploadBooksByCategory(category);
      setState(() {
        _isUploading = false;
        _uploadStatus = 'Tải lên thành công danh mục $category!';
        _showSuccessMessage = true;
      });
      _fetchBooks();
    } catch (e) {
      setState(() {
        _isUploading = false;
        _uploadStatus = 'Lỗi khi tải dữ liệu: $e';
      });
    }
  }

  Future<void> _deleteBook(String bookId) async {
    try {
      await _firestore.collection('menu_items').doc(bookId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Đã xóa sách thành công',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      _fetchBooks();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Lỗi khi xóa sách: $e',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TabBar(
            controller: _tabController,
            labelColor: const Color.fromARGB(221, 202, 159, 159),
            unselectedLabelColor: Colors.grey[600],
            indicatorColor: const Color.fromARGB(221, 202, 159, 159),
            indicatorWeight: 3,
            labelStyle: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
            tabs: const [
              Tab(text: 'Sách', icon: Icon(Icons.book)),
              Tab(text: 'Người dùng', icon: Icon(Icons.people)),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBooksTab(),
          _buildUsersTab(),
        ],
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton(
              backgroundColor: const Color.fromARGB(221, 202, 159, 159),
              child: const Icon(Icons.add, color: Colors.white),
              onPressed: _navigateToAddBook,
            )
          : null,
    );
  }

  Widget _buildBooksTab() {
    return Column(
      children: [
        _buildCategoryFilter(),
        Expanded(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('menu_items')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                          child: CircularProgressIndicator(
                        color: Color.fromARGB(221, 202, 159, 159),
                      ));
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Lỗi: ${snapshot.error}',
                          style: GoogleFonts.poppins(
                            color: Colors.red,
                            fontSize: 16,
                          ),
                        ),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.book_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Không có sách nào',
                              style: GoogleFonts.poppins(
                                color: Colors.grey[600],
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: _navigateToAddBook,
                              icon: const Icon(Icons.add),
                              label: Text('Thêm sách',
                                  style: GoogleFonts.poppins()),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(221, 202, 159, 159),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final books = snapshot.data!.docs;

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: books.length,
                      itemBuilder: (context, index) {
                        final bookData =
                            books[index].data() as Map<String, dynamic>;
                        final documentId = books[index].id;
                        final name = bookData['name'] ?? 'Không có tên';
                        final author = bookData['author'] ?? 'Không có tác giả';
                        final imageUrl = bookData['image'] ?? '';
                        final price = bookData['price'] ?? 0;
                        final category =
                            bookData['category'] ?? 'Không phân loại';

                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: InkWell(
                            onTap: () =>
                                _navigateToEditBook(bookData, documentId),
                            borderRadius: BorderRadius.circular(16),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Book cover image
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      width: 80,
                                      height: 120,
                                      decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.1),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: imageUrl.isNotEmpty
                                          ? imageUrl.startsWith('assets/')
                                              ? Image.asset(
                                                  imageUrl,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error,
                                                          stackTrace) =>
                                                      Container(
                                                    color: Colors.grey[200],
                                                    child: const Icon(
                                                      Icons.broken_image,
                                                      size: 30,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                )
                                              : Image.network(
                                                  imageUrl,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error,
                                                          stackTrace) =>
                                                      Container(
                                                    color: Colors.grey[200],
                                                    child: const Icon(
                                                      Icons.broken_image,
                                                      size: 30,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                )
                                          : Container(
                                              color: Colors.grey[200],
                                              child: const Icon(
                                                Icons.book,
                                                size: 30,
                                                color: Colors.grey,
                                              ),
                                            ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  // Book details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          name,
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Tác giả: $author',
                                          style: GoogleFonts.poppins(
                                            color: Colors.grey[700],
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        const SizedBox(height: 8),
                                      ],
                                    ),
                                  ),
                                  // Action buttons
                                  Column(
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.edit,
                                          color: Color.fromARGB(
                                              221, 202, 159, 159),
                                        ),
                                        onPressed: () => _navigateToEditBook(
                                            bookData, documentId),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        onPressed: () =>
                                            _showDeleteConfirmation(documentId),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              if (_isLoading)
                Container(
                  color: Colors.black.withOpacity(0.3),
                  child: const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color.fromARGB(221, 202, 159, 159),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Text(
              "Tất cả sách",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(221, 202, 159, 159),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsersTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_rounded,
              size: 100,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              'Quản lý người dùng',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(221, 202, 159, 159),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Xem và quản lý tất cả người dùng trong hệ thống',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UserManagementScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Đến trang quản lý người dùng'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(221, 202, 159, 159),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToAddBook() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddBookScreen()),
    ).then((_) => setState(() {}));
  }

  void _navigateToEditBook(Map<String, dynamic> bookData, String documentId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditBookScreen(
          book: bookData,
          documentId: documentId,
        ),
      ),
    ).then((_) => setState(() {}));
  }

  void _showDeleteConfirmation(String documentId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Xác nhận xóa',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Bạn có chắc chắn muốn xóa sách này không?',
          style: GoogleFonts.poppins(),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Hủy',
              style: GoogleFonts.poppins(
                color: Colors.grey[700],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteBook(documentId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Xóa',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
