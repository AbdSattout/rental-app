import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homio/config/constants.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../core/providers/auth.dart';
import '../../l10n/app_localizations.dart';
import '../providers/post.dart';
import '../providers/profile.dart';
import '../widgets/nav.dart';
import 'create_post.dart';
import 'home_tabs/home.dart';
import 'home_tabs/map.dart';
import 'home_tabs/profile.dart';
import 'home_tabs/settings.dart';
import 'host_reservations.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  NavItem _current = .home;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      // preload home and profile
      ref.read(getHomepageFeed(1).future);
      if (!ref.read(authProvider).isGuest) ref.read(getProfile.future);
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final currentUser = ref.watch(currentUserProvider);

    Widget body = switch (_current) {
      .home => const HomeTab(),
      .map => const MapTab(),
      .profile => ProfileTab(user: currentUser),
      .settings => const SettingsTab(),
    };

    return Scaffold(
      body: Padding(padding: const .symmetric(horizontal: 12), child: body),
      appBar: AppBar(animateColor: true, title: const Text(appName)),
      floatingActionButton: _current == .profile && currentUser?.role == .host
          ? Column(
              mainAxisSize: .min,
              crossAxisAlignment: .end,
              spacing: 12,
              children: [
                FloatingActionButton.small(
                  heroTag: 'create_post',
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CreatePostScreen()),
                  ),
                  tooltip: loc.publishApartment,
                  child: const HugeIcon(icon: HugeIcons.strokeRoundedAdd01),
                ),
                FloatingActionButton.extended(
                  heroTag: 'manage_reservations',
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HostReservationsScreen(),
                    ),
                  ),
                  tooltip: loc.manageReservations,
                  label: Text(loc.manageReservations),
                  icon: const HugeIcon(icon: HugeIcons.strokeRoundedCalendar03),
                ),
              ],
            )
          : null,
      floatingActionButtonLocation:
          _current == .profile && currentUser?.role == .host
          ? .miniEndFloat
          : null,
      bottomNavigationBar: Nav(
        selected: _current,
        onChanged: (i) => setState(() {
          _current = .values[i];
        }),
      ),
    );
  }
}
