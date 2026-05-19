import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:metube/custom/custom_method/custom_format_timer.dart';
import 'package:metube/custom/custom_method/custom_toast.dart';
import 'package:metube/database/database.dart';
import 'package:metube/database/download_history_database.dart';
import 'package:metube/database/watch_history_database.dart';
import 'package:metube/main.dart';
import 'package:metube/pages/nav_library_page/create_playlist_page/view/create_playlist_view.dart';
import 'package:metube/pages/nav_library_page/download_page/download_view.dart';
import 'package:metube/pages/nav_library_page/history_page/history_view.dart';
import 'package:metube/pages/nav_library_page/main_page/nav_library_controller.dart';
import 'package:metube/pages/nav_library_page/watch_later_page/watch_later_view.dart';
import 'package:metube/pages/nav_library_page/your_video_page/your_video_page.dart';
import 'package:metube/pages/notification_page/notification_view.dart';
import 'package:metube/pages/profile_page/main_page/profile_view.dart';
import 'package:metube/pages/profile_page/your_channel_page/channel_video_page/get_channel_video_api.dart';
import 'package:metube/pages/search_page/search_view.dart';
import 'package:metube/pages/video_details_page/normal_video_details_view.dart';
import 'package:metube/pages/video_details_page/shorts_video_details_view.dart';
import 'package:metube/utils/colors/app_color.dart';
import 'package:metube/utils/icons/app_icons.dart';
import 'package:metube/utils/services/preview_image.dart';
import 'package:metube/utils/settings/app_settings.dart';
import 'package:metube/utils/string/app_string.dart';

class NavLibraryView extends GetView<NavLibraryPageController> {
  const NavLibraryView({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) => AppSettings.navigationIndex.value = 0,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: const Padding(
              padding: EdgeInsets.only(left: 15),
              child: Image(
                  image: AssetImage(AppIcons.logo), height: 30, width: 30)),
          leadingWidth: 45,
          titleSpacing: 10,
          title: Text(
            AppStrings.library.tr,
            style:
                GoogleFonts.urbanist(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          actions: [
            InkWell(
              onTap: () =>
                  Get.to(() => const SearchView(isSearchShorts: false)),
              child: Image.asset(
                AppIcons.search,
                width: 20,
                color: isDarkMode.value ? AppColor.white : AppColor.black,
              ),
            ),
            const SizedBox(width: 18),
            GestureDetector(
              onTap: () => Get.to(() => const NotificationPageView()),
              child: Image.asset(
                AppIcons.notification,
                width: 18,
                color: isDarkMode.value ? AppColor.white : AppColor.black,
              ),
            ),
            const SizedBox(width: 18),
            GestureDetector(
              onTap: () => Get.to(() => const ProfileView()),
              child: Obx(
                () => PreviewProfileImage(
                  size: 35,
                  id: Database.channelId ?? "",
                  image: AppSettings.profileImage.value,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 15),
          ],
          // actions: [
          //   IconButton(
          //     onPressed: () => Get.to(() => const SearchView(isSearchShorts: false)),
          //     icon: Obx(
          //       () => Image(
          //         image: const AssetImage(AppIcons.search),
          //         height: 20,
          //         width: 20,
          //         color: isDarkMode.value ? AppColors.white : AppColors.black,
          //       ),
          //     ),
          //   ),
          //   IconButton(
          //     onPressed: () => Get.to(() => const NotificationPageView()),
          //     icon: Obx(
          //       () => Image(
          //         image: const AssetImage(AppIcons.notification),
          //         height: 22,
          //         width: 22,
          //         color: isDarkMode.value ? AppColors.white : AppColors.black,
          //       ),
          //     ),
          //   ),
          //   IconButton(
          //     onPressed: () => Get.to(() => const ProfileView()),
          //     icon: Obx(
          //       () => PreviewProfileImage(
          //         size: 30,
          //         id: Database.channelId ?? "",
          //         image: AppSettings.profileImage.value,
          //         fit: BoxFit.cover,
          //       ),
          //     ),
          //   ),
          //   const SizedBox(width: 5),
          // ],
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => Get.to(() => const HistoryPageView()),
                child: Container(
                  height: Get.height * 0.05,
                  width: Get.width,
                  color: AppColor.transparent,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(AppStrings.history.tr,
                          style: GoogleFonts.urbanist(
                              fontSize: 17, fontWeight: FontWeight.bold)),
                      Text(
                        AppStrings.viewAll.tr,
                        style: GoogleFonts.urbanist(
                            color: AppColor.primaryColor,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: Get.height * 0.01),
              Obx(
                () => WatchHistory.mainWatchHistory.isEmpty
                    ? const Offstage()
                    : SizedBox(
                        height: 180,
                        width: Get.width,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: ListView.builder(
                            itemCount: WatchHistory.mainWatchHistory.length,
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.only(left: 5, right: 15),
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              // ✅ Extract safely at the top
                              final item = WatchHistory.mainWatchHistory[index];
                              final String videoId =
                                  item["videoId"]?.toString() ?? "";
                              final String videoUrl =
                                  item["videoUrl"]?.toString() ?? "";
                              final String videoImage =
                                  item["videoImage"]?.toString() ?? "";
                              final String videoTitle =
                                  item["videoTitle"]?.toString() ?? "";
                              final String channelName =
                                  item["channelName"]?.toString() ?? "";
                              final int videoTime = int.tryParse(
                                      item["videoTime"]?.toString() ?? "0") ??
                                  0;
                              final int videoType = item["videoType"] ?? 1;

                              return GestureDetector(
                                onTap: () {
                                  if (videoType == 1) {
                                    Get.to(NormalVideoDetailsView(
                                      videoId: videoId,
                                      videoUrl: videoUrl,
                                    ));
                                  } else {
                                    Get.to(ShortsVideoDetailsView(
                                      videoId: videoId,
                                      videoUrl: videoUrl,
                                    ));
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: SizedBox(
                                    width: 175,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Stack(
                                          children: [
                                            Container(
                                              clipBehavior: Clip.hardEdge,
                                              height: 125,
                                              width: 175,
                                              decoration: BoxDecoration(
                                                color: isDarkMode.value
                                                    ? AppColor.secondDarkMode
                                                    : AppColor.grey_400,
                                                borderRadius:
                                                    BorderRadius.circular(19),
                                              ),
                                              child: PreviewVideoImage(
                                                videoId: videoId,
                                                videoImage: videoImage,
                                              ),
                                            ),
                                            Positioned(
                                              bottom: 10,
                                              right: 10,
                                              child: Container(
                                                alignment: Alignment.center,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 5),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(7),
                                                  color: AppColor.black,
                                                ),
                                                child: Text(
                                                  CustomFormatTime.convert(
                                                      videoTime),
                                                  style: GoogleFonts.urbanist(
                                                      color: AppColor.white,
                                                      fontSize: 11),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: Get.height * 0.01),
                                        SizedBox(
                                          width: 175,
                                          child: Text(
                                            videoTitle,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.urbanist(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 175,
                                          child: Text(
                                            channelName,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.urbanist(
                                                fontSize: 12,
                                                color: AppColor.grey),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
              ),
              const Divider(indent: 15, endIndent: 15),
              const SizedBox(height: 10),
              LibraryItem(
                iconPath: AppIcons.boldPlay,
                title: AppStrings.yourVideos.tr,
                callback: () {
                  if (Database.isChannel && Database.channelId != null) {
                    // if (controller.mainChannelVideos[0] == null || (controller.mainChannelVideos[0]?.isEmpty ?? true)) {
                    GetChannelVideoApiClass.startPagination[0] = 0;
                    GetChannelVideoApiClass.startPagination[1] = 0;
                    controller.mainChannelVideos[0] = null;
                    controller.mainChannelVideos[1] = null;
                    controller.typeWiseGetChannelVideo(0);

                    // }
                    Get.to(() => const YourVideoPageView());
                  } else {
                    CustomToast.show(AppStrings.pleaseCreateChannel.tr);
                  }
                },
              ),
              const SizedBox(height: 15),
              LibraryItem(
                iconPath: AppIcons.boldDownload,
                title: AppStrings.download.tr,
                callback: () {
                  if (DownloadHistory.mainDownloadHistory.isEmpty) {
                    DownloadHistory.onGet();
                  }
                  Get.to(() => const DownloadView());
                },
              ),
              const SizedBox(height: 10),
              const Divider(indent: 15, endIndent: 15),
              SizedBox(height: Get.height * 0.01),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Text(
                      AppStrings.playlists.tr,
                      style: GoogleFonts.urbanist(
                          fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              LibraryItem(
                  iconPath: AppIcons.plus,
                  title: AppStrings.newPlaylist.tr,
                  callback: () {
                    if (Database.isChannel && Database.channelId != null) {
                      controller.playList.clear();
                      Get.to(const CreatePlayListView());
                    } else {
                      CustomToast.show(AppStrings.pleaseCreateChannel.tr);
                    }
                  }),
              const SizedBox(height: 15),
              LibraryItem(
                iconPath: AppIcons.timerHistory,
                title: AppStrings.watchLater.tr,
                callback: () {
                  if (controller.mainWatchLaterVideos == null ||
                      (controller.mainWatchLaterVideos?.isEmpty ?? true)) {
                    controller.onGetWatchLaterVideo();
                  }
                  Get.to(() => const WatchLaterView());
                },
              ),
              const SizedBox(height: 20),
              SizedBox(height: Get.height * 0.03),
            ],
          ),
        ),
      ),
    );
  }
}

class LibraryItem extends StatelessWidget {
  const LibraryItem(
      {super.key,
      required this.title,
      required this.iconPath,
      required this.callback});

  final String title;
  final String iconPath;
  final void Function() callback;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: callback,
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Row(
          children: [
            Container(
              alignment: Alignment.centerLeft,
              child: Obx(
                () => CircleAvatar(
                  radius: 23,
                  backgroundColor: isDarkMode.value
                      ? const Color(0xFF31252F)
                      : const Color(0xFFFFF1F3),
                  child:
                      Image(image: AssetImage(iconPath), height: 18, width: 18),
                ),
              ),
            ),
            SizedBox(width: Get.width * 0.03),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.urbanist(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                // subTitle == null ? const Offstage() : Text(subTitle!, style: GoogleFonts.urbanist(fontSize: 12, color: AppColors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// GestureDetector(
//   onTap: () {},
//   child: Row(
//     children: [
//       Text(
//         AppStrings.recentlyAdded,
//         style: GoogleFonts.urbanist(
//           fontSize: 16,
//           fontWeight: FontWeight.bold,
//           color: AppColors.primaryColor,
//         ),
//       ),
//       SizedBox(width: SizeConfig.blockSizeHorizontal * 2),
//       const ImageIcon(
//         AssetImage(AppIcons.arrowDown),
//         color: AppColors.primaryColor,
//       ),
//     ],
//   ),
// ),
// HistoryScreenButton2(
//   logo: AppIcons.likeBold,
//   name: AppStrings.likedVideos,
//   onTap: () {},
//   subTitle: '260 videos',
// ),
// SizedBox(
//   height: SizeConfig.blockSizeVertical * 1.5,
// ),
// GestureDetector(
//   onTap: () {
//     Get.to(
//       () => const MyFavoriteSongsScreen(),
//     );
//   },
//   child: Row(
//     children: [
//       Container(
//         margin: const EdgeInsets.only(
//           left: 13,
//         ),
//         decoration: const BoxDecoration(
//           image: DecorationImage(
//             image: AssetImage(AppIcons.songsImage),
//           ),
//         ),
//         height: 40,
//         width: 40,
//       ),
//       SizedBox(
//         width: SizeConfig.blockSizeHorizontal * 3,
//       ),
//       Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             AppStrings.myFavoriteSongs,
//             style: GoogleFonts.urbanist(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold),
//           ),
//           SizedBox(
//             height: SizeConfig.blockSizeVertical * 0.5,
//           ),
//           Text(
//             "125 videos",
//             style: GoogleFonts.urbanist(
//               fontSize: 12,
//               color: AppColors.grey,
//             ),
//           ),
//         ],
//       ),
//     ],
//   ),
// ),
