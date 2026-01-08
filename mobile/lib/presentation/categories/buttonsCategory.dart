import 'package:flutter/material.dart';
import 'package:homio2/models/fonts_class.dart';

class Buttonscategory extends StatefulWidget {
  //
  final bool isSelected;
  final String title;
  final VoidCallback onTap;
  //
  Buttonscategory({
    super.key,
    required this.isSelected,
    required this.title,
    required this.onTap,
  });

  @override
  State<Buttonscategory> createState() => _ButtonscategoryState();
}

class _ButtonscategoryState extends State<Buttonscategory> {
  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final secondryColor = Theme.of(context).colorScheme.secondary;
    final onSecondryColor = Theme.of(context).colorScheme.onSecondary;
    final surfaceColor = Theme.of(context).colorScheme.surface;

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          color: widget.isSelected ? primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            widget.title,
            style: FontsApp.momoTrust.copyWith(
              color: widget.isSelected ? Colors.white : secondryColor,
              fontSize: 13  ,
            ),
          ),
        ),
      ),
    );
  }
}
