import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView>
    with SingleTickerProviderStateMixin {
  final ImagePicker picker = ImagePicker();
  XFile? image;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  User? user;
  Map<String, dynamic>? userData;
  String? profileImageBase64;

  // Modern UI colors
  static const Color primaryColor = Color(0xFF3A86FF);
  static const Color backgroundColor = Color(0xFFF0F2F5);
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color textPrimaryColor = Color(0xFF212529);
  static const Color textSecondaryColor = Color(0xFF6C757D);
  static const Color accentColor = Color(0xFFFF006E);

  final TextEditingController nameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  // For animation
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    getUserData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    nameController.dispose();
    mobileController.dispose();
    addressController.dispose();
    super.dispose();
  }

  Future<void> getUserData() async {
    setState(() => _isLoading = true);
    user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot snapshot =
          await _firestore.collection('users').doc(user!.uid).get();
      if (snapshot.exists) {
        setState(() {
          userData = snapshot.data() as Map<String, dynamic>?;
          nameController.text = userData?['name'] ?? '';
          mobileController.text = userData?['mobile'] ?? '';
          addressController.text = userData?['address'] ?? '';
        });
      }
      await getProfileImage();
      setState(() => _isLoading = false);
      _animationController.forward();
    }
  }

  Future<void> getProfileImage() async {
    DataSnapshot snapshot =
        await _database.child('users/${user!.uid}/profile_image').get();
    if (snapshot.exists) {
      setState(() {
        profileImageBase64 = snapshot.value as String?;
      });
    }
  }

  Future<void> saveUserData() async {
    setState(() => _isSaving = true);

    try {
      if (user != null) {
        await _firestore.collection('users').doc(user!.uid).update({
          'name': nameController.text,
          'mobile': mobileController.text,
          'address': addressController.text,
        });

        if (image != null) {
          File file = File(image!.path);
          List<int> imageBytes = await file.readAsBytes();
          String base64Image = base64Encode(imageBytes);

          await _database
              .child('users/${user!.uid}/profile_image')
              .set(base64Image);

          setState(() {
            profileImageBase64 = base64Image;
          });
        }

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Thông tin đã được lưu thành công!'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: primaryColor),
            )
          : SafeArea(
              child: FadeTransition(
                opacity: _animation,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildHeader(),
                      _buildProfileContent(),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 15, 20, 25),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
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
            children: [
              Text(
                "Hồ sơ của bạn",
                style: TextStyle(
                  color: textPrimaryColor,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildProfileImage(),
          const SizedBox(height: 15),
          Text(
            "Xin chào, ${userData?['name'] ?? 'Người dùng'}!",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            userData?['email'] ?? '',
            style: TextStyle(
              color: textSecondaryColor,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage() {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            shape: BoxShape.circle,
            border: Border.all(color: primaryColor.withOpacity(0.3), width: 4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 15,
                spreadRadius: 2,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipOval(
            child: image != null
                ? Image.file(File(image!.path), fit: BoxFit.cover)
                : profileImageBase64 != null
                    ? Image.memory(
                        base64Decode(profileImageBase64!),
                        fit: BoxFit.cover,
                      )
                    : const Icon(Icons.person, size: 80, color: Colors.grey),
          ),
        ),
        GestureDetector(
          onTap: () async {
            try {
              final XFile? pickedImage = await picker.pickImage(
                source: ImageSource.gallery,
                maxWidth: 1800,
                maxHeight: 1800,
                imageQuality: 85,
              );

              if (pickedImage != null) {
                setState(() {
                  image = pickedImage;
                });

                // Save immediately after picking
                File file = File(pickedImage.path);
                List<int> imageBytes = await file.readAsBytes();
                String base64Image = base64Encode(imageBytes);

                await _database
                    .child('users/${user!.uid}/profile_image')
                    .set(base64Image);

                setState(() {
                  profileImageBase64 = base64Image;
                });

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Ảnh đại diện đã được cập nhật!'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                  );
                }
              }
            } catch (e) {
              print('Error picking image: $e');
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Không thể chọn ảnh. Vui lòng thử lại.'),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                  ),
                );
              }
            }
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primaryColor,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileContent() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Thông tin cá nhân",
            style: TextStyle(
              color: textPrimaryColor,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 15),
          _buildInfoCard(),
          const SizedBox(height: 30),
          _buildSaveButton(),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildTextField(
              label: "Họ tên",
              controller: nameController,
              icon: Icons.person_outline,
            ),
            const Divider(height: 25),
            _buildTextField(
              label: "Số điện thoại",
              controller: mobileController,
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
            const Divider(height: 25),
            _buildTextField(
              label: "Địa chỉ",
              controller: addressController,
              icon: Icons.location_on_outlined,
              isLast: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType? keyboardType,
    bool isLast = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: primaryColor, size: 22),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              style: TextStyle(
                fontSize: 15,
                color: textPrimaryColor,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                labelText: label,
                labelStyle: TextStyle(
                  color: textSecondaryColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _isSaving ? null : saveUserData,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey.shade300,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: _isSaving
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                'Lưu thông tin',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}
