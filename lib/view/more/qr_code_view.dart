import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'dart:ui';
import 'package:path_provider/path_provider.dart';
import 'dart:typed_data';
import 'package:flutter/rendering.dart';
import '../../common/color_extension.dart';

class QRCodeView extends StatefulWidget {
  const QRCodeView({Key? key}) : super(key: key);

  @override
  State<QRCodeView> createState() => _QRCodeViewState();
}

class _QRCodeViewState extends State<QRCodeView> {
  final TextEditingController _textController = TextEditingController();
  final GlobalKey _qrKey = GlobalKey();
  String _qrData = 'https://example.com';
  String _selectedType = 'Liên kết';
  bool _isGenerating = false;

  final List<String> _types = [
    'Liên kết',
    'Văn bản',
    'Email',
    'Số điện thoại',
    'Thông tin WiFi',
  ];

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _generateQRCode() {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập nội dung')),
      );
      return;
    }

    String formattedData = text;

    // Format data based on type
    switch (_selectedType) {
      case 'Email':
        if (!text.contains('@')) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Email không hợp lệ')),
          );
          return;
        }
        formattedData = 'mailto:$text';
        break;
      case 'Số điện thoại':
        formattedData = 'tel:$text';
        break;
      case 'Thông tin WiFi':
        final parts = text.split(',');
        if (parts.length < 2) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Định dạng WiFi: Tên mạng, Mật khẩu')),
          );
          return;
        }
        final ssid = parts[0].trim();
        final password = parts[1].trim();
        formattedData = 'WIFI:S:$ssid;T:WPA;P:$password;;';
        break;
      case 'Liên kết':
        if (!text.startsWith('http://') && !text.startsWith('https://')) {
          formattedData = 'https://$text';
        }
        break;
    }

    setState(() {
      _qrData = formattedData;
    });
  }

  Future<void> _shareQRCode() async {
    setState(() {
      _isGenerating = true;
    });

    try {
      // Capture QR code image
      RenderRepaintBoundary boundary =
          _qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData =
          await image.toByteData(format: ImageByteFormat.png);

      if (byteData != null) {
        final Uint8List pngBytes = byteData.buffer.asUint8List();

        // Save image temporarily
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/qrcode.png');
        await file.writeAsBytes(pngBytes);

        // Share the image
        await Share.shareXFiles(
          [XFile(file.path)],
          text: 'Chia sẻ mã QR từ ứng dụng',
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi chia sẻ: $e')),
      );
    } finally {
      setState(() {
        _isGenerating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Tạo mã QR",
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
              "Loại nội dung",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: TColor.primaryText,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _types.contains(_selectedType)
                      ? _selectedType
                      : _types.first,
                  isExpanded: true,
                  items: _types.map((String type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedType = newValue;
                      });
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Nội dung",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: TColor.primaryText,
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: _getHintText(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: TColor.primary, width: 2),
                ),
              ),
              maxLines: _selectedType == 'Văn bản' ? 3 : 1,
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _generateQRCode,
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Tạo mã QR',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: RepaintBoundary(
                  key: _qrKey,
                  child: QrImageView(
                    data: _qrData,
                    version: QrVersions.auto,
                    size: 200,
                    backgroundColor: Colors.white,
                    errorStateBuilder: (context, error) {
                      return Center(
                        child: Text(
                          'Lỗi khi tạo mã QR',
                          style: TextStyle(color: TColor.primaryText),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.share),
                label: Text(
                  'Chia sẻ mã QR',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onPressed: _isGenerating ? null : _shareQRCode,
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            if (_isGenerating)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              ),
            const SizedBox(height: 15),
            Center(
              child: Text(
                'Tạo và chia sẻ mã QR cho bạn bè',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: TColor.secondaryText,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getHintText() {
    switch (_selectedType) {
      case 'Liên kết':
        return 'Nhập URL (ví dụ: example.com)';
      case 'Email':
        return 'Nhập địa chỉ email';
      case 'Số điện thoại':
        return 'Nhập số điện thoại';
      case 'Thông tin WiFi':
        return 'Nhập theo định dạng: Tên mạng, Mật khẩu';
      default:
        return 'Nhập nội dung';
    }
  }
}
