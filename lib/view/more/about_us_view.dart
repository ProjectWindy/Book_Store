import 'package:books_store/common/color_extension.dart';
import 'package:books_store/view/cart/cart_screen.dart';
import 'package:flutter/material.dart';

class AboutUsView extends StatefulWidget {
  const AboutUsView({super.key});

  @override
  State<AboutUsView> createState() => _AboutUsViewState();
}

class _AboutUsViewState extends State<AboutUsView> {
  List aboutTextArr = [
    "Giới thiệu về bookStore\n\nChào mừng bạn đến với bookStore – ứng dụng mua sách trực tuyến thân thiện, tiện lợi và dành riêng cho những tâm hồn yêu sách. \n\nChào mừng bạn đến với bookStore – ứng dụng mua sách trực tuyến thân thiện, tiện lợi và dành riêng cho những tâm hồn yêu sách. Chúng tôi tin rằng mỗi cuốn sách đều chứa đựng tri thức, cảm hứng và những hành trình kỳ diệu. Với bookStore, việc tìm kiếm và sở hữu những tựa sách yêu thích chưa bao giờ dễ dàng đến thế.bookStore mang đến cho bạn:Kho sách phong phú từ nhiều thể loại: văn học, kinh doanh, kỹ năng sống, giáo dục,...Giao diện đơn giản, dễ sử dụng và tối ưu cho mọi thiết bị.Cập nhật nhanh chóng các ấn phẩm mới, sách bán chạy và ưu đãi hấp dẫn.Đánh giá, gợi ý sách cá nhân hóa phù hợp với gu đọc của bạn.Chúng tôi không chỉ bán sách – chúng tôi giúp bạn kết nối với tri thức, mở rộng thế giới quan và nuôi dưỡng tình yêu đọc sách mỗi ngày..",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 46,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Image.asset("assets/img/btn_back.png",
                          width: 20, height: 20),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child: Text(
                        "About Us",
                        style: TextStyle(
                            color: TColor.primaryText,
                            fontSize: 20,
                            fontWeight: FontWeight.w800),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const CartScreen()));
                      },
                      icon: Image.asset(
                        "assets/img/shopping_cart.png",
                        width: 25,
                        height: 25,
                      ),
                    ),
                  ],
                ),
              ),
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: aboutTextArr.length,
                itemBuilder: ((context, index) {
                  var txt = aboutTextArr[index] as String? ?? "";
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 25),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                              color: TColor.primary,
                              borderRadius: BorderRadius.circular(4)),
                        ),
                        const SizedBox(
                          width: 15,
                        ),
                        Expanded(
                          child: Text(
                            txt,
                            style: TextStyle(
                                color: TColor.primaryText, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
