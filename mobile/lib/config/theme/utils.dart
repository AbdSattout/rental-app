import 'package:flutter/material.dart';

TextTheme createTextTheme(
  BuildContext context,
  String bodyFont,
  String displayFont, [
  String? bodyFallback,
  String? displayFallback,
]) {
  final base = Theme.of(context).textTheme;

  final displayTheme = base.apply(
    fontFamily: displayFont,
    fontFamilyFallback:
        displayFallback != null ? [displayFallback] : null,
  );

  final bodyTheme = base.apply(
    fontFamily: bodyFont,
    fontFamilyFallback:
        bodyFallback != null ? [bodyFallback] : null,
  );

  return displayTheme.copyWith(
    bodyLarge: bodyTheme.bodyLarge,
    bodyMedium: bodyTheme.bodyMedium,
    bodySmall: bodyTheme.bodySmall,
    labelLarge: bodyTheme.labelLarge,
    labelMedium: bodyTheme.labelMedium,
    labelSmall: bodyTheme.labelSmall,
  );
}
