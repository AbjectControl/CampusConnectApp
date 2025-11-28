import 'package:cconnect/data/models/userModel.dart';
import 'package:cconnect/features/authentication/screens/login/screens/Login.dart';
import 'package:cconnect/features/chat/controllers/chat_provider.dart';
import 'package:cconnect/features/personalization/controllers/userProvider.dart';
import 'package:cconnect/routes/auth_gate.dart';
import 'package:cconnect/routes/routes.dart';
import 'package:cconnect/utils/helpers/snack_bar.dart';
import 'package:cconnect/utils/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

import 'package:cconnect/data/repositories/functions/FireBaseFunctions/chat_repository.dart';
import 'package:cconnect/data/repositories/functions/FireBaseFunctions/friendship_repository.dart';
import 'package:cconnect/data/repositories/functions/FireBaseFunctions/user.dart';
import 'package:cconnect/data/repositories/interfaces/ichat.dart';
import 'package:cconnect/data/repositories/interfaces/ifriendship.dart';
import 'package:cconnect/data/repositories/interfaces/igroup.dart';
import 'package:cconnect/data/repositories/interfaces/iuser.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MultiProvider(
      providers: [
        // Repositories (Services)
        Provider<IUserRepository>(create: (_) => UserRepository()),
        Provider<IChatRepository>(create: (_) => ChatRepository()),
        Provider<IGroupRepository>(create: (_) => ChatRepository()),
        Provider<IFriendshipRepository>(create: (_) => FriendshipRepository()),

        // ViewModels (Providers)
        ChangeNotifierProvider(
          create: (context) =>
              UserProvider(userRepository: context.read<IUserRepository>()),
        ),
        ChangeNotifierProvider(
          create: (_) => ChatProvider(
            chatRepository: ChatRepository(),
            groupRepository:
                ChatRepository(), // ChatRepository implements IGroupRepository
            friendshipRepository: FriendshipRepository(),
            userRepository: UserRepository(),
          ),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (state == AppLifecycleState.resumed) {
      userProvider.updateOnlineStatus(true);
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      userProvider.updateOnlineStatus(false);
    }
  }

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
