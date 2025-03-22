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

class _PickPlacePageState extends State<PickPlacePage> {
  final edtCity = TextEditingController();

  @override
  void initState() {
    edtCity.text = context.read<CityCubit>().init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pop(context),
        label: const Text('Back'),
        icon: const Icon(Icons.arrow_back),
      ),
      body: Stack(
        children: [

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
          Positioned(
            top: 80,
            left: 40,
            child: CustomPaint(
              size: const Size(150, 150),
              painter: SunWithRipplesPainter(),
            ),
          ),
          Positioned(
            bottom: 180,
            right: -120,
            child: Transform.scale(
              scale: 3,
              child: CustomPaint(
                size: const Size(350, 180),
                painter: CloudPainter(),
              ),
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
                          return IconButton.filledTonal(
                            onPressed: () {
                              context.read<CityCubit>().saveCity();
                              FocusManager.instance.primaryFocus?.unfocus();
                              Navigator.pop(context, 'refresh');
                            },
                            icon: const Icon(Icons.check),
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

// Custom Painter for Sun with Ripple Effect
class SunWithRipplesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..style = PaintingStyle.fill;

    // Draw Sun
    paint.color = Colors.orangeAccent;
    canvas.drawCircle(const Offset(40, 40), 40, paint);

    // Draw Ripple Effect
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

// Custom Painter for Cloud Shape
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
