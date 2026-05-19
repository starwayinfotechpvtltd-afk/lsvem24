// import 'dart:io';
// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:video_player/video_player.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:provider/provider.dart';
// import 'package:yourappname/provider/shortprovider.dart';
// import 'package:metube/utils/constant/app_constant.dart';
// import './video_compositor.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:dio/dio.dart';
// import 'package:http_parser/http_parser.dart';
// import 'package:yourappname/webservice/dioclient.dart';
// import 'package:flutter/services.dart';
// import 'package:device_info_plus/device_info_plus.dart';
// import 'package:yourappname/reels/uploadshort.dart';
// import 'package:video_thumbnail/video_thumbnail.dart' as video_thumb;
// import 'package:gal/gal.dart';

// class ReelGreenScreen extends StatefulWidget {
//   final String content;

//   const ReelGreenScreen({super.key, required this.content});

//   @override
//   State<ReelGreenScreen> createState() => _ReelGreenScreenState();
// }

// class _ReelGreenScreenState extends State<ReelGreenScreen>
//     with WidgetsBindingObserver {
//   CameraController? _cam;
//   bool _camReady = false;
//   bool _isRecording = false;
//   bool _isProcessing = false;

//   VideoPlayerController? _bg;
//   bool _bgReady = false;
//   String? _bgVideoPath;

//   bool _overlayInit = false;
//   Offset _overlayTopLeftPx = const Offset(0, 0);
//   double _overlaySizePx = 0;

//   // Recording tracking
//   DateTime? _recordingStartTime;
//   Duration _recordingDuration = Duration.zero;

//   @override
//   void initState() {
//     super.initState();
//     debugPrint('ReelGreenScreen initState contentId=${widget.content}');
//     WidgetsBinding.instance.addObserver(this);

//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       await _requestStoragePermission();
//       _loadBackgroundVideo();
//     });
//   }

//   @override
//   void dispose() {
//     _bg?.pause();
//     _bg?.dispose();
//     _cam?.dispose();
//     WidgetsBinding.instance.removeObserver(this);
//     super.dispose();
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     final controller = _cam;
//     if (controller == null || !controller.value.isInitialized) return;

//     if (state == AppLifecycleState.inactive ||
//         state == AppLifecycleState.paused) {
//       controller.pausePreview();
//       _bg?.pause();
//     } else if (state == AppLifecycleState.resumed) {
//       controller.resumePreview();
//       if (_isRecording) _bg?.play();
//     }
//   }

//   Future<void> _loadBackgroundVideo() async {
//     try {
//       debugPrint('Loading background video directly: ${widget.content}');

//       if (widget.content.isEmpty) {
//         debugPrint('Empty content URL');
//         return;
//       }

//       // ✅ IMPORTANT: Save background source
//       _bgVideoPath = widget.content;

//       await _initBackgroundPlayerFromUrl(widget.content);
//     } catch (e, stackTrace) {
//       debugPrint('Error loading background video: $e');
//       debugPrint('StackTrace: $stackTrace');
//     }
//   }

// // Add this method for network URLs
//   Future<void> _initBackgroundPlayerFromUrl(String url) async {
//     try {
//       debugPrint('Initializing video player from URL: $url');

//       // ✅ VideoPlayerController handles the network request automatically
//       _bg = VideoPlayerController.networkUrl(Uri.parse(url));

//       await _bg!.initialize();
//       _bg!.setLooping(true);
//       await _bg!.setVolume(0.3);

//       if (!mounted) return;
//       setState(() => _bgReady = true);

//       debugPrint('✅ Video player initialized successfully');
//     } catch (e) {
//       debugPrint('❌ Background player init error: $e');

//       if (!mounted) return;

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to load video: $e')),
//       );

//       _bgVideoPath = 'camera_only';
//       setState(() => _bgReady = false);
//     }
//   }

//   Future<String?> _downloadBackgroundVideo(String url) async {
//     try {
//       final dir = await getApplicationDocumentsDirectory();
//       final file =
//           File('${dir.path}/bg_${DateTime.now().millisecondsSinceEpoch}.mp4');

//       final dio = Dio();
//       await dio.download(url, file.path);

//       if (!await file.exists()) {
//         return null;
//       }

//       return file.path;
//     } catch (e) {
//       debugPrint('❌ Background download error: $e');
//       return null;
//     }
//   }

//   Future<void> _initCamera() async {
//     try {
//       // Request permissions
//       final camPerm = await Permission.camera.request();
//       final micPerm = await Permission.microphone.request();

//       if (camPerm.isPermanentlyDenied || micPerm.isPermanentlyDenied) {
//         if (!mounted) return;
//         final shouldOpen = await _showPermissionDialog();
//         if (shouldOpen) await openAppSettings();
//         return;
//       }

//       if (camPerm != PermissionStatus.granted ||
//           micPerm != PermissionStatus.granted) {
//         if (!mounted) return;
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Camera/Mic permission required')),
//         );
//         return;
//       }

//       final cameras = await availableCameras();
//       if (cameras.isEmpty) throw Exception('No cameras available');

//       final front = cameras.firstWhere(
//         (c) => c.lensDirection == CameraLensDirection.front,
//         orElse: () => cameras.first,
//       );

//       _cam = CameraController(
//         front,
//         ResolutionPreset.high,
//         enableAudio: true,
//         imageFormatGroup: ImageFormatGroup.yuv420,
//       );

//       await _cam!.initialize();
//       if (!mounted) return;
//       setState(() => _camReady = true);
//     } catch (e) {
//       debugPrint('Camera init error: $e');
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Camera init failed: $e')),
//       );
//     }
//   }

//   Future<bool> _showPermissionDialog() async {
//     return await showDialog<bool>(
//           context: context,
//           builder: (context) => AlertDialog(
//             title: const Text('Permission Required'),
//             content: const Text(
//               'Camera and microphone permissions are required for green screen recording. '
//               'Please enable them in settings.',
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context, false),
//                 child: const Text('Cancel'),
//               ),
//               TextButton(
//                 onPressed: () => Navigator.pop(context, true),
//                 child: const Text('Open Settings'),
//               ),
//             ],
//           ),
//         ) ??
//         false;
//   }

//   Future<void> _switchCamera() async {
//     if (_isRecording) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Stop recording before switching camera')),
//       );
//       return;
//     }

//     try {
//       final cameras = await availableCameras();
//       if (_cam == null || cameras.isEmpty) return;

//       final current = _cam!.description;
//       final targetLens = current.lensDirection == CameraLensDirection.front
//           ? CameraLensDirection.back
//           : CameraLensDirection.front;

//       final target = cameras.firstWhere(
//         (c) => c.lensDirection == targetLens,
//         orElse: () => cameras.first,
//       );

//       await _cam!.dispose();
//       _cam = CameraController(
//         target,
//         ResolutionPreset.high,
//         enableAudio: true,
//         imageFormatGroup: ImageFormatGroup.yuv420,
//       );

//       await _cam!.initialize();
//       if (!mounted) return;
//       setState(() => _camReady = true);
//     } catch (e) {
//       debugPrint('Switch camera error: $e');
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to switch camera: $e')),
//       );
//     }
//   }

//   Future<bool> _requestStoragePermission() async {
//     try {
//       final deviceInfo = DeviceInfoPlugin();
//       final androidInfo = await deviceInfo.androidInfo;

//       if (androidInfo.version.sdkInt >= 33) {
//         // Android 13+ (API 33+)
//         final photos = await Permission.photos.request();
//         final videos = await Permission.videos.request();
//         return photos.isGranted && videos.isGranted;
//       } else {
//         // Android 12 and below
//         final storage = await Permission.storage.request();
//         return storage.isGranted;
//       }
//     } catch (e) {
//       debugPrint('Storage permission error: $e');
//       return false;
//     }
//   }

//   Future<void> _initBackgroundPlayer(String path) async {
//     try {
//       _bg = VideoPlayerController.file(File(path));
//       await _bg!.initialize();
//       _bg!.setLooping(true);
//       await _bg!.setVolume(0.3); // Lower background volume
//       if (!mounted) return;
//       setState(() => _bgReady = true);
//     } catch (e) {
//       debugPrint('Background player init error: $e');
//     }
//   }

//   Future<void> _startRecording() async {
//     if (_cam == null || _isRecording) return;

//     try {
//       // Start background if available
//       if (_bgReady && _bg != null) {
//         await _bg?.seekTo(Duration.zero);
//         await _bg?.play();
//         await Future.delayed(const Duration(milliseconds: 100));
//       }

//       await _cam!.startVideoRecording();

//       setState(() {
//         _isRecording = true;
//         _recordingStartTime = DateTime.now();
//       });

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(_bgReady
//               ? 'Recording started'
//               : 'Recording camera only (no background)'),
//           duration: const Duration(seconds: 2),
//         ),
//       );
//     } catch (e) {
//       debugPrint('Start recording error: $e');
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to start recording: $e')),
//       );
//     }
//   }

//   Future<void> _stopRecording() async {
//     if (_cam == null || !_isRecording) return;

//     try {
//       // ✅ REQUEST STORAGE PERMISSION FIRST
//       final hasPermission = await _requestStoragePermission();
//       if (!hasPermission) {
//         throw Exception('Storage permission denied');
//       }

//       final xfile = await _cam!.stopVideoRecording();
//       await _bg?.pause();

//       // Ensure camera file exists
//       final recordedFile = File(xfile.path);
//       int retry = 0;
//       const maxRetries = 30;
//       while (!await recordedFile.exists() && retry < maxRetries) {
//         await Future.delayed(const Duration(milliseconds: 200));
//         retry++;
//         debugPrint('Waiting for camera file... attempt $retry/$maxRetries');
//       }

//       if (!await recordedFile.exists()) {
//         throw Exception(
//             'Camera video file not created after ${maxRetries * 200}ms');
//       }

//       setState(() {
//         _isRecording = false;
//         _isProcessing = true;
//         _recordingDuration =
//             DateTime.now().difference(_recordingStartTime ?? DateTime.now());
//       });

//       if (_recordingDuration.inMilliseconds < 500) {
//         throw Exception('Recording too short');
//       }

//       if (!mounted) return;
//       _showProcessingDialog();

//       // ---------- BACKGROUND VIDEO HANDLING ----------
//       String? bgPath;

//       if (_bgReady && _bgVideoPath != null && _bgVideoPath!.isNotEmpty) {
//         if (_bgVideoPath!.startsWith('http')) {
//           debugPrint('Downloading background video...');
//           bgPath = await _downloadBackgroundVideo(_bgVideoPath!);
//           if (bgPath == null || !File(bgPath).existsSync()) {
//             throw Exception('Background video download failed');
//           }
//         } else {
//           bgPath = _bgVideoPath;
//         }
//       }

//       if (bgPath == null || bgPath.isEmpty) {
//         throw Exception('Background video missing');
//       }

//       // ---------- COMPOSITING ----------
//       final outputPath = await VideoCompositor.compositeCameraOverlay(
//         backgroundVideoPath: bgPath,
//         cameraVideoPath: recordedFile.path,
//         overlayPosition: _overlayTopLeftPx,
//         overlaySize: _overlaySizePx,
//         screenSize: MediaQuery.of(context).size,
//         duration: _recordingDuration,
//       );

//       Navigator.pop(context); // Close processing dialog
//       setState(() => _isProcessing = false);

//       if (outputPath == null || !File(outputPath).existsSync()) {
//         throw Exception('Green screen video creation failed');
//       }

//       // ✅ Save to device storage (gallery)
//       // await _saveToGallery(outputPath);

//       // ✅ Show success dialog with options
//       if (!mounted) return;
//       _showSuccessDialogWithOptions(outputPath);
//     } catch (e) {
//       debugPrint('❌ Stop recording error: $e');

//       if (_isProcessing && mounted) {
//         Navigator.pop(context);
//       }

//       setState(() {
//         _isProcessing = false;
//         _isRecording = false;
//       });

//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Recording failed: $e')),
//       );
//     }
//   }

//   /// ✅ Save video to device gallery
//   Future<void> _saveToGallery(String videoPath) async {
//     try {
//       final file = File(videoPath);
//       if (!await file.exists()) {
//         debugPrint('❌ Video file does not exist for gallery save');
//         return;
//       }

//       if (Platform.isAndroid) {
//         final deviceInfo = DeviceInfoPlugin();
//         final androidInfo = await deviceInfo.androidInfo;
//         final timestamp = DateTime.now().millisecondsSinceEpoch;

//         if (androidInfo.version.sdkInt >= 30) {
//           // Android 11+ - Use app-specific directory (visible in gallery)
//           final appDir = await getApplicationDocumentsDirectory();
//           final galleryDir = Directory('${appDir.path}/GreenScreen');

//           if (!await galleryDir.exists()) {
//             await galleryDir.create(recursive: true);
//           }

//           final savedPath = '${galleryDir.path}/greenscreen_$timestamp.mp4';
//           await file.copy(savedPath);
//           debugPrint('✅ Video saved to: $savedPath');
//         } else {
//           // Android 10 and below - Save to DCIM
//           final dcimDir = Directory('/storage/emulated/0/DCIM/GreenScreen');

//           if (!await dcimDir.exists()) {
//             await dcimDir.create(recursive: true);
//           }

//           final savedPath = '${dcimDir.path}/greenscreen_$timestamp.mp4';
//           await file.copy(savedPath);
//           debugPrint('✅ Video saved to gallery: $savedPath');
//         }
//       } else if (Platform.isIOS) {
//         // iOS - Save to app documents
//         final appDir = await getApplicationDocumentsDirectory();
//         final timestamp = DateTime.now().millisecondsSinceEpoch;
//         final savedPath = '${appDir.path}/greenscreen_$timestamp.mp4';
//         await file.copy(savedPath);
//         debugPrint('✅ Video saved to: $savedPath');
//       }
//     } catch (e) {
//       debugPrint('❌ Save to gallery error: $e');
//     }
//   }

//   /// ✅ Show success dialog with upload option
//   void _showSuccessDialogWithOptions(String outputPath) {
//   showDialog(
//     context: context,
//     barrierDismissible: false,
//     builder: (context) => AlertDialog(
//       title: Row(
//         children: [
//           Icon(Icons.check_circle, color: Colors.green, size: 28),
//           SizedBox(width: 8),
//           Text('Success!'),
//         ],
//       ),
//       content: Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Your green screen video has been created and saved!',
//             style: TextStyle(fontSize: 15),
//           ),
//           const SizedBox(height: 12),
//           Container(
//             padding: EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: Colors.grey[200],
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Row(
//               children: [
//                 Icon(Icons.video_file, color: Colors.blue, size: 20),
//                 SizedBox(width: 8),
//                 Expanded(
//                   child: Text(
//                     outputPath.split('/').last,
//                     style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'File size: ${(File(outputPath).lengthSync() / (1024 * 1024)).toStringAsFixed(2)} MB',
//             style: TextStyle(fontSize: 12, color: Colors.grey[600]),
//           ),
//         ],
//       ),
//       actions: [
//         TextButton(
//           onPressed: () async {
//             // ✅ Save to device storage before closing
//             await _saveToDeviceStorage(outputPath);
            
//             if (!mounted) return;
//             Navigator.pop(context); // Close dialog
//             Navigator.pop(context); // Close green screen page
//           },
//           child: const Text('Done'),
//         ),
//         ElevatedButton.icon(
//           onPressed: () async {
//             Navigator.pop(context); // Close dialog

//             // ✅ Navigate to upload page with video path
//             await _navigateToUploadPage(outputPath);
//           },
//           icon: Icon(Icons.cloud_upload),
//           label: const Text('Upload'),
//           style: ElevatedButton.styleFrom(
//             backgroundColor: Colors.blue,
//             foregroundColor: Colors.white,
//           ),
//         ),
//       ],
//     ),
//   );
// }


//   /// ✅ Navigate to upload page and handle result
//   /// ✅ Navigate to upload page with thumbnail generation
//   Future<void> _navigateToUploadPage(String videoPath) async {
//     try {
//       final videoFile = File(videoPath);

//       // Verify video file exists
//       if (!await videoFile.exists()) {
//         throw Exception('Video file not found');
//       }

//       // Show loading while generating thumbnail
//       if (!mounted) return;
//       showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (context) => const AlertDialog(
//           content: Row(
//             children: [
//               CircularProgressIndicator(),
//               SizedBox(width: 16),
//               Text('Preparing upload...'),
//             ],
//           ),
//         ),
//       );

//       // Generate thumbnail from video
//       File? coverImageFile;
//       try {
//         final thumbnailPath = await _generateVideoThumbnail(videoPath);
//         if (thumbnailPath != null) {
//           coverImageFile = File(thumbnailPath);
//         }
//       } catch (e) {
//         debugPrint('❌ Thumbnail generation error: $e');
//       }

//       // Close loading dialog
//       if (!mounted) return;
//       Navigator.pop(context);

//       // If thumbnail generation failed, show error
//       if (coverImageFile == null || !await coverImageFile.exists()) {
//         if (!mounted) return;
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content:
//                 Text('Failed to generate video thumbnail. Please try again.'),
//             backgroundColor: Colors.red,
//           ),
//         );
//         return;
//       }

//       // Navigate to UploadShort page
//       if (!mounted) return;
//       final result = await Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => UploadShort(
//             videoFile: videoFile,
//             videoImageFile: coverImageFile!,
//           ),
//         ),
//       );

//       // Handle result
//       if (!mounted) return;

//       if (result == true || result == 'success') {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('✅ Green screen video uploaded successfully!'),
//             backgroundColor: Colors.green,
//             duration: Duration(seconds: 2),
//           ),
//         );

//         // Return to home or previous screen
//         Navigator.pop(context);
//       }
//     } catch (e) {
//       debugPrint('❌ Navigation error: $e');

//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Error: $e'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   /// ✅ Generate thumbnail from video file
//   Future<String?> _generateVideoThumbnail(String videoPath) async {
//     try {
//       final dir = await getApplicationDocumentsDirectory();
//       final timestamp = DateTime.now().millisecondsSinceEpoch;
//       final thumbnailPath = '${dir.path}/thumb_$timestamp.jpg';

//       // Generate thumbnail using video_thumbnail package with prefix
//       final thumbnail = await video_thumb.VideoThumbnail.thumbnailFile(
//         video: videoPath,
//         thumbnailPath: thumbnailPath,
//         imageFormat: video_thumb.ImageFormat.JPEG, // ✅ Use prefix
//         maxWidth: 720,
//         quality: 85,
//       );

//       debugPrint('✅ Thumbnail generated: $thumbnail');
//       return thumbnail;
//     } catch (e) {
//       debugPrint('❌ Thumbnail generation failed: $e');
//       return null;
//     }
//   }

//   Future<void> uploadGreenScreenVideo(String path) async {
//     final file = File(path);

//     if (!await file.exists()) {
//       throw Exception('Final video file does not exist');
//     }

//     // Save local copy
//     final dir = await getApplicationDocumentsDirectory();
//     final timestamp = DateTime.now().millisecondsSinceEpoch;
//     final localCopyPath = '${dir.path}/greenscreen_$timestamp.mp4';
//     await file.copy(localCopyPath);

//     debugPrint('✅ Video saved locally at: $localCopyPath');

//     final formData = FormData.fromMap({
//       'video': await MultipartFile.fromFile(
//         path,
//         filename: file.path.split('/').last,
//         contentType: MediaType('video', 'mp4'),
//       ),
//       if (Constant.userID != null) 'user_id': Constant.userID.toString(),
//     });

//     try {
//       // ✅ Increase timeout for video uploads
//       final response = await DioClient.instance.dio.post(
//         '/upload/greenscreen-video',
//         data: formData,
//         options: Options(
//           contentType: 'multipart/form-data',
//           sendTimeout: const Duration(minutes: 5), // ✅ Added
//           receiveTimeout: const Duration(minutes: 5), // ✅ Added
//         ),
//         onSendProgress: (sent, total) {
//           final progress = (sent / total * 100).toStringAsFixed(1);
//           debugPrint('Upload progress: $progress%');
//         },
//       );

//       debugPrint('✅ Upload success: ${response.statusCode}');
//     } on DioException catch (e) {
//       debugPrint('❌ Upload failed: ${e.message}');
//       debugPrint('Response: ${e.response?.data}');
//       rethrow;
//     }
//   }

//   void _showProcessingDialog() {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => WillPopScope(
//         onWillPop: () async => false,
//         child: const AlertDialog(
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               CircularProgressIndicator(),
//               SizedBox(height: 16),
//               Text('Processing green screen video...'),
//               SizedBox(height: 8),
//               Text(
//                 'This may take a few moments',
//                 style: TextStyle(fontSize: 12, color: Colors.grey),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   void _showSuccessDialog(String outputPath) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Success!'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text('Your green screen video has been created!'),
//             const SizedBox(height: 8),
//             Text(
//               'Saved to: ${outputPath.split('/').last}',
//               style: const TextStyle(fontSize: 12, color: Colors.grey),
//             ),
//             const SizedBox(height: 8),
//             const Text(
//               'Video has been saved to your device and uploaded.',
//               style: TextStyle(fontSize: 12),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//             },
//             child: const Text('OK'),
//           ),
//           TextButton(
//             onPressed: () async {
//               // Option to view the video
//               // You could use url_launcher or open_file package
//               Navigator.pop(context);
//             },
//             child: const Text('View Video'),
//           ),
//         ],
//       ),
//     );
//   }

// Future<void> _saveToDeviceStorage(String videoPath) async {
//   try {
//     final file = File(videoPath);
//     if (!await file.exists()) {
//       throw Exception('Video file not found');
//     }

//     // Show saving dialog
//     if (!mounted) return;
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => const AlertDialog(
//         content: Row(
//           children: [
//             CircularProgressIndicator(),
//             SizedBox(width: 16),
//             Text('Saving to gallery...'),
//           ],
//         ),
//       ),
//     );

//     // ✅ Save to gallery using Gal package
//     await Gal.putVideo(videoPath, album: 'GreenScreen');

//     // Close loading dialog
//     if (!mounted) return;
//     Navigator.pop(context);

//     // Show success
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text('✅ Video saved to gallery'),
//         backgroundColor: Colors.green,
//         duration: Duration(seconds: 2),
//       ),
//     );

//     debugPrint('✅ Video saved to gallery: $videoPath');
//   } catch (e) {
//     debugPrint('❌ Save error: $e');

//     if (mounted && Navigator.canPop(context)) {
//       Navigator.pop(context);
//     }

//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('Failed to save: $e'),
//         backgroundColor: Colors.red,
//       ),
//     );
//   }
// }

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;

//     if (_camReady && !_overlayInit) {
//       _overlayInit = true;
//       _overlaySizePx = size.width * 0.28;
//       const m = 24.0;
//       _overlayTopLeftPx = Offset(
//         size.width - _overlaySizePx - m,
//         size.height * 0.15,
//       );
//     }

//     if (!_camReady) {
//       return Scaffold(
//         backgroundColor: Colors.black,
//         appBar: AppBar(
//           backgroundColor: Colors.transparent,
//           elevation: 0,
//           leading: IconButton(
//             icon: const Icon(Icons.close, color: Colors.white),
//             onPressed: () => Navigator.pop(context),
//           ),
//           title:
//               const Text('Green Screen', style: TextStyle(color: Colors.white)),
//         ),
//         body: Stack(
//           children: [
//             Positioned.fill(
//               child: _bgReady ? _buildBackgroundVideo() : _buildBackgroundPh(),
//             ),
//             Center(
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   const Icon(Icons.videocam, size: 64, color: Colors.white54),
//                   const SizedBox(height: 16),
//                   ElevatedButton.icon(
//                     onPressed: _initCamera,
//                     icon: const Icon(Icons.video_call),
//                     label: const Text('Start Green Screen'),
//                     style: ElevatedButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 24,
//                         vertical: 12,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       );
//     }

//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: SafeArea(
//         child: Stack(
//           children: [
//             // Background video
//             Positioned.fill(
//               child: _bgReady ? _buildBackgroundVideo() : _buildBackgroundPh(),
//             ),

//             // Camera overlay
//             _buildCameraOverlay(size),

//             // Recording indicator
//             if (_isRecording)
//               Positioned(
//                 top: 16,
//                 left: 16,
//                 child: Container(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                   decoration: BoxDecoration(
//                     color: Colors.red,
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Container(
//                         width: 8,
//                         height: 8,
//                         decoration: const BoxDecoration(
//                           color: Colors.white,
//                           shape: BoxShape.circle,
//                         ),
//                       ),
//                       const SizedBox(width: 8),
//                       const Text(
//                         'REC',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),

//             // Control buttons
//             Positioned(
//               left: 16,
//               right: 16,
//               bottom: 24,
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   FloatingActionButton(
//                     heroTag: null, // CHANGED: was 'close_btn'
//                     backgroundColor: Colors.white24,
//                     foregroundColor: Colors.white,
//                     onPressed: _isRecording || _isProcessing
//                         ? null
//                         : () => Navigator.pop(context),
//                     child: const Icon(Icons.close),
//                   ),
//                   FloatingActionButton(
//                     heroTag: null, // CHANGED: was 'switch_btn'
//                     backgroundColor: Colors.white24,
//                     foregroundColor: Colors.white,
//                     onPressed:
//                         _isRecording || _isProcessing ? null : _switchCamera,
//                     child: const Icon(Icons.cameraswitch),
//                   ),
//                   FloatingActionButton(
//                     heroTag: null, // CHANGED: was 'rec_btn'
//                     backgroundColor: _isRecording ? Colors.red : Colors.white,
//                     foregroundColor: _isRecording ? Colors.white : Colors.red,
//                     onPressed: _isProcessing
//                         ? null
//                         : () async {
//                             if (_isRecording) {
//                               await _stopRecording();
//                             } else {
//                               await _startRecording();
//                             }
//                           },
//                     child: Icon(
//                       _isRecording ? Icons.stop : Icons.fiber_manual_record,
//                       size: 32,
//                     ),
//                   ),
//                   FloatingActionButton(
//                     heroTag: null, // CHANGED: was 'reset_btn'
//                     backgroundColor: Colors.white24,
//                     foregroundColor: Colors.white,
//                     onPressed: _isRecording || _isProcessing
//                         ? null
//                         : () {
//                             setState(() {
//                               _overlaySizePx = size.width * 0.28;
//                               const m = 24.0;
//                               _overlayTopLeftPx = Offset(
//                                 size.width - _overlaySizePx - m,
//                                 size.height * 0.15,
//                               );
//                             });
//                           },
//                     child: const Icon(Icons.aspect_ratio),
//                   ),
//                 ],
//               ),
//             ),

//             // Instructions overlay
//             if (!_isRecording && _camReady)
//               Positioned(
//                 top: 16,
//                 left: 16,
//                 right: 16,
//                 child: Container(
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: Colors.black54,
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: const Text(
//                     'Drag to move • Pinch corner to resize • Tap record to start',
//                     style: TextStyle(color: Colors.white, fontSize: 12),
//                     textAlign: TextAlign.center,
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildBackgroundVideo() {
//     return FittedBox(
//       fit: BoxFit.cover,
//       child: SizedBox(
//         width: _bg!.value.size.width,
//         height: _bg!.value.size.height,
//         child: VideoPlayer(_bg!),
//       ),
//     );
//   }

//   Widget _buildBackgroundPh() {
//     return Container(
//       decoration: const BoxDecoration(
//         gradient: LinearGradient(
//           colors: [Colors.black, Colors.black87],
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//         ),
//       ),
//       child: const Center(
//         child: CircularProgressIndicator(color: Colors.white38),
//       ),
//     );
//   }

//   Widget _buildCameraOverlay(Size screenSize) {
//     double clampX(double x, double w) => x.clamp(0.0, screenSize.width - w);
//     double clampY(double y, double h) => y.clamp(0.0, screenSize.height - h);

//     final left = clampX(_overlayTopLeftPx.dx, _overlaySizePx);
//     final top = clampY(_overlayTopLeftPx.dy, _overlaySizePx);

//     return Positioned(
//       left: left,
//       top: top,
//       width: _overlaySizePx,
//       height: _overlaySizePx,
//       child: GestureDetector(
//         onPanUpdate: (d) {
//           setState(() {
//             _overlayTopLeftPx = Offset(
//               clampX(_overlayTopLeftPx.dx + d.delta.dx, _overlaySizePx),
//               clampY(_overlayTopLeftPx.dy + d.delta.dy, _overlaySizePx),
//             );
//           });
//         },
//         child: Stack(
//           children: [
//             // Camera preview
//             Container(
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 border: Border.all(
//                   color: _isRecording ? Colors.red : Colors.white,
//                   width: 3,
//                 ),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.5),
//                     blurRadius: 10,
//                     spreadRadius: 2,
//                   ),
//                 ],
//               ),
//               child: Container(
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   border: Border.all(
//                     color: _isRecording ? Colors.red : Colors.white,
//                     width: 3,
//                   ),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.4),
//                       blurRadius: 12,
//                       spreadRadius: 2,
//                     ),
//                   ],
//                 ),
//                 child: SizedBox(
//                   width: _overlaySizePx,
//                   height: _overlaySizePx, // 🔒 Force perfect circle
//                   child: AnimatedContainer(
//                     duration: const Duration(milliseconds: 250),
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       border: Border.all(
//                         color: _isRecording ? Colors.red : Colors.white,
//                         width: _isRecording ? 4 : 2,
//                       ),
//                       boxShadow: _isRecording
//                           ? [
//                               BoxShadow(
//                                 color: Colors.red.withOpacity(0.6),
//                                 blurRadius: 20,
//                                 spreadRadius: 4,
//                               ),
//                             ]
//                           : [
//                               BoxShadow(
//                                 color: Colors.black.withOpacity(0.4),
//                                 blurRadius: 10,
//                                 spreadRadius: 2,
//                               ),
//                             ],
//                     ),
//                     child: ClipOval(
//                       child: _cam != null && _camReady
//                           ? FittedBox(
//                               fit: BoxFit.cover,
//                               child: SizedBox(
//                                 width: _cam!.value.previewSize?.height ??
//                                     _overlaySizePx,
//                                 height: _cam!.value.previewSize?.width ??
//                                     _overlaySizePx,
//                                 child: CameraPreview(_cam!),
//                               ),
//                             )
//                           : Container(
//                               color: Colors.black,
//                               alignment: Alignment.center,
//                               child: const CircularProgressIndicator(
//                                 color: Colors.white,
//                                 strokeWidth: 2,
//                               ),
//                             ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),

//             // Resize handle

//             Positioned(
//               right: 0,
//               bottom: 0,
//               child: GestureDetector(
//                 onPanUpdate: (d) {
//                   setState(() {
//                     final newSize = (_overlaySizePx + d.delta.dx).clamp(
//                       screenSize.width * 0.15,
//                       screenSize.width * 0.75,
//                     );
//                     _overlaySizePx = newSize;
//                     _overlayTopLeftPx = Offset(
//                       clampX(_overlayTopLeftPx.dx, _overlaySizePx),
//                       clampY(_overlayTopLeftPx.dy, _overlaySizePx),
//                     );
//                   });
//                 },
//                 child: Container(
//                   width: 32,
//                   height: 32,
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     shape: BoxShape.circle,
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.3),
//                         blurRadius: 4,
//                       ),
//                     ],
//                   ),
//                   child: const Icon(
//                     Icons.open_in_full,
//                     size: 18,
//                     color: Colors.black,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
