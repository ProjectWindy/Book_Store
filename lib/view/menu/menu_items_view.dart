import 'package:books_store/common/color_extension.dart';
import 'package:books_store/common_widget/menu_item_row.dart';
import 'package:books_store/common_widget/round_textfield.dart';
import 'package:books_store/providers/cart_provider.dart';
import 'package:books_store/services/product_service.dart';
import 'package:books_store/view/cart/cart_screen.dart';
import 'package:books_store/view/menu/item_details_view.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MenuItem {
  String image;
  String name;
  String rate;
  String rating;
  String type;
  String foodType;

  MenuItem({
    required this.image,
    required this.name,
    required this.rate,
    required this.rating,
    required this.type,
    required this.foodType,
  });

  Map<String, dynamic> toJson() {
    return {
      'image': image,
      'name': name,
      'rate': rate,
      'rating': rating,
      'type': type,
      'food_type': foodType,
    };
  }
}

Future<void> uploadMenuItems() async {
  final DatabaseReference database = FirebaseDatabase.instance.ref();
  final DataSnapshot snapshot = await database.child('menu_items').get();

  if (snapshot.exists) {
    print("Dữ liệu đã tồn tại, không tải lên nữa.");
    return;
  }

  print("Dữ liệu đã được tải lên Firebase thành công.");
}

class MenuItemsView extends StatefulWidget {
  final Map mObj;
  const MenuItemsView({super.key, required this.mObj});

  @override
  State<MenuItemsView> createState() => _MenuItemsViewState();
}

class _MenuItemsViewState extends State<MenuItemsView> {
  TextEditingController txtSearch = TextEditingController();
  String selectedType = 'Tất cả';
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Set initial category based on the menu item selected
    selectedType = widget.mObj["name"] ?? 'Tất cả';

    txtSearch.addListener(() {
      setState(() {
        searchQuery = txtSearch.text;
      });
    });
  }

  Stream<QuerySnapshot> getMenuItemsStream() {
    // Sử dụng cùng collection "menu_items" như trong ProductService
    return FirebaseFirestore.instance.collection("menu_items").snapshots();
  }

  void filterByType(String type) {
    setState(() {
      selectedType = type;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              const SizedBox(height: 46),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Image.asset("assets/img/btn_back.png",
                          width: 20, height: 20),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.mObj["name"].toString(),
                        style: TextStyle(
                            color: TColor.primaryText,
                            fontSize: 20,
                            fontWeight: FontWeight.w800),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CartScreen(),
                          ),
                        );
                      },
                      icon: Image.asset(
                        "assets/img/shopping_cart.png",
                        width: 25,
                        height: 25,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: RoundTextfield(
                  hintText: "Tìm kiếm sách...",
                  controller: txtSearch,
                  left: Container(
                    alignment: Alignment.center,
                    width: 30,
                    child: Image.asset(
                      "assets/img/search.png",
                      width: 20,
                      height: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    _buildFilterChip('Tất cả'),
                    _buildFilterChip('Tiểu thuyết', filterValue: 'Fiction'),
                    _buildFilterChip('Đời sống', filterValue: 'Non-Fiction'),
                    _buildFilterChip('Bán chạy nhất',
                        filterValue: 'Bestseller'),
                    _buildFilterChip('Khuyến mãi', filterValue: 'Promotions'),
                    _buildFilterChip('Khoa học'),
                    _buildFilterChip('Lịch sử'),
                    _buildFilterChip('Tiểu sử'),
                    _buildFilterChip('Tự trợ'),
                    _buildFilterChip('Truyện'),
                  ],
                ),
              ),
              const SizedBox(height: 15),

              // Sử dụng StreamBuilder để lấy dữ liệu từ Firestore
              StreamBuilder<QuerySnapshot>(
                stream: getMenuItemsStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          'Lỗi khi tải dữ liệu: ${snapshot.error}',
                          style: TextStyle(color: TColor.secondaryText),
                        ),
                      ),
                    );
                  }

                  // Lọc dữ liệu theo tìm kiếm và loại
                  final menuItems = snapshot.data?.docs
                          .map((doc) => {
                                ...doc.data() as Map<String, dynamic>,
                                'id': doc.id,
                                // Đảm bảo các trường không bị null
                                'name': (doc.data()
                                        as Map<String, dynamic>)['name'] ??
                                    'Sách không tên',
                                'rate': (doc.data()
                                        as Map<String, dynamic>)['rate'] ??
                                    '0.0',
                                'type': (doc.data()
                                        as Map<String, dynamic>)['type'] ??
                                    'Sách',
                                'food_type': (doc.data()
                                        as Map<String, dynamic>)['food_type'] ??
                                    'Khác',
                                'image': (doc.data()
                                        as Map<String, dynamic>)['image'] ??
                                    '',
                              })
                          .where((item) {
                        // Lọc theo tìm kiếm
                        bool matchesSearch = searchQuery.isEmpty ||
                            (item['name']?.toString() ?? '')
                                .toLowerCase()
                                .contains(searchQuery.toLowerCase());

                        // Lọc theo loại
                        bool matchesType = selectedType == 'Tất cả' ||
                            item['type'] == selectedType ||
                            item['food_type'] == selectedType;

                        return matchesSearch && matchesType;
                      }).toList() ??
                      [];

                  if (menuItems.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Center(
                        child: Text(
                          'Nhập tên sách bạn muốn tìm kiếm',
                          style: TextStyle(color: TColor.secondaryText),
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: menuItems.length,
                    itemBuilder: (context, index) {
                      var mObj = menuItems[index];
                      return MenuItemRow(
                        mObj: mObj,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ItemDetailsView(
                                      item: mObj,
                                    )),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String type, {String? filterValue}) {
    bool isSelected = selectedType == (filterValue ?? type);
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(
          type,
          style: TextStyle(
            color: isSelected ? Colors.white : TColor.primary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        selected: isSelected,
        onSelected: (bool selected) {
          filterByType(filterValue ?? type);
        },
        backgroundColor: Colors.white,
        selectedColor: TColor.primary,
        checkmarkColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color:
                isSelected ? TColor.primary : TColor.primary.withOpacity(0.5),
          ),
        ),
      ),
    );
  }
}
