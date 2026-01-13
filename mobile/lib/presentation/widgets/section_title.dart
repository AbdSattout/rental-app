import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class SectionTitle extends StatelessWidget {
  const SectionTitle({super.key, required this.title, required this.icon});

  final String title;
  final List<List<dynamic>> icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const .all(8.0),
      child: Row(
        spacing: 10,
        children: [
          HugeIcon(
            icon: icon,
            size: 18,
            color: ColorScheme.of(context).primary,
            strokeWidth: 2,
          ),
          Text(title, style: TextTheme.of(context).labelLarge),
        ],
      ),
    );
  }
}
