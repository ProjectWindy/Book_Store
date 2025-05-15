class Book {
  final String id;
  final String title;
  final String author;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final bool isUpcoming;
  final String? releaseDate;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    this.isUpcoming = false,
    this.releaseDate,
  });

  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      author: map['author'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      imageUrl: map['imageUrl'] ?? '',
      category: map['category'] ?? '',
      isUpcoming: map['isUpcoming'] ?? false,
      releaseDate: map['releaseDate'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
      'isUpcoming': isUpcoming,
      'releaseDate': releaseDate,
    };
  }
}
