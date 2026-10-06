import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double width;
  final double? height;
  final BoxFit fit;

  const AppLogo({
    super.key,
    this.width = 120,
    this.height,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/tap_jaya_logo.png',
      width: width,
      height: height,
      fit: fit,
    );
  }
}