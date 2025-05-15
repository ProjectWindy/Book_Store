import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AddBookScreen extends StatefulWidget {
  const AddBookScreen({Key? key}) : super(key: key);

  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _priceController = TextEditingController();
  final _summaryController = TextEditingController();
  final _coverUrlController = TextEditingController();
  String _selectedCategory = 'Fiction';
  final List<String> _categories = [
    'Fiction',
    'Non-Fiction',
    'Bestseller',
    'Promotions',
    'Cooking',
    'Self-Help',
    'Mystery',
    'Science Fiction',
    'Fantasy',
    'Biography',
    'History',
  ];
  bool _isSaving = false;

  // Danh sách ảnh mẫu
  final List<String> _sampleImages = [
    'https://m.media-amazon.com/images/I/71aLultW5EL._AC_UF1000,1000_QL80_.jpg',
    'https://m.media-amazon.com/images/I/61xkvfPVupL._AC_UF1000,1000_QL80_.jpg',
    'https://m.media-amazon.com/images/I/81xT2mdyL7L._AC_UF1000,1000_QL80_.jpg',
    'https://m.media-amazon.com/images/I/91HHxxtA1wL._AC_UF1000,1000_QL80_.jpg',
    'https://m.media-amazon.com/images/I/71dNsRuYL7L._AC_UF1000,1000_QL80_.jpg',
    'https://m.media-amazon.com/images/I/51Ga5GuElyL._AC_UF1000,1000_QL80_.jpg',
  ];

  // Danh sách ảnh từ assets
  final List<String> _assetImages = [
    'assets/images/books/Đắc Nhân Tâm.jpg',
    'assets/images/books/Nhà_giả_kim_(sách).jpg',
    'assets/images/books/Tuổi Trẻ Đáng Giá Bao Nhiêu.png',
    'assets/images/books/Người Giàu Có Nhất Thành Babylon.jpg',
    'assets/images/books/tư Duy Nhanh Và Chậm.jpg',
    'assets/images/books/Hạt Giống Tâm Hồn.jpg',
    'assets/images/books/Bên Kia Bầu Trời.jpg',
    'assets/images/books/Khéo Ăn Nói Sẽ Có Được Thiên Hạ.jpg',
    'assets/images/books/Mắt Biếc.jpg',
    'assets/images/books/Tôi Thấy Hoa Vàng Trên Cỏ Xanh.jpg',
    'assets/images/books/Cà Phê Cùng Tony.jpg',
    'assets/images/books/Bước Chậm Lại Giữa Thế Gian Vội Vã.jpg',
    'assets/images/books/Harry Potter và Hòn Đá Phù Thủy.jpg',
    'assets/images/books/Lược Sử Loài Người.jpg',
    'assets/images/books/Steve Jobs.jpg',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _priceController.dispose();
    _summaryController.dispose();
    _coverUrlController.dispose();
    super.dispose();
  }

  Future<void> _saveBook() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      await FirebaseFirestore.instance.collection('menu_items').add({
        'name': _titleController.text,
        'author': _authorController.text,
        'rate': _priceController.text,
        'description': _summaryController.text,
        'image': _coverUrlController.text.isNotEmpty
            ? _coverUrlController.text
            : _assetImages[0], // Use first asset image as default
        'author_img': '', // No author image, using default icon
        'category': _selectedCategory,
        'type': _selectedCategory,
        'created_at': Timestamp.now(),
        'updated_at': Timestamp.now(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Sách đã được thêm thành công'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            margin: EdgeInsets.all(16),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 8),
                Expanded(child: Text('Lỗi khi thêm sách: $e')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            margin: EdgeInsets.all(16),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Chọn nguồn ảnh',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_album, color: Colors.green),
              title: const Text('Chọn từ assets'),
              onTap: () {
                Navigator.pop(context);
                _showAssetImagesDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.link, color: Colors.purple),
              title: const Text('Sử dụng link'),
              onTap: () {
                Navigator.pop(context);
                _showLinkInputDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.image, color: Colors.orange),
              title: const Text('Dùng ảnh mẫu'),
              onTap: () {
                Navigator.pop(context);
                _showSampleImagesDialog();
              },
            ),
          ],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  void _showLinkInputDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Nhập link ảnh',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: TextField(
          controller: _coverUrlController,
          decoration: const InputDecoration(
            labelText: 'URL hình ảnh sách',
            hintText: 'https://example.com/image.jpg',
            prefixIcon: Icon(Icons.link),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {});
            },
            child: const Text('Lưu'),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  // Hiển thị dialog chọn ảnh mẫu
  void _showSampleImagesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Chọn ảnh mẫu',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Container(
          width: double.maxFinite,
          height: 300,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.7,
            ),
            itemCount: _sampleImages.length,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  setState(() {
                    _coverUrlController.text = _sampleImages[index];
                  });
                  Navigator.pop(context);
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    _sampleImages[index],
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  (loadingProgress.expectedTotalBytes ?? 1)
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.error, color: Colors.red),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  // Hiển thị dialog chọn ảnh từ assets
  void _showAssetImagesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Chọn ảnh từ assets',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Container(
          width: double.maxFinite,
          height: 300,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.7,
            ),
            itemCount: _assetImages.length,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  setState(() {
                    _coverUrlController.text = _assetImages[index];
                  });
                  Navigator.pop(context);
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    _assetImages[index],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.error, color: Colors.red),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _buildCoverPreview() {
    if (_coverUrlController.text.isEmpty) {
      return Container(
        width: 140,
        height: 180,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_outlined,
              size: 50,
              color: Colors.grey[500],
            ),
            SizedBox(height: 8),
            Text(
              "Hình ảnh sách",
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 140,
            height: 180,
            child: _coverUrlController.text.startsWith('http')
                ? CachedNetworkImage(
                    imageUrl: _coverUrlController.text,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[200],
                      child: Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[200],
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red[400],
                            size: 40,
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Hình ảnh lỗi",
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.red[400],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Image.asset(
                    _coverUrlController.text,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[200],
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red[400],
                            size: 40,
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Hình ảnh lỗi",
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.red[400],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ),
        Positioned(
          right: 0,
          top: 0,
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: InkWell(
              onTap: _showImageSourceDialog,
              child: const Icon(
                Icons.edit,
                size: 20,
                color: Colors.blue,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    bool isRequired = true,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(
          fontSize: 15,
          color: Colors.black54,
        ),
        prefixIcon: Icon(icon, color: Colors.blue[700]),
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
          borderSide: BorderSide(color: Colors.blue[700]!, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
      style: GoogleFonts.poppins(
        fontSize: 15,
        color: Colors.black87,
      ),
      validator: validator ??
          (value) {
            if (isRequired && (value == null || value.isEmpty)) {
              return 'Vui lòng nhập $label';
            }
            return null;
          },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Thêm sách mới',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Book Preview Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCoverPreview(),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _titleController.text.isEmpty
                                  ? "Tên sách"
                                  : _titleController.text,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.black87,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 12),
                            Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.person,
                                    size: 24,
                                    color: Colors.grey[500],
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _authorController.text.isEmpty
                                        ? "Tên tác giả"
                                        : _authorController.text,
                                    style: GoogleFonts.poppins(
                                      fontSize: 15,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Thể loại: $_selectedCategory",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Giá: ${_priceController.text.isEmpty ? "0" : NumberFormat.currency(locale: 'vi_VN', symbol: '', decimalDigits: 0).format(double.tryParse(_priceController.text) ?? 0)}đ",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 24),
              Text(
                "Thông tin sách",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 16),

              // Book Form
              _buildInputField(
                controller: _titleController,
                label: "Tên sách",
                icon: Icons.book,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập tên sách';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              _buildInputField(
                controller: _authorController,
                label: "Tác giả",
                icon: Icons.person,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập tên tác giả';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              _buildInputField(
                controller: _priceController,
                label: "Giá tiền (VNĐ)",
                icon: Icons.monetization_on,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập giá sách';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Giá tiền không hợp lệ';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Category Dropdown
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Thể loại sách',
                  labelStyle: GoogleFonts.poppins(
                    fontSize: 15,
                    color: Colors.black54,
                  ),
                  prefixIcon: Icon(Icons.category, color: Colors.blue[700]),
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
                    borderSide: BorderSide(color: Colors.blue[700]!, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                ),
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  color: Colors.black87,
                ),
                value: _selectedCategory,
                items: _categories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  }
                },
              ),
              SizedBox(height: 24),

              Text(
                "Hình ảnh sách",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 16),

              GestureDetector(
                onTap: _showImageSourceDialog,
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.image, color: Colors.blue[700]),
                      SizedBox(width: 16),
                      Text(
                        _coverUrlController.text.isEmpty
                            ? "Chọn ảnh bìa sách"
                            : "Đã chọn ảnh bìa sách",
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          color: _coverUrlController.text.isEmpty
                              ? Colors.black54
                              : Colors.black87,
                        ),
                      ),
                      Spacer(),
                      Icon(Icons.arrow_forward_ios,
                          size: 16, color: Colors.grey[400]),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 24),

              Text(
                "Mô tả sách",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 16),

              _buildInputField(
                controller: _summaryController,
                label: "Mô tả chi tiết",
                icon: Icons.description,
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập mô tả sách';
                  }
                  return null;
                },
              ),
              SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveBook,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: _isSaving
                      ? CircularProgressIndicator(color: Colors.white)
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add, size: 22),
                            SizedBox(width: 8),
                            Text(
                              'Thêm sách mới',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
