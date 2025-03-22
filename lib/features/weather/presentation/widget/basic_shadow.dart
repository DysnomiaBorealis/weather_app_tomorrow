import 'package:flutter/material.dart';

class BasicShadow extends StatelessWidget {
  const BasicShadow({super.key, required this.topDown});
  final bool topDown;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: topDown ? Alignment.topCenter : Alignment.bottomCenter,
          end: topDown ? Alignment.bottomCenter : Alignment.topCenter,
          colors: const [
            Colors.black87,
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}
