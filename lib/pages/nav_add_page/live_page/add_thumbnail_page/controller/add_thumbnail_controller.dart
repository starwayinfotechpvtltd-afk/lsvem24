import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:metube/custom/custom_method/custom_toast.dart';
import 'package:metube/custom/custom_ui/loader_ui.dart';
import 'package:metube/database/database.dart';
import 'package:metube/pages/custom_pages/file_upload_page/convert_video_image_api.dart';
import 'package:metube/pages/nav_add_page/live_page/go_live_page/api/create_live_user_api.dart';
import 'package:metube/pages/nav_add_page/live_page/view/live_view.dart';
import 'package:metube/utils/colors/app_color.dart';
import 'package:metube/utils/settings/app_settings.dart';
import 'package:metube/utils/string/app_string.dart';

class AddThumbnailController extends GetxController {
  TextEditingController titleController = TextEditingController();

  @override
  void onInit() {
    AppSettings.pickImagePath.value = "";
    super.onInit();
  }

  void onGoLive() async {
    if (AppSettings.pickImagePath.value == "") {
      CustomToast.show(AppStrings.pleaseAddThumbnail.tr);
    } else if (titleController.text.trim().isEmpty) {
      CustomToast.show(AppStrings.pleaseEnterTitle.tr);
    } else {
      Get.dialog(const LoaderUi(color: AppColor.white), barrierDismissible: false);

      final thumbnail = await ConvertVideoImageApi.callApi(AppSettings.pickImagePath.value, true);

      if (thumbnail != null) {
        final liveHistoryId = await CreateLiveUserApi.callApi(
          loginUserId: Database.loginUserId ?? "",
          liveType: 1,
          thumbnail: thumbnail,
          title: titleController.text.trim(),
        );

        Get.close(2);

        if (liveHistoryId != null) {
          AppSettings.showLog("liveHistoryId => $liveHistoryId");

          Get.to(
            () => LivePage(
              isHost: true,
              localUserID: Database.loginUserId!,
              localUserName: "Seller",
              roomID: liveHistoryId,
            ),
          );
        }
      }
    }
  }
}
