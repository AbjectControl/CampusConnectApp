import 'package:cconnect/features/academics/screens/academics_screen.dart';
import 'package:cconnect/features/chat/screens/chat_screen.dart';
import 'package:cconnect/features/community/screens/community_screen.dart';
import 'package:cconnect/features/home/screens/home_screen.dart';
import 'package:cconnect/features/personalization/screens/profile/profile_screen.dart';
import 'package:cconnect/utils/constraints/appicons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MainNavScreen extends StatefulWidget {
  const MainNavScreen({super.key});

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    CommunityScreen(),
    AcademicsScreen(),
    ChatScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final Color selectedColor = Theme.of(context).colorScheme.primary;
    const Color unselectedColor = Color(0xFFB6B6B6);

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: selectedColor,
        unselectedItemColor: unselectedColor,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: [
          BottomNavigationBarItem(
            icon: SvgPicture.string(
              homeIcon,
              colorFilter: ColorFilter.mode(
                _selectedIndex == 0 ? selectedColor : unselectedColor,
                BlendMode.srcIn,
              ),
            ),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.string(
              communityIcon,
              colorFilter: ColorFilter.mode(
                _selectedIndex == 1 ? selectedColor : unselectedColor,
                BlendMode.srcIn,
              ),
            ),
            label: "Community",
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _selectedIndex == 2
                    ? selectedColor.withOpacity(0.1)
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: SvgPicture.string(
                academicsIcon,
                colorFilter: ColorFilter.mode(
                  _selectedIndex == 2 ? selectedColor : unselectedColor,
                  BlendMode.srcIn,
                ),
              ),
            ),
            label: "Academics",
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.string(
              messageIcon,
              colorFilter: ColorFilter.mode(
                _selectedIndex == 3 ? selectedColor : unselectedColor,
                BlendMode.srcIn,
              ),
            ),
            label: "Chat",
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.string(
              userIcon,
              colorFilter: ColorFilter.mode(
                _selectedIndex == 4 ? selectedColor : unselectedColor,
                BlendMode.srcIn,
              ),
            ),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
