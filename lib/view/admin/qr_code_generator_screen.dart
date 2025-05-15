import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRCodeGeneratorScreen extends StatefulWidget {
  const QRCodeGeneratorScreen({Key? key}) : super(key: key);

  @override
  State<QRCodeGeneratorScreen> createState() => _QRCodeGeneratorScreenState();
}

class _QRCodeGeneratorScreenState extends State<QRCodeGeneratorScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _discountController =
      TextEditingController(text: '10');
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _minPurchaseController =
      TextEditingController(text: '0');

  TabController? _tabController;
  DateTime _expiryDate = DateTime.now().add(const Duration(days: 30));
  bool _isActive = true;
  bool _isLoading = false;
  bool _isEditing = false;
  String? _editingVoucherId;
  bool _isCustomDiscount = false;
  bool _isCustomMinPurchase = false;

  // Predefined values for discount and min purchase
  final List<int> _discountOptions = [5, 10, 15, 20, 25, 30, 50, 70];
  final List<int> _minPurchaseOptions = [
    0,
    50000,
    100000,
    200000,
    300000,
    500000
  ];

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _codeController.dispose();
    _titleController.dispose();
    _discountController.dispose();
    _descriptionController.dispose();
    _minPurchaseController.dispose();
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color.fromARGB(221, 202, 159, 159),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _expiryDate) {
      setState(() {
        _expiryDate = picked;
      });
    }
  }

  void _resetForm() {
    _codeController.clear();
    _titleController.clear();
    _discountController.text = '10';
    _descriptionController.clear();
    _minPurchaseController.text = '0';
    setState(() {
      _expiryDate = DateTime.now().add(const Duration(days: 30));
      _isActive = true;
      _isEditing = false;
      _editingVoucherId = null;
      _isCustomDiscount = false;
      _isCustomMinPurchase = false;
    });
  }

  String _generateRandomCode(int length) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
  }

  void _generateVoucherCode() {
    setState(() {
      _codeController.text = _generateRandomCode(8);
    });
  }

  Future<void> _saveVoucher() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final voucherData = {
        'code': _codeController.text.toUpperCase(),
        'title': _titleController.text,
        'discount': double.parse(_discountController.text),
        'description': _descriptionController.text,
        'minPurchase': double.parse(_minPurchaseController.text),
        'expiryDate': Timestamp.fromDate(_expiryDate),
        'isActive': _isActive,
        'createdAt':
            _isEditing ? FieldValue.serverTimestamp() : Timestamp.now(),
        'updatedAt': Timestamp.now(),
      };

      if (_isEditing && _editingVoucherId != null) {
        await FirebaseFirestore.instance
            .collection('vouchers')
            .doc(_editingVoucherId)
            .update(voucherData);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Mã giảm giá đã được cập nhật',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        await FirebaseFirestore.instance
            .collection('vouchers')
            .add(voucherData);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Đã tạo mã giảm giá mới',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.green,
          ),
        );
      }

      _resetForm();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Lỗi: $e',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _editVoucher(DocumentSnapshot voucher) {
    final data = voucher.data() as Map<String, dynamic>;
    _codeController.text = data['code'] ?? '';
    _titleController.text = data['title'] ?? '';

    final discount = (data['discount'] ?? 0).toString();
    _discountController.text = discount;
    setState(() {
      _isCustomDiscount = !_discountOptions.contains(int.tryParse(discount));
    });

    final minPurchase = (data['minPurchase'] ?? 0).toString();
    _minPurchaseController.text = minPurchase;
    setState(() {
      _isCustomMinPurchase =
          !_minPurchaseOptions.contains(int.tryParse(minPurchase));
    });

    _descriptionController.text = data['description'] ?? '';

    setState(() {
      _expiryDate = (data['expiryDate'] as Timestamp).toDate();
      _isActive = data['isActive'] ?? true;
      _isEditing = true;
      _editingVoucherId = voucher.id;
      // Chuyển tab về tab tạo voucher
      _tabController?.animateTo(0);
    });
  }

  Future<void> _deleteVoucher(String id) async {
    try {
      await FirebaseFirestore.instance.collection('vouchers').doc(id).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Đã xóa mã giảm giá',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Lỗi khi xóa: $e',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Quản lý mã giảm giá',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: _resetForm,
              tooltip: 'Hủy chỉnh sửa',
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color.fromARGB(221, 202, 159, 159),
          unselectedLabelColor: Colors.grey[600],
          indicatorColor: const Color.fromARGB(221, 202, 159, 159),
          tabs: [
            Tab(
              icon: const Icon(Icons.add_circle_outline),
              text: _isEditing ? 'Sửa voucher' : 'Tạo voucher',
            ),
            const Tab(
              icon: Icon(Icons.list_alt),
              text: 'Danh sách',
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Color.fromARGB(221, 202, 159, 159),
                ),
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _buildVoucherForm(),
                  ),
                ),
                _buildVoucherList(),
              ],
            ),
    );
  }

  Widget _buildVoucherForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isEditing ? 'Chỉnh sửa mã giảm giá' : 'Tạo mã giảm giá mới',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color.fromARGB(221, 202, 159, 159),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mã giảm giá',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _codeController,
                              decoration: InputDecoration(
                                hintText: 'Mã giảm giá',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: const Icon(Icons.code),
                              ),
                              style: GoogleFonts.poppins(),
                              textCapitalization: TextCapitalization.characters,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Vui lòng nhập mã giảm giá';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: _generateVoucherCode,
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(221, 202, 159, 159),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.autorenew,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Giảm giá (%)',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ..._discountOptions.map((discount) => ChoiceChip(
                                label: Text('$discount%'),
                                selected: !_isCustomDiscount &&
                                    _discountController.text ==
                                        discount.toString(),
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(() {
                                      _discountController.text =
                                          discount.toString();
                                      _isCustomDiscount = false;
                                    });
                                  }
                                },
                                selectedColor:
                                    const Color.fromARGB(221, 202, 159, 159)
                                        .withOpacity(0.7),
                                labelStyle: GoogleFonts.poppins(
                                  color: !_isCustomDiscount &&
                                          _discountController.text ==
                                              discount.toString()
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              )),
                          ChoiceChip(
                            label:
                                Text(_isCustomDiscount ? 'Tùy chỉnh' : 'Khác'),
                            selected: _isCustomDiscount,
                            onSelected: (selected) {
                              setState(() {
                                _isCustomDiscount = selected;
                                if (selected) {
                                  // Clear for custom input
                                  _discountController.text = '';
                                } else {
                                  // Default to first option
                                  _discountController.text =
                                      _discountOptions.first.toString();
                                }
                              });
                            },
                            selectedColor:
                                const Color.fromARGB(221, 202, 159, 159)
                                    .withOpacity(0.7),
                            labelStyle: GoogleFonts.poppins(
                              color: _isCustomDiscount
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ],
                      ),
                      if (_isCustomDiscount) ...[
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _discountController,
                          decoration: InputDecoration(
                            hintText: 'Nhập % giảm giá',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: const Icon(Icons.discount),
                          ),
                          style: GoogleFonts.poppins(),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Vui lòng nhập % giảm giá';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Vui lòng nhập số';
                            }
                            if (double.parse(value) <= 0 ||
                                double.parse(value) > 100) {
                              return 'Giá trị từ 1-100';
                            }
                            return null;
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Tiêu đề',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.title),
              ),
              style: GoogleFonts.poppins(),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập tiêu đề';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Mô tả',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.description),
              ),
              style: GoogleFonts.poppins(),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Giá trị đơn hàng tối thiểu',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ..._minPurchaseOptions.map((amount) => ChoiceChip(
                                label: Text(
                                  amount == 0
                                      ? 'Không giới hạn'
                                      : NumberFormat.compact(locale: 'vi')
                                          .format(amount),
                                ),
                                selected: !_isCustomMinPurchase &&
                                    _minPurchaseController.text ==
                                        amount.toString(),
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(() {
                                      _minPurchaseController.text =
                                          amount.toString();
                                      _isCustomMinPurchase = false;
                                    });
                                  }
                                },
                                selectedColor:
                                    const Color.fromARGB(221, 202, 159, 159)
                                        .withOpacity(0.7),
                                labelStyle: GoogleFonts.poppins(
                                  color: !_isCustomMinPurchase &&
                                          _minPurchaseController.text ==
                                              amount.toString()
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              )),
                          ChoiceChip(
                            label: Text(
                                _isCustomMinPurchase ? 'Tùy chỉnh' : 'Khác'),
                            selected: _isCustomMinPurchase,
                            onSelected: (selected) {
                              setState(() {
                                _isCustomMinPurchase = selected;
                                if (selected) {
                                  // Clear for custom input
                                  _minPurchaseController.text = '';
                                } else {
                                  // Default to first option
                                  _minPurchaseController.text =
                                      _minPurchaseOptions.first.toString();
                                }
                              });
                            },
                            selectedColor:
                                const Color.fromARGB(221, 202, 159, 159)
                                    .withOpacity(0.7),
                            labelStyle: GoogleFonts.poppins(
                              color: _isCustomMinPurchase
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ],
                      ),
                      if (_isCustomMinPurchase) ...[
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _minPurchaseController,
                          decoration: InputDecoration(
                            hintText: 'Nhập giá trị đơn hàng tối thiểu',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: const Icon(Icons.attach_money),
                          ),
                          style: GoogleFonts.poppins(),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Vui lòng nhập giá trị';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Vui lòng nhập số';
                            }
                            return null;
                          },
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(context),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Ngày hết hạn',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        DateFormat('dd/MM/yyyy').format(_expiryDate),
                        style: GoogleFonts.poppins(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: Text(
                'Mã giảm giá đang hoạt động',
                style: GoogleFonts.poppins(),
              ),
              value: _isActive,
              onChanged: (value) {
                setState(() {
                  _isActive = value;
                });
              },
              activeColor: const Color.fromARGB(221, 202, 159, 159),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _saveVoucher,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(221, 202, 159, 159),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _isEditing ? 'Cập nhật mã giảm giá' : 'Tạo mã giảm giá',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoucherList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('vouchers')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Color.fromARGB(221, 202, 159, 159),
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Lỗi: ${snapshot.error}',
              style: GoogleFonts.poppins(color: Colors.red),
            ),
          );
        }

        final vouchers = snapshot.data?.docs ?? [];

        if (vouchers.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.local_offer_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Chưa có mã giảm giá nào',
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
          itemCount: vouchers.length,
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, index) {
            final voucher = vouchers[index];
            final data = voucher.data() as Map<String, dynamic>;
            final isActive = data['isActive'] ?? false;
            final expiryDate = (data['expiryDate'] as Timestamp).toDate();
            final isExpired = expiryDate.isBefore(DateTime.now());
            final discount = data['discount'] ?? 0;
            final minPurchase = data['minPurchase'] ?? 0;
            final code = data['code'] ?? '';

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: isActive && !isExpired
                      ? Colors.green.shade200
                      : Colors.grey.shade300,
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isActive && !isExpired
                          ? Colors.green.shade50
                          : Colors.grey.shade50,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isActive && !isExpired
                                ? Colors.green.shade100
                                : Colors.grey.shade200,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.percent,
                            color: isActive && !isExpired
                                ? Colors.green.shade700
                                : Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data['title'] ?? 'Không có tiêu đề',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: Colors.grey[800],
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    code,
                                    style: GoogleFonts.poppins(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.5,
                                      color: const Color.fromARGB(
                                          221, 202, 159, 159),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  InkWell(
                                    onTap: () {
                                      Clipboard.setData(
                                          ClipboardData(text: code));
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Đã sao chép mã $code',
                                            style: GoogleFonts.poppins(),
                                          ),
                                          backgroundColor: Colors.green,
                                          duration: const Duration(seconds: 1),
                                        ),
                                      );
                                    },
                                    child: Icon(
                                      Icons.copy,
                                      size: 18,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(221, 202, 159, 159)
                                .withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Giảm $discount%',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color.fromARGB(221, 202, 159, 159),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (data['description'] != null &&
                                  data['description'].toString().isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Text(
                                    data['description'],
                                    style: GoogleFonts.poppins(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.shopping_cart_outlined,
                                    size: 16,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Đơn tối thiểu: ${NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0).format(minPurchase)}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.event_outlined,
                                    size: 16,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Hết hạn: ${DateFormat('dd/MM/yyyy').format(expiryDate)}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      color: isExpired
                                          ? Colors.red
                                          : Colors.grey[700],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  if (isExpired)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.red.shade100,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.circle,
                                    size: 12,
                                    color: isActive && !isExpired
                                        ? Colors.green
                                        : Colors.grey,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    isActive && !isExpired
                                        ? 'Đang hoạt động'
                                        : 'Không hoạt động',
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      color: isActive && !isExpired
                                          ? Colors.green
                                          : Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        // QR Code placeholder
                        InkWell(
                          onTap: () => _showQrDialog(context, code),
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.qr_code_2,
                                  size: 60,
                                  color: Color.fromARGB(221, 202, 159, 159),
                                ),
                                Text(
                                  'Xem QR',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ButtonBar(
                    children: [
                      TextButton.icon(
                        icon: const Icon(Icons.edit),
                        label: const Text('Sửa'),
                        onPressed: () => _editVoucher(voucher),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.blueGrey,
                        ),
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.delete),
                        label: const Text('Xóa'),
                        onPressed: () => _deleteVoucher(voucher.id),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showQrDialog(BuildContext context, String code) async {
    final qrImageKey = GlobalKey();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'QR Code: $code',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              RepaintBoundary(
                key: qrImageKey,
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: QrImageView(
                    data: code,
                    version: QrVersions.auto,
                    size: 200,
                    backgroundColor: Colors.white,
                    errorStateBuilder: (cxt, err) {
                      return const Center(
                        child: Text(
                          "Không thể tạo QR",
                          textAlign: TextAlign.center,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        final boundary = qrImageKey.currentContext
                            ?.findRenderObject() as RenderRepaintBoundary?;
                        if (boundary != null) {
                          final image = await boundary.toImage(pixelRatio: 3.0);
                          final byteData = await image.toByteData(
                              format: ui.ImageByteFormat.png);
                          if (byteData != null) {
                            final bytes = byteData.buffer.asUint8List();
                            final path = await saveQRImage(bytes);

                            if (!mounted) return;

                            await Share.shareXFiles(
                              [XFile(path)],
                              text: 'Mã giảm giá: $code',
                            );
                          }
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Lỗi khi chia sẻ: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.share),
                    label: const Text('Chia sẻ'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(221, 202, 159, 159),
                    ),
                  ),
                  const SizedBox(width: 12),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.close),
                    label: const Text('Đóng'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<String> saveQRImage(Uint8List bytes) async {
    final directory = await getApplicationDocumentsDirectory();
    final path =
        '${directory.path}/qr_code_${DateTime.now().millisecondsSinceEpoch}.png';
    final file = File(path);
    await file.writeAsBytes(bytes);
    return path;
  }
}
