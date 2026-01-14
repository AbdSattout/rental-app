import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:homio/presentation/screens/home.dart';
import 'package:homio/presentation/screens/signup.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../l10n/app_localizations.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController controller = PageController();
  int currentPage = 0;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorScheme.of(context).primary,
        systemOverlayStyle: SystemUiOverlayStyle(
          systemNavigationBarColor: ColorScheme.of(context).surface,
          systemNavigationBarIconBrightness: Brightness.values.firstWhere(
            // opposite of app brightness
            (brightness) => brightness != ColorScheme.of(context).brightness,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: controller,
              onPageChanged: (index) {
                setState(() {
                  currentPage = index;
                });
              },
              children: [
                _OnboardingPage(
                  imageAsset: 'assets/stickers/hello.svg',
                  title: loc.welcome_title,
                  description: loc.welcome_description,
                ),
                _OnboardingPage(
                  imageAsset: 'assets/stickers/house-searching2.svg',
                  title: loc.find_home_title,
                  description: loc.find_home_description,
                ),
                _OnboardingPage(
                  imageAsset: 'assets/stickers/house-searching1.svg',
                  title: loc.start_journey_title,
                  description: loc.start_journey_description,
                ),
              ],
            ),
          ),
          Padding(
            padding: const .symmetric(horizontal: 24),
            child: SmoothPageIndicator(controller: controller, count: 3),
          ),
          Padding(
            padding: .fromLTRB(
              24,
              24,
              24,
              MediaQuery.paddingOf(context).bottom < 24
                  ? 24
                  : MediaQuery.paddingOf(context).bottom + 24,
            ),
            child: AbsorbPointer(
              absorbing: currentPage != 2,
              child: AnimatedOpacity(
                opacity: currentPage == 2 ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: Row(
                  mainAxisAlignment: .spaceBetween,
                  spacing: 16,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HomeScreen(),
                          ),
                        );
                      },
                      child: Text(
                        loc.continueAsGuest,
                        overflow: .ellipsis,
                        maxLines: 1,
                        style: .new(fontSize: 12),
                      ),
                    ),
                    FilledButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignupScreen(),
                          ),
                        );
                      },
                      child: Text(
                        loc.get_started,
                        overflow: .ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final String imageAsset;
  final String title;
  final String description;

  const _OnboardingPage({
    required this.imageAsset,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      children: [
        Expanded(
          flex: 3,
          child: Stack(
            children: [
              Positioned(
                top: 0,
                right: 0,
                left: 0,
                bottom: screenWidth,
                child: Container(color: colorScheme.primary),
              ),
              Positioned(
                bottom: 0,
                left: -screenWidth * 0.5,
                child: Container(
                  width: screenWidth * 2,
                  height: screenWidth * 2,
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    shape: .circle,
                  ),
                ),
              ),
              Positioned(
                bottom: 50,
                top: screenWidth * 0.05,
                right: screenWidth * 0.05,
                left: screenWidth * 0.05,
                child: SvgPicture.asset(
                  imageAsset,
                  fit: .contain,
                  alignment: .bottomCenter,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: Padding(
            padding: const .all(24),
            child: Column(
              spacing: 16,
              mainAxisAlignment: .center,
              children: [
                Text(
                  title,
                  style: textTheme.headlineMedium,
                  textAlign: .center,
                ),
                Text(
                  description,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.secondary,
                  ),
                  textAlign: .center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
