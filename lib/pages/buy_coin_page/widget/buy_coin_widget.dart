import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:metube/main.dart';
import 'package:metube/pages/buy_coin_history_page/view/buy_coin_history_view.dart';
import 'package:metube/utils/colors/app_color.dart';
import 'package:metube/utils/icons/app_icons.dart';
import 'package:metube/utils/string/app_string.dart';
import 'package:metube/utils/utils.dart';

class BuyCoinAppbarWidget extends StatelessWidget {
  const BuyCoinAppbarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      width: Get.width,
      color: AppColor.transparent,
      margin: EdgeInsets.only(top: MediaQuery.of(context).viewPadding.top),
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: Center(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                height: 50,
                width: 50,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColor.transparent,
                  shape: BoxShape.circle,
                ),
                child: Image.asset(AppIcons.arrowBack, color: isDarkMode.value ? AppColor.white : AppColor.black, width: 22),
              ),
            ),
            5.width,
            Text(
              AppStrings.buyCoins.tr,
              style: GoogleFonts.urbanist(fontSize: 20, color: isDarkMode.value ? AppColor.white : AppColor.black, fontWeight: FontWeight.bold),
            ),
            Spacer(),
            GestureDetector(
              onTap: () => Get.to(BuyCoinHistoryView()),
              child: Container(
                height: 50,
                width: 50,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColor.transparent,
                  shape: BoxShape.circle,
                ),
                child: Image.asset(AppIcons.historyIcon, width: 23),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
