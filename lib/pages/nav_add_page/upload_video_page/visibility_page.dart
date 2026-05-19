import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:metube/custom/basic_button.dart';
import 'package:metube/custom/custom_method/custom_filled_button.dart';
import 'package:metube/pages/nav_add_page/upload_video_page/upload_video_controller.dart';
import 'package:metube/utils/colors/app_color.dart';
import 'package:metube/utils/string/app_string.dart';

class VisibilityPageView extends GetView<UploadVideoController> {
  const VisibilityPageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BasicAppBar(title: AppStrings.addVisibility.tr),
          const SizedBox(height: 10),
          const VisibilityDataView(index: 0),
          const VisibilityDataView(index: 1),
          const VisibilityDataView(index: 2),
          const Expanded(child: Offstage()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: CustomFilledButton(title: AppStrings.apply.tr, callback: () => Get.back()),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

class VisibilityDataView extends GetView<UploadVideoController> {
  const VisibilityDataView({super.key, required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    List visibilityCollection = [
      {"title": AppStrings.public.tr, "subTitle": AppStrings.anyoneCanSearchForAndView.tr},
      {"title": AppStrings.private.tr, "subTitle": AppStrings.onlyFollowersCanView.tr},
      {"title": AppStrings.unlisted.tr, "subTitle": AppStrings.anyoneWithTheLinkCanView.tr},
    ];
    return GestureDetector(
      onTap: () => controller.selectVisibility.value = index,
      child: Container(
        height: 50,
        width: Get.width,
        margin: const EdgeInsets.only(bottom: 15),
        color: Colors.transparent,
        child: Row(
          children: [
            Obx(
              () => Radio(
                fillColor: const WidgetStatePropertyAll(AppColor.primaryColor),
                value: index,
                groupValue: controller.selectVisibility.value,
                onChanged: (value) {},
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  visibilityCollection[index]["title"].toString(),
                  style: GoogleFonts.urbanist(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(
                  width: Get.width / 1.2,
                  child: Text(
                    visibilityCollection[index]["subTitle"].toString(),
                    maxLines: 1,
                    style: GoogleFonts.urbanist(fontSize: 14),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
