// Data mẫu để tải lên Firebase
// Hỗ trợ cả ảnh local (assets) và ảnh từ internet (cached)

import 'package:flutter/material.dart';

final List<Map<String, dynamic>> firebaseBooks = [
  // CATEGORY: Fiction - Tiểu thuyết
  {
    'id': 'F007',
    'name': 'Cánh Đồng Bất Tận',
    'rate': '135000',
    'rating': '4.6',
    'type': 'Fiction',
    'category': 'Fiction',
    'image':
        'https://salt.tikicdn.com/cache/280x280/ts/product/7e/05/59/7e4eee1e8f4a3689d6ed2c82839ee552.jpg',
    'description':
        'Tác phẩm gồm 17 truyện ngắn viết về số phận con người trong bối cảnh nông thôn Việt Nam.',
    'author': 'Nguyễn Ngọc Tư',
    'age': '16+',
    'author_img':
        'https://reviewsach.net/wp-content/uploads/2018/12/Nguyen-Ngoc-Tu.jpg',
    'seller': true,
    'language': 'VIETNAMESE',
    'is_cached': true
  },
  {
    'id': 'F008',
    'name': 'Mùa Hè Không Tên',
    'rate': '115000',
    'rating': '4.5',
    'type': 'Fiction',
    'category': 'Fiction',
    'image':
        'https://salt.tikicdn.com/cache/750x750/ts/product/0a/de/55/27d43a8c582a8eef1a1ce7f407da7c6d.jpg.webp',
    'description':
        'Câu chuyện cảm động về tình bạn và khám phá bản thân trong mùa hè tuổi học trò.',
    'author': 'Nguyễn Nhật Ánh',
    'age': '12+',
    'author_img':
        'https://cdn0.fahasa.com/media/wysiwyg/Nha_Van/nguyen-nhat-anh.jpg',
    'seller': true,
    'language': 'VIETNAMESE',
    'is_cached': true
  },
  {
    'id': 'F009',
    'name': 'Tôi Là Bêtô',
    'rate': '95000',
    'rating': '4.7',
    'type': 'Fiction',
    'category': 'Fiction',
    'image': 'assets/images/books/toi_la_beto.jpg',
    'description':
        'Câu chuyện hài hước và sâu sắc qua góc nhìn của một chú chó tên Bêtô.',
    'author': 'Nguyễn Nhật Ánh',
    'age': '10+',
    'author_img': 'assets/images/authors/nguyen_nhat_anh.jpg',
    'seller': true,
    'language': 'VIETNAMESE',
    'is_cached': false
  },
  {
    'id': 'F010',
    'name': 'Những Đứa Trẻ Chạy Dọc Bờ Sông',
    'rate': '125000',
    'rating': '4.6',
    'type': 'Fiction',
    'category': 'Fiction',
    'image':
        'https://salt.tikicdn.com/cache/750x750/ts/product/5e/1b/d0/c29a43c58f7d8cfd7e720e59b15bf924.jpg.webp',
    'description':
        'Tác phẩm về tuổi thơ nghèo khó nhưng đầy mơ mộng của những đứa trẻ miền quê.',
    'author': 'Nguyễn Huy Thiệp',
    'age': '14+',
    'author_img':
        'https://upload.wikimedia.org/wikipedia/vi/2/25/Nguy%E1%BB%85n_Huy_Thi%E1%BB%87p.jpg',
    'seller': true,
    'language': 'VIETNAMESE',
    'is_cached': true
  },
  {
    'id': 'F011',
    'name': 'Lặng Lẽ Sapa',
    'rate': '105000',
    'rating': '4.8',
    'type': 'Fiction',
    'category': 'Fiction',
    'image': 'assets/images/books/lang_le_sapa.jpg',
    'description':
        'Tuyển tập truyện ngắn nổi tiếng của nhà văn Nguyễn Thành Long.',
    'author': 'Nguyễn Thành Long',
    'age': '14+',
    'author_img': 'assets/images/authors/nguyen_thanh_long.jpg',
    'seller': true,
    'language': 'VIETNAMESE',
    'is_cached': false
  },

  // CATEGORY: Non-Fiction - Sách Phi Hư Cấu
  {
    'id': 'NF006',
    'name': 'Điểm Đến Của Cuộc Đời',
    'rate': '170000',
    'rating': '4.9',
    'type': 'Non-Fiction',
    'category': 'Non-Fiction',
    'image':
        'https://product.hstatic.net/200000123069/product/diem_den_cuoc_doi_a9b0a83c56334c4e87e9a9f0c37cc9ce_master.jpg',
    'description':
        'Cuốn sách về ý nghĩa cuộc sống và những giá trị cốt lõi trong hành trình nhân sinh.',
    'author': 'Nguyên Phong',
    'age': '18+',
    'author_img':
        'https://blog.hocmai.vn/wp-content/uploads/2023/01/image-207.png',
    'seller': true,
    'language': 'VIETNAMESE',
    'is_cached': true
  },
  {
    'id': 'NF007',
    'name': 'Quẳng Gánh Lo Đi Và Vui Sống',
    'rate': '120000',
    'rating': '4.7',
    'type': 'Non-Fiction',
    'category': 'Non-Fiction',
    'image':
        'https://salt.tikicdn.com/cache/750x750/ts/product/c7/b1/18/c2e9d5d272ae79b8992a4cae1f52e9e4.jpg.webp',
    'description':
        'Những bài học giúp bạn giảm stress và sống tích cực hơn trong cuộc sống.',
    'author': 'Dale Carnegie',
    'age': '16+',
    'author_img':
        'https://upload.wikimedia.org/wikipedia/en/e/ef/Dale_Carnegie.jpg',
    'seller': true,
    'language': 'VIETNAMESE',
    'is_cached': true
  },
  {
    'id': 'NF008',
    'name': 'Sức Mạnh Của Thói Quen',
    'rate': '145000',
    'rating': '4.8',
    'type': 'Non-Fiction',
    'category': 'Non-Fiction',
    'image': 'assets/images/books/suc_manh_cua_thoi_quen.jpg',
    'description':
        'Khám phá cách thức thói quen vận hành và làm thế nào để thay đổi chúng.',
    'author': 'Charles Duhigg',
    'age': '16+',
    'author_img': 'assets/images/authors/charles_duhigg.jpg',
    'seller': true,
    'language': 'VIETNAMESE',
    'is_cached': false
  },
  {
    'id': 'NF009',
    'name': 'Hiệu Ứng Chim Mồi',
    'rate': '130000',
    'rating': '4.6',
    'type': 'Non-Fiction',
    'category': 'Non-Fiction',
    'image':
        'https://salt.tikicdn.com/cache/750x750/ts/product/a8/de/7d/082e28fe9645f5120e93dce60cf2b2e5.jpg.webp',
    'description':
        'Những trải nghiệm thực tế về tâm lý học và cách thức ra quyết định của con người.',
    'author': 'Hạo Nhiên',
    'age': '16+',
    'author_img':
        'https://i0.wp.com/tamlyhoctoipham.com/wp-content/uploads/2018/11/hao-nhien.jpg',
    'seller': true,
    'language': 'VIETNAMESE',
    'is_cached': true
  },
  {
    'id': 'NF010',
    'name': 'Kinh Tế Học Hài Hước',
    'rate': '150000',
    'rating': '4.5',
    'type': 'Non-Fiction',
    'category': 'Non-Fiction',
    'image': 'assets/images/books/kinh_te_hoc_hai_huoc.jpg',
    'description':
        'Giải thích các khái niệm kinh tế phức tạp bằng cách tiếp cận hài hước, dễ hiểu.',
    'author': 'Steven D. Levitt',
    'age': '18+',
    'author_img': 'assets/images/authors/steven_levitt.jpg',
    'seller': true,
    'language': 'VIETNAMESE',
    'is_cached': false
  },

  // CATEGORY: Promotions - Khuyến Mãi
  {
    'id': 'P005',
    'name': 'Đời Ngắn Đừng Ngủ Dài',
    'rate': '70000',
    'rating': '4.5',
    'type': 'Promotions',
    'category': 'Promotions',
    'image':
        'https://salt.tikicdn.com/cache/750x750/ts/product/0f/0e/10/8d66a29ca7cadadc4fc5af377e160a13.jpg.webp',
    'description':
        'Những bài học về sống trọn vẹn với cuộc đời - Giá khuyến mãi đặc biệt!',
    'author': 'Robin Sharma',
    'age': '16+',
    'author_img':
        'https://m.media-amazon.com/images/S/amzn-author-media-prod/f0tks3g34c85lso5qjf9i8cksh.jpg',
    'seller': true,
    'language': 'VIETNAMESE',
    'is_cached': true
  },
  {
    'id': 'P006',
    'name': 'Người Trong Muôn Nghề',
    'rate': '85000',
    'rating': '4.6',
    'type': 'Promotions',
    'category': 'Promotions',
    'image':
        'https://salt.tikicdn.com/cache/750x750/ts/product/9e/c6/5a/4cd13c6684c657fc3ffc3c1913baa0d0.jpg.webp',
    'description':
        'Cẩm nang hướng nghiệp với những góc nhìn thực tế - Giảm giá đặc biệt!',
    'author': 'Spiderum',
    'age': '16+',
    'author_img': 'https://spiderum.com/assets/images/spiderum-logo.png',
    'seller': true,
    'language': 'VIETNAMESE',
    'is_cached': true
  },
  {
    'id': 'P007',
    'name': 'Kỹ Năng Sống Cho Học Sinh',
    'rate': '55000',
    'rating': '4.7',
    'type': 'Promotions',
    'category': 'Promotions',
    'image': 'assets/images/books/ky_nang_song.jpg',
    'description':
        'Những kỹ năng thiết yếu giúp học sinh phát triển toàn diện - Ưu đãi mùa tựu trường!',
    'author': 'Nhiều tác giả',
    'age': '10+',
    'author_img': 'assets/images/authors/default_author.jpg',
    'seller': true,
    'language': 'VIETNAMESE',
    'is_cached': false
  },
  {
    'id': 'P008',
    'name': 'Nghĩ Giàu Làm Giàu',
    'rate': '75000',
    'rating': '4.8',
    'type': 'Promotions',
    'category': 'Promotions',
    'image':
        'https://salt.tikicdn.com/cache/w1200/ts/product/42/e3/76/864ef120078c91c1dfb1d83be9c687f8.jpg',
    'description':
        'Cuốn sách kinh điển về phát triển tư duy làm giàu - Giảm giá sốc!',
    'author': 'Napoleon Hill',
    'age': '18+',
    'author_img':
        'https://upload.wikimedia.org/wikipedia/commons/5/5a/Napoleon_Hill_headshot.jpg',
    'seller': true,
    'language': 'VIETNAMESE',
    'is_cached': true
  },
  {
    'id': 'P009',
    'name': 'Sherlock Holmes (Trọn Bộ)',
    'rate': '350000',
    'rating': '4.9',
    'type': 'Promotions',
    'category': 'Promotions',
    'image': 'assets/images/books/sherlock_holmes.jpg',
    'description':
        'Trọn bộ tác phẩm trinh thám nổi tiếng thế giới - Giá ưu đãi cho bộ sách!',
    'author': 'Arthur Conan Doyle',
    'age': '14+',
    'author_img': 'assets/images/authors/arthur_conan_doyle.jpg',
    'seller': true,
    'language': 'VIETNAMESE',
    'is_cached': false
  },

  // CATEGORY: Bestseller - Bán Chạy Nhất
  {
    'id': 'B006',
    'name': 'Rèn Luyện Tư Duy Phản Biện',
    'rate': '110000',
    'rating': '4.7',
    'type': 'Bestseller',
    'category': 'Bestseller',
    'image':
        'https://salt.tikicdn.com/cache/750x750/ts/product/22/b9/c8/dccdeb6e3451de745b65dbdb2c2eb326.jpg.webp',
    'description':
        'Hướng dẫn cách phát triển tư duy phản biện để đưa ra quyết định tốt hơn.',
    'author': 'Albert Rutherford',
    'age': '16+',
    'author_img':
        'https://bizweb.dktcdn.net/thumb/grande/100/350/165/articles/nguyen-nhat-anh.jpg',
    'seller': true,
    'language': 'VIETNAMESE',
    'is_cached': true
  },
  {
    'id': 'B007',
    'name': 'Hôm Nay Tôi Thất Tình',
    'rate': '95000',
    'rating': '4.6',
    'type': 'Bestseller',
    'category': 'Bestseller',
    'image':
        'https://salt.tikicdn.com/cache/750x750/ts/product/d0/58/d6/6085d9f9c47e32db3659e30504e1409e.jpg.webp',
    'description':
        'Những câu chuyện, lời khuyên dành cho những trái tim tan vỡ.',
    'author': 'Hạ Vũ',
    'age': '16+',
    'author_img':
        'https://kenh14cdn.com/203336854389633024/2022/2/17/photo-1-16450432518041476748413.jpg',
    'seller': true,
    'language': 'VIETNAMESE',
    'is_cached': true
  },
  {
    'id': 'B008',
    'name': 'Dạy Con Làm Giàu (Tập 1)',
    'rate': '88000',
    'rating': '4.8',
    'type': 'Bestseller',
    'category': 'Bestseller',
    'image': 'assets/images/books/day_con_lam_giau.jpg',
    'description':
        'Bài học về tài chính cá nhân được truyền đạt qua câu chuyện của tác giả.',
    'author': 'Robert Kiyosaki',
    'age': '18+',
    'author_img': 'assets/images/authors/robert_kiyosaki.jpg',
    'seller': true,
    'language': 'VIETNAMESE',
    'is_cached': false
  },
  {
    'id': 'B009',
    'name': 'Tiểu Sử Steve Jobs',
    'rate': '160000',
    'rating': '4.9',
    'type': 'Bestseller',
    'category': 'Bestseller',
    'image':
        'https://salt.tikicdn.com/cache/750x750/ts/product/e1/29/3a/d5c6879f2856e0c78c0585d3edee9a91.jpg.webp',
    'description':
        'Cuốn tiểu sử đầy đủ về cuộc đời và sự nghiệp của đồng sáng lập Apple.',
    'author': 'Walter Isaacson',
    'age': '16+',
    'author_img':
        'https://upload.wikimedia.org/wikipedia/commons/thumb/3/37/Walter_Isaacson_VF_2012_Shankbone_2.JPG/800px-Walter_Isaacson_VF_2012_Shankbone_2.JPG',
    'seller': true,
    'language': 'VIETNAMESE',
    'is_cached': true
  },
  {
    'id': 'B010',
    'name': 'Đừng Bao Giờ Đi Ăn Một Mình',
    'rate': '115000',
    'rating': '4.7',
    'type': 'Bestseller',
    'category': 'Bestseller',
    'image': 'assets/images/books/dung_bao_gio_di_an_mot_minh.jpg',
    'description':
        'Bí quyết xây dựng các mối quan hệ để thành công trong công việc và cuộc sống.',
    'author': 'Keith Ferrazzi',
    'age': '18+',
    'author_img': 'assets/images/authors/keith_ferrazzi.jpg',
    'seller': true,
    'language': 'VIETNAMESE',
    'is_cached': false
  },

  // CATEGORY: Cooking - Nấu Ăn (Thêm danh mục mới)
  {
    'id': 'C001',
    'name': '100 Món Ăn Ngon Mỗi Ngày',
    'rate': '180000',
    'rating': '4.8',
    'type': 'Cooking',
    'category': 'Cooking',
    'image':
        'https://salt.tikicdn.com/cache/750x750/ts/product/35/83/63/87915d7d6a2dc0ab34c2af459d029010.jpg.webp',
    'description':
        'Công thức chi tiết cho 100 món ăn ngon từ đơn giản đến phức tạp.',
    'author': 'Nguyễn Quỳnh Chi',
    'age': 'All',
    'author_img': 'https://i.ytimg.com/vi/xeKU6My1n5k/maxresdefault.jpg',
    'seller': true,
    'language': 'VIETNAMESE',
    'is_cached': true
  },
  {
    'id': 'C002',
    'name': 'Ẩm Thực Việt Nam',
    'rate': '220000',
    'rating': '4.9',
    'type': 'Cooking',
    'category': 'Cooking',
    'image': 'assets/images/books/am_thuc_viet_nam.jpg',
    'description':
        'Giới thiệu về văn hóa ẩm thực Việt Nam và cách chế biến các món đặc sản.',
    'author': 'Luke Nguyễn',
    'age': 'All',
    'author_img': 'assets/images/authors/luke_nguyen.jpg',
    'seller': true,
    'language': 'VIETNAMESE',
    'is_cached': false
  },
  {
    'id': 'C003',
    'name': 'Bánh Ngọt Cho Người Mới Bắt Đầu',
    'rate': '150000',
    'rating': '4.7',
    'type': 'Cooking',
    'category': 'Cooking',
    'image':
        'https://salt.tikicdn.com/cache/750x750/ts/product/6c/f5/14/d67c13df8eabb5ca98aafcd6fa4fc114.jpg.webp',
    'description':
        'Hướng dẫn cơ bản và công thức làm bánh ngọt dành cho người mới học làm bánh.',
    'author': 'Linh Trang',
    'age': 'All',
    'author_img':
        'https://kenh14cdn.com/thumb_w/660/203336854389633024/2023/5/18/cqmckahjcyzbznwfaacmf-yocxomz08nz2kv5wlk8k-6466208025cd0703e6e110f3-16843439402581169358651.jpeg',
    'seller': true,
    'language': 'VIETNAMESE',
    'is_cached': true
  },
  {
    'id': 'C004',
    'name': 'Nấu Ăn Dinh Dưỡng Cho Trẻ',
    'rate': '135000',
    'rating': '4.6',
    'type': 'Cooking',
    'category': 'Cooking',
    'image': 'assets/images/books/dinh_duong_cho_tre.jpg',
    'description':
        'Hướng dẫn chế biến các món ăn đảm bảo dinh dưỡng cho trẻ từ 6 tháng đến 6 tuổi.',
    'author': 'BS. Trần Thị Huyền',
    'age': 'All',
    'author_img': 'assets/images/authors/bs_huyen.jpg',
    'seller': true,
    'language': 'VIETNAMESE',
    'is_cached': false
  },
  {
    'id': 'C005',
    'name': 'Cocktail Đơn Giản Tại Nhà',
    'rate': '165000',
    'rating': '4.5',
    'type': 'Cooking',
    'category': 'Cooking',
    'image':
        'https://salt.tikicdn.com/cache/750x750/ts/product/4a/90/69/e2dcf0e5bd287d8579ae949f2838133a.jpg.webp',
    'description':
        'Hướng dẫn pha chế các loại cocktail phổ biến với nguyên liệu dễ tìm.',
    'author': 'Trần Minh Tuấn',
    'age': '18+',
    'author_img': 'https://i.ytimg.com/vi/FJR34V5FR-c/maxresdefault.jpg',
    'seller': true,
    'language': 'VIETNAMESE',
    'is_cached': true
  },

  // CATEGORY: Self-Help - Phát Triển Bản Thân (Thêm danh mục mới)
  {
    'id': 'SH001',
    'name': 'Đắc Nhân Tâm (Bản Đặc Biệt)',
    'rate': '110000',
    'rating': '4.9',
    'type': 'Self-Help',
    'category': 'Self-Help',
    'image':
        'https://salt.tikicdn.com/cache/750x750/ts/product/41/c5/d0/6125e3eadf86f3ca2dcc0826089bafb7.jpg.webp',
    'description':
        'Phiên bản đặc biệt của cuốn sách kinh điển về nghệ thuật thu phục lòng người.',
    'author': 'Dale Carnegie',
    'age': '16+',
    'author_img':
        'https://upload.wikimedia.org/wikipedia/en/e/ef/Dale_Carnegie.jpg',
    'seller': true,
    'language': 'VIETNAMESE',
    'is_cached': true
  },
  {
    'id': 'SH002',
    'name': '7 Thói Quen Hiệu Quả',
    'rate': '170000',
    'rating': '4.8',
    'type': 'Self-Help',
    'category': 'Self-Help',
    'image': 'assets/images/books/7_thoi_quen_hieu_qua.jpg',
    'description':
        'Bảy thói quen giúp bạn thay đổi cuộc sống và đạt được thành công.',
    'author': 'Stephen R. Covey',
    'age': '16+',
    'author_img': 'assets/images/authors/stephen_covey.jpg',
    'seller': true,
    'language': 'VIETNAMESE',
    'is_cached': false
  },
  {
    'id': 'SH003',
    'name': 'Người Giàu Nhất Thành Babylon',
    'rate': '95000',
    'rating': '4.7',
    'type': 'Self-Help',
    'category': 'Self-Help',
    'image':
        'https://salt.tikicdn.com/cache/750x750/ts/product/44/5b/41/893d4ca2dd37d075513a5883852fa561.jpg.webp',
    'description':
        'Những bài học tài chính cá nhân vượt thời gian từ nền văn minh Babylon cổ đại.',
    'author': 'George S. Clason',
    'age': '16+',
    'author_img':
        'https://upload.wikimedia.org/wikipedia/en/9/90/TheRichestManInBabylon.jpg',
    'seller': true,
    'language': 'VIETNAMESE',
    'is_cached': true
  },
  {
    'id': 'SH004',
    'name': 'Không Phải Lỗi Của Bạn',
    'rate': '125000',
    'rating': '4.5',
    'type': 'Self-Help',
    'category': 'Self-Help',
    'image': 'assets/images/books/khong_phai_loi_cua_ban.jpg',
    'description':
        'Giúp bạn vượt qua tổn thương từ quá khứ và xây dựng lòng tự trọng lành mạnh.',
    'author': 'Megan Devine',
    'age': '18+',
    'author_img': 'assets/images/authors/megan_devine.jpg',
    'seller': true,
    'language': 'VIETNAMESE',
    'is_cached': false
  },
  {
    'id': 'SH005',
    'name': 'Thay Đổi Cuộc Sống Với Nhân Số Học',
    'rate': '145000',
    'rating': '4.6',
    'type': 'Self-Help',
    'category': 'Self-Help',
    'image':
        'https://salt.tikicdn.com/cache/750x750/ts/product/99/b2/35/c4ca9dded90d26c0c0818e12bc150242.jpg.webp',
    'description':
        'Khám phá bản thân và số mệnh thông qua khoa học nhân số học.',
    'author': 'Lê Đỗ Quỳnh Hương',
    'age': '16+',
    'author_img':
        'https://bizweb.dktcdn.net/100/336/794/articles/le-do-quynh-huong-va-dan-tre-1.jpg',
    'seller': true,
    'language': 'VIETNAMESE',
    'is_cached': true
  },
];

// Hàm helper để chuyển đổi từ chuỗi giá sang double
double parsePrice(String price) {
  return double.parse(price);
}

// Hàm upload data lên Firebase
void uploadBooksToFirebase() {
  // Triển khai chức năng upload lên Firebase tại đây
  // Đây là mẫu để chạy trong ứng dụng của bạn
  /*
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  CollectionReference books = firestore.collection('books');
  
  for (var book in firebaseBooks) {
    books.add(book).then((value) {
      print("Book added with ID: ${value.id}");
    }).catchError((error) {
      print("Failed to add book: $error");
    });
  }
  */
}

// Hàm lấy book phục vụ việc hiển thị ảnh (asset hoặc cached)
Future<ImageProvider> getBookImage(Map<String, dynamic> book) async {
  bool isCached = book['is_cached'] ?? false;
  String imageUrl = book['image'];

  if (isCached) {
    // Sử dụng CachedNetworkImageProvider cho ảnh từ internet
    return NetworkImage(imageUrl);
  } else {
    // Sử dụng AssetImage cho ảnh local
    return AssetImage(imageUrl);
  }
}

// Hàm lấy danh sách sách theo category
List<Map<String, dynamic>> getBooksByCategory(String category) {
  if (category == 'All') {
    return firebaseBooks;
  }
  return firebaseBooks.where((book) => book['category'] == category).toList();
}
