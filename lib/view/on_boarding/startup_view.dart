import 'package:books_store/view/login/welcome_view.dart';
import 'package:books_store/view/main_tabview/main_tabview.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StartupView extends StatefulWidget {
  const StartupView({super.key});

  @override
  State createState() => _StartupViewState();
}

class _StartupViewState extends State {
  @override
  void initState() {
    super.initState();
    goWelcomePage();
  }

  void goWelcomePage() async {
    await Future.delayed(const Duration(seconds: 3));
    checkLoginStatus();
  }

  void checkLoginStatus() {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
       Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const MainTabView()));
    } else {
       Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const WelcomeView()));
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            "assets/img/splash_bg.png",
            width: media.width,
            height: media.height,
            fit: BoxFit.cover,
          ),
          Image.asset(
            "assets/img/app_logo.png",
            width: media.width * 0.55,
            height: media.width * 0.55,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
}
