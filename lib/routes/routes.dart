import 'package:cconnect/common/widgets/navigation/main_nav_screen.dart';
import 'package:cconnect/data/models/lost_found_item.dart';
import 'package:cconnect/data/models/userModel.dart';
import 'package:cconnect/features/academics/screens/mentorship_request_screen.dart';
import 'package:cconnect/features/authentication/screens/login/screens/Login.dart';
import 'package:cconnect/features/authentication/screens/onboarding/onboarding_screen.dart';
import 'package:cconnect/features/authentication/screens/passwordConfig/screens/forgot_password_screen.dart';
import 'package:cconnect/features/authentication/screens/signup/screens/email_verify_screen.dart';
import 'package:cconnect/features/authentication/screens/signup/signup_screen.dart';
import 'package:cconnect/features/chat/screens/contact_info/contact_info_screen.dart';
import 'package:cconnect/features/chat/screens/friends/friends_chat_screen.dart';
import 'package:cconnect/features/chat/screens/groups/group_chat_screen.dart';
import 'package:cconnect/features/community/screens/communityEvents/CommunityEventsScreen.dart';
import 'package:cconnect/features/community/screens/communityLostFound/CommunityLostFoundScreen.dart';
import 'package:cconnect/features/community/screens/communityLostFound/lost_found_detail_screen.dart';
import 'package:cconnect/features/community/screens/communityLostFound/report_found_item_screen.dart';
import 'package:cconnect/features/community/screens/communityLostFound/report_lost_item_screen.dart';
import 'package:cconnect/features/community/screens/communitySurveys/CommunitySurveysScreen.dart';
import 'package:cconnect/features/personalization/screens/admin/admin_dashboard_screen.dart';
import 'package:cconnect/features/personalization/screens/complete_profile/complete_profile_screen.dart';
import 'package:cconnect/routes/auth_gate.dart';
import 'package:flutter/material.dart';

class AppRoutes {
  AppRoutes._();

  static const String home = '/home';
  static const String login = '/login';
  static const String signUp = '/signUp';
  static const String onboarding = '/onboarding';
  static const String authGate = '/auth-gate';
  static const String mainNav = '/main-nav';
  static const String verifyMailScreen = '/verify-mail';
  static const String forgotPassword = '/forgot-password';
  static const String completeProfile = '/complete-profile';
  static const String communitySurveys = '/community-surveys';
  static const String communityEvents = '/community-events';
  static const String communityLostFound = '/community-lost-found';
  static const String mentorshipRequest = '/mentorship-request';
  static const String groupChat = '/group-chat';
  static const String friendsChat = '/friends-chat';
  static const String contactInfo = '/contact-info';
  static const String adminDashboard = '/admin-dashboard';
  static const String reportLostItem = '/report-lost-item';
  static const String reportFoundItem = '/report-found-item';
  static const String lostFoundDetail = '/lost-found-detail';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const MainNavScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case signUp:
        return MaterialPageRoute(builder: (_) => const SignUpScreen());
      case onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      case authGate:
        return MaterialPageRoute(builder: (_) => const AuthGate());
      case mainNav:
        return MaterialPageRoute(builder: (_) => const MainNavScreen());
      case verifyMailScreen:
        final email = settings.arguments as String? ?? '';
        return MaterialPageRoute(
          builder: (_) => EmailVerifyScreen(email: email),
        );
      case forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      case completeProfile:
        return MaterialPageRoute(builder: (_) => const CompleteProfileScreen());
      case communitySurveys:
        return MaterialPageRoute(
          builder: (_) => const CommunitySurveysScreen(),
        );
      case communityEvents:
        return MaterialPageRoute(builder: (_) => const CommunityEventsScreen());
      case communityLostFound:
        return MaterialPageRoute(
          builder: (_) => const CommunityLostFoundScreen(),
        );
      case mentorshipRequest:
        return MaterialPageRoute(
          builder: (_) => const MentorshipRequestScreen(),
        );
      case groupChat:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => GroupChatScreen(
            groupId: args['groupId'],
            groupName: args['groupName'],
          ),
        );
      case friendsChat:
        final user = settings.arguments as User;
        return MaterialPageRoute(
          builder: (_) => FriendsChatScreen(targetUser: user),
        );
      case contactInfo:
        final user = settings.arguments as User;
        return MaterialPageRoute(builder: (_) => ContactInfoScreen(user: user));
      case adminDashboard:
        return MaterialPageRoute(builder: (_) => const AdminDashboardScreen());
      case reportLostItem:
        return MaterialPageRoute(builder: (_) => const ReportLostItemScreen());
      case reportFoundItem:
        return MaterialPageRoute(builder: (_) => const ReportFoundItemScreen());
      case lostFoundDetail:
        final item = settings.arguments as LostFoundItem;
        return MaterialPageRoute(
          builder: (_) => LostFoundDetailScreen(item: item),
        );
      default:
        return MaterialPageRoute(builder: (_) => const AuthGate());
    }
  }
}
