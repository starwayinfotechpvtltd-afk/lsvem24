import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:metube/custom/custom_ui/loader_ui.dart';
import 'package:metube/database/database.dart';
import 'package:metube/database/search_history_database.dart';
import 'package:metube/pages/nav_subscription_page/subscribe_channel_api.dart';
import 'package:metube/pages/search_page/search_api.dart';
import 'package:metube/pages/search_page/search_model.dart';
import 'package:metube/pages/splash_screen_page/api/unlock_private_video_api.dart';
import 'package:metube/utils/permission_service.dart';
import 'package:metube/utils/settings/app_settings.dart';
import 'package:metube/utils/string/app_string.dart';
import 'package:metube/utils/utils.dart';
import 'package:metube/widget/subscribe_premium_channel_bottom_sheet.dart';
import 'package:metube/widget/subscribed_success_dialog.dart';
import 'package:metube/widget/unlock_premium_video_bottom_sheet.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SearchingController extends GetxController {
  TextEditingController searchController = TextEditingController();

  SearchModel? searchModel;
  bool isLoading = false;

  RxBool isShowHistory = false.obs;

  List<Channel> searchChannel = [];
  List<Videos> searchVideo = [];
  List<Shorts> searchShorts = [];

  SpeechToText speechToText = SpeechToText();

  int selectedTabIndex = 0;
  List<String> tabTitles = [AppStrings.all.tr, AppStrings.channels.tr, AppStrings.videos.tr, AppStrings.shorts.tr];

  String text = AppStrings.micNode.tr;
  bool isListening = false;

  void init() {
    initializeMic();
    isShowHistory.value = true;
    SearchHistory.onGet();
  }

  void onDispose() {
    SearchHistory.onSet();
    selectedTabIndex = 0;
    searchChannel.clear();
    searchVideo.clear();
    searchShorts.clear();
    searchController.clear();
  }

  void onChangeTab(int value) {
    selectedTabIndex = value;
    update(["onChangeTab"]);
  }

  Future<void> onChanged() async {
    AppSettings.showLog("Search Text => ${searchController.text}");

    if (searchController.text.trim().isNotEmpty) {
      isShowHistory.value = false;
      onGetSearchData();
    } else {
      isShowHistory.value = true;
    }
  }

  Future<void> onGetSearchData() async {
    try {
      isLoading = true;
      update(["onGetSearchData"]);

      searchModel = await SearchApi.callApi(Database.loginUserId ?? "", searchController.text.trim(), "All");

      if (searchModel?.searchData?.channel != null) {
        searchChannel.clear();
        searchChannel.addAll(searchModel?.searchData?.channel ?? []);
      }

      if (searchModel?.searchData?.videos != null) {
        searchVideo.clear();
        searchVideo.addAll(searchModel?.searchData?.videos ?? []);
      }

      if (searchModel?.searchData?.shorts != null) {
        searchShorts.clear();
        searchShorts.addAll(searchModel?.searchData?.shorts ?? []);
        AppSettings.showLog("Search Shorts Len => ${searchShorts.length}");
      }

      isLoading = false;
      update(["onGetSearchData"]);
    } catch (e) {
      AppSettings.showLog("Get Search Data Error => $e");
    }
  }

  void onClickMic() async {
    bool granted = await PermissionService.requestMicPermission();
    if (granted) {
      // ✅ Start speech-to-text / mic function
      AppSettings.showLog("Audio Recording Start");
      isListening = true;
      update(["onClickMic"]);
      await startListening();
      await 5.seconds.delay();
      await stopListening();
      isListening = false;
      update(["onClickMic"]);
      AppSettings.showLog("Audio Recording Stop");
    } else {
      // ❌ Do nothing, user must allow
    }
    // PermissionStatus microphoneStatus = await Permission.microphone.request();
    // if (microphoneStatus == PermissionStatus.granted && isListening == false) {
    //   AppSettings.showLog("Audio Recording Start");
    //   isListening = true;
    //   update(["onClickMic"]);
    //   await startListening();
    //   await 5.seconds.delay();
    //   await stopListening();
    //   isListening = false;
    //   update(["onClickMic"]);
    //   AppSettings.showLog("Audio Recording Stop");
    // }
  }

  Future<void> initializeMic() async {
    try {
      var available = await speechToText.initialize();
      if (available == false) {
        AppSettings.showLog("Please Initialize Mic...");
      }
    } catch (e) {
      AppSettings.showLog("Mic Error => $e");
    }
  }

  Future<void> startListening() async {
    searchController.clear();
    await speechToText.listen(
      onResult: (result) {
        text = result.recognizedWords;
        Utils.showLog("MicroPhone ->> $text");
      },
    );
  }

  Future<void> stopListening() async {
    await speechToText.stop();

    if (text != AppStrings.micNode.tr) {
      searchController.text = text;
      text = AppStrings.micNode.tr;
    }

    if (searchController.text.trim().isNotEmpty) {
      if (!SearchHistory.mainSearchHistory.contains(searchController.text)) {
        SearchHistory.mainSearchHistory.insert(0, searchController.text);
      }
      onGetSearchData();
      isShowHistory.value = false;
    }
  }

  void onUnlockPrivateVideo({required int index, required BuildContext context, required bool isShorts}) async {
    if (isShorts) {
      UnlockPremiumVideoBottomSheet.onShow(
        coin: (searchShorts[index].videoUnlockCost ?? 0).toString(),
        callback: () async {
          Get.dialog(const LoaderUi(), barrierDismissible: false);
          await UnlockPrivateVideoApi.callApi(loginUserId: Database.loginUserId ?? "", videoId: searchShorts[index].id ?? "");

          if (UnlockPrivateVideoApi.unlockPrivateVideoModel?.isUnlocked == true) {
            searchShorts = searchShorts.map((e) {
              if (e.id == searchShorts[index].id) {
                e.videoPrivacyType = 1;
              }
              return e;
            }).toList();

            update(["onGetSearchData"]);
          }

          Get.close(2);
          SubscribedSuccessDialog.show(context);
        },
      );
    } else {
      UnlockPremiumVideoBottomSheet.onShow(
        coin: (searchVideo[index].videoUnlockCost ?? 0).toString(),
        callback: () async {
          Get.dialog(const LoaderUi(), barrierDismissible: false);
          await UnlockPrivateVideoApi.callApi(loginUserId: Database.loginUserId ?? "", videoId: searchVideo[index].id ?? "");

          if (UnlockPrivateVideoApi.unlockPrivateVideoModel?.isUnlocked == true) {
            searchVideo = searchVideo.map((e) {
              if (e.id == searchVideo[index].id) {
                e.videoPrivacyType = 1;
              }
              return e;
            }).toList();

            update(["onGetSearchData"]);
          }

          Get.close(2);
          SubscribedSuccessDialog.show(context);
        },
      );
    }
  }

  void onSubscribePrivateChannel({required int index, required BuildContext context, required bool isShorts}) async {
    if (isShorts) {
      SubscribePremiumChannelBottomSheet.onShow(
        coin: (searchShorts[index].subscriptionCost ?? 0).toString(),
        callback: () async {
          Get.dialog(const LoaderUi(), barrierDismissible: false);
          final bool isSuccess = await SubscribeChannelApiClass.callApi(searchShorts[index].channelId ?? "");

          Get.close(2);

          if (isSuccess) {
            searchShorts = searchShorts.map((e) {
              if (e.id == searchShorts[index].id) {
                e.videoPrivacyType = 1;
              }
              return e;
            }).toList();

            update(["onGetSearchData"]);
            SubscribedSuccessDialog.show(context);
          }
        },
      );
    } else {
      SubscribePremiumChannelBottomSheet.onShow(
        coin: (searchVideo[index].subscriptionCost ?? 0).toString(),
        callback: () async {
          Get.dialog(const LoaderUi(), barrierDismissible: false);
          final bool isSuccess = await SubscribeChannelApiClass.callApi(searchVideo[index].channelId ?? "");

          Get.close(2);

          if (isSuccess) {
            searchVideo = searchVideo.map((e) {
              if (e.id == searchVideo[index].id) {
                e.videoPrivacyType = 1;
              }
              return e;
            }).toList();

            update(["onGetSearchData"]);
            SubscribedSuccessDialog.show(context);
          }
        },
      );
    }
  }
}

class SearchAllModel {
  final int type;
  final dynamic data;
  SearchAllModel({required this.type, required this.data});
}

//
//
//
// List<SearchData>? searchAllVideos;
// List<SearchChannelData>? mainSearchChannels;
// List<SearchShortsData>? mainShortsVideos;
//
// // List<LastSearchedData>? allVideoSearchHistory;
// RxList<bool> isSubscribedChannel = <bool>[].obs;
//
// // RxBool isLoading = false.obs;
// RxBool isSearching = false.obs;
// RxBool isFilteredVideo = true.obs;
//
// @override
// void onInit() {
//   searchAllVideos = null;
//   searchController.clear();
//   super.onInit();
// }
//
// Future<void> onGetSearchShorts() async {
//   mainShortsVideos = null; // Clear Old Data...
//   update(["onGetSearchShorts"]);
//   mainShortsVideos = await SearchShortsApi.callApi(searchController.text, Database.loginUserId!) ?? [];
//   update(["onGetSearchShorts"]);
// }
//
// Future<void> onGetSearchVideos() async {
//   searchAllVideos = null;
//   update(["onGetSearchVideos"]);
//   searchAllVideos = await SearchAllVideoApiClass.callApi(searchController.text) ?? [];
//   update(["onGetSearchVideos"]);
// }

// void getAllVideoSearchHistory() async {
//   isLoading.value = true;
//   allVideoSearchHistory = await GetAllVideoSearchHistoryApi.callApi();
//   isLoading.value = false;
//   update();
// }
//
// Future clearAllHistory() async {
//   isLoading.value = true;
//   await ClearSearchHistoryApiClass.callApi();
//   allVideoSearchHistory?.clear();
//   isLoading.value = false;
// }

// void onSearchChannels() async {
//   mainSearchChannels = null;
//   isSubscribedChannel.value = [];
//   update(["onSearchChannels"]);
//   mainSearchChannels = await SearchChannelApiClass.callApi(searchController.text) ?? [];
//   mainSearchChannels?.forEach((element) {
//     isSubscribedChannel.add(element.isSubscribed!);
//   });
//
//   update(["onSearchChannels"]);
// }
