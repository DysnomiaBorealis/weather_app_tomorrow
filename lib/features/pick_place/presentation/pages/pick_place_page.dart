// ignore_for_file: deprecated_member_use
import 'package:d_view/d_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:weather_app_tommorow/features/pick_place/presentation/cubit/city_cubit.dart';

class PickPlacePage extends StatefulWidget {
  const PickPlacePage({super.key});

  @override
  State<PickPlacePage> createState() => _PickPlacePageState();
}

class _PickPlacePageState extends State<PickPlacePage>
    with SingleTickerProviderStateMixin {
  final edtCity = TextEditingController();

  // Animation controller for cloud and sun animations
  late AnimationController _animationController;
  late Animation<double> _cloudAnimation;
  late Animation<double> _cloud2Animation;
  late Animation<double> _cloud3Animation;
  late Animation<double> _cloud4Animation;
  late Animation<double> _sunRotationAnimation;
  late Animation<double> _sunScaleAnimation;

  @override
  void initState() {
    edtCity.text = context.read<CityCubit>().init();

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);

    // Cloud animations
    _cloudAnimation = Tween<double>(
      begin: -15.0,
      end: 15.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _cloud2Animation = Tween<double>(
      begin: -10.0,
      end: 10.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.1, 0.9, curve: Curves.easeInOut),
      ),
    );

    _cloud3Animation = Tween<double>(
      begin: -20.0,
      end: 20.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeInOut),
      ),
    );

    // Add fourth cloud animation
    _cloud4Animation = Tween<double>(
      begin: -8.0,
      end: 8.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeInOut),
      ),
    );

    // Sun animations
    _sunRotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.05,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _sunScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      floatingActionButton: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF64B5F6), Color(0xFF1976D2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(30),
            splashColor: Colors.white.withOpacity(0.2),
            highlightColor: Colors.transparent,
            hoverColor: Colors.transparent,
            onTap: () => Navigator.pop(context),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.arrow_back, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Back', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF4A9EF7), Color(0xFFDDEAF9)],
                ),
              ),
            ),
          ),

          // Animated Sun
          Positioned(
            top: 80,
            left: 40,
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _sunRotationAnimation.value,
                  child: Transform.scale(
                    scale: _sunScaleAnimation.value,
                    child: CustomPaint(
                      size: const Size(150, 150),
                      painter: SunWithRipplesPainter(
                        ripplePhase: _animationController.value,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Cloud 1 - Repositioned to bottom right
          Positioned(
            bottom: screenHeight * 0.05, // 5% from bottom
            right: -120,
            child: AnimatedBuilder(
              animation: _cloudAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _cloudAnimation.value),
                  child: Transform.scale(
                    scale: 3,
                    child: CustomPaint(
                      size: const Size(350, 180),
                      painter: CloudPainter(),
                    ),
                  ),
                );
              },
            ),
          ),

          // Cloud 2 - Repositioned to top right
          Positioned(
            top: screenHeight * 0.08, // 8% from top
            right: screenWidth * 0.2, // 20% from right edge
            child: AnimatedBuilder(
              animation: _cloud2Animation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(_cloud2Animation.value, 0),
                  child: Transform.scale(
                    scale: 1.2,
                    child: Opacity(
                      opacity: 0.7,
                      child: CustomPaint(
                        size: const Size(180, 100),
                        painter: CloudPainter(),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Cloud 3 - Moved to bottom left, well below text
          Positioned(
            bottom: screenHeight * 0.25, // 25% from bottom
            left: 20,
            child: AnimatedBuilder(
              animation: _cloud3Animation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(_cloud3Animation.value, 0),
                  child: Transform.scale(
                    scale: 1.5,
                    child: Opacity(
                      opacity: 0.8,
                      child: CustomPaint(
                        size: const Size(200, 120),
                        painter: CloudPainter(),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Cloud 4 - Small cloud at very bottom left
          Positioned(
            bottom: screenHeight * 0.05, // 5% from bottom
            left: screenWidth * 0.1, // 10% from left
            child: AnimatedBuilder(
              animation: _cloud4Animation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(
                      _cloud4Animation.value, _cloud4Animation.value * 0.5),
                  child: Transform.scale(
                    scale: 1.2,
                    child: Opacity(
                      opacity: 0.6,
                      child: CustomPaint(
                        size: const Size(180, 100),
                        painter: SmallCloudPainter(),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Cloud 5 - Small cloud at very top left
          Positioned(
            top: screenHeight * 0.05, // 5% from top
            left: 40,
            child: AnimatedBuilder(
              animation: _cloud2Animation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(_cloud2Animation.value * -1, 0),
                  child: Transform.scale(
                    scale: 1.0,
                    child: Opacity(
                      opacity: 0.5,
                      child: CustomPaint(
                        size: const Size(120, 70),
                        painter: SmallCloudPainter(),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          Positioned(
            top: MediaQuery.of(context).size.height / 4,
            left: 30,
            right: 30,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SetUp\nthe location',
                  style: Theme.of(context).textTheme.displaySmall!.copyWith(
                        fontWeight: FontWeight.w900,
                        color: Theme.of(context).primaryColor,
                      ),
                ),
                DView.spaceHeight(24),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.only(left: 30),
                  height: 50,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: edtCity,
                          decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.all(0),
                            border: InputBorder.none,
                            hintText: 'Type the city name',
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onChanged: (value) {
                            context.read<CityCubit>().listenChange(value);
                          },
                        ),
                      ),
                      DView.spaceWidth(30),
                      BlocBuilder<CityCubit, String>(
                        builder: (context, state) {
                          if (state == '') return DView.nothing();
                          return Container(
                            margin: const EdgeInsets.only(right: 6),
                            decoration: BoxDecoration(
                              // Changed from green to blue gradient to match app theme
                              gradient: const LinearGradient(
                                colors: [Color(0xFF64B5F6), Color(0xFF1976D2)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                splashColor: Colors.white.withOpacity(0.2),
                                highlightColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                onTap: () {
                                  context.read<CityCubit>().saveCity();
                                  FocusManager.instance.primaryFocus?.unfocus();
                                  Navigator.pop(context, 'refresh');
                                },
                                child: const Padding(
                                  padding: EdgeInsets.all(12.0),
                                  child: Icon(Icons.check,
                                      color: Colors.white, size: 20),
                                ),
                              ),
                            ),
                          );
                        },
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Animated Sun with Ripple Effect painter
class SunWithRipplesPainter extends CustomPainter {
  final double ripplePhase;

  SunWithRipplesPainter({this.ripplePhase = 0.0});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..style = PaintingStyle.fill;

    // Draw Sun
    paint.color = Colors.orangeAccent;
    canvas.drawCircle(const Offset(40, 40), 40, paint);

    // Draw Ripple Effect with phase offset
    paint
      ..color =
          Colors.white.withOpacity(0.3 - 0.15 * ripplePhase) // Animated opacity
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Animating ripples
    for (double i = 50; i <= 80; i += 15) {
      double rippleRadius = i + (10 * ripplePhase);
      canvas.drawCircle(const Offset(40, 40), rippleRadius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant SunWithRipplesPainter oldDelegate) =>
      oldDelegate.ripplePhase != ripplePhase;
}

// Original CloudPainter with no changes
class CloudPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.fill;

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

// Add a new painter for small clouds
class SmallCloudPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.fill;

    // Draw a simpler, smaller cloud
    final Path path = Path()
      ..moveTo(size.width * 0.2, size.height * 0.5)
      ..arcToPoint(
        Offset(size.width * 0.5, size.height * 0.3),
        radius: const Radius.circular(30),
      )
      ..arcToPoint(
        Offset(size.width * 0.8, size.height * 0.5),
        radius: const Radius.circular(30),
      )
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
