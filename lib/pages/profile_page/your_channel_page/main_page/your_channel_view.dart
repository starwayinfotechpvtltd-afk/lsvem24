import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:metube/custom/custom_method/custom_check_internet.dart';
import 'package:metube/custom/custom_method/custom_format_number.dart';
import 'package:metube/custom/custom_ui/loader_ui.dart';
import 'package:metube/custom/shimmer/channel_profile_shimmer_ui.dart';
import 'package:metube/database/database.dart';
import 'package:metube/main.dart';
import 'package:metube/pages/custom_pages/network_issue_page/network_issue_view.dart';
import 'package:metube/pages/custom_pages/report_page/custom_channel_report_view.dart';
import 'package:metube/pages/nav_shorts_page/nav_shorts_details_view.dart';
import 'package:metube/pages/nav_subscription_page/subscribe_channel_api.dart';
import 'package:metube/pages/profile_page/your_channel_page/main_page/your_channel_controller.dart';
import 'package:metube/utils/colors/app_color.dart';
import 'package:metube/utils/icons/app_icons.dart';
import 'package:metube/utils/services/preview_image.dart';
import 'package:metube/utils/settings/app_settings.dart';
import 'package:metube/utils/string/app_string.dart';
import 'package:metube/utils/utils.dart';
import 'package:metube/widget/subscribe_premium_channel_bottom_sheet.dart';
import 'package:metube/widget/subscribed_success_dialog.dart';

class YourChannelView extends StatefulWidget {
  const YourChannelView({
    super.key,
    required this.loginUserId,
    required this.channelId,
  });

  final String loginUserId;
  final String channelId;

  @override
  State<YourChannelView> createState() => _YourChannelViewState();
}

class _YourChannelViewState extends State<YourChannelView> {
  final _controller = Get.find<YourChannelController>();
  List tabBarItem = ["HOME".tr, "PLAYLISTS".tr, "VIDEOS".tr, "ABOUT".tr];

  @override
  void initState() {
    _controller.init(widget.loginUserId, widget.channelId);

    super.initState();
  }

  @override
  void dispose() {
    _controller.onClear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Obx(
        () => Visibility(
          visible: _controller.isPaginationLoading.value,
          child: LinearProgressIndicator(color: AppColor.primaryColor, backgroundColor: AppColor.grey_300),
        ),
      ),
      appBar: AppBar(
        elevation: 0,
        leadingWidth: 60,
        leading: IconButtonUi(
          callback: () => Get.back(),
          icon: Obx(
            () => Image.asset(AppIcons.arrowBack, height: 20, width: 20, color: isDarkMode.value ? AppColor.white : AppColor.black),
          ),
        ),
        centerTitle: AppSettings.isCenterTitle,
        title: Text(AppStrings.channelDetails.tr),
        actions: [
          Visibility(
            visible: (_controller.channelId != (Database.channelId ?? "")),
            child: Padding(
              padding: const EdgeInsets.only(right: 20),
              child: GestureDetector(  
                onTap: () {
                  CustomChannelReportView.show();
                },
                child: Icon(
                  Icons.more_vert,
                  size: 25,
                  color: isDarkMode.value ? AppColor.white : AppColor.black,
                ),
              ),
            ),
          ),
        ],
      ),
      body: !CustomCheckInternet.isConnect.value
          ? const NetworkIssueView()
          : GetBuilder<YourChannelController>(
              id: "onChangeScrollController",
              builder: (controller) {
                    if (controller.channelHomeModel == null) {
                      return const ChannelProfileShimmerUi();
                    }

                    if (controller.tabBarPage.isEmpty) {
                      return const SizedBox();
                    }

                    if (controller.selectedTab >= controller.tabBarPage.length) {
                      return const SizedBox();
                    }

                    return NestedScrollView(
                controller: controller.selectedTab == 0
                    ? controller.homeScrollController
                    : controller.selectedTab == 1
                        ? controller.playListScrollController
                        : controller.selectedTab == 2
                            ? controller.selectedVideoType == 0
                                ? controller.channelNormalVideoController
                                : controller.channelShortVideoController
                            : null,
                floatHeaderSlivers: true,
                headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                  return <Widget>[
                    SliverList(
                      delegate: SliverChildListDelegate(
                        [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const SizedBox(height: 10),
                              GetBuilder<YourChannelController>(
                                id: "onGetChannelHomeVideo",
                                builder: (controller) => controller.channelHomeModel == null
                                    ? const ChannelProfileShimmerUi()
                                    : Column(
                                        children: [
                                          PreviewProfileImage(
                                            size: 100,
                                            id: widget.channelId,
                                            image: controller.channelHomeModel?.channelImage ?? "",
                                            fit: BoxFit.cover,
                                          ),
                                          const SizedBox(height: 5), //  [0-15]
                                          SizedBox(
                                            width: Get.width / 1.5,
                                            child: Center(
                                              child: Text(
                                                controller.channelHomeModel?.channelName ?? "",
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                                style: GoogleFonts.urbanist(fontSize: 22, fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                          ),

                                          Obx(
                                            () => Text(
                                                "${controller.countSubscribes} ${AppStrings.subscribes.tr} • ${CustomFormatNumber.convert(controller.channelHomeModel?.totalVideosOfChannel ?? 0)} ${AppStrings.videos.tr}",
                                                style: GoogleFonts.urbanist(color: AppColor.grey, fontSize: 14)),
                                          ),
                                          const SizedBox(height: 10),
                                          Visibility(
                                            visible: (Database.channelId ?? "") != controller.channelId,
                                            child: Column(
                                              children: [
                                                Obx(
                                                  () => Visibility(
                                                    visible: controller.isSubscribe.value || (controller.channelHomeModel?.channelType ?? 0) == 1,
                                                    child: GestureDetector(
                                                      onTap: () async {
                                                        if (controller.isSubscribe.value) {
                                                          controller.countSubscribes--;
                                                        } else {
                                                          controller.countSubscribes++;
                                                        }
                                                        controller.isSubscribe.value = !controller.isSubscribe.value;
                                                        await SubscribeChannelApiClass.callApi(controller.channelId);
                                                      },
                                                      child: Container(
                                                        width: 130,
                                                        height: 50,
                                                        alignment: Alignment.center,
                                                        decoration: BoxDecoration(
                                                          color: controller.isSubscribe.value ? Colors.transparent : AppColor.primaryColor,
                                                          borderRadius: BorderRadius.circular(25),
                                                          border: Border.all(color: AppColor.primaryColor, width: 2),
                                                        ),
                                                        child: Text(
                                                          controller.isSubscribe.value ? AppStrings.subscribed.tr : AppStrings.subscribe.tr,
                                                          style: GoogleFonts.urbanist(
                                                            color: controller.isSubscribe.value ? AppColor.primaryColor : AppColor.white,
                                                            fontSize: 16,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Obx(
                                                  () => Visibility(
                                                    visible: !controller.isSubscribe.value && (controller.channelHomeModel?.channelType ?? 0) == 2,
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        SubscribePremiumChannelBottomSheet.onShow(
                                                          coin: (controller.channelHomeModel?.subscriptionCost ?? 0).toString(),
                                                          callback: () async {
                                                            Get.dialog(const LoaderUi(), barrierDismissible: false);
                                                            final bool isSuccess = await SubscribeChannelApiClass.callApi(controller.channelId);

                                                            Get.close(2);

                                                            if (isSuccess) {
                                                              SubscribedSuccessDialog.show(context);
                                                              await 1.seconds.delay();
                                                              if (mounted) {
                                                                    await controller.init(widget.loginUserId, widget.channelId);
                                                                  }
                                                            }
                                                          },
                                                        );
                                                      },
                                                      child: Container(
                                                        height: 50,
                                                        width: 300,
                                                        decoration: BoxDecoration(
                                                          color: controller.isSubscribe.value ? Colors.transparent : AppColor.primaryColor,
                                                          borderRadius: BorderRadius.circular(25),
                                                          border: Border.all(color: AppColor.primaryColor, width: 2),
                                                        ),
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            Text(
                                                              controller.isSubscribe.value ? AppStrings.subscribed.tr : AppStrings.subscribe.tr,
                                                              style: GoogleFonts.urbanist(
                                                                color: controller.isSubscribe.value ? AppColor.primaryColor : AppColor.white,
                                                                fontSize: 16,
                                                                fontWeight: FontWeight.bold,
                                                              ),
                                                            ),
                                                            50.width,
                                                            Image.asset(AppIcons.coin, width: 23),
                                                            5.width,
                                                            Text(
                                                              "${controller.channelHomeModel?.subscriptionCost ?? 0} Per Month",
                                                              style: GoogleFonts.urbanist(
                                                                color: controller.isSubscribe.value ? AppColor.primaryColor : AppColor.white,
                                                                fontSize: 16,
                                                                fontWeight: FontWeight.bold,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                              const SizedBox(height: 10),
                            ],
                          ),
                        ],
                      ),
                    ),
                    PreferredSize(
                      preferredSize: const Size.fromHeight(50),
                      child: SliverAppBar(
                        toolbarHeight: 0,
                        pinned: true,
                        floating: true,
                        bottom: PreferredSize(
                          preferredSize: const Size.fromHeight(50),
                          child: SizedBox(
                            height: 50,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                for (int i = 0; i < 4; i++)
                                  GetBuilder<YourChannelController>(
                                    id: "onChangeTabBar",
                                    builder: (controller) => GestureDetector(
                                      onTap: () => controller.onChangeTabBar(i),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                        decoration: BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(color: controller.selectedTab == i ? AppColor.primaryColor : Colors.transparent, width: 2),
                                          ),
                                        ),
                                        child: Text(
                                          tabBarItem[i],
                                          style: TextStyle(
                                            color: controller.selectedTab == i ? AppColor.primaryColor : AppColor.grey,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ];
                },
                body: PageView.builder(
                  onPageChanged: (value) => _controller.onChangeTabBar(value),
                  itemCount: tabBarItem.length,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) => GetBuilder<YourChannelController>(
                    id: "onChangeTabBar",
                    builder: (controller) {
                      if (controller.tabBarPage.isEmpty) {
                        return const SizedBox();
                      }

                      if (controller.selectedTab >= controller.tabBarPage.length) {
                        return const SizedBox();
                      }

                      return controller.tabBarPage[controller.selectedTab];
                    },
                  ),
                ),
              );
            }
            ),
    );
  }
}

/////-----------------------------
// NestedScrollView(
// // floatHeaderSlivers: true,
// physics: NeverScrollableScrollPhysics(),
// headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
// return <Widget>[
// SliverList(
// delegate: SliverChildListDelegate(
// [
// GetBuilder<YourChannelController>(
// id: "onGetChannelHomeVideo",
// builder: (controller) => controller.channelHomeModel == null
// ? const LoaderUi()
//     : Column(
// children: [
// Container(
// height: 100,
// width: 100,
// clipBehavior: Clip.antiAlias,
// decoration: const BoxDecoration(shape: BoxShape.circle),
// child: ConvertedChannelImageView(imagePath: controller.channelHomeModel!.channelImage!),
// ),
// SizedBox(height: SizeConfig.blockSizeVertical * 2),
// Text(
// controller.channelHomeModel!.channelName!,
// style: GoogleFonts.urbanist(fontSize: 22, fontWeight: FontWeight.bold),
// ),
// SizedBox(height: SizeConfig.blockSizeVertical * 0.5),
// Text(
// "${controller.channelHomeModel!.totalSubscribers} subscribers • ${FormatNumber.convert(controller.channelHomeModel!.totalVideosOfChannel!)} videos",
// style: GoogleFonts.urbanist(color: AppColors.grey, fontSize: 14)),
// SizedBox(height: SizeConfig.blockSizeVertical * 1.5),
// Obx(
// () => GestureDetector(
// onTap: () async {
// controller.isSubscribe.value = !controller.isSubscribe.value;
// await SubscribeChannelApiClass.callApi(controller.channelId);
// },
// child: Container(
// padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
// decoration: BoxDecoration(
// color: controller.isSubscribe.value ? Colors.transparent : AppColors.primaryColor,
// borderRadius: BorderRadius.circular(25),
// border: Border.all(color: AppColors.primaryColor, width: 2),
// ),
// child: Text(
// controller.isSubscribe.value ? "Subscribed" : "Subscribe",
// style: GoogleFonts.urbanist(
// color: controller.isSubscribe.value ? AppColors.primaryColor : AppColors.white,
// fontSize: 16,
// fontWeight: FontWeight.bold,
// ),
// ),
// ),
// ),
// ),
// const SizedBox(height: 20),
// ],
// ),
// ),
// ],
// ),
// ),
// PreferredSize(
// preferredSize: const Size.fromHeight(50),
// child: SliverAppBar(
// toolbarHeight: 0,
// pinned: true,
// floating: true,
// bottom: PreferredSize(
// preferredSize: const Size.fromHeight(50),
// child: Container(
// color: AppColors.white,
// child: Row(
// mainAxisAlignment: MainAxisAlignment.spaceAround,
// children: [
// for (int i = 0; i < 4; i++)
// GetBuilder<YourChannelController>(
// id: "onChangeTabBar",
// builder: (controller) => GestureDetector(
// onTap: () => controller.onChangeTabBar(i),
// child: Container(
// padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
// decoration: BoxDecoration(
// border: Border(
// bottom: BorderSide(
// color:
// controller.selectedTab == i ? AppColors.primaryColor : Colors.transparent,
// width: 2),
// ),
// ),
// child: Text(
// controller.tabBarItem[i],
// style: TextStyle(
// color: controller.selectedTab == i ? AppColors.primaryColor : AppColors.grey,
// fontSize: 12,
// ),
// ),
// ),
// ),
// ),
// ],
// )
// // TabBar(
// //   labelColor: AppColors.primaryColor,
// //   indicatorColor: AppColors.primaryColor,
// //   labelStyle: labelStyle,
// //   unselectedLabelColor: AppColors.grey,
// //   controller: _tabBarController,
// //   indicatorSize: TabBarIndicatorSize.tab,
// //   tabs: const [
// //     Tab(child: Text("HOME", style: TextStyle(fontSize: 11))),
// //     Tab(child: Text("PLAYLISTS", style: TextStyle(fontSize: 11))),
// //     Tab(child: Text("VIDEOS", style: TextStyle(fontSize: 11))),
// //     Tab(child: Text("ABOUT", style: TextStyle(fontSize: 11))),
// //   ],
//
// // ),
// ),
// ),
// ),
// ),
// ];
// },
// body: PageView.builder(
// onPageChanged: (value) => _controller.onChangeTabBar(value),
// itemCount: _controller.tabBarItem.length,
// itemBuilder: (context, index) => GetBuilder<YourChannelController>(
// id: "onChangeTabBar",
// builder: (controller) => controller.tabBarPage[controller.selectedTab],
// ),
// ),
// ),
///--------------------

// TabBarView(
//   controller: _tabBarController,
//   children: const [
//     ChannelHomeTabView(),
//     ChannelPlayListTabView(),
//     ChannelVideoTabView(),
//     ChannelAboutTabView(),
//   ],
// ),

// CustomScrollView(
//   slivers: <Widget>[
//     SliverList(
//       delegate: SliverChildListDelegate(
//         <Widget>[
//           GetBuilder<YourChannelController>(
//             builder: (controller) => Column(
//               children: [
//                 Container(
//                   height: 100,
//                   width: 100,
//                   clipBehavior: Clip.antiAlias,
//                   decoration: const BoxDecoration(shape: BoxShape.circle),
//                   child: ConvertedChannelImageView(imagePath: AppSettings.userProfileData!.user!.image!),
//                 ),
//                 SizedBox(height: SizeConfig.blockSizeVertical * 2),
//                 Text(
//                   controller.channelHomeModel?.channelName ?? "*** ***** ***",
//                   style: GoogleFonts.urbanist(fontSize: 22, fontWeight: FontWeight.bold),
//                 ),
//                 SizedBox(height: SizeConfig.blockSizeVertical * 0.5),
//                 Text(
//                     "${controller.channelHomeModel?.totalSubscribers} subscribers • ${FormatNumber.convert(controller.channelHomeModel?.totalVideosOfChannel ?? 0)} videos",
//                     style: GoogleFonts.urbanist(color: AppColors.grey, fontSize: 14)),
//                 SizedBox(height: SizeConfig.blockSizeVertical * 1.5),
//                 Obx(
//                   () => GestureDetector(
//                     onTap: () async {
//                       controller.isSubscribe.value = !controller.isSubscribe.value;
//
//                       await SubscribeChannelApiClass.callApi(widget.channelId);
//                     },
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
//                       decoration: BoxDecoration(
//                         color: (controller.isSubscribe.value) ? Colors.transparent : AppColors.primaryColor,
//                         borderRadius: BorderRadius.circular(25),
//                         border: Border.all(color: AppColors.primaryColor, width: 2),
//                       ),
//                       child: Text(
//                         (controller.isSubscribe.value) ? "Subscribed" : "Subscribe",
//                         style: GoogleFonts.urbanist(
//                           color: (controller.isSubscribe.value) ? AppColors.primaryColor : AppColors.white,
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//               ],
//             ),
//           ),
//         ],
//       ),
//     ),
//     SliverAppBar(
//       elevation: 0,
//       automaticallyImplyLeading: false,
//       backgroundColor: Colors.transparent,
//       pinned: true,
//       flexibleSpace: PreferredSize(
//         preferredSize: const Size.fromHeight(40.0),
//         child: Container(
//           color: AppColors.white,
//           child: TabBar(
//             labelColor: AppColors.primaryColor,
//             indicatorColor: AppColors.primaryColor,
//             labelStyle: labelStyle,
//             unselectedLabelColor: AppColors.grey,
//             controller: _tabBarController,
//             indicatorSize: TabBarIndicatorSize.tab,
//             tabs: const [
//               Tab(child: Text("HOME", style: TextStyle(fontSize: 11))),
//               Tab(child: Text("PLAYLISTS", style: TextStyle(fontSize: 11))),
//               Tab(child: Text("VIDEOS", style: TextStyle(fontSize: 11))),
//               Tab(child: Text("ABOUT", style: TextStyle(fontSize: 11))),
//             ],
//           ),
//         ),
//       ),
//     ),
//     SliverFillRemaining(
//       child: TabBarView(
//         controller: _tabBarController,
//         children: const [
//           ChannelHomeTabView(),
//           ChannelPlayListTabView(),
//           ChannelVideoTabView(),
//           ChannelAboutTabView(),
//         ],
//       ),
//     ),
//   ],
// ),

// Column(
//   children: [
//     Container(
//       height: 100,
//       width: 100,
//       clipBehavior: Clip.antiAlias,
//       decoration: const BoxDecoration(shape: BoxShape.circle),
//       child: ConvertedChannelImageView(imagePath: AppSettings.userProfileData!.user!.image!),
//     ),
//     SizedBox(height: SizeConfig.blockSizeVertical * 2),
//     Text(
//       AppSettings.userProfileData?.user?.fullName ?? "*** ***** ***",
//       style: titalstyle1,
//     ),
//     SizedBox(height: SizeConfig.blockSizeVertical * 0.5),
//     Text(
//       AppSettings.userProfileData?.user?.email ?? "**********",
//       style: GoogleFonts.urbanist(color: AppColors.grey),
//     ),
//     const SizedBox(height: 20),
//     TabBar(
//       labelColor: AppColors.primaryColor,
//       indicatorColor: AppColors.primaryColor,
//       labelStyle: labelStyle,
//       unselectedLabelColor: AppColors.grey,
//       controller: _tabBarController,
//       indicatorSize: TabBarIndicatorSize.tab,
//       tabs: const [
//         Tab(child: Text("HOME", style: TextStyle(fontSize: 11))),
//         Tab(child: Text("PLAYLISTS", style: TextStyle(fontSize: 11))),
//         Tab(child: Text("VIDEOS", style: TextStyle(fontSize: 11))),
//         Tab(child: Text("ABOUT", style: TextStyle(fontSize: 11))),
//       ],
//     ),
//     Expanded(
//       child: TabBarView(
//         controller: _tabBarController,
//         children: const [
//           ChannelHomeTabView(),
//           ChannelPlayListTabView(),
//           ChannelVideoTabView(),
//           ChannelAboutTabView(),
//         ],
//       ),
//     ),
//   ],
// ),
