import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:metube/ads/google_ads/google_small_native_ad.dart';
import 'package:metube/custom/custom_ui/data_not_found_ui.dart';
import 'package:metube/custom/shimmer/video_list_shimmer_ui.dart';
import 'package:metube/database/database.dart';
import 'package:metube/main.dart';
import 'package:metube/pages/profile_page/your_channel_page/channel_playlist_page/channel_playlist_model.dart';
import 'package:metube/pages/profile_page/your_channel_page/channel_playlist_page/preview_playlist_view.dart';
import 'package:metube/pages/profile_page/your_channel_page/main_page/your_channel_controller.dart';
import 'package:metube/utils/colors/app_color.dart';
import 'package:metube/utils/config/size_config.dart';
import 'package:metube/utils/icons/app_icons.dart';
import 'package:metube/utils/services/preview_image.dart';
import 'package:metube/utils/settings/app_settings.dart';
import 'package:metube/utils/string/app_string.dart';

class ChannelPlayListTabView extends StatelessWidget {
  const ChannelPlayListTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<YourChannelController>(
      id: "onGetPlayList",
      builder: (controller) {
        return controller.channelPlayList == null
            ? const VideoListShimmerUi()
            : (controller.channelPlayList!.isEmpty)
                ? DataNotFoundUi(title: AppStrings.playlistNotAvailable.tr)

                // : NotificationListener<ScrollNotification>(
                //     onNotification: (notification) {
                //       if (notification is UserScrollNotification) {
                //         if (notification.direction == ScrollDirection.forward) {
                //           controller.mainScrollController.animateTo(0, duration: const Duration(milliseconds: 500), curve: Curves.linear);
                //         } else if (notification.direction == ScrollDirection.reverse) {
                //           controller.mainScrollController.animateTo(250, duration: const Duration(milliseconds: 500), curve: Curves.linear);
                //         }
                //       }
                //       return true;
                //     },
                //     child:
                : (controller.channelPlayList!.where((element) => element.playListType == 2 || element.channelId == Database.channelId).isNotEmpty)
                    ? SingleChildScrollView(
                        // controller: controller.playListScrollController,
                        physics: const BouncingScrollPhysics(),
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: controller.channelPlayList?.length,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          itemBuilder: (context, index) {
                            final list = controller.channelPlayList;
                            if (list == null || index >= list.length) {
                              return const SizedBox.shrink();
                            }
                            final item = list[index];
                            if (item.playListType == 1 && item.channelId != Database.channelId) {
                              return const Offstage();
                            }
                            final videos = item.videos;
                            final thumb = (videos != null && videos.isNotEmpty) ? videos.first : null;

                            return Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 10),
                                        child: GestureDetector(
                                          onTap: () {
                                            controller.selectedPlayList = index;
                                            Get.to(
                                              () => PreviewPlaylistView(
                                                channelName: item.channelName ?? "",
                                                playListName: item.playListName ?? "",
                                                videos: videos ?? const <Videos>[],
                                              ),
                                            );
                                          },
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Stack(
                                                children: [
                                                  Obx(
                                                    () => Container(
                                                      clipBehavior: Clip.hardEdge,
                                                      height: SizeConfig.smallVideoImageHeight,
                                                      width: SizeConfig.smallVideoImageWidth,
                                                      decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.circular(20), color: isDarkMode.value ? AppColor.secondDarkMode : AppColor.grey_400),
                                                      child: thumb != null
                                                          ? PreviewVideoImage(
                                                              videoId: thumb.videoId ?? "",
                                                              videoImage: thumb.videoImage ?? "",
                                                            )
                                                          : Center(
                                                              child: Image.asset(
                                                                AppIcons.logo,
                                                                width: 40,
                                                                color: isDarkMode.value ? AppColor.primaryColor : AppColor.white,
                                                              ),
                                                            ),
                                                    ),
                                                  ),
                                                  Positioned(
                                                    right: 0,
                                                    child: Container(
                                                      height: (Get.height / 4 > 200) ? Get.height / 7.5 : 110,
                                                      width: SizeConfig.screenWidth / 5,
                                                      decoration: BoxDecoration(
                                                        color: AppColor.black.withOpacity(0.4),
                                                        borderRadius: const BorderRadius.only(
                                                          topRight: Radius.circular(20),
                                                          bottomRight: Radius.circular(20),
                                                        ),
                                                      ),
                                                      child: Column(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          Text(
                                                            (item.totalVideo ?? 0).toString(),
                                                            style: GoogleFonts.urbanist(fontSize: 14, color: AppColor.white),
                                                          ),
                                                          SizedBox(height: SizeConfig.blockSizeVertical * 1),
                                                          const ImageIcon(AssetImage(AppIcons.boldPlay), color: AppColor.white, size: 18),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(width: Get.width * 0.03),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      item.playListName ?? "",
                                                      maxLines: 3,
                                                      style: GoogleFonts.urbanist(fontSize: 16, fontWeight: FontWeight.bold),
                                                    ),
                                                    SizedBox(height: SizeConfig.blockSizeVertical * 1),
                                                    Text(
                                                      item.channelName ?? "",
                                                      style: GoogleFonts.urbanist(
                                                        fontSize: 12,
                                                        color: isDarkMode.value ? AppColor.white.withOpacity(0.7) : AppColor.black.withOpacity(0.7),
                                                      ),
                                                    ),
                                                    SizedBox(height: SizeConfig.blockSizeVertical * 1),
                                                    Text(
                                                      "${item.totalVideo ?? 0} videos",
                                                      style: GoogleFonts.urbanist(
                                                        fontSize: 10,
                                                        color: isDarkMode.value ? AppColor.white.withOpacity(0.7) : AppColor.black.withOpacity(0.7),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const Offstage()
                                              // GestureDetector(child: const Icon(Icons.more_vert), onTap: () {}),
                                            ],
                                          ),
                                        ),
                                      ),
                                      index != 0 && index % AppSettings.showAdsIndex == 0 ? const GoogleSmallNativeAd() : const Offstage(),
                                    ],
                                  );
                          },
                        ),
                      )
                    : DataNotFoundUi(title: AppStrings.playlistNotAvailable.tr);
      },
    );
  }
}
