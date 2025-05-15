// import 'package:books_store/services/service_call.dart';
// import 'package:books_store/view/admin/image.dart';
// import 'package:flutter/material.dart';
// import '../../models/food.dart';
 
// class AddProductScreen extends StatefulWidget {
//   @override
//   _AddProductScreenState createState() => _AddProductScreenState();
// }

// class _AddProductScreenState extends State<AddProductScreen> {
//   final FirestoreService firestoreService = FirestoreService();
//   final _formKey = GlobalKey<FormState>();

//   String name = '';
//   String foodType = '';
//   String image = '';
//   String rate = '';
//   String rating = '';
//   String type = '';

//    final List<String> foodTypeOptions = [
//     'Desserts',
//     'Main Course',
//     'Drinks',
//     'Appetizers'
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Thêm sản phẩm")),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 TextFormField(
//                   decoration: InputDecoration(labelText: 'Tên sản phẩm'),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Vui lòng nhập tên sản phẩm';
//                     }
//                     return null;
//                   },
//                   onChanged: (value) {
//                     setState(() {
//                       name = value;
//                     });
//                   },
//                 ),
//                 SizedBox(height: 16),
//                 DropdownButtonFormField<String>(
//                   decoration: InputDecoration(labelText: 'Loại món'),
//                   value: foodType.isEmpty ? null : foodType,
//                   hint: Text('Chọn loại món'),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Vui lòng chọn loại món';
//                     }
//                     return null;
//                   },
//                   items: foodTypeOptions.map((String type) {
//                     return DropdownMenuItem<String>(
//                       value: type,
//                       child: Text(type),
//                     );
//                   }).toList(),
//                   onChanged: (value) {
//                     setState(() {
//                       foodType = value!;
//                     });
//                   },
//                 ),
//                 SizedBox(height: 16),

//                  AssetImageSelector(
//                   initialImage: image,
//                   onImageSelected: (selectedImage) {
//                     setState(() {
//                       image = selectedImage;
//                     });
//                   },
//                 ),
//                  if (image.isNotEmpty)
//                   Padding(
//                     padding: const EdgeInsets.only(top: 8.0),
//                     child: Text(
//                       'Đường dẫn đã chọn: $image',
//                       style: TextStyle(fontSize: 14, color: Colors.grey[600]),
//                     ),
//                   ),

//                 SizedBox(height: 16),
//                 TextFormField(
//                   decoration: InputDecoration(labelText: 'Giá (VD: 4.9)'),
//                   keyboardType: TextInputType.number,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Vui lòng nhập giá';
//                     }
//                      if (double.tryParse(value) == null) {
//                       return 'Giá phải là số';
//                     }
//                     return null;
//                   },
//                   onChanged: (value) {
//                     setState(() {
//                       rate = value;
//                     });
//                   },
//                 ),
//                 SizedBox(height: 16),
//                 TextFormField(
//                   decoration: InputDecoration(labelText: 'Số lượt đánh giá'),
//                   keyboardType: TextInputType.number,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Vui lòng nhập số lượt đánh giá';
//                     }
//                      if (int.tryParse(value) == null) {
//                       return 'Số lượt đánh giá phải là số nguyên';
//                     }
//                     return null;
//                   },
//                   onChanged: (value) {
//                     setState(() {
//                       rating = value;
//                     });
//                   },
//                 ),
//                 SizedBox(height: 16),
//                 TextFormField(
//                   decoration:
//                       InputDecoration(labelText: 'Loại (VD: Cakes by Tella)'),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Vui lòng nhập loại';
//                     }
//                     return null;
//                   },
//                   onChanged: (value) {
//                     setState(() {
//                       type = value;
//                     });
//                   },
//                 ),
//                 SizedBox(height: 24),
//                 ElevatedButton(
//                   onPressed: () {
//                     if (_formKey.currentState!.validate() && image.isNotEmpty) {
//                       firestoreService.addProduct(
//                         ProductModel(
//                           id: '',
//                           name: name,
//                           foodType: foodType,
//                           image: image,
//                           rate: rate,
//                           rating: rating,
//                           type: type,
//                         ),
//                       );
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(
//                             content: Text('Sản phẩm đã được thêm thành công')),
//                       );
//                       Navigator.pop(context);
//                     } else if (image.isEmpty) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(
//                             content:
//                                 Text('Vui lòng chọn hình ảnh cho sản phẩm')),
//                       );
//                     }
//                   },
//                   child: Text("Thêm sản phẩm"),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
