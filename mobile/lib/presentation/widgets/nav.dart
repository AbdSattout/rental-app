import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

enum NavItem { home, chat, profile, settings }

class Nav extends StatelessWidget {
  const Nav({
    super.key,
    required this.selected,
    required this.onChanged,
    required this.pageController,
  });

  final NavItem selected;
  final void Function(int) onChanged;
  final PageController pageController;

  Widget _buildNavItem(List<List<dynamic>> icon, int index) {
    return AnimatedBuilder(
      animation: pageController,
      builder: (context, child) {
        final double page =
            pageController.hasClients && pageController.page != null
            ? pageController.page!
            : selected.index.toDouble();

        final double scrollOffset = page - index;
        final double animationFactor = 1.0 - scrollOffset.abs().clamp(0.0, 1.0);

        final double translateY = -10.0 * animationFactor;
        final double scale = 1.0 + 0.1 * animationFactor;
        final double size = 40.0 + 10.0 * animationFactor;
        final double iconSize = 25.0;

        final Color iconColor = Color.lerp(
          ColorScheme.of(context).secondary,
          ColorScheme.of(context).onPrimary,
          animationFactor,
        )!;
        final Color backgroundColor = Color.lerp(
          Colors.transparent,
          ColorScheme.of(context).primary,
          animationFactor,
        )!;
        final double blurRadius = 15.0 * animationFactor;
        final double spreadRadius = 1.0 * animationFactor;
        final Color shadowColor = ColorScheme.of(
          context,
        ).primary.withValues(alpha: 0.35 * animationFactor);

        return GestureDetector(
          onTap: () => onChanged(index),
          child: Transform(
            transform: Matrix4.identity()
              ..translateByDouble(0, translateY, 0, 1)
              ..scaleByDouble(scale, scale, 1, 1),
            alignment: .center,
            child: Column(
              mainAxisSize: .min,
              children: [
                Container(
                  height: size,
                  width: size,
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    shape: .circle,
                    boxShadow: animationFactor > 0.01
                        ? [
                            BoxShadow(
                              color: shadowColor,
                              blurRadius: blurRadius,
                              spreadRadius: spreadRadius,
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: HugeIcon(
                      icon: icon,
                      color: iconColor,
                      size: iconSize,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: .fromLTRB(
        20,
        20,
        20,
        min(MediaQuery.paddingOf(context).bottom, 20),
      ),
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: NavigationBarTheme.of(context).backgroundColor,
          borderRadius: .circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.2),
              spreadRadius: 3,
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: .spaceAround,
          children: [
            _buildNavItem(HugeIcons.strokeRoundedHome01, 0),
            _buildNavItem(HugeIcons.strokeRoundedBubbleChat, 1),
            _buildNavItem(HugeIcons.strokeRoundedUser03, 2),
            _buildNavItem(HugeIcons.strokeRoundedSettings01, 3),
          ],
        ),
      ),
    );
  }
}
