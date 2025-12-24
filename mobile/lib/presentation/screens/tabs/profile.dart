import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
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
import '../post_details.dart';

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

    if (widget.user != null && widget.user!.role == .host) {
      _scrollController.addListener(() {
        if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200) {
          ref.read(ownPostsProvider.notifier).loadMore();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final profileAsync = ref.watch(getProfile);

    final role = switch (widget.user?.role) {
      .admin => loc.admin,
      .host => loc.host,
      .tenant => loc.tenant,
      .guest || null => loc.guest,
    };

    final isGuest = widget.user == null || widget.user!.role == .guest;

    final posts = !isGuest ? ref.watch(ownPostsProvider) : null;

    return Scaffold(
      appBar: !isGuest
          ? AppBar(title: Text(loc.profile), animateColor: true)
          : null,
      body: isGuest
          ? Center(child: Text(loc.guestMode))
          : RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(getOwnPosts);
              },
              child: Padding(
                padding: const .all(12),
                child: Column(
                  spacing: 16,
                  children: [
                    Skeletonizer(
                      enabled:
                          profileAsync.isLoading || profileAsync.asData == null,
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
                                foregroundImage: CachedNetworkImageProvider(
                                  AssetUtil.getThumbnail(profile.profileImage),
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
                                    '${profile.firstName} ${profile.lastName}',
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

                    if (posts != null)
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
                                  if (posts.isLoading && !posts.hasError) {
                                    return const PostsGridSkeleton();
                                  } else if (posts.hasError) {
                                    final error = posts.error;
                                    String message;
                                    if (error is DioException &&
                                        error.response == null) {
                                      message = loc.noInternetConnection;
                                    } else {
                                      message = error.toString();
                                    }

                                    return ErrorRetry(
                                      message: message,
                                      onRetry: () async {
                                        ref.invalidate(getOwnPosts);
                                      },
                                    );
                                  } else if (posts.requireValue.$2.isEmpty) {
                                    return ListView(
                                      children: [
                                        Warning(
                                          variant: WarningVariant.info,
                                          message: loc.nothingHere,
                                        ),
                                      ],
                                    );
                                  } else {
                                    return PostsGrid(
                                      controller: _scrollController,
                                      hasMore: posts.requireValue.$1.hasMore,
                                      posts: posts.requireValue.$2,
                                      detailsFlags: PostDetailsScreenFlags(
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
                    if (widget.user!.role != UserRole.host)
                      Warning(
                        variant: WarningVariant.info,
                        message: loc.notAHost,
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}
