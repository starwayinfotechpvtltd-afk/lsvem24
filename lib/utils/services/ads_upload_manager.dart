import 'dart:io';

import 'package:get/get.dart';

enum AdsUploadStatus {
  waiting,
  uploading,
  success,
  failed,
}

class AdsUploadTask {
  final String id;

  final String title;
  final String description;

  final String? country;
  final String? state;
  final String? type;
  final String? category;
  final String? adRuns;
  final String? city;
  final String? budget;
  final String? placement;

  final int durationSeconds;
  final double fileSizeMB;

  final File? image;
  final File? video;

  AdsUploadStatus status;

  String message;

  DateTime createdAt;

  AdsUploadTask({
    required this.id,
    required this.title,
    required this.description,
    required this.country,
    required this.state,
    required this.type,
    required this.category,
    required this.adRuns,
    required this.city,
    required this.budget,
    required this.placement,
    required this.durationSeconds,
    required this.fileSizeMB,
    required this.image,
    required this.video,
    this.status = AdsUploadStatus.waiting,
    this.message = "",
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}

class AdsUploadManager extends GetxService {
  static AdsUploadManager get to => Get.find<AdsUploadManager>();

  /// Queue
  final RxList<AdsUploadTask> uploads = <AdsUploadTask>[].obs;

  /// Currently uploading
  final RxBool isUploading = false.obs;

  /// Add upload
  void addTask(AdsUploadTask task) {
    uploads.add(task);

    _startNextUpload();
  }

  Future<void> _startNextUpload() async {
    if (isUploading.value) return;

    final waiting = uploads.firstWhereOrNull(
      (e) => e.status == AdsUploadStatus.waiting,
    );

    if (waiting == null) {
      return;
    }

    isUploading.value = true;

    waiting.status = AdsUploadStatus.uploading;

    uploads.refresh();

    try {
      await _upload(waiting);
    } finally {
      isUploading.value = false;

      uploads.refresh();

      _startNextUpload();
    }
  }

  Future<void> _upload(AdsUploadTask task) async {
    /// Actual upload code will be added in Part 2.
  }

  int get totalUploads => uploads.length;

  int get uploadingCount =>
      uploads.where((e) => e.status == AdsUploadStatus.uploading).length;

  int get successCount =>
      uploads.where((e) => e.status == AdsUploadStatus.success).length;

  int get failedCount =>
      uploads.where((e) => e.status == AdsUploadStatus.failed).length;

  void removeCompleted() {
    uploads.removeWhere(
      (e) =>
          e.status == AdsUploadStatus.success ||
          e.status == AdsUploadStatus.failed,
    );
  }
}