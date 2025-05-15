// import 'package:books_store/common/color_extension.dart';
// import 'package:books_store/common_widget/round_button.dart';
// import 'package:books_store/services/cart.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:books_store/view/more/checkout_view.dart';

// class MyOrderView extends StatelessWidget {
//   const MyOrderView({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final cart = Provider.of<Cart>(context);

//     double subtotal = cart.getTotal();
//     double deliveryCost = 2.0;
//     double totalAmount = subtotal + deliveryCost;

//     return Scaffold(
//       backgroundColor: TColor.white,
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(vertical: 20),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const SizedBox(height: 46),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 15),
//                 child: Row(
//                   children: [
//                     IconButton(
//                       onPressed: () {
//                         Navigator.pop(context);
//                       },
//                       icon: Image.asset("assets/img/btn_back.png",
//                           width: 20, height: 20),
//                     ),
//                     const SizedBox(width: 8),
//                     Expanded(
//                       child: Text(
//                         "My Order",
//                         style: TextStyle(
//                           color: TColor.primaryText,
//                           fontSize: 20,
//                           fontWeight: FontWeight.w800,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               if (cart.items.isEmpty) ...[
//                 Padding(
//                   padding: const EdgeInsets.all(25),
//                   child: Center(
//                     child: Text(
//                       "Your cart is empty.",
//                       style: TextStyle(
//                         color: TColor.primaryText,
//                         fontSize: 18,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),
//                 ),
//               ] else ...[
//                 Padding(
//                   padding:
//                       const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
//                   child: Row(
//                     children: [
//                       ClipRRect(
//                         borderRadius: BorderRadius.circular(15),
//                         child: Image.asset(
//                           "assets/img/shop_logo.png",
//                           width: 80,
//                           height: 80,
//                           fit: BoxFit.cover,
//                         ),
//                       ),
//                       const SizedBox(width: 8),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               "King Burgers",
//                               style: TextStyle(
//                                 color: TColor.primaryText,
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.w700,
//                               ),
//                             ),
//                             const SizedBox(height: 4),
//                             Row(
//                               children: [
//                                 Image.asset("assets/img/rate.png",
//                                     width: 10, height: 10),
//                                 const SizedBox(width: 4),
//                                 Text("4.9",
//                                     style: TextStyle(
//                                         color: TColor.primary, fontSize: 12)),
//                                 const SizedBox(width: 8),
//                                 Text("(124 Ratings)",
//                                     style: TextStyle(
//                                         color: TColor.secondaryText,
//                                         fontSize: 12)),
//                               ],
//                             ),
//                             const SizedBox(height: 4),
//                             Row(
//                               children: [
//                                 Text("Burger",
//                                     style: TextStyle(
//                                         color: TColor.secondaryText,
//                                         fontSize: 12)),
//                                 Text(" . ",
//                                     style: TextStyle(
//                                         color: TColor.primary, fontSize: 12)),
//                                 Text("Western Food",
//                                     style: TextStyle(
//                                         color: TColor.secondaryText,
//                                         fontSize: 12)),
//                               ],
//                             ),
//                             const SizedBox(height: 4),
//                             Row(
//                               children: [
//                                 Image.asset("assets/img/location-pin.png",
//                                     width: 13, height: 13),
//                                 const SizedBox(width: 4),
//                                 Expanded(
//                                   child: Text(
//                                     "No 03, 4th Lane, Newyork",
//                                     style: TextStyle(
//                                         color: TColor.secondaryText,
//                                         fontSize: 12),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 Container(
//                   decoration: BoxDecoration(color: TColor.textfield),
//                   child: ListView.separated(
//                     physics: const NeverScrollableScrollPhysics(),
//                     shrinkWrap: true,
//                     padding: EdgeInsets.zero,
//                     itemCount: cart.items.length,
//                     separatorBuilder: (context, index) => Divider(
//                       indent: 25,
//                       endIndent: 25,
//                       color: TColor.secondaryText.withOpacity(0.5),
//                       height: 1,
//                     ),
//                     itemBuilder: (context, index) {
//                       var cObj = cart.items[index];  
//                       return Container(
//                         padding: const EdgeInsets.symmetric(
//                             vertical: 15, horizontal: 25),
//                         child: Row(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Expanded(
//                               child: Text(
//                                 "${cObj["name"] ?? "Unknown Item"} x${cObj["qty"] ?? 1}",
//                                 style: TextStyle(
//                                     color: TColor.primaryText,
//                                     fontSize: 13,
//                                     fontWeight: FontWeight.w500),
//                               ),
//                             ),
//                             const SizedBox(width: 15),
//                             Text(
//                               "\$${cObj["price"]?.toString() ?? "0"}",
//                               style: TextStyle(
//                                   color: TColor.primaryText,
//                                   fontSize: 13,
//                                   fontWeight: FontWeight.w700),
//                             ),
//                           ],
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 25),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             "Delivery Instructions",
//                             style: TextStyle(
//                                 color: TColor.primaryText,
//                                 fontSize: 13,
//                                 fontWeight: FontWeight.w700),
//                           ),
//                           // TextButton.icon(
//                           //   onPressed: () {},
//                           //   icon: Icon(Icons.add, color: TColor.primary),
//                           //   label: Text(
//                           //     "Add Notes",
//                           //     style: TextStyle(
//                           //         color: TColor.primary,
//                           //         fontSize: 13,
//                           //         fontWeight: FontWeight.w500),
//                           //   ),
//                           // ),
//                         ],
//                       ),
//                       Divider(
//                           color: TColor.secondaryText.withOpacity(0.5),
//                           height: 1),
//                       const SizedBox(height: 15),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             "Sub Total",
//                             style: TextStyle(
//                                 color: TColor.primaryText,
//                                 fontSize: 13,
//                                 fontWeight: FontWeight.w700),
//                           ),
//                           Text(
//                             "\$${subtotal.toStringAsFixed(2)}",
//                             style: TextStyle(
//                                 color: TColor.primary,
//                                 fontSize: 13,
//                                 fontWeight: FontWeight.w700),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 8),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             "Delivery Cost",
//                             style: TextStyle(
//                                 color: TColor.primaryText,
//                                 fontSize: 13,
//                                 fontWeight: FontWeight.w700),
//                           ),
//                           Text(
//                             "\$${deliveryCost.toStringAsFixed(2)}",
//                             style: TextStyle(
//                                 color: TColor.primary,
//                                 fontSize: 13,
//                                 fontWeight: FontWeight.w700),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 15),
//                       Divider(
//                           color: TColor.secondaryText.withOpacity(0.5),
//                           height: 1),
//                       const SizedBox(height: 15),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             "Total",
//                             style: TextStyle(
//                                 color: TColor.primaryText,
//                                 fontSize: 13,
//                                 fontWeight: FontWeight.w700),
//                           ),
//                           Text(
//                             "\$${totalAmount.toStringAsFixed(2)}",
//                             style: TextStyle(
//                                 color: TColor.primary,
//                                 fontSize: 22,
//                                 fontWeight: FontWeight.w700),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 25),
//                       RoundButton(
//                           title: "Checkout",
//                           onPressed: () {
//                             cart.clear();
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) => CheckoutView(
//                                   totalAmount: totalAmount,
//                                   subtotal: subtotal,
//                                   deliveryCost: deliveryCost,
//                                 ),
//                               ),
//                             );
//                           }),
//                       const SizedBox(height: 20),
//                     ],
//                   ),
//                 ),
//               ],
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
