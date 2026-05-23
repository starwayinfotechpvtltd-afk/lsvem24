import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:metube/database/database.dart';
import 'package:metube/main.dart';
import 'package:metube/pages/nav_home_page/controller/nav_home_controller.dart';
import 'package:metube/pages/nav_home_page/widget/nav_home_widget.dart';
import 'package:metube/pages/notification_page/notification_view.dart';
import 'package:metube/pages/profile_page/earn_reward_page/earn_reward_view.dart';
import 'package:metube/pages/profile_page/main_page/profile_view.dart';
import 'package:metube/pages/search_page/search_view.dart';
import 'package:metube/pages/video_details_page/video_details_model.dart';
import 'package:metube/utils/colors/app_color.dart';
import 'package:metube/utils/icons/app_icons.dart';
import 'package:metube/utils/services/preview_image.dart';
import 'package:metube/utils/settings/app_settings.dart'; 
import 'package:metube/utils/string/app_string.dart';

VideoDetailsModel? videoDetailsModel;

class NavHomePageView extends StatefulWidget {
  const NavHomePageView({super.key});

  @override
  State<NavHomePageView> createState() => _NavHomePageViewState();
}

class _NavHomePageViewState extends State<NavHomePageView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leadingWidth: 100,
        backgroundColor: Colors.transparent,
        leading: const Padding(
          padding: EdgeInsets.only(left: 15),
          child: SizedBox(
            width: 150,
            height: 100,
            child: Image(
              image: AssetImage(AppIcons.logo),
              fit: BoxFit.contain,
            ),
          ),
        ),
        // titleSpacing: 10,
        // title: Text(AppStrings.appName.tr,
        //     style: GoogleFonts.urbanist(
        //         fontSize: 20, fontWeight: FontWeight.bold)),
        actions: [
          InkWell(
            onTap: () => Get.to(() => const SearchView(isSearchShorts: false)),
            child: Obx(
              () => Image.asset(
                AppIcons.search,
                width: 20,
                color: isDarkMode.value ? AppColor.white : AppColor.black,
              ),
            ),
          ),
          const SizedBox(width: 18),
          GestureDetector(
            onTap: () => Get.to(() => const NotificationPageView()),
            child: Obx(
              () => Image.asset(
                AppIcons.notification,
                width: 18,
                color: isDarkMode.value ? AppColor.white : AppColor.black,
              ),
            ),
          ),
          const SizedBox(width: 18),
          GestureDetector(
            onTap: () => Get.to(() => const EarnRewardView()),
            child: Image.asset(
              AppIcons.earnRewardIcon,
              width: 20,
            ),
          ),
          const SizedBox(width: 18),
          GestureDetector(
            onTap: () => Get.to(() => const ProfileView()),
            child: Obx(
              () => PreviewProfileImage(
                size: 35,
                id: Database.channelId ?? "",
                image: AppSettings.profileImage.value ?? "",
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 15),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          SizedBox(
            width: Get.width,
            height: 35,
            child: GetBuilder<NavHomeController>(
              id: "onChangeTab",
              builder: (controller) => ListView.builder(
                padding: EdgeInsets.zero,
                scrollDirection: Axis.horizontal,
                itemCount: controller.tabTitles.length,
                itemBuilder: (context, index) => GestureDetector(
                  onTap: () => controller.onChangeTab(index),
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    margin: const EdgeInsets.only(left: 10),
                    decoration: BoxDecoration(
                      color: controller.selectedTabIndex == index
                          ? AppColor.primaryColor
                          : AppColor.primaryColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Obx(
                      () => Text(
                        controller.tabTitles[index],
                        style: GoogleFonts.urbanist(
                          fontSize: 14,
                          color: controller.selectedTabIndex == index
                              ? isDarkMode.value
                                  ? AppColor.white
                                  : AppColor.white
                              : isDarkMode.value
                                  ? AppColor.white
                                  : AppColor.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: GetBuilder<NavHomeController>(
              id: "onChangeTab",
              builder: (controller) => controller.selectedTabIndex == 0
                  ? const AllTabWidget()
                  : controller.selectedTabIndex == 1
                      ? const PopularTabWidget()
                      : controller.selectedTabIndex == 2
                          ? const NewTabWidget()
                          : const LiveTabWidget(),
            ),
          ),
          Column(
            children: [
              GetBuilder<NavHomeController>(
                id: "onPagination",
                builder: (controller) => Visibility(
                  visible: controller.isLoadingPagination,
                  child: const LinearProgressIndicator(
                    backgroundColor: AppColor.grey,
                    color: AppColor.primaryColor,
                  ),
                ),
              ),
              Obx(
                () => Visibility(
                  visible: AppSettings.isUploading.value ?? false,
                  child: Container(
                    height: 38,
                    width: Get.width,
                    color: isDarkMode.value
                        ? AppColor.secondDarkMode
                        : Colors.white,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Obx(
                          () => Text(
                            AppSettings.uploadStatusMessage.value.isNotEmpty
                                ? AppSettings.uploadStatusMessage.value
                                : "${AppStrings.videoUploading.tr}...",
                            style: GoogleFonts.urbanist(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ).paddingOnly(left: 10),
                        ),
                        const SizedBox(height: 5),
                        const LinearProgressIndicator(
                            color: AppColor.primaryColor),
                      ],
                    ),
                  ),
                ),
              ),
              Obx(
                () => Visibility(
                  visible: AppSettings.isDownloading.value ?? false,
                  child: Container(
                    height: 38,
                    width: Get.width,
                    color: isDarkMode.value
                        ? AppColor.secondDarkMode
                        : Colors.white,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("${AppStrings.videoDownloading.tr}...",
                                style: GoogleFonts.urbanist(
                                    fontSize: 16, fontWeight: FontWeight.bold))
                            .paddingOnly(left: 10),
                        const SizedBox(height: 5),
                        const LinearProgressIndicator(
                            color: AppColor.primaryColor),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
