import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:metube/custom/custom_method/custom_format_number.dart';
import 'package:metube/custom/custom_ui/data_not_found_ui.dart';
import 'package:metube/database/database.dart';
import 'package:metube/main.dart';
import 'package:metube/pages/profile_page/coin_history_page/coin_history_view.dart';
import 'package:metube/pages/profile_page/withdraw_page/withdraw_view.dart';
import 'package:metube/pages/profile_page/my_wallet_page/my_wallet_controller.dart';
import 'package:metube/utils/colors/app_color.dart';
import 'package:metube/utils/icons/app_icons.dart';
import 'package:metube/utils/string/app_string.dart';
import 'package:metube/utils/auth/auth_service.dart';

class MyWalletView extends StatelessWidget {
  const MyWalletView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MyWalletController());
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
                  AppStrings.myWallet.tr,
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
            Container(
              height: 135,
              width: Get.width,
              padding: const EdgeInsets.only(left: 20, top: 10, bottom: 10),
              decoration: BoxDecoration(
                color: AppColor.grey_50,
                borderRadius: BorderRadius.circular(25),
                image: const DecorationImage(image: AssetImage(AppIcons.walletImage), fit: BoxFit.cover),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    AppStrings.myBalance.tr,
                    style: GoogleFonts.urbanist(fontSize: 16, color: AppColor.white, fontWeight: FontWeight.bold),
                  ),
                  GetBuilder<MyWalletController>(
                    id: "onGetWalletHistory",
                    builder: (controller) => Text(
                      "${AppStrings.currencySymbol} ${CustomFormatNumber.convert(controller.myBalance)}",
                      style: GoogleFonts.urbanist(fontSize: 34, color: AppColor.white, fontWeight: FontWeight.w900),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
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
                      GetBuilder<MyWalletController>(
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
              child: GetBuilder<MyWalletController>(
                id: "onGetWalletHistory",
                builder: (controller) => controller.isLoadingHistory
                    ? const HistoryShimmer()
                    : controller.walletHistory.isEmpty
                        ? DataNotFoundUi(title: AppStrings.noEarningTransactionsRecorded.tr)
                        : SingleChildScrollView(
                            child: ListView.builder(
                              itemCount: controller.walletHistory.length,
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                final indexData = controller.walletHistory[index];
                                return WalletItem(
                                  id: indexData.uniqueId ?? "",
                                  title: historyType(int.parse((indexData.type ?? 0).toString())),
                                  coin: CustomFormatNumber.convert(int.parse((indexData.coin ?? 0).toString())),
                                  dateTime: indexData.date ?? "",
                                  amount: "+ ${CustomFormatNumber.convert(int.parse((indexData.amount ?? 0).toString()))}",
                                );
                              },
                            ),
                          ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: GestureDetector(
        onTap: () async {
          if (!AuthService.checkLogin()) return;
          Get.to(WithdrawView(balance: controller.myBalance.toDouble()));
        },
        child: Container(
          height: 55,
          width: MediaQuery.of(context).size.width,
          margin: const EdgeInsets.all(15),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColor.primaryColor,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Text(
            AppStrings.withdraw.tr,
            textAlign: TextAlign.center,
            style: GoogleFonts.urbanist(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: AppColor.white,
            ),
          ),
        ),
      ),
    );
  }
}

String historyType(int type) {
  switch (type) {
    case 1:
      {
        return AppStrings.monetization.tr;
      }
    case 2:
      {
        return AppStrings.withdrawCoin.tr;
      }

    default:
      {
        return "";
      }
  }
}

class WalletItem extends StatelessWidget {
  const WalletItem({super.key, required this.id, required this.title, required this.coin, required this.dateTime, required this.amount});

  final String id;
  final String title;
  final String coin;
  final String amount;
  final String dateTime;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 75,
      width: Get.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: Get.width,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.urbanist(fontSize: 16, color: AppColor.primaryColor, fontWeight: FontWeight.bold),
                  ),
                ),
                Row(
                  children: [
                    Image.asset(width: 18, AppIcons.coin),
                    const SizedBox(width: 3),
                    Text(
                      coin,
                      style: GoogleFonts.urbanist(
                        fontSize: 16,
                        color: AppColor.primaryColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      amount,
                      style: GoogleFonts.urbanist(
                        fontSize: 16,
                        color: Colors.green,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
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
