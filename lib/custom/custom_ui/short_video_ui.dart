import 'dart:ui';

import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_typedefs/rx_typedefs.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:metube/custom/custom_method/custom_format_number.dart';
import 'package:metube/main.dart';
import 'package:metube/pages/video_details_page/more_information_bottom_sheet.dart';
import 'package:metube/pages/video_details_page/more_information_model.dart';
import 'package:metube/utils/colors/app_color.dart';
import 'package:metube/utils/icons/app_icons.dart';
import 'package:metube/utils/services/preview_image.dart';
import 'package:metube/utils/string/app_string.dart';
import 'package:metube/utils/style/app_style.dart';
import 'package:metube/utils/utils.dart';
import 'package:metube/utils/auth/auth_service.dart';

class ShortVideoUi extends StatelessWidget {
  const ShortVideoUi({
    super.key,
    required this.videoId,
    required this.title,
    required this.videoImage,
    this.views,
    required this.videoUrl,
    required this.videoTime,
    required this.channelName,
    required this.channelId,
    required this.isSave,
  });

  final String videoId;
  final String channelId;
  final String title;
  final String videoImage;
  final String videoUrl;
  final int? views;
  final int videoTime;
  final bool isSave;

  final String channelName;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.only(right: 10),
        height: 280,
        width: 180,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(color: isDarkMode.value ? AppColor.secondDarkMode : AppColor.grey_400, borderRadius: BorderRadius.circular(20)),
        child: Stack(
          children: [
            PreviewVideoImage(videoId: videoId, videoImage: videoImage),
            // ConvertedPathView(imageVideoPath: videoImage),
            Positioned(
              top: 10,
              right: 10,
              child: GestureDetector(
                onTap: () => MoreInfoBottomSheet.show(
                  context,
                  MoreInformationModel(
                    videoId: videoId,
                    title: title,
                    videoImage: videoImage,
                    channelId: channelId,
                    videoType: 2,
                    videoTime: videoTime,
                    videoUrl: videoUrl,
                    channelName: channelName,
                    views: views ?? 0,
                    isSave: isSave,
                  ),
                  true,
                ),
                child: const Icon(Icons.more_vert, color: AppColor.white),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 145, child: Text(title, maxLines: 3, style: shortsStyle)),
                  const SizedBox(height: 10),
                  views != null ? Text("${CustomFormatNumber.convert(views!)} views", style: shortsStyle) : const Offstage(),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ShortsPrivateContentWidget extends StatelessWidget {
  const ShortsPrivateContentWidget({
    super.key,
    required this.id,
    required this.image,
    required this.subscribe,
    required this.unlock,
    required this.subscribeCoin,
    required this.unlockCoin,
    required this.title,
    required this.views,
    required this.channelType,
  });

  final String id;
  final String image;
  final String title;
  final int views;
  final int subscribeCoin;
  final int unlockCoin;
  final int channelType;
  final Callback subscribe;
  final Callback unlock;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.only(right: 10),
      height: 280,
      width: 180,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(color: isDarkMode.value ? AppColor.secondDarkMode : AppColor.grey_400, borderRadius: BorderRadius.circular(20)),
      child: Stack(
        alignment: Alignment.center,
        children: [
          PreviewVideoImage(videoId: id, videoImage: image),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                color: Colors.black.withOpacity(0),
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(AppIcons.lock, width: 30),
              10.height,
              Text(
                AppStrings.thisVideoIsPrivateContent.tr,
                style: GoogleFonts.urbanist(fontSize: 14, color: AppColor.white, fontWeight: FontWeight.w900),
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
              10.height,
              Column(
                children: [
                  Visibility(
                    visible: channelType == 2,
                    child: GestureDetector(
                      onTap: () {
                        if (!AuthService.checkLogin()) return;
                        subscribe();
                      },
                      child: BlurryContainer(
                        height: 42,
                        width: 140,
                        blur: 5,
                        borderRadius: BorderRadius.circular(30),
                        color: AppColor.white.withOpacity(0.4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              AppStrings.subscribe.tr,
                              style: GoogleFonts.urbanist(
                                color: AppColor.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            5.width,
                            Image.asset(AppIcons.coin, width: 15),
                            2.width,
                            Text(
                              "$subscribeCoin/m",
                              style: GoogleFonts.urbanist(
                                color: AppColor.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  10.height,
                  GestureDetector(
                    onTap: unlock,
                    child: Container(
                      height: 42,
                      width: 140,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: AppColor.primaryColor,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            AppStrings.unlockVideo.tr,
                            style: GoogleFonts.urbanist(color: AppColor.white, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                          5.width,
                          Image.asset(AppIcons.coin, width: 15),
                          2.width,
                          Text(
                            "$unlockCoin",
                            style: GoogleFonts.urbanist(color: AppColor.white, fontWeight: FontWeight.w800, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Positioned(
          //   bottom: 0,
          //   left: 10,
          //   child: Column(
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     children: [
          //       SizedBox(width: 145, child: Text(title, maxLines: 2, style: shortsStyle)),
          //       const SizedBox(height: 5),
          //       Text("${CustomFormatNumber.convert(views)} views", style: shortsStyle),
          //       const SizedBox(height: 10),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }
}
