import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:metube/custom/custom_ui/data_not_found_ui.dart';
import 'package:metube/custom/custom_ui/loader_ui.dart';
import 'package:metube/database/database.dart';
import 'package:metube/main.dart';
import 'package:metube/pages/nav_add_page/live_page/api/get_live_users_api.dart';
import 'package:metube/pages/nav_add_page/live_page/view/live_view.dart';
import 'package:metube/pages/nav_shorts_page/nav_shorts_details_view.dart';
import 'package:metube/pages/nav_subscription_page/nav_subscription_controller.dart';
import 'package:metube/pages/profile_page/your_channel_page/main_page/your_channel_view.dart';
import 'package:metube/utils/colors/app_color.dart';
import 'package:metube/utils/icons/app_icons.dart';
import 'package:metube/utils/services/preview_image.dart';
import 'package:metube/utils/settings/app_settings.dart';
import 'package:metube/utils/string/app_string.dart';

class SubscribedChannelView extends GetView<NavSubscriptionPageController> {
  const SubscribedChannelView({super.key, required this.loginUserId});

  final String loginUserId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: AppSettings.isCenterTitle,
        leadingWidth: 60,
        leading: IconButtonUi(
          callback: () => Get.back(),
          icon: Obx(
            () => Image.asset(AppIcons.arrowBack, height: 20, width: 20, color: isDarkMode.value ? AppColor.white : AppColor.black),
          ),
        ),
        title: Text(
          "${AppStrings.channelList.tr} (${controller.mainSubscribedChannels?.length ?? 0})",
          style: GoogleFonts.urbanist(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: controller.mainSubscribedChannels == null
          ? const LoaderUi()
          : controller.mainSubscribedChannels!.isEmpty
              ? const DataNotFoundUi()
              : SingleChildScrollView(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: controller.mainSubscribedChannels!.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          if (GetLiveUsersApi.isLive(controller.mainSubscribedChannels![index].channelId!)) {
                            Get.to(
                              () => LivePage(
                                isHost: false,
                                localUserID: Database.loginUserId!,
                                localUserName: AppSettings.channelName.value,
                                roomID: GetLiveUsersApi.roomId(controller.mainSubscribedChannels![index].channelId!),
                              ),
                            )?.then(
                              (value) => Get.to(
                                YourChannelView(
                                  loginUserId: loginUserId,
                                  channelId: controller.mainSubscribedChannels![index].channelId!,
                                ),
                              ),
                            );
                          } else {
                            Get.to(
                              YourChannelView(
                                loginUserId: loginUserId,
                                channelId: controller.mainSubscribedChannels![index].channelId!,
                              ),
                            );
                          }
                        },
                        onDoubleTap: () => Get.to(
                          YourChannelView(
                            loginUserId: loginUserId,
                            channelId: controller.mainSubscribedChannels![index].channelId!,
                          ),
                        ),
                        child: ListTile(
                          leading: Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: controller.selectedChannel == index ? AppColor.primaryColor : Colors.transparent, width: 2),
                            ),
                            child: PreviewProfileImage(
                              size: 50,
                              id: controller.mainSubscribedChannels![index].channelId ?? "",
                              image: controller.mainSubscribedChannels![index].channelImage ?? "",
                              fit: BoxFit.cover,
                            ),
                          ),
                          title: Text(
                            controller.mainSubscribedChannels![index].channelName.toString(),
                            style: GoogleFonts.urbanist(fontWeight: FontWeight.bold),
                          ),
                          trailing: GetLiveUsersApi.isLive(controller.mainSubscribedChannels![index].channelId!)
                              ? Text(
                                  "Live",
                                  style: GoogleFonts.urbanist(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColor.primaryColor,
                                  ),
                                )
                              : null,
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

//   Padding(
//               padding: EdgeInsets.only(left: SizeConfig.blockSizeHorizontal * 3),
//               child: FilterChip(
//                 selected: isSelected,
//                 backgroundColor: isDarkMode.value ? AppColors.secondDarkMode : AppColors.white,
//                 selectedColor: AppColors.primaryColor,
//                 showCheckmark: false,
//                 labelStyle: GoogleFonts.urbanist(
//                   fontSize: 13,
//                   color: (isSelected == true) ? AppColors.white : AppColors.primaryColor,
//                   fontWeight: FontWeight.w800,
//                 ),
//                 elevation: 0,
//                 side: const BorderSide(color: AppColors.primaryColor),
//                 avatar: Image(
//                   image: const AssetImage(AppIcons.swap),
//                   height: 20,
//                   width: 20,
//                   color: (isSelected == true) ? AppColors.white : AppColors.primaryColor,
//                 ),
//                 label: const Text("Most Relevant"),
//                 onSelected: (bool value) {
//                   // setState(() {
//                   //   isSelected = value;
//                   // });
//                 },
//               ),
//             ),
