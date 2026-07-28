import 'dart:io';

import 'package:get/get.dart';
import 'package:metube/custom/custom_method/custom_toast.dart';
import 'package:metube/database/database.dart';
import 'package:metube/notification/local_notification_services.dart';
import 'package:metube/pages/login_related_page/fill_profile_page/get_profile_api.dart';
import 'package:metube/pages/profile_page/ads_management_page/create_ads_api.dart';

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
  static AdsUploadManager get to {
    if (!Get.isRegistered<AdsUploadManager>()) {
      Get.put(AdsUploadManager(), permanent: true);
    }
    return Get.find<AdsUploadManager>();
  }

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
    final notificationId = DateTime.now().millisecondsSinceEpoch % 100000;
    final adTitle = task.title.isNotEmpty ? task.title : 'Ad';

    LocalNotificationServices.showUploadProgressNotification(
      id: notificationId,
      title: 'Uploading Ad',
      body: 'Preparing ad media...',
      progress: 5,
    );

    try {
      final isSuccess = await CreateAdsApi.callApi(
        title: task.title,
        description: task.description,
        country: task.country,
        state: task.state,
        type: task.type,
        category: task.category,
        adRuns: task.adRuns,
        city: task.city,
        budget: task.budget,
        placement: task.placement,
        durationSeconds: task.durationSeconds,
        fileSizeMB: task.fileSizeMB,
        image: task.image,
        video: task.video,
        onProgress: (p) {
          final currentProgress = 10 + (p * 75).toInt();
          LocalNotificationServices.showUploadProgressNotification(
            id: notificationId,
            title: 'Uploading Ad',
            body: 'Uploading ad media (${(p * 100).toInt()}%)...',
            progress: currentProgress,
          );
        },
      );

      LocalNotificationServices.showUploadProgressNotification(
        id: notificationId,
        title: 'Uploading Ad',
        body: 'Saving ad details...',
        progress: 95,
      );

      if (isSuccess) {
        task.status = AdsUploadStatus.success;
        task.message = CreateAdsApi.message?.isNotEmpty == true
            ? CreateAdsApi.message!
            : "Ads uploaded successfully";

        LocalNotificationServices.showUploadSuccessNotification(
          id: notificationId,
          title: 'Ad Upload Complete',
          body: adTitle,
        );

        CustomToast.show(task.message);
        await GetProfileApi.callApi(Database.loginUserId ?? '');
      } else {
        task.status = AdsUploadStatus.failed;
        task.message = CreateAdsApi.message?.isNotEmpty == true
            ? CreateAdsApi.message!
            : "Failed to upload ad";

        LocalNotificationServices.showUploadFailedNotification(
          id: notificationId,
          title: 'Ad Upload Failed',
          body: task.message,
        );

        CustomToast.show(task.message);
      }
    } catch (e) {
      task.status = AdsUploadStatus.failed;
      task.message = e.toString().replaceFirst('Exception: ', '');

      LocalNotificationServices.showUploadFailedNotification(
        id: notificationId,
        title: 'Ad Upload Failed',
        body: task.message,
      );

      CustomToast.show("Ad upload failed: ${task.message}");
    }
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