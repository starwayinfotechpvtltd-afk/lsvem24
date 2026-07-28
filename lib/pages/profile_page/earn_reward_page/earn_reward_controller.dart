import 'dart:math';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:metube/custom/custom_method/custom_get_current_week_date.dart';
import 'package:metube/custom/custom_method/custom_toast.dart';
import 'package:metube/custom/custom_ui/loader_ui.dart';
import 'package:metube/database/database.dart';
import 'package:metube/pages/profile_page/earn_reward_page/check_in_done_dialog.dart';
import 'package:metube/pages/profile_page/earn_reward_page/earn_coin_from_check_in_api.dart';
import 'package:metube/pages/profile_page/earn_reward_page/earn_coin_from_check_in_model.dart';
import 'package:metube/pages/profile_page/earn_reward_page/earn_coin_from_watch_ad_api.dart';
import 'package:metube/pages/profile_page/earn_reward_page/earn_coin_from_watch_ad_model.dart';
import 'package:metube/pages/profile_page/earn_reward_page/get_ad_reward_api.dart';
import 'package:metube/pages/profile_page/earn_reward_page/get_ad_reward_model.dart';
import 'package:metube/pages/profile_page/earn_reward_page/get_daily_reward_api.dart';
import 'package:metube/pages/profile_page/earn_reward_page/get_daily_reward_model.dart';
import 'package:metube/utils/settings/app_settings.dart';  
import 'package:metube/pages/long_video_ads/get_long_video_ads_api.dart';
import 'package:metube/pages/long_video_ads/long_video_ad_overlay.dart';
import 'package:metube/pages/long_video_ads/long_video_ad_model.dart';

class EarnRewardController extends GetxController {
  // >>>> Ad Reward <<<<<

  RxInt myRewardCoin = 0.obs;

  RxBool isShowOriginalCoin = false.obs;

  EarnCoinFromWatchAdModel? earnCoinFromWatchAdModel;
  GetAdRewardModel? getAdRewardModel;
  bool isLoadingAdRewards = false;
  List<Data> adRewards = [];
  Timer? timer;
  int completeAdTask = 0;
  bool isEnableCurrentAdTask = false;
  int nextAdTaskTime = 0;

  Future<void> init() async {
    onGetDailyRewards();
    await onGetAdRewards();

    if (completeAdTask == 0) {
      isEnableCurrentAdTask = true;
    } else if (Database.nextAdTaskTime == null || Database.nextAdTaskTime == 0) {
      isEnableCurrentAdTask = true;
    } else {
      onStartTimer();
    }
  }

  void onStopTimer() {
    timer?.cancel();
    nextAdTaskTime = 0;
    isEnableCurrentAdTask = true;
    Database.onSetNextAdTaskTime(nextAdTaskTime);
    update(["onChangeAdReward"]);
  }

  void onOpenApp() async {
    if (Database.lastRewardDate != null && Database.nextAdTaskTime != null && Database.nextAdTaskTime != 0) {
      DateTime now = DateTime.now();
      DateTime lastDateTime = DateTime.parse(Database.lastRewardDate ?? "");
      Duration difference = now.difference(lastDateTime);
      int seconds = difference.inSeconds;

      print("********* Dif => $seconds ");

      int lastTime = Database.nextAdTaskTime ?? 0;

      if (lastTime > seconds) {
        int currentTime = lastTime - seconds;
        Database.onSetNextAdTaskTime(currentTime);
      } else {
        Database.onSetNextAdTaskTime(0);
      }

      await 100.milliseconds.delay();

      update(["onChangeAdReward"]);
      onStartTimer();
    } else {
      onStartTimer();
    }
  }

  void onCloseApp() async {
    DateTime now = DateTime.now();
    Database.onSetLastRewardDate(now.toString());

    timer?.cancel();
    timer = null;
    Database.onSetNextAdTaskTime(nextAdTaskTime);
  }

  String convertAdTime(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int remainingSeconds = seconds % 60;

    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  //   int minutes = seconds ~/ 60;
  //   int remainingSeconds = seconds % 60;
  //
  //   String formattedMinutes = minutes.toString().padLeft(2, '0');
  //   String formattedSeconds = remainingSeconds.toString().padLeft(2, '0');
  //
  //   return '$formattedMinutes:$formattedSeconds';
  // }

  Future<void> onGetAdRewards() async {
    isLoadingAdRewards = true;
    update(["onGetAdRewards"]);
    getAdRewardModel = await GetAdRewardApi.callApi(userId: Database.loginUserId ?? "");

    completeAdTask = getAdRewardModel?.userWatchAds?.count ?? 0;

    if (getAdRewardModel?.data?.isNotEmpty ?? false) {
      adRewards.clear();
      adRewards.addAll(getAdRewardModel?.data ?? []);
      isLoadingAdRewards = false;
      update(["onGetAdRewards"]);
    }
  }

  Future<void> onClickPlay(int index) async {
  AppSettings.showLog("Click To Index => $index");

  if (index != completeAdTask || !isEnableCurrentAdTask) {
    return;
  }

  Get.dialog(
    const LoaderUi(),
    barrierDismissible: false,
  );

  final ads = await GetLongVideoAdsApi.callApi(
    placement: "pre-roll",
  );

  if (Get.isDialogOpen ?? false) {
    Get.back();
  }

  if (ads.isEmpty) {
    CustomToast.show("No advertisement available");
    return;
  }

  final random = Random();
  final LongVideoAd ad = ads[random.nextInt(ads.length)];

  Get.to(
    () => LongVideoAdOverlay(
      ad: ad,
      isRewardAd: true,

      onStarted: () {
        AppSettings.showLog("Reward ad started");
      },

      onCompleted: () async {
          Get.back();

        onShowAd(index);

        await onCreateAdReward(
          adRewards[index].coinEarnedFromAd ?? 0,
        );
      },

      onFailed: () {
        if (Get.isOverlaysOpen) {
          Get.back();
        }

        CustomToast.show("Failed to play advertisement");
      },
    ),
  );
}

  void onShowAd(int index) {
    final newIndex = index + 1;

    if (newIndex < adRewards.length) {
      AppSettings.showLog("Next Task Available");

      isEnableCurrentAdTask = false;
      nextAdTaskTime = adRewards[newIndex].adDisplayInterval ?? 0;
      completeAdTask = newIndex;
      Database.onSetNextAdTaskTime(nextAdTaskTime);

      AppSettings.showLog("Ad Reward Save Database => $completeAdTask ${Database.nextAdTaskTime}");
      update(["onChangeAdReward"]);

      onStartTimer();
    } else {
      completeAdTask = adRewards.length;
      isEnableCurrentAdTask = false;
      Database.onSetNextAdTaskTime(0);
      update(["onChangeAdReward"]);
      AppSettings.showLog("Next Not Task Available");
    }
  }

  void onStartTimer() {
    AppSettings.showLog("On Start Time");
    isEnableCurrentAdTask = false;
    nextAdTaskTime = Database.nextAdTaskTime ?? 0;

    if (nextAdTaskTime != 0) {
      timer?.cancel();
      timer = null;
      timer = Timer.periodic(
        const Duration(seconds: 1),
        (time) {
          if (nextAdTaskTime != 0) {
            nextAdTaskTime--;
            Database.onSetNextAdTaskTime(nextAdTaskTime);
            update(["onChangeAdReward"]);
          } else {
            onStopTimer();
          }
        },
      );
    } else {
      isEnableCurrentAdTask = true;
    }
  }

  Future<void> onCreateAdReward(int coinEarnedFromAd) async {
    earnCoinFromWatchAdModel = await EarnCoinFromWatchAdApi.callApi(
      loginUserId: Database.loginUserId ?? "",
      coinEarnedFromAd: coinEarnedFromAd,
    );
    if (earnCoinFromWatchAdModel?.status == false) {
      CustomToast.show(earnCoinFromWatchAdModel?.message ?? "");
    } else if (earnCoinFromWatchAdModel?.data?.coin != null) {
      myRewardCoin.value = earnCoinFromWatchAdModel?.data?.coin ?? 0;
    }
  }

  // >>>>> >>>>> >>>>> Check In Reward <<<<< <<<<< <<<<<

  GetDailyRewardModel? getDailyRewardModel;
  EarnCoinFromCheckInModel? earnCoinFromCheckInModel;
  bool isLoadingDailyRewards = false;
  List<DailyRewardData> dailyRewards = [];
  bool isTodayCheckIn = false;
  int todayCoin = 0;

  Future<void> onGetDailyRewards() async {
    isLoadingDailyRewards = true;
    update(["onGetDailyRewards"]);
    getDailyRewardModel = await GetDailyRewardApi.callApi(loginUserId: Database.loginUserId ?? "");

    if (getDailyRewardModel?.data?.isNotEmpty ?? false) {
      dailyRewards.clear();
      dailyRewards.addAll(getDailyRewardModel?.data ?? []);
      isLoadingDailyRewards = false;

      myRewardCoin.value = getDailyRewardModel?.totalCoins ?? 0;

      int currentWeekday = DateTime.now().weekday; // Monday = 1, Sunday = 7

      isTodayCheckIn = false;
      todayCoin = 0;

      for (int index = 0; index < dailyRewards.length; index++) {
        if (dailyRewards[index].day == currentWeekday) {
          todayCoin = dailyRewards[index].reward ?? 0;
          isTodayCheckIn = dailyRewards[index].isCheckIn ?? false;
          break;
        }
      }
      update(["onGetDailyRewards"]);
    } else {
      isLoadingDailyRewards = false;
      update(["onGetDailyRewards"]);
    }
  }

  void onCheckIn(BuildContext context) async {
    if (isTodayCheckIn) {
      CustomToast.show("You have already checked in today.");
    } else {
      Get.dialog(const LoaderUi(), barrierDismissible: false);
      earnCoinFromCheckInModel = await EarnCoinFromCheckInApi.callApi(
        loginUserId: Database.loginUserId ?? "",
        dailyRewardCoin: todayCoin,
      );

      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      if (earnCoinFromCheckInModel?.status == true) {
        CheckInDoneDialog.show(context, todayCoin.toString());
        await onGetDailyRewards();
      } else {
        CustomToast.show(earnCoinFromCheckInModel?.message ?? "Check-in failed");
      }
    }
  }
}

//   @override
//   void onInit() {
//     onRestart();
//     super.onInit();
//   }
//

// DateTime now = DateTime.now();
// String currentDate = DateTime(now.year, now.month, now.day).toString();
//
// if (currentDate != Database.lastRewardDate) {
//   Database.onSetNextAdTaskTime(0);
//   Database.onSetCurrentAdTask(0);
//   Database.onSetLastRewardDate(currentDate);
//
//   AppSettings.showLog("New Day Start = >${Database.lastRewardDate}");
// }
//
// isEnable = false;
// currentAdTask = Database.currentAdTask ?? 0;
//
// if (currentAdTask == 0 || nextAdTaskTime == 0) {
//   isEnable = true;
// }
