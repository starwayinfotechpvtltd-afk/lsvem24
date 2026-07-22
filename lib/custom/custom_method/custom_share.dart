import 'dart:developer';
import 'package:metube/utils/constant/app_constant.dart';
import 'package:metube/utils/services/convert_to_network.dart';
import 'package:share_plus/share_plus.dart';

class CustomShare {
  static Future<ShareResult?> share({
    required String videoId,
    required String channelId,
    required String name,
    required String image,
    required String url,
    required String pageRoutes,
    String? slug,
    bool isShort = false,
  }) async {
    log("Share Method Called Success");
    final shareLink = _resolveShareLink(
      url: url,
      videoId: videoId,
      slug: slug,
      isShort: isShort,
    );

    final shareText = [
      if (name.trim().isNotEmpty) name.trim(),
      if (shareLink.isNotEmpty) shareLink,
    ].where((element) => element.isNotEmpty).join("\n");

    try {
      return SharePlus.instance.share(
        ShareParams(
          title: name.trim().isEmpty ? null : name.trim(),
          subject: name.trim().isEmpty ? null : name.trim(),
          text: shareText.isEmpty ? "Check this video" : shareText,
        ),
      );
    } catch (e) {
      log("Native Share Sheet Failed => $e");
      return null;
    }
  }

  static String _resolveShareLink({
    required String url,
    required String videoId,
    String? slug,
    bool isShort = false,
  }) {
    final slugVal = (slug ?? '').trim();
    final effectiveSlug = slugVal.isNotEmpty ? slugVal : videoId.trim();

    if (effectiveSlug.isNotEmpty) {
      final prefix = isShort ? "shorts" : "videos";
      return "https://lsvem24.com/$prefix/$effectiveSlug";
    }

    return url.trim();
  }
}
