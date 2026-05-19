import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:metube/custom/custom_ui/data_not_found_ui.dart';
import 'package:metube/main.dart';
import 'package:metube/pages/profile_page/coin_history_page/coin_history_controller.dart';
import 'package:metube/utils/colors/app_color.dart';
import 'package:metube/utils/icons/app_icons.dart';
import 'package:metube/utils/string/app_string.dart';
import 'package:shimmer/shimmer.dart';

class CoinHistoryView extends StatelessWidget {
  const CoinHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CoinHistoryController());
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(MediaQuery.of(context).viewPadding.top + 60),
        child: Container(
          padding: EdgeInsets.only(top: MediaQuery.of(context).viewPadding.top, left: 15, right: 15),
          height: MediaQuery.of(context).viewPadding.top + 60,
          width: Get.width,
          color: AppColor.transparent,
          child: Row(
            children: [
              GestureDetector(
                onTap: Get.back,
                child: Container(
                  height: 40,
                  width: 40,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(color: Colors.transparent, shape: BoxShape.circle),
                  child: Obx(
                    () => Image.asset(
                      AppIcons.arrowBack,
                      color: isDarkMode.value ? AppColor.white : AppColor.black,
                      width: 23,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Obx(
                () => Text(
                  AppStrings.coinHistory.tr,
                  style: GoogleFonts.urbanist(
                    fontSize: 19,
                    color: isDarkMode.value ? AppColor.white : AppColor.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  AppStrings.history.tr,
                  style: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => controller.onChangeDateRange(context),
                  child: Row(
                    children: [
                      GetBuilder<CoinHistoryController>(
                        id: "onChangeDateRange",
                        builder: (controller) => Text(
                          controller.selectDateRange,
                          style: GoogleFonts.urbanist(fontSize: 12, color: AppColor.primaryColor, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Image.asset(
                        AppIcons.downArrowBold,
                        width: 20,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: GetBuilder<CoinHistoryController>(
                id: "onGetConvertedCoinHistory",
                builder: (controller) => controller.isLoadingHistory
                    ? const HistoryShimmer()
                    : controller.convertedCoinHistory.isEmpty
                        ? DataNotFoundUi(title: AppStrings.coinHistoryNotAvailable.tr)
                        : SingleChildScrollView(
                            child: ListView.builder(
                              itemCount: controller.convertedCoinHistory.length,
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                final indexData = controller.convertedCoinHistory[index];
                                return CoinHistoryItem(
                                  id: indexData.uniqueId ?? "",
                                  title: historyType(indexData.type ?? 0),
                                  coin: "+ ${indexData.coin ?? 0}",
                                  dateTime: indexData.date ?? "",
                                  isIncome: indexData.isIncome ?? false,
                                );
                              },
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

String historyType(int type) {
  switch (type) {
    case 1:
      {
        return AppStrings.dailyCheckIn.tr;
      }
    case 2:
      {
        return AppStrings.dailyTask.tr;
      }
    case 3:
      {
        return AppStrings.loginBonus.tr;
      }
    case 4:
      {
        return AppStrings.referralBonus.tr;
      }
    case 5:
      {
        return AppStrings.engWatchVideoBonus.tr;
      }
    case 6:
      {
        return AppStrings.engCommentVideoBonus.tr;
      }
    case 7:
      {
        return AppStrings.engLikeVideoBonus.tr;
      }
    case 8:
      {
        return AppStrings.purchaseCoinPlan.tr;
      }
    case 9:
      {
        return AppStrings.unlockPrivateVideo.tr;
      }
    case 10:
      {
        return AppStrings.subscribePrivateChannel.tr;
      }
    default:
      {
        return "";
      }
  }
}

class HistoryShimmer extends StatelessWidget {
  const HistoryShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: isDarkMode.value ? AppColor.secondDarkMode : AppColor.grey_300,
      highlightColor: AppColor.white,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (int i = 0; i < 15; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  children: [
                    SizedBox(
                      width: Get.width,
                      child: Row(
                        children: [
                          Container(
                            height: 25,
                            width: 200,
                            margin: const EdgeInsets.all(2),
                            decoration: BoxDecoration(color: AppColor.black, borderRadius: BorderRadius.circular(5)),
                          ),
                          const Spacer(),
                          Container(
                            height: 25,
                            width: 100,
                            margin: const EdgeInsets.all(2),
                            decoration: BoxDecoration(color: AppColor.black, borderRadius: BorderRadius.circular(5)),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: Get.width,
                      child: Row(
                        children: [
                          Container(
                            height: 25,
                            width: 100,
                            margin: const EdgeInsets.all(2),
                            decoration: BoxDecoration(color: AppColor.black, borderRadius: BorderRadius.circular(5)),
                          ),
                          const Spacer(),
                          Container(
                            height: 25,
                            width: 150,
                            margin: const EdgeInsets.all(2),
                            decoration: BoxDecoration(color: AppColor.black, borderRadius: BorderRadius.circular(5)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class CoinHistoryItem extends StatelessWidget {
  const CoinHistoryItem({super.key, required this.id, required this.title, required this.coin, required this.dateTime, required this.isIncome});

  final String id;
  final String title;
  final String coin;
  final String dateTime;
  final bool isIncome;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 75,
      width: Get.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Text(
                title,
                style: GoogleFonts.urbanist(fontSize: 16, color: AppColor.primaryColor, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Text(
                coin,
                style: GoogleFonts.urbanist(
                  fontSize: 16,
                  color: isIncome ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Row(
            children: [
              Text(
                "ID : $id",
                style: GoogleFonts.urbanist(fontSize: 12, color: AppColor.grey, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Image.asset(
                width: 16,
                AppIcons.timeCircle,
                color: AppColor.grey,
              ),
              const SizedBox(width: 3),
              Text(
                dateTime,
                style: GoogleFonts.urbanist(fontSize: 10.3, color: AppColor.grey, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Divider(color: AppColor.grey_200),
        ],
      ),
    );
  }
}
