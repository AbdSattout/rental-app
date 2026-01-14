import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class SectionTitle extends StatelessWidget {
  const SectionTitle({
    super.key,
    required this.title,
    required this.icon,
    this.iconSize = 18,
    this.textStyle,
  });

  final String title;
  final List<List<dynamic>> icon;
  final double iconSize;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const .all(8.0),
      child: Row(
        spacing: 10,
        children: [
          HugeIcon(
            icon: icon,
            size: iconSize,
            color: ColorScheme.of(context).primary,
            strokeWidth: 2,
          ),
          Text(title, style: textStyle ?? TextTheme.of(context).labelLarge),
        ],
      ),
    );
  }
}
