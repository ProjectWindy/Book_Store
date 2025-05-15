import 'package:flutter/material.dart';
 
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../common/color_extension.dart';
import '../../common_widget/round_button.dart';
import 'change_address_view.dart';
import 'checkout_message_view.dart';
import '../../services/checkout_service.dart';

class CheckoutView extends StatefulWidget {
  final double totalAmount;
  final double subtotal;
  final double deliveryCost;

  const CheckoutView({
    Key? key,
    required this.totalAmount,
    required this.subtotal,
    required this.deliveryCost,
  }) : super(key: key);

  @override
  State<CheckoutView> createState() => _CheckoutViewState();
}

class _CheckoutViewState extends State<CheckoutView> {
  final CheckoutService _checkoutService = CheckoutService();
  String userAddress = "Loading address...";

  List paymentArr = [
    {"name": "Cash on delivery", "icon": "assets/img/cash.png"},
    {"name": "**** **** **** 2187", "icon": "assets/img/visa_icon.png"},
    {"name": "test@gmail.com", "icon": "assets/img/paypal.png"},
  ];

  int selectMethod = -1;

  @override
  void initState() {
    super.initState();
    fetchUserAddress();
  }

  Future<void> fetchUserAddress() async {
    String address = await _checkoutService.fetchUserAddress();
    setState(() {
      userAddress = address;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 46),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Image.asset("assets/img/btn_back.png",
                          width: 20, height: 20),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Checkout",
                        style: TextStyle(
                          color: TColor.primaryText,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Delivery Address",
                        style: TextStyle(
                            color: TColor.secondaryText, fontSize: 12)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            userAddress,
                            style: TextStyle(
                              color: TColor.primaryText,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChangeAddressView(),
                              ),
                            );

                            if (result != null && result is String) {
                              setState(() {
                                userAddress = result;
                              });
                            }
                          },
                          child: Text(
                            "Change",
                            style: TextStyle(
                              color: TColor.primary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(height: 8, color: TColor.textfield),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Payment method",
                            style: TextStyle(
                                color: TColor.secondaryText,
                                fontSize: 13,
                                fontWeight: FontWeight.w500)),
                        TextButton.icon(
                          onPressed: () {},
                          icon: Icon(Icons.add, color: TColor.primary),
                          label: Text("Add Card",
                              style: TextStyle(
                                  color: TColor.primary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: paymentArr.length,
                      itemBuilder: (context, index) {
                        var pObj = paymentArr[index] as Map? ?? {};
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          padding: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 15.0),
                          decoration: BoxDecoration(
                            color: TColor.textfield,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                                color: TColor.secondaryText.withOpacity(0.2)),
                          ),
                          child: Row(
                            children: [
                              Image.asset(pObj["icon"].toString(),
                                  width: 50, height: 20, fit: BoxFit.contain),
                              Expanded(
                                child: Text(pObj["name"],
                                    style: TextStyle(
                                        color: TColor.primaryText,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500)),
                              ),
                              InkWell(
                                onTap: () =>
                                    setState(() => selectMethod = index),
                                child: Icon(
                                  selectMethod == index
                                      ? Icons.radio_button_on
                                      : Icons.radio_button_off,
                                  color: TColor.primary,
                                  size: 15,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 25),
                child: RoundButton(
                  title: "Send Order",
                  onPressed: () async {
                    try {
                      await _checkoutService.processPayment(
                        totalAmount: widget.totalAmount,
                        subtotal: widget.subtotal,
                        deliveryCost: widget.deliveryCost,
                        cartDetails: paymentArr,
                      );

                      showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.transparent,
                        isScrollControlled: true,
                        builder: (context) => const CheckoutMessageView(),
                      );
                    } catch (e) {
                      print("Error processing payment: $e");
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
