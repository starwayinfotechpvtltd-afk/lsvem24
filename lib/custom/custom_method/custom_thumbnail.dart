import 'package:metube/pages/custom_pages/file_upload_page/convert_video_image_api.dart';
import 'package:metube/utils/settings/app_settings.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class CustomGetThumbnail {
  static Future<String?> onGet(String videoPath, int videoType) async {
    try {
      final videoThumbnail = await VideoThumbnail.thumbnailFile(
        video: videoPath,
        thumbnailPath: (await getTemporaryDirectory()).path,
        imageFormat: ImageFormat.JPEG,
        timeMs: -1,
        maxHeight: 400,
        quality: 100,
      );
      if (videoThumbnail != null) {
        final thumbnailUrl = await ConvertVideoImageApi.callApi(videoThumbnail, videoType == 1 ? true : false);
        AppSettings.showLog("Picked Video Thumbnail Url => $thumbnailUrl");
        return thumbnailUrl;
      } else {
        AppSettings.showLog("Picked Video Thumbnail Error");
        return null;
      }
    } catch (e) {
      AppSettings.showLog("Catch :- Get Thumbnail Error");
    }
    return null;
  }
}
