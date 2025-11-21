import 'package:cconnect/data/models/userModel.dart';
import 'package:cconnect/features/authentication/screens/login/screens/Login.dart';
import 'package:cconnect/features/personalization/controllers/userProvider.dart';
import 'package:cconnect/routes/auth_gate.dart';
import 'package:cconnect/routes/routes.dart';
import 'package:cconnect/utils/helpers/snack_bar.dart';
import 'package:cconnect/utils/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => UserProvider())],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: SnackbarService.messengerKey,
      debugShowCheckedModeBanner: false,
      title: 'Campus Connect',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      onGenerateRoute: AppRoutes.generateRoute,
      home: const AuthGate(),
    );
  }
}

// HomeScreen stays as you defined it
class HomeScreen extends StatelessWidget {
  final User user;

  const HomeScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Welcome ${user.email}")),
      body: const Center(child: Text("Logged in successfully!")),
    );
  }
}
