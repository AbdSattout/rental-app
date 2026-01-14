import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homio/presentation/screens/post_details.dart';
import 'package:homio/presentation/screens/search.dart';
import 'package:homio/presentation/widgets/empty.dart';
import 'package:homio/presentation/widgets/location_search.dart';
import 'package:homio/presentation/widgets/section_title.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../core/providers/auth.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/post.dart';
import '../../providers/profile.dart';
import '../../widgets/error_retry.dart';
import '../../widgets/post_card.dart';
import '../../widgets/warning.dart';

class HomeSectionSkeletonizer extends StatelessWidget {
  const HomeSectionSkeletonizer({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Skeletonizer(
      enabled: true,
      effect: PulseEffect(
        from: ColorScheme.of(context).secondary.withValues(alpha: 0.1),
        to: ColorScheme.of(context).secondary.withValues(alpha: 0.2),
      ),
      child: ListView(
        padding: EdgeInsets.symmetric(horizontal: 20),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(8),
                child: Row(
                  spacing: 10,
                  children: [
                    Bone.circle(size: 18),
                    Text(loc.loading, style: TextTheme.of(context).labelLarge),
                  ],
                ),
              ),
              SingleChildScrollView(
                clipBehavior: Clip.none,
                scrollDirection: Axis.horizontal,
                child: Row(
                  spacing: 10,
                  children: List.generate(
                    3,
                    (_) => SizedBox(width: 256, child: PostCardSkeleton()),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class HomeTab extends ConsumerWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final currentProfileAsync = authState.isGuest
        ? null
        : ref.watch(getProfile);
    final loc = AppLocalizations.of(context)!;
    final posts = ref.watch(homepageFeedProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(getHomepageFeed),
      child: Column(
        spacing: 20,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: () {
              if (authState.isAuthenticated &&
                  authState.isApproved &&
                  currentProfileAsync != null) {
                return Skeletonizer(
                  enabled:
                      currentProfileAsync.isLoading ||
                      currentProfileAsync.asData?.value == null,
                  child: Padding(
                    padding: EdgeInsets.only(top: 36),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc.hello(
                            currentProfileAsync.asData?.value.firstName
                                    .trim() ??
                                loc.guest,
                          ),
                          style: Theme.of(context).textTheme.displayMedium!
                              .copyWith(color: ColorScheme.of(context).primary),
                        ),
                        Text(
                          '${loc.welcome} 👋',
                          style: Theme.of(context).textTheme.titleMedium!
                              .copyWith(
                                color: ColorScheme.of(context).secondary,
                              ),
                        ),
                      ],
                    ),
                  ),
                );
              } else if (!authState.isApproved) {
                return Warning(message: loc.approvalPending);
              } else if (!authState.isAuthenticated) {
                return Warning(message: loc.guestMode);
              }
            }(),
          ),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Hero(
              tag: 'search_bar',
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: .circular(10),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SearchScreen(),
                      ),
                    );
                  },
                  child: LocationSearchField(
                    controller: .new(),
                    disabled: true,
                  ),
                ),
              ),
            ),
          ),

          Expanded(
            child: Builder(
              builder: (_) {
                if (posts.isLoading && !posts.hasError) {
                  return const HomeSectionSkeletonizer();
                }

                if (posts.hasError) {
                  final error = posts.error;
                  String message;
                  if (error is DioException && error.response == null) {
                    message = loc.noInternetConnection;
                  } else {
                    message = error.toString();
                  }

                  return ErrorRetry(
                    message: message,
                    onRetry: () async {
                      ref.invalidate(getHomepageFeed);
                    },
                  );
                }

                if (posts.requireValue.$2.isEmpty) {
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        physics: AlwaysScrollableScrollPhysics(),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: Empty(
                            message: loc.nothingHere,
                            icon: HugeIcons.strokeRoundedCrying,
                          ),
                        ),
                      );
                    },
                  );
                }

                return ListView(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SectionTitle(
                              title: loc.latestPosts,
                              icon: HugeIcons.strokeRoundedHouse01,
                            ),
                            if (posts.requireValue.$1.hasMore)
                              GestureDetector(
                                child: Text(
                                  loc.showAll,
                                  style: TextTheme.of(context).labelSmall
                                      ?.copyWith(
                                        color: ColorScheme.of(
                                          context,
                                        ).secondary,
                                      ),
                                ),
                              ),
                          ],
                        ),
                        SingleChildScrollView(
                          clipBehavior: Clip.none,
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            spacing: 10,
                            children: [
                              for (final post in posts.requireValue.$2)
                                SizedBox(
                                  width: 256,
                                  child: PostCard(
                                    post: post,
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (c) => PostDetailsScreen(
                                          postId: post.id,
                                          flags: const PostDetailsScreenFlags(
                                            showButtons: true,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
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
    );
  }
}
