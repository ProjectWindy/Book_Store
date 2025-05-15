import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../common/color_extension.dart';
import '../more/upcoming_books_view.dart';

// ... existing imports and code

// Add this section to the home screen below an existing section (like popular books, bestsellers, etc.)
Widget _buildUpcomingBooksSection(BuildContext context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Sách sắp ra mắt',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: TColor.primaryText,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const UpcomingBooksView()),
                );
              },
              child: Text(
                'Xem tất cả',
                style: GoogleFonts.poppins(
                  color: TColor.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
      SizedBox(
        height: 220,
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('upcoming_books')
              .orderBy('releaseDate')
              .limit(5)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Lỗi khi tải sách sắp ra mắt',
                  style: TextStyle(color: TColor.secondaryText),
                ),
              );
            }

            final books = snapshot.data?.docs ?? [];

            if (books.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Text(
                    'Chưa có sách sắp ra mắt',
                    style: TextStyle(color: TColor.secondaryText),
                  ),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              scrollDirection: Axis.horizontal,
              itemCount: books.length,
              itemBuilder: (context, index) {
                final book = books[index].data() as Map<String, dynamic>;
                final releaseDate = (book['releaseDate'] as Timestamp).toDate();

                return GestureDetector(
                  onTap: () {
                    _showUpcomingBookDetails(context, book, releaseDate);
                  },
                  child: Container(
                    width: 140,
                    margin:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Book cover
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                          child: (book['coverUrl'] ?? '')
                                  .toString()
                                  .startsWith('assets/')
                              ? Image.asset(
                                  book['coverUrl'] ??
                                      'assets/images/upcoming/default_upcoming.jpg',
                                  width: 140,
                                  height: 140,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 140,
                                      height: 140,
                                      color: Colors.grey[200],
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.book,
                                              size: 40,
                                              color: Colors.grey[400],
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Sắp ra mắt',
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                )
                              : Image.network(
                                  book['coverUrl'] ??
                                      'assets/images/upcoming/default_upcoming.jpg',
                                  width: 140,
                                  height: 140,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 140,
                                      height: 140,
                                      color: Colors.grey[200],
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.book,
                                              size: 40,
                                              color: Colors.grey[400],
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Sắp ra mắt',
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 12,
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
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // "Coming soon" badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.amber,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Sắp ra mắt',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                book['title'] ?? 'Unknown',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '${releaseDate.day}/${releaseDate.month}/${releaseDate.year}',
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
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
      ),
    ],
  );
}

void _showUpcomingBookDetails(
    BuildContext context, Map<String, dynamic> book, DateTime releaseDate) {
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
        children: [
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
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
                        child: (book['coverUrl'] ?? '')
                                .toString()
                                .startsWith('assets/')
                            ? Image.asset(
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
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
                              )
                            : Image.network(
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
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

                  // Title and badge
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          book['title'] ?? 'Sách không tên',
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: TColor.primaryText,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Sắp ra mắt',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
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

                  // Genre
                  if (book['genre'] != null)
                    Row(
                      children: [
                        Icon(
                          Icons.category,
                          size: 18,
                          color: TColor.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Thể loại: ${book['genre']}',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: TColor.primaryText,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 16),

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
                    book['description'] ?? 'Chưa có mô tả cho sách này',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: TColor.secondaryText,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Coming soon message
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber, width: 1),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.amber,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Sách này sẽ được phát hành vào ngày ${releaseDate.day}/${releaseDate.month}/${releaseDate.year}. Hãy quay lại sau nhé!',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.amber.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
