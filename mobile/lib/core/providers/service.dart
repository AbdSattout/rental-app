import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homio/core/providers/navigator_key.dart';

import '../../core/services/api.dart';
import '../../core/services/preferences.dart';
import '../../core/services/secure_storage.dart';

final preferencesServiceProvider = Provider((ref) => PreferencesService());

final secureStorageServiceProvider = Provider((ref) => SecureStorageService());

final apiServiceProvider = Provider((ref) {
  final secureStorage = ref.watch(secureStorageServiceProvider);
  final navigatorKey = ref.read(navigatorKeyProvider);
  return ApiService(secureStorage, navigatorKey);
});
