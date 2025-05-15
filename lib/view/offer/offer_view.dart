import 'package:books_store/common/color_extension.dart';
import 'package:books_store/common_widget/round_button.dart';
import 'package:books_store/common_widget/popular_resutaurant_row.dart';
import 'package:books_store/view/cart/cart_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:intl/intl.dart';

import '../more/my_order_view.dart';
import '../menu/item_details_view.dart';

class OfferView extends StatefulWidget {
  const OfferView({super.key});

  @override
  State<OfferView> createState() => _OfferViewState();
}

class _OfferViewState extends State<OfferView>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> offerArr = [];
  bool isLoading = true;

  // Modern UI colors
  static const Color primaryColor = Color(0xFF3A86FF);
  static const Color backgroundColor = Color(0xFFF0F2F5);
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color textPrimaryColor = Color(0xFF212529);
  static const Color textSecondaryColor = Color(0xFF6C757D);
  static const Color accentColor = Color(0xFFFF006E);

  // For animations
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    fetchMenuItems();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> fetchMenuItems() async {
    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      QuerySnapshot snapshot = await firestore.collection("menu_items").get();

      List<Map<String, dynamic>> offers = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        return {
          'image': data['image'] ?? 'assets/img/default.png',
          'name': data['name'] ?? 'Unknown',
          'rate': data['rate']?.toString() ?? '0.0',
          'rating': data['rating']?.toString() ?? '0',
          'type': data['type'] ?? 'Unknown',
          'food_type': data['food_type'] ?? 'Other',
          'description': data['description'] ?? '',
          'price': data['price']?.toString() ?? '0.0',
          'author': data['author'] ?? '',
          'category': data['category'] ?? '',
          'id': data['id'] ?? '',
        };
      }).toList();

      setState(() {
        offerArr = offers;
        isLoading = false;
      });

      print("Fetched menu items for offers: ${offers.length}");
    } catch (e) {
      print("Error fetching menu items: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: _buildBooksList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Sách hot",
                style: TextStyle(
                  color: textPrimaryColor,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const CartScreen()),
                    );
                  },
                  icon: Icon(
                    Icons.shopping_cart_outlined,
                    color: primaryColor,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Những bộ sách được tìm kiếm nhiều nhất , sách hot, sách bán chạy và nhiều hơn nữa!",
            style: TextStyle(
              color: textSecondaryColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 15),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                isLoading = true;
              });
              fetchMenuItems();
              _animationController.reset();
              _animationController.forward();
            },
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text("Tải", style: TextStyle(fontSize: 14)),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBooksList() {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                color: primaryColor,
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Đang tải sách...",
              style: TextStyle(
                color: textSecondaryColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    if (offerArr.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.book_outlined,
              size: 70,
              color: Colors.grey.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              "Không có sách nào",
              style: TextStyle(
                color: textSecondaryColor,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: offerArr.length,
      itemBuilder: (context, index) {
        var mObj = offerArr[index];

        // Create staggered animation
        final delay = 0.2 + (index * 0.1);

        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            final value = _animationController.value > delay
                ? (_animationController.value - delay) / (1 - delay)
                : 0.0;

            return Transform.translate(
              offset: Offset(0, 30 * (1 - value)),
              child: Opacity(
                opacity: value,
                child: child,
              ),
            );
          },
          child: _buildBookCard(mObj),
        );
      },
    );
  }

  Widget _buildBookCard(Map<String, dynamic> book) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ItemDetailsView(
              item: book,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: cardColor,
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
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              child: _buildBookImage(book['image']),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book['name'],
                      style: TextStyle(
                        color: textPrimaryColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      book['type'],
                      style: TextStyle(
                        color: textSecondaryColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.star_rounded,
                              color: Colors.amber,
                              size: 18,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              book['rating'].toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 4),
                          ],
                        ),
                        Text(
                          _formatPrice(book['rate']),
                          style: TextStyle(
                            color: textSecondaryColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
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

  String _formatPrice(dynamic priceValue) {
    try {
      double price;
      if (priceValue is double) {
        price = priceValue;
      } else {
        price = double.parse(priceValue.toString());
      }
      NumberFormat formatter = NumberFormat('#,###', 'vi_VN');
      return '${formatter.format(price).replaceAll(',', '.')} VND';
    } catch (e) {
      return '$priceValue VND';
    }
  }

  Widget _buildBookImage(String imagePath) {
    if (imagePath.startsWith('assets/')) {
      return Image.asset(
        imagePath,
        width: 100,
        height: 120,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 100,
            height: 120,
            color: Colors.grey.shade200,
            child: const Icon(
              Icons.image_not_supported_outlined,
              color: Colors.grey,
              size: 40,
            ),
          );
        },
      );
    } else {
      return Image.network(
        imagePath,
        width: 100,
        height: 120,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 100,
            height: 120,
            color: Colors.grey.shade200,
            child: const Icon(
              Icons.image_not_supported_outlined,
              color: Colors.grey,
              size: 40,
            ),
          );
        },
      );
    }
  }
}
