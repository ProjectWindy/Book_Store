import 'package:books_store/services/auth_service.dart';
import 'package:books_store/view/login/login_view.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'order_overview_screen.dart';
import 'product_approval_screen.dart';
import 'revenue_report_screen.dart';
import 'user_management_screen.dart';
import 'data_management_screen.dart';
import 'notification_screen.dart';
import 'qr_code_generator_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;
  int _notificationCount = 0;

  final List<Widget> _screens = [
    const UserManagementScreen(),
    const ProductApprovalScreen(),
    const OrderOverviewScreen(),
    const RevenueReportScreen(),
    const DataManagementScreen(),
    const NotificationScreen(),
    const QRCodeGeneratorScreen(),
    // const SystemActivityScreen(),
  ];

  final List<DrawerItem> _drawerItems = [
    DrawerItem(
      title: 'Quản lý người dùng',
      icon: Icons.people,
      description: 'Quản lý người dùng và phân quyền',
    ),
    DrawerItem(
      title: 'Duyệt sản phẩm',
      icon: Icons.inventory,
      description: 'Xem xét và phê duyệt sản phẩm',
    ),
    DrawerItem(
      title: 'Tổng quan đơn hàng',
      icon: Icons.shopping_cart,
      description: 'Theo dõi đơn hàng trong hệ thống',
    ),
    DrawerItem(
      title: 'Báo cáo doanh thu',
      icon: Icons.bar_chart,
      description: 'Xem thống kê doanh thu',
    ),
    DrawerItem(
      title: 'Quản lý dữ liệu',
      icon: Icons.upload_file,
      description: 'Quản lý dữ liệu hệ thống',
    ),
    DrawerItem(
      title: 'Thông báo',
      icon: Icons.notifications,
      description: 'Xem các thông báo mới',
      hasBadge: true,
    ),
    DrawerItem(
      title: 'Tạo mã QR',
      icon: Icons.qr_code,
      description: 'Tạo mã QR cho sản phẩm và khuyến mãi',
    ),
    // DrawerItem(
    //   title: 'System Activity',
    //   icon: Icons.analytics,
    //   description: 'Track seller performance',
    // ),
  ];

  @override
  void initState() {
    super.initState();
    _fetchNotificationCount();
  }

  Future<void> _fetchNotificationCount() async {
    try {
      // Theo dõi các đơn hàng mới chưa đọc
      final snapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('isRead', isEqualTo: false)
          .get();

      setState(() {
        _notificationCount = snapshot.docs.length;
      });

      // Thiết lập lắng nghe realtime
      FirebaseFirestore.instance
          .collection('orders')
          .where('isRead', isEqualTo: false)
          .snapshots()
          .listen((snapshot) {
        setState(() {
          _notificationCount = snapshot.docs.length;
        });
      });
    } catch (e) {
      print('Lỗi khi tải thông báo: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          _drawerItems[_selectedIndex].title,
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: const Color.fromARGB(221, 202, 159, 159),
          ),
        ),
        backgroundColor: Colors.grey[50],
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      drawer: Drawer(
        elevation: 5,
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color.fromARGB(221, 202, 159, 159),
                    const Color.fromARGB(221, 202, 159, 159).withOpacity(0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.admin_panel_settings,
                      size: 60,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Trang quản trị',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                itemCount: _drawerItems.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: _selectedIndex == index
                          ? Colors.pink.withOpacity(0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Stack(
                      children: [
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          leading: Icon(
                            _drawerItems[index].icon,
                            color: _selectedIndex == index
                                ? const Color.fromARGB(221, 202, 159, 159)
                                : Colors.grey[600],
                            size: 28,
                          ),
                          title: Text(
                            _drawerItems[index].title,
                            style: GoogleFonts.poppins(
                              color: _selectedIndex == index
                                  ? const Color.fromARGB(221, 202, 159, 159)
                                  : Colors.black87,
                              fontWeight: _selectedIndex == index
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Text(
                            _drawerItems[index].description,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          selected: _selectedIndex == index,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          onTap: () {
                            setState(() {
                              _selectedIndex = index;
                            });
                            Navigator.pop(context);
                          },
                        ),
                        if (_drawerItems[index].hasBadge &&
                            _notificationCount > 0)
                          Positioned(
                            right: 12,
                            top: 12,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                _notificationCount > 9
                                    ? '9+'
                                    : _notificationCount.toString(),
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
                  );
                },
              ),
            ),
            const Divider(),
            Container(
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(Icons.logout, color: Colors.red, size: 28),
                title: Text(
                  'Đăng xuất',
                  style: GoogleFonts.poppins(
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text(
                          "Đăng xuất",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        content: Text(
                          "Bạn có chắc chắn muốn đăng xuất?",
                          style: GoogleFonts.poppins(),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text(
                              "Hủy",
                              style: GoogleFonts.poppins(
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              Navigator.of(context).pop();
                              try {
                                final authService = AuthService();
                                await authService.logout();
                                if (context.mounted) {
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const LoginView(),
                                    ),
                                    (route) => false,
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Lỗi đăng xuất: $e'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(221, 202, 159, 159),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                            ),
                            child: Text(
                              "Đăng xuất",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
      body: _screens[_selectedIndex],
    );
  }
}

class DrawerItem {
  final String title;
  final IconData icon;
  final String description;
  final bool hasBadge;

  DrawerItem({
    required this.title,
    required this.icon,
    required this.description,
    this.hasBadge = false,
  });
}
