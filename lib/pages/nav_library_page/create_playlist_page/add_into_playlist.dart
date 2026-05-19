import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:metube/custom/custom_method/custom_toast.dart';
import 'package:metube/custom/custom_ui/data_not_found_ui.dart';
import 'package:metube/custom/custom_ui/loader_ui.dart';
import 'package:metube/database/database.dart';
import 'package:metube/main.dart';
import 'package:metube/pages/nav_library_page/create_playlist_page/add_into_play_list_api.dart';
import 'package:metube/pages/profile_page/your_channel_page/channel_playlist_page/channel_playlist_api.dart';
import 'package:metube/pages/profile_page/your_channel_page/channel_playlist_page/channel_playlist_model.dart';
import 'package:metube/utils/colors/app_color.dart';
import 'package:metube/utils/config/size_config.dart';
import 'package:metube/utils/services/preview_image.dart';
import 'package:metube/utils/string/app_string.dart';
import 'package:metube/utils/style/app_style.dart';

class AddIntoPlayList {
  static ChannelPlaylistModel? channelPlaylistModel;
  static RxList<PlayListsOfChannel>? mainPlayList;

  static RxBool isLoading = true.obs;
  static RxString selectedPlayList = "".obs;

  static Future<void> onGetPlayList(String channelId) async {
    channelPlaylistModel = await ChannelPlayListApi.callApi(channelId);
    isLoading.value = false;

    mainPlayList ??= <PlayListsOfChannel>[].obs;
    if (channelPlaylistModel?.playListsOfChannel != null && channelPlaylistModel!.playListsOfChannel!.isNotEmpty) {
      mainPlayList?.addAll(channelPlaylistModel!.playListsOfChannel!);
    } else {
      ChannelPlayListApi.startPagination--;
    }
  }

  static void onAddToPlayList(String channelId, String videoId) async {
    ChannelPlayListApi.startPagination = 0;
    mainPlayList?.clear();
    channelPlaylistModel = null;
    isLoading.value = true;
    onGetPlayList(channelId);

    Get.bottomSheet(
      backgroundColor: isDarkMode.value ? AppColor.secondDarkMode : AppColor.white,
      SizedBox(
        height: SizeConfig.screenHeight / 2,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
            const SizedBox(height: 10),
            Text(AppStrings.addToPlayList.tr, style: titalstyle1),
            const SizedBox(height: 5),
            const Divider(
              indent: 25,
              endIndent: 25,
              color: AppColor.grey,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Obx(
                () => isLoading.value
                    ? const LoaderUi()
                    : mainPlayList?.isEmpty ?? true
                        ? const DataNotFoundUi()
                        : SingleChildScrollView(
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: mainPlayList?.length ?? 0,
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              itemBuilder: (context, index) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: GestureDetector(
                                  onTap: () async {
                                    CustomToast.show(AppStrings.pleaseWait.tr);
                                    Get.back();
                                    await AddIntoPlayListApi.callApi(Database.loginUserId!, channelId, mainPlayList![index].id!, videoId);
                                  },
                                  child: Row(
                                    children: [
                                      Container(
                                        clipBehavior: Clip.hardEdge,
                                        height: 50,
                                        width: 50,
                                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: isDarkMode.value ? AppColor.secondDarkMode : AppColor.grey_400),
                                        child: PreviewVideoImage(
                                          videoId: mainPlayList![index].videos![0].videoId!,
                                          videoImage: mainPlayList![index].videos![0].videoImage!,
                                        ),
                                        // child: ConvertedPathView(
                                        //     imageVideoPath: controller.channelPlayList![index].videos![0].videoImage!),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text("${mainPlayList?[index].playListName ?? ""} (${mainPlayList?[index].totalVideo.toString() ?? "0"})",
                                                style: GoogleFonts.urbanist(fontSize: 16, fontWeight: FontWeight.w600)),
                                            Text(mainPlayList?[index].channelName ?? "", style: GoogleFonts.urbanist(fontSize: 14, color: AppColor.grey_400)),
                                          ],
                                        ),
                                      ),
                                      // Obx(() => Radio(value: mainPlayList?[index].id, groupValue: selectedPlayList.value, onChanged: (value) => selectedPlayList.value = value!))
                                    ],
                                  ),
                                ),
                              ),
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
