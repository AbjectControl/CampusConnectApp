import 'package:cconnect/features/authentication/screens/login/screens/Login.dart';
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
    Center(child: Text("Home Screen")), // Placeholder
    Center(child: Text("Favorites Screen")), // Placeholder
    Center(child: Text("Cart Screen")), // Placeholder
    Center(child: Text("Profile Screen")), // Placeholder
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
        showUnselectedLabels: false,
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
              heartIcon,
              colorFilter: ColorFilter.mode(
                _selectedIndex == 1 ? selectedColor : unselectedColor,
                BlendMode.srcIn,
              ),
            ),
            label: "Favorites",
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.string(
              chatIcon,
              colorFilter: ColorFilter.mode(
                _selectedIndex == 2 ? selectedColor : unselectedColor,
                BlendMode.srcIn,
              ),
            ),
            label: "Cart",
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.string(
              userIcon,
              colorFilter: ColorFilter.mode(
                _selectedIndex == 3 ? selectedColor : unselectedColor,
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
