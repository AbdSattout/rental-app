import "package:flutter/material.dart";
import "package:smooth_page_indicator/smooth_page_indicator.dart";

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static ColorScheme lightScheme() {
    return .fromSeed(
      seedColor: .fromARGB(255, 166, 153, 254),
      brightness: .light,
    ).copyWith(
      brightness: .light,
      primary: Color.fromARGB(255, 166, 153, 254),
      surfaceTint: Color(0xff5e5791),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xffe5deff),
      onPrimaryContainer: Color(0xff473f77),
      secondary: Color.fromARGB(255, 156, 156, 156),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xffe5dff9),
      onSecondaryContainer: Color(0xff474459),
      tertiary: Color(0xff7c5265),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xffffd8e7),
      onTertiaryContainer: Color(0xff613b4d),
      error: Color(0xffba1a1a),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffffdad6),
      onErrorContainer: Color(0xff93000a),
      surface: Color.fromARGB(255, 244, 244, 244),
      onSurface: Color(0xff1c1b20),
      onSurfaceVariant: Color(0xff48454f),
      outline: Color(0xff78767f),
      outlineVariant: Color(0xffc9c5d0),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff313036),
      inversePrimary: Color(0xffc8bfff),
      primaryFixed: Color(0xffe5deff),
      onPrimaryFixed: Color(0xff1b1249),
      primaryFixedDim: Color(0xffc8bfff),
      onPrimaryFixedVariant: Color(0xff473f77),
      secondaryFixed: Color(0xffe5dff9),
      onSecondaryFixed: Color(0xff1c192b),
      secondaryFixedDim: Color(0xffc9c3dc),
      onSecondaryFixedVariant: Color(0xff474459),
      tertiaryFixed: Color(0xffffd8e7),
      onTertiaryFixed: Color(0xff301121),
      tertiaryFixedDim: Color(0xffecb8ce),
      onTertiaryFixedVariant: Color(0xff613b4d),
      surfaceDim: Color(0xffddd8e0),
      surfaceBright: Color(0xffffffff),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff7f2fa),
      surfaceContainer: Color(0xfff1ecf4),
      surfaceContainerHigh: Color(0xffebe6ee),
      surfaceContainerHighest: Color(0xffe5e1e9),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme darkScheme() {
    return .fromSeed(seedColor: .new(0xA79AFE), brightness: .dark).copyWith(
      brightness: Brightness.dark,
      primary: Color(0xffc8bfff),
      surfaceTint: Color(0xffc8bfff),
      onPrimary: Color(0xff30285f),
      primaryContainer: Color(0xff473f77),
      onPrimaryContainer: Color(0xffe5deff),
      secondary: Color(0xffc9c3dc),
      onSecondary: Color(0xff312e41),
      secondaryContainer: Color(0xff474459),
      onSecondaryContainer: Color(0xffe5dff9),
      tertiary: Color(0xffecb8ce),
      onTertiary: Color(0xff482536),
      tertiaryContainer: Color(0xff613b4d),
      onTertiaryContainer: Color(0xffffd8e7),
      error: Color(0xffffb4ab),
      onError: Color(0xff690005),
      errorContainer: Color(0xff93000a),
      onErrorContainer: Color(0xffffdad6),
      surface: Color(0xff141318),
      onSurface: Color(0xffe5e1e9),
      onSurfaceVariant: Color(0xffc9c5d0),
      outline: Color(0xff928f99),
      outlineVariant: Color(0xff48454f),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe5e1e9),
      inversePrimary: Color(0xff5e5791),
      primaryFixed: Color(0xffe5deff),
      onPrimaryFixed: Color(0xff1b1249),
      primaryFixedDim: Color(0xffc8bfff),
      onPrimaryFixedVariant: Color(0xff473f77),
      secondaryFixed: Color(0xffe5dff9),
      onSecondaryFixed: Color(0xff1c192b),
      secondaryFixedDim: Color(0xffc9c3dc),
      onSecondaryFixedVariant: Color(0xff474459),
      tertiaryFixed: Color(0xffffd8e7),
      onTertiaryFixed: Color(0xff301121),
      tertiaryFixedDim: Color(0xffecb8ce),
      onTertiaryFixedVariant: Color(0xff613b4d),
      surfaceDim: Color(0xff141318),
      surfaceBright: Color(0xff3a383e),
      surfaceContainerLowest: Color(0xff0e0d13),
      surfaceContainerLow: Color(0xff1c1b20),
      surfaceContainer: Color(0xff201f25),
      surfaceContainerHigh: Color(0xff2a292f),
      surfaceContainerHighest: Color(0xff35343a),
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  ThemeData theme(ColorScheme colorScheme) => ThemeData(
    useMaterial3: true,
    brightness: colorScheme.brightness,
    colorScheme: colorScheme,
    textTheme: textTheme.apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    ),
    inputDecorationTheme: InputDecorationTheme(
      prefixIconColor: colorScheme.secondary,
      suffixIconColor: colorScheme.secondary,
      border: OutlineInputBorder(
        borderRadius: .circular(10),
        borderSide: .none,
      ),
      filled: true,
      fillColor: colorScheme.surfaceBright,
      hintStyle: .new(color: colorScheme.secondary),
    ),
    buttonTheme: ButtonThemeData(
      padding: .symmetric(horizontal: 16, vertical: 8),
      shape: RoundedSuperellipseBorder(borderRadius: .circular(10)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: .symmetric(horizontal: 16, vertical: 8),
        shape: RoundedSuperellipseBorder(borderRadius: .circular(10)),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        padding: .symmetric(horizontal: 16, vertical: 8),
        shape: RoundedSuperellipseBorder(borderRadius: .circular(10)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: .symmetric(horizontal: 16, vertical: 8),
        shape: RoundedSuperellipseBorder(borderRadius: .circular(10)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        padding: .symmetric(horizontal: 16, vertical: 8),
        shape: RoundedSuperellipseBorder(borderRadius: .circular(10)),
      ),
    ),
    cardTheme: CardThemeData(
      shape: RoundedSuperellipseBorder(borderRadius: .circular(10)),
    ),
    appBarTheme: AppBarTheme(
      centerTitle: true,
      foregroundColor: colorScheme.primary,
    ),
    scaffoldBackgroundColor: colorScheme.surface,
    canvasColor: colorScheme.surface,
    extensions: [
      SmoothPageIndicatorTheme(
        effect: ExpandingDotsEffect(dotHeight: 8, dotWidth: 8),
        defaultColors: DefaultIndicatorColors(
          active: colorScheme.primary,
          inactive: colorScheme.primaryContainer,
        ),
      ),
    ],
  );
}
