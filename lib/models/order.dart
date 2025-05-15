import 'package:flutter/material.dart';
import 'book.dart';
import 'cart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/seed_books_data.dart';

enum OrderStatus {
  pending, // Đã đặt
  processing, // Đang xử lý
  shipped, // Đã giao
  cancelled // Đã hủy
}

class PaymentMethod {
  final String name;
  final String icon;

  PaymentMethod({
    required this.name,
    required this.icon,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'icon': icon,
    };
  }

  factory PaymentMethod.fromMap(Map<String, dynamic> map) {
    return PaymentMethod(
      name: map['name'] ?? '',
      icon: map['icon'] ?? '',
    );
  }
}

class Order {
  final String id;
  final String userId;
  final List<CartItem> items;
  final double totalAmount;
  final String address;
  final String phone;
  final OrderStatus status;
  final DateTime createdAt;
  final PaymentMethod? paymentMethod;
  final double deliveryFee;
  final double subtotal;
  final String? voucherCode;
  final double discountAmount;

  Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.address,
    required this.phone,
    this.status = OrderStatus.pending,
    DateTime? createdAt,
    this.paymentMethod,
    this.deliveryFee = 2.0,
    required this.subtotal,
    this.voucherCode,
    this.discountAmount = 0.0,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'items': items
          .map((item) => {
                'bookId': item.book.id,
                'title': item.book.title,
                'price': item.book.price,
                'quantity': item.quantity,
                'cover': item.book.cover,
                'author': item.book.author,
                'authorImg': item.book.authorImg,
                'rating': item.book.rating,
                'genre': item.book.genre,
                'language': item.book.lanugage,
                'age': item.book.age,
                'summary': item.book.summary,
                'showImage': item.book.showImage,
                'seller': item.book.seller,
              })
          .toList(),
      'totalAmount': totalAmount,
      'address': address,
      'phone': phone,
      'status': status.toString(),
      'createdAt': Timestamp.fromDate(createdAt),
      'paymentMethod': paymentMethod?.toMap(),
      'deliveryFee': deliveryFee,
      'subtotal': subtotal,
      'voucherCode': voucherCode,
      'discountAmount': discountAmount,
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'],
      userId: map['userId'],
      items: (map['items'] as List)
          .map((item) => CartItem(
                book: Book(
                  id: item['bookId'],
                  title: item['title'],
                  price: item['price'],
                  cover: item['cover'] ?? '',
                  author: item['author'] ?? '',
                  authorImg: item['authorImg'] ?? '',
                  rating: item['rating'] ?? 0.0,
                  genre: item['genre'] ?? '',
                  lanugage: item['language'] ?? '',
                  age: item['age'] ?? '',
                  summary: item['summary'] ?? '',
                  showImage: item['showImage'] ?? '',
                  seller: item['seller'] ?? false,
                  category: map['type'] ?? ' ',
                ),
                quantity: item['quantity'],
              ))
          .toList(),
      totalAmount: map['totalAmount'],
      address: map['address'],
      phone: map['phone'],
      status: OrderStatus.values.firstWhere(
        (e) => e.toString() == map['status'],
        orElse: () => OrderStatus.pending,
      ),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      paymentMethod: map['paymentMethod'] != null
          ? PaymentMethod.fromMap(map['paymentMethod'])
          : null,
      deliveryFee: map['deliveryFee'] ?? 2.0,
      subtotal: map['subtotal'] ?? map['totalAmount'] - 2.0,
      voucherCode: map['voucherCode'],
      discountAmount: map['discountAmount'] ?? 0.0,
    );
  }

  String get statusText {
    switch (status) {
      case OrderStatus.pending:
        return "Pending";
      case OrderStatus.processing:
        return "Processing";
      case OrderStatus.shipped:
        return "Shipped";
      case OrderStatus.cancelled:
        return "Cancelled";
    }
  }

  Color get statusColor {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.processing:
        return Colors.blue;
      case OrderStatus.shipped:
        return Colors.purple;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }
}

// Sample order data
final List<Order> orders = [
  Order(
    id: "ORD001",
    userId: "USER001",
    items: [
      CartItem(
        book: mapToBook(seedBooks[0]),
        quantity: 2,
      ),
      CartItem(
        book: mapToBook(seedBooks[1]),
        quantity: 1,
      ),
    ],
    totalAmount: 71.35,
    address: "123 Main St",
    phone: "555-1234",
    status: OrderStatus.shipped,
    paymentMethod: PaymentMethod(
      name: "Credit Card",
      icon: "assets/img/credit_card.png",
    ),
    deliveryFee: 2.0,
    subtotal: 69.35,
  ),
  Order(
    id: "ORD002",
    userId: "USER002",
    items: [
      CartItem(
        book: mapToBook(seedBooks[2]),
        quantity: 1,
      ),
    ],
    totalAmount: 20.14,
    address: "456 Oak Ave",
    phone: "555-5678",
    status: OrderStatus.shipped,
    paymentMethod: PaymentMethod(
      name: "PayPal",
      icon: "assets/img/paypal.png",
    ),
    deliveryFee: 2.0,
    subtotal: 18.14,
  ),
  Order(
    id: "ORD003",
    userId: "USER003",
    items: [
      CartItem(
        book: mapToBook(seedBooks[3]),
        quantity: 3,
      ),
    ],
    totalAmount: 58.20,
    address: "789 Pine St",
    phone: "555-9012",
    status: OrderStatus.processing,
    paymentMethod: PaymentMethod(
      name: "Debit Card",
      icon: "assets/img/debit_card.png",
    ),
    deliveryFee: 2.0,
    subtotal: 56.20,
  ),
];
