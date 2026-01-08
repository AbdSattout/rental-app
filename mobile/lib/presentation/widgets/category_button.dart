import 'package:flutter/material.dart';

class CategoryButton extends StatefulWidget {
  final bool isSelected;
  final String title;
  final VoidCallback onTap;

  const CategoryButton({
    super.key,
    required this.isSelected,
    required this.title,
    required this.onTap,
  });

  @override
  State<CategoryButton> createState() => _CategoryButtonState();
}

class _CategoryButtonState extends State<CategoryButton> {
  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final secondaryColor = Theme.of(context).colorScheme.secondary;

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
            style: TextTheme.of(context).titleSmall!.copyWith(
              color: widget.isSelected ? Colors.white : secondaryColor,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
