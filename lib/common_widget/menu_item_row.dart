import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../common/color_extension.dart';

class MenuItemRow extends StatelessWidget {
  final Map mObj;
  final VoidCallback onTap;
  const MenuItemRow({super.key, required this.mObj, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: onTap,
        child: Stack(
          alignment: Alignment.bottomLeft,
          children: [
            (mObj["image"] != null &&
                    mObj["image"].toString().startsWith('assets/'))
                ? Image.asset(
                    mObj["image"].toString(),
                    width: double.maxFinite,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: double.maxFinite,
                      height: 200,
                      color: Colors.grey[300],
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image_not_supported,
                              size: 40,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Không có hình ảnh",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : CachedNetworkImage(
                    imageUrl: mObj["image"]?.toString() ?? '',
                    width: double.maxFinite,
                    height: 200,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => Container(
                      width: double.maxFinite,
                      height: 200,
                      color: Colors.grey[300],
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.menu_book,
                              size: 40,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Không có hình ảnh",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    placeholder: (context, url) => Container(
                      width: double.maxFinite,
                      height: 200,
                      color: Colors.grey[300],
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),
            Container(
              width: double.maxFinite,
              height: 200,
              decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [
                Colors.transparent,
                Colors.transparent,
                Colors.black
              ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mObj["name"]?.toString() ?? "Sách không tên",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: TColor.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.star,
                            color: TColor.primary,
                            size: 12,
                          ),
                          const SizedBox(
                            width: 4,
                          ),
                          Text(
                            mObj["rate"]?.toString() ?? "0.0",
                            textAlign: TextAlign.center,
                            style:
                                TextStyle(color: TColor.primary, fontSize: 11),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          Text(
                            mObj["type"]?.toString() ?? "Sách",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: TColor.white, fontSize: 11),
                          ),
                          Text(
                            " . ",
                            textAlign: TextAlign.center,
                            style:
                                TextStyle(color: TColor.primary, fontSize: 11),
                          ),
                          Text(
                            mObj["food_type"]?.toString() ?? "Khác",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: TColor.white, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 22,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
