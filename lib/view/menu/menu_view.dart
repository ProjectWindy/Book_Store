import 'package:books_store/view/cart/cart_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'menu_items_view.dart';

class MenuView extends StatefulWidget {
  const MenuView({super.key});

  @override
  State<MenuView> createState() => _MenuViewState();
}

class _MenuViewState extends State<MenuView>
    with SingleTickerProviderStateMixin {
  List menuArr = [];
  bool isLoading = true;
  TextEditingController txtSearch = TextEditingController();

  // Define modern colors
  static const Color primaryColor = Color(0xFF3A86FF);
  static const Color backgroundColor = Color(0xFFF0F2F5);
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color textPrimaryColor = Color(0xFF212529);
  static const Color textSecondaryColor = Color(0xFF6C757D);

  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();

    // Fetch categories from Firestore
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      // Nếu collection không tồn tại, sử dụng dữ liệu mặc định
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('book_categories').get();

      if (snapshot.docs.isEmpty) {
        // Nếu không có dữ liệu, sử dụng dữ liệu mặc định
        menuArr = [
          {
            "name": "Truyện",
            "image": "assets/img/Fictions.jpg",
          },
          {
            "name": "Tài liệu",
            "image": "assets/img/non.png",
          },
          {
            "name": "Sách hot",
            "image": "assets/img/Pro.jpg",
          },
          {
            "name": "Sách bán chạy",
            "image": "assets/img/best.jpg",
          },
        ];
      } else {
        // Nếu có dữ liệu, sử dụng dữ liệu từ Firestore
        menuArr = snapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          return {
            "name": data["name"] ?? "Unknown",
            "image": data["image"] ?? "assets/img/default.jpg",
          };
        }).toList();
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching categories: $e");
      // Sử dụng dữ liệu mặc định khi có lỗi
      menuArr = [
        {
          "name": "Truyện",
          "image": "assets/img/Fictions.jpg",
        },
        {
          "name": "Tài liệu",
          "image": "assets/img/non.png",
        },
        {
          "name": "Sách hot",
          "image": "assets/img/Pro.jpg",
        },
        {
          "name": "Sách bán chạy",
          "image": "assets/img/best.jpg",
        },
      ];

      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        alignment: Alignment.centerLeft,
        children: [
          // Background accent
          Positioned(
            left: 0,
            child: Container(
              margin: const EdgeInsets.only(top: 130),
              width: media.width * 0.2,
              height: media.height * 0.65,
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.8),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(35),
                  bottomRight: Radius.circular(35),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: FadeTransition(
                    opacity: _animation,
                    child: _buildCategoryList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Danh mục sách",
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
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(15),
            ),
            child: TextField(
              controller: txtSearch,
              decoration: InputDecoration(
                hintText: "Tìm kiếm sách...",
                hintStyle: TextStyle(
                  color: textSecondaryColor,
                  fontSize: 14,
                ),
                prefixIcon: Icon(Icons.search, color: primaryColor),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryList() {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: primaryColor,
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 25, left: 20, right: 20, bottom: 100),
      itemCount: menuArr.length,
      itemBuilder: ((context, index) {
        var mObj = menuArr[index] as Map? ?? {};
        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            final delay = 0.2 + (index * 0.1);
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
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MenuItemsView(
                    mObj: mObj,
                  ),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 15),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                    ),
                    child: mObj["image"].toString().startsWith("assets/")
                        ? Image.asset(
                            mObj["image"].toString(),
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              width: 100,
                              height: 100,
                              color: Colors.grey[100],
                              child: const Center(
                                child: Icon(
                                  Icons.menu_book,
                                  color: Colors.grey,
                                  size: 40,
                                ),
                              ),
                            ),
                          )
                        : Image.network(
                            mObj["image"].toString(),
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              width: 100,
                              height: 100,
                              color: Colors.grey[100],
                              child: const Center(
                                child: Icon(
                                  Icons.menu_book,
                                  color: Colors.grey,
                                  size: 40,
                                ),
                              ),
                            ),
                          ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            mObj["name"].toString(),
                            style: TextStyle(
                              color: textPrimaryColor,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 18,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
