import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/user.dart';
import '../../data/repositories/auth.dart';
import '../services/preferences.dart';
import '../services/secure_storage.dart';
import 'service.dart';

enum AuthError { unknown, invalidCredentials, networkError, badRequest }

class AuthState {
  final User? user;
  final String? token;
  final bool isLoading;
  final ({AuthError type, String message})? error;
  final AuthStatus status;

  AuthState({
    this.user,
    this.token,
    this.isLoading = false,
    this.error,
    this.status = .loading,
  });

  AuthState copyWith({
    User? user,
    String? token,
    bool isLoading = false,
    ({AuthError type, String message})? error,
    AuthStatus? status,
  }) {
    if (error != null) {
      assert(status == .error || status == null);
    } else {
      assert(status != .error);
    }

    return AuthState(
      user: user ?? this.user,
      token: token ?? this.token,
      isLoading: isLoading,
      error: error,
      status: error != null ? .error : status ?? this.status,
    );
  }

  bool get isAuthenticated => token != null && user != null;
  bool get isApproved => user?.isApproved ?? true;
  bool get isGuest => !isAuthenticated || !isApproved || user?.role == .guest;
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
    state = state.copyWith(isLoading: true, status: .loading);

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
            status: .authenticated,
          );
          return;
        } catch (e) {
          // unknown error
          if (e is! DioException) rethrow;
          final res = e.response;
          // no response
          if (res == null) {
            state = state.copyWith(
              error: (type: .networkError, message: e.toString()),
            );
            return;
          }
          // token is invalid, clear it
          if (res.statusCode == 401) {
            await _secureStorage.deleteToken();
          }
        }
      }

      // check for saved credentials
      final creds = await _secureStorage.getCredentials();
      if (creds != null) {
        try {
          await _loginWithCredentials(creds['phone']!, creds['password']!);
          return;
        } catch (e) {
          if (e is! DioException) rethrow;

          final res = e.response;

          if (res == null) {
            state = state.copyWith(
              error: (type: .networkError, message: e.toString()),
            );
            return;
          }

          // login failed with saved credentials
          if (res.statusCode == 403) {
            // account not approved yet
            state = state.copyWith(status: .approvalPending);
            return;
          } else if (res.statusCode == 401) {
            // account rejected - delete credentials and mark as rejected
            await _secureStorage.deleteCredentials();
            state = state.copyWith(status: .rejected);
            return;
          }
        }
      }

      // no token or credentials, check if first time
      final isFirstTime = _preferences.isFirstTime();
      if (isFirstTime) {
        state = state.copyWith(status: .initial);
      } else {
        state = state.copyWith(status: .unauthenticated);
      }
    } catch (e) {
      state = state.copyWith(error: (type: .unknown, message: e.toString()));
    }
  }

  Future<void> login(String phoneNumber, String password) async {
    state = state.copyWith(isLoading: true, status: .loading);

    try {
      final response = await _repo.login(
        phoneNumber: phoneNumber,
        password: password,
      );

      final token = response.data['token'] as String;
      final userData = User.fromJson(response.data['user']);

      await _secureStorage.saveToken(token);
      await _secureStorage.deleteCredentials();

      state = state.copyWith(
        user: userData,
        token: token,
        status: .authenticated,
      );

      await _preferences.setNotFirstTime();
    } on DioException catch (e) {
      final res = e.response;
      if (res == null) {
        state = state.copyWith(
          error: (type: .networkError, message: e.toString()),
        );
        return;
      }
      switch (res.statusCode) {
        case 403:
          // account not approved - save credentials for later attempts
          await _secureStorage.saveCredentials(phoneNumber, password);
          state = state.copyWith(status: .approvalPending);
        case 401:
          // invalid credentials
          state = state.copyWith(
            error: (type: .invalidCredentials, message: e.toString()),
          );
        case var _? && >= 400 && < 500:
          // validation error / bad request
          state = state.copyWith(
            error: (type: .badRequest, message: e.toString()),
          );
        case _:
          rethrow;
      }
    } catch (e) {
      state = state.copyWith(error: (type: .unknown, message: e.toString()));
    }
  }

  Future<void> _loginWithCredentials(
    String phoneNumber,
    String password,
  ) async {
    final Response response;

    try {
      response = await _repo.login(
        phoneNumber: phoneNumber,
        password: password,
      );
    } on DioException catch (e) {
      if (e.response == null) {
        state = state.copyWith(
          error: (type: .networkError, message: e.toString()),
        );
        return;
      } else {
        rethrow;
      }
    } catch (e) {
      state = state.copyWith(error: (type: .unknown, message: e.toString()));
      return;
    }

    final token = response.data['token'] as String;
    final userData = User.fromJson(response.data['user']);

    await _secureStorage.saveToken(token);
    await _secureStorage.deleteCredentials();

    state = state.copyWith(
      user: userData,
      token: token,
      status: .authenticated,
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
    state = state.copyWith(isLoading: true, status: .loading);

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
      final res = e.response;
      if (res == null) {
        state = state.copyWith(
          error: (type: .networkError, message: e.toString()),
        );
        return;
      }
      switch (res.statusCode) {
        case var _? && >= 400 && < 500:
          // validation error / bad request
          state = state.copyWith(
            error: (type: .badRequest, message: e.toString()),
          );
        case _:
          rethrow;
      }
    } catch (e) {
      state = state.copyWith(error: (type: .unknown, message: e.toString()));
    }
  }

  Future<void> _tryLoginAfterSignup(String phoneNumber, String password) async {
    try {
      await _loginWithCredentials(phoneNumber, password);
    } on DioException catch (e) {
      final res = e.response;
      if (res == null) {
        state = state.copyWith(
          error: (type: .networkError, message: e.toString()),
        );
      } else if (res.statusCode == 403) {
        state = state.copyWith(status: .approvalPending);
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
      await _secureStorage.clearAll();
      state = AuthState(status: .unauthenticated);
    } catch (e) {
      if (e is DioException && e.response == null) {
        state = state.copyWith(
          error: (type: .networkError, message: e.toString()),
        );
      }
    }
  }

  Future<void> beHost() async {
    try {
      if (state.user == null ||
          state.user!.requestingHost ||
          state.user!.role != .tenant) {
        return;
      }

      state = state.copyWith(isLoading: true, error: null);

      await _repo.beHost();

      state = state.copyWith(user: state.user!.copyWith(requestingHost: true));
    } catch (e) {
      if (e is DioException && e.response == null) {
        state = state.copyWith(
          error: (type: .networkError, message: e.toString()),
        );
      } else {
        state = state.copyWith(error: (type: .unknown, message: e.toString()));
      }
    }
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

final currentUserProvider = Provider((ref) {
  final authState = ref.watch(authProvider);
  return authState.user;
});

final authStatusProvider = Provider((ref) {
  final authState = ref.watch(authProvider);
  return authState.status;
});
