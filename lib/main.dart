import 'package:books_store/common/color_extension.dart';
import 'package:books_store/common/locator.dart';
import 'package:books_store/common/service_call.dart';
import 'package:books_store/data/upload_books_data.dart';
import 'package:books_store/firebase_options.dart';
import 'package:books_store/screens/order_detail_screen.dart';
import 'package:books_store/screens/order_management_screen.dart';
import 'package:books_store/services/auth_service.dart';
import 'package:books_store/services/home.dart';
import 'package:books_store/services/notification_service.dart';
import 'package:books_store/services/payment_service.dart';
import 'package:books_store/services/voucher_service.dart';
import 'package:books_store/view/admin/admin_dashboard.dart';
import 'package:books_store/view/login/welcome_view.dart';
import 'package:books_store/view/main_tabview/main_tabview.dart';
import 'package:books_store/view/on_boarding/startup_view.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'common/globs.dart';
import 'providers/cart_provider.dart';

class AppInitializer {
  static SharedPreferences? prefs;
  static final NotificationService notificationService = NotificationService();
  static final VoucherService voucherService = VoucherService();
  static final PaymentService paymentService = PaymentService();

  static Future<void> initialize() async {
    try {
      WidgetsFlutterBinding.ensureInitialized();
      await EasyLocalization.ensureInitialized();
      await initializeDateFormatting('vi', null);
      await initializeDateFormatting('en', null);
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // Initialize services
      setUpLocator();
      await notificationService.initialize();
      await paymentService.initialize();
      prefs = await SharedPreferences.getInstance();
      Globs.prefs = prefs;

      configLoading();
    } catch (e) {
      print('Error initializing app: $e');
    }
  }

  static void configLoading() {
    EasyLoading.instance
      ..indicatorType = EasyLoadingIndicatorType.ring
      ..loadingStyle = EasyLoadingStyle.custom
      ..indicatorSize = 45.0
      ..radius = 5.0
      ..progressColor = TColor.primaryText
      ..backgroundColor = TColor.primary
      ..indicatorColor = Colors.yellow
      ..textColor = TColor.primaryText
      ..userInteractions = false
      ..dismissOnTap = false;
  }

  static Future<Widget> getInitialScreen() async {
    if (Globs.udValueBool(Globs.userLogin)) {
      ServiceCall.userPayload = Globs.udValue(Globs.userPayload);
      final authService = AuthService();
      String userRole = await authService.getUserRole();
      ServiceCall.userRole = userRole;

      switch (userRole.toLowerCase()) {
        case 'admin':
          return const AdminDashboard();
        case 'seller':
          return const MainTabView();
        default:
          return const MainTabView();
      }
    }
    return const StartupView();
  }
}

void main() async {
  await AppInitializer.initialize();
  final initialScreen = await AppInitializer.getInitialScreen();

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en'),
        Locale('vi'),
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('vi'),
      startLocale: const Locale('vi'),
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => HomeProvider()),
          ChangeNotifierProvider(create: (context) => CartProvider()),
        ],
        child: MyApp(
          defaultHome: initialScreen,
        ),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  final Widget defaultHome;
  const MyApp({super.key, required this.defaultHome});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Books Store',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: "Metropolis",
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: widget.defaultHome,
      navigatorKey: locator<NavigationService>().navigatorKey,
      onGenerateRoute: (routeSettings) {
        switch (routeSettings.name) {
          case "welcome":
            return MaterialPageRoute(builder: (context) => const WelcomeView());
          case "home":
            return MaterialPageRoute(builder: (context) => const MainTabView());
          case "admin":
            return MaterialPageRoute(
                builder: (context) => const AdminDashboard());
          case "upload_books":
            return MaterialPageRoute(
                builder: (context) => const UploadBooksDataScreen());
          case "order_management":
            return MaterialPageRoute(
                builder: (context) => const OrderManagementScreen());
          case "order_detail":
            final args = routeSettings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
                builder: (context) => OrderDetailScreen(
                      orderId: args['orderId'],
                    ));
          default:
            return MaterialPageRoute(
              builder: (context) => Scaffold(
                body: Center(
                  child: Text("No path for ${routeSettings.name}"),
                ),
              ),
            );
        }
      },
      builder: (context, child) {
        return FlutterEasyLoading(child: child);
      },
    );
  }
}
