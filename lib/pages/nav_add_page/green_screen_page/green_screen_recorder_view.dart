import 'dart:io';

import 'package:camera/camera.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:metube/database/database.dart';
import 'package:metube/pages/nav_add_page/green_screen_page/video_compositor.dart';
import 'package:metube/pages/nav_add_page/upload_video_page/upload_video_controller.dart';
import 'package:metube/pages/nav_add_page/upload_video_page/upload_video_view.dart';
import 'package:metube/utils/colors/app_color.dart';
import 'package:metube/utils/settings/app_settings.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart' as video_thumb;

class GreenScreenRecorderView extends StatefulWidget {
  const GreenScreenRecorderView({super.key, required this.backgroundVideoUrl});
  final String backgroundVideoUrl;

  @override
  State<GreenScreenRecorderView> createState() =>
      _GreenScreenRecorderViewState();
}

class _GreenScreenRecorderViewState extends State<GreenScreenRecorderView>
    with WidgetsBindingObserver {
  CameraController? _cam;
  bool _camReady = false;
  bool _isRecording = false;
  bool _isProcessing = false;

  VideoPlayerController? _bg;
  bool _bgReady = false;
  String? _bgVideoPath;

  bool _overlayInit = false;
  Offset _overlayTopLeftPx = const Offset(0, 0);
  double _overlaySizePx = 0;

  // ── Timer ───────────────────────────────────────────────────────────────────
  final Stopwatch _stopwatch = Stopwatch();
  DateTime? _recordingStartTime;
  Duration _recordingDuration = Duration.zero;

  // ── Overlay snapshot & keyframe tracking ────────────────────────────────────
  Offset _recordStartOverlayPos = const Offset(0, 0);
  double _recordStartOverlaySize = 0;
  final List<Map<String, double>> _overlayKeyframes = [];
  DateTime? _keyframeBaseTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _requestStoragePermission();
      _loadBackgroundVideo();
    });
  }

  @override
  void dispose() {
    _bg?.removeListener(_onBgVideoListener);
    _bg?.pause();
    _bg?.dispose();
    _cam?.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _cam;
    if (controller == null || !controller.value.isInitialized) return;

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      controller.pausePreview();
      _bg?.pause();
    } else if (state == AppLifecycleState.resumed) {
      controller.resumePreview();
      if (_isRecording) _bg?.play();
    }
  }

  // ── Auto-stop listener: fires when bg video reaches its end ──────────────────
  void _onBgVideoListener() {
    if (_bg == null || !_isRecording) return;

    final pos = _bg!.value.position;
    final duration = _bg!.value.duration;

    // Guard: duration must be valid
    if (duration.inMilliseconds <= 0) return;

    // Trigger stop within last 200ms to handle precision gaps
    if (pos.inMilliseconds >= duration.inMilliseconds - 200) {
      AppSettings.showLog(
          "🎬 BG short video ended — auto-stopping green screen recording");

      // Remove listener immediately to prevent multiple triggers
      _bg!.removeListener(_onBgVideoListener);

      // Stop recording (runs compositing + shows success dialog automatically)
      _stopRecording();
    }
  }

// ── Background video ──────────────────────────────────────────────────────── (same)
  Future<void> _loadBackgroundVideo() async {
    if (widget.backgroundVideoUrl.isEmpty) return;
    _bgVideoPath = widget.backgroundVideoUrl;
    try {
      _bg = VideoPlayerController.networkUrl(
          Uri.parse(widget.backgroundVideoUrl));
      await _bg!.initialize();
      _bg!.setLooping(false);
      _bg!.addListener(_onBgVideoListener);
      await _bg!.setVolume(0.4);
      if (!mounted) return;
      setState(() => _bgReady = true);
    } catch (e) {
      AppSettings.showLog("GreenScreen BG error: $e");
      setState(() => _bgReady = false);
    }
  }

// Add this method for network URLs
  Future<void> _initBackgroundPlayerFromUrl(String url) async {
    try {
      debugPrint('Initializing video player from URL: $url');

      // ✅ VideoPlayerController handles the network request automatically
      _bg = VideoPlayerController.networkUrl(Uri.parse(url));

      await _bg!.initialize();
      _bg!.setLooping(false);
      _bg!.addListener(_onBgVideoListener);
      await _bg!.setVolume(0.3);

      if (!mounted) return;
      setState(() => _bgReady = true);

      debugPrint('✅ Video player initialized successfully');
    } catch (e) {
      debugPrint('❌ Background player init error: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load video: $e')),
      );

      _bgVideoPath = 'camera_only';
      setState(() => _bgReady = false);
    }
  }

  // Downloads background to local file for FFmpeg (needs local path)
  Future<String?> _downloadBackgroundVideo(String url) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file =
          File('${dir.path}/bg_${DateTime.now().millisecondsSinceEpoch}.mp4');
      // Use http to download
      final client = HttpClient();
      final request = await client.getUrl(Uri.parse(url));
      final response = await request.close();
      await response.pipe(file.openWrite());
      client.close();
      if (!await file.exists()) return null;
      return file.path;
    } catch (e) {
      AppSettings.showLog("GreenScreen BG download error: $e");
      return null;
    }
  }

  Future<void> _initCamera() async {
    try {
      // Request permissions
      final camPerm = await Permission.camera.request();
      final micPerm = await Permission.microphone.request();

      if (camPerm.isPermanentlyDenied || micPerm.isPermanentlyDenied) {
        if (!mounted) return;
        final shouldOpen = await _showPermissionDialog();
        if (shouldOpen) await openAppSettings();
        return;
      }

      if (camPerm != PermissionStatus.granted ||
          micPerm != PermissionStatus.granted) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Camera/Mic permission required')),
        );
        return;
      }

      final cameras = await availableCameras();
      if (cameras.isEmpty) throw Exception('No cameras available');

      final front = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _cam = CameraController(
        front,
        ResolutionPreset.high,
        enableAudio: true,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await _cam!.initialize();
      if (!mounted) return;
      setState(() => _camReady = true);
    } catch (e) {
      debugPrint('Camera init error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Camera init failed: $e')),
      );
    }
  }

  Future<bool> _showPermissionDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Permission Required'),
            content: const Text(
              'Camera and microphone permissions are required for green screen recording. '
              'Please enable them in settings.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Open Settings'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _switchCamera() async {
    if (_isRecording) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Stop recording before switching camera')),
      );
      return;
    }

    try {
      final cameras = await availableCameras();
      if (_cam == null || cameras.isEmpty) return;

      final current = _cam!.description;
      final targetLens = current.lensDirection == CameraLensDirection.front
          ? CameraLensDirection.back
          : CameraLensDirection.front;

      final target = cameras.firstWhere(
        (c) => c.lensDirection == targetLens,
        orElse: () => cameras.first,
      );

      await _cam!.dispose();
      _cam = CameraController(
        target,
        ResolutionPreset.high,
        enableAudio: true,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await _cam!.initialize();
      if (!mounted) return;
      setState(() => _camReady = true);
    } catch (e) {
      debugPrint('Switch camera error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to switch camera: $e')),
      );
    }
  }

  Future<bool> _requestStoragePermission() async {
    try {
      if (!Platform.isAndroid) return true;
      final info = await DeviceInfoPlugin().androidInfo;

      if (info.version.sdkInt >= 33) {
        // Android 13+ — READ_MEDIA_VIDEO
        final videos = await Permission.videos.request();
        final photos = await Permission.photos.request();
        debugPrint(
            'Android 13+ permissions — videos: $videos, photos: $photos');
        // Only videos is needed to save video to gallery
        return videos.isGranted;
      } else if (info.version.sdkInt >= 30) {
        // Android 11-12 — no write permission needed for gallery via Gal
        return true;
      } else {
        // Android 10 and below
        final storage = await Permission.storage.request();
        debugPrint('Storage permission: $storage');
        return storage.isGranted;
      }
    } catch (e) {
      debugPrint('Storage permission error: $e');
      return true; // don't block saving on permission check failure
    }
  }

  Future<void> _initBackgroundPlayer(String path) async {
    try {
      _bg = VideoPlayerController.file(File(path));
      await _bg!.initialize();
      _bg!.setLooping(false);
      _bg!.addListener(_onBgVideoListener);
      await _bg!.setVolume(0.3); // Lower background volume
      if (!mounted) return;
      setState(() => _bgReady = true);
    } catch (e) {
      debugPrint('Background player init error: $e');
    }
  }

  Future<void> _startRecording() async {
    if (_cam == null || _isRecording) return;
    try {
      if (_bgReady && _bg != null) {
        await _bg?.seekTo(Duration.zero);
        _bg!.removeListener(_onBgVideoListener);
        _bg!.addListener(_onBgVideoListener);
        await _bg?.play();
        await Future.delayed(const Duration(milliseconds: 100));
      }

      await _cam!.startVideoRecording();
      _stopwatch
        ..reset()
        ..start();

      // ✅ Snapshot + init keyframe tracking
      _recordStartOverlayPos = _overlayTopLeftPx;
      _recordStartOverlaySize = _overlaySizePx;
      _overlayKeyframes.clear();
      _keyframeBaseTime = DateTime.now();
      _overlayKeyframes.add({
        'time': 0.0,
        'x': _overlayTopLeftPx.dx,
        'y': _overlayTopLeftPx.dy,
        'size': _overlaySizePx,
      });

      setState(() {
        _isRecording = true;
        _recordingStartTime = DateTime.now();
      });

      _showSnack('Recording started');
    } catch (e) {
      debugPrint('Start recording error: $e');
      _showSnack('Failed to start: $e', isError: true);
    }
  }

  Future<void> _stopRecording() async {
    if (_cam == null || !_isRecording) return;
    try {
      final xfile = await _cam!.stopVideoRecording();
      await _bg?.pause();
      _stopwatch.stop();

      _recordingDuration =
          DateTime.now().difference(_recordingStartTime ?? DateTime.now());

      // ✅ Add final keyframe at stop time
      if (_keyframeBaseTime != null) {
        final elapsed = _recordingDuration.inMilliseconds / 1000.0;
        _overlayKeyframes.add({
          'time': elapsed,
          'x': _overlayTopLeftPx.dx,
          'y': _overlayTopLeftPx.dy,
          'size': _overlaySizePx,
        });
      }

      // ✅ Snapshot before setState clears anything
      final keyframesSnapshot =
          List<Map<String, double>>.from(_overlayKeyframes);
      final startPos = _recordStartOverlayPos;
      final startSize = _recordStartOverlaySize;

      setState(() {
        _isRecording = false;
        _isProcessing = true;
      });

      if (_recordingDuration.inMilliseconds < 500) {
        throw Exception('Recording too short (< 0.5s)');
      }

      // Wait for file
      final cameraFile = File(xfile.path);
      int retry = 0;
      while (!await cameraFile.exists() && retry < 30) {
        await Future.delayed(const Duration(milliseconds: 200));
        retry++;
      }
      if (!await cameraFile.exists()) {
        throw Exception('Camera file not created');
      }

      if (!mounted) return;
      _showProcessingDialog();

      // Resolve background video path (needs local file for FFmpeg)
      String? bgPath = _bgVideoPath;
      if (bgPath != null && bgPath.startsWith('http')) {
        AppSettings.showLog('Downloading background for FFmpeg...');
        bgPath = await _downloadBackgroundVideo(bgPath);
      }

      if (bgPath == null || bgPath.isEmpty || !File(bgPath).existsSync()) {
        throw Exception('Background video not available for compositing');
      }

      // ---------- COMPOSITING ----------
      final outputPath = await VideoCompositor.compositeCameraOverlay(
        backgroundVideoPath: bgPath,
        cameraVideoPath: cameraFile.path,
        overlayPosition: _overlayTopLeftPx,
        overlaySize: _overlaySizePx,
        screenSize: MediaQuery.of(context).size,
        duration: _recordingDuration,
      );

      if (!mounted) return;
      Navigator.pop(context); // close processing dialog
      setState(() => _isProcessing = false);

      if (outputPath == null || !File(outputPath).existsSync()) {
        throw Exception('FFmpeg compositing failed');
      }

      _showSuccessDialog(outputPath);
    } catch (e) {
      AppSettings.showLog("GreenScreen stop record error: $e");
      if (_isProcessing && mounted) Navigator.pop(context);
      setState(() {
        _isProcessing = false;
        _isRecording = false;
      });
      if (!mounted) return;
      _showSnack('Recording failed: $e', isError: true);
    }
  }

  /// ✅ Save video to device gallery

  Future<void> _saveToGallery(String videoPath) async {
    _showLoadingDialog('Saving to gallery...');
    try {
      final file = File(videoPath);
      if (!file.existsSync()) throw Exception('File not found: $videoPath');

      // ── Request permission correctly per SDK version ──────────────────────
      if (Platform.isAndroid) {
        final info = await DeviceInfoPlugin().androidInfo;
        if (info.version.sdkInt >= 33) {
          final status = await Permission.videos.request();
          if (status.isPermanentlyDenied) {
            if (mounted && Navigator.canPop(context)) Navigator.pop(context);
            _showSnack('Permission denied — enable in Settings',
                isError: true);
            await openAppSettings();
            return;
          }
          // isGranted OR isDenied (not permanently) — Gal still works on
          // most Android 13 devices without explicit READ_MEDIA_VIDEO grant
          // because Gal uses MediaStore API internally
        } else if (info.version.sdkInt < 30) {
          final status = await Permission.storage.request();
          if (status.isDenied || status.isPermanentlyDenied) {
            if (mounted && Navigator.canPop(context)) Navigator.pop(context);
            _showSnack('Storage permission denied', isError: true);
            return;
          }
        }
        // Android 11-12: no permission needed for MediaStore write via Gal
      }

      // ── Save via Gal (uses MediaStore on Android) ─────────────────────────
      await Gal.putVideo(videoPath, album: 'GreenScreen');

      if (!mounted) return;
      if (Navigator.canPop(context)) Navigator.pop(context);
      _showSnack('Video saved to gallery', isSuccess: true);
    } catch (e) {
      debugPrint('Gallery save error: $e');
      if (mounted && Navigator.canPop(context)) Navigator.pop(context);

      // ── Fallback: copy to app documents folder ────────────────────────────
      try {
        final dir = await getApplicationDocumentsDirectory();
        final dest = Directory('${dir.path}/GreenScreen');
        if (!dest.existsSync()) await dest.create(recursive: true);
        final fileName =
            'greenscreen_${DateTime.now().millisecondsSinceEpoch}.mp4';
        await File(videoPath).copy('${dest.path}/$fileName');
        if (!mounted) return;
        _showSnack('Saved to app storage (GreenScreen/$fileName)',
            isSuccess: true);
      } catch (e2) {
        if (!mounted) return;
        _showSnack('Save failed: $e2', isError: true);
      }
    }
  }

  /// ✅ Navigate to upload page and handle result
  /// ✅ Navigate to upload page with thumbnail generation
  ///
  ///
  ///
  // ── Upload ──────────────────────────────────────────────────────────────────
  Future<void> _navigateToUpload(String videoPath) async {
    try {
      if (!File(videoPath).existsSync()) throw Exception('File not found');

      // Generate thumbnail
      try {
        final dir = await getApplicationDocumentsDirectory();
        await video_thumb.VideoThumbnail.thumbnailFile(
          video: videoPath,
          thumbnailPath: dir.path,
          imageFormat: video_thumb.ImageFormat.JPEG,
          maxWidth: 720,
          quality: 85,
        );
      } catch (_) {}

      if (!mounted) return;
      Navigator.pop(context); // close loading

      Get.put(UploadVideoController());
      Get.to(() => UploadVideoView(
            videoPath: videoPath,
            loginUserId: Database.loginUserId ?? "",
            loginUserChannelId: Database.channelId ?? "",
            videoType: 2, // Short
          ));
    } catch (e) {
      if (mounted && Navigator.canPop(context)) Navigator.pop(context);
      _showSnack('Error: $e', isError: true);
    }
  }

  // ── Dialogs ─────────────────────────────────────────────────────────────────
  void _showProcessingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Processing green screen video...'),
              SizedBox(height: 8),
              Text(
                'This may take a few moments',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSuccessDialog(String outputPath) {
    final sizeMb =
        (File(outputPath).lengthSync() / (1024 * 1024)).toStringAsFixed(2);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColor.secondDarkMode,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 28),
          const SizedBox(width: 8),
          Expanded(
            child: Text('Recording Complete!',
                style: GoogleFonts.urbanist(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Green screen video is ready.',
                style:
                    GoogleFonts.urbanist(color: Colors.white70, fontSize: 14)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(10)),
              child: Row(children: [
                const Icon(Icons.video_file,
                    color: Colors.greenAccent, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    outputPath.split('/').last,
                    style: GoogleFonts.urbanist(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 6),
            Text('Size: $sizeMb MB',
                style: GoogleFonts.urbanist(color: Colors.grey, fontSize: 12)),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () async {
              Navigator.pop(ctx);
              await _saveToGallery(outputPath);
            },
            icon: const Icon(Icons.download, color: Colors.greenAccent),
            label: Text('Save to Gallery',
                style: GoogleFonts.urbanist(color: Colors.greenAccent)),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primaryColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await _navigateToUpload(outputPath);
            },
            icon: const Icon(Icons.cloud_upload, color: Colors.white, size: 18),
            label: Text('Upload Short',
                style: GoogleFonts.urbanist(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showLoadingDialog(String msg) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColor.secondDarkMode,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Row(children: [
          const CircularProgressIndicator(color: Colors.green),
          const SizedBox(width: 16),
          Text(msg, style: GoogleFonts.urbanist(color: Colors.white)),
        ]),
      ),
    );
  }

  void _showSnack(String msg, {bool isError = false, bool isSuccess = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError
          ? Colors.red
          : isSuccess
              ? Colors.green
              : Colors.black87,
      duration: const Duration(seconds: 3),
    ));
  }

  /// ✅ Generate thumbnail from video file
  Future<String?> _generateVideoThumbnail(String videoPath) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final thumbnailPath = '${dir.path}/thumb_$timestamp.jpg';

      // Generate thumbnail using video_thumbnail package with prefix
      final thumbnail = await video_thumb.VideoThumbnail.thumbnailFile(
        video: videoPath,
        thumbnailPath: thumbnailPath,
        imageFormat: video_thumb.ImageFormat.JPEG, // ✅ Use prefix
        maxWidth: 720,
        quality: 85,
      );

      debugPrint('✅ Thumbnail generated: $thumbnail');
      return thumbnail;
    } catch (e) {
      debugPrint('❌ Thumbnail generation failed: $e');
      return null;
    }
  }

  // Future<void> uploadGreenScreenVideo(String path) async {
  //   final file = File(path);

  //   if (!await file.exists()) {
  //     throw Exception('Final video file does not exist');
  //   }

  //   // Save local copy
  //   final dir = await getApplicationDocumentsDirectory();
  //   final timestamp = DateTime.now().millisecondsSinceEpoch;
  //   final localCopyPath = '${dir.path}/greenscreen_$timestamp.mp4';
  //   await file.copy(localCopyPath);

  //   debugPrint('✅ Video saved locally at: $localCopyPath');

  //   final formData = FormData.fromMap({
  //     'video': await MultipartFile.fromFile(
  //       path,
  //       filename: file.path.split('/').last,
  //       contentType: MediaType('video', 'mp4'),
  //     ),
  //     if (Constant.userID != null) 'user_id': Constant.userID.toString(),
  //   });

  //   try {
  //     // ✅ Increase timeout for video uploads
  //     final response = await DioClient.instance.dio.post(
  //       '/upload/greenscreen-video',
  //       data: formData,
  //       options: Options(
  //         contentType: 'multipart/form-data',
  //         sendTimeout: const Duration(minutes: 5), // ✅ Added
  //         receiveTimeout: const Duration(minutes: 5), // ✅ Added
  //       ),
  //       onSendProgress: (sent, total) {
  //         final progress = (sent / total * 100).toStringAsFixed(1);
  //         debugPrint('Upload progress: $progress%');
  //       },
  //     );

  //     debugPrint('✅ Upload success: ${response.statusCode}');
  //   } on DioException catch (e) {
  //     debugPrint('❌ Upload failed: ${e.message}');
  //     debugPrint('Response: ${e.response?.data}');
  //     rethrow;
  //   }
  // }

  Future<void> _saveToDeviceStorage(String videoPath) async {
    try {
      final file = File(videoPath);
      if (!await file.exists()) {
        throw Exception('Video file not found');
      }

      // Show saving dialog
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Saving to gallery...'),
            ],
          ),
        ),
      );

      // ✅ Save to gallery using Gal package
      await Gal.putVideo(videoPath, album: 'GreenScreen');

      // Close loading dialog
      if (!mounted) return;
      Navigator.pop(context);

      // Show success
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Video saved to gallery'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      debugPrint('✅ Video saved to gallery: $videoPath');
    } catch (e) {
      debugPrint('❌ Save error: $e');

      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    if (_camReady && !_overlayInit) {
      _overlayInit = true;
      _overlaySizePx = size.width * 0.28;
      const m = 24.0;
      _overlayTopLeftPx = Offset(
        size.width - _overlaySizePx - m,
        size.height * 0.15,
      );
    }

    if (!_camReady) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title:
              const Text('Green Screen', style: TextStyle(color: Colors.white)),
        ),
        body: Stack(
          children: [
            Positioned.fill(
              child: _bgReady ? _buildBackgroundVideo() : _buildBackgroundPh(),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.videocam, size: 64, color: Colors.white54),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _initCamera,
                    icon: const Icon(Icons.video_call),
                    label: const Text('Start Green Screen'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Background video
            Positioned.fill(
              child: _bgReady ? _buildBackgroundVideo() : _buildBackgroundPh(),
            ),

            // Camera overlay
            _buildCameraOverlay(size),

            // Recording indicator
            if (_isRecording)
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'REC',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Control buttons
            Positioned(
              left: 16,
              right: 16,
              bottom: 24,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FloatingActionButton(
                    heroTag: null, // CHANGED: was 'close_btn'
                    backgroundColor: Colors.white24,
                    foregroundColor: Colors.white,
                    onPressed: _isRecording || _isProcessing
                        ? null
                        : () => Navigator.pop(context),
                    child: const Icon(Icons.close),
                  ),
                  FloatingActionButton(
                    heroTag: null, // CHANGED: was 'switch_btn'
                    backgroundColor: Colors.white24,
                    foregroundColor: Colors.white,
                    onPressed:
                        _isRecording || _isProcessing ? null : _switchCamera,
                    child: const Icon(Icons.cameraswitch),
                  ),
                  FloatingActionButton(
                    heroTag: null, // CHANGED: was 'rec_btn'
                    backgroundColor: _isRecording ? Colors.red : Colors.white,
                    foregroundColor: _isRecording ? Colors.white : Colors.red,
                    onPressed: _isProcessing
                        ? null
                        : () async {
                            if (_isRecording) {
                              await _stopRecording();
                            } else {
                              await _startRecording();
                            }
                          },
                    child: Icon(
                      _isRecording ? Icons.stop : Icons.fiber_manual_record,
                      size: 32,
                    ),
                  ),
                  FloatingActionButton(
                    heroTag: null, // CHANGED: was 'reset_btn'
                    backgroundColor: Colors.white24,
                    foregroundColor: Colors.white,
                    onPressed: _isRecording || _isProcessing
                        ? null
                        : () {
                            setState(() {
                              _overlaySizePx = size.width * 0.28;
                              const m = 24.0;
                              _overlayTopLeftPx = Offset(
                                size.width - _overlaySizePx - m,
                                size.height * 0.15,
                              );
                            });
                          },
                    child: const Icon(Icons.aspect_ratio),
                  ),
                ],
              ),
            ),

            // Instructions overlay
            if (!_isRecording && _camReady)
              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Drag to move • Pinch corner to resize • Tap record to start',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundVideo() {
    return FittedBox(
      fit: BoxFit.cover,
      child: SizedBox(
        width: _bg!.value.size.width,
        height: _bg!.value.size.height,
        child: VideoPlayer(_bg!),
      ),
    );
  }

  Widget _buildBackgroundPh() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.black, Colors.black87],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: Colors.white38),
      ),
    );
  }

  Widget _buildCameraOverlay(Size screenSize) {
    double clampX(double x, double w) => x.clamp(0.0, screenSize.width - w);
    double clampY(double y, double h) => y.clamp(0.0, screenSize.height - h);

    final left = clampX(_overlayTopLeftPx.dx, _overlaySizePx);
    final top = clampY(_overlayTopLeftPx.dy, _overlaySizePx);

    void recordKeyframe() {
      if (!_isRecording || _keyframeBaseTime == null) return;
      final elapsed =
          DateTime.now().difference(_keyframeBaseTime!).inMilliseconds / 1000.0;
      if (_overlayKeyframes.isNotEmpty &&
          elapsed - _overlayKeyframes.last['time']! < 0.05) return;
      _overlayKeyframes.add({
        'time': elapsed,
        'x': _overlayTopLeftPx.dx,
        'y': _overlayTopLeftPx.dy,
        'size': _overlaySizePx,
      });
    }

    return Positioned(
      left: left,
      top: top,
      width: _overlaySizePx,
      height: _overlaySizePx,
      child: GestureDetector(
        onPanUpdate: (d) {
          setState(() {
            _overlayTopLeftPx = Offset(
              clampX(_overlayTopLeftPx.dx + d.delta.dx, _overlaySizePx),
              clampY(_overlayTopLeftPx.dy + d.delta.dy, _overlaySizePx),
            );
          });
        },
        child: Stack(
          children: [
            // Camera preview
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: _isRecording ? Colors.red : Colors.white,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _isRecording ? Colors.red : Colors.white,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: SizedBox(
                  width: _overlaySizePx,
                  height: _overlaySizePx, // 🔒 Force perfect circle
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _isRecording ? Colors.red : Colors.white,
                        width: _isRecording ? 4 : 2,
                      ),
                      boxShadow: _isRecording
                          ? [
                              BoxShadow(
                                color: Colors.red.withOpacity(0.6),
                                blurRadius: 20,
                                spreadRadius: 4,
                              ),
                            ]
                          : [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.4),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                    ),
                    child: ClipOval(
                      child: _cam != null && _camReady
                          ? FittedBox(
                              fit: BoxFit.cover,
                              child: SizedBox(
                                width: _cam!.value.previewSize?.height ??
                                    _overlaySizePx,
                                height: _cam!.value.previewSize?.width ??
                                    _overlaySizePx,
                                child: CameraPreview(_cam!),
                              ),
                            )
                          : Container(
                              color: Colors.black,
                              alignment: Alignment.center,
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ),

            // Resize handle

            Positioned(
              right: 0,
              bottom: 0,
              child: GestureDetector(
                onPanUpdate: (d) {
                  setState(() {
                    final newSize = (_overlaySizePx + d.delta.dx).clamp(
                      screenSize.width * 0.15,
                      screenSize.width * 0.75,
                    );
                    _overlaySizePx = newSize;
                    _overlayTopLeftPx = Offset(
                      clampX(_overlayTopLeftPx.dx, _overlaySizePx),
                      clampY(_overlayTopLeftPx.dy, _overlaySizePx),
                    );
                  });
                },
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.open_in_full,
                    size: 18,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
