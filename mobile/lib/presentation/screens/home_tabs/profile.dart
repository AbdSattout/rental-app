import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homio/core/providers/auth.dart';
import 'package:homio/core/utils/asset.dart';
import 'package:homio/l10n/app_localizations.dart';
import 'package:homio/presentation/providers/profile.dart';
import 'package:homio/presentation/screens/profile_tabs/favorites.dart';
import 'package:homio/presentation/screens/profile_tabs/posts.dart';
import 'package:homio/presentation/screens/profile_tabs/reservations.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ProfileTab extends ConsumerStatefulWidget {
  const ProfileTab({super.key});

  @override
  ConsumerState<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends ConsumerState<ProfileTab>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 3);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    final authState = ref.watch(authProvider);
    final profileAsync = !authState.isGuest ? ref.watch(getProfile) : null;

    final role = switch (authState.user?.role) {
      .admin => loc.admin,
      .host => loc.host,
      .tenant => loc.tenant,
      .guest || null => loc.guest,
    };

    return Scaffold(
      body: authState.isGuest
          ? Center(child: Text(loc.guestMode))
          : NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverOverlapAbsorber(
                    handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                      context,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: Padding(
                        padding: const .all(12),
                        child: Column(
                          spacing: 16,
                          children: [
                            Skeletonizer(
                              enabled:
                                  profileAsync!.isLoading ||
                                  profileAsync.asData == null,
                              child: Builder(
                                builder: (context) {
                                  final profile = profileAsync.asData?.value;
                                  if (profile == null) {
                                    return const SizedBox.shrink();
                                  }
                                  return Column(
                                    spacing: 16,
                                    children: [
                                      CircleAvatar(
                                        radius: 48,
                                        foregroundImage:
                                            CachedNetworkImageProvider(
                                              AssetUtil.getThumbnail(
                                                profile.profileImage,
                                              ),
                                            ),
                                        child: HugeIcon(
                                          icon: HugeIcons.strokeRoundedUser03,
                                        ),
                                      ),
                                      Column(
                                        spacing: 4,
                                        children: [
                                          Text(
                                            '${profile.firstName} ${profile.lastName}',
                                            style: TextTheme.of(
                                              context,
                                            ).titleLarge,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            authState.user!.phoneNumber,
                                            style: TextTheme.of(
                                              context,
                                            ).bodyMedium,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 2),
                                          Badge(
                                            label: Row(
                                              spacing: 4,
                                              children: [
                                                HugeIcon(
                                                  icon: HugeIcons
                                                      .strokeRoundedUserAi,
                                                  size: 12,
                                                  color: Colors.white,
                                                ),
                                                Text("${loc.role}: $role"),
                                              ],
                                            ),
                                            backgroundColor: Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                            padding: .symmetric(
                                              vertical: 2,
                                              horizontal: 8,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _SliverTabBarDelegate(
                      TabBar(
                        dividerColor: Colors.transparent,
                        controller: _tabController,
                        tabs: [
                          Tab(
                            icon: const HugeIcon(
                              icon: HugeIcons.strokeRoundedHouse01,
                            ),
                            text: loc.myApartments,
                          ),
                          Tab(
                            icon: const HugeIcon(
                              icon: HugeIcons.strokeRoundedFavourite,
                            ),
                            text: loc.myFavorites,
                          ),
                          Tab(
                            icon: const HugeIcon(
                              icon: HugeIcons.strokeRoundedCalendar02,
                            ),
                            text: loc.myReservations,
                          ),
                        ],
                      ),
                    ),
                  ),
                ];
              },
              body: Padding(
                padding: const .only(top: 12, left: 12, right: 12),
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    PostsTab(user: authState.user),
                    FavoritesTab(user: authState.user),
                    ReservationsTab(user: authState.user),
                  ],
                ),
              ),
            ),
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return tabBar != oldDelegate.tabBar;
  }
}
