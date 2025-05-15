import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:books_store/common/globs.dart';
import 'package:books_store/common/locator.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

typedef ResSuccess = Future<void> Function(Map<String, dynamic>);
typedef ResFailure = Future<void> Function(dynamic);

class ServiceCall {
  static final NavigationService navigationService =
      locator<NavigationService>();
  static Map userPayload = {};
  static String userRole = 'users';

  static String getUserRoleType() {
    switch (userRole.toLowerCase()) {
      case 'admin':
        return 'admin';
      case 'seller':
        return 'seller';
      default:
        return 'user';
    }
  }

  static Future<void> checkUserRoleAndNavigate() async {
    try {
      if (kDebugMode) {
        print('Starting role check...');
      }

      // Lấy thông tin user từ Firebase
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        if (kDebugMode) {
          print('Current user UID: ${user.uid}');
        }

        // Lấy document của user từ Firestore
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          final role = userDoc.data()?['role'] ?? 'user';
          userRole = role;

          if (kDebugMode) {
            print('User role from Firestore: $role');
            print('Current ServiceCall.userRole: $userRole');
          }

          // Điều hướng dựa trên role
          switch (role.toLowerCase()) {
            case 'admin':
              if (kDebugMode) {
                print('Navigating to admin_home');
              }
              navigationService.navigateTo("admin_home");
              break;
            case 'seller':
              if (kDebugMode) {
                print('Navigating to seller_home');
              }
              navigationService.navigateTo("seller_home");
              break;
            default:
              if (kDebugMode) {
                print('Navigating to user_home');
              }
              navigationService.navigateTo("user_home");
          }
        } else {
          if (kDebugMode) {
            print('User document not found in Firestore');
          }
        }
      } else {
        if (kDebugMode) {
          print('No current user found');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error checking user role: $e');
      }
      navigationService.navigateTo("welcome");
    }
  }

  static void post(Map<String, dynamic> parameter, String path,
      {bool isToken = false, ResSuccess? withSuccess, ResFailure? failure}) {
    Future(() {
      try {
        var headers = {'Content-Type': 'application/x-www-form-urlencoded'};

        http
            .post(Uri.parse(path), body: parameter, headers: headers)
            .then((value) {
          if (kDebugMode) {
            print(value.body);
          }
          try {
            var jsonObj =
                json.decode(value.body) as Map<String, dynamic>? ?? {};

            if (withSuccess != null) withSuccess(jsonObj);
          } catch (err) {
            if (failure != null) failure(err.toString());
          }
        }).catchError((e) {
          if (failure != null) failure(e.toString());
        });
      } catch (err) {
        if (failure != null) failure(err.toString());
      }
    });
  }

  static logout() {
    Globs.udBoolSet(false, Globs.userLogin);
    userPayload = {};
    navigationService.navigateTo("welcome");
  }
}
