import 'package:flutter/foundation.dart';

class AssetUtil {
  static const String defaultCdnUrl = 'http://127.0.0.1:8000/storage';

  static String getAssetUrl(String path, {String? transformation}) {
    final cdnUrl = const String.fromEnvironment(
      'CDN_URL',
      defaultValue: defaultCdnUrl,
    );

    if (path.isEmpty) return '';

    if (!kDebugMode && transformation != null) {
      return '$cdnUrl/t_$transformation/$path';
    }

    return '$cdnUrl/$path';
  }

  static String getThumbnail(String path) {
    return getAssetUrl(path, transformation: 'Thumbnail');
  }

  static String getProfile(String path) {
    return getAssetUrl(path, transformation: 'Profile');
  }

  static String getBanner(String path) {
    return getAssetUrl(path, transformation: 'Banner 16:9');
  }
}
