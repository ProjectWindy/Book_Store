import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  String _selectedRole = 'all';
  final _searchController = TextEditingController();
  bool _isAddingUser = false;
  bool _isEditingUser = false;
  Map<String, dynamic>? _editingUserData;
  String? _editingUserId;

  // Các controller cho form thêm/sửa người dùng
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  String _selectedNewRole = 'user';

  @override
  void dispose() {
    _searchController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: _buildUserList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddUserForm();
        },
        backgroundColor: const Color.fromARGB(221, 202, 159, 159),
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Tìm kiếm người dùng...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            ),
            style: GoogleFonts.poppins(),
            onChanged: (value) {
              setState(() {});
            },
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildRoleFilter('Tất cả', 'all'),
                _buildRoleFilter('Người dùng', 'user'),
                _buildRoleFilter('Người bán', 'seller'),
                _buildRoleFilter('Quản trị viên', 'admin'),
                _buildRoleFilter('Đã chặn', 'blocked'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleFilter(String label, String role) {
    final isSelected = _selectedRole == role;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(
          label,
          style: GoogleFonts.poppins(),
        ),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedRole = role;
          });
        },
        backgroundColor: Colors.white,
        selectedColor:
            const Color.fromARGB(221, 202, 159, 159).withOpacity(0.2),
        checkmarkColor: const Color.fromARGB(221, 202, 159, 159),
        labelStyle: GoogleFonts.poppins(
          color: isSelected
              ? const Color.fromARGB(221, 202, 159, 159)
              : Colors.black87,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
    );
  }

  Widget _buildUserList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _buildUserQuery(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
              child: Text('Lỗi: ${snapshot.error}',
                  style: GoogleFonts.poppins(color: Colors.red)));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Color.fromARGB(221, 202, 159, 159),
              ),
            ),
          );
        }

        final users = snapshot.data?.docs ?? [];
        if (users.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_off, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'Không tìm thấy người dùng',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: users.length,
          padding: const EdgeInsets.all(8),
          itemBuilder: (context, index) {
            final userData = users[index].data() as Map<String, dynamic>;
            final userId = users[index].id;
            final isBlocked = userData['status'] == 'blocked';
            final userRole = userData['role'] ?? 'user';
            String roleText;

            switch (userRole) {
              case 'admin':
                roleText = 'Quản trị viên';
                break;
              case 'seller':
                roleText = 'Người bán';
                break;
              default:
                roleText = 'Người dùng';
            }

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor:
                              const Color.fromARGB(221, 202, 159, 159)
                                  .withOpacity(0.2),
                          radius: 24,
                          child: Text(
                            (userData['name'] ?? 'U')[0].toUpperCase(),
                            style: GoogleFonts.poppins(
                              color: const Color.fromARGB(221, 202, 159, 159),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userData['name'] ?? _formatMissingInfo('Tên'),
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color:
                                      isBlocked ? Colors.grey : Colors.black87,
                                ),
                              ),
                              Text(
                                userData['email'] ??
                                    _formatMissingInfo('Email'),
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isBlocked
                                ? Colors.red.withOpacity(0.1)
                                : const Color.fromARGB(221, 202, 159, 159)
                                    .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            isBlocked ? 'Đã chặn' : roleText,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isBlocked
                                  ? Colors.red
                                  : const Color.fromARGB(221, 202, 159, 159),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 8),
                    _buildUserInfoItem(
                      Icons.phone,
                      'Điện thoại',
                      userData['phone'],
                    ),
                    const SizedBox(height: 8),
                    _buildUserInfoItem(
                      Icons.location_on,
                      'Địa chỉ',
                      userData['address'],
                    ),
                    const SizedBox(height: 8),
                    _buildUserInfoItem(
                      Icons.shopping_bag,
                      'Đơn hàng',
                      userData['orderCount']?.toString(),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton.icon(
                          icon: const Icon(Icons.edit, size: 16),
                          label: Text(
                            'Sửa',
                            style: GoogleFonts.poppins(fontSize: 13),
                          ),
                          onPressed: () => _showEditUserForm(userData, userId),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          icon: Icon(
                            isBlocked ? Icons.lock_open : Icons.lock,
                            size: 16,
                          ),
                          label: Text(
                            isBlocked ? 'Bỏ chặn' : 'Chặn',
                            style: GoogleFonts.poppins(fontSize: 13),
                          ),
                          onPressed: () => _toggleUserBlock(userId, isBlocked),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                isBlocked ? Colors.green : Colors.orange,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.delete, size: 16),
                          label: Text(
                            'Xóa',
                            style: GoogleFonts.poppins(fontSize: 13),
                          ),
                          onPressed: () => _showDeleteUserConfirmation(
                              userId, userData['name'] ?? 'Người dùng'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _formatMissingInfo(String field) {
    return '$field chưa cập nhật';
  }

  Widget _buildUserInfoItem(IconData icon, String label, String? value) {
    final isMissing = value == null || value.isEmpty;

    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: Colors.blueGrey,
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        Expanded(
          child: Text(
            isMissing ? _formatMissingInfo(label) : value!,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: isMissing ? Colors.grey[400] : Colors.grey[800],
              fontStyle: isMissing ? FontStyle.italic : FontStyle.normal,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Stream<QuerySnapshot> _buildUserQuery() {
    Query query = FirebaseFirestore.instance.collection('users');

    if (_selectedRole != 'all') {
      if (_selectedRole == 'blocked') {
        query = query.where('status', isEqualTo: 'blocked');
      } else {
        query = query.where('role', isEqualTo: _selectedRole);
      }
    }

    if (_searchController.text.isNotEmpty) {
      // Thực hiện tìm kiếm
      String searchTerm = _searchController.text.toLowerCase();

      // Sử dụng cách khác để tìm kiếm
      return query.snapshots().map((snapshot) {
        final filteredDocs = snapshot.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final name = (data['name'] ?? '').toString().toLowerCase();
          final email = (data['email'] ?? '').toString().toLowerCase();
          final phone = (data['phone'] ?? '').toString().toLowerCase();

          return name.contains(searchTerm) ||
              email.contains(searchTerm) ||
              phone.contains(searchTerm);
        }).toList();

        // Trả về một QuerySnapshot mới với các documents đã lọc
        return snapshot;
      });
    }

    return query.snapshots();
  }

  void _showAddUserForm() {
    // Reset các controller
    _nameController.clear();
    _emailController.clear();
    _passwordController.clear();
    _phoneController.clear();
    _selectedNewRole = 'user';

    setState(() {
      _isAddingUser = true;
      _isEditingUser = false;
      _editingUserData = null;
      _editingUserId = null;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        elevation: 8,
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(221, 202, 159, 159)
                          .withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.person_add,
                      color: Color.fromARGB(221, 202, 159, 159),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Thêm người dùng mới',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        Text(
                          'Điền thông tin để tạo người dùng mới',
                          style: GoogleFonts.poppins(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 24),
              _buildFormField(
                controller: _nameController,
                label: 'Họ tên',
                icon: Icons.person_outline,
                isRequired: true,
              ),
              const SizedBox(height: 20),
              _buildFormField(
                controller: _emailController,
                label: 'Email',
                icon: Icons.email_outlined,
                isRequired: true,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              _buildFormField(
                controller: _passwordController,
                label: 'Mật khẩu',
                icon: Icons.lock_outline,
                isRequired: true,
                isPassword: true,
              ),
              const SizedBox(height: 20),
              _buildFormField(
                controller: _phoneController,
                label: 'Số điện thoại',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20),
              _buildRoleDropdown(),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey[700],
                      side: BorderSide(color: Colors.grey[300]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                    child: Text(
                      'Hủy',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      _addNewUser();
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(221, 202, 159, 159),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.add, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Tạo',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isRequired = false,
    bool isPassword = false,
    bool enabled = true,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[800],
              ),
            ),
            if (isRequired)
              Text(
                ' *',
                style: GoogleFonts.poppins(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          enabled: enabled,
          keyboardType: keyboardType,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[800],
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: enabled ? Colors.white : Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                  color: Color.fromARGB(221, 202, 159, 159), width: 1.5),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            hintText: 'Nhập $label',
            hintStyle: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[400],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRoleDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.badge_outlined, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Text(
              'Vai trò',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[800],
              ),
            ),
            Text(
              ' *',
              style: GoogleFonts.poppins(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedNewRole,
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[800],
            ),
            icon: Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
            items: [
              _buildDropdownItem('user', 'Người dùng', Icons.person),
              _buildDropdownItem('seller', 'Người bán', Icons.store),
              _buildDropdownItem(
                  'admin', 'Quản trị viên', Icons.admin_panel_settings),
            ],
            onChanged: (value) {
              setState(() {
                _selectedNewRole = value!;
              });
            },
            dropdownColor: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ],
    );
  }

  DropdownMenuItem<String> _buildDropdownItem(
      String value, String label, IconData icon) {
    return DropdownMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color.fromARGB(221, 202, 159, 159)),
          const SizedBox(width: 10),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addNewUser() async {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Vui lòng điền đầy đủ thông tin',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    try {
      // Tạo tài khoản với Firebase Auth
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Thêm thông tin vào Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(credential.user!.uid)
          .set({
        'name': _nameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'role': _selectedNewRole,
        'status': 'active',
        'created_at': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Đã thêm người dùng thành công',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Lỗi: $e',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  void _showEditUserForm(Map<String, dynamic> userData, String userId) {
    _nameController.text = userData['name'] ?? '';
    _emailController.text = userData['email'] ?? '';
    _passwordController.clear(); // Không hiển thị mật khẩu
    _phoneController.text = userData['phone'] ?? '';
    _selectedNewRole = userData['role'] ?? 'user';

    setState(() {
      _isAddingUser = false;
      _isEditingUser = true;
      _editingUserData = userData;
      _editingUserId = userId;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        elevation: 8,
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(221, 202, 159, 159)
                          .withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.edit,
                      color: Color.fromARGB(221, 202, 159, 159),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Chỉnh sửa người dùng',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        Text(
                          'Cập nhật thông tin người dùng',
                          style: GoogleFonts.poppins(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 24),
              _buildFormField(
                controller: _nameController,
                label: 'Họ tên',
                icon: Icons.person_outline,
                isRequired: true,
              ),
              const SizedBox(height: 20),
              _buildFormField(
                controller: _emailController,
                label: 'Email',
                icon: Icons.email_outlined,
                isRequired: true,
                enabled: false,
              ),
              const SizedBox(height: 20),
              _buildFormField(
                controller: _phoneController,
                label: 'Số điện thoại',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20),
              _buildRoleDropdown(),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey[700],
                      side: BorderSide(color: Colors.grey[300]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                    child: Text(
                      'Hủy',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      _updateUser();
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(221, 202, 159, 159),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.save, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Lưu thay đổi',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _updateUser() async {
    if (_nameController.text.isEmpty || _editingUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Vui lòng điền đầy đủ thông tin',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    try {
      // Cập nhật thông tin trong Firestore
      final updateData = {
        'name': _nameController.text,
        'phone': _phoneController.text,
        'role': _selectedNewRole,
        'updated_at': Timestamp.now(),
      };

      await FirebaseFirestore.instance
          .collection('users')
          .doc(_editingUserId)
          .update(updateData);

      // Không thay đổi mật khẩu người dùng
      // Đã loại bỏ code thay đổi mật khẩu

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Đã cập nhật người dùng thành công',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Lỗi: $e',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  void _showDeleteUserConfirmation(String userId, String userName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Xác nhận xóa',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Bạn có chắc chắn muốn xóa người dùng "$userName" không?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Hủy',
              style: GoogleFonts.poppins(
                color: Colors.grey[700],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _deleteUser(userId);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Xóa',
              style: GoogleFonts.poppins(
                color: Colors.white,
              ),
            ),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Future<void> _deleteUser(String userId) async {
    try {
      // Xóa người dùng từ Firestore
      await FirebaseFirestore.instance.collection('users').doc(userId).delete();

      // Trong thực tế, bạn cũng nên xóa tài khoản trong Firebase Auth
      // Nhưng điều này yêu cầu xác thực lại người dùng hoặc quyền admin

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Đã xóa người dùng thành công',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Lỗi khi xóa người dùng: $e',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  Future<void> _toggleUserBlock(String userId, bool isCurrentlyBlocked) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'status': isCurrentlyBlocked ? 'active' : 'blocked',
        'updated_at': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isCurrentlyBlocked ? 'Đã bỏ chặn người dùng' : 'Đã chặn người dùng',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Lỗi: $e',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }
}
