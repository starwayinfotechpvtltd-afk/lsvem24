import 'dart:async';
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
import 'package:metube/utils/settings/app_settings.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart' as video_thumb;
import 'package:google_mlkit_selfie_segmentation/google_mlkit_selfie_segmentation.dart';
import 'package:metube/utils/auth/auth_service.dart';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';

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
  String _maskMode = 'oval'; // 'oval' (AI Person Cutout - Normal Room), 'chroma' (Green Screen Sheet), 'circle' (Reaction)
  double _baseOverlaySize = 0;
  bool _isPinching = false;
  double _pinchScaleRatio = 1.0;

  // -- ML Kit Live Preview -----------------------------------------------------
  final SelfieSegmenter _segmenter = SelfieSegmenter(mode: SegmenterMode.stream, enableRawSizeMask: true);
  bool _isProcessingFrame = false;
  ui.Image? _liveMaskImage;

  // -- Timer -------------------------------------------------------------------
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _progressTimer;
  DateTime? _recordingStartTime;
  Duration _recordingDuration = Duration.zero;

  // -- Overlay snapshot & keyframe tracking ------------------------------------
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
    _progressTimer?.cancel();
    _segmenter.close();
    _bg?.removeListener(_onBgVideoListener);
    _bg?.pause();
    _bg?.dispose();
    _cam?.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _onBgVideoListener() {
    if (_bg == null || !_isRecording) return;

    final pos = _bg!.value.position;
    final duration = _bg!.value.duration;

    if (duration.inMilliseconds <= 0) return;

    if (_isRecording) {
      setState(() {
        _recordingDuration = _stopwatch.elapsed;
      });
    }

    if (pos.inMilliseconds >= duration.inMilliseconds - 200) {
      AppSettings.showLog(
          "🎬 BG short video ended -- auto-stopping green screen recording");

      _bg!.removeListener(_onBgVideoListener);
      _stopRecording();
    }
  }

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    if (_cam == null) return null;
    final camera = _cam!.description;
    final sensorOrientation = camera.sensorOrientation;
    final rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    if (rotation == null) return null;

    InputImageFormat? format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null) {
      if (Platform.isAndroid) {
        format = InputImageFormat.nv21;
      } else if (Platform.isIOS) {
        format = InputImageFormat.bgra8888;
      }
    }
    if (format == null || image.planes.isEmpty) return null;

    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: image.planes.first.bytesPerRow,
      ),
    );
  }

  void _cycleMaskMode() {
    setState(() {
      if (_maskMode == 'oval') {
        _maskMode = 'circle';
      } else if (_maskMode == 'circle') {
        _maskMode = 'chroma';
      } else {
        _maskMode = 'oval';
      }
    });

    final label = _maskMode == 'oval'
        ? 'AI Person Cutout (Normal Room - No Green Screen Needed)'
        : _maskMode == 'chroma'
            ? 'Chroma Green Screen Backdrop'
            : 'Reaction Circle';

    _showSnack('Mode: $label');
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

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

  Future<String?> _downloadBackgroundVideo(String url) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file =
          File('${dir.path}/bg_${DateTime.now().millisecondsSinceEpoch}.mp4');
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
        ResolutionPreset.veryHigh, // VeryHigh for crisp Full HD camera recording
        enableAudio: true,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await _cam!.initialize();
      if (!mounted) return;
      setState(() => _camReady = true);

      _startLivePreviewStream();
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

  void _startLivePreviewStream() {
    if (_cam == null || !_camReady || _isRecording) return;
    try {
      _cam!.startImageStream((image) async {
        if (_isProcessingFrame || _maskMode != 'oval') return;
        _isProcessingFrame = true;
        try {
          final inputImage = _inputImageFromCameraImage(image);
          if (inputImage != null) {
            final mask = await _segmenter.processImage(inputImage);
            if (mounted && mask != null) {
              // Convert mask confidences to a 32-bit RGBA Uint8List for fast decoding
              final maskW = mask.width;
              final maskH = mask.height;
              final confs = mask.confidences;
              final pixels = Uint8List(maskW * maskH * 4);
              int idx = 0;
              for (int i = 0; i < maskW * maskH; i++) {
                final conf = confs[i];
                int val = 0;
                if (conf >= 0.7) {
                  val = 255;
                } else if (conf > 0.3) {
                  val = ((conf - 0.3) / 0.4 * 255).round().clamp(0, 255);
                }
                pixels[idx++] = 255; // R
                pixels[idx++] = 255; // G
                pixels[idx++] = 255; // B
                pixels[idx++] = val; // A (Soft alpha blend)
              }
              ui.decodeImageFromPixels(
                pixels,
                maskW,
                maskH,
                ui.PixelFormat.rgba8888,
                (resultImage) {
                  if (mounted) {
                    setState(() {
                      _liveMaskImage = resultImage;
                    });
                  }
                },
              );
            }
          }
        } catch (e) {
          debugPrint('ML Segmenter live frame error: $e');
        } finally {
          _isProcessingFrame = false;
        }
      });
    } catch (e) {
      debugPrint('Failed to start live preview stream: $e');
    }
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
        ResolutionPreset.veryHigh,
        enableAudio: true,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await _cam!.initialize();
      if (!mounted) return;
      setState(() => _camReady = true);

      _startLivePreviewStream();
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
        final videos = await Permission.videos.request();
        await Permission.photos.request();
        return videos.isGranted;
      } else if (info.version.sdkInt >= 30) {
        return true;
      } else {
        final storage = await Permission.storage.request();
        return storage.isGranted;
      }
    } catch (e) {
      debugPrint('Storage permission error: $e');
      return true;
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

      if (_cam != null && _cam!.value.isStreamingImages) {
        try {
          await _cam!.stopImageStream();
        } catch (_) {}
      }

      await _cam!.startVideoRecording();
      _stopwatch
        ..reset()
        ..start();

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

      _progressTimer?.cancel();
      _progressTimer = Timer.periodic(const Duration(milliseconds: 50), (_) {
        if (mounted && _isRecording) {
          setState(() {
            _recordingDuration = _stopwatch.elapsed;
          });
        }
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
      _progressTimer?.cancel();
      final xfile = await _cam!.stopVideoRecording();
      await _bg?.pause();
      _stopwatch.stop();

      _recordingDuration =
          DateTime.now().difference(_recordingStartTime ?? DateTime.now());

      if (_keyframeBaseTime != null) {
        final elapsed = _recordingDuration.inMilliseconds / 1000.0;
        _overlayKeyframes.add({
          'time': elapsed,
          'x': _overlayTopLeftPx.dx,
          'y': _overlayTopLeftPx.dy,
          'size': _overlaySizePx,
        });
      }

      final keyframesSnapshot = List<Map<String, double>>.from(_overlayKeyframes);

      setState(() {
        _isRecording = false;
        _isProcessing = true;
      });

      if (_camReady && _cam != null) {
        _startLivePreviewStream();
      }

      if (_recordingDuration.inMilliseconds < 200) {
        throw Exception('Recording too short (< 0.2s)');
      }

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
      final currentScreenSize = MediaQuery.of(context).size;
      _showProcessingDialog();

      String? bgPath = _bgVideoPath;
      if (bgPath != null && bgPath.startsWith('http')) {
        AppSettings.showLog('Downloading background for FFmpeg...');
        bgPath = await _downloadBackgroundVideo(bgPath);
      }

      if (bgPath == null || bgPath.isEmpty || !File(bgPath).existsSync()) {
        throw Exception('Background video not available for compositing');
      }

      // ---------- COMPOSITING WITH KEYFRAMED MOVEMENT & AI PERSON SEGMENTATION ----------
      final outputPath = await VideoCompositor.compositeCameraOverlay(
        backgroundVideoPath: bgPath,
        cameraVideoPath: cameraFile.path,
        overlayPosition: _overlayTopLeftPx,
        overlaySize: _overlaySizePx,
        screenSize: currentScreenSize,
        duration: _recordingDuration,
        maskMode: _maskMode,
        keyframes: keyframesSnapshot,
      );

      if (!mounted) return;
      Navigator.pop(context);
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

  Future<void> _saveToGallery(String videoPath) async {
    _showLoadingDialog('Saving to gallery...');
    try {
      final file = File(videoPath);
      if (!file.existsSync()) throw Exception('File not found: $videoPath');

      if (Platform.isAndroid) {
        final info = await DeviceInfoPlugin().androidInfo;
        if (info.version.sdkInt >= 33) {
          final status = await Permission.videos.request();
          if (status.isPermanentlyDenied) {
            if (mounted && Navigator.canPop(context)) Navigator.pop(context);
            _showSnack('Permission denied -- enable in Settings',
                isError: true);
            await openAppSettings();
            return;
          }
        } else if (info.version.sdkInt < 30) {
          final status = await Permission.storage.request();
          if (status.isDenied || status.isPermanentlyDenied) {
            if (mounted && Navigator.canPop(context)) Navigator.pop(context);
            _showSnack('Storage permission denied', isError: true);
            return;
          }
        }
      }

      await Gal.putVideo(videoPath, album: 'GreenScreen');

      if (!mounted) return;
      if (Navigator.canPop(context)) Navigator.pop(context);
      _showSnack('Video saved to gallery', isSuccess: true);
    } catch (e) {
      debugPrint('Gallery save error: $e');
      if (mounted && Navigator.canPop(context)) Navigator.pop(context);

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

  Future<void> _navigateToUpload(String videoPath) async {
    try {
      if (!File(videoPath).existsSync()) throw Exception('File not found');

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
      Navigator.pop(context);

      Get.put(UploadVideoController());
      Get.to(() => UploadVideoView(
            videoPath: videoPath,
            loginUserId: Database.loginUserId ?? "",
            loginUserChannelId: Database.channelId ?? "",
            videoType: 2,
          ));
    } catch (e) {
      if (mounted && Navigator.canPop(context)) Navigator.pop(context);
      _showSnack('Error: $e', isError: true);
    }
  }

  void _showProcessingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          backgroundColor: const Color(0xFF181818),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Compositing LSVEM24 Short...',
                style: GoogleFonts.urbanist(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              // const SizedBox(height: 8),
              // Text(
              //   'Rendering high quality 1080p video with camera movement',
              //   style: GoogleFonts.urbanist(fontSize: 12, color: Colors.grey),
              //   textAlign: TextAlign.center,
              // ),
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
        backgroundColor: const Color(0xFF181818),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 28),
          const SizedBox(width: 8),
          Expanded(
            child: Text('Short Recording Ready!',
                style: GoogleFonts.urbanist(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your face reaction short is rendered in 1080p.',
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
                    color: Colors.redAccent, size: 20),
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
              if (!AuthService.checkLogin()) return;
              Navigator.pop(ctx);
              await _saveToGallery(outputPath);
            },
            icon: const Icon(Icons.download, color: Colors.white),
            label: Text('Save Gallery',
                style: GoogleFonts.urbanist(color: Colors.white)),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await _navigateToUpload(outputPath);
            },
            icon: const Icon(Icons.cloud_upload, color: Colors.white, size: 18),
            label: Text('Upload Short',
                style: GoogleFonts.urbanist(color: Colors.white, fontWeight: FontWeight.bold)),
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
        backgroundColor: const Color(0xFF181818),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Row(children: [
          const CircularProgressIndicator(color: Colors.red),
          const SizedBox(width: 16),
          Text(msg, style: GoogleFonts.urbanist(color: Colors.white)),
        ]),
      ),
    );
  }

  void _showSnack(String msg, {bool isError = false, bool isSuccess = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.urbanist(color: Colors.white)),
      backgroundColor: isError
          ? Colors.red
          : isSuccess
              ? Colors.green
              : Colors.black87,
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    if (_camReady && !_overlayInit) {
      _overlayInit = true;
      _overlaySizePx = size.width * 0.32;
      const m = 20.0;
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
          title: Text('YouTube Green Screen',
              style: GoogleFonts.urbanist(color: Colors.white, fontWeight: FontWeight.bold)),
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
                    label: Text('Enable Camera',
                        style: GoogleFonts.urbanist(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
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
            // Background Video Stream
            Positioned.fill(
              child: _bgReady ? _buildBackgroundVideo() : _buildBackgroundPh(),
            ),

            // Camera Overlay with Two-Finger Pinch & Drag
            _buildCameraOverlay(size),

            // YouTube Shorts Top Bar
            _buildYouTubeHeader(),

            // YouTube Shorts Progress Bar
            _buildYouTubeProgressBar(size),

            // YouTube Shorts Right Action Toolbar
            _buildYouTubeRightToolbar(),

            // YouTube Shorts Bottom Record Bar
            _buildYouTubeBottomBar(),
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

  Widget _buildYouTubeProgressBar(Size size) {
    final maxMs = _bg != null && _bg!.value.isInitialized && _bg!.value.duration.inMilliseconds > 0
        ? _bg!.value.duration.inMilliseconds
        : 60000;
    final progressRatio = (_recordingDuration.inMilliseconds / maxMs).clamp(0.0, 1.0);

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 4,
        color: Colors.white24,
        child: Align(
          alignment: Alignment.centerLeft,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 50),
            width: size.width * progressRatio,
            decoration: const BoxDecoration(
              color: Colors.red,
              boxShadow: [
                BoxShadow(color: Colors.redAccent, blurRadius: 6),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildYouTubeHeader() {
    return Positioned(
      top: 4,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black.withOpacity(0.75), Colors.transparent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Close Button
            GestureDetector(
              onTap: _isRecording || _isProcessing ? null : () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
              ),
            ),

            // Title / Live Timer Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: _isRecording ? Colors.red.withOpacity(0.9) : Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _isRecording ? Colors.redAccent : Colors.white.withOpacity(0.25),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isRecording ? Icons.fiber_manual_record : Icons.videocam_rounded,
                    color: Colors.white,
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _isRecording
                        ? 'REC ${_formatDuration(_recordingDuration)}'
                        : 'Green Screen',
                    style: GoogleFonts.urbanist(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildYouTubeRightToolbar() {
    return Positioned(
      right: 16,
      top: 90,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 12,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Switch Camera
            _buildToolbarIconButton(
              icon: Icons.flip_camera_ios_rounded,
              label: 'Flip',
              onTap: _isRecording || _isProcessing ? null : _switchCamera,
            ),
            const SizedBox(height: 16),

            // Face Fit Mask Switcher
            _buildToolbarIconButton(
              icon: _maskMode == 'oval'
                  ? Icons.face_retouching_natural_rounded
                  : _maskMode == 'circle'
                      ? Icons.circle_outlined
                      : Icons.auto_fix_high_rounded,
              label: _maskMode == 'oval' ? 'Face Fit' : _maskMode == 'circle' ? 'Circle' : 'Chroma',
              onTap: _isRecording || _isProcessing ? null : _cycleMaskMode,
            ),
            const SizedBox(height: 16),

            // Reset Size & Position
            _buildToolbarIconButton(
              icon: Icons.restart_alt_rounded,
              label: 'Reset',
              onTap: _isRecording || _isProcessing
                  ? null
                  : () {
                      final size = MediaQuery.of(context).size;
                      setState(() {
                        _overlaySizePx = size.width * 0.32;
                        const m = 20.0;
                        _overlayTopLeftPx = Offset(
                          size.width - _overlaySizePx - m,
                          size.height * 0.15,
                        );
                        _maskMode = 'oval';
                      });
                      _showSnack('Reset face size & position');
                    },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolbarIconButton({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(6),
        child: Column(
          children: [
            Icon(icon, color: onTap == null ? Colors.white38 : Colors.white, size: 24),
            const SizedBox(height: 3),
            Text(
              label,
              style: GoogleFonts.urbanist(
                color: onTap == null ? Colors.white38 : Colors.white70,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildYouTubeBottomBar() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.only(bottom: 24, top: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.transparent, Colors.black.withOpacity(0.85)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Instruction Banner
            if (!_isRecording)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.65),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.15)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.pinch_rounded, color: Colors.white70, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'Pinch with 2 fingers to scale face • Drag to reposition',
                      style: GoogleFonts.urbanist(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

            // Record Button (YouTube Red Circle / Stop Square)
            GestureDetector(
              onTap: _isProcessing
                  ? null
                  : () async {
                      if (_isRecording) {
                        await _stopRecording();
                      } else {
                        await _startRecording();
                      }
                    },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: _isRecording ? 80 : 74,
                    height: _isRecording ? 80 : 74,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.red,
                        width: _isRecording ? 4 : 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(_isRecording ? 0.6 : 0.25),
                          blurRadius: _isRecording ? 20 : 10,
                          spreadRadius: _isRecording ? 4 : 1,
                        ),
                      ],
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: _isRecording ? 30 : 56,
                    height: _isRecording ? 30 : 56,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(_isRecording ? 8 : 28),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaskedCameraPreview() {
    if (_maskMode == 'oval' && _liveMaskImage != null) {
      final isFront = _cam?.description.lensDirection == CameraLensDirection.front;
      return ShaderMask(
        blendMode: BlendMode.dstIn,
        shaderCallback: (Rect bounds) {
          final Matrix4 matrix = Matrix4.identity();
          final double imgW = _liveMaskImage!.width.toDouble();
          final double imgH = _liveMaskImage!.height.toDouble();
          
          if (isFront) {
            matrix.translate(bounds.width, 0.0);
            matrix.scale(-bounds.width / imgW, bounds.height / imgH);
          } else {
            matrix.scale(bounds.width / imgW, bounds.height / imgH);
          }

          return ImageShader(
            _liveMaskImage!,
            TileMode.clamp,
            TileMode.clamp,
            matrix.storage,
          );
        },
        child: CameraPreview(_cam!),
      );
    }
    return CameraPreview(_cam!);
  }

  Widget _buildCameraOverlay(Size screenSize) {
    double clampX(double x, double w) => x.clamp(0.0, screenSize.width - w);
    double clampY(double y, double h) => y.clamp(0.0, screenSize.height - h);

    final overlayW = _overlaySizePx;
    final overlayH = _maskMode == 'oval' ? _overlaySizePx * 1.25 : _overlaySizePx;

    final left = clampX(_overlayTopLeftPx.dx, overlayW);
    final top = clampY(_overlayTopLeftPx.dy, overlayH);

    void recordKeyframe() {
      if (!_isRecording || _keyframeBaseTime == null) return;
      final elapsed =
          DateTime.now().difference(_keyframeBaseTime!).inMilliseconds / 1000.0;
      if (_overlayKeyframes.isNotEmpty &&
          elapsed - _overlayKeyframes.last['time']! < 0.04) return;
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
      width: overlayW,
      height: overlayH,
      child: GestureDetector(
        onScaleStart: (details) {
          _baseOverlaySize = _overlaySizePx;
          setState(() {
            _isPinching = true;
          });
        },
        onScaleUpdate: (details) {
          setState(() {
            // ✅ Two-finger pinch to adjust face size (check scale threshold > 1%)
            if ((details.scale - 1.0).abs() > 0.01) {
              final newSize = (_baseOverlaySize * details.scale).clamp(
                screenSize.width * 0.18,
                screenSize.width * 0.85,
              );
              final sizeDiff = newSize - _overlaySizePx;
              _overlaySizePx = newSize;
              _pinchScaleRatio = newSize / (screenSize.width * 0.32);

              final currentW = newSize;
              final currentH = _maskMode == 'oval' ? newSize * 1.25 : newSize;

              // Center-pivot adjustment
              _overlayTopLeftPx = Offset(
                clampX(_overlayTopLeftPx.dx - (sizeDiff / 2), currentW),
                clampY(_overlayTopLeftPx.dy - (sizeDiff / 2), currentH),
              );
            } else if (details.focalPointDelta != Offset.zero) {
              // ✅ Drag / Pan repositioning
              final currentW = _overlaySizePx;
              final currentH = _maskMode == 'oval' ? _overlaySizePx * 1.25 : _overlaySizePx;
              _overlayTopLeftPx = Offset(
                clampX(_overlayTopLeftPx.dx + details.focalPointDelta.dx, currentW),
                clampY(_overlayTopLeftPx.dy + details.focalPointDelta.dy, currentH),
              );
            }
          });
          recordKeyframe();
        },
        onScaleEnd: (details) {
          setState(() {
            _isPinching = false;
          });
        },
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Pinch scale ratio pill indicator
            if (_isPinching)
              Positioned(
                top: -34,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red, width: 1),
                    ),
                    child: Text(
                      'Face Size: ${(_pinchScaleRatio * 100).round()}%',
                      style: GoogleFonts.urbanist(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),

            // Camera preview container face fit
            Container(
              decoration: _maskMode == 'oval'
                  ? null
                  : BoxDecoration(
                      borderRadius: _maskMode == 'circle'
                          ? null
                          : BorderRadius.circular(overlayW / 2),
                      shape: _maskMode == 'circle' ? BoxShape.circle : BoxShape.rectangle,
                      border: Border.all(
                        color: _isRecording ? Colors.red : Colors.white.withOpacity(0.9),
                        width: _isRecording ? 3.5 : 2.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _isRecording ? Colors.red.withOpacity(0.5) : Colors.black45,
                          blurRadius: _isRecording ? 16 : 10,
                          spreadRadius: _isRecording ? 3 : 1,
                        ),
                      ],
                    ),
              child: ClipRRect(
                borderRadius: _maskMode == 'oval'
                    ? BorderRadius.zero
                    : BorderRadius.circular(_maskMode == 'circle' ? overlayW : overlayW / 2),
                child: _cam != null && _camReady
                    ? ColorFiltered(
                        colorFilter: _maskMode == 'chroma'
                            ? const ColorFilter.matrix([
                                1, 0, 0, 0, 0,
                                0, 1, 0, 0, 0,
                                0, 0, 1, 0, 0,
                                -0.2, 0.8, -0.2, 1, 0,
                              ])
                            : const ColorFilter.mode(Colors.transparent, BlendMode.dst),
                        child: FittedBox(
                          fit: BoxFit.cover,
                          alignment: Alignment.topCenter,
                          child: SizedBox(
                            width: _cam!.value.previewSize?.height ?? overlayW,
                            height: _cam!.value.previewSize?.width ?? overlayH,
                            child: _buildMaskedCameraPreview(),
                          ),
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
          ],
        ),
      ),
    );
  }
}
