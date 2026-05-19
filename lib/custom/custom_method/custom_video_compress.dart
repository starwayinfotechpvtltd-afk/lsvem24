// import 'package:metube/utils/settings/app_settings.dart';
// import 'package:video_compress/video_compress.dart';
//
// class CustomVideoCompress {
//   static Future<String?> onCompress(String videoPath) async {
//     try {
//       final compressVideo = await VideoCompress.compressVideo(videoPath, deleteOrigin: true, includeAudio: true, quality: VideoQuality.LowQuality);
//       AppSettings.showLog("Video Compress Path => ${compressVideo?.path}");
//       AppSettings.showLog("Video Compress Size => ${compressVideo?.filesize}");
//       return compressVideo?.path;
//     } catch (e) {
//       AppSettings.showLog("Video Compress Failed...");
//     }
//     return null;
//   }
// }
