import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SmartAsset extends StatelessWidget {
  final String path;
  final double? width;
  final double? height;
  final BoxFit fit;

  const SmartAsset({
    super.key,
    required this.path,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    if (path.toLowerCase().endsWith('.svg')) {
      return SvgPicture.asset(path, width: width, height: height, fit: fit);
    } else {
      return Image.asset(path, width: width, height: height, fit: fit);
    }
  }
}
