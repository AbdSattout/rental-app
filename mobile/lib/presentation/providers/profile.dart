import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/profile.dart';
import '../../data/repositories/profile.dart';

class ProfileState {
  final bool isLoading;
  final String? error;
  final Profile? profile;

  ProfileState({this.isLoading = false, this.error, this.profile});

  ProfileState copyWith({bool? isLoading, String? error, Profile? profile}) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      profile: profile ?? this.profile,
    );
  }
}

class ProfileNotifier extends Notifier<ProfileState> {
  late ProfileRepository _repo;

  @override
  ProfileState build() {
    _repo = ref.watch(profileRepositoryProvider);
    return ProfileState();
  }

  Future<void> getProfile() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await _repo.fetchProfile();
      final data = response.data["profile"] ?? response.data;

      final profile = Profile.fromJson(data);

      state = state.copyWith(profile: profile, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> getProfileByPost(int postId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await _repo.fetchProfileByPost(postId);
      final data = response.data["profile"] ?? response.data;

      final profile = Profile.fromJson(data);

      state = state.copyWith(profile: profile, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> updateProfile({
    String? firstName,
    String? lastName,
    String? dateOfBirth,
    List<int>? profileImageBytes,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await _repo.updateProfile(
        firstName: firstName,
        lastName: lastName,
        dateOfBirth: dateOfBirth,
        profileImageBytes: profileImageBytes,
      );

      final data = response.data["data"] ?? response.data;
      final updated = Profile.fromJson(data);

      state = state.copyWith(profile: updated, isLoading: false);

      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}

final profileProvider = NotifierProvider<ProfileNotifier, ProfileState>(
  ProfileNotifier.new,
);
