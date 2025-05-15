import 'package:flutter/foundation.dart';
import '../models/cart.dart';
import '../models/book.dart';

class CartProvider extends ChangeNotifier {
  final Cart _cart = Cart();

  List<CartItem> get items => _cart.items;
  double get totalAmount => _cart.totalAmount;
  int get itemCount => _cart.itemCount;

  void addItem(Book book) {
    _cart.addItem(book);
    notifyListeners();
  }

  void removeItem(Book book) {
    _cart.removeItem(book);
    notifyListeners();
  }

  void updateQuantity(Book book, int quantity) {
    _cart.updateQuantity(book, quantity);
    notifyListeners();
  }

  void clear() {
    _cart.clear();
    notifyListeners();
  }

  bool isInCart(Book book) {
    return _cart.items.any((item) => item.book.title == book.title);
  }

  int getQuantity(Book book) {
    final item = _cart.items.firstWhere(
      (item) => item.book.title == book.title,
      orElse: () => CartItem(book: book, quantity: 0),
    );
    return item.quantity;
  }
}
