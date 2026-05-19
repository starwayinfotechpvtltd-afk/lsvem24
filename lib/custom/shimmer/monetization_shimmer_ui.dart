import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:metube/main.dart';
import 'package:metube/utils/colors/app_color.dart';
import 'package:shimmer/shimmer.dart';

class MonetizationShimmerUi extends StatelessWidget {
  const MonetizationShimmerUi({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: isDarkMode.value ? AppColor.secondDarkMode : AppColor.grey_300,
      highlightColor: AppColor.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          for (int i = 0; i < 2; i++)
            Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Container(
                    height: Get.height / 45,
                    width: Get.height / 8,
                    margin: const EdgeInsets.only(left: 5, top: 5, right: 5, bottom: 5),
                    decoration: BoxDecoration(color: AppColor.black, borderRadius: BorderRadius.circular(20)),
                  ),
                ),
                Container(
                  height: Get.height / 45,
                  margin: const EdgeInsets.only(left: 5, right: 5, bottom: 5),
                  decoration: BoxDecoration(color: AppColor.black, borderRadius: BorderRadius.circular(20)),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    height: Get.height / 45,
                    width: Get.height / 12,
                    margin: const EdgeInsets.only(bottom: 5, right: 5),
                    decoration: BoxDecoration(color: AppColor.black, borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              ],
            ),
        ],
      ).paddingSymmetric(horizontal: 15),
    );
  }
}
