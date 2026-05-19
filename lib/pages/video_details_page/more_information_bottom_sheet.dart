import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:metube/custom/basic_button.dart';
import 'package:metube/custom/custom_method/custom_download.dart';
import 'package:metube/custom/custom_method/custom_share.dart';
import 'package:metube/custom/custom_method/custom_toast.dart';
import 'package:metube/custom/custom_ui/premium_plan_dialog.dart';
import 'package:metube/database/database.dart';
import 'package:metube/database/download_history_database.dart';
import 'package:metube/main.dart';
import 'package:metube/notification/local_notification_services.dart';
import 'package:metube/pages/custom_pages/report_page/custom_report_view.dart';
import 'package:metube/pages/custom_pages/share_count_page/share_count_api.dart';
import 'package:metube/pages/login_related_page/fill_profile_page/get_profile_api.dart';
import 'package:metube/pages/nav_library_page/create_playlist_page/add_into_playlist.dart';
import 'package:metube/pages/nav_library_page/download_page/download_view.dart';
import 'package:metube/pages/nav_library_page/watch_later_page/create_watch_later_api.dart';
import 'package:metube/pages/video_details_page/more_information_model.dart';
import 'package:metube/utils/colors/app_color.dart';
import 'package:metube/utils/config/size_config.dart';
import 'package:metube/utils/icons/app_icons.dart';
import 'package:metube/utils/services/convert_to_network.dart';
import 'package:metube/utils/settings/app_settings.dart';
import 'package:metube/utils/string/app_string.dart';
import 'package:metube/utils/style/app_style.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class MoreInfoBottomSheet {
  static void show(
      BuildContext context, MoreInformationModel element, bool isShorts) async {
    AppSettings.showLog("Selected Video => ${element.title}");
    Get.bottomSheet(
      backgroundColor:
          isDarkMode.value ? AppColor.secondDarkMode : AppColor.white,
      SizedBox(
        height: isShorts ? 210 : 280,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Container(
                width: SizeConfig.blockSizeHorizontal * 12,
                height: 3,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(60),
                  color: AppColor.grey_300,
                ),
              ),
              const SizedBox(height: 16),
              Text(AppStrings.moreOption.tr, style: titalstyle1),
              const SizedBox(height: 8),
              Divider(indent: 25, endIndent: 25, color: AppColor.grey_200),
              const SizedBox(height: 8),
              BottomShitButton(
                widget: ImageIcon(
                    AssetImage(element.isSave
                        ? AppIcons.saveDone2
                        : AppIcons.timeCircle),
                    size: 23),
                name: element.isSave
                    ? AppStrings.saved.tr
                    : AppStrings.saveToWatchLater.tr,
                onTap: () {
                  if (element.isSave == false) {
                    CustomToast.show(AppStrings.addToWatchLater.tr);
                    CreateWatchLater.callApi(
                        Database.loginUserId!, element.videoId);
                    Get.back();
                  } else {
                    AppSettings.showLog("Video Already Saved");
                  }
                },
              ),
              const SizedBox(height: 16),
              isShorts
                  ? const Offstage()
                  : Column(
                      children: [
                        BottomShitButton(
                          widget: ImageIcon(
                            const AssetImage(AppIcons.libraryLogo),
                            size: 23,
                            color: isShorts || Database.channelId == null
                                ? AppColor.grey
                                : null,
                          ),
                          name: AppStrings.saveToPlaylist.tr,
                          color: isShorts || Database.channelId == null
                              ? AppColor.grey
                              : null,
                          onTap: isShorts || Database.channelId == null
                              ? () {}
                              : () {
                                  Get.back();
                                  AddIntoPlayList.onAddToPlayList(
                                      Database.channelId!, element.videoId);
                                },
                        ),
                        const SizedBox(height: 16),
                        BottomShitButton(
                          widget: ImageIcon(
                            const AssetImage(AppIcons.download),
                            size: 23,
                            color: isShorts ||
                                    DownloadHistory.mainDownloadHistory.any(
                                        (map) =>
                                            map['videoId'] == element.videoId)
                                ? AppColor.grey
                                : null,
                          ),
                          name: AppStrings.download.tr,
                          color: isShorts ||
                                  DownloadHistory.mainDownloadHistory.any(
                                      (map) =>
                                          map['videoId'] == element.videoId)
                              ? AppColor.grey
                              : null,
                          onTap: isShorts ||
                                  DownloadHistory.mainDownloadHistory.any(
                                      (map) =>
                                          map['videoId'] == element.videoId)
                              ? () {}
                              : () async {
                                  if ((GetProfileApi
                                          .profileModel?.user?.isPremiumPlan ??
                                      false)) {
                                    Get.back(); // Close Bottom Sheet

                                    CustomToast.show("Downloading....");
                                    AppSettings.isDownloading.value = true;
                                    // final downloadPath = await CustomDownload.download(Database.onGetVideoUrl(element.videoId) ?? await ConvertToNetwork.normalVideo(element.videoUrl), element.videoId);
                                    final downloadPath =
                                        await CustomDownload.download(
                                            Database.onGetVideoUrl(
                                                    element.videoId) ??
                                                await ConvertToNetwork.convert(
                                                    element.videoUrl),
                                            element.videoId);

                                    if (downloadPath != null) {
                                      final downloadThumbnail =
                                          await VideoThumbnail.thumbnailFile(
                                        video: downloadPath,
                                        thumbnailPath:
                                            (await getTemporaryDirectory())
                                                .path,
                                        imageFormat: ImageFormat.JPEG,
                                        maxHeight: 400,
                                        quality: 100,
                                      );
                                      if (downloadThumbnail != null) {
                                        DateTime now = DateTime.now();
                                        String formattedDate = now.toString();

                                        DownloadHistory.mainDownloadHistory
                                            .insert(
                                          0,
                                          {
                                            "videoId": element.videoId,
                                            "videoTitle": element.title,
                                            "videoType": element.videoType,
                                            "videoTime": element.videoTime,
                                            "videoUrl": downloadPath,
                                            "videoImage": downloadThumbnail,
                                            "views": element.views,
                                            "channelName": element.channelName,
                                            "time": formattedDate
                                          },
                                        );
                                        DownloadHistory.onSet();
                                      }
                                      LocalNotificationServices
                                          .onSendNotification(
                                        "Download Complete",
                                        element.title,
                                        () {
                                          AppSettings.showLog(
                                              "Go To Download Routes");
                                          if (DownloadHistory
                                              .mainDownloadHistory.isEmpty) {
                                            DownloadHistory.onGet();
                                          }
                                          Get.to(() => const DownloadView());
                                        },
                                      );
                                      AppSettings.isDownloading.value = false;
                                      CustomToast.show(
                                          "Video download complete");
                                    } else {
                                      AppSettings.isDownloading.value = false;
                                      CustomToast.show(
                                          "Video download failed !!");
                                    }
                                  } else {
                                    PremiumPlanDialog().show(context);
                                  }
                                },
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
              BottomShitButton(
                widget: const ImageIcon(AssetImage(AppIcons.send), size: 23),
                name: AppStrings.share.tr,
                onTap: () async {
                  Get.back();
                  await CustomShare.share(
                    videoId: element.videoId,
                    name: element.title,
                    url: element.videoUrl,
                    image: element.videoImage,
                    pageRoutes: isShorts ? "ShortsVideo" : "NormalVideo",
                    channelId: element.channelId,
                  );
                  await ShareCountApiClass.callApi(
                      Database.loginUserId!, element.videoId);
                },
              ),
              const SizedBox(height: 16),
              BottomShitButton(
                widget:
                    const ImageIcon(AssetImage(AppIcons.closeSquare), size: 23),
                name: "${AppStrings.report.tr}-${AppStrings.block.tr}",
                onTap: () {
                  Get.back();
                  CustomReportView.show(element.videoId);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(30),
          topLeft: Radius.circular(30),
        ),
      ),
    );
  }
}
