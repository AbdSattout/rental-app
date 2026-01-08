import 'package:flutter/material.dart';

enum NavItem { home, map, profile, settings }

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

  Widget _buildNavItem(IconData icon, int index) {
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
          Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          Colors.white,
          animationFactor,
        )!;
        final Color backgroundColor = Color.lerp(
          Colors.transparent,
          Theme.of(context).colorScheme.primary,
          animationFactor,
        )!;
        final double blurRadius = 15.0 * animationFactor;
        final double spreadRadius = 1.0 * animationFactor;
        final Color shadowColor = Theme.of(
          context,
        ).colorScheme.primary.withValues(alpha: 0.7 * animationFactor);

        return GestureDetector(
          onTap: () => onChanged(index),
          child: Transform(
            transform: Matrix4.identity()
              ..translate(0.0, translateY)
              ..scale(scale),
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: .min,
              children: [
                Container(
                  height: size,
                  width: size,
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    shape: BoxShape.circle,
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
                    child: Icon(icon, color: iconColor, size: iconSize),
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
      padding: const .all(20),
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: .circular(25.0),
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
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            _buildNavItem(Icons.home, 0),
            _buildNavItem(Icons.map, 1),
            _buildNavItem(Icons.person, 2),
            _buildNavItem(Icons.settings, 3),
          ],
        ),
      ),
    );
  }
}
