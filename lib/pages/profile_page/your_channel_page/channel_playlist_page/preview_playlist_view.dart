import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:metube/custom/custom_method/custom_format_timer.dart';
import 'package:metube/main.dart';
import 'package:metube/pages/profile_page/your_channel_page/channel_playlist_page/channel_playlist_model.dart';
import 'package:metube/pages/profile_page/your_channel_page/main_page/your_channel_controller.dart';
import 'package:metube/pages/video_details_page/normal_video_details_view.dart';
import 'package:metube/utils/colors/app_color.dart';
import 'package:metube/utils/config/size_config.dart';
import 'package:metube/utils/icons/app_icons.dart';
import 'package:metube/utils/services/preview_image.dart';
import 'package:metube/utils/string/app_string.dart';

class PreviewPlaylistView extends StatelessWidget {
  const PreviewPlaylistView({super.key, required this.channelName, required this.playListName, required this.videos});

  final String channelName;
  final String playListName;
  final List<Videos> videos;
  @override
  Widget build(BuildContext context) {
    final yourChannelController = Get.find<YourChannelController>();
    return Scaffold(
        appBar: AppBar(
          systemOverlayStyle: const SystemUiOverlayStyle(statusBarColor: Colors.transparent, statusBarBrightness: Brightness.dark),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading:
              GestureDetector(child: Image.asset(AppIcons.arrowBack, color: isDarkMode.value ? AppColor.white : AppColor.black).paddingOnly(left: 15), onTap: () => Get.back()),
          leadingWidth: 33,
          title: Text(AppStrings.yourPlayList.tr, style: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: videos.length,
            padding: const EdgeInsets.only(top: 0, bottom: 50, left: 10, right: 10),
            itemBuilder: (context, index) {
  final video = videos[index];

  return Padding(
    padding: const EdgeInsets.only(top: 10),
    child: GestureDetector(
      onTap: () {
        yourChannelController.selectedPlayListVideo = index;

        Get.to(
          () => NormalVideoDetailsView(
            videoId: video.videoId ?? "",
            videoUrl: video.videoUrl ?? "",
            isPlayList: true,
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
                    borderRadius: BorderRadius.circular(20),
                    color: isDarkMode.value
                        ? AppColor.secondDarkMode
                        : AppColor.grey_400,
                  ),
                  child: PreviewVideoImage(
                    videoId: video.videoId ?? "",
                    videoImage: video.videoImage ?? "",
                  ),
                ),
              ),
              Positioned(
                bottom: 10,
                right: 10,
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(7),
                    color: AppColor.black,
                  ),
                  child: Text(
                    CustomFormatTime.convert(
                      int.tryParse(video.videoTime.toString()) ?? 0,
                    ),
                    style: GoogleFonts.urbanist(
                      color: AppColor.white,
                      fontSize: 11,
                    ),
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
                  video.videoName ?? "",
                  maxLines: 3,
                  style: GoogleFonts.urbanist(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: SizeConfig.blockSizeVertical * 1),
                Text(
                  channelName,
                  style: GoogleFonts.urbanist(
                    fontSize: 12,
                    color: isDarkMode.value
                        ? AppColor.white.withOpacity(0.7)
                        : AppColor.black.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          const Offstage(),
        ],
      ),
    ),
  );
},
          ),
        ));
  }
}
