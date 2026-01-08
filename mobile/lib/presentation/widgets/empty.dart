import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class Empty extends StatelessWidget {
  const Empty({super.key, required this.icon, required this.message});

  final List<List<dynamic>> icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        spacing: 16,
        mainAxisAlignment: .center,
        children: [
          HugeIcon(icon: icon, size: 64),
          Text(message, style: TextTheme.of(context).titleMedium),
        ],
      ),
    );
  }
}
