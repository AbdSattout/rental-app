import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '/core/utils/asset.dart';
import '../../data/models/profile.dart';
import '../../l10n/app_localizations.dart';
import '../providers/post.dart';
import '../providers/profile.dart';
import '../screens/post_details.dart';
import '../widgets/error_retry.dart';
import '../widgets/posts_grid.dart';
import '../widgets/section_title.dart';
import '../widgets/warning.dart';

class PosterProfileScreen extends ConsumerStatefulWidget {
  final int profileId;
  final Profile? initialProfile;

  const PosterProfileScreen({
    super.key,
    required this.profileId,
    this.initialProfile,
  });

  @override
  ConsumerState<PosterProfileScreen> createState() =>
      _PosterProfileScreenState();
}

class _PosterProfileScreenState extends ConsumerState<PosterProfileScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (widget.initialProfile == null) {
        ref.read(profileProvider.notifier).getProfileByPost(widget.profileId);
      }
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        ref.read(userPostsProvider(widget.profileId).notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    if (widget.initialProfile == null) {
      await ref
          .read(profileProvider.notifier)
          .getProfileByPost(widget.profileId);
    }
    ref.invalidate(getUserPosts);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final profileState = ref.watch(profileProvider);

    final profile = widget.initialProfile ?? profileState.profile;
    final posts = ref.watch(userPostsProvider(widget.profileId));

    return Scaffold(
      appBar: AppBar(title: Text(loc.hostProfile), animateColor: true),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: Padding(
          padding: const .all(12),
          child: Column(
            spacing: 16,
            children: [
              Skeletonizer(
                enabled: profileState.isLoading || profile == null,
                child: Builder(
                  builder: (_) {
                    if (profile != null) {
                      return Container(
                        padding: const .all(8),
                        child: Row(
                          spacing: 8,
                          children: [
                            ClipRRect(
                              borderRadius: .circular(40),
                              child: SizedBox(
                                width: 80,
                                height: 80,
                                child: CachedNetworkImage(
                                  imageUrl: AssetUtil.getProfile(
                                    profile.profileImage,
                                  ),
                                  fit: BoxFit.cover,
                                  errorWidget: (context, url, error) =>
                                      Container(
                                        color: colorScheme.surfaceContainer,
                                        child: HugeIcon(
                                          icon: HugeIcons.strokeRoundedUser03,
                                          size: 40,
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: ListTile(
                                title: Text(
                                  '${profile.firstName.trim()} ${profile.lastName.trim()}',
                                  style: TextTheme.of(context).bodyLarge,
                                  overflow: .ellipsis,
                                ),
                                subtitle: Text(
                                  '${posts.asData?.value.$2.length ?? 0} ${loc.appartments}',
                                  overflow: .ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    } else if (profileState.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (profileState.error != null) {
                      return ErrorRetry(
                        message: profileState.error!,
                        onRetry: () async {
                          await ref
                              .read(profileProvider.notifier)
                              .getProfileByPost(widget.profileId);
                        },
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                ),
              ),

              Expanded(
                child: Column(
                  children: [
                    SectionTitle(
                      title: loc.appartments,
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
                                canOpenHostProfile: false,
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
