import 'dart:async';
import 'dart:math';
import 'dart:convert';
import 'package:d_view/d_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:extended_image/extended_image.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:weather_app_tommorow/common/enum.dart';
import 'package:weather_app_tommorow/common/extension.dart';
import 'package:weather_app_tommorow/features/weather/presentation/bloc/current_weather/current_weather_bloc.dart';
import 'package:weather_app_tommorow/features/weather/presentation/widget/basic_shadow.dart';

class CurrentWeatherPage extends StatefulWidget {
  const CurrentWeatherPage({super.key});

  @override
  State<CurrentWeatherPage> createState() => _CurrentWeatherPageState();
}

class _CurrentWeatherPageState extends State<CurrentWeatherPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _cloudAnimation;
  late Animation<double> _cloud2Animation;
  late Animation<double> _cloud3Animation;
  late Animation<double> _cloud4Animation;
  late Animation<double> _sunRotationAnimation;
  late Animation<double> _sunScaleAnimation;
  late Animation<double> _rainAnimation;

  // Add animation controllers for notification button
  late AnimationController _notificationButtonController;
  late Animation<double> _notificationScaleAnimation;

  // Notification settings
  bool _rainAlerts = false;
  bool _stormAlerts = false;
  bool _temperatureAlerts = false;

  // Add animation controller for Lottie movement
  late AnimationController _lottiePositionController;
  late Animation<double> _lottieXAnimation;
  late Animation<double> _lottieYAnimation;

  // Rain and thunder control variables
  bool _isRaining = false;
  bool _isThundering = false;
  Timer? _rainTimer;
  Timer? _thunderTimer;

  // Toggle between custom animations and Lottie animations
  bool _showLottieAnimation = false;
  bool _animationErrorReported = false;

  // Key for more reliable rebuilding
  final GlobalKey _animationKey = GlobalKey();

  // Add refresh button animation controller
  late AnimationController _refreshRotationController;
  late Animation<double> _refreshRotationAnimation;

  // Add animation controllers for each button
  late AnimationController _cityButtonController;
  late AnimationController _hourlyButtonController;
  late Animation<double> _cityScaleAnimation;
  late Animation<double> _hourlyScaleAnimation;

  // Add notification plugin instance
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Add timer for periodic weather checks
  Timer? _weatherCheckTimer;

  // Add keys for SharedPreferences
  static const String _keyRainAlerts = 'rain_alerts';
  static const String _keyStormAlerts = 'storm_alerts';
  static const String _keyTempAlerts = 'temperature_alerts';

  // Add animation controllers for new buttons
  late AnimationController _historyButtonController;
  late AnimationController _savedLocationsButtonController;
  late Animation<double> _historyScaleAnimation;
  late Animation<double> _savedLocationsScaleAnimation;

  // Key for SharedPreferences saved locations
  static const String _keySavedLocations = 'saved_locations';

  // List to store saved locations
  List<Map<String, dynamic>> _savedLocations = [];

  refresh() {
    context.read<CurrentWeatherBloc>().add(OnGetCurrentWeather());
  }

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);

    // Initialize notification button animation
    _notificationButtonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _notificationScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _notificationButtonController,
      curve: Curves.easeInOut,
    ));

    // Lottie movement controller - longer duration for smoother traversal
    _lottiePositionController = AnimationController(
      vsync: this,
      duration:
          const Duration(seconds: 45), // Longer duration for smoother effect
    )..repeat(reverse: false); // Changed to not reverse for continuous movement

    // Lottie X position animation (horizontal movement) - wider range
    _lottieXAnimation = Tween<double>(
      begin: -100.0, // Increased range
      end: 100.0, // Increased range
    ).animate(
      CurvedAnimation(
        parent: _lottiePositionController,
        curve: Curves.easeInOutSine, // Changed curve for more natural movement
      ),
    );

    // Lottie Y position animation (vertical movement) - wider range
    _lottieYAnimation = Tween<double>(
      begin: -80.0, // Increased range
      end: 80.0, // Increased range
    ).animate(
      CurvedAnimation(
        parent: _lottiePositionController,
        // Using a different interval for Y to create elliptical path
        curve: const Interval(0.0, 1.0, curve: Curves.easeInOutCubic),
      ),
    );

    // Cloud floating animation
    _cloudAnimation = Tween<double>(
      begin: -15.0,
      end: 15.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    // Second cloud animation (different speed and range)
    _cloud2Animation = Tween<double>(
      begin: -10.0,
      end: 10.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.1, 0.9, curve: Curves.easeInOut),
      ),
    );

    // Third cloud animation (horizontal movement)
    _cloud3Animation = Tween<double>(
      begin: -20.0,
      end: 20.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeInOut),
      ),
    );

    // Fourth cloud animation
    _cloud4Animation = Tween<double>(
      begin: -8.0,
      end: 8.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeInOut),
      ),
    );

    // Rain animation
    _rainAnimation = Tween<double>(
      begin: 0.0,
      end: 20.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.linear,
      ),
    );

    // Sun rotation animation
    _sunRotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.05, // Subtle rotation (just a few degrees)
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    // Sun pulsating animation
    _sunScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    // Set up rain timer to toggle rain every 3 seconds
    _rainTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      setState(() {
        _isRaining = !_isRaining;

        // If it starts raining, schedule a thunder
        if (_isRaining) {
          // Random delay for thunder (0.5-1.5 seconds after rain starts)
          Future.delayed(
              Duration(
                  milliseconds: 500 +
                      (1000 *
                              (0.5 +
                                  (0.5 *
                                      (DateTime.now().millisecondsSinceEpoch %
                                          2))))
                          .toInt()), () {
            if (_isRaining) {
              // Only show thunder if still raining
              setState(() {
                _isThundering = true;
              });

              // Turn off thunder after 0.5 seconds
              _thunderTimer = Timer(const Duration(milliseconds: 500), () {
                setState(() {
                  _isThundering = false;
                });
              });
            }
          });
        }
      });
    });

    // Initialize refresh rotation animation
    _refreshRotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _refreshRotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _refreshRotationController,
      curve: Curves.easeInOut,
    ));

    // Initialize city button animation
    _cityButtonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _cityScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _cityButtonController,
      curve: Curves.easeInOut,
    ));

    // Initialize hourly button animation
    _hourlyButtonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _hourlyScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _hourlyButtonController,
      curve: Curves.easeInOut,
    ));

    // Initialize notifications
    _initializeNotifications();

    // Load saved notification preferences
    _loadNotificationSettings();

    // Initialize history button animation
    _historyButtonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _historyScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _historyButtonController,
      curve: Curves.easeInOut,
    ));

    // Initialize saved locations button animation
    _savedLocationsButtonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _savedLocationsScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _savedLocationsButtonController,
      curve: Curves.easeInOut,
    ));

    // Load saved locations
    _loadSavedLocations();

    refresh();
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _refreshRotationController.dispose();
    _cityButtonController.dispose();
    _hourlyButtonController.dispose();
    _notificationButtonController.dispose(); // Add this line
    _lottiePositionController.dispose(); // Dispose the new controller
    _rainTimer?.cancel();
    _thunderTimer?.cancel();
    _weatherCheckTimer?.cancel();
    _historyButtonController.dispose();
    _savedLocationsButtonController.dispose();
    super.dispose();
  }

  // Get the appropriate Lottie animation based on weather condition
  String _getWeatherLottieAnimation(String weatherCondition) {
    final condition = weatherCondition.toLowerCase();

    print("Current weather condition: $condition");

    if (condition.contains('thunder') || condition.contains('storm')) {
      return 'assets/animations/storm.json';
    } else if (condition.contains('rain') || condition.contains('drizzle')) {
      return 'assets/animations/rainy.json';
    } else if (condition.contains('snow')) {
      return 'assets/animations/snow.json';
    } else if (condition.contains('cloud')) {
      return 'assets/animations/cloudy.json';
    } else if (condition.contains('fog')) {
      return 'assets/animations/foggy.json';
    } else {
      return 'assets/animations/sunny.json';
    }
  }

  // Toggle between animation types with enhanced debugging
  void _toggleAnimationType() {
    print("⚡ TOGGLE ANIMATION: Current state = $_showLottieAnimation");

    setState(() {
      _showLottieAnimation = !_showLottieAnimation;
      _animationErrorReported = false;
      print("⚡ ANIMATION STATE CHANGED TO: $_showLottieAnimation");
    });

    // Show a more prominent visual indicator of the tap
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: _showLottieAnimation ? Colors.green : Colors.blue,
        content: Row(
          children: [
            Icon(
              _showLottieAnimation ? Icons.check_circle : Icons.refresh,
              color: Colors.white,
            ),
            const SizedBox(width: 10),
            Text(
              _showLottieAnimation
                  ? 'Switched to Lottie animation'
                  : 'Switched to custom animation',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Get weather description from current state
  String _getCurrentWeatherDescription() {
    final state = context.read<CurrentWeatherBloc>().state;
    if (state is CurrentWeatherLoaded) {
      print("⚡ Current weather: ${state.data.description}");
      return state.data.description;
    }
    print("⚡ No weather data available, using default");
    return "clear";
  }

  Widget background() {
    return Stack(
      children: [
        // Gradient Background
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF4A9EF7), Color(0xFFDDEAF9)],
            ),
          ),
        ),

        // Weather animations with a global key for more reliable rebuilding
        Container(
          key: _animationKey,
          child: GestureDetector(
            onTap: _toggleAnimationType,
            behavior: HitTestBehavior.opaque,
            child: !_showLottieAnimation
                ? _buildCustomAnimations()
                : _buildLottieAnimation(_getCurrentWeatherDescription()),
          ),
        ),

        // More prominent animation toggle button
        Positioned(
          top: 200,
          right: 20,
          child: Container(
            height: 70, // Larger touch target
            width: 70, // Larger touch target
            alignment: Alignment.center,
            child: FloatingActionButton(
              heroTag: 'animToggle',
              onPressed: _toggleAnimationType,
              tooltip: 'Toggle animation type',
              backgroundColor:
                  _showLottieAnimation ? Colors.green : Colors.blue,
              child: Icon(
                _showLottieAnimation
                    ? Icons.animation
                    : Icons.animation_outlined,
                color: Colors.white,
                size: 28, // Larger icon
              ),
            ),
          ),
        ),

        // Instruction overlay when using Lottie
        if (_showLottieAnimation)
          Positioned(
            top: 120,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Tap anywhere to return to custom animation',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
          ),

        // Debug overlay
        Positioned(
          top: 250,
          left: 20,
          child: Container(
            padding: const EdgeInsets.all(8),
            color: Colors.black54,
            child: Text(
              'Animation Mode: ${_showLottieAnimation ? "Lottie" : "Custom"}',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }

  // Build the custom animations that were already implemented
  Widget _buildCustomAnimations() {
    return Stack(
      children: [
        // Thunder flash effect
        if (_isThundering)
          Container(
            color: Colors.white.withOpacity(0.7),
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

        // Cloud 1 (original cloud, repositioned)
        Positioned(
          bottom: 220,
          right: -100,
          child: AnimatedBuilder(
            animation: _cloudAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _cloudAnimation.value),
                child: Transform.scale(
                  scale: 2.5,
                  child: Opacity(
                    opacity: 0.9,
                    child: CustomPaint(
                      size: const Size(350, 180),
                      painter: CloudPainter(),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Cloud 2 (new cloud)
        Positioned(
          top: 140,
          right: 100,
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

        // Cloud 3 (new cloud)
        Positioned(
          top: 240,
          left: 50,
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

        // Cloud 4 (small cloud)
        Positioned(
          bottom: 300,
          left: 30,
          child: AnimatedBuilder(
            animation: _cloud4Animation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(
                    _cloud4Animation.value, _cloud4Animation.value * 0.5),
                child: Transform.scale(
                  scale: 0.8,
                  child: Opacity(
                    opacity: 0.6,
                    child: CustomPaint(
                      size: const Size(150, 80),
                      painter: SmallCloudPainter(),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Animated Rain (conditional)
        if (_isRaining)
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _rainAnimation,
              builder: (context, child) {
                return CustomPaint(
                  painter: RainPainter(
                    animationValue: _rainAnimation.value,
                    density: 80, // Number of raindrops
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  // Build and display the appropriate Lottie animation with more debug info
  Widget _buildLottieAnimation(String weatherDescription) {
    final animationPath = _getWeatherLottieAnimation(weatherDescription);
    print(
        "⚡ Building Lottie animation: $animationPath for weather: $weatherDescription");

    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _lottiePositionController,
        builder: (context, child) {
          // Calculate a more interesting path (figure-8 or circular pattern)
          // Using sin/cos functions to create circular motion
          final double phi =
              _lottiePositionController.value * 2 * 3.14159; // Full circle
          final double radius = 70.0; // Radius of movement

          // Calculate offset based on sine and cosine for a more natural movement
          final xOffset = _lottieXAnimation.value * 0.7 +
              radius * sin(phi) * 0.3; // Combine linear and circular motion
          final yOffset = _lottieYAnimation.value * 0.7 +
              radius *
                  cos(phi * 2) *
                  0.3; // Frequency doubled for figure-8 pattern

          return Transform.translate(
            offset: Offset(xOffset, yOffset),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildWeatherAnimation(animationPath, weatherDescription),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Helper method to load Lottie animation with error handling
  Widget _buildWeatherAnimation(
      String animationPath, String weatherDescription) {
    try {
      if (!_animationErrorReported) {
        print("Trying to load Lottie animation: $animationPath");
      }

      return Lottie.asset(
        animationPath,
        width: 300,
        height: 300,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          if (!_animationErrorReported) {
            print('⚠️ Failed to load animation: $error');
            print(
                '⚠️ Make sure you have the animation files in: assets/animations/');
            print('⚠️ Run "flutter pub get" after adding the files');
            _animationErrorReported = true;
          }
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildFallbackWeatherIcon(weatherDescription),
              const SizedBox(height: 8),
              const Text(
                "Animation file not found",
                style: TextStyle(
                  color: Colors.white,
                  backgroundColor: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          );
        },
      );
    } catch (e) {
      if (!_animationErrorReported) {
        print('⚠️ Exception loading animation: $e');
        _animationErrorReported = true;
      }
      return _buildFallbackWeatherIcon(weatherDescription);
    }
  }

  // Fallback for when Lottie animations are not available
  Widget _buildFallbackWeatherIcon(String weatherCondition) {
    final condition = weatherCondition.toLowerCase();
    IconData weatherIcon;

    if (condition.contains('thunder') || condition.contains('storm')) {
      weatherIcon = Icons.flash_on;
    } else if (condition.contains('rain') || condition.contains('drizzle')) {
      weatherIcon = Icons.water_drop;
    } else if (condition.contains('snow')) {
      weatherIcon = Icons.ac_unit;
    } else if (condition.contains('cloud')) {
      weatherIcon = Icons.cloud;
    } else {
      weatherIcon = Icons.wb_sunny;
    }

    return Icon(
      weatherIcon,
      size: 120,
      color: Colors.white,
    );
  }

  Widget headerAction() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // First row of buttons
        Row(
          children: [
            buttonAction(
              onTap: () {
                _cityButtonController
                    .forward()
                    .then((_) => _cityButtonController.reverse());
                Navigator.pushNamed(
                  context,
                  AppRoute.pickPlace.name,
                ).then((backResponse) {
                  if (backResponse == null) return;
                  if (backResponse == 'refresh') refresh();
                });
              },
              title: 'City',
              icon: Icons.location_on,
              animationController: _cityButtonController,
              scaleAnimation: _cityScaleAnimation,
              gradient: const LinearGradient(
                colors: [Color(0xFF64B5F6), Color(0xFF1976D2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            DView.width(8),
            buttonAction(
              onTap: () {
                // Add refresh animation effect
                _refreshRotationController.reset();
                _refreshRotationController.forward();
                refresh();
              },
              title: 'Refresh',
              icon: Icons.refresh,
              customIconWidget: RotationTransition(
                turns: _refreshRotationAnimation,
                child: const Icon(
                  Icons.refresh,
                  size: 12,
                  color: Colors.white,
                ),
              ),
              gradient: const LinearGradient(
                colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ],
        ),
        DView.height(8), // Add spacing between rows
        // Second row of buttons
        Row(
          children: [
            buttonAction(
              onTap: () {
                _hourlyButtonController
                    .forward()
                    .then((_) => _hourlyButtonController.reverse());
                Navigator.pushNamed(context, AppRoute.hourlyForecast.name);
              },
              title: 'Hourly',
              icon: Icons.access_time,
              animationController: _hourlyButtonController,
              scaleAnimation: _hourlyScaleAnimation,
              gradient: const LinearGradient(
                colors: [Color(0xFF9C27B0), Color(0xFF6A1B9A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            DView.width(8),
            buttonAction(
              onTap: () {
                _notificationButtonController
                    .forward()
                    .then((_) => _notificationButtonController.reverse());
                _showNotificationDialog();
              },
              title: 'Alerts',
              icon: Icons.notifications,
              animationController: _notificationButtonController,
              scaleAnimation: _notificationScaleAnimation,
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFFFA726),
                  Color(0xFFF57C00)
                ], // Orange gradient
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ],
        ),
        DView.height(8),
        // New third row of buttons
        Row(
          children: [
            buttonAction(
              onTap: _showHistoryPage,
              title: 'History',
              icon: Icons.history,
              animationController: _historyButtonController,
              scaleAnimation: _historyScaleAnimation,
              gradient: const LinearGradient(
                colors: [Color(0xFFFF7043), Color(0xFFE64A19)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            DView.width(8),
            buttonAction(
              onTap: _showSavedLocationsBottomSheet,
              title: 'Saved',
              icon: Icons.star,
              animationController: _savedLocationsButtonController,
              scaleAnimation: _savedLocationsScaleAnimation,
              gradient: const LinearGradient(
                colors: [Color(0xFFFFD54F), Color(0xFFFFC107)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget buttonAction({
    required VoidCallback onTap,
    required String title,
    required IconData icon,
    Widget? customIconWidget,
    required Gradient gradient,
    AnimationController? animationController,
    Animation<double>? scaleAnimation,
  }) {
    Widget buttonContent = Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
            ),
          ),
          DView.width(4),
          customIconWidget ?? Icon(icon, size: 12, color: Colors.white),
        ],
      ),
    );

    // If we have animation controllers, wrap in animated builder
    if (animationController != null && scaleAnimation != null) {
      buttonContent = AnimatedBuilder(
        animation: animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: scaleAnimation.value,
            child: child,
          );
        },
        child: buttonContent,
      );
    }

    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.3),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 2,
              offset: const Offset(0, 1),
            )
          ],
          gradient: gradient,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(30),
            child: buttonContent,
          ),
        ),
      ),
    );
  }

  Widget foreground() {
    return BlocBuilder<CurrentWeatherBloc, CurrentWeatherState>(
      builder: (context, state) {
        if (state is CurrentWeatherLoading) return DView.loadingCircle();
        if (state is CurrentWeatherFailure) {
          return Column(
            key: const Key('part_error'),
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DView.error(data: state.message),
              IconButton.filledTonal(
                onPressed: () {
                  refresh();
                },
                icon: const Icon(Icons.refresh),
              ),
            ],
          );
        }
        if (state is CurrentWeatherLoaded) {
          final weather = state.data;
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              key: const Key('weather_loaded'),
              // Increase bottom padding by 1 more pixel to fix the overflow
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 151),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    weather.cityName ?? '',
                    style: const TextStyle(
                      fontSize: 30,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          blurRadius: 6,
                          color: Colors.black12,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '- ${weather.main} -',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          blurRadius: 6,
                          color: Colors.black26,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                  ),
                  ExtendedImage.asset(
                    weather.icon,
                    height: 100,
                    width: 100,
                  ),
                  Text(
                    weather.description.capitalize,
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          blurRadius: 6,
                          color: Colors.black45,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    DateFormat('EEEE, d MMM yyyy').format(DateTime.now()),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                      shadows: [
                        Shadow(
                          blurRadius: 6,
                          color: Colors.black26,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                  ),
                  DView.height(20),
                  Text(
                    '${weather.temperature.round()}\u2103',
                    style: const TextStyle(
                      fontSize: 50,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          blurRadius: 6,
                          color: Colors.black26,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                  ),
                  DView.height(25), // Further reduced from 30
                  GridView(
                    padding: const EdgeInsets.all(0),
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      // Further reduced to ensure no overflow
                      mainAxisExtent: 54,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                    ),
                    children: [
                      itemStat(
                        icon: Icons.thermostat,
                        title: 'Temperature',
                        data: '${weather.temperature}°C',
                      ),
                      itemStat(
                        icon: Icons.air,
                        title: 'Wind',
                        data: '${weather.wind}m/s',
                      ),
                      itemStat(
                        icon: Icons.compare_arrows,
                        title: 'Pressure',
                        data: '${NumberFormat.currency(
                          decimalDigits: 0,
                          symbol: '',
                        ).format(weather.pressureSurfaceLevel)}hPa',
                      ),
                      itemStat(
                        icon: Icons.water_drop_outlined,
                        title: 'Humidity',
                        data: '${weather.humidity}%',
                      ),
                    ],
                  ),
                  // Even more bottom padding
                  SizedBox(height: MediaQuery.of(context).padding.bottom + 30),
                ],
              ),
            ),
          );
        }
        return Container();
      },
    );
  }

  // Make the stat items slightly more compact
  Widget itemStat({
    required IconData icon,
    required String title,
    required String data,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(
        vertical: 5, // Further reduced from 6
        horizontal: 12,
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.white,
            foregroundColor: Theme.of(context).primaryColor,
            radius: 15, // Further reduced from 16
            child: Icon(icon, size: 15), // Further reduced from 16
          ),
          DView.width(6),
          Expanded(
            // Wrap in Expanded to prevent text overflow
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11, // Reduced from 12
                    color: Colors.white70,
                  ),
                ),
                Text(
                  data,
                  style: const TextStyle(
                    fontSize: 13, // Reduced from 14
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Add these new notification-related methods
  void _showNotificationDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: const Color(0xFF4A9EF7).withOpacity(0.9),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'Weather Alerts',
            style: TextStyle(
              fontSize: 22,
              color: Colors.white,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  blurRadius: 3,
                  color: Colors.black26,
                  offset: Offset(1, 1),
                ),
              ],
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildNotificationSwitch(
                setState,
                title: 'Rain Alerts',
                subtitle: 'Get notified when rain is expected',
                value: _rainAlerts,
                onChanged: (value) {
                  setState(() => _rainAlerts = value);
                },
                icon: Icons.water_drop,
              ),
              const Divider(color: Colors.white30, height: 1),
              _buildNotificationSwitch(
                setState,
                title: 'Storm Alerts',
                subtitle: 'Get notified about incoming storms',
                value: _stormAlerts,
                onChanged: (value) {
                  setState(() => _stormAlerts = value);
                },
                icon: Icons.thunderstorm,
              ),
              const Divider(color: Colors.white30, height: 1),
              _buildNotificationSwitch(
                setState,
                title: 'Temperature Alerts',
                subtitle: 'Alerts for significant temperature changes',
                value: _temperatureAlerts,
                onChanged: (value) {
                  setState(() => _temperatureAlerts = value);
                },
                icon: Icons.thermostat,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white70,
              ),
              child: const Text('CANCEL'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF4A9EF7),
                elevation: 2,
              ),
              onPressed: () {
                _saveNotificationSettings();
                Navigator.pop(context);

                // Show confirmation
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Weather alerts ${_hasAnyAlerts() ? 'enabled' : 'disabled'}'),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor:
                        _hasAnyAlerts() ? Colors.green : Colors.grey,
                  ),
                );
              },
              child: const Text('SAVE'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSwitch(
    StateSetter setState, {
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: Colors.green.shade300,
          ),
        ],
      ),
    );
  }

  bool _hasAnyAlerts() {
    return _rainAlerts || _stormAlerts || _temperatureAlerts;
  }

  // Initialize the notification system
  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap
        print('Notification tapped: ${response.payload}');
      },
    );

    // Create notification channels for Android
    if (Theme.of(context).platform == TargetPlatform.android) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(const AndroidNotificationChannel(
            'weather_alerts_channel',
            'Weather Alerts',
            description: 'Notifications for important weather conditions',
            importance: Importance.high,
          ));

      // Request notification permissions for Android 13+ (API level 33+)
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();

      // Request permission for exact alarms if needed
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestExactAlarmsPermission();
    }
  }

  // Load saved notification settings
  Future<void> _loadNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _rainAlerts = prefs.getBool(_keyRainAlerts) ?? false;
      _stormAlerts = prefs.getBool(_keyStormAlerts) ?? false;
      _temperatureAlerts = prefs.getBool(_keyTempAlerts) ?? false;
    });
  }

  // Revised implementation for saving notification settings
  Future<void> _saveNotificationSettings() async {
    // Save preferences to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyRainAlerts, _rainAlerts);
    await prefs.setBool(_keyStormAlerts, _stormAlerts);
    await prefs.setBool(_keyTempAlerts, _temperatureAlerts);

    // Log configuration
    print('Weather alerts configuration saved:');
    print('Rain alerts: $_rainAlerts');
    print('Storm alerts: $_stormAlerts');
    print('Temperature alerts: $_temperatureAlerts');

    // Cancel existing timer if it exists
    _weatherCheckTimer?.cancel();

    // If any alerts are enabled, start periodic weather checks
    if (_hasAnyAlerts()) {
      // Check weather conditions every 30 minutes (adjust as needed)
      _weatherCheckTimer = Timer.periodic(
          const Duration(minutes: 30), (_) => _checkWeatherConditions());

      // Do an immediate check
      _checkWeatherConditions();
    }
  }

  // Check weather conditions and send notifications if needed
  Future<void> _checkWeatherConditions() async {
    try {
      // Get current weather state from the bloc
      final state = context.read<CurrentWeatherBloc>().state;

      if (state is CurrentWeatherLoaded) {
        final weather = state.data;
        final weatherDescription = weather.description.toLowerCase();
        final temperature = weather.temperature;

        // Check for rain conditions
        if (_rainAlerts &&
            (weatherDescription.contains('rain') ||
                weatherDescription.contains('drizzle'))) {
          _showWeatherNotification('Rain Alert',
              'Rain expected in ${weather.cityName ?? "your area"}.', 'rain');
        }

        // Check for storm conditions
        if (_stormAlerts &&
            (weatherDescription.contains('storm') ||
                weatherDescription.contains('thunder'))) {
          _showWeatherNotification('Storm Alert',
              'Storm expected in ${weather.cityName ?? "your area"}.', 'storm');
        }

        // Check for extreme temperature (adjust thresholds as needed)
        if (_temperatureAlerts) {
          if (temperature > 30) {
            _showWeatherNotification(
                'High Temperature Alert',
                'Temperature is ${temperature.toStringAsFixed(1)}°C in ${weather.cityName ?? "your area"}.',
                'high_temp');
          } else if (temperature < 0) {
            _showWeatherNotification(
                'Low Temperature Alert',
                'Temperature is ${temperature.toStringAsFixed(1)}°C in ${weather.cityName ?? "your area"}.',
                'low_temp');
          }
        }
      }
    } catch (e) {
      print('Error checking weather conditions: $e');
    }
  }

  // Show a notification
  Future<void> _showWeatherNotification(
      String title, String body, String payload) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'weather_alerts_channel',
      'Weather Alerts',
      channelDescription: 'Notifications for important weather conditions',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'Weather Alert',
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecond, // Random ID based on current time
      title,
      body,
      platformDetails,
      payload: payload,
    );

    print('Notification sent: $title - $body');
  }

  // Load saved locations from SharedPreferences
  Future<void> _loadSavedLocations() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLocationsJson = prefs.getString(_keySavedLocations);

    if (savedLocationsJson != null) {
      try {
        final List<dynamic> decoded = jsonDecode(savedLocationsJson);
        setState(() {
          _savedLocations = decoded.cast<Map<String, dynamic>>();
        });
        print('Loaded ${_savedLocations.length} saved locations');
      } catch (e) {
        print('Error loading saved locations: $e');
        _savedLocations = [];
      }
    }
  }

  // Save locations to SharedPreferences
  Future<void> _saveSavedLocations() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLocationsJson = jsonEncode(_savedLocations);
    await prefs.setString(_keySavedLocations, savedLocationsJson);
    print('Saved ${_savedLocations.length} locations to preferences');
  }

  // Add current location to saved locations
  Future<void> _addCurrentLocationToSaved() async {
    final state = context.read<CurrentWeatherBloc>().state;
    if (state is CurrentWeatherLoaded) {
      final weather = state.data;

      // Check if location already saved
      final locationName = weather.cityName ?? 'Unknown';
      final existingIndex = _savedLocations
          .indexWhere((location) => location['name'] == locationName);

      if (existingIndex >= 0) {
        // Update existing location
        setState(() {
          _savedLocations[existingIndex] = {
            'name': locationName,
            'temperature': weather.temperature,
            'description': weather.description,
            'icon': weather.icon,
            'timestamp': DateTime.now().millisecondsSinceEpoch,
          };
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Updated saved location: $locationName'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        // Add new location
        setState(() {
          _savedLocations.add({
            'name': locationName,
            'temperature': weather.temperature,
            'description': weather.description,
            'icon': weather.icon,
            'timestamp': DateTime.now().millisecondsSinceEpoch,
          });
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added to saved locations: $locationName'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
          ),
        );
      }

      // Save to SharedPreferences
      await _saveSavedLocations();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot save location at this time'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Remove location from saved locations
  Future<void> _removeSavedLocation(int index) async {
    final locationName = _savedLocations[index]['name'];

    setState(() {
      _savedLocations.removeAt(index);
    });

    await _saveSavedLocations();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Removed from saved locations: $locationName'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Set saved location as current
  void _setLocationAsCurrent(String locationName) {
    Navigator.pushNamed(
      context,
      AppRoute.pickPlace.name,
      arguments: {'searchQuery': locationName},
    ).then((backResponse) {
      if (backResponse == 'refresh') refresh();
    });

    Navigator.pop(context); // Close bottom sheet
  }

  // Fix the capitalize error in saved locations bottom sheet
  void _showSavedLocationsBottomSheet() {
    _savedLocationsButtonController
        .forward()
        .then((_) => _savedLocationsButtonController.reverse());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 5,
              )
            ],
          ),
          child: Column(
            children: [
              // Handle and title
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF4A9EF7),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(2.5),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Saved Locations',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _addCurrentLocationToSaved,
                          icon: const Icon(Icons.add_location_alt, size: 16),
                          label: const Text('Add Current'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF4A9EF7),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            textStyle: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // List of saved locations
              Expanded(
                child: _savedLocations.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.location_off,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No saved locations yet',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Add your favorite locations for quick access',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: _savedLocations.length,
                        itemBuilder: (context, index) {
                          final location = _savedLocations[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  // Location icon or weather icon
                                  CircleAvatar(
                                    backgroundColor: const Color(0xFF4A9EF7)
                                        .withOpacity(0.2),
                                    child: location['icon'] != null
                                        ? Image.asset(
                                            location['icon'],
                                            width: 30,
                                            height: 30,
                                          )
                                        : const Icon(Icons.place),
                                  ),
                                  const SizedBox(width: 16),
                                  // Location details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          location['name'] ??
                                              'Unknown Location',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        if (location['description'] != null)
                                          Text(
                                            // Fix capitalize error with null safety and direct capitalization
                                            location['description'] != null
                                                ? _capitalizeString(
                                                    location['description'])
                                                : '',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  // Temperature
                                  if (location['temperature'] != null)
                                    Padding(
                                      padding: const EdgeInsets.only(right: 16),
                                      child: Text(
                                        '${location['temperature'].round()}°C',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF4A9EF7),
                                        ),
                                      ),
                                    ),
                                  // Action buttons
                                  Column(
                                    children: [
                                      IconButton(
                                        onPressed: () => _setLocationAsCurrent(
                                            location['name']),
                                        icon: const Icon(
                                          Icons.navigation,
                                          color: Color(0xFF4A9EF7),
                                        ),
                                        tooltip: 'Set as current',
                                        constraints: const BoxConstraints(),
                                        padding: const EdgeInsets.all(8),
                                      ),
                                      IconButton(
                                        onPressed: () =>
                                            _removeSavedLocation(index),
                                        icon: const Icon(
                                          Icons.delete_outline,
                                          color: Colors.redAccent,
                                        ),
                                        tooltip: 'Remove',
                                        constraints: const BoxConstraints(),
                                        padding: const EdgeInsets.all(8),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Add helper method to capitalize strings safely
  String _capitalizeString(String? text) {
    if (text == null || text.isEmpty) return '';
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  // Show history page - placeholder implementation
  void _showHistoryPage() {
    _historyButtonController
        .forward()
        .then((_) => _historyButtonController.reverse());

    // Navigate to the history page using the correct route name
    Navigator.pushNamed(context, AppRoute.weatherDetail.name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Remove extra padding on the screen
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        // Enable bottom safe area to properly handle system UI
        bottom: true,
        child: Stack(
          children: [
            // FIRST LAYER: Background gradient
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF4A9EF7), Color(0xFFDDEAF9)],
                ),
              ),
            ),

            // SECOND LAYER: Animated background - The key fix is here!
            // Moving this up in the stack ensures it's visible beneath other elements
            _showLottieAnimation
                ? _buildLottieAnimation(_getCurrentWeatherDescription())
                : _buildCustomAnimations(),

            // THIRD LAYER: Shadows
            Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                height: MediaQuery.of(context).size.height / 2,
                width: double.infinity,
                child: const BasicShadow(topDown: false),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height / 8,
              width: double.infinity,
              child: const BasicShadow(topDown: true),
            ),

            // FOURTH LAYER: UI elements (header and content)
            Column(
              children: [
                Padding(
                  // Adjust top padding since we're using SafeArea now
                  padding: const EdgeInsets.only(
                    left: 20,
                    top: 10, // Reduced from 20
                    right: 20,
                  ),
                  child: headerAction(),
                ),
                Expanded(
                  child: foreground(),
                ),
              ],
            ),

            // FIFTH LAYER: Animation controls always on top
            // Redesigned toggle button that better aligns with the weather theme
            Positioned(
              top: 200,
              right: 20,
              child: Container(
                height: 70,
                width: 70,
                decoration: BoxDecoration(
                  // Use a weather-themed gradient instead of solid colors
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: _showLottieAnimation
                        ? [const Color(0xFF48CAE4), const Color(0xFF0096C7)]
                        : [const Color(0xFF90E0EF), const Color(0xFF48CAE4)],
                  ),
                  borderRadius: BorderRadius.circular(35),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                    BoxShadow(
                      color: Colors.white.withOpacity(0.2),
                      blurRadius: 5,
                      spreadRadius: -1,
                      offset: const Offset(-2, -2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(35),
                    onTap: () {
                      print(
                          "ANIMATION TOGGLE PRESSED - Current: $_showLottieAnimation");
                      setState(() {
                        _showLottieAnimation = !_showLottieAnimation;
                      });
                      // Force rebuild
                      Future.delayed(Duration.zero, () {
                        setState(() {});
                      });
                    },
                    child: Center(
                      child: Icon(
                        _showLottieAnimation ? Icons.auto_awesome : Icons.waves,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Animation mode indicator with weather-themed appearance
            Positioned(
              top: 280,
              right: 20,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  // Use a weather-theme gradient that matches the button
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: _showLottieAnimation
                        ? [const Color(0xFF48CAE4), const Color(0xFF0096C7)]
                        : [const Color(0xFF90E0EF), const Color(0xFF48CAE4)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 4,
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: Colors.white.withOpacity(0.1),
                      blurRadius: 4,
                      spreadRadius: 0,
                      offset: const Offset(-1, -1),
                    )
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _showLottieAnimation ? Icons.auto_awesome : Icons.waves,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _showLottieAnimation ? "LOTTIE" : "CUSTOM",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Animated version of the sun painter
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
      ..color = Colors.white
          .withOpacity(0.3 - 0.15 * ripplePhase) // Opacity animation
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Base ripples
    for (double i = 50; i <= 80; i += 15) {
      // Add phase offset to create animated ripples
      double rippleRadius = i + (10 * ripplePhase);
      canvas.drawCircle(const Offset(40, 40), rippleRadius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant SunWithRipplesPainter oldDelegate) =>
      oldDelegate.ripplePhase != ripplePhase;
}

// Cloud Painter (same as before)
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

// Add a rain painter for rain animation
class RainPainter extends CustomPainter {
  final double animationValue;
  final int density;

  RainPainter({
    required this.animationValue,
    this.density = 50,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.white.withOpacity(0.7)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.5;

    final random = DateTime.now().millisecondsSinceEpoch;

    for (int i = 0; i < density; i++) {
      // Pseudo-random positions
      final double x = ((i * 17 + random) % 100) * size.width / 100;
      final double length = 10.0 + ((i * 13) % 20);

      // Calculate y position with animation
      final double startY = ((i * 19 + random) % 100) * size.height / 100;
      final double y = (startY + animationValue * 15) % size.height;

      // Draw raindrop
      canvas.drawLine(
        Offset(x, y),
        Offset(x - 1, y + length),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant RainPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}
