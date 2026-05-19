import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:metube/custom/custom_method/custom_profile_image.dart';
import 'package:metube/custom/custom_ui/data_not_found_ui.dart';
import 'package:metube/custom/custom_ui/loader_ui.dart';
import 'package:metube/database/database.dart';
import 'package:metube/main.dart';
import 'package:metube/pages/nav_shorts_page/nav_shorts_details_view.dart';
import 'package:metube/pages/notification_page/clear_notification_api.dart';
import 'package:metube/pages/notification_page/notification_controller.dart';
import 'package:metube/utils/colors/app_color.dart';
import 'package:metube/utils/config/size_config.dart';
import 'package:metube/utils/icons/app_icons.dart';
import 'package:metube/utils/services/preview_image.dart';
import 'package:metube/utils/settings/app_settings.dart';
import 'package:metube/utils/string/app_string.dart';

class NotificationPageView extends GetView<NotificationController> {
  const NotificationPageView({super.key});

  @override
  Widget build(BuildContext context) {
    controller.onGetNotification();
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 60,
        leading: IconButtonUi(
          callback: () => Get.back(),
          icon: Obx(
            () => Image.asset(AppIcons.arrowBack, height: 20, width: 20, color: isDarkMode.value ? AppColor.white : AppColor.black),
          ),
        ),
        elevation: 0,
        centerTitle: AppSettings.isCenterTitle,
        title: Text(
          AppStrings.notification.tr,
          style: GoogleFonts.urbanist(fontSize: 19, fontWeight: FontWeight.bold),
        ),
        actions: [
          GetBuilder<NotificationController>(
            id: "onGetNotification",
            builder: (controller) => (controller.mainNotifications == null || (controller.mainNotifications?.isEmpty ?? true))
                ? const Offstage()
                : IconButton(
                    icon: Text(AppStrings.clearAll.tr, style: GoogleFonts.urbanist(fontSize: 16, fontWeight: FontWeight.w600)),
                    onPressed: () {
                      Get.bottomSheet(
                        backgroundColor: isDarkMode.value ? AppColor.secondDarkMode : AppColor.white,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(40),
                            topLeft: Radius.circular(40),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(
                            left: SizeConfig.blockSizeHorizontal * 3,
                            right: SizeConfig.blockSizeHorizontal * 3,
                          ),
                          height: 180,
                          decoration: BoxDecoration(
                            color: isDarkMode.value ? AppColor.secondDarkMode : AppColor.white,
                            borderRadius: const BorderRadius.only(topRight: Radius.circular(40), topLeft: Radius.circular(40)),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const SizedBox(height: 10),
                              Container(
                                width: 30,
                                height: 3,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(60),
                                  color: isDarkMode.value ? AppColor.white.withOpacity(0.2) : AppColor.grey_200,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                AppStrings.clear.tr,
                                style: GoogleFonts.urbanist(
                                  fontSize: 22,
                                  color: isDarkMode.value ? AppColor.white : AppColor.logOutColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Divider(indent: 30, color: AppColor.grey_200, endIndent: 30),
                              const SizedBox(height: 5),
                              Text(
                                AppStrings.clearNotificationText.tr,
                                style: GoogleFonts.urbanist(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 15),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: () => Get.back(),
                                    child: Container(
                                      height: 45,
                                      width: 130,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(30),
                                        color: AppColor.primaryColor.withOpacity(0.2),
                                      ),
                                      child: Text(
                                        AppStrings.cancel.tr,
                                        style: GoogleFonts.urbanist(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: AppColor.primaryColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  GestureDetector(
                                    child: Container(
                                      height: 45,
                                      width: 130,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), color: AppColor.primaryColor),
                                      child: Text(
                                        AppStrings.yesClear.tr,
                                        style: GoogleFonts.urbanist(color: AppColor.white, fontWeight: FontWeight.bold, fontSize: 14),
                                      ),
                                    ),
                                    onTap: () async {
                                      Get.back();
                                      Get.dialog(const LoaderUi(), barrierDismissible: false);
                                      final response = await ClearNotificationApi.callApi(loginUserId: Database.loginUserId!);
                                      if (response) {
                                        controller.mainNotifications?.clear();
                                        controller.update(["onGetNotification"]);
                                      }
                                      Get.back();
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          SizedBox(width: SizeConfig.blockSizeHorizontal * 3),
        ],
      ),
      body: GetBuilder<NotificationController>(
        id: "onGetNotification",
        builder: (controller) => controller.mainNotifications == null
            ? const LoaderUi()
            : controller.mainNotifications!.isEmpty
                ? DataNotFoundUi(title: AppStrings.notificationNotAvailable.tr)
                : SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(10),
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.mainNotifications!.length,
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  clipBehavior: Clip.hardEdge,
                                  height: 30,
                                  width: 30,
                                  decoration: const BoxDecoration(shape: BoxShape.circle),
                                  // child: PreviewChannelImage(channelId: Database.channelId!, channelImage: Database.profileImage!),
                                  child: const CustomProfileImage(),
                                ),
                                SizedBox(width: Get.width * 0.03),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        controller.mainNotifications![index].message.toString(),
                                        style: GoogleFonts.urbanist(fontSize: 13, fontWeight: FontWeight.bold),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 3,
                                      ),
                                      SizedBox(height: SizeConfig.blockSizeVertical * 0.5),
                                      Text(
                                        controller.mainNotifications![index].time.toString(),
                                        style: GoogleFonts.urbanist(fontSize: 12, color: AppColor.grey),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: Get.width * 0.01),
                                Container(
                                  clipBehavior: Clip.hardEdge,
                                  height: 80,
                                  width: 120,
                                  decoration: BoxDecoration(color: isDarkMode.value ? AppColor.secondDarkMode : AppColor.grey_400, borderRadius: BorderRadius.circular(15)),
                                  child: PreviewVideoImage(
                                    videoId: controller.mainNotifications![index].videoId!,
                                    videoImage: controller.mainNotifications![index].videoImage!,
                                  ),
                                  // child: ConvertedPathView(
                                  //     imageVideoPath: controller.mainNotifications![index].videoImage!),
                                ),
                              ],
                            ),
                            SizedBox(height: SizeConfig.blockSizeVertical * 2),
                          ],
                        );
                      },
                    ),
                  ),
      ),
    );
  }
}
