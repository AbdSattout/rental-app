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

class PostState {
  final bool isLoading;
  final String? error;

  final List<Post>? homepagePosts;
  final PaginationInfo? homepagePagination;

  final List<Post>? filteredPosts;
  final PaginationInfo? filteredPagination;

  final List<Post>? userPosts;
  final PaginationInfo? userPagination;

  final List<Post>? ownPosts;
  final PaginationInfo? ownPagination;

  final Post? selectedPost;

  PostState({
    this.isLoading = false,
    this.error,
    this.homepagePosts,
    this.homepagePagination,
    this.filteredPosts,
    this.filteredPagination,
    this.userPosts,
    this.userPagination,
    this.ownPosts,
    this.ownPagination,
    this.selectedPost,
  });

  PostState copyWith({
    bool? isLoading,
    String? error,
    List<Post>? homepagePosts,
    PaginationInfo? homepagePagination,
    List<Post>? filteredPosts,
    PaginationInfo? filteredPagination,
    List<Post>? userPosts,
    PaginationInfo? userPagination,
    List<Post>? ownPosts,
    PaginationInfo? ownPagination,
    Post? selectedPost,
  }) {
    return PostState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      homepagePosts: homepagePosts ?? this.homepagePosts,
      homepagePagination: homepagePagination ?? this.homepagePagination,
      filteredPosts: filteredPosts ?? this.filteredPosts,
      filteredPagination: filteredPagination ?? this.filteredPagination,
      userPosts: userPosts ?? this.userPosts,
      userPagination: userPagination ?? this.userPagination,
      ownPosts: ownPosts ?? this.ownPosts,
      ownPagination: ownPagination ?? this.ownPagination,
      selectedPost: selectedPost ?? this.selectedPost,
    );
  }
}

List<Post> parsePosts(List list) => list.map((e) => Post.fromJson(e)).toList();

class PostNotifier extends Notifier<PostState> {
  late PostRepository _repo;

  @override
  PostState build() {
    _repo = ref.watch(postRepositoryProvider);
    return PostState();
  }

  Future<void> getPostDetails(int postId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await _repo.getPostDetails(postId);

      final post = Post.fromJson(response.data['post'] ?? response.data);

      print(response);
      state = state.copyWith(selectedPost: post, isLoading: false);
    } catch (e) {
      print(e);
      if (e is DioException) {
        print(e.response!.data);
      }
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> getHomepageFeed({bool refresh = false}) async {
    if (state.isLoading) return;
    try {
      state = state.copyWith(isLoading: true, error: null);

      final nextPage = refresh
          ? 1
          : (state.homepagePagination?.currentPage ?? 0) + 1;

      final hasMore = state.homepagePagination?.hasMore ?? true;
      if (!refresh && !hasMore) {
        state = state.copyWith(isLoading: false);
        return;
      }

      final response = await _repo.getHomepageFeed(page: nextPage);
      final postsJson = response.data["posts"];

      final pagination = PaginationInfo.fromJson(postsJson);
      final posts = parsePosts(postsJson["data"]);

      state = state.copyWith(
        homepagePosts: refresh
            ? posts
            : [...state.homepagePosts ?? [], ...posts],
        homepagePagination: pagination,
        isLoading: false,
      );
    } catch (e) {
      print(e);
      print("post provider");
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> filterPosts({
    PostType? type,
    double? minPrice,
    double? maxPrice,
    int? minBathrooms,
    int? maxBathrooms,
    int? minRooms,
    int? maxRooms,
    double? userLatitude,
    double? userLongitude,
    int? radius,
    bool refresh = false,
  }) async {
    if (state.isLoading) return;
    try {
      state = state.copyWith(isLoading: true, error: null);

      final nextPage = refresh
          ? 1
          : (state.filteredPagination?.currentPage ?? 0) + 1;

      final hasMore = state.filteredPagination?.hasMore ?? true;
      if (!refresh && !hasMore) {
        state = state.copyWith(isLoading: false);
        return;
      }

      final response = await _repo.filterPosts(
        type: type,
        minPrice: minPrice,
        maxPrice: maxPrice,
        minBathrooms: minBathrooms,
        maxBathrooms: maxBathrooms,
        minRooms: minRooms,
        maxRooms: maxRooms,
        userLatitude: userLatitude,
        userLongitude: userLongitude,
        radius: radius,
        page: nextPage,
      );

      final postsJson = response.data;
      final pagination = PaginationInfo.fromJson(postsJson);
      final posts = parsePosts(postsJson["data"]);

      state = state.copyWith(
        filteredPosts: refresh
            ? posts
            : [...state.filteredPosts ?? [], ...posts],
        filteredPagination: pagination,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> getUserPosts(int userId, {bool refresh = false}) async {
    if (state.isLoading) return;
    try {
      state = state.copyWith(isLoading: true, error: null);

      final nextPage = refresh
          ? 1
          : (state.userPagination?.currentPage ?? 0) + 1;

      final hasMore = state.userPagination?.hasMore ?? true;
      if (!refresh && !hasMore) {
        state = state.copyWith(isLoading: false);
        return;
      }

      final response = await _repo.getUserPosts(userId, page: nextPage);
      final postsJson = response.data["posts"];

      final pagination = PaginationInfo.fromJson(postsJson);
      final posts = parsePosts(postsJson["data"]);

      state = state.copyWith(
        userPosts: refresh ? posts : [...state.userPosts ?? [], ...posts],
        userPagination: pagination,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> getOwnPosts({bool refresh = false}) async {
    if (state.isLoading) return;
    try {
      state = state.copyWith(isLoading: true, error: null);

      final nextPage = refresh
          ? 1
          : (state.ownPagination?.currentPage ?? 0) + 1;

      final hasMore = state.ownPagination?.hasMore ?? true;
      if (!refresh && !hasMore) {
        state = state.copyWith(isLoading: false);
        return;
      }

      final response = await _repo.getOwnPosts(page: nextPage);
      final postsJson = response.data["posts"];

      final pagination = PaginationInfo.fromJson(postsJson);
      final posts = parsePosts(postsJson["data"]);

      state = state.copyWith(
        ownPosts: refresh ? posts : [...state.ownPosts ?? [], ...posts],
        ownPagination: pagination,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> createPost({
    required PostType type,
    required double space,
    required int rooms,
    required int bathrooms,
    required double price,
    required double latitude,
    required double longitude,
    required List<MultipartFile> photos,
  }) async {
    print("creating");
    try {
      state = state.copyWith(isLoading: true, error: null);

      await _repo.createPost(
        type: type,
        space: space,
        rooms: rooms,
        bathrooms: bathrooms,
        price: price,
        latitude: latitude,
        longitude: longitude,
        photos: photos,
      );

      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      if (e is DioException) {
        print(e.response!.data);
      }
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> updatePost({
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
    print("updating");
    try {
      state = state.copyWith(isLoading: true, error: null);

      await _repo.updatePost(
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

      await getPostDetails(postId);

      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      print(e);
      if (e is DioException) {
        print(e.response!.data);
      }
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> deletePost(int postId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      await _repo.deletePost(postId);

      state = state.copyWith(
        homepagePosts: state.homepagePosts
            ?.where((p) => p.id != postId)
            .toList(),
        userPosts: state.userPosts?.where((p) => p.id != postId).toList(),
        ownPosts: state.ownPosts?.where((p) => p.id != postId).toList(),
        isLoading: false,
      );

      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}

final postProvider = NotifierProvider<PostNotifier, PostState>(
  PostNotifier.new,
);
