import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../core/providers/auth.dart';
import '../../data/models/user.dart';
import '../../l10n/app_localizations.dart';
import '../providers/post.dart';
import '../providers/profile.dart';
import '../widgets/nav.dart';
import 'create_post.dart';
import 'tabs/home.dart';
import 'tabs/map.dart';
import 'tabs/profile.dart';
import 'tabs/settings.dart';

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
      ref.read(getProfile.future);
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
      body: body,
      floatingActionButton:
          _current == NavItem.profile && currentUser?.role == UserRole.host
          ? FloatingActionButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreatePostScreen()),
              ),
              tooltip: loc.publishApartment,
              child: const HugeIcon(icon: HugeIcons.strokeRoundedAdd01),
            )
          : null,
      bottomNavigationBar: Nav(
        selected: _current,
        onChanged: (i) => setState(() {
          _current = NavItem.values[i];
        }),
      ),
      extendBody: _current != .map,
    );
  }
}
