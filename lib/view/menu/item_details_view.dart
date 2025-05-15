import 'package:books_store/providers/cart_provider.dart';
import 'package:books_store/services/cart.dart';
import 'package:books_store/view/cart/cart_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:books_store/models/book.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../../common/color_extension.dart';
import '../../common_widget/round_icon_button.dart';
import '../more/my_order_view.dart';

class ItemDetailsView extends StatefulWidget {
  final Map<String, dynamic> item;

  const ItemDetailsView({Key? key, required this.item}) : super(key: key);

  @override
  _ItemDetailsViewState createState() => _ItemDetailsViewState();
}

class _ItemDetailsViewState extends State<ItemDetailsView> {
  int quantity = 1;

  Stream<QuerySnapshot> getRelatedBooks() {
    // Lấy sách cùng thể loại từ Firestore
    String category = widget.item['type'] ?? 'Truyện';
    return FirebaseFirestore.instance
        .collection('menu_items')
        .where('type', isEqualTo: category)
        .limit(5)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: TColor.white,
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          widget.item['image'].toString().startsWith('assets/')
              ? Image.asset(
                  widget.item['image'].toString(),
                  width: media.width,
                  height: media.width,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: media.width,
                    height: media.width,
                    color: Colors.grey[300],
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image_not_supported,
                            size: 50,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            "Không có hình ảnh",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : CachedNetworkImage(
                  imageUrl: widget.item['image'],
                  width: media.width,
                  height: media.width,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => Container(
                    width: media.width,
                    height: media.width,
                    color: Colors.grey[300],
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.menu_book,
                            size: 50,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            "Không có hình ảnh",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  placeholder: (context, url) => Container(
                    width: media.width,
                    height: media.width,
                    color: Colors.grey[300],
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
          Container(
            width: media.width,
            height: media.width,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  colors: [Colors.black, Colors.transparent, Colors.black],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter),
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Column(
                    children: [
                      SizedBox(
                        height: media.width - 60,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: TColor.white,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 35),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 25),
                              child: Text(
                                widget.item['name'],
                                style: TextStyle(
                                  color: TColor.primaryText,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 25),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      IgnorePointer(
                                        ignoring: true,
                                        child: RatingBar.builder(
                                          initialRating: double.tryParse(widget
                                                      .item['rate']
                                                      ?.toString() ??
                                                  '0') ??
                                              0.0,
                                          minRating: 1,
                                          direction: Axis.horizontal,
                                          allowHalfRating: true,
                                          itemCount: 5,
                                          itemSize: 20,
                                          itemPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 1.0),
                                          itemBuilder: (context, _) => Icon(
                                            Icons.star,
                                            color: TColor.primary,
                                          ),
                                          onRatingUpdate: (rating) {
                                            print(rating);
                                          },
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "${widget.item['rating']} đánh giá sao",
                                        style: TextStyle(
                                          color: TColor.primary,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        "${NumberFormat('#,###', 'vi_VN').format(double.tryParse(widget.item['rate']?.toString() ?? '0') ?? 0).replaceAll(',', '.')}vnd",
                                        style: TextStyle(
                                          color: TColor.primaryText,
                                          fontSize: 31,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "/mỗi quyển",
                                        style: TextStyle(
                                          color: TColor.primaryText,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 15),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 25),
                              child: Text(
                                "Mô tả",
                                style: TextStyle(
                                  color: TColor.primaryText,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 25),
                              child: Text(
                                widget.item['description'] ??
                                    "Không có mô tả nào",
                                style: TextStyle(
                                  color: TColor.secondaryText,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 25),
                              child: Divider(
                                color: TColor.secondaryText.withOpacity(0.4),
                                height: 1,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 25),
                              child: Text(
                                "Số lượng",
                                style: TextStyle(
                                  color: TColor.primaryText,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Padding(
                            //   padding:
                            //       const EdgeInsets.symmetric(horizontal: 25),
                            //   child: Row(
                            //     children: [
                            //       Text(
                            //         "Number of Books",
                            //         style: TextStyle(
                            //           color: TColor.primaryText,
                            //           fontSize: 14,
                            //           fontWeight: FontWeight.w700,
                            //         ),
                            //       ),
                            //       const Spacer(),
                            //       InkWell(
                            //         onTap: () {
                            //           setState(() {
                            //             if (quantity > 1) {
                            //               quantity--;
                            //             }
                            //           });
                            //         },
                            //         child: Container(
                            //           padding: const EdgeInsets.symmetric(
                            //               horizontal: 15),
                            //           height: 25,
                            //           alignment: Alignment.center,
                            //           decoration: BoxDecoration(
                            //             color: TColor.primary,
                            //             borderRadius:
                            //                 BorderRadius.circular(12.5),
                            //           ),
                            //           child: Text(
                            //             "-",
                            //             style: TextStyle(
                            //               color: TColor.white,
                            //               fontSize: 14,
                            //               fontWeight: FontWeight.w700,
                            //             ),
                            //           ),
                            //         ),
                            //       ),
                            //       const SizedBox(width: 8),
                            //       Container(
                            //         padding: const EdgeInsets.symmetric(
                            //             horizontal: 15),
                            //         height: 25,
                            //         alignment: Alignment.center,
                            //         decoration: BoxDecoration(
                            //           border: Border.all(
                            //             color: TColor.primary,
                            //           ),
                            //           borderRadius: BorderRadius.circular(12.5),
                            //         ),
                            //         child: Text(
                            //           quantity.toString(),
                            //           style: TextStyle(
                            //             color: TColor.primary,
                            //             fontSize: 14,
                            //             fontWeight: FontWeight.w500,
                            //           ),
                            //         ),
                            //       ),
                            //       const SizedBox(width: 8),
                            //       InkWell(
                            //         onTap: () {
                            //           setState(() {
                            //             quantity++;
                            //           });
                            //         },
                            //         child: Container(
                            //           padding: const EdgeInsets.symmetric(
                            //               horizontal: 15),
                            //           height: 25,
                            //           alignment: Alignment.center,
                            //           decoration: BoxDecoration(
                            //             color: TColor.primary,
                            //             borderRadius:
                            //                 BorderRadius.circular(12.5),
                            //           ),
                            //           child: Text(
                            //             "+",
                            //             style: TextStyle(
                            //               color: TColor.white,
                            //               fontSize: 14,
                            //               fontWeight: FontWeight.w700,
                            //             ),
                            //           ),
                            //         ),
                            //       ),
                            //     ],
                            //   ),
                            // ),
                            const SizedBox(height: 25),
                            SizedBox(
                              height: 220,
                              child: Stack(
                                alignment: Alignment.centerLeft,
                                children: [
                                  Container(
                                    width: media.width * 0.25,
                                    height: 160,
                                    decoration: BoxDecoration(
                                      color: TColor.primary,
                                      borderRadius: const BorderRadius.only(
                                        topRight: Radius.circular(35),
                                        bottomRight: Radius.circular(35),
                                      ),
                                    ),
                                  ),
                                  Center(
                                    child: Stack(
                                      alignment: Alignment.centerRight,
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.only(
                                            top: 8,
                                            bottom: 8,
                                            left: 10,
                                            right: 20,
                                          ),
                                          width: media.width - 80,
                                          height: 120,
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(35),
                                              bottomLeft: Radius.circular(35),
                                              topRight: Radius.circular(10),
                                              bottomRight: Radius.circular(10),
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black12,
                                                blurRadius: 12,
                                                offset: Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                "Price",
                                                style: TextStyle(
                                                  color: TColor.primaryText,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(height: 15),
                                              Text(
                                                "${NumberFormat('#,###', 'vi_VN').format(double.tryParse(widget.item['rate']?.toString() ?? '0') ?? 0).replaceAll(',', '.')}vnd",
                                                style: TextStyle(
                                                  color: TColor.primaryText,
                                                  fontSize: 21,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              const SizedBox(height: 15),
                                              SizedBox(
                                                width: 130,
                                                height: 25,
                                                child: RoundIconButton(
                                                  title: "Thêm ",
                                                  icon:
                                                      "assets/img/shopping_add.png",
                                                  color: TColor.primary,
                                                  onPressed: () {
                                                    final cart = Provider.of<
                                                            CartProvider>(
                                                        context,
                                                        listen: false);

                                                    // Tạo đối tượng Book từ dữ liệu
                                                    final book = Book(
                                                      id: widget.item['id'] ??
                                                          'B${DateTime.now().millisecondsSinceEpoch}',
                                                      title:
                                                          widget.item['name'] ??
                                                              '',
                                                      price: double.tryParse(widget
                                                                  .item['rate']
                                                                  ?.toString() ??
                                                              '0') ??
                                                          0.0,
                                                      cover: widget
                                                              .item['image'] ??
                                                          '',
                                                      author: widget
                                                              .item['author'] ??
                                                          'Unknown Author',
                                                      age: widget.item['age'] ??
                                                          'ALL AGE',
                                                      authorImg: widget.item[
                                                              'author_img'] ??
                                                          '',
                                                      seller: widget
                                                              .item['seller'] ??
                                                          false,
                                                      genre:
                                                          widget.item['type'] ??
                                                              '',
                                                      lanugage: widget.item[
                                                              'language'] ??
                                                          'ENGLISH',
                                                      summary: widget.item[
                                                              'description'] ??
                                                          '',
                                                      showImage: widget
                                                              .item['image'] ??
                                                          '',
                                                      rating: double.tryParse(widget
                                                                  .item['rate']
                                                                  ?.toString() ??
                                                              '0') ??
                                                          0.0,
                                                      category: '',
                                                    );

                                                    // Thêm vào giỏ hàng
                                                    cart.addItem(book);

                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                          content: Text(
                                                              '${widget.item['name']} đã được thêm vào giỏ hàng!')),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    const CartScreen(),
                                              ),
                                            );
                                          },
                                          child: Container(
                                            width: 45,
                                            height: 45,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(22.5),
                                              boxShadow: const [
                                                BoxShadow(
                                                  color: Colors.black12,
                                                  blurRadius: 4,
                                                  offset: Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            alignment: Alignment.center,
                                            child: Image.asset(
                                              "assets/img/shopping_cart.png",
                                              width: 20,
                                              height: 20,
                                              color: TColor.primary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Phần sách liên quan
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Sách liên quan",
                              style: TextStyle(
                                color: TColor.primaryText,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 15),
                            SizedBox(
                              height: 200,
                              child: StreamBuilder<QuerySnapshot>(
                                stream: getRelatedBooks(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }

                                  if (snapshot.hasError) {
                                    return Center(
                                      child: Text(
                                        "Lỗi khi tải sách liên quan",
                                        style: TextStyle(
                                            color: TColor.secondaryText),
                                      ),
                                    );
                                  }

                                  final books = snapshot.data?.docs ?? [];

                                  if (books.isEmpty) {
                                    return Center(
                                      child: Text(
                                        "Không có sách liên quan",
                                        style: TextStyle(
                                            color: TColor.secondaryText),
                                      ),
                                    );
                                  }

                                  return ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: books.length,
                                    itemBuilder: (context, index) {
                                      final book = books[index].data()
                                          as Map<String, dynamic>;

                                      // Bỏ qua sách hiện tại
                                      if (book['name'] == widget.item['name']) {
                                        return const SizedBox.shrink();
                                      }

                                      return GestureDetector(
                                        onTap: () {
                                          // Thêm ID vào Map để có thể sử dụng trong trang chi tiết
                                          final bookWithId = {
                                            ...book,
                                            'id': books[index].id,
                                          };

                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ItemDetailsView(
                                                item: bookWithId,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          width: 120,
                                          margin:
                                              const EdgeInsets.only(right: 10),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                child: (book['image'] ?? '')
                                                        .toString()
                                                        .startsWith('assets/')
                                                    ? Image.asset(
                                                        book['image'] ?? '',
                                                        height: 120,
                                                        width: 120,
                                                        fit: BoxFit.cover,
                                                        errorBuilder: (context,
                                                                error,
                                                                stackTrace) =>
                                                            Container(
                                                          color:
                                                              Colors.grey[300],
                                                          child: const Icon(
                                                            Icons.broken_image,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      )
                                                    : CachedNetworkImage(
                                                        imageUrl:
                                                            book['image'] ?? '',
                                                        height: 120,
                                                        width: 120,
                                                        fit: BoxFit.cover,
                                                        placeholder:
                                                            (context, url) =>
                                                                Container(
                                                          color:
                                                              Colors.grey[300],
                                                          child: const Center(
                                                            child:
                                                                CircularProgressIndicator(),
                                                          ),
                                                        ),
                                                        errorWidget: (context,
                                                                url, error) =>
                                                            Container(
                                                          color:
                                                              Colors.grey[300],
                                                          child: Icon(
                                                            Icons.menu_book,
                                                            color: Colors
                                                                .grey[400],
                                                          ),
                                                        ),
                                                      ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                book['name'] ?? '',
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: TColor.primaryText,
                                                ),
                                              ),
                                              Text(
                                                "${NumberFormat('#,###', 'vi_VN').format(double.tryParse(book['rate']?.toString() ?? '0') ?? 0).replaceAll(',', '.')}vnd",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: TColor.primary,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                  Container(
                    height: media.width - 20,
                    alignment: Alignment.bottomRight,
                    margin: const EdgeInsets.only(right: 4),
                    child: InkWell(
                      onTap: () {
                        // isFav = !isFav;
                        // setState(() {});
                      },
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.favorite_border,
                          color: TColor.primary,
                          size: 35,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                const SizedBox(height: 35),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Image.asset(
                          "assets/img/btn_back.png",
                          width: 20,
                          height: 20,
                          color: TColor.white,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CartScreen(),
                            ),
                          );
                        },
                        icon: Image.asset(
                          "assets/img/shopping_cart.png",
                          width: 25,
                          height: 25,
                          color: TColor.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
