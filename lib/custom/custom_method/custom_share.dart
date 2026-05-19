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
  }) async {
    log("Share Method Called Success");
    final shareLink = _resolveShareLink(url: url, videoId: videoId);

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
    // await FlutterShare.share(title: title, linkUrl: "https://play.google.com/store/apps/details?id=AppPackageName");
  }

  static String _resolveShareLink({
    required String url,
    required String videoId,
  }) {
    final trimmedUrl = url.trim();
    if (trimmedUrl.isNotEmpty) {
      return ConvertToNetwork.resolve(trimmedUrl);
    }

    final trimmedVideoId = videoId.trim();
    if (trimmedVideoId.isEmpty) return "";

    final baseUrl = Constant.mediaBaseURL.endsWith("/")
        ? Constant.mediaBaseURL.substring(0, Constant.mediaBaseURL.length - 1)
        : Constant.mediaBaseURL;

    return "$baseUrl/video/$trimmedVideoId";
  }
}
