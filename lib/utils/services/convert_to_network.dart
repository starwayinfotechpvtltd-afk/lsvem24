import 'package:metube/utils/constant/app_constant.dart';
import 'package:metube/utils/settings/app_settings.dart';

class ConvertToNetwork {
  /// Converts any relative path like "/uploads/video.mp4"
  /// into a full URL: "http://192.168.0.209:5000/uploads/video.mp4"
  /// If already a full URL, returns as-is (with host/path fixes for uploads).
  static Future<String> convert(String url) async {
    return resolve(url);
  }

  static String _mediaBase() {
    String base = Constant.mediaBaseURL.trim();
    if (base.endsWith('/')) {
      base = base.substring(0, base.length - 1);
    }
    return base;
  }

  /// Synchronous version — use this everywhere for images and videos.
  static String resolve(String url) {
    final trimmed = url.trim();
    if (trimmed.isEmpty) {
      AppSettings.showLog("⚠️ ConvertToNetwork: empty URL");
      return '';
    }

    var value = trimmed.replaceAll('/api/uploads/', '/uploads/');

    if (value.startsWith('http://') || value.startsWith('https://')) {
      try {
        final uri = Uri.parse(value);
        var path = uri.path;
        if (path.isEmpty || path == '/') {
          return value;
        }
        if (!path.startsWith('/')) {
          path = '/$path';
        }
        path = path.replaceAll('/api/uploads/', '/uploads/');

        // Local uploads: always use app media base (fixes localhost / wrong host).
        if (path.startsWith('/uploads/')) {
          final fullUrl = '${_mediaBase()}$path';
          AppSettings.showLog("✅ ConvertToNetwork: media URL => $fullUrl");
          return fullUrl;
        }

        AppSettings.showLog("✅ ConvertToNetwork: external URL => $value");
        return value;
      } catch (e) {
        AppSettings.showLog("⚠️ ConvertToNetwork parse error => $e");
        return value;
      }
    }

    String path = value.startsWith('/') ? value : '/$value';
    path = path.replaceAll('/api/uploads/', '/uploads/');
    final fullUrl = '${_mediaBase()}$path';

    AppSettings.showLog("✅ ConvertToNetwork: resolved => $fullUrl");
    return fullUrl;
  }
}
