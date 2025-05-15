import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../common/color_extension.dart';

class UpcomingBooksView extends StatefulWidget {
  const UpcomingBooksView({Key? key}) : super(key: key);

  @override
  State<UpcomingBooksView> createState() => _UpcomingBooksViewState();
}

class _UpcomingBooksViewState extends State<UpcomingBooksView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Sách sắp ra mắt",
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: TColor.primaryText,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: TColor.primaryText,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('upcoming_books')
            .orderBy('releaseDate')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Đã xảy ra lỗi khi tải dữ liệu',
                style: TextStyle(color: TColor.secondaryText),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final books = snapshot.data!.docs;

          if (books.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.book_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Chưa có sách sắp ra mắt',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Vui lòng quay lại sau',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index].data() as Map<String, dynamic>;
              final releaseDate = (book['releaseDate'] as Timestamp).toDate();
              final daysUntilRelease =
                  releaseDate.difference(DateTime.now()).inDays;

              return GestureDetector(
                onTap: () => _showBookDetails(context, book),
                child: Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Book cover image
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        child: Image.network(
                          book['coverUrl'] ??
                              'assets/images/upcoming/default_upcoming.jpg',
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: double.infinity,
                              height: 200,
                              color: Colors.grey[200],
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.book,
                                      size: 50,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Sách sắp ra mắt',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // Book details
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: TColor.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    daysUntilRelease > 0
                                        ? 'Còn $daysUntilRelease ngày'
                                        : 'Ra mắt hôm nay!',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: TColor.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Icon(
                                  Icons.notifications_none,
                                  color: TColor.primary,
                                  size: 22,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Nhận thông báo',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: TColor.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              book['title'] ?? 'Sách không tên',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: TColor.primaryText,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              book['author'] ?? 'Tác giả không xác định',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: TColor.secondaryText,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              book['description'] ?? 'Không có mô tả',
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: TColor.primaryText.withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Text(
                                  'Đơn giá: ${book['price']?.toString() ?? 'Chưa xác định'} đ',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: TColor.primary,
                                  ),
                                ),
                                const Spacer(),
                                ElevatedButton(
                                  onPressed: () => _showPreorderInfo(context),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 10,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text('Đặt trước'),
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
    );
  }

  void _showBookDetails(BuildContext context, Map<String, dynamic> book) {
    final releaseDate = (book['releaseDate'] as Timestamp).toDate();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with close button
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Chi tiết sách',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: TColor.primaryText,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Book cover
                    Center(
                      child: Container(
                        height: 250,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            book['coverUrl'] ??
                                'assets/images/upcoming/default_upcoming.jpg',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: double.infinity,
                                height: 250,
                                color: Colors.grey[200],
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.book,
                                        size: 50,
                                        color: Colors.grey[400],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Sách sắp ra mắt',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Title and author
                    Text(
                      book['title'] ?? 'Sách không tên',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: TColor.primaryText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      book['author'] ?? 'Tác giả không xác định',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: TColor.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Release date
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 18,
                          color: TColor.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Ngày phát hành: ${releaseDate.day}/${releaseDate.month}/${releaseDate.year}',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: TColor.primaryText,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Price
                    Row(
                      children: [
                        Icon(
                          Icons.attach_money,
                          size: 18,
                          color: TColor.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Giá bán: ${book['price']?.toString() ?? 'Chưa xác định'} đ',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: TColor.primaryText,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Genre
                    Row(
                      children: [
                        Icon(
                          Icons.category,
                          size: 18,
                          color: TColor.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Thể loại: ${book['genre'] ?? 'Chưa phân loại'}',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: TColor.primaryText,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Description
                    Text(
                      'Mô tả',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: TColor.primaryText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      book['description'] ??
                          'Không có mô tả cho cuốn sách này.',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: TColor.primaryText.withOpacity(0.8),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Preorder button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _showPreorderInfo(context),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Đặt trước',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Notify button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Bạn sẽ nhận được thông báo khi sách được phát hành'),
                            ),
                          );
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: TColor.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.notifications_none,
                              color: TColor.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Nhận thông báo khi phát hành',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPreorderInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Thông tin đặt trước',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: TColor.primaryText,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Chức năng đặt trước sách sắp được ra mắt!',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: TColor.primaryText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Bạn có thể đăng ký nhận thông báo để biết khi nào sách được phát hành.',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: TColor.secondaryText,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Đóng',
              style: GoogleFonts.poppins(
                color: TColor.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      'Bạn sẽ nhận được thông báo khi sách được phát hành'),
                ),
              );
            },
            child: Text(
              'Nhận thông báo',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
