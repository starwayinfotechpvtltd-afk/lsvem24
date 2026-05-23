import 'dart:io';

import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:path_provider/path_provider.dart';

class VideoCompressor {
  static Future<String?> compress({
    required String input,
    required bool isShort,
  }) async {
    if (!File(input).existsSync()) return null;

    try {
      final dir = await getTemporaryDirectory();
      final output =
          '${dir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.mp4';

      final escapedInput = _escapePath(input);
      final escapedOutput = _escapePath(output);

      final command = isShort
          ? '-y -i $escapedInput -c:v libx264 -preset medium -crf 23 '
              '-maxrate 2M -bufsize 4M -vf scale=720:-2 -movflags +faststart '
              '-c:a aac -b:a 128k $escapedOutput'
          : '-y -i $escapedInput -c:v libx264 -preset medium -crf 22 '
              '-maxrate 4M -bufsize 8M -vf scale=1280:-2 -movflags +faststart '
              '-c:a aac -b:a 160k $escapedOutput';

      final session = await FFmpegKit.execute(command);
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode) && File(output).existsSync()) {
        final size = await File(output).length();
        if (size > 10000) return output;
      }

      return input;
    } catch (e) {
      return input;
    }
  }

  static String _escapePath(String path) {
    if (path.contains(' ')) return '"$path"';
    return path;
  }
}
