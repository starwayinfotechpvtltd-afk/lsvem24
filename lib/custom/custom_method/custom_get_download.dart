import 'dart:io';

import 'package:metube/utils/settings/app_settings.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class CustomGetDownload {
  static Future<List> onGet() async {
    try {
      Directory? filePath = Platform.isAndroid ? await getExternalStorageDirectory() : await getApplicationSupportDirectory();

      final downloadPath = '${filePath?.path}/MyDownload';

      AppSettings.showLog("Download Path => $downloadPath");

      Directory(downloadPath).createSync(recursive: true);

      List downloadVideos =
          Directory(downloadPath).listSync().where((entity) => entity is File && entity.path.endsWith('.mp4')).map((e) => path.basenameWithoutExtension(e.path)).toList();

      // .listSync()
      // .where((entity) => entity is File && entity.path.endsWith('.mp4'))
      // .map((e) => e.path)
      // .toList();

      AppSettings.showLog("Downloaded Video $downloadVideos");

      return downloadVideos;
    } catch (e) {
      AppSettings.showLog("Get Download Video Error !!!");
      return [];
    }
  }
}
