import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/book.dart';
import '../../providers/cart_provider.dart';

class BookDetailScreen extends StatefulWidget {
  final Book book;
  const BookDetailScreen({super.key, required this.book});

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  bool isFavorite = false;
  String? userName;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBookHeader(),
                _buildInfoCategories(),
                _buildTabsSection(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SliverAppBar(
      expandedHeight: size.height * 0.4,
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF6A62B7).withOpacity(0.9),
                      const Color(0xFF362C7E).withOpacity(0.9),
                    ],
                  ),
                ),
              ),
            ),
            Center(
              child: Hero(
                tag: widget.book.cover,
                child: Container(
                  height: size.height * 0.32,
                  width: size.width * 0.45,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: widget.book.cover.startsWith('assets/')
                        ? Image.asset(
                            widget.book.cover,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              color: Colors.grey[200],
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.book,
                                      size: 40,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "No Image",
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        : CachedNetworkImage(
                            imageUrl: widget.book.cover,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: Colors.grey[200],
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                            errorWidget: (context, url, error) =>
                                CachedNetworkImage(
                              imageUrl:
                                  'https://images.unsplash.com/photo-1544947950-fa07a98d237f?ixlib=rb-4.0.3',
                              width: MediaQuery.of(context).size.width / 3,
                              height: MediaQuery.of(context).size.width / 3,
                              fit: BoxFit.cover,
                            ),
                          ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -1,
              left: 0,
              right: 0,
              child: Container(
                height: 30,
                decoration: const BoxDecoration(
                  color: Color(0xFFF8F9FF),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
              ),
            ),
          ],
        ),
      ),
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child:
              const Icon(Icons.arrow_back, color: Color(0xFF362C7E), size: 20),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        if (userName != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Center(
              child: Text(
                userName!,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : const Color(0xFF362C7E),
              size: 20,
            ),
          ),
          onPressed: () {
            setState(() {
              isFavorite = !isFavorite;
            });
          },
        ),
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.share, color: Color(0xFF362C7E), size: 20),
          ),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildBookHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.book.title,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Color(0xFF19233C),
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: Colors.white,
                backgroundImage: widget.book.authorImg.startsWith('assets/')
                    ? AssetImage(widget.book.authorImg)
                    : NetworkImage(widget.book.authorImg) as ImageProvider,
                onBackgroundImageError: (exception, stackTrace) {},
                child: Icon(
                  Icons.person,
                  size: 30,
                  color: Colors.grey[400],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.book.author,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF19233C),
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Author',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF8C92A6),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFECEDFF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.star,
                      color: Color(0xFFFFC319),
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.book.rating.toString(),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF19233C),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCategories() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      height: 130,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildInfoItem(
            'Genre',
            widget.book.genre,
            Icons.category_outlined,
            const Color(0xFFE2F1FF),
            const Color(0xFF4E87F5),
          ),
          _buildInfoItem(
            'Language',
            widget.book.lanugage,
            Icons.language,
            const Color(0xFFE7F9EF),
            const Color(0xFF2AB97F),
          ),
          _buildInfoItem(
            'Age',
            widget.book.age,
            Icons.person_outline,
            const Color(0xFFFFEEE3),
            const Color(0xFFFF9057),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String title, String value, IconData icon,
      Color bgColor, Color iconColor) {
    return Container(
      width: 105,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF8C92A6),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF19233C),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildTabsSection() {
    return Container(
      height: 400,
      margin: const EdgeInsets.only(top: 20),
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFFECEDFF),
                borderRadius: BorderRadius.circular(25),
              ),
              child: TabBar(
                padding:
                    EdgeInsets.zero, // Loại bỏ padding để indicator full size
                indicatorSize:
                    TabBarIndicatorSize.tab, // Để indicator phủ toàn bộ tab
                indicator: BoxDecoration(
                  color: Color(0xFF6A62B7),
                  borderRadius:
                      BorderRadius.circular(10), // Bo góc nhẹ để không quá sắc
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Color(0xFF6A62B7),
                labelStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                tabs: const [
                  Tab(text: "Summary"),
                  Tab(text: "Reviews"),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: TabBarView(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "About Book",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF19233C),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            widget.book.summary,
                            style: const TextStyle(
                              fontSize: 15,
                              height: 1.6,
                              color: Color(0xFF656F8C),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECEDFF),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.rate_review_outlined,
                            size: 40,
                            color: Color(0xFF6A62B7),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "No Reviews Yet",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                            color: Color(0xFF19233C),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Be the first to review this book",
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF8C92A6),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.edit, size: 18),
                          label: const Text("Write a Review"),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF6A62B7),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: const BorderSide(color: Color(0xFF6A62B7)),
                            ),
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
      ),
    );
  }

  Widget _buildBottomBar() {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        final isInCart = cartProvider.isInCart(widget.book);

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${NumberFormat.currency(locale: 'vi_VN', symbol: '', decimalDigits: 0).format(widget.book.price * 1)}đ",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF19233C),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  if (isInCart) {
                    cartProvider.removeItem(widget.book);
                  } else {
                    cartProvider.addItem(widget.book);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isInCart
                      ? const Color(0xFFFF5151)
                      : const Color(0xFF6A62B7),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  children: [
                    Icon(
                      isInCart
                          ? Icons.shopping_cart_checkout
                          : Icons.shopping_cart,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isInCart ? "Remove" : "Add to Cart",
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
