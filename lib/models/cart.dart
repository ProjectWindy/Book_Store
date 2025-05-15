import 'book.dart';

class CartItem {
  final Book book;
  int quantity;

  CartItem({
    required this.book,
    this.quantity = 1,
  });

  double get totalPrice => book.price * quantity;
}

class Cart {
  static final Cart _instance = Cart._internal();
  factory Cart() => _instance;
  Cart._internal();

  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  double get totalAmount {
    return _items.fold(0, (sum, item) => sum + item.totalPrice);
  }

  int get itemCount => _items.length;

  void addItem(Book book) {
    final existingItem = _items.firstWhere(
      (item) => item.book.title == book.title,
      orElse: () => CartItem(book: book, quantity: 0),
    );

    if (existingItem.quantity == 0) {
      _items.add(CartItem(book: book));
    } else {
      existingItem.quantity++;
    }
  }

  void removeItem(Book book) {
    _items.removeWhere((item) => item.book.title == book.title);
  }

  void updateQuantity(Book book, int quantity) {
    final existingItem = _items.firstWhere(
      (item) => item.book.title == book.title,
      orElse: () => CartItem(book: book, quantity: 0),
    );

    if (quantity <= 0) {
      removeItem(book);
    } else {
      existingItem.quantity = quantity;
    }
  }

  void clear() {
    _items.clear();
  }
}
