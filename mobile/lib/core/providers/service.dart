import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/api.dart';
import '../../core/services/preferences.dart';
import '../../core/services/secure_storage.dart';

final preferencesServiceProvider = Provider((ref) => PreferencesService());

final secureStorageServiceProvider = Provider((ref) => SecureStorageService());

final apiServiceProvider = Provider((ref) {
  final secureStorage = ref.watch(secureStorageServiceProvider);
  return ApiService(secureStorage);
});
