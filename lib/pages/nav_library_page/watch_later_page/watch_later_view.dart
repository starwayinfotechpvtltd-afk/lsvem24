import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:metube/custom/custom_method/custom_format_timer.dart';
import 'package:metube/custom/custom_ui/data_not_found_ui.dart';
import 'package:metube/custom/custom_ui/small_video_widget.dart';
import 'package:metube/custom/shimmer/video_list_shimmer_ui.dart';
import 'package:metube/main.dart';
import 'package:metube/pages/nav_library_page/main_page/nav_library_controller.dart';
import 'package:metube/pages/nav_shorts_page/nav_shorts_details_view.dart';
import 'package:metube/pages/profile_page/setting_page/settings_view.dart';
import 'package:metube/pages/video_details_page/normal_video_details_view.dart';
import 'package:metube/pages/video_details_page/shorts_video_details_view.dart';
import 'package:metube/utils/colors/app_color.dart';
import 'package:metube/utils/config/size_config.dart';
import 'package:metube/utils/icons/app_icons.dart';
import 'package:metube/utils/services/preview_image.dart';
import 'package:metube/utils/settings/app_settings.dart';
import 'package:metube/utils/string/app_string.dart';
import 'package:metube/utils/style/app_style.dart';

class WatchLaterView extends StatelessWidget {
  const WatchLaterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle(statusBarColor: Colors.transparent, statusBarIconBrightness: isDarkMode.value ? Brightness.light : Brightness.dark),
        leading: IconButtonUi(
            callback: () => Get.back(), icon: Image.asset(AppIcons.arrowBack, color: isDarkMode.value ? AppColor.white : AppColor.black).paddingOnly(left: 15, right: 20)),
        leadingWidth: 55,
        centerTitle: AppSettings.isCenterTitle,
        title: Text(AppStrings.watchLater.tr, style: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.bold)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButtonUi(
              callback: () => Get.to(const SettingsView()),
              icon: Obx(
                () => Image.asset(
                  AppIcons.setting,
                  height: 25,
                  width: 25,
                  color: isDarkMode.value ? AppColor.white : AppColor.black,
                ),
              ),
            ),
          ),
        ],
      ),
      body: GetBuilder<NavLibraryPageController>(
        id: "onGetWatchLaterVideo",
        builder: (controller) => Column(
          children: [
            // const SizedBox(height: 10),
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 20),
            //   child: Row(
            //     children: [
            //       const ImageIcon(AssetImage(AppIcons.download), size: 17),
            //       SizedBox(width: Get.width * 0.02),
            //       Text(
            //         "${controller.mainWatchLaterVideos?.length ?? 0}  ${AppStrings.unwatchedVideo.tr}",
            //         style: GoogleFonts.urbanist(fontSize: 15, fontWeight: FontWeight.bold),
            //       ),
            //     ],
            //   ),
            // ),
            // const SizedBox(height: 10),
            Expanded(
              child: controller.mainWatchLaterVideos == null
                  ? const VideoListShimmerUi()
                  : controller.mainWatchLaterVideos!.isEmpty
                      ? DataNotFoundUi(title: AppStrings.videoNotSaved.tr)
                      : RefreshIndicator(
                          color: AppColor.primaryColor,
                          onRefresh: () async => await controller.onGetWatchLaterVideo(),
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: ListView.separated(
                              itemCount: controller.mainWatchLaterVideos!.length,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: const EdgeInsets.all(10),
                              itemBuilder: (context, index) {
                                final indexData = controller.mainWatchLaterVideos![index];

                                return ((indexData.videoPrivacyType == 2 && indexData.channelType == 1) ||
                                        (indexData.videoPrivacyType == 2 && indexData.channelType == 2 && indexData.isSubscribed == false))
                                    ? GestureDetector(
                                        onTap: () => controller.onUnlockPrivateVideo(index: index, context: context),
                                        child: SmallVideoWidget(
                                          id: indexData.id ?? "",
                                          image: indexData.videoImage ?? "",
                                          videoTime: (indexData.videoTime ?? 0).toString(),
                                          title: indexData.videoTitle ?? "",
                                          views: 0,
                                          uploadTime: "",
                                          channelName: indexData.channelName,
                                        ),
                                      )
                                    : controller.mainWatchLaterVideos![index].videoType == 1
                                        ? GestureDetector(
                                            onTap: () => Get.to(
                                              NormalVideoDetailsView(
                                                videoId: controller.mainWatchLaterVideos![index].videoId!,
                                                videoUrl: controller.mainWatchLaterVideos![index].videoUrl!,
                                              ),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.only(bottom: 10),
                                              child: Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: [
                                                  // Padding(
                                                  //   padding: EdgeInsets.only(top: Get.width * 0.15),
                                                  //   child: GestureDetector(
                                                  //     onTap: () {},
                                                  //     child: const ImageIcon(AssetImage(AppIcons.puse), size: 17),
                                                  //   ),
                                                  // ),
                                                  Stack(
                                                    children: [
                                                      Obx(
                                                        () => Container(
                                                          clipBehavior: Clip.hardEdge,
                                                          height: SizeConfig.smallVideoImageHeight,
                                                          width: SizeConfig.smallVideoImageWidth,
                                                          decoration: BoxDecoration(
                                                              color: isDarkMode.value ? AppColor.secondDarkMode : AppColor.grey_400, borderRadius: BorderRadius.circular(19)),
                                                          child: PreviewVideoImage(
                                                            videoId: controller.mainWatchLaterVideos![index].id!,
                                                            videoImage: controller.mainWatchLaterVideos![index].videoImage!,
                                                          ),
                                                        ),
                                                      ),
                                                      Positioned(
                                                        bottom: 10,
                                                        right: 10,
                                                        child: Container(
                                                          alignment: Alignment.center,
                                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                          decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(7),
                                                            color: AppColor.black,
                                                          ),
                                                          child: Text(
                                                            CustomFormatTime.convert(int.parse(controller.mainWatchLaterVideos![index].videoTime.toString())),
                                                            style: GoogleFonts.urbanist(color: AppColor.white, fontSize: 11),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(width: Get.width * 0.02),

                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          controller.mainWatchLaterVideos![index].videoTitle.toString(),
                                                          maxLines: 3,
                                                          style: GoogleFonts.urbanist(fontSize: 16, fontWeight: FontWeight.bold),
                                                        ),
                                                        SizedBox(height: Get.height * 0.01),
                                                        Text(
                                                          controller.mainWatchLaterVideos![index].channelName.toString(),
                                                          style: GoogleFonts.urbanist(
                                                            fontSize: 12,
                                                            color: isDarkMode.value ? AppColor.white.withOpacity(0.7) : AppColor.black.withOpacity(0.7),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(width: Get.width * 0.01),
                                                ],
                                              ),
                                            ),
                                          )
                                        : const Offstage();
                              },
                              separatorBuilder: (context, index) => (controller.mainWatchLaterVideos!.where((element) => element.videoType == 2).isNotEmpty) && index == 0
                                  ? SizedBox(
                                      height: 250,
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: ListView.builder(
                                          itemCount: controller.mainWatchLaterVideos?.length ?? 0,
                                          scrollDirection: Axis.horizontal,
                                          shrinkWrap: true,
                                          physics: const BouncingScrollPhysics(),
                                          padding: const EdgeInsets.only(bottom: 10),
                                          itemBuilder: (BuildContext context, int index) {
                                            return controller.mainWatchLaterVideos![index].videoType == 2
                                                ? GestureDetector(
                                                    onTap: () => Get.to(
                                                          ShortsVideoDetailsView(
                                                            videoId: controller.mainWatchLaterVideos![index].videoId!,
                                                            videoUrl: controller.mainWatchLaterVideos![index].videoUrl!,
                                                          ),
                                                        ),
                                                    child: Container(
                                                      height: 250,
                                                      width: 165,
                                                      clipBehavior: Clip.antiAlias,
                                                      margin: EdgeInsets.only(right: index == (controller.mainWatchLaterVideos!.length - 1) ? 0 : 10),
                                                      decoration: BoxDecoration(
                                                          color: isDarkMode.value ? AppColor.secondDarkMode : AppColor.grey_300, borderRadius: BorderRadius.circular(20)),
                                                      child: Stack(
                                                        children: [
                                                          PreviewVideoImage(
                                                            videoId: controller.mainWatchLaterVideos![index].videoId!,
                                                            videoImage: controller.mainWatchLaterVideos![index].videoImage!,
                                                          ),
                                                          Positioned(
                                                            bottom: 0,
                                                            left: 10,
                                                            child: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                SizedBox(
                                                                  width: 145,
                                                                  child: Text(
                                                                    controller.mainWatchLaterVideos![index].videoTitle!.toString(),
                                                                    maxLines: 3,
                                                                    style: shortsStyle,
                                                                  ),
                                                                ),
                                                                const SizedBox(height: 10),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ))
                                                : const Offstage();
                                          },
                                        ),
                                      ),
                                    )
                                  : const Offstage(),
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
