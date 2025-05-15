import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/voucher_service.dart';
import '../../models/voucher_model.dart';
import '../../common/color_extension.dart';
import 'package:intl/intl.dart';

class VoucherManagementView extends StatefulWidget {
  const VoucherManagementView({Key? key}) : super(key: key);

  @override
  State<VoucherManagementView> createState() => _VoucherManagementViewState();
}

class _VoucherManagementViewState extends State<VoucherManagementView> {
  final VoucherService _voucherService = VoucherService();
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _valueController = TextEditingController();
  final _maxDiscountController = TextEditingController();
  final _quantityController = TextEditingController();
  String _selectedType = 'percentage';
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));
  bool _isActive = true;

  @override
  void dispose() {
    _codeController.dispose();
    _valueController.dispose();
    _maxDiscountController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _createVoucher() async {
    if (_formKey.currentState!.validate()) {
      try {
        final success = await _voucherService.createVoucher(
          code: _codeController.text,
          type: _selectedType,
          value: double.parse(_valueController.text),
          maxDiscount: _maxDiscountController.text.isNotEmpty
              ? double.parse(_maxDiscountController.text)
              : null,
          quantity: int.parse(_quantityController.text),
          startDate: _startDate,
          endDate: _endDate,
          isActive: _isActive,
        );

        if (success) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Tạo voucher thành công'),
                backgroundColor: TColor.primary,
              ),
            );
          }
          _clearForm();
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Không thể tạo voucher'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _clearForm() {
    _codeController.clear();
    _valueController.clear();
    _maxDiscountController.clear();
    _quantityController.clear();
    setState(() {
      _selectedType = 'percentage';
      _startDate = DateTime.now();
      _endDate = DateTime.now().add(const Duration(days: 30));
      _isActive = true;
    });
  }

  Future<void> _selectDate(bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Quản lý voucher",
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: TColor.primaryText,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: TColor.primaryText,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Tạo voucher mới",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: TColor.primaryText,
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _codeController,
                        decoration: InputDecoration(
                          labelText: 'Mã voucher',
                          labelStyle: TextStyle(color: TColor.placeholder),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                                color: TColor.placeholder.withOpacity(0.5)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: TColor.primary),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập mã voucher';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedType,
                        decoration: InputDecoration(
                          labelText: 'Loại giảm giá',
                          labelStyle: TextStyle(color: TColor.placeholder),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                                color: TColor.placeholder.withOpacity(0.5)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: TColor.primary),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'percentage',
                            child: Text('Phần trăm'),
                          ),
                          DropdownMenuItem(
                            value: 'fixed',
                            child: Text('Số tiền cố định'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedType = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedType == 'percentage'
                                ? 'Phần trăm giảm giá'
                                : 'Số tiền giảm giá',
                            style: TextStyle(
                              fontSize: 14,
                              color: TColor.placeholder,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (_selectedType == 'percentage')
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                for (int value in [
                                  5,
                                  10,
                                  15,
                                  20,
                                  25,
                                  30,
                                  40,
                                  50,
                                  70
                                ])
                                  ChoiceChip(
                                    label: Text('$value%'),
                                    selected: _valueController.text ==
                                        value.toString(),
                                    onSelected: (selected) {
                                      if (selected) {
                                        setState(() {
                                          _valueController.text =
                                              value.toString();
                                        });
                                      }
                                    },
                                    backgroundColor: Colors.white,
                                    selectedColor:
                                        TColor.primary.withOpacity(0.2),
                                    labelStyle: TextStyle(
                                      color: _valueController.text ==
                                              value.toString()
                                          ? TColor.primary
                                          : TColor.placeholder,
                                      fontWeight: _valueController.text ==
                                              value.toString()
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      side: BorderSide(
                                        color: _valueController.text ==
                                                value.toString()
                                            ? TColor.primary
                                            : TColor.placeholder
                                                .withOpacity(0.3),
                                      ),
                                    ),
                                  ),
                                ChoiceChip(
                                  label: const Text('Khác'),
                                  selected: ![
                                    '5',
                                    '10',
                                    '15',
                                    '20',
                                    '25',
                                    '30',
                                    '40',
                                    '50',
                                    '70'
                                  ].contains(_valueController.text),
                                  onSelected: (selected) {
                                    if (selected) {
                                      // Show dialog for custom value
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text(
                                              'Nhập phần trăm giảm giá'),
                                          content: TextField(
                                            controller: _valueController,
                                            keyboardType: TextInputType.number,
                                            decoration: const InputDecoration(
                                              hintText: 'Ví dụ: 45',
                                              suffix: Text('%'),
                                            ),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              child: const Text('Hủy'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                                setState(() {});
                                              },
                                              child: const Text('Xác nhận'),
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                  },
                                  backgroundColor: Colors.white,
                                  selectedColor:
                                      TColor.primary.withOpacity(0.2),
                                  labelStyle: TextStyle(
                                    color: ![
                                      '5',
                                      '10',
                                      '15',
                                      '20',
                                      '25',
                                      '30',
                                      '40',
                                      '50',
                                      '70'
                                    ].contains(_valueController.text)
                                        ? TColor.primary
                                        : TColor.placeholder,
                                    fontWeight: ![
                                      '5',
                                      '10',
                                      '15',
                                      '20',
                                      '25',
                                      '30',
                                      '40',
                                      '50',
                                      '70'
                                    ].contains(_valueController.text)
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    side: BorderSide(
                                      color: ![
                                        '5',
                                        '10',
                                        '15',
                                        '20',
                                        '25',
                                        '30',
                                        '40',
                                        '50',
                                        '70'
                                      ].contains(_valueController.text)
                                          ? TColor.primary
                                          : TColor.placeholder.withOpacity(0.3),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          else
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                for (int value in [
                                  10000,
                                  20000,
                                  30000,
                                  50000,
                                  100000,
                                  150000,
                                  200000
                                ])
                                  ChoiceChip(
                                    label: Text(
                                        '${NumberFormat.currency(locale: 'vi_VN', symbol: '', decimalDigits: 0).format(value)}đ'),
                                    selected: _valueController.text ==
                                        value.toString(),
                                    onSelected: (selected) {
                                      if (selected) {
                                        setState(() {
                                          _valueController.text =
                                              value.toString();
                                        });
                                      }
                                    },
                                    backgroundColor: Colors.white,
                                    selectedColor:
                                        TColor.primary.withOpacity(0.2),
                                    labelStyle: TextStyle(
                                      color: _valueController.text ==
                                              value.toString()
                                          ? TColor.primary
                                          : TColor.placeholder,
                                      fontWeight: _valueController.text ==
                                              value.toString()
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      side: BorderSide(
                                        color: _valueController.text ==
                                                value.toString()
                                            ? TColor.primary
                                            : TColor.placeholder
                                                .withOpacity(0.3),
                                      ),
                                    ),
                                  ),
                                ChoiceChip(
                                  label: const Text('Khác'),
                                  selected: ![
                                    '10000',
                                    '20000',
                                    '30000',
                                    '50000',
                                    '100000',
                                    '150000',
                                    '200000'
                                  ].contains(_valueController.text),
                                  onSelected: (selected) {
                                    if (selected) {
                                      // Show dialog for custom value
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text(
                                              'Nhập số tiền giảm giá'),
                                          content: TextField(
                                            controller: _valueController,
                                            keyboardType: TextInputType.number,
                                            decoration: const InputDecoration(
                                              hintText: 'Ví dụ: 75000',
                                              suffix: Text('đ'),
                                            ),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              child: const Text('Hủy'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                                setState(() {});
                                              },
                                              child: const Text('Xác nhận'),
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                  },
                                  backgroundColor: Colors.white,
                                  selectedColor:
                                      TColor.primary.withOpacity(0.2),
                                  labelStyle: TextStyle(
                                    color: ![
                                      '10000',
                                      '20000',
                                      '30000',
                                      '50000',
                                      '100000',
                                      '150000',
                                      '200000'
                                    ].contains(_valueController.text)
                                        ? TColor.primary
                                        : TColor.placeholder,
                                    fontWeight: ![
                                      '10000',
                                      '20000',
                                      '30000',
                                      '50000',
                                      '100000',
                                      '150000',
                                      '200000'
                                    ].contains(_valueController.text)
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    side: BorderSide(
                                      color: ![
                                        '10000',
                                        '20000',
                                        '30000',
                                        '50000',
                                        '100000',
                                        '150000',
                                        '200000'
                                      ].contains(_valueController.text)
                                          ? TColor.primary
                                          : TColor.placeholder.withOpacity(0.3),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Giảm giá tối đa (tùy chọn)',
                            style: TextStyle(
                              fontSize: 14,
                              color: TColor.placeholder,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (int value in [
                                50000,
                                100000,
                                200000,
                                300000,
                                500000
                              ])
                                ChoiceChip(
                                  label: Text(
                                      '${NumberFormat.currency(locale: 'vi_VN', symbol: '', decimalDigits: 0).format(value)}đ'),
                                  selected: _maxDiscountController.text ==
                                      value.toString(),
                                  onSelected: (selected) {
                                    if (selected) {
                                      setState(() {
                                        _maxDiscountController.text =
                                            value.toString();
                                      });
                                    }
                                  },
                                  backgroundColor: Colors.white,
                                  selectedColor:
                                      TColor.primary.withOpacity(0.2),
                                  labelStyle: TextStyle(
                                    color: _maxDiscountController.text ==
                                            value.toString()
                                        ? TColor.primary
                                        : TColor.placeholder,
                                    fontWeight: _maxDiscountController.text ==
                                            value.toString()
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    side: BorderSide(
                                      color: _maxDiscountController.text ==
                                              value.toString()
                                          ? TColor.primary
                                          : TColor.placeholder.withOpacity(0.3),
                                    ),
                                  ),
                                ),
                              ChoiceChip(
                                label: const Text('Không giới hạn'),
                                selected: _maxDiscountController.text.isEmpty,
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(() {
                                      _maxDiscountController.clear();
                                    });
                                  }
                                },
                                backgroundColor: Colors.white,
                                selectedColor: TColor.primary.withOpacity(0.2),
                                labelStyle: TextStyle(
                                  color: _maxDiscountController.text.isEmpty
                                      ? TColor.primary
                                      : TColor.placeholder,
                                  fontWeight:
                                      _maxDiscountController.text.isEmpty
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: BorderSide(
                                    color: _maxDiscountController.text.isEmpty
                                        ? TColor.primary
                                        : TColor.placeholder.withOpacity(0.3),
                                  ),
                                ),
                              ),
                              ChoiceChip(
                                label: const Text('Khác'),
                                selected:
                                    _maxDiscountController.text.isNotEmpty &&
                                        ![
                                          '50000',
                                          '100000',
                                          '200000',
                                          '300000',
                                          '500000'
                                        ].contains(_maxDiscountController.text),
                                onSelected: (selected) {
                                  if (selected) {
                                    // Show dialog for custom value
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title:
                                            const Text('Nhập giảm giá tối đa'),
                                        content: TextField(
                                          controller: _maxDiscountController,
                                          keyboardType: TextInputType.number,
                                          decoration: const InputDecoration(
                                            hintText: 'Ví dụ: 150000',
                                            suffix: Text('đ'),
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: const Text('Hủy'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                              setState(() {});
                                            },
                                            child: const Text('Xác nhận'),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                },
                                backgroundColor: Colors.white,
                                selectedColor: TColor.primary.withOpacity(0.2),
                                labelStyle: TextStyle(
                                  color:
                                      _maxDiscountController.text.isNotEmpty &&
                                              ![
                                                '50000',
                                                '100000',
                                                '200000',
                                                '300000',
                                                '500000'
                                              ].contains(
                                                  _maxDiscountController.text)
                                          ? TColor.primary
                                          : TColor.placeholder,
                                  fontWeight:
                                      _maxDiscountController.text.isNotEmpty &&
                                              ![
                                                '50000',
                                                '100000',
                                                '200000',
                                                '300000',
                                                '500000'
                                              ].contains(
                                                  _maxDiscountController.text)
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: BorderSide(
                                    color: _maxDiscountController
                                                .text.isNotEmpty &&
                                            ![
                                              '50000',
                                              '100000',
                                              '200000',
                                              '300000',
                                              '500000'
                                            ].contains(
                                                _maxDiscountController.text)
                                        ? TColor.primary
                                        : TColor.placeholder.withOpacity(0.3),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Số lượng voucher',
                            style: TextStyle(
                              fontSize: 14,
                              color: TColor.placeholder,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color:
                                          TColor.placeholder.withOpacity(0.5)),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    // Minus button
                                    IconButton(
                                      onPressed: () {
                                        final currentValue = int.tryParse(
                                                _quantityController.text) ??
                                            1;
                                        if (currentValue > 1) {
                                          setState(() {
                                            _quantityController.text =
                                                (currentValue - 1).toString();
                                          });
                                        }
                                      },
                                      icon: Icon(
                                        Icons.remove,
                                        color: TColor.primary,
                                      ),
                                      iconSize: 20,
                                    ),
                                    // Quantity display
                                    Container(
                                      constraints:
                                          const BoxConstraints(minWidth: 40),
                                      alignment: Alignment.center,
                                      child: Text(
                                        _quantityController.text.isEmpty
                                            ? '1'
                                            : _quantityController.text,
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    // Plus button
                                    IconButton(
                                      onPressed: () {
                                        final currentValue = int.tryParse(
                                                _quantityController.text) ??
                                            1;
                                        setState(() {
                                          _quantityController.text =
                                              (currentValue + 1).toString();
                                        });
                                      },
                                      icon: Icon(
                                        Icons.add,
                                        color: TColor.primary,
                                      ),
                                      iconSize: 20,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    for (final quantity in [
                                      10,
                                      50,
                                      100,
                                      200,
                                      500
                                    ])
                                      ChoiceChip(
                                        label: Text('$quantity'),
                                        selected: _quantityController.text ==
                                            quantity.toString(),
                                        onSelected: (selected) {
                                          if (selected) {
                                            setState(() {
                                              _quantityController.text =
                                                  quantity.toString();
                                            });
                                          }
                                        },
                                        backgroundColor: Colors.white,
                                        selectedColor:
                                            TColor.primary.withOpacity(0.2),
                                        labelStyle: TextStyle(
                                          color: _quantityController.text ==
                                                  quantity.toString()
                                              ? TColor.primary
                                              : TColor.placeholder,
                                          fontWeight:
                                              _quantityController.text ==
                                                      quantity.toString()
                                                  ? FontWeight.w600
                                                  : FontWeight.normal,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          side: BorderSide(
                                            color: _quantityController.text ==
                                                    quantity.toString()
                                                ? TColor.primary
                                                : TColor.placeholder
                                                    .withOpacity(0.3),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (_quantityController.text.isEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                'Vui lòng nhập số lượng',
                                style: TextStyle(
                                  color: Colors.red[700],
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => _selectDate(true),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 15, horizontal: 12),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color:
                                          TColor.placeholder.withOpacity(0.5)),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Ngày bắt đầu',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: TColor.placeholder,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      _formatDate(_startDate),
                                      style: const TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: InkWell(
                              onTap: () => _selectDate(false),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 15, horizontal: 12),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color:
                                          TColor.placeholder.withOpacity(0.5)),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Ngày kết thúc',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: TColor.placeholder,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      _formatDate(_endDate),
                                      style: const TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: const Text('Kích hoạt'),
                        value: _isActive,
                        activeColor: TColor.primary,
                        contentPadding: EdgeInsets.zero,
                        onChanged: (value) {
                          setState(() {
                            _isActive = value;
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _createVoucher,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: TColor.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Tạo voucher',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Danh sách voucher hiện có",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: TColor.primaryText,
              ),
            ),
            const SizedBox(height: 16),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('vouchers')
                  .orderBy('expiryDate', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text('Đã xảy ra lỗi');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final vouchers = snapshot.data!.docs
                    .map((doc) => Voucher.fromMap({
                          'id': doc.id,
                          ...doc.data() as Map<String, dynamic>,
                        }))
                    .toList();

                if (vouchers.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Icon(
                            Icons.local_offer_outlined,
                            size: 60,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Chưa có voucher nào',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: vouchers.length,
                  itemBuilder: (context, index) {
                    final voucher = vouchers[index];
                    final bool isExpired =
                        DateTime.now().isAfter(voucher.expiryDate);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isExpired
                                ? Colors.grey.withOpacity(0.3)
                                : Colors.transparent,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.local_offer,
                                        color: isExpired
                                            ? Colors.grey
                                            : TColor.primary,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        voucher.code,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: isExpired
                                              ? Colors.grey
                                              : TColor.primaryText,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isExpired
                                          ? Colors.grey[200]
                                          : (voucher.isActive
                                              ? Colors.green[50]
                                              : Colors.red[50]),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      isExpired
                                          ? 'Hết hạn'
                                          : (voucher.isActive
                                              ? 'Đang kích hoạt'
                                              : 'Đã tắt'),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isExpired
                                            ? Colors.grey
                                            : (voucher.isActive
                                                ? Colors.green
                                                : Colors.red),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                voucher.type == 'percentage'
                                    ? 'Giảm ${voucher.value}%'
                                    : 'Giảm ${voucher.value} đ',
                                style: TextStyle(
                                  fontSize: 16,
                                  color:
                                      isExpired ? Colors.grey : Colors.black87,
                                ),
                              ),
                              if (voucher.type == 'percentage' &&
                                  voucher.maxDiscount != null)
                                Text(
                                  'Giảm tối đa: ${voucher.maxDiscount} đ',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isExpired
                                        ? Colors.grey
                                        : Colors.black54,
                                  ),
                                ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'HSD: ${_formatDate(voucher.startDate)} - ${_formatDate(voucher.expiryDate)}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isExpired
                                          ? Colors.grey
                                          : Colors.black54,
                                    ),
                                  ),
                                  Text(
                                    'Còn lại: ${voucher.quantity}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isExpired
                                          ? Colors.grey
                                          : Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
