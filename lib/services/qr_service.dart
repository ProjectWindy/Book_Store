import 'package:qr_flutter/qr_flutter.dart';
 import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class QRService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
 

  static Widget generateQRWidget(String data, {double size = 200}) {
    return QrImageView(
      data: data,
      size: size,
      backgroundColor: Colors.white,
    );
  }

  // New method to generate QR code for a book
  Future<String> generateBookQR(String bookId) async {
    try {
      final bookDoc = await _firestore.collection('books').doc(bookId).get();
      if (!bookDoc.exists) {
        return '';
      }

      final bookData = bookDoc.data() as Map<String, dynamic>;
      final qrData = {
        'bookId': bookId,
        'title': bookData['title'],
        'price': bookData['price'],
        'timestamp': DateTime.now().toIso8601String(),
      };

      return qrData.toString();
    } catch (e) {
       return '';
    }
  }

  // New method to validate scanned QR code
  Future<Map<String, dynamic>?> validateQR(String qrData) async {
    try {
      final data = Map<String, dynamic>.from(qrData as Map);
      final bookId = data['bookId'];

      if (bookId == null) {
        return null;
      }

      final bookDoc = await _firestore.collection('books').doc(bookId).get();
      if (!bookDoc.exists) {
        return null;
      }

      return {
        'bookId': bookId,
        'title': bookDoc.data()?['title'],
        'price': bookDoc.data()?['price'],
        'isValid': true,
      };
    } catch (e) {
       return null;
    }
  }
}
