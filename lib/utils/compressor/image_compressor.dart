import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class ImageCompressor {

  static Future<String?> compress(
    String path,
  ) async {

    final input = File(path);

    if (!input.existsSync()) {
      return null;
    }

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

      quality: 85,

      minWidth: 720,
      minHeight: 720,

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

    return result.path;
  }
}