import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:books_store/models/voucher_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../models/order.dart';
import '../../providers/cart_provider.dart';
import '../../services/notification_service.dart';
import '../../services/order_service.dart';
import '../../services/payment_service.dart';
import '../../services/voucher_service.dart';
import '../order/order_success_screen.dart';

// Payment method type enum
enum PaymentMethodType { cashOnDelivery, online }

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _orderService = OrderService();
  final _voucherService = VoucherService();
  bool _isLoading = false;
  bool _isLoadingVouchers = false;
  bool _isApplyingVoucher = false;
  PaymentMethod? _selectedPaymentMethod;
  PaymentMethodType _selectedPaymentType = PaymentMethodType.cashOnDelivery;
  final double _deliveryFee = 20000.0;
  String? _voucherCode;
  double _discountAmount = 0.0;
  bool _showQrPayment = false;
  String _qrPaymentData = '';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  List<Voucher> _availableVouchers = [];
  Voucher? _selectedVoucher;
  bool _showVoucherSelection = false;
  Timer? _paymentTimer;
  final ValueNotifier<int> _countdown = ValueNotifier<int>(10);

  // Define app color scheme
  static const Color primaryColor = Color(0xFF3A86FF);
  static const Color secondaryColor = Color(0xFF8338EC);
  static const Color accentColor = Color(0xFFFF006E);
  static const Color backgroundColor = Color(0xFFF0F2F5);
  static const Color textPrimaryColor = Color(0xFF212529);
  static const Color textSecondaryColor = Color(0xFF6C757D);
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color successColor = Color(0xFF28A745);

  final List<PaymentMethod> _onlinePaymentMethods = [
    PaymentMethod(
      name: "QR Code Payment",
      icon: "assets/img/qr_code.png",
    ),
  ];

  final PaymentMethod _cashOnDeliveryMethod = PaymentMethod(
    name: "Cash On Delivery",
    icon: "assets/img/cod.png",
  );

  // Thêm biến để lưu ID đơn hàng hiện tại
  String? _currentOrderId;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _animationController.forward();
    _fetchAvailableVouchers();
  }

  Future<void> _fetchAvailableVouchers() async {
    if (mounted) {
      setState(() {
        _isLoadingVouchers = true;
      });
    }

    try {
      final vouchers = await _voucherService.getActiveVouchers();
      if (mounted) {
        setState(() {
          _availableVouchers = vouchers;
          _isLoadingVouchers = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingVouchers = false;
        });
      }
      print('Error fetching vouchers: $e');
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _phoneController.dispose();
    _animationController.dispose();
    _paymentTimer?.cancel();
    _countdown.dispose();
    super.dispose();
  }

  Future<void> _applyVoucher(String code) async {
    setState(() => _isApplyingVoucher = true);

    try {
      final voucher = await _voucherService.getVoucherByCode(code);

      if (voucher == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Mã giảm giá không tồn tại'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.redAccent.withOpacity(0.9),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        );
        setState(() => _isApplyingVoucher = false);
        return;
      }

      if (!voucher.isValid) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                const Text('Mã giảm giá đã hết hạn hoặc đã hết lượt sử dụng'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.redAccent.withOpacity(0.9),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        );
        setState(() => _isApplyingVoucher = false);
        return;
      }

      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      final subtotal = cartProvider.totalAmount;
      final discount = _voucherService.calculateDiscount(voucher, subtotal);

      setState(() {
        _selectedVoucher = voucher;
        _voucherCode = code;
        _discountAmount = discount;
        _isApplyingVoucher = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Áp dụng mã giảm giá thành công: -${NumberFormat.currency(locale: 'vi_VN', symbol: '', decimalDigits: 0).format(discount * 1)}đ'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: successColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi áp dụng mã giảm giá: $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.redAccent.withOpacity(0.9),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
      setState(() => _isApplyingVoucher = false);
    }
  }

  void _selectVoucher(Voucher voucher) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final subtotal = cartProvider.totalAmount;
    final discount = _voucherService.calculateDiscount(voucher, subtotal);

    setState(() {
      _selectedVoucher = voucher;
      _voucherCode = voucher.code;
      _discountAmount = discount;
      _showVoucherSelection = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Áp dụng mã giảm giá thành công: -${NumberFormat.currency(locale: 'vi_VN', symbol: '', decimalDigits: 0).format(discount * 1)}đ'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: successColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  void _generateQRPayment() {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final subtotal = cartProvider.totalAmount;
    final totalAmount = _calculateTotalAmount();

    // Create a QR payment data object
    final paymentData = {
      'merchant': 'Book Store',
      'amount': totalAmount,
      'orderId': _currentOrderId,
      'reference': 'ORDER${DateTime.now().millisecondsSinceEpoch}',
      'timestamp': DateTime.now().toIso8601String(),
    };

    print("QR Payment - OrderID: $_currentOrderId");

    setState(() {
      _qrPaymentData = jsonEncode(paymentData);
      _showQrPayment = true;
    });

    // Reset and start animation when showing QR
    _animationController.reset();
    _animationController.forward();
  }

  double _calculateTotalAmount() {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final subtotal = cartProvider.totalAmount;
    return subtotal + _deliveryFee - _discountAmount;
  }

  // Hợp nhất phương thức tạo đơn hàng và hiển thị QR
  Future<void> _createOrderAndShowQR() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      final subtotal = cartProvider.totalAmount;
      final totalAmount = _calculateTotalAmount();

      // Get actual user ID from Firebase Auth
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      // Set payment method
      final paymentMethod = _selectedPaymentMethod;

      final order = await _orderService.createOrder(
        userId: user.uid,
        items: cartProvider.items,
        totalAmount: totalAmount,
        address: _addressController.text,
        phone: _phoneController.text,
        paymentMethod: paymentMethod,
        deliveryFee: _deliveryFee,
        subtotal: subtotal,
        voucherCode: _voucherCode,
        discountAmount: _discountAmount,
      );

      // Lưu ID đơn hàng mới tạo
      _currentOrderId = order.id;

      // Ghi log để debug
      print("Đã tạo đơn hàng QR với ID: $_currentOrderId");

      // Update voucher usage if voucher was applied
      if (_voucherCode != null) {
        final voucher = await _voucherService.getVoucherByCode(_voucherCode!);
        if (voucher != null) {
          await _voucherService.updateVoucherUsage(voucher.id);
        }
      }

      // Clear cart after successful order
      cartProvider.clear();

      // Create a QR payment data object - Đảm bảo số tiền chính xác
      final formattedAmount =
          NumberFormat.currency(locale: 'vi_VN', symbol: '', decimalDigits: 0)
              .format(totalAmount);

      final paymentData = {
        'merchant': 'Book Store',
        'amount': totalAmount,
        'displayAmount': '$formattedAmount đ', // Thêm số tiền hiển thị đúng
        'orderId': _currentOrderId, // Lưu orderId vào QR
        'reference': 'ORDER${DateTime.now().millisecondsSinceEpoch}',
        'timestamp': DateTime.now().toIso8601String(),
      };

      if (mounted) {
        setState(() {
          _qrPaymentData = jsonEncode(paymentData);
          _showQrPayment = true;
          _isLoading = false;
        });
      }

      // Reset and start animation when showing QR
      _animationController.reset();
      _animationController.forward();
    } catch (e) {
      if (mounted) {
        print("Lỗi khi tạo đơn hàng QR: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.redAccent.withOpacity(0.9),
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Phương thức xử lý hành động đặt hàng
  Future<void> _handleOrderAction() async {
    // Kiểm tra validate form
    if (!_formKey.currentState!.validate()) return;

    if (_selectedPaymentType == PaymentMethodType.online &&
        _selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Vui lòng chọn phương thức thanh toán online'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.redAccent.withOpacity(0.9),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
      return;
    }

    if (_selectedPaymentType == PaymentMethodType.cashOnDelivery) {
      // Thanh toán COD - sử dụng phương thức cũ
      _placeOrder();
    } else if (_selectedPaymentType == PaymentMethodType.online) {
      // Thanh toán online - sử dụng phương thức mới hợp nhất
      _createOrderAndShowQR();
    }
  }

  // Phương thức đặt hàng COD
  Future<void> _placeOrder() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      final subtotal = cartProvider.totalAmount;
      final totalAmount = _calculateTotalAmount();

      // Get actual user ID from Firebase Auth
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      // Set payment method for COD
      final paymentMethod = _cashOnDeliveryMethod;

      final order = await _orderService.createOrder(
        userId: user.uid,
        items: cartProvider.items,
        totalAmount: totalAmount,
        address: _addressController.text,
        phone: _phoneController.text,
        paymentMethod: paymentMethod,
        deliveryFee: _deliveryFee,
        subtotal: subtotal,
        voucherCode: _voucherCode,
        discountAmount: _discountAmount,
      );

      // Lưu ID đơn hàng mới tạo
      _currentOrderId = order.id;

      // Ghi log để debug
      print("Đã tạo đơn hàng COD với ID: $_currentOrderId");

      // Update voucher usage if voucher was applied
      if (_voucherCode != null) {
        final voucher = await _voucherService.getVoucherByCode(_voucherCode!);
        if (voucher != null) {
          await _voucherService.updateVoucherUsage(voucher.id);
        }
      }

      // Clear cart after successful order
      cartProvider.clear();

      // Tạo thông báo đơn hàng mới
      final notificationService = NotificationService();
      notificationService.createNotification(
        userId: user.uid,
        title: 'Đơn hàng mới',
        message: 'Đơn hàng #${order.id} của bạn đã được tạo thành công.',
        type: 'order',
        orderId: order.id,
        additionalData: {
          'status': 'pending',
          'route': 'order_detail',
          'routeParams': {'orderId': order.id},
        },
      );

      // Navigate to success screen
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => OrderSuccessScreen(orderId: order.id),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        print("Lỗi khi tạo đơn hàng COD: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.redAccent.withOpacity(0.9),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final subtotal = cartProvider.totalAmount;
    final totalAmount = _calculateTotalAmount();

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'Checkout',
          style: GoogleFonts.nunito(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: textPrimaryColor,
          ),
        ),
        backgroundColor: Colors.white.withOpacity(0.95),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textPrimaryColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.transparent),
          ),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: _showQrPayment
            ? _buildQRPaymentView(totalAmount)
            : _buildCheckoutForm(subtotal, totalAmount),
      ),
    );
  }

  Widget _buildQRPaymentView(double totalAmount) {
    // Reset countdown to 10 seconds
    _countdown.value = 10;

    // Cancel any existing timer
    _paymentTimer?.cancel();

    // Start countdown timer
    _paymentTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown.value > 0) {
        _countdown.value--;
      } else {
        // Cancel the timer when countdown reaches zero
        _paymentTimer?.cancel();

        if (_showQrPayment && mounted) {
          // Process the payment immediately without waiting
          _processQRPayment();
        }
      }
    });

    // Lấy số tiền hiển thị từ dữ liệu QR nếu có
    String displayAmount = '';
    try {
      final qrData = jsonDecode(_qrPaymentData);
      if (qrData.containsKey('displayAmount')) {
        displayAmount = qrData['displayAmount'];
      } else {
        // Nếu không có, định dạng số tiền từ tổng số
        displayAmount =
            '${NumberFormat.currency(locale: 'vi_VN', symbol: '', decimalDigits: 0).format(totalAmount)}đ';
      }
    } catch (e) {
      // Nếu có lỗi, sử dụng định dạng mặc định
      displayAmount =
          '${NumberFormat.currency(locale: 'vi_VN', symbol: '', decimalDigits: 0).format(totalAmount)}đ';
    }

    return Column(
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Quét mã QR để thanh toán',
                style: GoogleFonts.nunito(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: textPrimaryColor,
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: primaryColor.withOpacity(0.3), width: 2),
                          color: Colors.white,
                        ),
                        child: QrImageView(
                          data: _qrPaymentData,
                          version: QrVersions.auto,
                          size: 220,
                          backgroundColor: Colors.white,
                          eyeStyle: const QrEyeStyle(
                            eyeShape: QrEyeShape.square,
                            color: primaryColor,
                          ),
                          dataModuleStyle: const QrDataModuleStyle(
                            dataModuleShape: QrDataModuleShape.square,
                            color: primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Tổng thanh toán',
                        style: GoogleFonts.nunito(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: textSecondaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        displayAmount,
                        style: GoogleFonts.nunito(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ValueListenableBuilder<int>(
                          valueListenable: _countdown,
                          builder: (context, seconds, _) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.timer_outlined,
                                    size: 18,
                                    color: seconds <= 3
                                        ? Colors.red
                                        : textSecondaryColor),
                                const SizedBox(width: 8),
                                Text(
                                  'Tự động thanh toán sau: $seconds giây',
                                  style: GoogleFonts.nunito(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: seconds <= 3
                                        ? Colors.red
                                        : textSecondaryColor,
                                  ),
                                ),
                              ],
                            );
                          }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    // Cancel timer when going back
                    _paymentTimer?.cancel();
                    setState(() {
                      _showQrPayment = false;
                    });
                    _animationController.reset();
                    _animationController.forward();
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    side: const BorderSide(color: primaryColor, width: 1.5),
                  ),
                  child: Text(
                    'Quay lại',
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: primaryColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          // Cancel timer when clicking Paid
                          _paymentTimer?.cancel();
                          _processQRPayment();
                        },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade300,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Đã thanh toán',
                          style: GoogleFonts.nunito(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Helper method to process QR payment and navigate to success page
  void _processQRPayment() {
    if (_isLoading) return; // Prevent multiple submissions

    setState(() {
      _isLoading = true;
    });

    try {
      // Lấy user hiện tại
      final user = FirebaseAuth.instance.currentUser;

      // Nếu _currentOrderId bị null, thử lấy từ dữ liệu QR
      if (_currentOrderId == null && _qrPaymentData.isNotEmpty) {
        try {
          final Map<String, dynamic> qrData = jsonDecode(_qrPaymentData);
          if (qrData.containsKey('orderId')) {
            _currentOrderId = qrData['orderId'];
            print('Đã khôi phục orderId từ dữ liệu QR: $_currentOrderId');
          }
        } catch (e) {
          print('Lỗi khi đọc dữ liệu QR: $e');
        }
      }

      if (user != null && _currentOrderId != null) {
        // Tạo thông báo thanh toán thành công với route tới trang order
        final notificationService = NotificationService();
        notificationService.createNotification(
          userId: user.uid,
          title: 'Thanh toán thành công',
          message:
              'Đơn hàng #$_currentOrderId của bạn đã được thanh toán thành công.',
          type: 'order',
          orderId: _currentOrderId,
          additionalData: {
            'status': 'ok',
            'route': 'order_detail',
            'routeParams': {'orderId': _currentOrderId},
          },
        );

        // In ra log để debug
        print(
            'Đã tạo thông báo thanh toán thành công cho đơn hàng: $_currentOrderId');

        // Cập nhật trạng thái đơn hàng sang đã thanh toán
        final paymentService = PaymentService();
        paymentService.updatePaymentStatus(_currentOrderId!, 'paid');
      } else {
        print(
            'Lỗi: user hoặc orderId null - user: ${user?.uid}, orderId: $_currentOrderId');
      }

      // Chuyển đến trang thành công
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => OrderSuccessScreen(orderId: _currentOrderId ?? ''),
          ),
        );
      }
    } catch (e) {
      // Xử lý lỗi nếu có
      print('Lỗi khi xử lý thanh toán QR: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  Widget _buildCheckoutForm(double subtotal, double totalAmount) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeading(title: 'Thông tin giao hàng'),
            const SizedBox(height: 20),
            InfoContainer(
              child: Column(
                children: [
                  _buildInputField(
                    controller: _addressController,
                    label: 'Địa chỉ giao hàng',
                    icon: Icons.location_on_outlined,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập địa chỉ giao hàng';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildInputField(
                    controller: _phoneController,
                    label: 'Số điện thoại',
                    icon: Icons.phone_outlined,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập số điện thoại';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Voucher Input
            SectionHeading(title: 'Mã giảm giá'),
            const SizedBox(height: 20),
            InfoContainer(
              child: _selectedVoucher != null
                  ? _buildSelectedVoucherView()
                  : Row(
                      children: [
                        Icon(
                          Icons.discount_outlined,
                          color: primaryColor,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _showVoucherSelection = true;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Text(
                                'Chọn hoặc nhập mã giảm giá',
                                style: GoogleFonts.nunito(
                                  color: textSecondaryColor,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _showVoucherSelection = true;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 24,
                            ),
                            backgroundColor: primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Chọn',
                            style: GoogleFonts.nunito(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
            if (_showVoucherSelection) _buildVoucherSelectionView(),
            const SizedBox(height: 32),

            SectionHeading(title: 'Phương thức thanh toán'),
            const SizedBox(height: 20),

            // Payment type selection (Online or Cash on Delivery)
            Row(
              children: [
                Expanded(
                  child: _buildPaymentTypeOption(
                    type: PaymentMethodType.cashOnDelivery,
                    title: "Thanh toán khi nhận hàng",
                    icon: Icons.home_outlined,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildPaymentTypeOption(
                    type: PaymentMethodType.online,
                    title: "Thanh toán online",
                    icon: Icons.credit_card_outlined,
                  ),
                ),
              ],
            ),

            // Show online payment methods if online payment type is selected
            if (_selectedPaymentType == PaymentMethodType.online) ...[
              const SizedBox(height: 20),
              AnimatedOpacity(
                opacity: _selectedPaymentType == PaymentMethodType.online
                    ? 1.0
                    : 0.0,
                duration: const Duration(milliseconds: 300),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _onlinePaymentMethods.length,
                  itemBuilder: (context, index) {
                    final method = _onlinePaymentMethods[index];
                    final isSelected =
                        _selectedPaymentMethod?.name == method.name;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: cardColor,
                        border: Border.all(
                          color: isSelected ? primaryColor : Colors.transparent,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _selectedPaymentMethod = method;
                            });
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 16),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.grey.shade200,
                                      width: 1,
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(8),
                                  child: Image.asset(
                                    method.icon,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(
                                        method.name == "QR Code Payment"
                                            ? Icons.qr_code
                                            : Icons.payment,
                                        size: 28,
                                        color: primaryColor,
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  method.name,
                                  style: GoogleFonts.nunito(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: textPrimaryColor,
                                  ),
                                ),
                                const Spacer(),
                                if (isSelected)
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: primaryColor,
                                    ),
                                    child: const Icon(
                                      Icons.check,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],

            const SizedBox(height: 32),
            SectionHeading(title: 'Tổng đơn hàng'),
            const SizedBox(height: 20),
            InfoContainer(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildOrderSummaryRow(
                    title: 'Tạm tính',
                    value:
                        '${NumberFormat.currency(locale: 'vi_VN', symbol: '', decimalDigits: 0).format(subtotal * 1)}đ',
                  ),
                  const SizedBox(height: 12),
                  _buildOrderSummaryRow(
                    title: 'Phí giao hàng',
                    value:
                        '${NumberFormat.currency(locale: 'vi_VN', symbol: '', decimalDigits: 0).format(_deliveryFee)}đ',
                  ),
                  if (_discountAmount > 0) ...[
                    const SizedBox(height: 12),
                    _buildOrderSummaryRow(
                      title:
                          'Giảm giá${_voucherCode != null ? ' ($_voucherCode)' : ''}',
                      value:
                          '-${NumberFormat.currency(locale: 'vi_VN', symbol: '', decimalDigits: 0).format(_discountAmount * 1)}đ',
                      valueColor: successColor,
                    ),
                  ],
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(height: 1, color: Color(0xFFE9ECEF)),
                  ),
                  _buildOrderSummaryRow(
                    title: 'Tổng cộng',
                    titleStyle: GoogleFonts.nunito(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: textPrimaryColor,
                    ),
                    value:
                        '${NumberFormat.currency(locale: 'vi_VN', symbol: '', decimalDigits: 0).format(totalAmount * 1)}đ',
                    valueStyle: GoogleFonts.nunito(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _handleOrderAction,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                backgroundColor: primaryColor,
                disabledBackgroundColor: Colors.grey.shade300,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                minimumSize: const Size(double.infinity, 56),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _selectedPaymentType == PaymentMethodType.online &&
                                  _selectedPaymentMethod?.name ==
                                      "QR Code Payment"
                              ? 'Tạo mã QR thanh toán'
                              : 'Đặt hàng ngay',
                          style: GoogleFonts.nunito(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, color: primaryColor, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: TextFormField(
            controller: controller,
            validator: validator,
            style: GoogleFonts.nunito(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: textPrimaryColor,
            ),
            decoration: InputDecoration(
              labelText: label,
              labelStyle: GoogleFonts.nunito(
                color: textSecondaryColor,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderSummaryRow({
    required String title,
    required String value,
    TextStyle? titleStyle,
    TextStyle? valueStyle,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: titleStyle ??
              GoogleFonts.nunito(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: textSecondaryColor,
              ),
        ),
        Text(
          value,
          style: valueStyle ??
              GoogleFonts.nunito(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: valueColor ?? textPrimaryColor,
              ),
        ),
      ],
    );
  }

  Widget _buildPaymentTypeOption({
    required PaymentMethodType type,
    required String title,
    required IconData icon,
  }) {
    final isSelected = _selectedPaymentType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentType = type;
          // Reset selected payment method when switching types
          if (type == PaymentMethodType.cashOnDelivery) {
            _selectedPaymentMethod = null;
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor.withOpacity(0.1) : cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? primaryColor : Colors.grey.shade300,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? primaryColor : textSecondaryColor,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isSelected ? primaryColor : textPrimaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedVoucherView() {
    return Row(
      children: [
        Icon(
          Icons.discount_outlined,
          color: primaryColor,
          size: 24,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _selectedVoucher!.code,
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: textPrimaryColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _getVoucherDescription(_selectedVoucher!),
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: successColor,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close, color: textSecondaryColor),
          onPressed: () {
            setState(() {
              _selectedVoucher = null;
              _voucherCode = null;
              _discountAmount = 0.0;
            });
          },
        ),
      ],
    );
  }

  String _getVoucherDescription(Voucher voucher) {
    if (voucher.type == 'percentage') {
      return 'Giảm ${voucher.value.toInt()}% (tối đa ${voucher.maxDiscount != null ? "${NumberFormat.currency(locale: 'vi_VN', symbol: '', decimalDigits: 0).format(voucher.maxDiscount! * 1)}đ" : "không giới hạn"})';
    } else if (voucher.type == 'fixed') {
      return 'Giảm ${NumberFormat.currency(locale: 'vi_VN', symbol: '', decimalDigits: 0).format(voucher.value * 1)}đ';
    } else if (voucher.type == 'free_shipping') {
      return 'Miễn phí giao hàng';
    } else {
      return 'Khuyến mãi đặc biệt';
    }
  }

  Widget _buildVoucherSelectionView() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(top: 12),
      child: InfoContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Mã giảm giá có sẵn',
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: textPrimaryColor,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: textSecondaryColor),
                  onPressed: () {
                    setState(() {
                      _showVoucherSelection = false;
                    });
                  },
                ),
              ],
            ),
            const Divider(),
            if (_isLoadingVouchers)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_availableVouchers.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Không có mã giảm giá nào',
                    style: GoogleFonts.nunito(
                      color: textSecondaryColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              )
            else
              Column(
                children: [
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _availableVouchers.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final voucher = _availableVouchers[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.discount_outlined,
                            color: primaryColor,
                          ),
                        ),
                        title: Text(
                          voucher.code,
                          style: GoogleFonts.nunito(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: textPrimaryColor,
                          ),
                        ),
                        subtitle: Text(
                          _getVoucherDescription(voucher),
                          style: GoogleFonts.nunito(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: successColor,
                          ),
                        ),
                        trailing: OutlinedButton(
                          onPressed: () => _selectVoucher(voucher),
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            side: const BorderSide(color: primaryColor),
                          ),
                          child: Text(
                            'Áp dụng',
                            style: GoogleFonts.nunito(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: primaryColor,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            const SizedBox(height: 8),
            const Divider(),
            Text(
              'Nhập mã giảm giá',
              style: GoogleFonts.nunito(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: textPrimaryColor,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Nhập mã giảm giá',
                      hintStyle: GoogleFonts.nunito(
                        color: textSecondaryColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                    style: GoogleFonts.nunito(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: textPrimaryColor,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _voucherCode = value.isEmpty ? null : value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isApplyingVoucher || _voucherCode == null
                      ? null
                      : () => _applyVoucher(_voucherCode!),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 24,
                    ),
                    backgroundColor: primaryColor,
                    disabledBackgroundColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isApplyingVoucher
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Áp dụng',
                          style: GoogleFonts.nunito(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class InfoContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;

  const InfoContainer({
    super.key,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: _CheckoutScreenState.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 2,
          ),
        ],
      ),
      padding: padding ?? const EdgeInsets.all(16),
      child: child,
    );
  }
}

class SectionHeading extends StatelessWidget {
  final String title;

  const SectionHeading({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.nunito(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: _CheckoutScreenState.textPrimaryColor,
      ),
    );
  }
}
