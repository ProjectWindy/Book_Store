import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

class EditBookScreen extends StatefulWidget {
  final String documentId;
  final Map<String, dynamic> book;

  const EditBookScreen({
    Key? key,
    required this.documentId,
    required this.book,
  }) : super(key: key);

  @override
  State<EditBookScreen> createState() => _EditBookScreenState();
}

class _EditBookScreenState extends State<EditBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _authorController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _authorImageController = TextEditingController();
  String _selectedCategory = 'Fiction';
  String _selectedLanguage = 'Tiếng Việt';
  String _selectedAgeGroup = '12+';
  String _selectedRating = '4.5';

  // Predefined price options in VND
  final List<String> _priceOptions = [
    '50000',
    '75000',
    '100000',
    '125000',
    '150000',
    '175000',
    '200000',
    '225000',
    '250000',
    '300000',
    '350000',
    '400000',
    '450000',
    '500000'
  ];

  // Popular author suggestions
  final List<String> _authorSuggestions = [
    'Nguyễn Nhật Ánh',
    'Tô Hoài',
    'Ngô Tất Tố',
    'Nam Cao',
    'Nguyễn Du',
    'Xuân Diệu',
    'Huy Cận',
    'Vũ Trọng Phụng',
    'J. K. Rowling',
    'Stephen King',
    'Haruki Murakami',
    'Paulo Coelho',
    'Dan Brown',
    'George R. R. Martin',
    'J. R. R. Tolkien'
  ];

  final List<String> _categories = [
    'Fiction',
    'Non-Fiction',
    'Bestseller',
    'Promotions',
    'Cooking',
    'Self-Help',
    'Education',
    'Biography',
    'History',
    'Science',
    'Children',
    'Poetry',
    'Romance',
    'Mystery',
    'Thriller',
  ];

  final List<String> _languages = [
    'Tiếng Việt',
    'English',
    'Français',
    'Español',
    'Deutsch',
    '中文',
    '日本語',
    '한국어',
  ];

  final List<String> _ageGroups = [
    '3+',
    '6+',
    '9+',
    '12+',
    '15+',
    '18+',
    'All ages',
  ];

  final List<String> _ratings = [
    '5.0',
    '4.9',
    '4.8',
    '4.7',
    '4.6',
    '4.5',
    '4.4',
    '4.3',
    '4.2',
    '4.1',
    '4.0',
    '3.9',
    '3.8',
    '3.7',
    '3.6',
    '3.5',
    '3.0',
    '2.5',
    '2.0',
  ];

  bool _isSaving = false;
  bool _showCustomPriceField = false;
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  bool _isUploadingImage = false;

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
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _nameController.text = widget.book['name'] ?? '';
    _authorController.text = widget.book['author'] ?? '';
    _priceController.text = widget.book['rate'] ?? '';
    _descriptionController.text = widget.book['description'] ?? '';
    _imageUrlController.text = widget.book['image'] ?? '';
    _authorImageController.text = widget.book['author_img'] ?? '';

    // Kiểm tra và gán giá trị cho dropdown
    _selectedCategory = _categories.contains(widget.book['category'])
        ? widget.book['category']
        : _categories.first;

    _selectedLanguage = _languages.contains(widget.book['language'])
        ? widget.book['language']
        : _languages.first;

    _selectedAgeGroup = _ageGroups.contains(widget.book['age'])
        ? widget.book['age']
        : _ageGroups.first;

    _selectedRating = _ratings.contains(widget.book['rating']?.toString())
        ? widget.book['rating'].toString()
        : _ratings.first;

    // Check if the current price is in our predefined list
    _showCustomPriceField = !_priceOptions.contains(_priceController.text);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _authorController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    _authorImageController.dispose();
    super.dispose();
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
          controller: _imageUrlController,
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
              setState(() {
                _imageFile = null;
              });
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

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
          _imageUrlController.text = ''; // Clear URL when using local image
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
                    _imageUrlController.text = _sampleImages[index];
                    _imageFile = null;
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
                    _imageUrlController.text = _assetImages[index];
                    _imageFile = null;
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

  Future<String?> _uploadImage() async {
    if (_imageFile == null) return null;

    setState(() {
      _isUploadingImage = true;
    });

    try {
      final String fileName = path.basename(_imageFile!.path);
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String uniqueFileName =
          '${widget.documentId}_$timestamp\_$fileName';

      final Reference storageRef = FirebaseStorage.instance
          .ref()
          .child('book_covers')
          .child(uniqueFileName);

      await storageRef.putFile(_imageFile!);
      final String downloadUrl = await storageRef.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi tải ảnh: $e'),
          backgroundColor: Colors.red,
        ),
      );
      return null;
    } finally {
      setState(() {
        _isUploadingImage = false;
      });
    }
  }

  Future<void> _saveBook() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('menu_items')
          .doc(widget.documentId)
          .update({
        'name': _nameController.text,
        'author': _authorController.text,
        'rate': _priceController.text,
        'description': _descriptionController.text,
        'image': _imageUrlController.text.isNotEmpty
            ? _imageUrlController.text
            : _assetImages[0], // Sử dụng ảnh asset đầu tiên nếu không có URL
        'author_img': _authorImageController.text,
        'category': _selectedCategory,
        'type': _selectedCategory,
        'language': _selectedLanguage,
        'age': _selectedAgeGroup,
        'rating': double.parse(_selectedRating),
        'updated_at': Timestamp.now(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sách đã được cập nhật thành công'),
            backgroundColor: Color.fromARGB(221, 202, 159, 159),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi cập nhật sách: $e'),
            backgroundColor: Colors.red,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Chỉnh Sửa Sách',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isSaving ? null : _saveBook,
            tooltip: 'Lưu thay đổi',
          ),
        ],
      ),
      body: Container(
        color: Colors.grey[50],
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Book preview section
              if (_imageUrlController.text.isNotEmpty || _imageFile != null)
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Stack(
                      children: [
                        Container(
                          height: 220,
                          width: 160,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: _imageFile != null
                                ? Image.file(
                                    _imageFile!,
                                    fit: BoxFit.cover,
                                  )
                                : _buildBookCover(_imageUrlController.text),
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
                    ),
                  ),
                ),

              // Form section
              Card(
                margin: const EdgeInsets.all(16),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Book title field
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'Tên sách',
                            hintText: 'Nhập tên sách',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: const Icon(Icons.book),
                            fillColor: Colors.white,
                            filled: true,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Vui lòng nhập tên sách';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Author field with autocomplete
                        Autocomplete<String>(
                          optionsBuilder: (TextEditingValue textEditingValue) {
                            if (textEditingValue.text.isEmpty) {
                              return const Iterable<String>.empty();
                            }
                            return _authorSuggestions.where((String option) {
                              return option.toLowerCase().contains(
                                    textEditingValue.text.toLowerCase(),
                                  );
                            });
                          },
                          onSelected: (String selection) {
                            _authorController.text = selection;
                          },
                          fieldViewBuilder: (
                            BuildContext context,
                            TextEditingController controller,
                            FocusNode focusNode,
                            VoidCallback onFieldSubmitted,
                          ) {
                            // Initialize the controller with the current value
                            controller.text = _authorController.text;
                            // Update our actual controller when this one changes
                            controller.addListener(() {
                              _authorController.text = controller.text;
                            });

                            return TextFormField(
                              controller: controller,
                              focusNode: focusNode,
                              decoration: InputDecoration(
                                labelText: 'Tác giả',
                                hintText: 'Chọn hoặc nhập tên tác giả',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: const Icon(Icons.person),
                                fillColor: Colors.white,
                                filled: true,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Vui lòng nhập tên tác giả';
                                }
                                return null;
                              },
                            );
                          },
                          optionsViewBuilder: (
                            BuildContext context,
                            AutocompleteOnSelected<String> onSelected,
                            Iterable<String> options,
                          ) {
                            return Align(
                              alignment: Alignment.topLeft,
                              child: Material(
                                elevation: 4.0,
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxHeight: 200,
                                    maxWidth: double.infinity,
                                  ),
                                  child: ListView.builder(
                                    padding: const EdgeInsets.all(8.0),
                                    itemCount: options.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      final String option =
                                          options.elementAt(index);
                                      return InkWell(
                                        onTap: () {
                                          onSelected(option);
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(12.0),
                                          child: Text(option),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),

                        // Price selection
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Giá sách',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                ..._priceOptions.map((price) {
                                  final isSelected =
                                      _priceController.text == price &&
                                          !_showCustomPriceField;
                                  final formattedPrice = NumberFormat.currency(
                                    locale: 'vi_VN',
                                    symbol: '',
                                    decimalDigits: 0,
                                  ).format(double.parse(price));

                                  return ChoiceChip(
                                    label: Text('$formattedPrice₫'),
                                    selected: isSelected,
                                    onSelected: (selected) {
                                      setState(() {
                                        if (selected) {
                                          _priceController.text = price;
                                          _showCustomPriceField = false;
                                        }
                                      });
                                    },
                                    backgroundColor: Colors.white,
                                    selectedColor:
                                        const Color.fromARGB(221, 202, 159, 159)
                                            .withOpacity(0.2),
                                    labelStyle: TextStyle(
                                      color: isSelected
                                          ? const Color.fromARGB(
                                              221, 202, 159, 159)
                                          : Colors.grey[800],
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      side: BorderSide(
                                        color: isSelected
                                            ? const Color.fromARGB(
                                                221, 202, 159, 159)
                                            : Colors.grey.shade300,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                // Other price option
                                ChoiceChip(
                                  label: const Text('Khác'),
                                  selected: _showCustomPriceField,
                                  onSelected: (selected) {
                                    setState(() {
                                      _showCustomPriceField = selected;
                                      if (!selected) {
                                        _priceController.text =
                                            _priceOptions[0];
                                      }
                                    });
                                  },
                                  backgroundColor: Colors.white,
                                  selectedColor:
                                      const Color.fromARGB(221, 202, 159, 159)
                                          .withOpacity(0.2),
                                  labelStyle: TextStyle(
                                    color: _showCustomPriceField
                                        ? const Color.fromARGB(
                                            221, 202, 159, 159)
                                        : Colors.grey[800],
                                    fontWeight: _showCustomPriceField
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    side: BorderSide(
                                      color: _showCustomPriceField
                                          ? const Color.fromARGB(
                                              221, 202, 159, 159)
                                          : Colors.grey.shade300,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (_showCustomPriceField) ...[
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _priceController,
                                decoration: InputDecoration(
                                  labelText: 'Giá tùy chỉnh (VNĐ)',
                                  hintText: 'Ví dụ: 150000',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  prefixIcon: const Icon(Icons.monetization_on),
                                  fillColor: Colors.white,
                                  filled: true,
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Vui lòng nhập giá sách';
                                  }
                                  if (double.tryParse(value) == null) {
                                    return 'Vui lòng nhập số hợp lệ';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Category dropdown
                        DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'Danh mục',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: const Icon(Icons.category),
                            fillColor: Colors.white,
                            filled: true,
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
                        const SizedBox(height: 16),

                        // Language dropdown
                        DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'Ngôn ngữ',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: const Icon(Icons.language),
                            fillColor: Colors.white,
                            filled: true,
                          ),
                          value: _selectedLanguage,
                          items: _languages.map((language) {
                            return DropdownMenuItem<String>(
                              value: language,
                              child: Text(language),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedLanguage = value;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 16),

                        // Age group dropdown
                        DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'Độ tuổi',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: const Icon(Icons.people),
                            fillColor: Colors.white,
                            filled: true,
                          ),
                          value: _selectedAgeGroup,
                          items: _ageGroups.map((age) {
                            return DropdownMenuItem<String>(
                              value: age,
                              child: Text(age),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedAgeGroup = value;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 16),

                        // Rating dropdown
                        DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'Đánh giá',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: const Icon(Icons.star),
                            fillColor: Colors.white,
                            filled: true,
                          ),
                          value: _selectedRating,
                          items: _ratings.map((rating) {
                            return DropdownMenuItem<String>(
                              value: rating,
                              child: Row(
                                children: [
                                  Text(rating),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.star,
                                    size: 16,
                                    color: Colors.amber.shade700,
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedRating = value;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 16),

                        // Description field
                        TextFormField(
                          controller: _descriptionController,
                          decoration: InputDecoration(
                            labelText: 'Mô tả',
                            hintText: 'Nhập mô tả sách',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignLabelWithHint: true,
                            fillColor: Colors.white,
                            filled: true,
                          ),
                          maxLines: 5,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Vui lòng nhập mô tả sách';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // Author image URL (hidden behind the button)
                        Visibility(
                          visible: false,
                          child: TextFormField(
                            controller: _authorImageController,
                            decoration: const InputDecoration(
                              labelText: 'URL hình ảnh tác giả',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: _isSaving || _isUploadingImage ? null : _saveBook,
            icon: _isSaving || _isUploadingImage
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.save),
            label: Text(
              _isSaving
                  ? 'Đang lưu...'
                  : _isUploadingImage
                      ? 'Đang tải ảnh...'
                      : 'Lưu thay đổi',
              style: GoogleFonts.poppins(
                  fontSize: 16, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(221, 202, 159, 159),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBookCover(String imagePath) {
    if (imagePath.startsWith('http')) {
      // Network image
      return Image.network(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          // Try to load placeholder from assets if network image fails
          return Image.asset(
            'assets/images/books/Đắc Nhân Tâm.jpg',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              // If even the asset fails, show a colored container with book icon
              return Container(
                color: Colors.grey[200],
                child: Center(
                  child: Icon(
                    Icons.book,
                    size: 40,
                    color: Colors.grey[500],
                  ),
                ),
              );
            },
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: Colors.grey[100],
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        (loadingProgress.expectedTotalBytes ?? 1)
                    : null,
                strokeWidth: 2,
              ),
            ),
          );
        },
      );
    } else if (imagePath.startsWith('assets/')) {
      // Asset image
      return Image.asset(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          // If asset fails, show container with icon
          return Container(
            color: Colors.grey[200],
            child: Center(
              child: Icon(
                Icons.book,
                size: 40,
                color: Colors.grey[500],
              ),
            ),
          );
        },
      );
    } else {
      // Fallback image
      return Image.asset(
        'assets/images/books/Đắc Nhân Tâm.jpg',
        fit: BoxFit.cover,
      );
    }
  }
}
