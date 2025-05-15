import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CheckoutService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> fetchUserAddress() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final userDoc =
            await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists && userDoc.data()!.containsKey('address')) {
          return userDoc.data()!['address'];
        }
      }
      return "No address found";
    } catch (e) {
       return "Error loading address";
    }
  }

  Future<void> processPayment({
    required double totalAmount,
    required double subtotal,
    required double deliveryCost,
    required List cartDetails,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception("User not logged in");

      // Create order in Firestore
      await _firestore.collection('orders').add({
        'userId': user.uid,
        'totalAmount': totalAmount,
        'subtotal': subtotal,
        'deliveryCost': deliveryCost,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'paymentMethod': cartDetails[0]['name'],
      });
    } catch (e) {
       rethrow;
    }
  }
}
