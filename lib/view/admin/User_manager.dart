import 'package:books_store/models/users.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserManagementView extends StatefulWidget {
  @override
  _UserManagementViewState createState() => _UserManagementViewState();
}

class _UserManagementViewState extends State<UserManagementView> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<UserModel> users = [];
  bool _isLoading = true;
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  void _showToast(String message, bool isSuccess) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.error,
              color: Colors.white,
            ),
            SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _fetchUsers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      QuerySnapshot snapshot = await _firestore.collection('users').get();
      setState(() {
        users = snapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          return UserModel.fromMap({
            'id': doc.id,
            ...data,
          });
        }).toList();
        _isLoading = false;
      });
      _showToast('Tải dữ liệu người dùng thành công', true);
    } catch (e) {
      print('Error fetching users: $e');
      setState(() {
        _isLoading = false;
      });
      _showToast('Lỗi khi tải dữ liệu người dùng', false);
    }
  }

  List<UserModel> get _filteredUsers {
    if (_searchQuery.isEmpty) return users;
    return users.where((user) {
      return user.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user.mobile.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  Future<void> _addUser(UserModel user) async {
    try {
      Map<String, dynamic> userData = user.toMap();
      userData.remove('id');

      DocumentReference docRef =
          await _firestore.collection('users').add(userData);

      _showToast('Thêm người dùng thành công', true);
      _fetchUsers();
    } catch (e) {
      _showToast('Lỗi khi thêm người dùng: $e', false);
    }
  }

  Future<void> _updateUser(UserModel user) async {
    try {
      Map<String, dynamic> userData = user.toMap();
      userData.remove('id');

      await _firestore.collection('users').doc(user.id).update(userData);

      _showToast('Cập nhật người dùng thành công', true);
      _fetchUsers();
    } catch (e) {
      _showToast('Lỗi khi cập nhật người dùng: $e', false);
    }
  }

  Future<void> _deleteUser(String id) async {
    try {
      bool confirm = await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Xác nhận xóa'),
              content: Text('Bạn có chắc chắn muốn xóa người dùng này?'),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text('Hủy', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('Xóa'),
                ),
              ],
            ),
          ) ??
          false;

      if (!confirm) return;

      await _firestore.collection('users').doc(id).delete();

      _showToast('Xóa người dùng thành công', true);
      _fetchUsers();
    } catch (e) {
      _showToast('Lỗi khi xóa người dùng: $e', false);
    }
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Colors.redAccent;
      case 'staff':
        return Colors.blueAccent;
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: Text(
          'Quản lý người dùng',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _fetchUsers,
            tooltip: 'Làm mới',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showUserDialog(),
        backgroundColor: Theme.of(context).primaryColor,
        child: Icon(Icons.add),
        tooltip: 'Thêm người dùng',
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _filteredUsers.isEmpty
                    ? _buildEmptyState()
                    : _buildUserList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.white,
      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'Tìm kiếm người dùng...',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[200],
          contentPadding: EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty
                ? 'Chưa có người dùng nào'
                : 'Không tìm thấy người dùng',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 16),
          if (_searchQuery.isNotEmpty)
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _searchQuery = '';
                });
              },
              icon: Icon(Icons.clear),
              label: Text('Xóa tìm kiếm'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildUserList() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _filteredUsers.length,
      itemBuilder: (context, index) {
        UserModel user = _filteredUsers[index];
        return _buildUserCard(user);
      },
    );
  }

  Widget _buildUserCard(UserModel user) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: Colors.grey[50],
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: _getRoleColor(user.role),
                    child: Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        // Text(
                        //   user.email,
                        //   style: TextStyle(
                        //     fontSize: 14,
                        //     color: Colors.grey[600],
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getRoleColor(user.role).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      user.role,
                      style: TextStyle(
                        fontSize: 12,
                        color: _getRoleColor(user.role),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(Icons.phone, 'Điện thoại', user.mobile),
                SizedBox(height: 8),
                _buildInfoRow(Icons.location_on, 'Địa chỉ', user.address),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => _showUserDialog(user: user),
                      icon: Icon(Icons.edit_outlined, size: 18),
                      label: Text('Sửa'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.blue,
                        side: BorderSide(color: Colors.blue),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: () => _deleteUser(user.id),
                      icon: Icon(Icons.delete_outline, size: 18),
                      label: Text('Xóa'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: Colors.grey[600],
        ),
        SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 2),
              Text(
                value.isEmpty ? '(Chưa cập nhật)' : value,
                style: TextStyle(
                  fontSize: 14,
                  color: value.isEmpty ? Colors.grey : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showUserDialog({UserModel? user}) {
    final nameController = TextEditingController(text: user?.name);
    // final emailController = TextEditingController(text: user?.email);
    final roleController = TextEditingController(text: user?.role);
    final addressController = TextEditingController(text: user?.address);
    final mobileController = TextEditingController(text: user?.mobile);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                user == null ? Icons.person_add : Icons.edit,
                color: Theme.of(context).primaryColor,
              ),
              SizedBox(width: 8),
              Text(
                user == null ? 'Thêm người dùng mới' : 'Chỉnh sửa người dùng',
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Container(
            width: double.maxFinite,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildFormField(
                      controller: nameController,
                      label: 'Họ và tên',
                      icon: Icons.person,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập tên';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    // _buildFormField(
                    //   controller: emailController,
                    //   label: 'Email',
                    //   icon: Icons.email,
                    //   keyboardType: TextInputType.emailAddress,
                    //   validator: (value) {
                    //     if (value == null || value.isEmpty) {
                    //       return 'Vui lòng nhập email';
                    //     }
                    //     if (!value.contains('@')) {
                    //       return 'Email không hợp lệ';
                    //     }
                    //     return null;
                    //   },
                    // ),
                    SizedBox(height: 16),
                    _buildFormField(
                      controller: mobileController,
                      label: 'Số điện thoại',
                      icon: Icons.phone,
                      keyboardType: TextInputType.phone,
                    ),
                    SizedBox(height: 16),
                    _buildFormField(
                      controller: addressController,
                      label: 'Địa chỉ',
                      icon: Icons.location_on,
                    ),
                    SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: roleController.text.isEmpty
                          ? 'user'
                          : roleController.text,
                      decoration: InputDecoration(
                        labelText: 'Vai trò',
                        prefixIcon: Icon(Icons.admin_panel_settings),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      items: [
                        'user',
                        'admin',
                      ].map((String role) {
                        return DropdownMenuItem<String>(
                          value: role,
                          child: Text(role),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        if (value != null) {
                          roleController.text = value;
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  if (user == null) {
                    _addUser(UserModel(
                      id: '',
                      name: nameController.text,
                      // email: emailController.text,
                      role: roleController.text,
                      address: addressController.text,
                      mobile: mobileController.text,
                    ));
                  } else {
                    _updateUser(UserModel(
                      id: user.id,
                      name: nameController.text,
                      // email: emailController.text,
                      role: roleController.text,
                      address: addressController.text,
                      mobile: mobileController.text,
                    ));
                  }
                  Navigator.of(context).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(user == null ? 'Thêm mới' : 'Cập nhật'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      keyboardType: keyboardType,
      validator: validator,
    );
  }
}
