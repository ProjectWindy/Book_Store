import 'package:flutter/material.dart';
import 'package:books_store/common_widget/round_button.dart';

import '../../common/color_extension.dart';
import 'login_view.dart';
import 'sing_up_view.dart';

class WelcomeView extends StatefulWidget {
  const WelcomeView({super.key});

  @override
  State<WelcomeView> createState() => _WelcomeViewState();
}

class _WelcomeViewState extends State<WelcomeView> {
  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Image.asset(
                  "assets/img/welcome_top_shape.png",
                  width: media.width,
                ),
                Image.asset(
                  "assets/img/app_logo.png",
                  // width: media.width * 0.55,
                  // height: media.width * 0.55,
                  fit: BoxFit.contain,
                ),
              ],
            ),
            SizedBox(
              height: media.width * 0.1,
            ),
            Text(
              "Chào mừng đến với hiệu sách trực tuyến tuyệt vời nhất của bạn!",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: TColor.secondaryText,
                  fontSize: 20,
                  fontWeight: FontWeight.w500),
            ),
            SizedBox(
              height: media.width * 0.1,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: RoundButton(
                title: "Login",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginView(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: RoundButton(
                title: "Create an Account",
                type: RoundButtonType.textPrimary,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SignUpView(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}
