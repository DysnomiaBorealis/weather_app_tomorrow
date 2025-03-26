import 'dart:math';

import 'package:d_view/d_view.dart';
import 'package:extended_image/extended_image.dart';

import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:weather_app_tommorow/common/extension.dart';
import 'package:weather_app_tommorow/features/weather/domain/entity/weather_entity.dart';
import 'package:weather_app_tommorow/features/weather/presentation/bloc/hourly_forecast/hourly_forecast_bloc.dart';
import 'package:weather_app_tommorow/features/weather/presentation/widget/basic_shadow.dart';

class HourlyForecastPage extends StatefulWidget {
  const HourlyForecastPage({super.key});

  @override
  State<HourlyForecastPage> createState() => _HourlyForecastPageState();
}

class _HourlyForecastPageState extends State<HourlyForecastPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _cloudAnimation;
  late Animation<double> _cloud2Animation;
  late Animation<double> _cloud3Animation;
  late Animation<double> _timelineAnimation;
  late Animation<double> _particleAnimation;

  refresh() {
    context.read<HourlyForecastBloc>().add(OnGetHourlyForecast());
  }

  List<WeatherEntity> _ensureSortedData(List<WeatherEntity> inputList) {
    // Clone the list to avoid mutation issues
    final List<WeatherEntity> sortedList = List<WeatherEntity>.from(inputList);

    // Debug log before sorting
    print('BEFORE SORTING - Hourly forecast timestamps:');
    for (var i = 0; i < sortedList.length; i++) {
      print(
          '$i: ${sortedList[i].dateTime.toIso8601String()} - ${DateFormat('HH:mm').format(sortedList[i].dateTime)}');
    }

    // Sort the list using our compareByDateTime method
    sortedList.sort((a, b) => a.compareByDateTime(b));

    // Debug log after sorting
    print('AFTER SORTING - Hourly forecast timestamps:');
    for (var i = 0; i < sortedList.length; i++) {
      print(
          '$i: ${sortedList[i].dateTime.toIso8601String()} - ${DateFormat('HH:mm').format(sortedList[i].dateTime)}');
    }

    return sortedList;
  }

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat(reverse: true);

    // Cloud floating animations
    _cloudAnimation = Tween<double>(
      begin: -20.0,
      end: 20.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _cloud2Animation = Tween<double>(
      begin: -15.0,
      end: 15.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.1, 0.9, curve: Curves.easeInOut),
      ),
    );

    _cloud3Animation = Tween<double>(
      begin: -25.0,
      end: 25.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeInOut),
      ),
    );

    // Timeline animation for hourly forecast visual effect
    _timelineAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
      ),
    );

    // Floating particles animation
    _particleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_animationController);

    refresh();
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget background() {
    return Stack(
      children: [
        // Gradient Background - Use a time-of-day inspired gradient
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF2C3E50), Color(0xFF4CA1AF)],
            ),
          ),
        ),

        // Add floating particles in the background
        AnimatedBuilder(
          animation: _particleAnimation,
          builder: (context, child) {
            return CustomPaint(
              painter: TimeParticlesPainter(
                animationValue: _particleAnimation.value,
                particleCount: 50,
              ),
              size: Size.infinite,
            );
          },
        ),

        // Animated timeline graphic
        Positioned(
          left: 20,
          right: 20,
          top: MediaQuery.of(context).padding.top + 70,
          child: AnimatedBuilder(
            animation: _timelineAnimation,
            builder: (context, child) {
              return CustomPaint(
                painter: TimelinePainter(
                  progress: _timelineAnimation.value,
                ),
                size: const Size(double.infinity, 3),
              );
            },
          ),
        ),

        // Cloud 1
        Positioned(
          top: 100,
          right: -50,
          child: AnimatedBuilder(
            animation: _cloudAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(_cloudAnimation.value, 0),
                child: Opacity(
                  opacity: 0.4,
                  child: CustomPaint(
                    size: const Size(200, 100),
                    painter: CloudPainter(),
                  ),
                ),
              );
            },
          ),
        ),

        // Cloud 2
        Positioned(
          top: 180,
          left: -80,
          child: AnimatedBuilder(
            animation: _cloud2Animation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(_cloud2Animation.value, 0),
                child: Opacity(
                  opacity: 0.3,
                  child: Transform.scale(
                    scale: 1.5,
                    child: CustomPaint(
                      size: const Size(200, 100),
                      painter: CloudPainter(),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Cloud 3
        Positioned(
          bottom: 100,
          right: 20,
          child: AnimatedBuilder(
            animation: _cloud3Animation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(_cloud3Animation.value, 0),
                child: Opacity(
                  opacity: 0.2,
                  child: Transform.scale(
                    scale: 0.8,
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
      ],
    );
  }

  Widget foreground() {
    return Column(
      children: [
        AppBar(
          title: const Text('Hourly Forecast',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    blurRadius: 5,
                    color: Colors.black45,
                    offset: Offset(1, 1),
                  ),
                ],
              )),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          forceMaterialTransparency: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        Expanded(
          child: BlocBuilder<HourlyForecastBloc, HourlyForecastState>(
            builder: (context, state) {
              if (state is HourlyForecastLoading) return DView.loadingCircle();
              if (state is HourlyForecastFailure) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      state.message,
                      style: const TextStyle(
                        color: Colors.white60,
                      ),
                    ),
                    DView.height(8),
                    IconButton.filledTonal(
                      onPressed: () {
                        refresh();
                      },
                      icon: const Icon(Icons.refresh),
                    ),
                  ],
                );
              }
              if (state is HourlyForecastLoaded) {
                // Get sorted data
                final list = _ensureSortedData(state.data);

                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.3),
                      ],
                    ),
                  ),
                  child: GroupedListView<WeatherEntity, String>(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(0),
                    elements: list,
                    groupBy: (element) =>
                        DateFormat('yyyy-MM-dd').format(element.dateTime),
                    groupHeaderBuilder: (element) {
                      return Align(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 5,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 20,
                          ),
                          child: Text(
                            DateFormat('EEEE, d MMM yyyy')
                                .format(element.dateTime),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                    order: GroupedListOrder
                        .ASC, // Ensure items are displayed in ascending order
                    itemComparator: (item1, item2) => item1.compareByDateTime(
                        item2), // Add this explicit comparator
                    itemBuilder: (context, weather) {
                      // Debug print each item as it's rendered
                      print(
                          'Rendering forecast for: ${DateFormat('yyyy-MM-dd HH:mm').format(weather.dateTime)}');

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        color: Colors.white.withOpacity(0.1),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              _buildWeatherIcon(
                                  weather.icon, weather.description),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      DateFormat('HH:mm')
                                          .format(weather.dateTime),
                                      style: const TextStyle(
                                        fontSize: 18,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      weather.description.capitalize,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        const Icon(Icons.water_drop,
                                            color: Colors.lightBlueAccent,
                                            size: 14),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${weather.humidity}%',
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Icon(Icons.air,
                                            color: Colors.white70, size: 14),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${weather.wind}m/s',
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '${weather.temperature.round()}\u2103',
                                style: const TextStyle(
                                  fontSize: 24,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              }
              return Container();
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: background(),
          ),
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
          foreground(),
        ],
      ),
    );
  }

  Widget _buildWeatherIcon(String iconPath, String description) {
    // Check if it's a local asset path
    if (iconPath.startsWith('assets/')) {
      return ExtendedImage.asset(
        iconPath,
        height: 70,
        width: 70,
        fit: BoxFit.contain,
        loadStateChanged: (state) {
          switch (state.extendedImageLoadState) {
            case LoadState.loading:
              return const Center(
                child: SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(
                    color: Colors.white54,
                    strokeWidth: 2,
                  ),
                ),
              );
            case LoadState.failed:
              debugPrint('Failed to load asset image: $iconPath');
              return _getWeatherFallbackIcon(description);
            case LoadState.completed:
              return null; // Return null to display the loaded image
          }
        },
      );
    }
    // It's a network URL
    else {
      return ExtendedImage.network(
        iconPath.startsWith('https')
            ? iconPath
            : iconPath.replaceFirst('http', 'https'),
        height: 70,
        width: 70,
        cache: true,
        enableLoadState: true,
        handleLoadingProgress: true,
        retries: 3,
        timeLimit: const Duration(seconds: 15),
        loadStateChanged: (state) {
          switch (state.extendedImageLoadState) {
            case LoadState.loading:
              return const Center(
                child: SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(
                    color: Colors.white54,
                    strokeWidth: 2,
                  ),
                ),
              );
            case LoadState.failed:
              debugPrint('Failed to load network image: $iconPath');
              return _getWeatherFallbackIcon(description);
            case LoadState.completed:
              return null; // Return null to display the loaded image
          }
        },
      );
    }
  }

  Widget _getWeatherFallbackIcon(String description) {
    final desc = description.toLowerCase();
    IconData iconData;

    if (desc.contains('clear') || desc.contains('sunny')) {
      iconData = Icons.wb_sunny;
    } else if (desc.contains('cloud')) {
      iconData = Icons.cloud;
    } else if (desc.contains('rain') || desc.contains('shower')) {
      iconData = Icons.beach_access;
    } else if (desc.contains('snow') || desc.contains('sleet')) {
      iconData = Icons.ac_unit;
    } else if (desc.contains('thunder') || desc.contains('storm')) {
      iconData = Icons.flash_on;
    } else if (desc.contains('mist') || desc.contains('fog')) {
      iconData = Icons.cloud_queue;
    } else {
      iconData = Icons.cloud;
    }

    return Container(
      height: 70,
      width: 70,
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        iconData,
        color: Colors.white70,
        size: 40,
      ),
    );
  }
}

// Cloud Painter reused from current_weather_page
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

// Small Cloud Painter reused from current_weather_page
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

// New painter for the timeline effect
class TimelinePainter extends CustomPainter {
  final double progress;

  TimelinePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    // Background line
    final Paint bgPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      bgPaint,
    );

    // Animated progress line
    final Paint progressPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width * progress, size.height / 2),
      progressPaint,
    );

    // Draw dots for hour markers
    final Paint dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final int numDots = 24; // One for each hour
    final double spacing = size.width / (numDots - 1);

    for (int i = 0; i < numDots; i++) {
      final double x = i * spacing;
      final double radius = (progress * size.width >= x) ? 4.0 : 2.5;
      canvas.drawCircle(
        Offset(x, size.height / 2),
        radius,
        dotPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant TimelinePainter oldDelegate) =>
      oldDelegate.progress != progress;
}

// Floating particles effect for time representation
class TimeParticlesPainter extends CustomPainter {
  final double animationValue;
  final int particleCount;

  TimeParticlesPainter({
    required this.animationValue,
    this.particleCount = 30,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Use a fixed seed for consistent particles
    final int seed = 42;

    for (int i = 0; i < particleCount; i++) {
      // Create pseudo-random positions that are deterministic
      final double x = ((i * 17 + seed) % 100) * size.width / 100;
      final double baseY = ((i * 23 + seed) % 100) * size.height / 100;

      // Make y position dependent on animation
      final double yOffset = 20 * sin((animationValue * 2 * 3.14) + (i * 0.2));
      final double y = baseY + yOffset;

      // Vary particle sizes
      final double particleSize = 1.0 + ((i * 11) % 3);

      // Vary opacity based on animation and particle index
      final double opacity =
          0.3 + 0.3 * sin((animationValue * 3.14) + (i * 0.7));

      paint.color = Colors.white.withOpacity(opacity);

      // Draw particle
      canvas.drawCircle(
        Offset(x, y),
        particleSize,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant TimeParticlesPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}
