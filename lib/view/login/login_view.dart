import 'package:books_store/common/extension.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../common/color_extension.dart';
import '../../common/globs.dart';
import '../../common_widget/round_button.dart';
import '../../common_widget/round_icon_button.dart';
import '../../common_widget/round_textfield.dart';
import '../../services/auth_service.dart';
import '../admin/admin_dashboard.dart';
import '../main_tabview/main_tabview.dart';
import 'rest_password_view.dart';
import 'sing_up_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  TextEditingController txtEmail = TextEditingController();
  TextEditingController txtPassword = TextEditingController();
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 64,
              ),
              Text(
                "Đăng nhập",
                style: GoogleFonts.poppins(
                    color: TColor.primaryText,
                    fontSize: 30,
                    fontWeight: FontWeight.w800),
              ),
              Text(
                "Nhập thông tin tài khoản của bạn",
                style: GoogleFonts.poppins(
                    color: TColor.secondaryText,
                    fontSize: 16,
                    fontWeight: FontWeight.w500),
              ),
              const SizedBox(
                height: 30,
              ),
              RoundTextfield(
                hintText: "Email của bạn",
                controller: txtEmail,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(
                height: 25,
              ),
              RoundTextfield(
                hintText: "Mật khẩu",
                controller: txtPassword,
                obscureText: true,
              ),
              const SizedBox(
                height: 30,
              ),
              RoundButton(
                  title: "Đăng nhập",
                  onPressed: () {
                    btnLogin();
                  }),
              const SizedBox(
                height: 8,
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ResetPasswordView(),
                    ),
                  );
                },
                child: Text(
                  "Quên mật khẩu?",
                  style: GoogleFonts.poppins(
                      color: TColor.secondaryText,
                      fontSize: 14,
                      fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Text(
                "hoặc đăng nhập với",
                style: GoogleFonts.poppins(
                    color: TColor.secondaryText,
                    fontSize: 14,
                    fontWeight: FontWeight.w500),
              ),
              const SizedBox(
                height: 30,
              ),
              const SizedBox(
                height: 25,
              ),
              RoundIconButton(
                icon: "assets/img/google_logo.png",
                title: "Đăng nhập với Google",
                color: const Color(0xffDD4B39),
                onPressed: () {
                  btnLoginWithGoogle();
                },
              ),
              const SizedBox(
                height: 80,
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SignUpView(),
                    ),
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Chưa có tài khoản? ",
                      style: GoogleFonts.poppins(
                          color: TColor.secondaryText,
                          fontSize: 14,
                          fontWeight: FontWeight.w500),
                    ),
                    Text(
                      "Đăng ký",
                      style: GoogleFonts.poppins(
                          color: TColor.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void btnLogin() async {
    final result = await _authService.loginWithEmailPassword(
      txtEmail.text,
      txtPassword.text,
    );

    if (result['success']) {
      // Get user role immediately after login
      String userRole = await _authService.getUserRole();
      print('User role after login: $userRole');

      // Navigate based on role
      if (userRole == 'admin') {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const AdminDashboard(),
          ),
          (route) => false,
        );
      } else if (userRole == 'seller') {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const MainTabView(),
          ),
          (route) => false,
        );
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const MainTabView(),
          ),
          (route) => false,
        );
      }
    } else {
      mdShowAlert(Globs.appName, result['message'], () {});
    }
  }

  void btnLoginWithGoogle() async {
    final result = await _authService.loginWithGoogle();

    if (result['success']) {
      // Get user role immediately after login
      String userRole = await _authService.getUserRole();
      print('User role after Google login: $userRole');

      // Navigate based on role
      if (userRole == 'admin') {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const AdminDashboard(),
          ),
          (route) => false,
        );
      } else if (userRole == 'seller') {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const MainTabView(),
          ),
          (route) => false,
        );
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const MainTabView(),
          ),
          (route) => false,
        );
      }
    } else {
      mdShowAlert(Globs.appName, result['message'], () {});
    }
  }
}
