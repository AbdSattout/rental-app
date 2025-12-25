import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homio/config/constants.dart';
import 'package:homio/presentation/widgets/error_retry.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:latlong2/latlong.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../core/utils/asset.dart';
import '../../l10n/app_localizations.dart';
import '../providers/post.dart';
import '../providers/profile.dart';
import '../utils.dart';
import '../widgets/section_title.dart';
import 'create_post.dart';
import 'poster_profile.dart';

class PostDetailsScreenFlags {
  final bool showHost;
  final bool showButtons;
  final bool canOpenHostProfile;
  final bool canEdit;

  const PostDetailsScreenFlags({
    this.showHost = true,
    this.showButtons = true,
    this.canOpenHostProfile = true,
    this.canEdit = false,
  });
}

class PostDetailsScreen extends ConsumerStatefulWidget {
  final int postId;
  final PostDetailsScreenFlags? flags;

  const PostDetailsScreen({super.key, required this.postId, this.flags});

  @override
  ConsumerState<PostDetailsScreen> createState() => _PostDetailsScreenState();
}

class MouseScroll extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
  };
}

class _PostDetailsScreenState extends ConsumerState<PostDetailsScreen> {
  final MapController _mapController = MapController();
  final PageController _pageController = PageController();
  int _count = 0;

  @override
  void initState() {
    super.initState();
    Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_pageController.page == _count - 1) {
        _pageController.animateToPage(
          0,
          duration: const Duration(seconds: 1),
          curve: Curves.easeOutExpo,
        );
      } else {
        _pageController.nextPage(
          duration: const Duration(seconds: 1),
          curve: Curves.easeOutExpo,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final postAsync = ref.watch(getPostDetails(widget.postId));
    final post = postAsync.asData?.value;
    final flags = widget.flags ?? const PostDetailsScreenFlags();
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    final profileAsync = flags.showHost
        ? ref.watch(getProfileByPost(widget.postId))
        : null;
    final profile = profileAsync?.asData?.value;

    _count = post?.photos.length ?? 0;

    return Scaffold(
      appBar: AppBar(title: Text(loc.postDetails), animateColor: true),
      body: SafeArea(
        child: Builder(
          builder: (context) {
            if (postAsync.hasError && !postAsync.isLoading) {
              final error = postAsync.error;
              String message;
              if (error is DioException && error.response == null) {
                message = loc.noInternetConnection;
              } else {
                message = error.toString();
              }
              return ErrorRetry(
                message: message,
                onRetry: () {
                  ref.invalidate(getPostDetails(widget.postId));
                  ref.invalidate(getProfileByPost(widget.postId));
                },
              );
            }

            if (postAsync.isLoading || post == null) {
              return const Center(child: CircularProgressIndicator());
            }

            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(getPostDetails(post.id));
                ref.invalidate(getProfileByPost(post.id));
              },
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                padding: .directional(start: 12, end: 12, top: 0, bottom: 12),
                child: Column(
                  spacing: 16,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: .circular(16),
                          border: Border.all(
                            color: ColorScheme.of(context).outline,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: PageView(
                            scrollBehavior: MouseScroll(),
                            scrollDirection: .horizontal,
                            controller: _pageController,

                            children: post.photos.map((photo) {
                              return CachedNetworkImage(
                                imageUrl: AssetUtil.getAssetUrl(photo.filePath),
                                fit: BoxFit.cover,
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),

                    if (post.photos.length > 1)
                      Center(
                        child: SmoothPageIndicator(
                          controller: _pageController,
                          count: post.photos.length,
                          onDotClicked: (index) {
                            _pageController.animateToPage(
                              index,
                              duration: .new(seconds: 1),
                              curve: Curves.easeOutExpo,
                            );
                          },
                        ),
                      ),

                    if (flags.showHost)
                      Column(
                        children: [
                          SectionTitle(
                            title: loc.postHost,
                            icon: HugeIcons.strokeRoundedUser03,
                          ),
                          Skeletonizer(
                            enabled:
                                flags.showHost &&
                                (profileAsync?.isLoading ?? true),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap:
                                  flags.canOpenHostProfile &&
                                      !(profileAsync != null &&
                                          profileAsync.hasError &&
                                          !profileAsync.isLoading)
                                  ? () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (c) => PosterProfileScreen(
                                          postId: post.id,
                                        ),
                                      ),
                                    )
                                  : null,
                              child:
                                  profileAsync != null &&
                                      profileAsync.hasError &&
                                      !profileAsync.isLoading
                                  ? Builder(
                                      builder: (context) {
                                        final error = profileAsync.error;
                                        String message;
                                        if (error is DioException &&
                                            error.response == null) {
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
                                      },
                                    )
                                  : Padding(
                                      padding: .all(16),
                                      child: Row(
                                        spacing: 16,
                                        children: [
                                          CircleAvatar(
                                            foregroundImage: profile != null
                                                ? CachedNetworkImageProvider(
                                                    AssetUtil.getThumbnail(
                                                      profile.profileImage,
                                                    ),
                                                  )
                                                : null,
                                            // FIXME: pngs?!
                                            child: HugeIcon(
                                              icon:
                                                  HugeIcons.strokeRoundedUser03,
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              profile != null
                                                  ? '${profile.firstName} ${profile.lastName}'
                                                  : loc.loading,
                                              style: TextTheme.of(
                                                context,
                                              ).bodyLarge,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          if (flags.canOpenHostProfile)
                                            HugeIcon(
                                              icon: isRTL
                                                  ? HugeIcons
                                                        .strokeRoundedArrowLeft02
                                                  : HugeIcons
                                                        .strokeRoundedArrowRight02,
                                            ),
                                        ],
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),

                    Column(
                      children: [
                        SectionTitle(
                          title: loc.details,
                          icon: HugeIcons.strokeRoundedInformationCircle,
                        ),
                        Row(
                          children: [
                            PostDetailsTile(
                              icon:
                                  HugeIcons.strokeRoundedSquareArrowDiagonal01,
                              subtitle: loc.space,
                              title: '${post.space}',
                            ),
                            PostDetailsTile(
                              icon: HugeIcons.strokeRoundedDoor01,
                              subtitle: loc.rooms,
                              title: '${post.rooms}',
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            PostDetailsTile(
                              icon: HugeIcons.strokeRoundedBathtub01,
                              subtitle: loc.bath,
                              title: '${post.bathrooms}',
                            ),
                            PostDetailsTile(
                              icon: HugeIcons.strokeRoundedDollarSquare,
                              subtitle: loc.price,
                              title: priceLabel(post.price),
                            ),
                          ],
                        ),
                      ],
                    ),

                    Column(
                      children: [
                        SectionTitle(
                          title: loc.location,
                          icon: HugeIcons.strokeRoundedLocation01,
                        ),
                        AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: .circular(16),
                              border: Border.all(
                                color: ColorScheme.of(context).outline,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: .circular(16),
                              child: FlutterMap(
                                mapController: _mapController,
                                options: MapOptions(
                                  onMapReady: () {
                                    _mapController.move(
                                      LatLng(post.latitude, post.longitude),
                                      15,
                                    );
                                  },
                                  initialCenter: LatLng(
                                    post.latitude,
                                    post.longitude,
                                  ),
                                  initialZoom: 15,
                                ),
                                children: [
                                  TileLayer(
                                    urlTemplate: osmUrlTemplate,
                                    userAgentPackageName: appId,
                                  ),
                                  MarkerLayer(
                                    markers: [
                                      Marker(
                                        alignment: .topCenter,
                                        point: LatLng(
                                          post.latitude,
                                          post.longitude,
                                        ),
                                        child: Icon(
                                          Icons.location_pin,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onPrimaryFixedVariant,
                                          size: 40,
                                        ),
                                      ),
                                    ],
                                  ),
                                  RichAttributionWidget(
                                    showFlutterMapAttribution: false,
                                    alignment: isRTL
                                        ? .bottomLeft
                                        : .bottomRight,
                                    attributions: [
                                      TextSourceAttribution(
                                        loc.openStreetMapContributors,
                                      ),
                                    ],
                                  ),
                                  Positioned.directional(
                                    textDirection: isRTL ? .rtl : .ltr,
                                    start: 0,
                                    child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: IconButton(
                                        icon: HugeIcon(
                                          icon: HugeIcons
                                              .strokeRoundedCenterFocus,
                                        ),
                                        onPressed: () {
                                          _mapController.move(
                                            LatLng(
                                              post.latitude,
                                              post.longitude,
                                            ),
                                            15,
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    if (flags.showButtons)
                      SizedBox(
                        height: 48,
                        child: Row(
                          spacing: 4,
                          crossAxisAlignment: .stretch,
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {},
                                child: Text(loc.contact),
                              ),
                            ),
                            Expanded(
                              child: FilledButton(
                                onPressed: () {},
                                child: Text(loc.rent),
                              ),
                            ),
                          ],
                        ),
                      ),

                    if (flags.canEdit)
                      SizedBox(
                        height: 48,
                        child: Row(
                          spacing: 4,
                          crossAxisAlignment: .stretch,
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        CreatePostScreen(post: post),
                                  ),
                                ),
                                child: Text(loc.edit),
                              ),
                            ),
                            Expanded(
                              child: FilledButton(
                                style: FilledButton.styleFrom(
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.error,
                                ),
                                onPressed: () => showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text(loc.deletePost),
                                    content: Text(loc.areYouSureDeletePost),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text(loc.cancel),
                                      ),
                                      FilledButton(
                                        onPressed: () async {
                                          await showBlockingLoadingUntil(
                                            context,
                                            action: () async {
                                              return await deletePost(
                                                ref,
                                                post.id,
                                              );
                                            },
                                            onCompleted: (result) {
                                              Navigator.pop(context);
                                              // success
                                              if (result == null) {
                                                ref.invalidate(getOwnPosts);
                                                Navigator.pop(context);
                                                return;
                                              }
                                              final message =
                                                  switch (result.type) {
                                                    .networkError =>
                                                      loc.networkError,
                                                    .badRequest =>
                                                      (loc.checkYourRequest),
                                                    _ => result.message,
                                                  };
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(message),
                                                ),
                                              );
                                            },
                                          );
                                        },
                                        child: Text(loc.delete),
                                      ),
                                    ],
                                  ),
                                ),
                                child: Text(loc.delete),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class PostDetailsTile extends StatelessWidget {
  const PostDetailsTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final List<List<dynamic>> icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListTile(
        leading: CircleAvatar(child: HugeIcon(icon: icon)),
        subtitle: Text(subtitle),
        title: Text(title),
      ),
    );
  }
}
