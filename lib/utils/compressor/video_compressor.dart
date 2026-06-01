import 'dart:io';

import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:metube/utils/helpers/media_path_helper.dart';
import 'package:path_provider/path_provider.dart';

class VideoCompressor {
  static const double targetUploadMB = 1.0;
static const int maxPasses = 6;

static Future<String?> compress({
  required String input,
  required bool isShort,
}) async {

  String current =
      localFilePath(input);

  if (!File(current).existsSync()) {
    return null;
  }

  final inputMb =
      (await File(current).length()) /
      1024 /
      1024;

  print(
    "Original size = "
    "${inputMb.toStringAsFixed(1)} MB"
  );

  // Already small
  if (inputMb <= targetUploadMB) {
    return current;
  }

  // Huge videos
  if (inputMb > 2000) {

    final emergency =
        await _runFfmpeg(
      current,
      crf: 40,
      width: 360,
      audio: 32,
    );

    return emergency ?? current;
  }

  for (
      int pass = 0;
      pass < maxPasses;
      pass++
  ) {

    final crf =
        28 + (pass * 3);

    final width =
        [
          720,
          540,
          480,
          360,
          320,
          240
        ][pass];

    final audio =
        [
          96,
          64,
          48,
          32,
          32,
          24
        ][pass];

    final out =
        await _runFfmpeg(
      current,
      crf: crf,
      width: width,
      audio: audio,
    );

    if (out == null) {
      break;
    }

    current = out;

    final mb =
        (await File(current).length()) /
        1024 /
        1024;

    print(
      "PASS ${pass + 1}"
      " → "
      "${mb.toStringAsFixed(2)}MB"
    );

    if (
        mb <=
            targetUploadMB) {
      return current;
    }
  }

  return current;
}

  static Future<String?> _runFfmpeg(
    String input,
    {
      required int crf,
      required int width,
      required int audio,
    }
  ) async {

    final dir =
        await getTemporaryDirectory();

    final output =
        "${dir.path}/c_${DateTime.now().millisecondsSinceEpoch}.mp4";

    final cmd =
      '-y '
      '-i "$input" '
      '-c:v libx264 '
      '-preset ultrafast '
      '-crf $crf '
      '-vf scale=$width:-2,fps=24 '
      '-movflags +faststart '
      '-c:a aac '
      '-b:a ${audio}k '
      '"$output"';

    final session =
        await FFmpegKit.execute(cmd);

    final rc =
        await session.getReturnCode();

    if (
      ReturnCode.isSuccess(rc) &&
      File(output).existsSync()
    ) {
      return output;
    }

    return null;
  }
}
