// import 'package:books_store/view/admin/image.dart';
// import 'package:food_delivery/models/food.dart';
// import 'package:food_delivery/view/admin/image.dart';
// import 'package:flutter/material.dart';
// import 'package:food_delivery/services/service_call.dart';

// class EditProductScreen extends StatefulWidget {
//   final ProductModel product;
//   final String documentId;

//   const EditProductScreen({
//     Key? key,
//     required this.product,
//     required this.documentId,
//   }) : super(key: key);

//   @override
//   _EditProductScreenState createState() => _EditProductScreenState();
// }

// class _EditProductScreenState extends State<EditProductScreen> {
//   final FirestoreService firestoreService = FirestoreService();
//   final _formKey = GlobalKey<FormState>();
//   bool _isLoading = false;
//   late String id;

//   late String name;
//   late String foodType;
//   late String image;
//   late String rate;
//   late String rating;
//   late String type;

//   final List<String> foodTypeOptions = [
//     'Desserts',
//     'Main Course',
//     'Drinks',
//     'Appetizers'
//   ];

//   @override
//   void initState() {
//     super.initState();
//     id = widget.documentId;
//     name = widget.product.name;
//     foodType = widget.product.foodType;
//     image = widget.product.image;
//     rate = widget.product.rate;
//     rating = widget.product.rating;
//     type = widget.product.type;
//   }

//   void _showToast(String message, bool isSuccess) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             Icon(
//               isSuccess ? Icons.check_circle : Icons.error,
//               color: Colors.white,
//             ),
//             const SizedBox(width: 8),
//             Expanded(child: Text(message)),
//           ],
//         ),
//         backgroundColor: isSuccess ? Colors.green : Colors.red,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(8),
//         ),
//         margin: const EdgeInsets.all(16),
//         duration: const Duration(seconds: 2),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Edit Product"),
//         elevation: 2,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.delete, color: Colors.red),
//             onPressed: _isLoading ? null : _confirmDelete,
//           ),
//         ],
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : Container(
//               padding: const EdgeInsets.all(16.0),
//               decoration: BoxDecoration(
//                 color: Colors.grey[50],
//               ),
//               child: Form(
//                 key: _formKey,
//                 child: SingleChildScrollView(
//                   child: Card(
//                     elevation: 4,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Padding(
//                       padding: const EdgeInsets.all(16.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.stretch,
//                         children: [
//                           TextFormField(
//                             initialValue: name,
//                             decoration: const InputDecoration(
//                               labelText: 'Product Name',
//                               border: OutlineInputBorder(),
//                             ),
//                             validator: (value) {
//                               if (value == null || value.isEmpty) {
//                                 return 'Please enter product name';
//                               }
//                               if (value.length < 3) {
//                                 return 'Product name must be at least 3 characters';
//                               }
//                               return null;
//                             },
//                             onChanged: (value) {
//                               setState(() {
//                                 name = value;
//                               });
//                             },
//                           ),
//                           const SizedBox(height: 16),
//                           DropdownButtonFormField<String>(
//                             decoration: const InputDecoration(
//                               labelText: 'Food Type',
//                               border: OutlineInputBorder(),
//                             ),
//                             value: foodType.isEmpty ? null : foodType,
//                             hint: const Text('Select food type'),
//                             validator: (value) {
//                               if (value == null || value.isEmpty) {
//                                 return 'Please select food type';
//                               }
//                               return null;
//                             },
//                             items: foodTypeOptions.map((String type) {
//                               return DropdownMenuItem<String>(
//                                 value: type,
//                                 child: Text(type),
//                               );
//                             }).toList(),
//                             onChanged: (value) {
//                               setState(() {
//                                 foodType = value!;
//                               });
//                             },
//                           ),
//                           const SizedBox(height: 16),
//                           AssetImageSelector(
//                             initialImage: image,
//                             onImageSelected: (selectedImage) {
//                               setState(() {
//                                 image = selectedImage;
//                               });
//                             },
//                           ),
//                           if (image.isNotEmpty)
//                             Padding(
//                               padding: const EdgeInsets.only(top: 8.0),
//                               child: Text(
//                                 'Selected image path: $image',
//                                 style: TextStyle(
//                                     fontSize: 14, color: Colors.grey[600]),
//                               ),
//                             ),
//                           const SizedBox(height: 16),
//                           TextFormField(
//                             initialValue: rate,
//                             decoration: const InputDecoration(
//                               labelText: 'Price (e.g., 4.9)',
//                               border: OutlineInputBorder(),
//                             ),
//                             keyboardType: const TextInputType.numberWithOptions(
//                                 decimal: true),
//                             validator: (value) {
//                               if (value == null || value.isEmpty) {
//                                 return 'Please enter price';
//                               }
//                               final price = double.tryParse(value);
//                               if (price == null) {
//                                 return 'Price must be a number';
//                               }
//                               if (price <= 0) {
//                                 return 'Price must be greater than 0';
//                               }
//                               return null;
//                             },
//                             onChanged: (value) {
//                               setState(() {
//                                 rate = value;
//                               });
//                             },
//                           ),
//                           const SizedBox(height: 16),
//                           TextFormField(
//                             initialValue: rating,
//                             decoration: const InputDecoration(
//                               labelText: 'Rating Count',
//                               border: OutlineInputBorder(),
//                             ),
//                             keyboardType: TextInputType.number,
//                             validator: (value) {
//                               if (value == null || value.isEmpty) {
//                                 return 'Please enter rating count';
//                               }
//                               final ratingCount = int.tryParse(value);
//                               if (ratingCount == null) {
//                                 return 'Rating count must be a whole number';
//                               }
//                               if (ratingCount < 0) {
//                                 return 'Rating count cannot be negative';
//                               }
//                               return null;
//                             },
//                             onChanged: (value) {
//                               setState(() {
//                                 rating = value;
//                               });
//                             },
//                           ),
//                           const SizedBox(height: 16),
//                           TextFormField(
//                             initialValue: type,
//                             decoration: const InputDecoration(
//                               labelText: 'Type (e.g., Cakes by Tella)',
//                               border: OutlineInputBorder(),
//                             ),
//                             validator: (value) {
//                               if (value == null || value.isEmpty) {
//                                 return 'Please enter type';
//                               }
//                               if (value.length < 3) {
//                                 return 'Type must be at least 3 characters';
//                               }
//                               return null;
//                             },
//                             onChanged: (value) {
//                               setState(() {
//                                 type = value;
//                               });
//                             },
//                           ),
//                           const SizedBox(height: 24),
//                           ElevatedButton(
//                             onPressed: _isLoading ? null : _updateProduct,
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.blue,
//                               foregroundColor: Colors.white,
//                               padding: const EdgeInsets.symmetric(vertical: 16),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                             ),
//                             child: const Text(
//                               "Save Changes",
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//     );
//   }

//   void _updateProduct() async {
//     if (_formKey.currentState!.validate() && image.isNotEmpty) {
//       setState(() {
//         _isLoading = true;
//       });

//       try {
//         ProductModel updatedProduct = ProductModel(
//           id: id,
//           name: name,
//           foodType: foodType,
//           image: image,
//           rate: rate,
//           rating: rating,
//           type: type,
//         );

//         await firestoreService.updateProduct(widget.documentId, updatedProduct);
//         _showToast('Product updated successfully', true);
//         if (mounted) {
//           Navigator.pop(context, true);
//         }
//       } catch (error) {
//         _showToast('Error: Unable to update product', false);
//       } finally {
//         if (mounted) {
//           setState(() {
//             _isLoading = false;
//           });
//         }
//       }
//     } else if (image.isEmpty) {
//       _showToast('Please select an image for the product', false);
//     }
//   }

//   void _confirmDelete() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text("Confirm Delete"),
//           content:
//               Text("Are you sure you want to delete '${widget.product.name}'?"),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           actions: <Widget>[
//             TextButton(
//               child: const Text("Cancel"),
//               onPressed: () => Navigator.of(context).pop(),
//             ),
//             TextButton(
//               child: const Text("Delete",
//                   style: TextStyle(
//                       color: Colors.red, fontWeight: FontWeight.bold)),
//               onPressed: () {
//                 Navigator.of(context).pop();
//                 _deleteProduct();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _deleteProduct() async {
//     if (widget.documentId.isEmpty) {
//       _showToast('Error: Invalid product ID', false);
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       await firestoreService.deleteProduct(widget.documentId);
//       _showToast('Product deleted successfully', true);
//       if (mounted) {
//         Navigator.pop(context, true);
//       }
//     } catch (error) {
//       _showToast('Error: Unable to delete product', false);
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }
// }
