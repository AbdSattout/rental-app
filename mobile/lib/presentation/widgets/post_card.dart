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
    return LayoutBuilder(
      builder: (context, constraints) {
        return Skeletonizer(
          enabled: true,
          effect: PulseEffect(
            from: ColorScheme.of(context).secondary.withValues(alpha: 0.1),
            to: ColorScheme.of(context).secondary.withValues(alpha: 0.2),
          ),
          child: AspectRatio(
            aspectRatio: constraints.maxWidth / (constraints.maxWidth + 36),
            child: Bone(borderRadius: BorderRadius.circular(20)),
          ),
        );
      },
    );
  }
}

class PostCardFlags {
  final bool showPerDay;

  const PostCardFlags({this.showPerDay = true});

  PostCardFlags copyWith({bool? showFavorite, bool? showPerDay}) {
    return PostCardFlags(showPerDay: showPerDay ?? this.showPerDay);
  }
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
    final secondryColor = Theme.of(context).colorScheme.secondary;
    final loc = AppLocalizations.of(context)!;

    return Card(
      shape: RoundedSuperellipseBorder(borderRadius: .circular(20)),
      margin: .all(0),
      color: ColorScheme.of(context).surfaceBright,
      child: InkWell(
        onTap: onTap,
        borderRadius: .circular(20),
        child: Padding(
          padding: const .all(12),
          child: Column(
            spacing: 12,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: .circular(8),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: .cover,
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const .symmetric(horizontal: 8),
                child: Row(
                  mainAxisAlignment: .spaceBetween,
                  spacing: 5,
                  children: [
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: priceLabel(post.price),
                              style: TextTheme.of(context).titleMedium,
                            ),
                            if (flags.showPerDay)
                              TextSpan(
                                text: " / ${loc.perDay}",
                                style: TextTheme.of(
                                  context,
                                ).bodySmall?.copyWith(color: secondryColor),
                              ),
                          ],
                        ),
                        overflow: .ellipsis,
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
