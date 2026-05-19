import 'dart:core';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:metube/ads/google_ads/google_large_native_ad.dart';
import 'package:metube/ads/google_ads/google_small_native_ad.dart';
import 'package:metube/custom/custom_method/custom_check_internet.dart';
import 'package:metube/custom/custom_method/custom_format_timer.dart';
import 'package:metube/custom/custom_ui/data_not_found_ui.dart';
import 'package:metube/custom/custom_ui/loader_ui.dart';
import 'package:metube/custom/custom_ui/normal_video_ui.dart';
import 'package:metube/custom/custom_ui/short_video_ui.dart';
import 'package:metube/custom/custom_ui/small_video_widget.dart';
import 'package:metube/custom/shimmer/normal_video_shimmer_ui.dart';
import 'package:metube/custom/shimmer/shorts_list_shimmer_ui.dart';
import 'package:metube/custom/shimmer/video_list_shimmer_ui.dart';
import 'package:metube/database/database.dart';
import 'package:metube/main.dart';
import 'package:metube/pages/custom_pages/network_issue_page/network_issue_view.dart';
import 'package:metube/pages/nav_add_page/live_page/api/get_live_users_api.dart';
import 'package:metube/pages/nav_add_page/live_page/view/live_view.dart';
import 'package:metube/pages/nav_add_page/live_page/widget/socket_manager_controller.dart';
import 'package:metube/pages/nav_subscription_page/get_subscribed_channel_api.dart';
import 'package:metube/pages/nav_subscription_page/nav_subscription_controller.dart';
import 'package:metube/pages/nav_subscription_page/subscribed_channel_view.dart';
import 'package:metube/pages/notification_page/notification_view.dart';
import 'package:metube/pages/profile_page/main_page/profile_view.dart';
import 'package:metube/pages/search_page/search_view.dart';
import 'package:metube/pages/video_details_page/normal_video_details_view.dart';
import 'package:metube/pages/video_details_page/shorts_video_details_view.dart';
import 'package:metube/utils/colors/app_color.dart';
import 'package:metube/utils/config/size_config.dart';
import 'package:metube/utils/icons/app_icons.dart';
import 'package:metube/utils/services/preview_image.dart';
import 'package:metube/utils/settings/app_settings.dart';
import 'package:metube/utils/string/app_string.dart';
import 'package:metube/utils/style/app_style.dart';

class NavSubscriptionView extends GetView<NavSubscriptionPageController> {
  const NavSubscriptionView({super.key});

  @override
  Widget build(BuildContext context) {
    List videoTypes = ['video'.tr, 'shorts'.tr];
    List subscribeType = ["all".tr, "today".tr, "continueWatching".tr];

    if (Database.loginUserId != null) {
      GetLiveUsersApi.callApi(loginUserId: Database.loginUserId!);
    }
    controller.onGetSubscribedChannels();
    controller.selectedChannel = null;

    controller.selectedSubscribeType = 0;
    controller.selectedVideoType = 0;

    controller.mainAllChannelVideos[0] = null;
    controller.mainAllChannelVideos[1] = null;
    controller.mainAllChannelVideos[2] = null;

    controller.particularChannelVideos[0] = null;
    controller.particularChannelVideos[1] = null;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        AppSettings.navigationIndex.value = 0;
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.only(left: 15),
            child: GestureDetector(
              onTap: () {
                GetSubScribedChannelApiClass.callApi();
              },
              child: const Image(
                image: AssetImage(AppIcons.logo),
                fit: BoxFit.contain,
              ),
            ),
          ),
          leadingWidth: 45,
          titleSpacing: 10,
          title: Text(
            AppStrings.subscriptions.tr,
            style: GoogleFonts.urbanist(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
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
        ),
        bottomNavigationBar: Obx(
          () => Visibility(
            visible: controller.isPaginationLoading.value,
            child: LinearProgressIndicator(
                color: AppColor.primaryColor,
                backgroundColor: AppColor.grey_300),
          ),
        ),
        body: !CustomCheckInternet.isConnect.value
            ? const NetworkIssueView()
            : GetBuilder<NavSubscriptionPageController>(
                id: "onGetSubscribedChannels",
                builder: (controller) =>
                    controller.mainSubscribedChannels == null
                        ? const LoaderUi()
                        : controller.mainSubscribedChannels!.isEmpty
                            ? DataNotFoundUi(
                                title: AppStrings.noSubscribedChannel.tr)
                            : GetBuilder<NavSubscriptionPageController>(
                                id: "onChangeVideoType",
                                builder: (controller) => NestedScrollView(
                                      controller: controller.selectedChannel ==
                                              null
                                          ? null
                                          : controller.selectedVideoType == 0
                                              ? controller.normalVideoController
                                              : controller
                                                  .shortsVideoController,
                                      floatHeaderSlivers: true,
                                      headerSliverBuilder:
                                          (BuildContext context,
                                              bool innerBoxIsScrolled) {
                                        return <Widget>[
                                          SliverList(
                                            delegate: SliverChildListDelegate(
                                              [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      "${AppStrings.subscriptionsChannel.tr} (${controller.mainSubscribedChannels!.length})",
                                                      style:
                                                          GoogleFonts.urbanist(
                                                              fontSize: 17,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                    ),
                                                    GestureDetector(
                                                      onTap: () {
                                                        if (Database
                                                                .loginUserId ==
                                                            null) return;

                                                        Get.to(
                                                          () =>
                                                              SubscribedChannelView(
                                                            loginUserId: Database
                                                                .loginUserId!,
                                                          ),
                                                        );
                                                      },
                                                      child: Text(
                                                        AppStrings.viewAll.tr,
                                                        style: GoogleFonts
                                                            .urbanist(
                                                                color: AppColor
                                                                    .primaryColor,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                      ),
                                                    ),
                                                  ],
                                                ).paddingSymmetric(
                                                    horizontal: 15,
                                                    vertical: 5),
                                                SizedBox(
                                                    height: 90,
                                                    width: Get.width,
                                                    child:
                                                        SingleChildScrollView(
                                                      scrollDirection:
                                                          Axis.horizontal,
                                                      child: ListView.builder(
                                                        shrinkWrap: true,
                                                        itemCount: controller
                                                                .mainSubscribedChannels
                                                                ?.length ??
                                                            0,
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                left: 10,
                                                                right: 10),
                                                        scrollDirection:
                                                            Axis.horizontal,
                                                        itemBuilder:
                                                            (context, index) {
                                                          return GestureDetector(
                                                            onDoubleTap: () =>
                                                                controller
                                                                    .onChangeParticularChannel(
                                                                        index),
                                                            onTap: () {
                                                              if (GetLiveUsersApi.isLive(controller
                                                                      .mainSubscribedChannels![
                                                                          index]
                                                                      .channelId!) &&
                                                                  (socket?.connected ??
                                                                      false)) {
                                                                  if (Database.loginUserId == null) return;
                                                                Get.to(
                                                                  () =>
                                                                      LivePage(
                                                                    isHost:
                                                                        false,
                                                                    localUserID:
                                                                        Database
                                                                            .loginUserId!,
                                                                    localUserName:
                                                                        AppSettings
                                                                            .channelName
                                                                            .value,
                                                                    roomID: GetLiveUsersApi.roomId(controller
                                                                        .mainSubscribedChannels![
                                                                            index]
                                                                        .channelId!),
                                                                  ),
                                                                )?.then((value) =>
                                                                    AppSettings
                                                                        .navigationIndex(
                                                                            0));
                                                              } else {
                                                                controller
                                                                    .onChangeParticularChannel(
                                                                        index);
                                                              }
                                                            },
                                                            child: Container(
                                                              margin:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      right: 5),
                                                              width: 70,
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  SizedBox(
                                                                    height: 65,
                                                                    child:
                                                                        Stack(
                                                                      children: [
                                                                        GetBuilder<
                                                                            NavSubscriptionPageController>(
                                                                          id: "onChangeParticularChannel",
                                                                          builder: (controller) =>
                                                                              Container(
                                                                            height:
                                                                                60,
                                                                            width:
                                                                                60,
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              shape: BoxShape.circle,
                                                                              border: Border.all(
                                                                                color: controller.selectedChannel == index ? AppColor.primaryColor : Colors.transparent,
                                                                                width: 2,
                                                                              ),
                                                                            ),
                                                                            child:
                                                                                PreviewProfileImage(
                                                                              size: 30,
                                                                              id: controller.mainSubscribedChannels![index].channelId ?? "",
                                                                              image: controller.mainSubscribedChannels![index].channelImage ?? "",
                                                                              fit: BoxFit.cover,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        GetLiveUsersApi.isLive(controller.mainSubscribedChannels![index].channelId!)
                                                                            ? Positioned(
                                                                                bottom: 0,
                                                                                left: 15,
                                                                                child: Container(
                                                                                  padding: const EdgeInsets.only(left: 5, right: 5, bottom: 2),
                                                                                  decoration: BoxDecoration(
                                                                                    color: AppColor.primaryColor,
                                                                                    borderRadius: BorderRadius.circular(5),
                                                                                    border: Border.all(color: AppColor.white),
                                                                                  ),
                                                                                  child: Center(
                                                                                    child: Text(
                                                                                      "Live",
                                                                                      style: GoogleFonts.urbanist(
                                                                                        color: AppColor.white,
                                                                                        fontSize: 10,
                                                                                        fontWeight: FontWeight.bold,
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              )
                                                                            : const Offstage(),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                      height:
                                                                          5),
                                                                  Text(
                                                                    controller
                                                                        .mainSubscribedChannels![
                                                                            index]
                                                                        .channelName
                                                                        .toString(),
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    style: GoogleFonts.urbanist(
                                                                        fontSize:
                                                                            14,
                                                                        fontWeight:
                                                                            FontWeight.w600),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    )),
                                              ],
                                            ),
                                          ),
                                          PreferredSize(
                                            preferredSize:
                                                const Size.fromHeight(50),
                                            child: SliverAppBar(
                                              toolbarHeight: 0,
                                              pinned: true,
                                              floating: true,
                                              bottom: PreferredSize(
                                                preferredSize:
                                                    const Size.fromHeight(50),
                                                child: GetBuilder<
                                                    NavSubscriptionPageController>(
                                                  id: "onChangeParticularChannel",
                                                  builder: (controller) =>
                                                      controller.selectedChannel ==
                                                              null
                                                          ? SizedBox(
                                                              height: 50,
                                                              width: Get.width,
                                                              child: Center(
                                                                child: ListView
                                                                    .builder(
                                                                  scrollDirection:
                                                                      Axis.horizontal,
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          left:
                                                                              15,
                                                                          right:
                                                                              15,
                                                                          bottom:
                                                                              8,
                                                                          top:
                                                                              8),
                                                                  itemCount:
                                                                      subscribeType
                                                                          .length,
                                                                  itemBuilder:
                                                                      (context,
                                                                          index) {
                                                                    return GestureDetector(
                                                                      onTap: () =>
                                                                          controller
                                                                              .onChangeSubscribeType(index),
                                                                      child: GetBuilder<
                                                                          NavSubscriptionPageController>(
                                                                        id: "onChangeSubscribeType",
                                                                        builder:
                                                                            (controller) =>
                                                                                Container(
                                                                          padding: const EdgeInsets
                                                                              .symmetric(
                                                                              horizontal: 15,
                                                                              vertical: 2),
                                                                          margin: const EdgeInsets
                                                                              .only(
                                                                              right: 10),
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            color: controller.selectedSubscribeType != index
                                                                                ? AppColor.transparent
                                                                                : AppColor.primaryColor,
                                                                            border:
                                                                                Border.all(color: AppColor.primaryColor),
                                                                            borderRadius:
                                                                                BorderRadius.circular(28),
                                                                          ),
                                                                          child:
                                                                              Center(
                                                                            child:
                                                                                Text(
                                                                              subscribeType[index],
                                                                              textAlign: TextAlign.center,
                                                                              style: GoogleFonts.urbanist(
                                                                                fontWeight: FontWeight.w600,
                                                                                fontSize: 16,
                                                                                color: controller.selectedSubscribeType == index ? AppColor.white : AppColor.primaryColor,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    );
                                                                  },
                                                                ),
                                                              ),
                                                            )
                                                          : SizedBox(
                                                              height: 50,
                                                              width: Get.width,
                                                              child: ListView
                                                                  .builder(
                                                                scrollDirection:
                                                                    Axis.horizontal,
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        left:
                                                                            15,
                                                                        right:
                                                                            15,
                                                                        bottom:
                                                                            8,
                                                                        top: 8),
                                                                itemCount:
                                                                    videoTypes
                                                                        .length,
                                                                itemBuilder:
                                                                    (context,
                                                                        index) {
                                                                  return GestureDetector(
                                                                    onTap: () =>
                                                                        controller
                                                                            .onChangeVideoType(index),
                                                                    child: GetBuilder<
                                                                        NavSubscriptionPageController>(
                                                                      id: "onChangeVideoType",
                                                                      builder:
                                                                          (controller) =>
                                                                              Container(
                                                                        padding: const EdgeInsets
                                                                            .symmetric(
                                                                            horizontal:
                                                                                15,
                                                                            vertical:
                                                                                2),
                                                                        margin: const EdgeInsets
                                                                            .only(
                                                                            right:
                                                                                5),
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          color: controller.selectedVideoType != index
                                                                              ? AppColor.transparent
                                                                              : AppColor.primaryColor,
                                                                          border:
                                                                              Border.all(color: AppColor.primaryColor),
                                                                          borderRadius:
                                                                              BorderRadius.circular(28),
                                                                        ),
                                                                        child:
                                                                            Center(
                                                                          child:
                                                                              Text(
                                                                            videoTypes[index],
                                                                            textAlign:
                                                                                TextAlign.center,
                                                                            style:
                                                                                GoogleFonts.urbanist(
                                                                              fontWeight: FontWeight.w600,
                                                                              fontSize: 16,
                                                                              color: controller.selectedVideoType == index ? AppColor.white : AppColor.primaryColor,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  );
                                                                },
                                                              ),
                                                            ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ];
                                      },
                                      body: GetBuilder<
                                          NavSubscriptionPageController>(
                                        id: "onChangeParticularChannel",
                                        builder: (controller) => controller
                                                    .selectedChannel ==
                                                null
                                            ? const TypeWiseSubscribedVideo()
                                            : GetBuilder<
                                                NavSubscriptionPageController>(
                                                id: "onChangeVideoType",
                                                builder: (controller) => controller
                                                            .selectedVideoType ==
                                                        0
                                                    ? const SubscribeChannelNormalVideo()
                                                    : const SubscribeChannelShortsVideo(),
                                              ),
                                      ),
                                    )),
              ),
      ),
    );
  }
}

class TypeWiseSubscribedVideo extends StatelessWidget {
  const TypeWiseSubscribedVideo({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<NavSubscriptionPageController>(
      id: "onChangeSubscribeType",
      builder: (controller) => GetBuilder<NavSubscriptionPageController>(
        id: "typeWiseGetSubScribedVideo",
        builder: (controller) => controller
                    .mainAllChannelVideos[controller.selectedSubscribeType] ==
                null
            ? const NormalVideoShimmerUi()
            : controller.mainAllChannelVideos[controller.selectedSubscribeType]!
                    .isEmpty
                ? const DataNotFoundUi()
                : SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller
                              .mainAllChannelVideos[
                                  controller.selectedSubscribeType]
                              ?.length ??
                          0,
                      itemBuilder: (context, index) {
                        final indexData = controller.mainAllChannelVideos[
                            controller.selectedSubscribeType]![index];
                        return (indexData.videoPrivacyType == 2 &&
                                indexData.channelType == 1)
                            ? PrivateContentNormalVideoUi(
                                videoId: indexData.id ?? "",
                                title: indexData.videoTitle ?? "",
                                videoImage: indexData.videoImage ?? "",
                                videoUrl: indexData.videoUrl ?? "",
                                videoTime: indexData.videoTime ?? 0,
                                channelId: indexData.channelId ?? "",
                                channelImage: indexData.channelImage ?? "",
                                channelName: indexData.channelName ?? "",
                                views: indexData.views ?? 0,
                                uploadTime:
                                    (indexData.videoTime ?? 0).toString(),
                                isSave: indexData.isSaveToWatchLater ?? false,
                                subscribeCallback: () {},
                                videoCallback: () =>
                                    controller.onUnlockPrivateVideo(
                                        index: index,
                                        context: context,
                                        isAllChannel: true),
                                videoCost: indexData.videoUnlockCost ?? 0,
                                subscribeCost: indexData.subscriptionCost ?? 0,
                                channelType: indexData.channelType ?? 1,
                              )
                            : Visibility(
                                visible: indexData.videoType == 1,
                                child: GestureDetector(
                                  onTap: () => Get.to(NormalVideoDetailsView(
                                      videoId: indexData.videoId!,
                                      videoUrl: indexData.videoUrl!)),
                                  child: Column(
                                    children: [
                                      NormalVideoUi(
                                        videoId: indexData.videoId!,
                                        title: indexData.videoTitle!,
                                        videoImage: indexData.videoImage!,
                                        videoUrl: indexData.videoUrl!,
                                        videoTime: indexData.videoTime!,
                                        channelId: indexData.channelId!,
                                        channelImage: indexData.channelImage!,
                                        channelName: indexData.channelName!,
                                        views: indexData.views!,
                                        isSave: indexData.isSaveToWatchLater!,
                                      ),
                                      index != 0 &&
                                              index %
                                                      AppSettings
                                                          .showAdsIndex ==
                                                  0
                                          ? const GoogleLargeNativeAd()
                                          : const Offstage()
                                    ],
                                  ),
                                ),
                              );
                      },
                      separatorBuilder: (context, index) => (controller
                                  .mainAllChannelVideos[
                                      controller.selectedSubscribeType]!
                                  .where((element) => element.videoType == 2)
                                  .isNotEmpty) &&
                              index == 0
                          ? SizedBox(
                              height: 280,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: ListView.builder(
                                  itemCount: controller
                                          .mainAllChannelVideos[
                                              controller.selectedSubscribeType]
                                          ?.length ??
                                      0,
                                  scrollDirection: Axis.horizontal,
                                  shrinkWrap: true,
                                  physics: const BouncingScrollPhysics(),
                                  padding: const EdgeInsets.only(
                                      left: 10, bottom: 10),
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    final indexData =
                                        controller.mainAllChannelVideos[
                                            controller
                                                .selectedSubscribeType]![index];
                                    return (indexData.videoPrivacyType == 2 &&
                                            indexData.channelType == 1)
                                        ? ShortsPrivateContentWidget(
                                            id: indexData.id ?? "",
                                            image: indexData.videoImage ?? "",
                                            subscribe: () {},
                                            unlock: () =>
                                                controller.onUnlockPrivateVideo(
                                                    index: index,
                                                    context: context,
                                                    isAllChannel: true),
                                            subscribeCoin:
                                                indexData.subscriptionCost ?? 0,
                                            unlockCoin:
                                                indexData.videoUnlockCost ?? 0,
                                            title: indexData.videoTitle ?? "",
                                            views: indexData.views ?? 0,
                                            channelType:
                                                indexData.channelType ?? 1,
                                          )
                                        : GestureDetector(
                                            onTap: () => Get.to(
                                                ShortsVideoDetailsView(
                                                    videoId: indexData.videoId!,
                                                    videoUrl:
                                                        indexData.videoUrl!)),
                                            child: Visibility(
                                              visible: indexData.videoType == 2,
                                              child: ShortVideoUi(
                                                videoId: indexData.videoId!,
                                                title: indexData.videoTitle!,
                                                videoImage:
                                                    indexData.videoImage!,
                                                videoUrl: indexData.videoUrl!,
                                                channelId:
                                                    indexData.channelId ?? "",
                                                views: indexData.views!,
                                                videoTime: indexData.videoTime!,
                                                channelName:
                                                    indexData.channelName!,
                                                isSave: indexData
                                                    .isSaveToWatchLater!,
                                              ),
                                            ),
                                          );
                                  },
                                ),
                              ),
                            )
                          : const Offstage(),
                    ),
                  ),
      ),
      // ),
    );
  }
}

class SubscribeChannelNormalVideo extends StatelessWidget {
  const SubscribeChannelNormalVideo({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<NavSubscriptionPageController>(
      id: "onChangeNormalVideo",
      builder: (controller) => controller.particularChannelVideos[0] == null
          ? const VideoListShimmerUi()
          : controller.particularChannelVideos[0]!.isEmpty
              ? DataNotFoundUi(title: AppStrings.videosNotAvailable)
              : SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount:
                        controller.particularChannelVideos[0]?.length ?? 0,
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    itemBuilder: (context, index) {
                      final indexData =
                          controller.particularChannelVideos[0]![index];
                      return ((indexData.videoPrivacyType == 2 &&
                                  indexData.channelType == 1) ||
                              (indexData.videoPrivacyType == 2 &&
                                  indexData.channelType == 2 &&
                                  indexData.isSubscribed == false))
                          ? GestureDetector(
                              onTap: () => controller.onUnlockPrivateVideo(
                                  index: index,
                                  context: context,
                                  isShorts: false,
                                  isAllChannel: false),
                              child: SmallVideoWidget(
                                id: indexData.id ?? "",
                                image: indexData.videoImage ?? "",
                                videoTime:
                                    (indexData.videoTime ?? 0).toString(),
                                title: indexData.title ?? "",
                                views: indexData.views ?? 0,
                                uploadTime: indexData.time ?? "",
                              ),
                            )
                          : Column(
                              children: [
                                GestureDetector(
                                  onTap: () => Get.to(
                                    NormalVideoDetailsView(
                                      videoId: controller
                                          .particularChannelVideos[0]![index]
                                          .id!,
                                      videoUrl: controller
                                          .particularChannelVideos[0]![index]
                                          .videoUrl!,
                                    ),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Stack(
                                        children: [
                                          Container(
                                            clipBehavior: Clip.hardEdge,
                                            height: SizeConfig
                                                .smallVideoImageHeight,
                                            width:
                                                SizeConfig.smallVideoImageWidth,
                                            decoration: BoxDecoration(
                                                color: isDarkMode.value
                                                    ? AppColor.secondDarkMode
                                                    : AppColor.grey_300,
                                                borderRadius:
                                                    BorderRadius.circular(20)),
                                            child: PreviewVideoImage(
                                              videoId: controller
                                                  .particularChannelVideos[0]![
                                                      index]
                                                  .id!,
                                              videoImage: controller
                                                  .particularChannelVideos[0]![
                                                      index]
                                                  .videoImage!,
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
                                                  color: AppColor.black),
                                              child: Text(
                                                CustomFormatTime.convert(
                                                    int.parse(controller
                                                        .particularChannelVideos[
                                                            0]![index]
                                                        .videoTime
                                                        .toString())),
                                                style: GoogleFonts.urbanist(
                                                    color: AppColor.white,
                                                    fontSize: 11),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(width: Get.width * 0.03),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              controller
                                                  .particularChannelVideos[0]![
                                                      index]
                                                  .title
                                                  .toString(),
                                              maxLines: 3,
                                              style: GoogleFonts.urbanist(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            const SizedBox(height: 10),
                                            Obx(
                                              () => Text(
                                                "${controller.particularChannelVideos[0]![index].views.toString()} • ${controller.particularChannelVideos[0]![index].time.toString()}",
                                                style: GoogleFonts.urbanist(
                                                    fontSize: 12,
                                                    color: isDarkMode.value
                                                        ? AppColor.white
                                                            .withOpacity(0.7)
                                                        : AppColor.black
                                                            .withOpacity(0.7)),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: Get.width * 0.01),
                                    ],
                                  ).paddingOnly(bottom: 10),
                                ),
                                index != 0 &&
                                        index % AppSettings.showAdsIndex == 0
                                    ? const GoogleSmallNativeAd()
                                    : const Offstage()
                              ],
                            );
                    },
                  ),
                ),
    );
  }
}

class SubscribeChannelShortsVideo extends StatelessWidget {
  const SubscribeChannelShortsVideo({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<NavSubscriptionPageController>(
      id: "onChangeShortsVideo",
      builder: (controller) => controller.particularChannelVideos[1] == null
          ? const ShortsListShimmerUi()
          : controller.particularChannelVideos[1]!.isEmpty
              ? DataNotFoundUi(title: AppStrings.shortsNotAvailable)
              : SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount:
                        controller.particularChannelVideos[1]?.length ?? 0,
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                            mainAxisExtent: 280),
                    itemBuilder: (context, index) {
                      final indexData =
                          controller.particularChannelVideos[1]![index];
                      return (indexData.videoPrivacyType == 2 &&
                              indexData.channelType == 1)
                          ? ShortsPrivateContentWidget(
                              id: indexData.id ?? "",
                              image: indexData.videoImage ?? "",
                              subscribe: () {},
                              unlock: () => controller.onUnlockPrivateVideo(
                                  index: index,
                                  context: context,
                                  isShorts: true,
                                  isAllChannel: false),
                              subscribeCoin: indexData.subscriptionCost ?? 0,
                              unlockCoin: indexData.videoUnlockCost ?? 0,
                              title: indexData.title ?? "",
                              views: indexData.views ?? 0,
                              channelType: indexData.channelType ?? 1,
                            )
                          : GestureDetector(
                              onTap: () => Get.to(
                                ShortsVideoDetailsView(
                                  videoId: controller
                                      .particularChannelVideos[1]![index].id!,
                                  videoUrl: controller
                                      .particularChannelVideos[1]![index]
                                      .videoUrl!,
                                ),
                              ),
                              child: Container(
                                height: 280,
                                width: 165,
                                clipBehavior: Clip.antiAlias,
                                decoration: BoxDecoration(
                                    color: AppColor.grey_400,
                                    borderRadius: BorderRadius.circular(20)),
                                child: Stack(
                                  children: [
                                    PreviewVideoImage(
                                        videoId: controller
                                            .particularChannelVideos[1]![index]
                                            .id!,
                                        videoImage: controller
                                            .particularChannelVideos[1]![index]
                                            .videoImage!),
                                    Positioned(
                                      bottom: 0,
                                      left: 10,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            width: 145,
                                            child: Text(
                                              controller
                                                  .particularChannelVideos[1]![
                                                      index]
                                                  .title
                                                  .toString(),
                                              maxLines: 3,
                                              style: shortsStyle,
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            "${controller.particularChannelVideos[1]![index].views.toString()} Views",
                                            style: shortsStyle,
                                          ),
                                          const SizedBox(height: 10),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                    },
                  ),
                ),
    );
  }
}
