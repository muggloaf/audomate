import 'package:flutter/material.dart';

import '../theme.dart';

class BrandWordmark extends StatelessWidget {
  const BrandWordmark({super.key, this.fontSize = 24});

  final double fontSize;

  @override
  Widget build(BuildContext context) => Text.rich(
    TextSpan(
      children: [
        const TextSpan(
          text: 'audo',
          style: TextStyle(color: brandGreen),
        ),
        TextSpan(
          text: 'mate.',
          style: const TextStyle(color: Colors.white),
        ),
      ],
    ),
    style: TextStyle(
      fontFamily: 'Figtree',
      fontSize: fontSize,
      height: 1,
      letterSpacing: -0.7,
      fontWeight: FontWeight.w700,
    ),
  );
}
