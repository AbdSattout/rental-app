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
      child: Bone.square(borderRadius: BorderRadius.circular(18)),
    );
  }
}

class PostCardFlags {
  final bool showType;

  const PostCardFlags({this.showType = true});
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
    final loc = AppLocalizations.of(context)!;
    final isRTL = Directionality.of(context) == .rtl;

    final type = switch (post.type) {
      PostType.apartment => loc.typeApartment.toUpperCase(),
      PostType.villa => loc.typeVilla.toUpperCase(),
      PostType.house => loc.typeHouse.toUpperCase(),
      PostType.office => loc.typeOffice.toUpperCase(),
    };

    return Card(
      margin: .all(0),
      shape: RoundedRectangleBorder(borderRadius: .circular(18)),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          children: [
            Positioned.fill(
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                errorWidget: (context, error, stackTrace) =>
                    const Center(child: Icon(Icons.broken_image)),
              ),
            ),

            Positioned(
              bottom: 4,
              right: isRTL ? null : 4,
              left: isRTL ? 4 : null,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: .blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                    padding: const .symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: .1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: .5),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      priceLabel(post.price),
                      style: TextTheme.of(context).labelMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            blurRadius: 8,
                            color: Colors.black54,
                            offset: .zero,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            if (flags.showType)
              Positioned(
                top: 4,
                left: isRTL ? null : 4,
                right: isRTL ? 4 : null,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: .blur(sigmaX: 5, sigmaY: 5),
                    child: Container(
                      padding: const .symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: .1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: .5),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        type,
                        style: TextTheme.of(context).labelSmall!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              blurRadius: 8,
                              color: Colors.black54,
                              offset: .zero,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
