import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '/core/utils/asset.dart';
import '../../l10n/app_localizations.dart';
import '../providers/post.dart';
import '../providers/profile.dart';
import '../screens/post_details.dart';
import '../widgets/error_retry.dart';
import '../widgets/posts_grid.dart';
import '../widgets/section_title.dart';
import '../widgets/warning.dart';

class PosterProfileScreen extends ConsumerStatefulWidget {
  final int postId;

  const PosterProfileScreen({super.key, required this.postId});

  @override
  ConsumerState<PosterProfileScreen> createState() =>
      _PosterProfileScreenState();
}

class _PosterProfileScreenState extends ConsumerState<PosterProfileScreen> {
  final ScrollController _scrollController = ScrollController();
  int? _userId;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        if (_userId != null) {
          ref.read(userPostsProvider(_userId!).notifier).loadMore();
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    ref.invalidate(getProfileByPost);
    ref.invalidate(getUserPosts);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final profileAsync = ref.watch(getProfileByPost(widget.postId));

    final profile = profileAsync.asData?.value;
    final posts = profile != null
        ? ref.watch(userPostsProvider(profile.id))
        : null;

    if (profile != null) {
      _userId = profile.id;
    }

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
                enabled:
                    (profileAsync.isLoading || profile == null) &&
                    !profileAsync.hasError,
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
                                  '${posts?.asData?.value.$2.length ?? 0} ${loc.appartments}',
                                  overflow: .ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    } else if (profileAsync.isLoading) {
                      return const Expanded(
                        child: Center(child: CircularProgressIndicator()),
                      );
                    } else if (profileAsync.hasError) {
                      final error = profileAsync.error;
                      String message;
                      if (error is DioException && error.response == null) {
                        message = loc.noInternetConnection;
                      } else {
                        message = error.toString();
                      }

                      return Expanded(
                        child: ErrorRetry(
                          message: message,
                          onRetry: () async {
                            ref.invalidate(getProfileByPost);
                          },
                        ),
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                ),
              ),

              if (!profileAsync.hasError)
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
                            if (posts == null ||
                                posts.isLoading && !posts.hasError) {
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
                                  ref.invalidate(getUserPosts);
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
