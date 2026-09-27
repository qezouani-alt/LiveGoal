import 'package:flutter/material.dart';

class AppBrandImage extends StatelessWidget {
  const AppBrandImage({super.key, required this.size, this.borderRadius});

  static const assetPath = 'assets/images/0001.png';

  final double size;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius ?? size * 0.22),
      child: Image.asset(
        assetPath,
        width: size,
        height: size,
        fit: BoxFit.cover,
        semanticLabel: 'LiveGoal AI app logo',
      ),
    );
  }
}
