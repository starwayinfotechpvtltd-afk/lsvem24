import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/session.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

class VideoCompositor {
  /// Composite camera overlay onto background video with circular mask
  static Future<String?> compositeCameraOverlay({
    required String backgroundVideoPath,
    required String cameraVideoPath,
    required Offset overlayPosition,
    required double overlaySize,
    required Size screenSize,
    required Duration duration,
  }) async {
    try {
      // ✅ Request proper storage permission for Android 13+
      if (Platform.isAndroid) {
        final hasPermission = await _requestStoragePermission();
        if (!hasPermission) {
          debugPrint('❌ Storage permission denied');
          return null;
        }
      }

      // ✅ Validate input files with size checks
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
      
      debugPrint('📹 Background file size: ${(bgSize / 1024).toStringAsFixed(2)} KB');
      debugPrint('📹 Camera file size: ${(camSize / 1024).toStringAsFixed(2)} KB');

      if (bgSize < 1024) {
        debugPrint('❌ Background video file too small or corrupted');
        return null;
      }
      if (camSize < 1024) {
        debugPrint('❌ Camera video file too small or corrupted');
        return null;
      }

      // ✅ Calculate overlay dimensions for circular mask
      final outputWidth = 720; // Target resolution
      final outputHeight =
    ((outputWidth * screenSize.height / screenSize.width) ~/ 2) * 2;
      
      // Scale factor from screen to output resolution
      final scaleFactor = outputWidth / screenSize.width;
      
      // Calculate overlay radius and center position in output coordinates
      final overlayRadius = (overlaySize * scaleFactor / 2).round();
      final centerX = ((overlayPosition.dx + overlaySize / 2) * scaleFactor).round();
      final centerY = ((overlayPosition.dy + overlaySize / 2) * scaleFactor).round();

      debugPrint('🎯 Overlay radius: $overlayRadius, Center: ($centerX, $centerY)');

      // ✅ Create output path
      final outputDir = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final outputPath = '${outputDir.path}/greenscreen_$timestamp.mp4';

      // ✅ FFmpeg command with circular mask overlay
      final command = '-y '
          '-i "$backgroundVideoPath" '
          '-i "$cameraVideoPath" '
          '-filter_complex '
          '"[1:v]scale=${overlayRadius * 2}:${overlayRadius * 2}[scaled];'
          '[scaled]format=rgba,'
          'geq=lum=\'p(X,Y)\':'
          'a=\'if(lte(hypot(X-$overlayRadius,Y-$overlayRadius),$overlayRadius),255,0)\'[masked];'
          '[0:v]scale=$outputWidth:$outputHeight:force_original_aspect_ratio=decrease, pad=$outputWidth:$outputHeight:(ow-iw)/2:(oh-ih)/2[bg];'
          '[bg][masked]overlay=x=${centerX - overlayRadius}:y=${centerY - overlayRadius}:shortest=1[outv]" '
          '-map "[outv]" '
          '-map 0:a? '
          '-t ${duration.inSeconds} '
          '-c:v libx264 '
          '-preset ultrafast '
          '-pix_fmt yuv420p '
          '-r 30 '
          '-crf 28 '
          '-c:a aac '
          '-b:a 128k '
          '-movflags +faststart '
          '"$outputPath"';

      debugPrint('🎬 Starting FFmpeg composition...');
      debugPrint('Command: ffmpeg $command');

      // ✅ Execute FFmpeg with proper error handling using ffmpeg_kit_flutter_new API
      bool processingComplete = false;
      String? errorMessage;

      await FFmpegKit.executeAsync(
        command,
        (Session session) async {
          final returnCode = await session.getReturnCode();
          final output = await session.getOutput();
          
          debugPrint('✅ FFmpeg session completed');
          debugPrint('Return code: $returnCode');
          debugPrint('Output: $output');
          
          if (returnCode == null || returnCode.getValue() != 0) {
            errorMessage = 'FFmpeg failed with return code: ${returnCode?.getValue()}';
            debugPrint('❌ $errorMessage');
          }
          
          processingComplete = true;
        },
        (log) {
          // Log callback - print FFmpeg logs
          debugPrint('FFmpeg log: ${log.getMessage()}');
        },
        (statistics) {
          // Statistics callback - track progress
          debugPrint('📊 Progress: ${statistics.getSize()} bytes, ${statistics.getTime()}ms');
        },
      );

      // ✅ Wait for processing to complete
      int waitCount = 0;
      const maxWait = 60; // 60 seconds timeout
      while (!processingComplete && waitCount < maxWait) {
        await Future.delayed(const Duration(seconds: 1));
        waitCount++;
        debugPrint('Waiting for FFmpeg... ${waitCount}s');
      }

      if (!processingComplete) {
        debugPrint('❌ FFmpeg timeout after ${maxWait}s');
        return null;
      }

      if (errorMessage != null) {
        debugPrint('❌ FFmpeg error: $errorMessage');
        return null;
      }

      // ✅ Verify output file was created
      final outputFile = File(outputPath);
      if (!await outputFile.exists()) {
        debugPrint('❌ Output file was not created');
        return null;
      }

      final outputSize = await outputFile.length();
      debugPrint('✅ Output file size: ${(outputSize / 1024).toStringAsFixed(2)} KB');

      if (outputSize < 1024) {
        debugPrint('❌ Output file is too small (likely corrupted)');
        return null;
      }

      // ✅ Save to gallery (optional)
      await _saveToGallery(outputPath, 'greenscreen_$timestamp.mp4');

      return outputPath;
    } catch (e, stackTrace) {
      debugPrint('❌ VideoCompositor error: $e');
      debugPrint('StackTrace: $stackTrace');
      return null;
    }
  }

  /// ✅ Request proper storage permissions based on Android version
  static Future<bool> _requestStoragePermission() async {
    try {
      if (!Platform.isAndroid) return true;

      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      
      debugPrint('📱 Android SDK: ${androidInfo.version.sdkInt}');

      if (androidInfo.version.sdkInt >= 33) {
        // Android 13+ (API 33+)
        final photos = await Permission.photos.request();
        final videos = await Permission.videos.request();
        
        if (photos.isPermanentlyDenied || videos.isPermanentlyDenied) {
          debugPrint('⚠️ Permissions permanently denied, opening settings...');
          await openAppSettings();
          return false;
        }
        
        return photos.isGranted && videos.isGranted;
      } else if (androidInfo.version.sdkInt >= 30) {
        // Android 11-12 (API 30-32)
        final storage = await Permission.storage.request();
        
        if (storage.isPermanentlyDenied) {
          await openAppSettings();
          return false;
        }
        
        return storage.isGranted;
      } else {
        // Android 10 and below
        final storage = await Permission.storage.request();
        return storage.isGranted;
      }
    } catch (e) {
      debugPrint('❌ Storage permission error: $e');
      return false;
    }
  }

  /// ✅ Save to gallery using proper Android storage APIs
  static Future<void> _saveToGallery(String filePath, String fileName) async {
    try {
      if (!await File(filePath).exists()) {
        debugPrint('❌ File does not exist: $filePath');
        return;
      }

      if (Platform.isAndroid) {
        final deviceInfo = DeviceInfoPlugin();
        final androidInfo = await deviceInfo.androidInfo;

        if (androidInfo.version.sdkInt >= 30) {
          // ✅ Android 11+ uses scoped storage (app-specific directory)
          final appDir = await getApplicationDocumentsDirectory();
          final saveDir = Directory('${appDir.path}/GreenScreen');
          
          if (!await saveDir.exists()) {
            await saveDir.create(recursive: true);
          }
          
          final newPath = '${saveDir.path}/$fileName';
          await File(filePath).copy(newPath);
          debugPrint('✅ Saved to app directory: $newPath');
        } else {
          // ✅ Android 10 and below - direct DCIM access
          final downloadsDir = Directory('/storage/emulated/0/DCIM/GreenScreen');
          
          if (!await downloadsDir.exists()) {
            await downloadsDir.create(recursive: true);
          }
          
          final newPath = '${downloadsDir.path}/$fileName';
          await File(filePath).copy(newPath);
          debugPrint('✅ Saved to gallery: $newPath');
        }
      } else if (!kIsWeb && Platform.isIOS) {
        final appDir = await getApplicationDocumentsDirectory();
        final saveDir = Directory('${appDir.path}/GreenScreen');
        
        if (!await saveDir.exists()) {
          await saveDir.create(recursive: true);
        }
        
        final newPath = '${saveDir.path}/$fileName';
        await File(filePath).copy(newPath);
        debugPrint('✅ Saved to iOS: $newPath');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Save to gallery error: $e');
      debugPrint('StackTrace: $stackTrace');
    }
  }

  /// Get all green screen projects
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
      
      // Sort by modified date (newest first)
      projects.sort((a, b) => b['modified'].compareTo(a['modified']));
      
      return projects;
    } catch (e) {
      debugPrint('❌ Get projects error: $e');
      return [];
    }
  }

  /// Delete a project
  static Future<bool> deleteProject(String projectPath) async {
    try {
      final file = File(projectPath);
      if (await file.exists()) {
        await file.delete();
        debugPrint('✅ Project deleted: $projectPath');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('❌ Delete project error: $e');
      return false;
    }
  }
}
