import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:metube/ads/google_ads/google_reward_ad.dart';
import 'package:metube/custom/custom_ui/loader_ui.dart';
import 'package:metube/database/database.dart';
import 'package:metube/pages/nav_home_page/api/fetch_all_video_api.dart';
import 'package:metube/pages/nav_home_page/api/fetch_new_video_api.dart';
import 'package:metube/pages/nav_home_page/api/fetch_popular_video_api.dart';
import 'package:metube/pages/nav_home_page/api/fetch_public_live_api.dart';
import 'package:metube/pages/nav_home_page/model/fetch_all_video_model.dart';
import 'package:metube/pages/nav_home_page/model/fetch_new_video_model.dart';
import 'package:metube/pages/nav_home_page/model/fetch_popular_video_model.dart';
import 'package:metube/pages/nav_home_page/model/fetch_public_live_model.dart';
import 'package:metube/pages/nav_subscription_page/subscribe_channel_api.dart';
import 'package:metube/pages/splash_screen_page/api/unlock_private_video_api.dart';
import 'package:metube/utils/utils.dart';
import 'package:metube/widget/subscribe_premium_channel_bottom_sheet.dart';
import 'package:metube/widget/subscribed_success_dialog.dart';
import 'package:metube/widget/unlock_premium_video_bottom_sheet.dart';

class NavHomeController extends GetxController {
  bool isLoadingPagination = false;

  int selectedTabIndex = 0;
  List<String> tabTitles = ["All", "Popular", "New", "Live"];

  ScrollController allTabScrollController = ScrollController();
  FetchAllVideoModel? fetchAllVideoModel;
  List<AllVideo> allVideos = [];
  List<AllShorts> allShorts = [];
  bool isLoadingAllTab = false;

  ScrollController popularTabScrollController = ScrollController();
  FetchPopularVideoModel? fetchPopularVideoModel;
  List<PopularVideos> popularVideos = [];
  List<PopularShorts> popularShorts = [];
  bool isLoadingPopularTab = false;

  ScrollController newTabScrollController = ScrollController();
  FetchNewVideoModel? fetchNewVideoModel;
  List<NewVideos> newVideos = [];
  List<NewShorts> newShorts = [];
  bool isLoadingNewTab = false;

  ScrollController publicLiveTabScrollController = ScrollController();
  FetchPublicLiveModel? fetchPublicLiveModel;
  List<LiveData?> publicLive = [];
  bool isLoadingPublicLiveTab = false;

  @override
  void onInit() {
    allTabScrollController.addListener(onPaginationAllTab);
    popularTabScrollController.addListener(onPaginationPopularTab);
    newTabScrollController.addListener(onPaginationNewTab);
    publicLiveTabScrollController.addListener(onPaginationLiveTab);
    GoogleRewardAd.loadAd();

    init();
    super.onInit();
  }

  @override
  void dispose() {
    allTabScrollController.dispose();
    popularTabScrollController.dispose();
    newTabScrollController.dispose();
    publicLiveTabScrollController.dispose();
    super.dispose();
  }

  void onChangeTab(int value) {
    selectedTabIndex = value;
    update(["onChangeTab"]);
  }

  Future init() async {
    FetchAllVideoApi.startPagination = 0;
    allVideos.clear();
    allShorts.clear();
    isLoadingAllTab = true;
    onGetAllTabVideo();

    FetchPopularVideoApi.startPagination = 0;
    popularVideos.clear();
    popularShorts.clear();
    isLoadingPopularTab = true;
    onGetPopularTabVideo();

    FetchNewVideoApi.startPagination = 0;
    newVideos.clear();
    newShorts.clear();
    isLoadingNewTab = true;
    onGetNewTabVideo();

    FetchPublicLiveApi.startPagination = 0;
    publicLive.clear();

    isLoadingPublicLiveTab = true;
    onGetPublicLiveTabVideo();
  }

  bool isRefreshing = false;

  Future<void> refreshInit() async {
    if (isRefreshing) return; // ✅ block duplicate calls
    isRefreshing = true;

    /// Reset All Tab
    FetchAllVideoApi.startPagination = 0;
    allVideos.clear();
    allShorts.clear();
    isLoadingAllTab = true;
    await onGetAllTabVideo(); // ✅ wait before moving on

    /// Reset Popular Tab
    FetchPopularVideoApi.startPagination = 0;
    popularVideos.clear();
    popularShorts.clear();
    isLoadingPopularTab = true;
    await onGetPopularTabVideo(); // ✅ wait

    /// Reset New Tab
    FetchNewVideoApi.startPagination = 0;
    newVideos.clear();
    newShorts.clear();
    isLoadingNewTab = true;
    await onGetNewTabVideo(); // ✅ wait

    /// Reset Public Live Tab
    FetchPublicLiveApi.startPagination = 0;
    publicLive.clear();
    isLoadingPublicLiveTab = true;
    await onGetPublicLiveTabVideo(); // ✅ wait
    isRefreshing = false;
  }

  Future<void> onGetAllTabVideo() async {
    fetchAllVideoModel = await FetchAllVideoApi.callApi(Database.loginUserId ?? "");

    final paginationShorts = fetchAllVideoModel?.data?.shorts;
    final paginationVideos = fetchAllVideoModel?.data?.videos;

    Utils.showLog("All Tab Pagination Data Len => ${paginationVideos?.length} => ${paginationShorts?.length}");

    if (paginationVideos?.isNotEmpty ?? false) {
      allVideos.addAll(paginationVideos ?? []);
      allShorts.addAll(paginationShorts ?? []);
    } else {
      FetchAllVideoApi.startPagination--;
      Utils.showLog("All Tab Pagination Data Empty");
    }
    isLoadingAllTab = false;
    update(["onGetAllTabVideo"]);
  }

  void onPaginationAllTab() async {
    if (allTabScrollController.position.pixels == allTabScrollController.position.maxScrollExtent) {
      isLoadingPagination = true;
      update(["onPagination"]);
      if (isLoadingPagination != true) {
        await onGetAllTabVideo();
      } else {
        Utils.showLog("REPEAT");
      }
      isLoadingPagination = false;
      update(["onPagination"]);
    }
  }

  Future<void> onGetPopularTabVideo() async {
    fetchPopularVideoModel = await FetchPopularVideoApi.callApi(loginUserId: Database.loginUserId ?? "");

    final paginationShorts = fetchPopularVideoModel?.data?.shorts;
    final paginationVideos = fetchPopularVideoModel?.data?.videos;

    Utils.showLog("Popular Tab Pagination Data Len => ${paginationVideos?.length} => ${paginationShorts?.length}");

    if (paginationVideos?.isNotEmpty ?? false) {
      popularVideos.addAll(paginationVideos ?? []);
      popularShorts.addAll(paginationShorts ?? []);
    } else {
      FetchPopularVideoApi.startPagination--;
      Utils.showLog("Popular Tab Pagination Data Empty");
    }
    isLoadingPopularTab = false;
    update(["onGetPopularTabVideo"]);
  }

  void onPaginationPopularTab() async {
    if (popularTabScrollController.position.pixels == popularTabScrollController.position.maxScrollExtent) {
      isLoadingPagination = true;
      update(["onPagination"]);
      await onGetPopularTabVideo();
      isLoadingPagination = false;
      update(["onPagination"]);
    }
  }

  Future<void> onGetNewTabVideo() async {
    fetchNewVideoModel = await FetchNewVideoApi.callApi(loginUserId: Database.loginUserId ?? "");

    final paginationShorts = fetchNewVideoModel?.data?.shorts;
    final paginationVideos = fetchNewVideoModel?.data?.videos;

    Utils.showLog("New Tab Pagination Data Len => ${paginationVideos?.length} => ${paginationShorts?.length}");

    if (paginationVideos?.isNotEmpty ?? false) {
      newVideos.addAll(paginationVideos ?? []);
      newShorts.addAll(paginationShorts ?? []);
    } else {
      FetchNewVideoApi.startPagination--;
      Utils.showLog("New Tab Pagination Data Empty");
    }
    isLoadingNewTab = false;
    update(["onGetNewTabVideo"]);
  }

  void onPaginationNewTab() async {
    if (newTabScrollController.position.pixels == newTabScrollController.position.maxScrollExtent) {
      isLoadingPagination = true;
      update(["onPagination"]);
      await onGetNewTabVideo();
      isLoadingPagination = false;
      update(["onPagination"]);
    }
  }

  Future<void> onGetPublicLiveTabVideo() async {
    fetchPublicLiveModel = await FetchPublicLiveApi.callApi(loginUserId: Database.loginUserId ?? "");

    final paginationData = fetchPublicLiveModel?.data;

    Utils.showLog("Live Tab Pagination Data Len => ${paginationData?.length}");

    if (paginationData?.isNotEmpty ?? false) {
      publicLive.addAll(paginationData ?? []);
    } else {
      FetchPublicLiveApi.startPagination--;
      Utils.showLog("Live Tab Pagination Data Empty");
    }
    isLoadingPublicLiveTab = false;
    update(["onGetPublicLiveTabVideo"]);
  }

  void onPaginationLiveTab() async {
    if (publicLiveTabScrollController.position.pixels == publicLiveTabScrollController.position.maxScrollExtent) {
      isLoadingPagination = true;
      update(["onPagination"]);
      await onGetPublicLiveTabVideo();
      isLoadingPagination = false;
      update(["onPagination"]);
    }
  }

  void onUnlockPrivateVideo({required int tabType, required int index, required BuildContext context, required bool isShorts}) async {
    // Type => All
    if (tabType == 0) {
      if (isShorts) {
        UnlockPremiumVideoBottomSheet.onShow(
          coin: (allShorts[index].videoUnlockCost ?? 0).toString(),
          callback: () async {
            Get.dialog(const LoaderUi(), barrierDismissible: false);
            await UnlockPrivateVideoApi.callApi(loginUserId: Database.loginUserId ?? "", videoId: allShorts[index].id ?? "");

            if (UnlockPrivateVideoApi.unlockPrivateVideoModel?.isUnlocked == true) {
              allShorts = allShorts.map((e) {
                if (e.id == allShorts[index].id) {
                  e.videoPrivacyType = 1;
                }
                return e;
              }).toList();

              update(["onGetAllTabVideo"]);
            }

            Get.close(2);
            SubscribedSuccessDialog.show(context);
          },
        );
      } else {
        UnlockPremiumVideoBottomSheet.onShow(
          coin: (allVideos[index].videoUnlockCost ?? 0).toString(),
          callback: () async {
            Get.dialog(const LoaderUi(), barrierDismissible: false);
            await UnlockPrivateVideoApi.callApi(loginUserId: Database.loginUserId ?? "", videoId: allVideos[index].id ?? "");

            if (UnlockPrivateVideoApi.unlockPrivateVideoModel?.isUnlocked == true) {
              allVideos = allVideos.map((e) {
                if (e.id == allVideos[index].id) {
                  e.videoPrivacyType = 1;
                }
                return e;
              }).toList();

              update(["onGetAllTabVideo"]);
            }

            Get.close(2);
            SubscribedSuccessDialog.show(context);
          },
        );
      }

      // Type => Popular
    } else if (tabType == 1) {
      if (isShorts) {
        UnlockPremiumVideoBottomSheet.onShow(
          coin: (popularShorts[index].videoUnlockCost ?? 0).toString(),
          callback: () async {
            Get.dialog(const LoaderUi(), barrierDismissible: false);
            await UnlockPrivateVideoApi.callApi(loginUserId: Database.loginUserId ?? "", videoId: popularShorts[index].id ?? "");

            if (UnlockPrivateVideoApi.unlockPrivateVideoModel?.isUnlocked == true) {
              popularShorts = popularShorts.map((e) {
                if (e.id == popularShorts[index].id) {
                  e.videoPrivacyType = 1;
                }
                return e;
              }).toList();

              update(["onGetPopularTabVideo"]);
            }

            Get.close(2);
            SubscribedSuccessDialog.show(context);
          },
        );
      } else {
        UnlockPremiumVideoBottomSheet.onShow(
          coin: (popularVideos[index].videoUnlockCost ?? 0).toString(),
          callback: () async {
            Get.dialog(const LoaderUi(), barrierDismissible: false);
            await UnlockPrivateVideoApi.callApi(loginUserId: Database.loginUserId ?? "", videoId: popularVideos[index].id ?? "");

            if (UnlockPrivateVideoApi.unlockPrivateVideoModel?.isUnlocked == true) {
              popularVideos = popularVideos.map((e) {
                if (e.id == popularVideos[index].id) {
                  e.videoPrivacyType = 1;
                }
                return e;
              }).toList();

              update(["onGetPopularTabVideo"]);
            }

            Get.close(2);
            SubscribedSuccessDialog.show(context);
          },
        );
      }

      // Type => New
    } else {
      if (isShorts) {
        UnlockPremiumVideoBottomSheet.onShow(
          coin: (newShorts[index].videoUnlockCost ?? 0).toString(),
          callback: () async {
            Get.dialog(const LoaderUi(), barrierDismissible: false);
            await UnlockPrivateVideoApi.callApi(loginUserId: Database.loginUserId ?? "", videoId: newShorts[index].id ?? "");

            if (UnlockPrivateVideoApi.unlockPrivateVideoModel?.isUnlocked == true) {
              newShorts = newShorts.map((e) {
                if (e.id == newShorts[index].id) {
                  e.videoPrivacyType = 1;
                }
                return e;
              }).toList();

              update(["onGetNewTabVideo"]);
            }

            Get.close(2);
            SubscribedSuccessDialog.show(context);
          },
        );
      } else {
        UnlockPremiumVideoBottomSheet.onShow(
          coin: (newVideos[index].videoUnlockCost ?? 0).toString(),
          callback: () async {
            Get.dialog(const LoaderUi(), barrierDismissible: false);
            await UnlockPrivateVideoApi.callApi(loginUserId: Database.loginUserId ?? "", videoId: newVideos[index].id ?? "");

            if (UnlockPrivateVideoApi.unlockPrivateVideoModel?.isUnlocked == true) {
              newVideos = newVideos.map((e) {
                if (e.id == newVideos[index].id) {
                  e.videoPrivacyType = 1;
                }
                return e;
              }).toList();

              update(["onGetNewTabVideo"]);
            }

            Get.close(2);
            SubscribedSuccessDialog.show(context);
          },
        );
      }
    }
  }

  void onSubscribePrivateChannel({required int tabType, required int index, required BuildContext context, required bool isShorts}) async {
    // Type => All
    if (tabType == 0) {
      if (isShorts) {
        SubscribePremiumChannelBottomSheet.onShow(
          coin: (allShorts[index].subscriptionCost ?? 0).toString(),
          callback: () async {
            Get.dialog(const LoaderUi(), barrierDismissible: false);
            final bool isSuccess = await SubscribeChannelApiClass.callApi(allShorts[index].channelId ?? "");

            Get.close(2);

            if (isSuccess) {
              allShorts = allShorts.map((e) {
                if (e.id == allShorts[index].id) {
                  e.videoPrivacyType = 1;
                }
                return e;
              }).toList();

              update(["onGetAllTabVideo"]);
              SubscribedSuccessDialog.show(context);
            }
          },
        );
      } else {
        SubscribePremiumChannelBottomSheet.onShow(
          coin: (allVideos[index].subscriptionCost ?? 0).toString(),
          callback: () async {
            Get.dialog(const LoaderUi(), barrierDismissible: false);
            final bool isSuccess = await SubscribeChannelApiClass.callApi(allVideos[index].channelId ?? "");

            Get.close(2);

            if (isSuccess) {
              allVideos = allVideos.map((e) {
                if (e.id == allVideos[index].id) {
                  e.videoPrivacyType = 1;
                }
                return e;
              }).toList();

              update(["onGetAllTabVideo"]);
              SubscribedSuccessDialog.show(context);
            }
          },
        );
      }

      // Type => Popular
    } else if (tabType == 1) {
      if (isShorts) {
        SubscribePremiumChannelBottomSheet.onShow(
          coin: (popularShorts[index].subscriptionCost ?? 0).toString(),
          callback: () async {
            Get.dialog(const LoaderUi(), barrierDismissible: false);
            final bool isSuccess = await SubscribeChannelApiClass.callApi(popularShorts[index].channelId ?? "");
            Get.close(2);
            if (isSuccess) {
              popularShorts = popularShorts.map((e) {
                if (e.id == popularShorts[index].id) {
                  e.videoPrivacyType = 1;
                }
                return e;
              }).toList();

              update(["onGetPopularTabVideo"]);
              SubscribedSuccessDialog.show(context);
            }
          },
        );
      } else {
        SubscribePremiumChannelBottomSheet.onShow(
          coin: (popularVideos[index].subscriptionCost ?? 0).toString(),
          callback: () async {
            Get.dialog(const LoaderUi(), barrierDismissible: false);
            final bool isSuccess = await SubscribeChannelApiClass.callApi(popularVideos[index].channelId ?? "");
            Get.close(2);
            if (isSuccess) {
              popularVideos = popularVideos.map((e) {
                if (e.id == popularVideos[index].id) {
                  e.videoPrivacyType = 1;
                }
                return e;
              }).toList();

              update(["onGetPopularTabVideo"]);
              SubscribedSuccessDialog.show(context);
            }
          },
        );
      }

      // Type => New
    } else {
      if (isShorts) {
        SubscribePremiumChannelBottomSheet.onShow(
          coin: (newShorts[index].subscriptionCost ?? 0).toString(),
          callback: () async {
            Get.dialog(const LoaderUi(), barrierDismissible: false);
            final bool isSuccess = await SubscribeChannelApiClass.callApi(newShorts[index].channelId ?? "");

            Get.close(2);
            if (isSuccess) {
              newShorts = newShorts.map((e) {
                if (e.id == newShorts[index].id) {
                  e.videoPrivacyType = 1;
                }
                return e;
              }).toList();

              update(["onGetNewTabVideo"]);
              SubscribedSuccessDialog.show(context);
            }
          },
        );
      } else {
        SubscribePremiumChannelBottomSheet.onShow(
          coin: (newVideos[index].subscriptionCost ?? 0).toString(),
          callback: () async {
            Get.dialog(const LoaderUi(), barrierDismissible: false);
            final bool isSuccess = await SubscribeChannelApiClass.callApi(newVideos[index].channelId ?? "");

            Get.close(2);
            if (isSuccess) {
              newVideos = newVideos.map((e) {
                if (e.id == newVideos[index].id) {
                  e.videoPrivacyType = 1;
                }
                return e;
              }).toList();

              update(["onGetNewTabVideo"]);
              SubscribedSuccessDialog.show(context);
            }
          },
        );
      }
    }
  }
}

// void onPagination() async {
//   if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
//     onChangeLoading();
//     await onGetHomeVideos();
//     onChangeLoading();
//   }
// }
//
// void onChangeLoading() {
//   isPaginationLoading = !isPaginationLoading;
//   update(["changeLoader"]);
// }

// Future<void> onGetHomeVideos() async {
//   _getAllVideoModel = await GetAllVideoApi.callApi(loginUserId: Database.loginUserId!);
//   if (_getAllVideoModel?.videos != null && _getAllVideoModel!.videos!.isNotEmpty) {
//     List<Videos> videos = _getAllVideoModel!.videos!;
//     AppSettings.showLog("Api Video Length => ${videos.length}");
//
//     if (videos.isNotEmpty) {
//       mainHomeVideos.addAll(videos);
//
//       onVideoConvert(videos);
//
//       update(["changeVideos"]);
//
//       AppSettings.showLog("Normal Video Pagination Length => ${mainHomeVideos.length}");
//     } else {
//       GetAllVideoApi.startPagination--;
//       AppSettings.showLog("Get All Video Response Is Empty");
//     }
//   } else {
//     GetAllVideoApi.startPagination--;
//     AppSettings.showLog("Get All Video Response Is Empty");
//   }
// }

// Future<void> onGetShortsVideos() async {
//   _getShortsVideoModel = await GetPreviewShortsVideoApi.callApi(Database.loginUserId!, 1, 50);
//
//   if (_getShortsVideoModel != null && (_getShortsVideoModel?.shorts?.isNotEmpty ?? false)) {
//     AppSettings.showLog("Pagination Page Length => ${_getShortsVideoModel?.shorts?.length}");
//
//     mainShortsVideos.addAll(_getShortsVideoModel!.shorts!);
//     mainShortsVideos.shuffle();
//
//     update(["changeVideos"]);
//     onShortsConvert();
//   } else {
//     AppSettings.showLog("Pagination Data Empty !!!");
//   }
// }
//
// void onVideoConvert(List<Videos> data) async {
//   for (int i = 0; i < data.length; i++) {
//     if (Database.onGetVideoUrl(data[i].id!) == null) {
//       if ((data[i].videoTime! < 3600000)) {
//         final videoUrl = await ConvertToNetwork.convert(data[i].videoUrl!);
//         if (videoUrl != "") {
//           AppSettings.showLog("Normal Video Convert Url Index => $i");
//           Database.onSetVideoUrl(data[i].id!, videoUrl);
//         } else {
//           AppSettings.showLog("Normal Video Failed Index => $i");
//         }
//       } else {
//         AppSettings.showLog("Long Video Pending Convert Index => $i");
//       }
//     }
//   }
// }
//
// void onShortsConvert() async {
//   for (int i = 0; i < mainShortsVideos.length; i++) {
//     final videoUrl = await ConvertToNetwork.convert(mainShortsVideos[i].videoUrl!);
//     if (videoUrl != "") {
//       AppSettings.showLog("Home Shorts Video Converted Index => $i");
//       Database.onSetVideoUrl(mainShortsVideos[i].id!, videoUrl);
//     } else {
//       AppSettings.showLog("Shorts Video Failed Index => $i");
//     }
//   }
// }
