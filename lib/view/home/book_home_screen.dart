import 'package:books_store/common/color_extension.dart';
import 'package:books_store/view/cart/cart_screen.dart';
import 'package:books_store/view/home/book_details_screen.dart';
import 'package:books_store/view/search/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../models/book.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/seed_books_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class BooksHome extends StatefulWidget {
  const BooksHome({super.key});

  @override
  State<BooksHome> createState() => _BooksHomeState();
}

class _BooksHomeState extends State<BooksHome> {
  int _selectedCategoryIndex = 0;
  final List<String> categories = [
    "Tất cả",
    "Truyện",
    "Khoa học",
    "Lịch sử",
    "Tiểu sử",
    "Tự trợ"
  ];

  // List to store books from Firestore
  List<Book> booklist = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBooksFromFirestore();
  }

  // Function to fetch books from Firestore
  Future<void> fetchBooksFromFirestore() async {
    try {
      setState(() {
        isLoading = true;
      });

      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      QuerySnapshot snapshot = await firestore.collection("menu_items").get();

      List<Book> books = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        return Book(
          id: data['id'] ?? '',
          title: data['name'] ?? 'Unknown',
          price: double.tryParse(data['rate']?.toString() ?? '0') ?? 0.0,
          cover: data['image'] ?? 'assets/img/default.png',
          showImage: data['image'] ?? 'assets/img/default.png',
          author: data['author'] ?? 'Unknown',
          age: data['age'] ?? '18+',
          authorImg:
              data['author_img'] ?? 'assets/images/authors/default_author.jpg',
          seller: data['seller'] ?? false,
          genre: data['type'] ?? 'Unknown',
          lanugage: data['language'] ?? 'VIETNAMESE',
          summary: data['description'] ?? '',
          rating: double.tryParse(data['rating']?.toString() ?? '0') ?? 0.0,
          category: data['category'] ?? data['type'] ?? 'Unknown',
        );
      }).toList();

      setState(() {
        booklist = books;
        isLoading = false;
      });

      print("Fetched books from Firestore: ${books.length}");
    } catch (e) {
      print("Error fetching books from Firestore: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // App Bar
            SliverAppBar(
              backgroundColor: Colors.grey[50],
              elevation: 0,
              floating: true,
              pinned: false,
              title: Text(
                "Cửa hàng sách",
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(221, 202, 159, 159),
                ),
              ),
              centerTitle: false,
              actions: [
                Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.shopping_cart_outlined,
                            color: Colors.black87),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => CartScreen()));
                        },
                      ),
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            "1",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Main Content
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Welcome Text
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Chào mừng bạn quay lại 👋",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          "Khám phá kho tàng tri thức ",
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Search Bar
                  _buildSearchBar(),
                  const SizedBox(height: 24),

                  // Featured Section
                  _buildFeaturedSection(),
                  const SizedBox(height: 24),

                  // Best Sellers Title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _sectionTitle("Sách bán chạy"),
                      _refreshButton(),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Best Sellers
                  _buildBestSellers(),
                  const SizedBox(height: 24),

                  // New Arrivals Title
                  _buildCategorySelector(),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _sectionTitle("Sách mới"),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // New Arrivals
                  _buildBookList(),
                  const SizedBox(height: 24),

                  // Fiction Books Title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _sectionTitle("Truyện"),
                      _viewAllButton(),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Fiction Books
                  _buildFictionBooks(),
                  const SizedBox(height: 24),

                  // Upcoming Books Title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _sectionTitle("Sách sắp ra mắt"),
                      _viewAllButton(),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Upcoming Books
                  _buildUpcomingBooksSection(),
                  const SizedBox(height: 24),

                  // Promotions Title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _sectionTitle("Khuyến mãi đặc biệt"),
                      _viewAllButton(),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Promotions
                  _buildPromotions(),
                  const SizedBox(height: 24),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SearchScreen()),
        );
      },
      child: Container(
        height: 55,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: TextField(
          enabled: false,
          decoration: InputDecoration(
            hintText: "Tìm kiếm.",
            hintStyle: GoogleFonts.poppins(
              color: Colors.grey[400],
              fontSize: 14,
            ),
            prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
            suffixIcon: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue[700],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.tune, color: Colors.white, size: 20),
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        itemCount: categories.length,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final isSelected = _selectedCategoryIndex == index;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategoryIndex = index;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue[700] : Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.3),
                          blurRadius: 8,
                          spreadRadius: 1,
                        )
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 4,
                          spreadRadius: 0.5,
                        )
                      ],
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : Colors.grey.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  categories[index],
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? Colors.white : Colors.grey[800],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeaturedSection() {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo.shade500, Colors.indigo.shade800],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            bottom: -15,
            child: Opacity(
              opacity: 0.2,
              child: Icon(
                Icons.book,
                size: 150,
                color: Colors.white,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "Khuyến mãi đặc biệt",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "20% ",
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        "Trên tất cả sách viễn tưởng",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      const SizedBox(height: 0),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, 'upload_books');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.indigo[700],
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                        ),
                        child: Text(
                          "Khám phá",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child:
                      Container(), // Space for the book icon in the background
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _viewAllButton() {
    return TextButton(
      onPressed: () {},
      style: TextButton.styleFrom(
        foregroundColor: Colors.blue[700],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: Row(
        children: [
          Text(
            "Xem tất cả",
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 4),
          Icon(Icons.arrow_forward, size: 16),
        ],
      ),
    );
  }

  Widget _refreshButton() {
    return TextButton.icon(
      onPressed: () {
        fetchBooksFromFirestore();
      },
      icon: Icon(Icons.refresh, color: Colors.blue[700], size: 18),
      label: Text(
        "Tải lại",
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.blue[700],
        ),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  Widget _buildBestSellers() {
    if (isLoading) {
      return _buildLoadingIndicator(200);
    }

    List<Book> bestSellerBooks = booklist.where((book) => book.seller).toList();

    if (bestSellerBooks.isEmpty) {
      return _buildEmptyState("Không có sách bán chạy", 200);
    }

    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        itemCount: bestSellerBooks.length,
        itemBuilder: (context, index) {
          final book = bestSellerBooks[index];
          return _bestSellerCard(book, context);
        },
      ),
    );
  }

  Widget _buildLoadingIndicator(double height) {
    return SizedBox(
      height: height,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                color: Colors.blue[700],
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Đang tải sách...",
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message, double height) {
    return SizedBox(
      height: height,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.book_outlined,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bestSellerCard(Book book, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BookDetailScreen(book: book),
          ),
        );
      },
      child: Container(
        width: 320,
        margin: const EdgeInsets.only(right: 18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade600, Colors.blue.shade900],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.25),
              blurRadius: 12,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 120,
              height: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 6,
                    spreadRadius: 1,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                ),
                child: book.showImage.startsWith('assets/')
                    ? Image.asset(
                        book.showImage,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[200],
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.book,
                                  size: 30,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "No Image",
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : CachedNetworkImage(
                        imageUrl: book.showImage,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) =>
                            CachedNetworkImage(
                          imageUrl:
                              'https://images.unsplash.com/photo-1544947950-fa07a98d237f?ixlib=rb-4.0.3',
                          width: MediaQuery.of(context).size.width / 3,
                          height: MediaQuery.of(context).size.width / 3,
                          fit: BoxFit.cover,
                        ),
                      ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "Bán chạy nhất",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 16,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              "4.8",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.3,
                                height: 1.4,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      book.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      book.author,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.8),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            "${NumberFormat.currency(locale: 'vi_VN', symbol: '', decimalDigits: 0).format(book.price * 1)}Đ",
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.blue[700],
                            size: 18,
                          ),
                        ),
                      ],
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

  Widget _buildBookList() {
    if (isLoading) {
      return _buildLoadingIndicator(280);
    }

    final filteredBooks = _selectedCategoryIndex == 0
        ? booklist
        : booklist
            .where(
                (book) => book.category == categories[_selectedCategoryIndex])
            .toList();

    if (filteredBooks.isEmpty) {
      return _buildEmptyState("Không có sách trong danh mục này", 280);
    }

    return SizedBox(
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        itemCount: filteredBooks.length,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final book = filteredBooks[index];
          return _bookCard(book, context);
        },
      ),
    );
  }

  Widget _bookCard(Book book, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookDetailScreen(book: book),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        width: 160,
        height: 280,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  child: SizedBox(
                    height: 140,
                    width: double.infinity,
                    child: _getBookCoverImage(book),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 14),
                        const SizedBox(width: 2),
                        Text(
                          "${book.rating}",
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.3,
                            height: 1.4,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      book.author,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            "${NumberFormat.currency(locale: 'vi_VN', symbol: '', decimalDigits: 0).format(book.price)} đ",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF3A86FF),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Color(0xFF3A86FF).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.add_shopping_cart_outlined,
                            color: Color(0xFF3A86FF),
                            size: 18,
                          ),
                        ),
                      ],
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

  Widget _buildFictionBooks() {
    if (isLoading) {
      return _buildLoadingIndicator(280);
    }

    final fictionBooks =
        booklist.where((book) => book.category == 'Truyện').toList();

    if (fictionBooks.isEmpty) {
      return _buildEmptyState("Không có sách thuộc thể loại truyện", 280);
    }

    return SizedBox(
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        itemCount: fictionBooks.length,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final book = fictionBooks[index];
          return _bookCard(book, context);
        },
      ),
    );
  }

  Widget _buildPromotions() {
    if (isLoading) {
      return _buildLoadingIndicator(310);
    }

    final promotionBooks =
        booklist.where((book) => book.category == 'Khuyến mãi').toList();

    if (promotionBooks.isEmpty) {
      return _buildEmptyState("Không có sách khuyến mãi", 310);
    }

    return SizedBox(
      height: 310,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        itemCount: promotionBooks.length,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final book = promotionBooks[index];
          return _specialOfferCard(book, context);
        },
      ),
    );
  }

  Widget _specialOfferCard(Book book, BuildContext context) {
    // Giả định rằng thông tin về giá gốc và giảm giá
    // sẽ được lưu trong các trường của đối tượng Book
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BookDetailScreen(book: book),
          ),
        );
      },
      child: Container(
        width: 180,
        height: 300,
        margin: const EdgeInsets.only(right: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 170,
                  margin: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                        spreadRadius: 1,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: _getBookCoverImage(book),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.3),
                          blurRadius: 6,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Text(
                      "KHUYẾN MÃI",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title.length > 20
                          ? "${book.title.substring(0, 18)}..."
                          : book.title,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      book.author,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${NumberFormat.currency(locale: 'vi_VN', symbol: '', decimalDigits: 0).format(book.price)}đ",
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[700],
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                "${NumberFormat.currency(locale: 'vi_VN', symbol: '', decimalDigits: 0).format(book.price * 1.25)}đ",
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  decoration: TextDecoration.lineThrough,
                                  color: Colors.grey[500],
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue[700],
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.3),
                                blurRadius: 6,
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.add_shopping_cart,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ],
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

  Widget _buildUpcomingBooksSection() {
    return SizedBox(
      height: 240,
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
            // Use local data instead of showing empty message
            return _buildLocalUpcomingBooks();
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
                  height: 220,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
                        child: Image.network(
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
                                  mainAxisAlignment: MainAxisAlignment.center,
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
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // "Coming soon" badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.amber,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
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
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '${releaseDate.day}/${releaseDate.month}/${releaseDate.year}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
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
            },
          );
        },
      ),
    );
  }

  // Local upcoming books data when Firestore returns empty
  Widget _buildLocalUpcomingBooks() {
    // Sample upcoming books data
    final List<Map<String, dynamic>> localUpcomingBooks = [
      {
        'title': 'The Last Chapter',
        'author': 'Jane Doe',
        'releaseDate': DateTime.now().add(const Duration(days: 30)),
        'coverUrl': 'assets/images/upcoming/book1.jpg',
        'description': 'A thrilling conclusion to the bestselling series.',
        'price': '299.000',
        'genres': ['Mystery', 'Thriller'],
      },
      {
        'title': 'Beyond the Stars',
        'author': 'John Smith',
        'releaseDate': DateTime.now().add(const Duration(days: 45)),
        'coverUrl': 'assets/images/upcoming/book2.jpg',
        'description':
            'An epic space adventure that will take your breath away.',
        'price': '329.000',
        'genres': ['Sci-Fi', 'Adventure'],
      },
      {
        'title': 'Heart of the Forest',
        'author': 'Maria Chen',
        'releaseDate': DateTime.now().add(const Duration(days: 15)),
        'coverUrl': 'assets/images/upcoming/book3.jpg',
        'description': 'Discover the magic hidden within the ancient trees.',
        'price': '279.000',
        'genres': ['Fantasy', 'Young Adult'],
      },
      {
        'title': 'Memories of Tomorrow',
        'author': 'David Lee',
        'releaseDate': DateTime.now().add(const Duration(days: 60)),
        'coverUrl': 'assets/images/upcoming/book4.jpg',
        'description':
            'A poignant tale of love, loss, and the power of remembrance.',
        'price': '319.000',
        'genres': ['Romance', 'Drama'],
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      scrollDirection: Axis.horizontal,
      itemCount: localUpcomingBooks.length,
      itemBuilder: (context, index) {
        final book = localUpcomingBooks[index];
        final releaseDate = book['releaseDate'] as DateTime;

        return GestureDetector(
          onTap: () {
            _showUpcomingBookDetails(context, book, releaseDate);
          },
          child: Container(
            width: 140,
            height: 220,
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
                  child: Image.network(
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
                            mainAxisAlignment: MainAxisAlignment.center,
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
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // "Coming soon" badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
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
                          book['title'],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${releaseDate.day}/${releaseDate.month}/${releaseDate.year}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
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
      },
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
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Book cover and basic info
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            book['coverUrl'] ??
                                'assets/images/upcoming/default_upcoming.jpg',
                            width: 120,
                            height: 160,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 120,
                                height: 160,
                                color: Colors.grey[200],
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.book,
                                        size: 30,
                                        color: Colors.grey[400],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Sách mới',
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
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                book['title'] ?? 'Unknown',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                book['author'] ?? 'Unknown author',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.amber,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Phát hành: ${releaseDate.day}/${releaseDate.month}/${releaseDate.year}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (book['price'] != null)
                                Text(
                                  '${book['price']} VND',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Description
                    const Text(
                      'Mô tả',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      book['description'] ?? 'Không có mô tả.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Genres/Categories
                    if (book['genres'] != null) ...[
                      const Text(
                        'Thể loại',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            (book['genres'] as List<dynamic>).map((genre) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              genre,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                    const SizedBox(height: 32),

                    // Notify me button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Bạn sẽ nhận được thông báo khi sách ra mắt!'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: TColor.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Thông báo khi ra mắt',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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

  // Hàm hiển thị ảnh bìa sách (hỗ trợ cả asset và cached image)
  Widget _getBookCoverImage(Book book) {
    // Kiểm tra xem đường dẫn có phải là asset không
    bool isAsset = book.cover.startsWith('assets/');

    if (isAsset) {
      // Sử dụng AssetImage cho ảnh local
      return Image.asset(
        book.cover,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[200],
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.book, size: 40, color: Colors.grey[400]),
                  const SizedBox(height: 4),
                  Text(
                    "No Image",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } else {
      // Sử dụng CachedNetworkImage cho ảnh từ internet
      return CachedNetworkImage(
        imageUrl: book.cover,
        fit: BoxFit.cover,
        placeholder: (context, url) => Center(
          child: CircularProgressIndicator(),
        ),
        errorWidget: (context, url, error) => Container(
          color: Colors.grey[200],
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.book, size: 40, color: Colors.grey[400]),
                const SizedBox(height: 4),
                Text(
                  "No Image",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}
