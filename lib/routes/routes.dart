
// import 'package:flutter/material.dart';

// class AppRoutes {
//   AppRoutes._();

//   static const String home = '/home';
//   static const String login = '/login';
//   static const String signUp = '/signUp';
//   static const String getstartedsplash = '/get-started-splash';
//   static const String authgate = '/auth-gate';
//   static const String verifyMailScreen = '/Verify-mail';
//   static const String completeProfile = '/completeProfile';
//   static const String forgotPassword = '/forgotPassword';
//   static const String mainNavBar = '/mainNavBar';
//   static const String productDetail = '/productDetail';
//   static const String checkOutScreen = '/checkOutScreen';
//   static const String changePassw = '/changePassw';
//   // Admin Panel
//   static const String adminhome = '/adminhome';
//   static const String uploadProduct = '/upload-product';
//   static const String allProducts = '/all-products';

//   static Route<dynamic> generateRoute(RouteSettings settings) {
//     if (settings.name == null || settings.name!.trim().isEmpty) {
//       return MaterialPageRoute(builder: (_) => const AuthGate());
//     }
//     switch (settings.name) {
//       case home:
//         return MaterialPageRoute(builder: (_) => const HomeScreen());
//       case login:
//         return MaterialPageRoute(builder: (_) => const LoginScreen());
//       case getstartedsplash:
//         return MaterialPageRoute(builder: (_) => const SplashScreen());
//       case authgate:
//         return MaterialPageRoute(builder: (_) => const AuthGate());
//       case signUp:
//         return MaterialPageRoute(builder: (_) => const SignUpScreen());
//       case verifyMailScreen:
//         final args = settings.arguments;
//         if (args is String && args.isNotEmpty) {
//           return MaterialPageRoute(
//             builder: (_) => EmailVerifyScreen(email: args),
//           );
//         } else {
//           return MaterialPageRoute(
//             builder: (_) => const Scaffold(
//               body: Center(child: Text('Email argument is missing')),
//             ),
//           );
//         }
//       case completeProfile:
//         return MaterialPageRoute(builder: (_) => const CompleteProfileScreen());
//       case forgotPassword:
//         return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
//       case adminhome:
//         return MaterialPageRoute(builder: (_) => const AdminPanelScreen());
//       case uploadProduct:
//         return MaterialPageRoute(builder: (_) => const AdminProductsUpload());
//       case allProducts:
//         return MaterialPageRoute(builder: (_) => const AdminAllProducts());
//       case mainNavBar:
//         return MaterialPageRoute(builder: (_) => const MainNavScreen());
//       case changePassw:
//         return MaterialPageRoute(builder: (_) => const ChangePassword());
//       case productDetail:
//         if (settings.arguments is String) {
//           final productId = settings.arguments as String;
//           return MaterialPageRoute(
//             builder: (_) => ProductScreen(productId: productId),
//           );
//         } else {
//           return MaterialPageRoute(
//             builder: (_) => const Scaffold(
//               body: Center(child: Text('Product data is missing or invalid')),
//             ),
//           );
//         }
//       case AppRoutes.checkOutScreen:
//         final args =
//             settings.arguments as double; // total passed from CartScreen
//         return MaterialPageRoute(builder: (_) => CheckoutScreen(total: args));
//       default:
//         return MaterialPageRoute(builder: (_) => const Error404Screen());
//     }
//   }
// }
