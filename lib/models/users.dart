class UserModel {
  final String id;
  final String name;
  // final String email;
  final String role;
  final String address;
  final String mobile;

  UserModel({
    required this.id,
    required this.name,
    // required this.email,
    required this.role,
    this.address = '',
    this.mobile = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      // 'email': email,
      'role': role,
      'address': address,
      'mobile': mobile,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      name: map['name'] ?? 'Unknown',
      // email: map['email'] ?? 'Unknown',
      role: map['role'] ?? 'user',
      address: map['address'] ?? '',
      mobile: map['mobile'] ?? '',
    );
  }
}
