import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../l10n/app_localizations.dart';

enum NavItem { home, map, profile, settings }

class Nav extends StatelessWidget {
  const Nav({super.key, required this.selected, required this.onChanged});

  final NavItem selected;
  final void Function(int) onChanged;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Theme.of(
                    context,
                  ).scaffoldBackgroundColor.withValues(alpha: 1),
                  Theme.of(
                    context,
                  ).scaffoldBackgroundColor.withValues(alpha: 1),
                  Theme.of(
                    context,
                  ).scaffoldBackgroundColor.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: SafeArea(
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.2),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: NavigationBar(
                    labelBehavior: .onlyShowSelected,
                    backgroundColor: Theme.of(
                      context,
                    ).scaffoldBackgroundColor.withValues(alpha: 0.8),
                    selectedIndex: selected.index,
                    onDestinationSelected: onChanged,
                    destinations: [
                      NavigationDestination(
                        icon: const HugeIcon(
                          icon: HugeIcons.strokeRoundedHome01,
                        ),
                        label: loc.home,
                      ),
                      NavigationDestination(
                        icon: const HugeIcon(icon: HugeIcons.strokeRoundedMaps),
                        label: loc.map,
                      ),
                      NavigationDestination(
                        icon: const HugeIcon(
                          icon: HugeIcons.strokeRoundedUser03,
                        ),
                        label: loc.profile,
                      ),
                      NavigationDestination(
                        icon: const HugeIcon(
                          icon: HugeIcons.strokeRoundedSettings05,
                        ),
                        label: loc.settings,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
