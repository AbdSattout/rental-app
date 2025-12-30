import 'package:flutter/material.dart';

import '../../data/models/post.dart';
import '../screens/post_details.dart';
import 'post_card.dart';

class PostsGridSkeleton extends StatelessWidget {
  const PostsGridSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: .all(0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: 8,
      itemBuilder: (_, _) {
        return const PostCardSkeleton();
      },
    );
  }
}

class PostsGrid extends StatelessWidget {
  const PostsGrid({
    super.key,
    required this.posts,
    this.hasMore = false,
    this.detailsFlags,
    this.cardFlags,
    this.controller,
  });

  final List<Post> posts;
  final bool hasMore;
  final ScrollController? controller;
  final PostDetailsScreenFlags? detailsFlags;
  final PostCardFlags? cardFlags;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: .all(0),
      physics: const AlwaysScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      controller: controller,
      itemCount: posts.length + (hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == posts.length && hasMore) {
          return const PostCardSkeleton();
        }

        final post = posts[index];
        return PostCard(
          post: post,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (c) =>
                  PostDetailsScreen(postId: post.id, flags: detailsFlags),
            ),
          ),
        );
      },
    );
  }
}
