import 'package:books_store/view/admin/admin_dashboard.dart';
import 'package:books_store/view/admin/product_manager%20copy.dart';
import 'package:books_store/view/more/about_us_view.dart';
import 'package:books_store/view/more/inbox_view.dart';
import 'package:books_store/view/more/notification_view.dart';
import 'package:books_store/view/more/payment_details_view.dart';
import 'package:books_store/view/more/qr_code_view.dart';
import 'package:books_store/view/more/upcoming_books_view.dart';
import 'package:books_store/view/more/voucher_management_view.dart';
import 'package:books_store/view/orders/order_history_screen.dart';
import 'package:books_store/view/seller/seller_orders_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../common/service_call.dart';
import '../../services/auth_service.dart';

class MoreView extends StatefulWidget {
  const MoreView({super.key});

  @override
  State<MoreView> createState() => _MoreViewState();
}

class _MoreViewState extends State<MoreView>
    with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();
  List<Map<String, dynamic>> moreArr = [];
  String userRole = '';
  String userName = 'User';
  String userEmail = '';
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
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _loadUserData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() => isLoading = true);

    try {
      String role = await _authService.getUserRole();
      // Get user data from Firestore
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          Map<String, dynamic>? userData =
              userDoc.data() as Map<String, dynamic>?;
          setState(() {
            userRole = role;
            userName = userData?['name'] ?? 'User';
            userEmail = userData?['email'] ?? '';
            moreArr = _buildMoreArr();
            isLoading = false;
          });
          _animationController.forward();
        }
      }

      // Chuyển hướng đến AdminDashboard nếu người dùng là admin
      if (role == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminDashboard()),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading user data: $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  List<Map<String, dynamic>> _buildMoreArr() {
    return [
      // {
      //   "index": "1",
      //   "name": "Thanh toán",
      //   "icon": Icons.payment_rounded,
      //   "description": "Quản lý phương thức thanh toán",
      //   "color": const Color(0xFF4361EE),
      // },
      {
        "index": "2",
        "name": "Đơn hàng của tôi",
        "icon": Icons.shopping_bag_rounded,
        "description": "Theo dõi đơn hàng hiện tại và trước đó",
        "color": const Color(0xFF2EC4B6),
      },
      {
        "index": "3",
        "name": "Thông báo",
        "icon": Icons.notifications_rounded,
        "description": "Kiểm tra thông báo của bạn",
        "color": const Color(0xFFFF9F1C),
      },
      {
        "index": "5",
        "name": "Sách sắp ra mắt",
        "icon": Icons.auto_stories_rounded,
        "description": "Xem trước sách sắp phát hành",
        "color": const Color(0xFFF72585),
      },
      // {
      //   "index": "6",
      //   "name": "Tạo mã QR",
      //   "icon": Icons.qr_code_rounded,
      //   "description": "Tạo mã QR để chia sẻ",
      //   "color": const Color(0xFF06D6A0),
      // },
      {
        "index": "7",
        "name": "Về chúng tôi",
        "icon": Icons.info_rounded,
        "description": "Tìm hiểu thêm về công ty chúng tôi",
        "color": const Color(0xFF118AB2),
      },

      {
        "index": "12",
        "name": "Đăng xuất",
        "icon": Icons.logout_rounded,
        "description": "Đăng xuất khỏi tài khoản",
        "color": Colors.red,
      },
      if (userRole == 'seller') ...[
        {
          "index": "8",
          "name": "Mã giảm giá",
          "icon": Icons.discount_rounded,
          "description": "Quản lý mã giảm giá",
          "color": const Color(0xFFEF476F),
        },
        {
          "index": "10",
          "name": "Quản lý sản phẩm",
          "icon": Icons.inventory_2_rounded,
          "description": "Thêm, sửa hoặc xóa sản phẩm",
          "color": const Color(0xFFFFBE0B),
        },
        {
          "index": "11",
          "name": "Đơn hàng",
          "icon": Icons.receipt_long_rounded,
          "description": "Quản lý đơn hàng của khách hàng",
          "color": const Color(0xFF3A0CA3),
        },
      ],
    ];
  }

  void handleNavigation(String index) {
    switch (index) {
      case "1":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PaymentDetailsView()),
        );
        break;
      case "2":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const OrderHistoryScreen()),
        );
        break;
      case "3":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const NotificationView()),
        );
        break;
      case "4":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const InboxView()),
        );
        break;
      case "5":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const UpcomingBooksView()),
        );
        break;
      case "6":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const QRCodeView()),
        );
        break;
      case "7":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AboutUsView()),
        );
        break;
      case "8":
        if (userRole == 'seller') {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const VoucherManagementView()),
          );
        }
        break;
      case "12":
        _showLogoutConfirmation();
        break;
      case "10":
        if (userRole == 'seller') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => BookListScreen()),
          );
        }
        break;
      case "11":
        if (userRole == 'seller') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SellerOrdersScreen()),
          );
        }
        break;
    }
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Đăng xuất',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: textPrimaryColor,
          ),
        ),
        content: Text(
          'Bạn có chắc chắn muốn đăng xuất?',
          style: TextStyle(color: textSecondaryColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Hủy',
              style: TextStyle(color: textSecondaryColor),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              Navigator.pop(context);
              ServiceCall.logout();
            },
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(color: primaryColor),
            )
          : SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  Expanded(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildMenuItems(),
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
        color: cardColor,
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
          Text(
            "Cài đặt",
            style: TextStyle(
              color: textPrimaryColor,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: primaryColor,
                child: Text(
                  userName.isNotEmpty ? userName[0].toUpperCase() : "U",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: textPrimaryColor,
                    ),
                  ),
                  Text(
                    userEmail,
                    style: TextStyle(
                      fontSize: 13,
                      color: textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItems() {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      itemCount: moreArr.length,
      itemBuilder: (context, index) {
        final item = moreArr[index];
        final isLogout = item["index"] == "9";

        // Create staggered animation
        final delay = 0.1 + (index * 0.05);

        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            final value = _animationController.value > delay
                ? (_animationController.value - delay) / (1 - delay)
                : 0.0;

            return Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: Opacity(
                opacity: value,
                child: child,
              ),
            );
          },
          child: _buildMenuItem(item, isLogout),
        );
      },
    );
  }

  Widget _buildMenuItem(Map<String, dynamic> item, bool isLogout) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isLogout ? Colors.red.withOpacity(0.1) : cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          if (!isLogout)
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => handleNavigation(item["index"]),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: item["color"].withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    item["icon"],
                    color: item["color"],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item["name"],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isLogout ? Colors.red : textPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item["description"],
                        style: TextStyle(
                          fontSize: 13,
                          color: textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: isLogout
                      ? Colors.red.withOpacity(0.7)
                      : Colors.grey.withOpacity(0.7),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
