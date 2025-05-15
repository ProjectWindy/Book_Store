import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/book.dart';
import '../home/book_details_screen.dart';
import '../../data/seed_books_data.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Book> _searchResults = [];
  bool _isSearching = false;
  String _selectedCategory = 'All';
  final List<String> _categories = [
    'All',
    'Fiction',
    'Science',
    'History',
    'Biography',
    'Self-Help'
  ];

  // Get books from seed data
  late List<Book> booklist = seedBooks.map((book) => mapToBook(book)).toList();

  void _performSearch(String query) {
    setState(() {
      _isSearching = true;
      if (query.isEmpty) {
        _searchResults = [];
      } else {
        _searchResults = booklist.where((book) {
          final matchesSearch =
              book.title.toLowerCase().contains(query.toLowerCase()) ||
                  book.author.toLowerCase().contains(query.toLowerCase());
          final matchesCategory =
              _selectedCategory == 'All' || book.category == _selectedCategory;
          return matchesSearch && matchesCategory;
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        elevation: 0,
        title: Container(
          height: 45,
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
          child: TextField(
            controller: _searchController,
            onChanged: _performSearch,
            decoration: InputDecoration(
              hintText: "Search for books...",
              hintStyle: GoogleFonts.poppins(
                color: Colors.grey[400],
                fontSize: 14,
              ),
              prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Category Filter
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategory = category;
                      _performSearch(_searchController.text);
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
                        category,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected ? Colors.white : Colors.grey[800],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Search Results
          Expanded(
            child: _isSearching
                ? ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final book = _searchResults[index];
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
                          margin: const EdgeInsets.only(bottom: 16),
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
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(8),
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: book.cover.startsWith('assets/')
                                  ? Image.asset(
                                      book.cover,
                                      width: 60,
                                      height: 80,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Container(
                                        width: 60,
                                        height: 80,
                                        color: Colors.grey[200],
                                        child: Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.book,
                                                size: 24,
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
                                      imageUrl: book.cover,
                                      width: 60,
                                      height: 80,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Container(
                                        color: Colors.grey[200],
                                        child: const Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Container(
                                        width: 60,
                                        height: 80,
                                        color: Colors.grey[200],
                                        child: Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.book,
                                                size: 24,
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
                                    ),
                            ),
                            title: Text(
                              book.title,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 12,
                                      backgroundColor: Colors.grey[200],
                                      child: book.authorImg
                                              .startsWith('assets/')
                                          ? Image.asset(
                                              book.authorImg,
                                              width: 24,
                                              height: 24,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error,
                                                      stackTrace) =>
                                                  Icon(
                                                Icons.person,
                                                size: 12,
                                                color: Colors.grey[400],
                                              ),
                                            )
                                          : CachedNetworkImage(
                                              imageUrl: book.authorImg,
                                              width: 24,
                                              height: 24,
                                              fit: BoxFit.cover,
                                              placeholder: (context, url) =>
                                                  Container(
                                                color: Colors.grey[200],
                                              ),
                                              errorWidget:
                                                  (context, url, error) => Icon(
                                                Icons.person,
                                                size: 12,
                                                color: Colors.grey[400],
                                              ),
                                            ),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        book.author,
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.star,
                                      size: 16,
                                      color: Colors.amber[700],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      book.rating.toString(),
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.blue[50],
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        book.category,
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: Colors.blue[700],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            trailing: Text(
                              "${NumberFormat.currency(locale: 'vi_VN', symbol: '', decimalDigits: 0).format(book.price * 1)}đ",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[700],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Search for books",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
