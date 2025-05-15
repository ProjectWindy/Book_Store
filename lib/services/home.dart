import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HomeProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> popularRestaurants = [];
  List<Map<String, dynamic>> mostPopular = [];
  List<Map<String, dynamic>> recentItems = [];
  List<Map<String, dynamic>> searchResults = [];

  bool isLoading = true;
  bool isSearching = false;

  HomeProvider() {
    fetchData();
  }

  /// Lấy dữ liệu từ Firestore
  Future<void> fetchData() async {
    try {
      final snapshots = await Future.wait([
        _firestore.collection('popular_items').get(),
        _firestore.collection('most_popular_items').get(),
        _firestore.collection('recent_items').get(),
      ]);

      popularRestaurants = snapshots[0].docs.map((doc) => doc.data()).toList();
      mostPopular = snapshots[1].docs.map((doc) => doc.data()).toList();
      recentItems = snapshots[2].docs.map((doc) => doc.data()).toList();

      isLoading = false;
      notifyListeners();
    } catch (e) {
       isLoading = false;
      notifyListeners();
    }
  }

  /// Tìm kiếm sản phẩm theo tên hoặc mô tả
  Future<void> searchProducts(String query) async {
    if (query.isEmpty) {
      clearSearch();
      return;
    }

    try {
      isSearching = true;
      notifyListeners();

      query = query.toLowerCase();

      final futures = [
        _firestore
            .collection('products')
            .where('name', isGreaterThanOrEqualTo: query)
            .where('name', isLessThanOrEqualTo: '$query\uf8ff')
            .get(),
        _firestore
            .collection('products')
            .where('description', isGreaterThanOrEqualTo: query)
            .where('description', isLessThanOrEqualTo: '$query\uf8ff')
            .get(),
      ];

      final results = await Future.wait(futures);

      final Set<String> addedIds = {};
      searchResults = [];

      for (var snapshot in results) {
        for (var doc in snapshot.docs) {
          var data = doc.data();
          if (addedIds.add(doc.id)) {
            data['id'] = doc.id;
            searchResults.add(data);
          }
        }
      }

      isSearching = false;
      notifyListeners();
    } catch (e) {
       isSearching = false;
      notifyListeners();
    }
  }

  /// Xóa kết quả tìm kiếm
  void clearSearch() {
    searchResults.clear();
    notifyListeners();
  }
}
