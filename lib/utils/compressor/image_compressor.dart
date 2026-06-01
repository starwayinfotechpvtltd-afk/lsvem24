import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:metube/utils/helpers/media_path_helper.dart';

class ImageCompressor {

  static Future<String?> compress(
    String path,
  ) async { 
    if (!localFileExists(path)) {
      return null;
    }

    final input = File(localFilePath(path));

    final dir =
        input.parent.path;

    final name =
        DateTime.now()
            .millisecondsSinceEpoch;

    final output =
        "$dir/thumb_$name.jpg";

    final result =
        await FlutterImageCompress.compressAndGetFile(
      path,
      output,

      quality: 70,

      minWidth: 480,
      minHeight: 480,

      keepExif: false,
    );

    if (result == null) {
      return null;
    }

    final size =
        await result.length();

    if (size == 0) {
      return null;
    }

    if (size > 500 * 1024) {
 return await compress(result.path);
}

    return result.path;
  }
}