// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:loading_animation_widget/loading_animation_widget.dart';

// class AuthGate extends StatelessWidget {
//   const AuthGate({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     return StreamBuilder(
//       stream: FirebaseAuthService().authStateChanges,
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return Scaffold(body: FullScreenLoader());
//         }

//         if (snapshot.hasData) {
//           final user = snapshot.data!;

//           return FutureBuilder<Map<String, dynamic>?>(
//             future: UserFirestoreService().fetchUser(user.uid),
//             builder: (context, userSnapshot) {
//               if (userSnapshot.connectionState == ConnectionState.waiting) {
//                 return Scaffold(
//                   body: Center(
//                     child: LoadingAnimationWidget.stretchedDots(
//                       color: theme.colorScheme.primary,
//                       size: 60,
//                     ),
//                   ),
//                 );
//               }

//               if (userSnapshot.hasData) {
//                 final userMap = userSnapshot.data!;
//                 final appUser = AppUser.fromMap(userMap);
//                 debugPrint("$appUser");

//                 Provider.of<UserProvider>(
//                   context,
//                   listen: false,
//                 ).setUser(appUser);

//                 final isProfileIncomplete =
//                     appUser.name.isEmpty ||
//                     appUser.phone.isEmpty ||
//                     appUser.photoUrl.isEmpty;

//                 if (isProfileIncomplete) {
//                   debugPrint("CompleteProfileScreen");
//                   return const CompleteProfileScreen(); // show once
//                 } else {
//                   debugPrint("MainNavScreen");
//                   return const MainNavScreen(); //otherwise, normal flow
//                 }
//               }

//               return const Scaffold(
//                 body: Center(child: Text("Error loading user")),
//               );
//             },
//           );
//         }

//         return const SplashScreen();
//       },
//     );
//   }
// }
