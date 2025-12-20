import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '/core/utils/asset.dart';
import '../../../data/models/user.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/post.dart';
import '../../providers/profile.dart';
import '../../widgets/error_retry.dart';
import '../../widgets/posts_grid.dart';
import '../../widgets/section_title.dart';
import '../../widgets/warning.dart';

class ProfileTab extends ConsumerStatefulWidget {
  final User? user;
  const ProfileTab({super.key, required this.user});

  @override
  ConsumerState<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends ConsumerState<ProfileTab> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (widget.user != null) {
        if (widget.user!.role == .host) {
          ref.read(postProvider.notifier).getOwnPosts();
        }
      }
    });

    _scrollController.addListener(() {
      final postState = ref.read(postProvider);
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        final hasMore = postState.userPagination?.hasMore ?? true;
        if (hasMore) {
          ref.read(postProvider.notifier).getOwnPosts();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final profileState = ref.watch(profileProvider);
    final postState = ref.watch(postProvider);

    final posts = postState.ownPosts;
    final pagination = postState.userPagination;

    final role = switch (widget.user?.role) {
      .admin => loc.admin,
      .host => loc.host,
      .tenant => loc.tenant,
      .guest || null => loc.guest,
    };

    final isGuest = widget.user == null || widget.user!.role == .guest;

    return Scaffold(
      appBar: !isGuest
          ? AppBar(title: Text(loc.profile), animateColor: true)
          : null,
      body: isGuest
          ? Center(child: Text(loc.guestMode))
          : RefreshIndicator(
              onRefresh: () async {
                await ref
                    .read(postProvider.notifier)
                    .getOwnPosts(refresh: true);
              },
              child: Padding(
                padding: const .all(12),
                child: Column(
                  spacing: 16,
                  children: [
                    Skeletonizer(
                      enabled:
                          profileState.isLoading ||
                          profileState.profile == null,
                      child: Column(
                        spacing: 16,
                        children: [
                          CircleAvatar(
                            radius: 48,
                            foregroundImage: CachedNetworkImageProvider(
                              AssetUtil.getThumbnail(
                                profileState.profile!.profileImage,
                              ),
                            ),
                            // FIXME: pngs?!
                            child: HugeIcon(
                              icon: HugeIcons.strokeRoundedUser03,
                            ),
                          ),
                          Column(
                            spacing: 4,
                            children: [
                              Text(
                                '${profileState.profile!.firstName} ${profileState.profile!.lastName}',
                                style: TextTheme.of(context).titleLarge,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                widget.user!.phoneNumber,
                                style: TextTheme.of(context).bodyMedium,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Badge(
                                label: Row(
                                  spacing: 4,
                                  children: [
                                    HugeIcon(
                                      icon: HugeIcons.strokeRoundedUserAi,
                                      size: 12,
                                      color: Colors.white,
                                    ),
                                    Text("${loc.role}: $role"),
                                  ],
                                ),
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.primary,
                                padding: .symmetric(vertical: 2, horizontal: 8),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    if (widget.user!.role == .host)
                      Expanded(
                        child: Column(
                          children: [
                            SectionTitle(
                              title: loc.myApartments,
                              icon: HugeIcons.strokeRoundedHouse01,
                            ),
                            Expanded(
                              child: Builder(
                                builder: (_) {
                                  if (postState.isLoading && posts == null) {
                                    return const PostsGridSkeleton();
                                  } else if (postState.error != null &&
                                      (posts?.isEmpty ?? true)) {
                                    return ErrorRetry(
                                      message: postState.error!,
                                      onRetry: () async {
                                        await ref
                                            .read(postProvider.notifier)
                                            .getOwnPosts(refresh: true);
                                      },
                                    );
                                  } else if (posts != null && posts.isEmpty) {
                                    return ListView(
                                      children: [
                                        Warning(
                                          variant: .info,
                                          message: loc.nothingHere,
                                        ),
                                      ],
                                    );
                                  } else {
                                    return PostsGrid(
                                      controller: _scrollController,
                                      hasMore: pagination?.hasMore ?? false,
                                      posts: posts ?? [],
                                      detailsFlags: .new(
                                        showHost: false,
                                        showButtons: false,
                                        canEdit: true,
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (widget.user!.role != .host)
                      Warning(variant: .info, message: loc.notAHost),
                  ],
                ),
              ),
            ),
    );
  }
}
