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
    final primaryColor = ColorScheme.of(context).primary;
    final secondaryColor = ColorScheme.of(context).onSecondaryContainer;

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: .symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          color: widget.isSelected
              ? primaryColor
              : ColorScheme.of(context).surfaceBright,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            widget.title,
            style: TextTheme.of(context).titleSmall!.copyWith(
              color: widget.isSelected
                  ? ColorScheme.of(context).onPrimary
                  : secondaryColor,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
