import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/session.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_selfie_segmentation/google_mlkit_selfie_segmentation.dart';

class VideoCompositor {
  /// Composite camera overlay onto background video with face mask, high quality, and keyframed movement
  static Future<String?> compositeCameraOverlay({
    required String backgroundVideoPath,
    required String cameraVideoPath,
    required Offset overlayPosition,
    required double overlaySize,
    required Size screenSize,
    required Duration duration,
    String maskMode = 'oval',
    List<Map<String, double>>? keyframes,
    Function(String status)? onProgress,
  }) async {
    try {
      if (Platform.isAndroid) {
        final hasPermission = await _requestStoragePermission();
        if (!hasPermission) {
          debugPrint('❌ Storage permission denied');
          return null;
        }
      }

      final bgFile = File(backgroundVideoPath);
      final camFile = File(cameraVideoPath);

      if (!await bgFile.exists()) {
        debugPrint('❌ Background video not found: $backgroundVideoPath');
        return null;
      }
      if (!await camFile.exists()) {
        debugPrint('❌ Camera video not found: $cameraVideoPath');
        return null;
      }

      final bgSize = await bgFile.length();
      final camSize = await camFile.length();

      if (bgSize < 1024 || camSize < 1024) {
        debugPrint('❌ Input video file too small or corrupted');
        return null;
      }

      // ✅ High Quality Shorts Resolution (1080x1920 Full HD)
      const outputWidth = 1080;
      const outputHeight = 1920;

      // Scale factor from preview screen coordinates to 1080p output coordinates
      final scaleFactor = outputWidth / screenSize.width;

      // ✅ Dynamic Keyframe Expression Builder with Max 15 Keyframe Cap
      String buildKeyframeExpr(String field, double fallback, {double multiplier = 1.0}) {
        if (keyframes == null || keyframes.isEmpty) {
          return (fallback * multiplier).round().toString();
        }

        final significantKfs = <Map<String, double>>[];
        for (var k in keyframes) {
          if (significantKfs.isEmpty) {
            significantKfs.add(k);
          } else {
            final last = significantKfs.last;
            final dx = (k['x']! - last['x']!).abs();
            final dy = (k['y']! - last['y']!).abs();
            final ds = (k['size']! - last['size']!).abs();
            final dt = (k['time']! - last['time']!).abs();
            if (dx > 1.5 || dy > 1.5 || ds > 1.5 || dt > 0.3) {
              significantKfs.add(k);
            }
          }
        }
        if (keyframes.isNotEmpty && significantKfs.last != keyframes.last) {
          significantKfs.add(keyframes.last);
        }

        const maxKfs = 15;
        final cleanKfs = <Map<String, double>>[];
        if (significantKfs.length <= maxKfs) {
          cleanKfs.addAll(significantKfs);
        } else {
          final step = (significantKfs.length - 1) / (maxKfs - 1);
          for (int i = 0; i < maxKfs - 1; i++) {
            final index = (i * step).round();
            cleanKfs.add(significantKfs[index]);
          }
          cleanKfs.add(significantKfs.last);
        }

        if (cleanKfs.isEmpty) return (fallback * multiplier).round().toString();
        if (cleanKfs.length == 1) return (cleanKfs.first[field]! * multiplier * scaleFactor).round().toString();

        String expr = (cleanKfs.last[field]! * multiplier * scaleFactor).round().toString();
        for (int i = cleanKfs.length - 2; i >= 0; i--) {
          final t0 = cleanKfs[i]['time']!;
          final t1 = cleanKfs[i + 1]['time']!;
          final v0 = (cleanKfs[i][field]! * multiplier * scaleFactor).round();
          final v1 = (cleanKfs[i + 1][field]! * multiplier * scaleFactor).round();
          final dt = (t1 - t0).clamp(0.01, 999.0);

          final interp = '$v0+($v1-$v0)*(t-${t0.toStringAsFixed(3)})/${dt.toStringAsFixed(3)}';
          expr = 'if(lte(t,${t1.toStringAsFixed(3)}),$interp,$expr)';
        }
        return expr;
      }

      // ✅ Enforce integer coordinates and EVEN dimensions (divisible by 2) for libx264/yuv420p compliance
      final xPosExpr = 'trunc(${buildKeyframeExpr('x', overlayPosition.dx * scaleFactor)})';
      final yPosExpr = 'trunc(${buildKeyframeExpr('y', overlayPosition.dy * scaleFactor)})';
      final rawWExpr = buildKeyframeExpr('size', overlaySize * scaleFactor);
      final rawHExpr = maskMode == 'oval'
          ? buildKeyframeExpr('size', overlaySize * scaleFactor, multiplier: 1.25)
          : rawWExpr;

      final wSizeExpr = '2*trunc(($rawWExpr)/2)';
      final hSizeExpr = '2*trunc(($rawHExpr)/2)';

      debugPrint('🎯 Mask: $maskMode, Output: ${outputWidth}x$outputHeight');

      final outputDir = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final outputPath = '${outputDir.path}/greenscreen_$timestamp.mp4';

      String filterComplex;
      String inputFlags = '-i "$backgroundVideoPath" -i "$cameraVideoPath" ';

      // ✅ AI Person Cutout: Generate mask video from ML Kit, then alphamerge
      if (maskMode == 'oval') {
        onProgress?.call('🧠 AI detecting person...');
        debugPrint('🧠 Starting AI Person Segmentation...');

        final maskVideoPath = await _generateMaskVideo(
          cameraVideoPath: cameraVideoPath,
          outputDir: outputDir.path,
          timestamp: timestamp,
          onProgress: onProgress,
        );

        if (maskVideoPath != null && File(maskVideoPath).existsSync()) {
          inputFlags = '-i "$backgroundVideoPath" -i "$cameraVideoPath" -i "$maskVideoPath" ';
          filterComplex = '[0:v]setsar=1,scale=$outputWidth:$outputHeight:force_original_aspect_ratio=increase,crop=$outputWidth:$outputHeight,setsar=1[bg];'
              '[1:v]setsar=1,scale=w=\'$wSizeExpr\':h=\'$hSizeExpr\':eval=frame,format=rgba,setsar=1[scaled];'
              '[2:v]scale=w=\'$wSizeExpr\':h=\'$hSizeExpr\':eval=frame,format=gray,boxblur=4:4,setsar=1[maskscaled];'
              '[scaled][maskscaled]alphamerge[person_only];'
              '[bg][person_only]overlay=x=\'$xPosExpr\':y=\'$yPosExpr\':eval=frame:shortest=1[outv]';
        } else {
          debugPrint('⚠️ ML mask generation failed, falling back to soft oval mask');
          filterComplex = '[0:v]setsar=1,scale=$outputWidth:$outputHeight:force_original_aspect_ratio=increase,crop=$outputWidth:$outputHeight,setsar=1[bg];'
              '[1:v]setsar=1,scale=w=\'$wSizeExpr\':h=\'$hSizeExpr\':eval=frame,format=rgba,setsar=1[scaled];'
              '[scaled]geq='
              'r=\'r(X,Y)\':'
              'g=\'g(X,Y)\':'
              'b=\'b(X,Y)\':'
              'a=\'255*clip((1-pow((X-W/2)/(W/2),2)-pow((Y-H/2)/(H/2),2))*4,0,1)\'[masked];'
              '[bg][masked]overlay=x=\'$xPosExpr\':y=\'$yPosExpr\':eval=frame:shortest=1[outv]';
        }
      } else if (maskMode == 'chroma') {
        filterComplex = '[0:v]setsar=1,scale=$outputWidth:$outputHeight:force_original_aspect_ratio=increase,crop=$outputWidth:$outputHeight,setsar=1[bg];'
            '[1:v]setsar=1,scale=w=\'$wSizeExpr\':h=\'$hSizeExpr\':eval=frame,format=rgba,setsar=1[scaled];'
            '[scaled]colorkey=0x00FF00:0.38:0.15[ckout1];'
            '[ckout1]colorkey=0x008000:0.35:0.15[ckout2];'
            '[bg][ckout2]overlay=x=\'$xPosExpr\':y=\'$yPosExpr\':eval=frame:shortest=1[outv]';
      } else { // 'circle'
        filterComplex = '[0:v]setsar=1,scale=$outputWidth:$outputHeight:force_original_aspect_ratio=increase,crop=$outputWidth:$outputHeight,setsar=1[bg];'
            '[1:v]setsar=1,scale=w=\'$wSizeExpr\':h=\'$wSizeExpr\':eval=frame,format=rgba,setsar=1[scaled];'
            '[scaled]geq='
            'r=\'r(X,Y)\':'
            'g=\'g(X,Y)\':'
            'b=\'b(X,Y)\':'
            'a=\'if(lte(hypot(X-W/2,Y-H/2),W/2),255,0)\'[masked];'
            '[bg][masked]overlay=x=\'$xPosExpr\':y=\'$yPosExpr\':eval=frame:shortest=1[outv]';
      }

      final durationSec = (duration.inMilliseconds / 1000.0).clamp(0.3, 3600.0).toStringAsFixed(3);

      onProgress?.call('🎬 Rendering final video...');

      final command = '-y '
          '$inputFlags'
          '-filter_complex "$filterComplex" '
          '-map "[outv]" '
          '-map 0:a? '
          '-t $durationSec '
          '-c:v libx264 '
          '-preset ultrafast '
          '-tune zerolatency '
          '-pix_fmt yuv420p '
          '-r 30 '
          '-crf 18 '
          '-b:v 5M '
          '-maxrate 8M '
          '-bufsize 10M '
          '-c:a aac '
          '-b:a 256k '
          '-movflags +faststart '
          '"$outputPath"';

      debugPrint('🎬 Starting FFmpeg composition...');
      debugPrint('Command: ffmpeg $command');

      bool processingComplete = false;
      String? errorMessage;

      await FFmpegKit.executeAsync(
        command,
        (Session session) async {
          final returnCode = await session.getReturnCode();
          final output = await session.getOutput();
          
          if (returnCode == null || returnCode.getValue() != 0) {
            errorMessage = 'FFmpeg failed with return code: ${returnCode?.getValue()}';
            debugPrint('❌ $errorMessage\nOutput: $output');
          }
          processingComplete = true;
        },
        (log) => debugPrint('FFmpeg log: ${log.getMessage()}'),
        (statistics) => debugPrint('📊 Progress: ${statistics.getSize()} bytes, ${statistics.getTime()}ms'),
      );

      int waitCount = 0;
      const maxWait = 120; // 120 seconds timeout
      while (!processingComplete && waitCount < maxWait) {
        await Future.delayed(const Duration(seconds: 1));
        waitCount++;
      }

      if (!processingComplete) return null;
      if (errorMessage != null) return null;

      final outputFile = File(outputPath);
      if (!await outputFile.exists() || (await outputFile.length()) < 1024) return null;

      await _saveToGallery(outputPath, 'greenscreen_$timestamp.mp4');
      return outputPath;
    } catch (e) {
      debugPrint('❌ VideoCompositor error: $e');
      return null;
    }
  }

  /// ✅ Generate ultra-fast mask video using ML Kit & Binary PGM Image Sequence
  static Future<String?> _generateMaskVideo({
    required String cameraVideoPath,
    required String outputDir,
    required int timestamp,
    Function(String status)? onProgress,
  }) async {
    final segmenter = SelfieSegmenter(
      mode: SegmenterMode.stream,
      enableRawSizeMask: true,
    );

    Directory? framesDir;
    Directory? cameraFramesDir;

    try {
      framesDir = Directory('$outputDir/mask_frames_$timestamp');
      if (await framesDir.exists()) await framesDir.delete(recursive: true);
      await framesDir.create(recursive: true);

      cameraFramesDir = Directory('$outputDir/cam_frames_$timestamp');
      if (await cameraFramesDir.exists()) await cameraFramesDir.delete(recursive: true);
      await cameraFramesDir.create(recursive: true);

      // Extract camera frames at 15fps as JPEG for fast disk I/O
      onProgress?.call('🎞️ Extracting camera frames...');
      final extractCmd = '-y -i "$cameraVideoPath" -vf "fps=15" -q:v 2 "${cameraFramesDir.path}/frame_%04d.jpg"';

      bool extractComplete = false;
      await FFmpegKit.executeAsync(extractCmd, (session) async => extractComplete = true);

      int wait = 0;
      while (!extractComplete && wait < 60) {
        await Future.delayed(const Duration(seconds: 1));
        wait++;
      }

      if (!extractComplete) return null;

      final frameFiles = await cameraFramesDir.list().where((f) => f.path.endsWith('.jpg')).toList();
      frameFiles.sort((a, b) => a.path.compareTo(b.path));

      if (frameFiles.isEmpty) return null;

      int processed = 0;
      for (final frameEntity in frameFiles) {
        processed++;
        if (processed % 10 == 0 || processed == frameFiles.length) {
          onProgress?.call('🧠 AI segmenting frame $processed/${frameFiles.length}...');
        }

        try {
          final inputImage = InputImage.fromFilePath(frameEntity.path);
          final mask = await segmenter.processImage(inputImage);

          final filename = frameEntity.path.split(RegExp(r'[/\\]')).last.replaceAll('.jpg', '.pgm');
          final pgmPath = '${framesDir.path}/$filename';

          if (mask != null) {
            final maskW = mask.width;
            final maskH = mask.height;
            final confs = mask.confidences;
            final total = maskW * maskH;

            final bodyBytes = Uint8List(total);
            for (int i = 0; i < total; i++) {
              final conf = confs[i];
              if (conf >= 0.7) {
                bodyBytes[i] = 255;
              } else if (conf <= 0.3) {
                bodyBytes[i] = 0;
              } else {
                bodyBytes[i] = ((conf - 0.3) / 0.4 * 255).round().clamp(0, 255);
              }
            }

            final header = utf8.encode('P5\n$maskW $maskH\n255\n');
            final builder = BytesBuilder(copy: false);
            builder.add(header);
            builder.add(bodyBytes);

            await File(pgmPath).writeAsBytes(builder.takeBytes(), flush: false);
          } else {
            const defaultW = 480;
            const defaultH = 640;
            final bodyBytes = Uint8List(defaultW * defaultH)..fillRange(0, defaultW * defaultH, 255);
            final header = utf8.encode('P5\n$defaultW $defaultH\n255\n');
            final builder = BytesBuilder(copy: false);
            builder.add(header);
            builder.add(bodyBytes);
            await File(pgmPath).writeAsBytes(builder.takeBytes(), flush: false);
          }
        } catch (e) {
          debugPrint('⚠️ Frame segmentation error: $e');
        }
      }

      onProgress?.call('🎬 Creating mask video...');

      final maskVideoPath = '$outputDir/mask_video_$timestamp.mp4';
      final encodeMaskCmd = '-y -framerate 15 '
          '-i "${framesDir.path}/frame_%04d.pgm" '
          '-c:v libx264 -preset ultrafast '
          '-pix_fmt yuv420p '
          '-crf 10 '
          '"$maskVideoPath"';

      bool encodeComplete = false;
      await FFmpegKit.executeAsync(encodeMaskCmd, (session) async => encodeComplete = true);

      wait = 0;
      while (!encodeComplete && wait < 60) {
        await Future.delayed(const Duration(seconds: 1));
        wait++;
      }

      if (!encodeComplete || !File(maskVideoPath).existsSync()) return null;
      return maskVideoPath;
    } catch (e) {
      debugPrint('❌ _generateMaskVideo error: $e');
      return null;
    } finally {
      segmenter.close();
      try {
        if (framesDir != null && await framesDir.exists()) await framesDir.delete(recursive: true);
        if (cameraFramesDir != null && await cameraFramesDir.exists()) await cameraFramesDir.delete(recursive: true);
      } catch (e) {
        debugPrint('⚠️ Mask frames cleanup warning: $e');
      }
    }
  }

  static Future<bool> _requestStoragePermission() async {
    try {
      if (!Platform.isAndroid) return true;
      final info = await DeviceInfoPlugin().androidInfo;
      if (info.version.sdkInt >= 33) {
        final photos = await Permission.photos.request();
        final videos = await Permission.videos.request();
        if (photos.isPermanentlyDenied || videos.isPermanentlyDenied) {
          await openAppSettings();
          return false;
        }
        return photos.isGranted && videos.isGranted;
      } else if (info.version.sdkInt >= 30) {
        final storage = await Permission.storage.request();
        if (storage.isPermanentlyDenied) {
          await openAppSettings();
          return false;
        }
        return storage.isGranted;
      } else {
        return (await Permission.storage.request()).isGranted;
      }
    } catch (e) {
      return false;
    }
  }

  static Future<void> _saveToGallery(String filePath, String fileName) async {
    try {
      if (!await File(filePath).exists()) return;
      if (Platform.isAndroid) {
        final info = await DeviceInfoPlugin().androidInfo;
        if (info.version.sdkInt >= 30) {
          final appDir = await getApplicationDocumentsDirectory();
          final saveDir = Directory('${appDir.path}/GreenScreen');
          if (!await saveDir.exists()) await saveDir.create(recursive: true);
          await File(filePath).copy('${saveDir.path}/$fileName');
        } else {
          final downloadsDir = Directory('/storage/emulated/0/DCIM/GreenScreen');
          if (!await downloadsDir.exists()) await downloadsDir.create(recursive: true);
          await File(filePath).copy('${downloadsDir.path}/$fileName');
        }
      } else if (!kIsWeb && Platform.isIOS) {
        final appDir = await getApplicationDocumentsDirectory();
        final saveDir = Directory('${appDir.path}/GreenScreen');
        if (!await saveDir.exists()) await saveDir.create(recursive: true);
        await File(filePath).copy('${saveDir.path}/$fileName');
      }
    } catch (e) {
      debugPrint('❌ Save to gallery error: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getProjects() async {
    try {
      final outputDir = await getApplicationDocumentsDirectory();
      final dir = Directory(outputDir.path);
      final projects = <Map<String, dynamic>>[];
      await for (var entity in dir.list()) {
        if (entity is File && entity.path.contains('greenscreen_') && entity.path.endsWith('.mp4')) {
          final stats = await entity.stat();
          projects.add({
            'path': entity.path,
            'name': entity.path.split('/').last,
            'size': stats.size,
            'modified': stats.modified.toString(),
          });
        }
      }
      projects.sort((a, b) => b['modified'].compareTo(a['modified']));
      return projects;
    } catch (e) {
      return [];
    }
  }

  static Future<bool> deleteProject(String projectPath) async {
    try {
      final file = File(projectPath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
