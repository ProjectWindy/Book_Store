import 'package:flutter/material.dart';

import '../../common/color_extension.dart';
import '../../services/location_service.dart';

class ChangeAddressView extends StatefulWidget {
  @override
  _ChangeAddressViewState createState() => _ChangeAddressViewState();
}

class _ChangeAddressViewState extends State<ChangeAddressView> {
  final LocationService _locationService = LocationService();
  TextEditingController addressController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadCurrentAddress();
  }

  Future<void> loadCurrentAddress() async {
    try {
      String? address = await _locationService.getCurrentAddress();
      setState(() {
        addressController.text = address ?? "";
      });
    } catch (e) {
      print("Error loading address: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.white,
      appBar: AppBar(
        backgroundColor: TColor.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Change Address",
          style: TextStyle(
            color: TColor.primaryText,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_ios,
            color: TColor.primaryText,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Enter Your Delivery Address",
              style: TextStyle(
                color: TColor.primaryText,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 15),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                controller: addressController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "Enter your complete address",
                  hintStyle: TextStyle(
                    color: TColor.secondaryText,
                    fontSize: 14,
                  ),
                  contentPadding: EdgeInsets.all(15),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        String newAddress = addressController.text.trim();
                        if (newAddress.isNotEmpty) {
                          setState(() {
                            isLoading = true;
                          });

                          try {
                            await _locationService.updateAddress(newAddress);

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Address updated successfully!"),
                                backgroundColor: Colors.green,
                                duration: Duration(seconds: 2),
                              ),
                            );

                            await Future.delayed(Duration(seconds: 1));
                            Navigator.pop(context, newAddress);
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Error updating address"),
                                backgroundColor: Colors.red,
                                duration: Duration(seconds: 2),
                              ),
                            );
                          } finally {
                            setState(() {
                              isLoading = false;
                            });
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Please enter an address"),
                              backgroundColor: Colors.orange,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: TColor.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                        "Save Address",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    addressController.dispose();
    super.dispose();
  }
}
