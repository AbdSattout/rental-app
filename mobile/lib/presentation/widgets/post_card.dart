import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../core/utils/asset.dart';
import '../../data/models/post.dart';
import '../../l10n/app_localizations.dart';
import '../utils.dart';

class PostCardSkeleton extends StatelessWidget {
  const PostCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      effect: PulseEffect(
        from: ColorScheme.of(context).secondary.withValues(alpha: 0.1),
        to: ColorScheme.of(context).secondary.withValues(alpha: 0.2),
      ),
      child: AspectRatio(
        aspectRatio: 248 / 284,
        child: Bone(borderRadius: BorderRadius.circular(40)),
      ),
    );
  }
}

class PostCardFlags {
  final bool showFavourite;

  const PostCardFlags({this.showFavourite = true});
}

class PostCard extends StatelessWidget {
  final Post post;
  final VoidCallback? onTap;
  final PostCardFlags flags;

  const PostCard({
    super.key,
    required this.post,
    this.onTap,
    this.flags = const PostCardFlags(),
  });

  String get imageUrl => AssetUtil.getThumbnail(post.featured.first.filePath);

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final secondryColor = Theme.of(context).colorScheme.secondary;
    final loc = AppLocalizations.of(context)!;

    return Card(
      shape: RoundedSuperellipseBorder(borderRadius: .circular(40)),
      margin: .all(0),
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: .circular(40),
        child: Padding(
          padding: const .all(12),
          child: Column(
            spacing: 12,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: .circular(28),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: .cover,
                      ),
                    ),
                  ),
                  if (flags.showFavourite)
                    Positioned.directional(
                      top: 5,
                      end: 5,
                      textDirection: Directionality.of(context),
                      child: IconButton(
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: .8),
                        ),
                        icon: Icon(
                          post.isFavorited
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: post.isFavorited
                              ? primaryColor
                              : secondryColor,
                        ),
                        onPressed: () {},
                      ),
                    ),
                ],
              ),
              Padding(
                padding: const .symmetric(horizontal: 12),
                child: Row(
                  mainAxisAlignment: .spaceBetween,
                  children: [
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: priceLabel(post.price),
                            style: TextTheme.of(context).titleMedium,
                          ),
                          TextSpan(
                            text: " / ${loc.perDay}",
                            style: TextTheme.of(
                              context,
                            ).bodySmall?.copyWith(color: secondryColor),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      spacing: 4,
                      children: [
                        Text(
                          post.averageRating
                              .toStringAsFixed(1)
                              .replaceFirst(".0", ""),
                          style: TextTheme.of(
                            context,
                          ).bodyLarge?.copyWith(color: secondryColor),
                        ),
                        Icon(Icons.star, color: Colors.amber),
                      ],
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
