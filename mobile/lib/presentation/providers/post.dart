import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/post.dart';
import '../../data/repositories/post.dart';

class PaginationInfo {
  final int currentPage;
  final int lastPage;
  final bool hasMore;

  PaginationInfo({
    required this.currentPage,
    required this.lastPage,
    required this.hasMore,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      currentPage: json['current_page'] ?? 1,
      lastPage: json['last_page'] ?? 1,
      hasMore: json['next_page_url'] != null,
    );
  }
}

List<Post> parsePosts(List list) => list.map((e) => Post.fromJson(e)).toList();

Duration? _retry(int count, Object error) {
  if (error is DioException && error.response == null) return null;
  if (count > 10) return null;
  return Duration(milliseconds: 200 * count);
}

final getHomepageFeed =
    FutureProvider.family<(PaginationInfo, List<Post>), int>((
      ref,
      int page,
    ) async {
      final repo = ref.read(postRepositoryProvider);
      final response = await repo.getHomepageFeed(page: page);
      final postsJson = response.data["posts"];
      final pagination = PaginationInfo.fromJson(postsJson);
      final posts = parsePosts(postsJson["data"]);
      return (pagination, posts);
    }, retry: _retry);

class HomepageFeedNotifier extends AsyncNotifier<(PaginationInfo, List<Post>)> {
  bool _isLoading = false;
  @override
  build() async {
    return await ref.watch(getHomepageFeed(1).future);
  }

  Future<void> loadMore() async {
    if (state.value == null || _isLoading) return;
    final (pagination, posts) = state.value!;
    if (!pagination.hasMore) return;

    (PaginationInfo, List<Post>)? next;

    _isLoading = true;
    while (next == null) {
      try {
        next = await ref.read(
          getHomepageFeed(pagination.currentPage + 1).future,
        );
        if (next == null) continue;
        state = AsyncData((next.$1, [...posts, ...next.$2]));
      } catch (_) {
        await Future.delayed(Duration(seconds: 1));
        ref.invalidate(getHomepageFeed(pagination.currentPage + 1));
      }
    }
    _isLoading = false;
  }
}

final homepageFeedProvider = AsyncNotifierProvider.autoDispose(
  HomepageFeedNotifier.new,
  retry: (_, _) => null,
);

final getFilteredPosts = FutureProvider.family((
  ref,
  ({PostFilter filter, int? page}) params,
) async {
  final repo = ref.read(postRepositoryProvider);
  final response = await repo.filterPosts(
    filter: params.filter,
    page: params.page ?? 1,
  );
  final postsJson = response.data;
  final pagination = PaginationInfo.fromJson(postsJson);
  final posts = parsePosts(postsJson["data"]);
  return (pagination, posts);
}, retry: _retry);

class FilteredPostsNotifier
    extends AsyncNotifier<(PaginationInfo, List<Post>)> {
  bool _isLoading = false;
  final PostFilter _filter;

  FilteredPostsNotifier(this._filter);

  @override
  build() async {
    return await ref.watch(getFilteredPosts((filter: _filter, page: 1)).future);
  }

  Future<void> loadMore() async {
    if (state.value == null || _isLoading) return;
    final (pagination, posts) = state.value!;
    if (!pagination.hasMore) return;

    (PaginationInfo, List<Post>)? next;

    _isLoading = true;
    while (next == null) {
      try {
        next = await ref.read(
          getFilteredPosts((
            filter: _filter,
            page: pagination.currentPage + 1,
          )).future,
        );
        if (next == null) continue;
        state = AsyncData((next.$1, [...posts, ...next.$2]));
      } catch (_) {
        await Future.delayed(Duration(seconds: 1));
        ref.invalidate(
          getFilteredPosts((filter: _filter, page: pagination.currentPage + 1)),
        );
      }
    }
    _isLoading = false;
  }
}

final filteredPostsProvider = AsyncNotifierProvider.autoDispose.family(
  FilteredPostsNotifier.new,
  retry: (_, _) => null,
);

final getPostDetails = FutureProvider.family<Post, int>((
  ref,
  int postId,
) async {
  final repo = ref.read(postRepositoryProvider);
  final response = await repo.getPostDetails(postId);
  final payload = response.data;
  return Post.fromJson(payload);
}, retry: _retry);

final getUserPosts = FutureProvider.family((
  ref,
  ({int userId, int page}) params,
) async {
  final repo = ref.read(postRepositoryProvider);
  final response = await repo.getUserPosts(params.userId, page: params.page);
  final postsJson = response.data["posts"];
  final pagination = PaginationInfo.fromJson(postsJson);
  final posts = parsePosts(postsJson["data"]);
  return (pagination, posts);
}, retry: _retry);

class UserPostsNotifier extends AsyncNotifier<(PaginationInfo, List<Post>)> {
  bool _isLoading = false;
  final int _userId;

  UserPostsNotifier(this._userId);

  @override
  build() async {
    return await ref.watch(getUserPosts((userId: _userId, page: 1)).future);
  }

  Future<void> loadMore() async {
    if (state.value == null || _isLoading) return;
    final (pagination, posts) = state.value!;
    if (!pagination.hasMore) return;

    (PaginationInfo, List<Post>)? next;

    _isLoading = true;
    while (next == null) {
      try {
        next = await ref.read(
          getUserPosts((
            userId: _userId,
            page: pagination.currentPage + 1,
          )).future,
        );
        if (next == null) continue;
        state = AsyncData((next.$1, [...posts, ...next.$2]));
      } catch (_) {
        await Future.delayed(Duration(seconds: 1));
        ref.invalidate(
          getUserPosts((userId: _userId, page: pagination.currentPage + 1)),
        );
      }
    }
    _isLoading = false;
  }
}

final userPostsProvider = AsyncNotifierProvider.autoDispose.family(
  UserPostsNotifier.new,
  retry: (_, _) => null,
);

final getOwnPosts = FutureProvider.family<(PaginationInfo, List<Post>), int>((
  ref,
  int page,
) async {
  final repo = ref.read(postRepositoryProvider);
  final response = await repo.getOwnPosts(page: page);
  final postsJson = response.data["posts"];
  final pagination = PaginationInfo.fromJson(postsJson);
  final posts = parsePosts(postsJson["data"]);
  return (pagination, posts);
}, retry: _retry);

class OwnPostsNotifier extends AsyncNotifier<(PaginationInfo, List<Post>)> {
  bool _isLoading = false;

  @override
  build() async {
    return await ref.watch(getOwnPosts(1).future);
  }

  Future<void> loadMore() async {
    if (state.value == null || _isLoading) return;
    final (pagination, posts) = state.value!;
    if (!pagination.hasMore) return;

    (PaginationInfo, List<Post>)? next;

    _isLoading = true;
    while (next == null) {
      try {
        next = await ref.read(getOwnPosts(pagination.currentPage + 1).future);
        if (next == null) continue;
        state = AsyncData((next.$1, [...posts, ...next.$2]));
      } catch (_) {
        await Future.delayed(Duration(seconds: 1));
        ref.invalidate(getOwnPosts(pagination.currentPage + 1));
      }
    }
    _isLoading = false;
  }
}

final ownPostsProvider = AsyncNotifierProvider.autoDispose(
  OwnPostsNotifier.new,
  retry: (_, _) => null,
);

enum PostError { unknown, networkError, badRequest }

Future<({PostError type, String message})?> createPost(
  WidgetRef ref, {
  required PostType type,
  required double space,
  required int rooms,
  required int bathrooms,
  required double price,
  required double latitude,
  required double longitude,
  required List<MultipartFile> photos,
}) async {
  final repo = ref.read(postRepositoryProvider);
  try {
    await repo.createPost(
      type: type,
      space: space,
      rooms: rooms,
      bathrooms: bathrooms,
      price: price,
      latitude: latitude,
      longitude: longitude,
      photos: photos,
    );
    return null;
  } on DioException catch (e) {
    final res = e.response;
    if (res == null) {
      return (type: PostError.networkError, message: e.toString());
    }
    if (res.statusCode != null &&
        res.statusCode! >= 400 &&
        res.statusCode! < 500) {
      return (type: PostError.badRequest, message: e.toString());
    }
    rethrow;
  } catch (e) {
    return (type: PostError.unknown, message: e.toString());
  }
}

Future<({PostError type, String message})?> updatePost(
  WidgetRef ref, {
  required int postId,
  required PostType type,
  required double space,
  required int rooms,
  required int bathrooms,
  required double price,
  required double latitude,
  required double longitude,
  List<MultipartFile>? photos,
}) async {
  final repo = ref.read(postRepositoryProvider);
  try {
    await repo.updatePost(
      postId: postId,
      type: type,
      space: space,
      rooms: rooms,
      bathrooms: bathrooms,
      price: price,
      latitude: latitude,
      longitude: longitude,
      photos: photos,
    );
    return null;
  } on DioException catch (e) {
    final res = e.response;
    if (res == null) {
      return (type: PostError.networkError, message: e.toString());
    }
    if (res.statusCode != null &&
        res.statusCode! >= 400 &&
        res.statusCode! < 500) {
      return (type: PostError.badRequest, message: e.toString());
    }
    rethrow;
  } catch (e) {
    return (type: PostError.unknown, message: e.toString());
  }
}

Future<({PostError type, String message})?> deletePost(
  WidgetRef ref,
  int postId,
) async {
  final repo = ref.read(postRepositoryProvider);
  try {
    await repo.deletePost(postId);
    return null;
  } on DioException catch (e) {
    final res = e.response;
    if (res == null) {
      return (type: PostError.networkError, message: e.toString());
    }
    if (res.statusCode != null &&
        res.statusCode! >= 400 &&
        res.statusCode! < 500) {
      return (type: PostError.badRequest, message: e.toString());
    }
    rethrow;
  } catch (e) {
    return (type: PostError.unknown, message: e.toString());
  }
}
