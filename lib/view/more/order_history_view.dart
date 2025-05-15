// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:food_delivery/services/order_history_service.dart';
// import 'package:intl/intl.dart';

// class OrderHistoryView extends StatelessWidget {
//   final OrderHistoryService _orderService = OrderHistoryService();

//   Widget _buildPaymentMethodIcon(String? icon) {
//     if (icon == null || icon.isEmpty) {
//       return const Icon(Icons.payment, size: 40, color: Colors.grey);
//     }

//     return Image.asset(
//       icon,
//       width: 40,
//       height: 40,
//       fit: BoxFit.contain,
//       errorBuilder: (context, error, stackTrace) {
//         return const Icon(Icons.payment, size: 40, color: Colors.grey);
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Order History'),
//         backgroundColor: Theme.of(context).focusColor,
//         centerTitle: true,
//         elevation: 1,
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: _orderService.getUserOrdersStream(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           if (snapshot.hasError) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Icon(Icons.error_outline, size: 60, color: Colors.red),
//                   const SizedBox(height: 16),
//                   Text('Error: ${snapshot.error}'),
//                 ],
//               ),
//             );
//           }

//           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: const [
//                   Icon(Icons.receipt_long_outlined,
//                       size: 60, color: Colors.grey),
//                   SizedBox(height: 16),
//                   Text(
//                     'No orders found',
//                     style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w500,
//                         color: Colors.grey),
//                   ),
//                 ],
//               ),
//             );
//           }

//           return ListView.builder(
//             padding: const EdgeInsets.all(16),
//             itemCount: snapshot.data!.docs.length,
//             itemBuilder: (context, index) {
//               var order =
//                   snapshot.data!.docs[index].data() as Map<String, dynamic>;

//               return Card(
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12)),
//                 elevation: 3,
//                 margin: const EdgeInsets.symmetric(vertical: 8),
//                 child: Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           _buildPaymentMethodIcon(order['icon']?.toString()),
//                           const SizedBox(width: 12),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   order['userName']?.toString() ?? 'N/A',
//                                   style: const TextStyle(
//                                     fontSize: 18,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 4),
//                                 Text(
//                                   _orderService
//                                       .formatDateTime(order['timestamp']),
//                                   style: TextStyle(
//                                     color: Colors.grey[600],
//                                     fontSize: 14,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                       const Divider(height: 24, thickness: 1.2),
//                       _buildOrderDetail('Delivery Fee:',
//                           _orderService.formatCurrency(order['deliveryCost'])),
//                       _buildOrderDetail('Subtotal:',
//                           _orderService.formatCurrency(order['subtotal'])),
//                       _buildOrderDetail(
//                         'Total Amount:',
//                         _orderService.formatCurrency(order['totalAmount']),
//                         isTotal: true,
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildOrderDetail(String label, String value, {bool isTotal = false}) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             label,
//             style: TextStyle(
//               fontSize: isTotal ? 16 : 14,
//               fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
//             ),
//           ),
//           Text(
//             value,
//             style: TextStyle(
//               fontSize: isTotal ? 16 : 14,
//               fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
//               color: isTotal ? Colors.red : Colors.black87,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
