import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart'; // Add this import for DragStartBehavior
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLastPage = false;

  final List<OnboardingItem> _onboardingItems = [
    OnboardingItem(
      title: "Never get caught in the rain again",
      description:
          "Our app alerts you before rain showers, so you'll always remember your umbrella",
      lottieAsset: 'assets/animations/rainy.json',
      fallbackIcon: Icons.umbrella,
    ),
    OnboardingItem(
      title: "Stay protected on sunny days",
      description:
          "Get UV index alerts and reminders to apply sunscreen on bright days",
      lottieAsset: 'assets/animations/sunny.json',
      fallbackIcon: Icons.wb_sunny,
    ),
    OnboardingItem(
      title: "Be prepared for any weather",
      description:
          "From snowstorms to heat waves, we've got you covered with accurate forecasts",
      lottieAsset: 'assets/animations/cloudy.json',
      fallbackIcon: Icons.cloud,
    ),
    OnboardingItem(
      title: "Track hourly changes",
      description:
          "Stay ahead of weather changes with our detailed hourly forecasts",
      lottieAsset: 'assets/animations/storm.json',
      fallbackIcon: Icons.bolt,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF4A9EF7), Color(0xFFDDEAF9)],
              ),
            ),
          ),

          // Page View
          PageView.builder(
            controller: _pageController,
            physics:
                const ClampingScrollPhysics(), // Changed to ClampingScrollPhysics for better swipe feel
            dragStartBehavior:
                DragStartBehavior.down, // Improves drag sensitivity
            itemCount: _onboardingItems.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
                _isLastPage = index == _onboardingItems.length - 1;
              });
            },
            itemBuilder: (context, index) {
              return _buildOnboardingPage(_onboardingItems[index]);
            },
          ),

          // Skip button - with gradient matching the background
          Positioned(
            top: 50,
            right: 20,
            child: !_isLastPage
                ? Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF4A9EF7), Color(0xFF6FB1F8)],
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                      border: Border.all(
                        color: Colors.white.withOpacity(0.4),
                        width: 1,
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(30),
                        onTap: () {
                          _pageController.animateToPage(
                            _onboardingItems.length - 1,
                            duration: const Duration(milliseconds: 600),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Text(
                                "Skip",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(width: 5),
                              Icon(
                                Icons.skip_next_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),

          // Bottom section with indicators and button
          Positioned(
            bottom: 50,
            left: 20,
            right: 20,
            child: Column(
              children: [
                // Page indicator
                Center(
                  child: SmoothPageIndicator(
                    controller: _pageController,
                    count: _onboardingItems.length,
                    effect: const WormEffect(
                      dotColor: Colors.white60,
                      activeDotColor: Colors.white,
                      dotHeight: 10,
                      dotWidth: 10,
                      spacing: 16,
                    ),
                    onDotClicked: (index) {
                      // Allow direct navigation by tapping dots
                      _pageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 30),

                // Conditional button layout: full-width on first page, split on others
                _currentPage == 0
                    // Full-width "Continue" button for first page
                    ? Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: ElevatedButton(
                          onPressed: () {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 600),
                              curve: Curves.easeInOut,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 8,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          child: const Text(
                            "Continue",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      )
                    // Row with Back and Continue/Get Started buttons for other pages
                    : Row(
                        children: [
                          // Back button
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ElevatedButton(
                                onPressed: () {
                                  _pageController.previousPage(
                                    duration: const Duration(milliseconds: 600),
                                    curve: Curves.easeInOut,
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  elevation: 8,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 15),
                                ),
                                child: const Text(
                                  "Back",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Continue or Get Started button
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: ElevatedButton(
                                onPressed: () {
                                  if (_isLastPage) {
                                    // Navigate to the weather page
                                    Navigator.pushReplacementNamed(
                                        context, '/');
                                  } else {
                                    // Go to next page
                                    _pageController.nextPage(
                                      duration:
                                          const Duration(milliseconds: 600),
                                      curve: Curves.easeInOut,
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  elevation: 8,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 15),
                                ),
                                child: Text(
                                  _isLastPage ? "Get Started" : "Continue",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOnboardingPage(OnboardingItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 5,
            child: Center(
              child: _buildLottieAnimation(item.lottieAsset, item.fallbackIcon),
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item.title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.overpass(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  item.description,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.overpass(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          // Bottom spacing to make room for buttons
          const Expanded(flex: 2, child: SizedBox()),
        ],
      ),
    );
  }

  Widget _buildLottieAnimation(String assetPath, IconData fallbackIcon) {
    return Lottie.asset(
      assetPath,
      width: 250,
      height: 250,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        print('⚠️ Failed to load Lottie animation: $error');
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              fallbackIcon,
              size: 120,
              color: Colors.white,
            ),
            const SizedBox(height: 16),
            const Text(
              "Animation not found",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        );
      },
    );
  }
}

class OnboardingItem {
  final String title;
  final String description;
  final String lottieAsset;
  final IconData fallbackIcon;

  OnboardingItem({
    required this.title,
    required this.description,
    required this.lottieAsset,
    required this.fallbackIcon,
  });
}

// Keep the custom painters for background elements when needed
class SunWithRipplesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..style = PaintingStyle.fill;

    // Sun
    paint.color = Colors.orangeAccent;
    canvas.drawCircle(const Offset(40, 40), 40, paint);

    // Ripple Effect
    paint
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (double i = 50; i <= 80; i += 15) {
      canvas.drawCircle(const Offset(40, 40), i, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CloudPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.white.withOpacity(0.3) // More transparent
      ..style = PaintingStyle.fill;

    // Cloud Body
    final Path path = Path()
      ..moveTo(size.width * 0.2, size.height * 0.6)
      ..arcToPoint(
        Offset(size.width * 0.4, size.height * 0.3),
        radius: const Radius.circular(60),
      )
      ..arcToPoint(
        Offset(size.width * 0.7, size.height * 0.35),
        radius: const Radius.circular(70),
      )
      ..arcToPoint(
        Offset(size.width * 0.9, size.height * 0.6),
        radius: const Radius.circular(60),
      )
      ..lineTo(size.width * 0.2, size.height * 0.6)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
