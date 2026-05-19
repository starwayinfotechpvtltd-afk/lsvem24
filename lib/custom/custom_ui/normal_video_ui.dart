import 'dart:ui';
import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_typedefs/rx_typedefs.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:metube/custom/custom_method/custom_format_number.dart';
import 'package:metube/custom/custom_method/custom_format_timer.dart';
import 'package:metube/database/database.dart';
import 'package:metube/main.dart';
import 'package:metube/pages/profile_page/your_channel_page/main_page/your_channel_view.dart';
import 'package:metube/pages/video_details_page/more_information_bottom_sheet.dart';
import 'package:metube/pages/video_details_page/more_information_model.dart';
import 'package:metube/utils/colors/app_color.dart';
import 'package:metube/utils/config/size_config.dart';
import 'package:metube/utils/icons/app_icons.dart';
import 'package:metube/utils/services/preview_image.dart';
import 'package:metube/utils/string/app_string.dart';
import 'package:metube/utils/utils.dart';

class NormalVideoUi extends StatelessWidget {
  const NormalVideoUi({
    super.key,
    required this.videoId,
    required this.title,
    required this.videoImage,
    required this.videoUrl,
    required this.videoTime,
    required this.channelId,
    required this.channelImage,
    required this.channelName,
    required this.views,
    this.uploadTime,
    required this.isSave,
  });

  final String videoId;
  final String title;
  final String videoImage;
  final String videoUrl;
  final int videoTime;
  final String channelId;
  final String channelImage;
  final String channelName;
  final int views;
  final String? uploadTime;
  final bool isSave;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(
          () => Container(
            height: SizeConfig.largeVideoImageHeight,
            width: Get.width,
            clipBehavior: Clip.antiAlias,
            margin: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: isDarkMode.value ? AppColor.secondDarkMode : AppColor.grey_400,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Stack(
              children: [
                PreviewVideoImage(videoId: videoId, videoImage: videoImage),

                // ConvertedPathView(imageVideoPath: videoImage),

                Positioned(
                  right: 20,
                  bottom: 15,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: AppColor.black),
                    child: Text(
                      CustomFormatTime.convert(videoTime),
                      style: GoogleFonts.urbanist(color: AppColor.white, fontSize: 11),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 5),
        GestureDetector(
          onTap: () => Get.to(() => YourChannelView(loginUserId: Database.loginUserId ?? "", channelId: channelId)),
          child: Container(
            color: AppColor.transparent,
            width: Get.width,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(width: 10),
                PreviewProfileImage(id: channelId, image: channelImage, size: 40, fit: BoxFit.cover),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        "$channelName - ${CustomFormatNumber.convert(views)} views ${uploadTime != null ? " - $uploadTime" : ""} ",
                        style: GoogleFonts.urbanist(fontSize: 12, color: AppColor.grey),
                      ),
                    ],
                  ),
                ),
                IconButton(
                    onPressed: () => MoreInfoBottomSheet.show(
                          context,
                          MoreInformationModel(
                            channelId: channelId,
                            videoImage: videoImage,
                            videoId: videoId,
                            title: title,
                            videoType: 1,
                            videoTime: videoTime,
                            videoUrl: videoUrl,
                            channelName: channelName,
                            views: views,
                            isSave: isSave,
                          ),
                          false,
                        ),
                    icon: const Icon(Icons.more_vert)),
                const SizedBox(width: 5),
              ],
            ),
          ),
        ),
        const SizedBox(height: 15),
      ],
    );
  }
}

class PrivateContentNormalVideoUi extends StatelessWidget {
  const PrivateContentNormalVideoUi({
    super.key,
    required this.videoId,
    required this.title,
    required this.videoImage,
    required this.videoUrl,
    required this.videoTime,
    required this.channelId,
    required this.channelImage,
    required this.channelName,
    required this.views,
    this.uploadTime,
    required this.isSave,
    required this.subscribeCallback,
    required this.videoCallback,
    required this.videoCost,
    required this.subscribeCost,
    required this.channelType,
  });
  final Callback subscribeCallback;
  final Callback videoCallback;
  final String videoId;
  final String title;
  final String videoImage;
  final String videoUrl;
  final int videoTime;
  final String channelId;
  final String channelImage;
  final String channelName;
  final int views;
  final String? uploadTime;
  final bool isSave;
  final int videoCost;
  final int subscribeCost;
  final int channelType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: SizeConfig.largeVideoImageHeight,
          width: Get.width,
          clipBehavior: Clip.antiAlias,
          margin: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: isDarkMode.value ? AppColor.secondDarkMode : AppColor.grey_400,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              PreviewVideoImage(videoId: videoId, videoImage: videoImage),
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    color: Colors.black.withOpacity(0),
                  ),
                ),
              ),
              Positioned.fill(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    5.height,
                    Image.asset(AppIcons.lock, width: 35),
                    10.height,
                    Text(
                      AppStrings.thisVideoIsPrivateContent.tr,
                      style: GoogleFonts.urbanist(fontSize: 16, color: AppColor.white, fontWeight: FontWeight.w900),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    5.height,
                    Text(
                      AppStrings.ifYouWantToSeeThisVideoBuyPrivateContentPremium.tr,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.urbanist(fontSize: 12, color: AppColor.white, fontWeight: FontWeight.w600),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    10.height,
                    channelType == 1
                        ? GestureDetector(
                            onTap: videoCallback,
                            child: Container(
                              height: 42,
                              width: 170,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: AppColor.primaryColor,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    AppStrings.unlockVideo.tr,
                                    style: GoogleFonts.urbanist(color: AppColor.white, fontWeight: FontWeight.bold, fontSize: 14.5),
                                  ),
                                  5.width,
                                  Image.asset(AppIcons.coin, width: 18),
                                  2.width,
                                  Text(
                                    CustomFormatNumber.convert(videoCost),
                                    style: GoogleFonts.urbanist(color: AppColor.white, fontWeight: FontWeight.w800, fontSize: 14.5),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : Row(
                            children: [
                              12.width,
                              Expanded(
                                child: GestureDetector(
                                  onTap: subscribeCallback,
                                  child: BlurryContainer(
                                    height: 42,
                                    blur: 5,
                                    borderRadius: BorderRadius.circular(30),
                                    color: AppColor.white.withOpacity(0.4),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          AppStrings.subscribe.tr,
                                          style: GoogleFonts.urbanist(color: AppColor.white, fontWeight: FontWeight.bold, fontSize: 14.5),
                                        ),
                                        5.width,
                                        Image.asset(AppIcons.coin, width: 18),
                                        2.width,
                                        Text(
                                          "$subscribeCost/m",
                                          style: GoogleFonts.urbanist(color: AppColor.white, fontWeight: FontWeight.w800, fontSize: 14.5),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              10.width,
                              Expanded(
                                child: GestureDetector(
                                  onTap: videoCallback,
                                  child: Container(
                                    height: 42,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(30),
                                      color: AppColor.primaryColor,
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          AppStrings.unlockVideo.tr,
                                          style: GoogleFonts.urbanist(color: AppColor.white, fontWeight: FontWeight.bold, fontSize: 14.5),
                                        ),
                                        5.width,
                                        Image.asset(AppIcons.coin, width: 18),
                                        2.width,
                                        Text(
                                          "$videoCost",
                                          style: GoogleFonts.urbanist(color: AppColor.white, fontWeight: FontWeight.w800, fontSize: 14.5),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              12.width,
                            ],
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 5),
        GestureDetector(
          onTap: () => Get.to(() => YourChannelView(loginUserId: Database.loginUserId ?? "", channelId: channelId)),
          child: Container(
            color: AppColor.transparent,
            width: Get.width,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(width: 10),
                PreviewProfileImage(id: channelId, image: channelImage, size: 40, fit: BoxFit.cover),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        "$channelName - ${CustomFormatNumber.convert(views)} views ${uploadTime != null ? " - $uploadTime" : ""} ",
                        style: GoogleFonts.urbanist(fontSize: 12, color: AppColor.grey),
                      ),
                    ],
                  ),
                ),
                IconButton(onPressed: videoCallback, icon: const Icon(Icons.more_vert)),
                const SizedBox(width: 5),
              ],
            ),
          ),
        ),
        const SizedBox(height: 15),
      ],
    );
  }
}
