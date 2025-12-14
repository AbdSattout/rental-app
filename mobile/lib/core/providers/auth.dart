import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/user.dart';
import '../../data/repositories/auth.dart';
import '../services/preferences.dart';
import '../services/secure_storage.dart';
import 'service.dart';

class AuthState {
  final User? user;
  final String? token;
  final bool isLoading;
  final String? error;
  final AuthStatus status;

  AuthState({
    this.user,
    this.token,
    this.isLoading = false,
    this.error,
    this.status = AuthStatus.loading,
  });

  AuthState copyWith({
    User? user,
    String? token,
    bool? isLoading,
    String? error,
    AuthStatus? status,
  }) {
    return AuthState(
      user: user ?? this.user,
      token: token ?? this.token,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      status: status ?? this.status,
    );
  }

  bool get isAuthenticated => token != null && user != null;
  bool get isApproved => user?.isApproved ?? false;
  bool get isGuest => !isAuthenticated || !isApproved;
}

enum AuthStatus {
  initial,
  loading,
  authenticated,
  approvalPending,
  unauthenticated,
  rejected,
  error,
}

class AuthNotifier extends Notifier<AuthState> {
  late AuthRepository _repo;
  late SecureStorageService _secureStorage;
  late PreferencesService _preferences;

  @override
  AuthState build() {
    _repo = ref.watch(authRepositoryProvider);
    _secureStorage = ref.watch(secureStorageServiceProvider);
    _preferences = ref.watch(preferencesServiceProvider);

    return AuthState();
  }

  Future<void> initializeAuth() async {
    state = state.copyWith(isLoading: true, status: AuthStatus.loading);

    try {
      // check for saved token first
      final token = await _secureStorage.getToken();
      if (token != null) {
        // verify token by getting user
        try {
          final response = await _repo.getUser();
          final userData = User.fromJson(
            response.data['data'] ?? response.data,
          );
          state = state.copyWith(
            user: userData,
            token: token,
            isLoading: false,
            status: AuthStatus.authenticated,
          );
          return;
        } catch (e) {
          // token is invalid, clear it
          await _secureStorage.deleteToken();
        }
      }

      // check for saved credentials
      final creds = await _secureStorage.getCredentials();
      if (creds != null) {
        try {
          await _loginWithCredentials(creds['phone']!, creds['password']!);
          return;
        } catch (e) {
          // login failed with saved credentials
          if (e is DioException) {
            if (e.response?.statusCode == 403) {
              // account not approved yet
              state = state.copyWith(
                isLoading: false,
                status: AuthStatus.approvalPending,
              );
              return;
            } else if (e.response?.statusCode == 401) {
              // account rejected - delete credentials and mark as rejected
              await _secureStorage.deleteCredentials();
              state = state.copyWith(
                isLoading: false,
                status: AuthStatus.rejected,
              );
              return;
            }
          }
        }
      }

      // no token or credentials, check if first time
      final isFirstTime = _preferences.isFirstTime();
      if (isFirstTime) {
        state = state.copyWith(isLoading: false, status: AuthStatus.initial);
      } else {
        state = state.copyWith(
          isLoading: false,
          status: AuthStatus.unauthenticated,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        status: AuthStatus.error,
        error: e.toString(),
      );
    }
  }

  Future<void> login(String phoneNumber, String password) async {
    state = state.copyWith(isLoading: true, status: AuthStatus.loading);

    try {
      final response = await _repo.login(
        phoneNumber: phoneNumber,
        password: password,
      );

      final token = response.data['token'] as String;
      final userData = User.fromJson(response.data['user'] ?? {});

      await _secureStorage.saveToken(token);
      await _secureStorage.deleteCredentials();

      state = state.copyWith(
        user: userData,
        token: token,
        isLoading: false,
        status: AuthStatus.authenticated,
        error: null,
      );

      await _preferences.setNotFirstTime();
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        // account not approved - save credentials for later attempts
        await _secureStorage.saveCredentials(phoneNumber, password);
        state = state.copyWith(
          isLoading: false,
          status: AuthStatus.approvalPending,
          error: null,
        );
      } else if (e.response?.statusCode == 401) {
        state = state.copyWith(
          isLoading: false,
          status: AuthStatus.unauthenticated,
          error: 'invalid_credentials', // FIXME: what to do with this error?!
        );
      } else {
        rethrow;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        status: AuthStatus.error,
        error: e.toString(),
      );
    }
  }

  Future<void> _loginWithCredentials(
    String phoneNumber,
    String password,
  ) async {
    final response = await _repo.login(
      phoneNumber: phoneNumber,
      password: password,
    );

    final token = response.data['token'] as String;
    final userData = User.fromJson(response.data['user'] ?? {});

    await _secureStorage.saveToken(token);
    await _secureStorage.deleteCredentials();

    state = state.copyWith(
      user: userData,
      token: token,
      status: AuthStatus.authenticated,
    );
  }

  Future<void> register({
    required String phoneNumber,
    required String password,
    required String firstName,
    required String lastName,
    required String dateOfBirth,
    required List<int> idImageBytes,
    required List<int> profileImageBytes,
  }) async {
    state = state.copyWith(isLoading: true, status: AuthStatus.loading);

    try {
      await _repo.register(
        phoneNumber: phoneNumber,
        password: password,
        firstName: firstName,
        lastName: lastName,
        dateOfBirth: dateOfBirth,
        idImageBytes: idImageBytes,
        profileImageBytes: profileImageBytes,
      );

      // save credentials for auto-login attempt
      await _secureStorage.saveCredentials(phoneNumber, password);

      // try to login
      await _tryLoginAfterSignup(phoneNumber, password);
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        status: AuthStatus.error,
        error: e.response?.data['message'] ?? e.message ?? 'signup_error',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        status: AuthStatus.error,
        error: e.toString(),
      );
    }
  }

  Future<void> _tryLoginAfterSignup(String phoneNumber, String password) async {
    try {
      await _loginWithCredentials(phoneNumber, password);
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        state = state.copyWith(
          isLoading: false,
          status: AuthStatus.approvalPending,
          error: null,
        );
        await _preferences.setNotFirstTime();
      } else {
        rethrow;
      }
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);

    try {
      await _repo.logout();
    } catch (_) {}

    await _secureStorage.clearAll();
    await _preferences.resetFirstTime();

    state = AuthState(status: AuthStatus.unauthenticated);
  }

  Future<void> retryLogin(String phoneNumber, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await login(phoneNumber, password);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void updateUser(User user) {
    state = state.copyWith(user: user);
  }

  Future<bool> beHost() async {
    try {
      if (state.user == null ||
          state.user!.requestingHost ||
          state.user!.role != .tenant) {
        return false;
      }

      state = state.copyWith(isLoading: true, error: null);

      await _repo.beHost();

      state = state.copyWith(user: state.user!.copyWith(requestingHost: true));

      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

final isAuthenticatedProvider = Provider((ref) {
  final authState = ref.watch(authProvider);
  return authState.isAuthenticated;
});

final currentUserProvider = Provider((ref) {
  final authState = ref.watch(authProvider);
  return authState.user;
});

final authTokenProvider = Provider((ref) {
  final authState = ref.watch(authProvider);
  return authState.token;
});

final isApprovedProvider = Provider((ref) {
  final authState = ref.watch(authProvider);
  return authState.isApproved;
});

final authStatusProvider = Provider((ref) {
  final authState = ref.watch(authProvider);
  return authState.status;
});

final authErrorProvider = Provider((ref) {
  final authState = ref.watch(authProvider);
  return authState.error;
});
