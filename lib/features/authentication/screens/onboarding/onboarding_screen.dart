import 'package:cconnect/common/widgets/texts/text_widget.dart';
import 'package:cconnect/utils/constraints/sizing.dart';
import 'package:cconnect/utils/constraints/strings.dart';
import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _onboardingData = [
    {
      "title": "Enhance Your Campus Life",
      "desc": "Discover campus events, join clubs, and connect with fellow students to make the most of your university experience.",
      // "image": "assets/images/onboarding1.png" // Placeholder
    },
    {
      "title": "Connect with Your Campus Community",
      "desc": "Engage with fellow students, join clubs, and participate in campus events. Your university experience starts here.",
      // "image": "assets/images/onboarding2.png"
    },
    {
      "title": "Excel in Your Studies",
      "desc": "Access a wealth of academic resources, from study guides to research tools, designed to help you achieve your academic goals.",
      // "image": "assets/images/onboarding3.png"
    },
  ];

  void _nextPage() {
    if (_currentPage < _onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    } else {
      Navigator.pushReplacementNamed(context, "/login");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (value) => setState(() => _currentPage = value),
                itemCount: _onboardingData.length,
                itemBuilder: (context, index) {
                  final data = _onboardingData[index];
                  return Padding(
                    padding: Sizing.paddingAll24,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Placeholder for Image
                        Container(
                          height: 250,
                          width: 250,
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.school, // Placeholder icon
                            size: 100,
                            color: primaryColor,
                          ),
                        ),
                        Sizing.h32,
                        AppText(
                          data["title"]!,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black, // Ensure visibility on white
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Sizing.h16,
                        AppText(
                          data["desc"]!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Dot Indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _onboardingData.length,
                (index) => Container(
                  margin: const EdgeInsets.only(right: 5),
                  height: 8,
                  width: _currentPage == index ? 20 : 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index ? primaryColor : Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            Sizing.h32,
            // Button
            Padding(
              padding: Sizing.paddingAll24,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _currentPage == _onboardingData.length - 1
                        ? "Get Started"
                        : "Next",
                  ),
                ),
              ),
            ),
            Sizing.h16,
          ],
        ),
      ),
    );
  }
}
