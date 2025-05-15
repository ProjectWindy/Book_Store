import 'dart:ui';

import 'package:flutter/material.dart';

import '../home/book_home_screen.dart';
import '../menu/menu_view.dart';
import '../more/more_view.dart';
import '../offer/offer_view.dart';
import '../profile/profile_view.dart';

class MainTabView extends StatefulWidget {
  const MainTabView({super.key});

  @override
  State<MainTabView> createState() => _MainTabViewState();
}

class _MainTabViewState extends State<MainTabView>
    with SingleTickerProviderStateMixin {
  int selctTab = 2;
  PageStorageBucket storageBucket = PageStorageBucket();
  Widget selectPageView = const BooksHome();

  // Define modern colors
  static const Color primaryColor = Color(0xFF3A86FF);
  static const Color backgroundColor = Color(0xFFF0F2F5);
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color inactiveColor = Color(0xFF94A3B8);

  // For animation
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _changeTab(int index, Widget view) {
    if (selctTab != index) {
      _animationController.reset();
      _animationController.forward();
      setState(() {
        selctTab = index;
        selectPageView = view;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: CurvedAnimation(
          parent: _animationController,
          curve: Curves.easeInOut,
        ),
        child: PageStorage(bucket: storageBucket, child: selectPageView),
      ),
      backgroundColor: backgroundColor,
      // These properties help prevent the bottom navigation bar from moving
      extendBody: true,
      resizeToAvoidBottomInset: false,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: SizedBox(
        width: 64,
        height: 64,
        child: FloatingActionButton(
          onPressed: () => _changeTab(2, const BooksHome()),
          elevation: 4,
          shape: const CircleBorder(),
          backgroundColor: selctTab == 2 ? primaryColor : cardColor,
          child: Icon(
            Icons.home_rounded,
            size: 30,
            color: selctTab == 2 ? Colors.white : inactiveColor,
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: BottomAppBar(
              elevation: 0,
              surfaceTintColor: cardColor,
              color: cardColor.withOpacity(0.9),
              notchMargin: 10,
              height: 68,
              padding: EdgeInsets.zero,
              shape: const CircularNotchedRectangle(),
              child: SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildTabItem(
                      icon: Icons.format_list_bulleted_rounded,
                      title: "Danh sách",
                      index: 0,
                      view: const MenuView(),
                    ),
                    _buildTabItem(
                      icon: Icons.local_fire_department_rounded,
                      title: "Sách hot",
                      index: 1,
                      view: const OfferView(),
                    ),
                    const SizedBox(width: 50),
                    _buildTabItem(
                      icon: Icons.person_rounded,
                      title: "Tài khoản",
                      index: 3,
                      view: const ProfileView(),
                    ),
                    _buildTabItem(
                      icon: Icons.settings_rounded,
                      title: "Cài đặt",
                      index: 4,
                      view: const MoreView(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem({
    required IconData icon,
    required String title,
    required int index,
    required Widget view,
  }) {
    final isSelected = selctTab == index;
    return Expanded(
      child: InkWell(
        onTap: () => _changeTab(index, view),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? primaryColor : inactiveColor,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? primaryColor : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
