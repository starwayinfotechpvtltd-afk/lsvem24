import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:metube/custom/basic_button.dart';
import 'package:metube/custom/custom_method/custom_filled_button.dart';
import 'package:metube/pages/nav_add_page/upload_video_page/upload_video_controller.dart';
import 'package:metube/utils/colors/app_color.dart';
import 'package:metube/utils/string/app_string.dart';

class CommentsPageView extends GetView<UploadVideoController> {
  const CommentsPageView({super.key});

  @override
  Widget build(BuildContext context) {
    final List commentCollection = [
      AppStrings.allowAllComments.tr,
      AppStrings.disableComments.tr,
      AppStrings.holdPotentiallyInappropriateCommentsForReview.tr,
      AppStrings.holdAllCommentsForReview.tr,
    ];

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BasicAppBar(title: AppStrings.comments.tr),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppStrings.commentText.tr, style: GoogleFonts.urbanist(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 10),
                for (int i = 0; i < 4; i++)
                  Row(
                    children: [
                      Obx(() => Radio(
                          fillColor: const WidgetStatePropertyAll(AppColor.primaryColor),
                          value: i,
                          groupValue: controller.selectComments.value,
                          onChanged: (value) => controller.selectComments.value = value!)),
                      Expanded(
                          child: Text(commentCollection[i], overflow: TextOverflow.ellipsis, maxLines: 1, style: GoogleFonts.urbanist(fontWeight: FontWeight.bold, fontSize: 14))),
                    ],
                  ),
              ],
            ),
          ),
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

// Row(
//   children: [
//     Obx(() => Radio(
//         fillColor: const MaterialStatePropertyAll(AppColors.primaryColor),
//         value: 3,
//         groupValue: AppSettings.selectComments.value,
//         onChanged: (value) => AppSettings.selectComments.value = value!)),
//     Text(AppSettings.commentCollection[3],
//         style: GoogleFonts.urbanist(fontWeight: FontWeight.bold, fontSize: 16)),
//   ],
// ),
// Row(
//   children: [
//     Obx(() => Radio(
//         fillColor: const MaterialStatePropertyAll(AppColors.primaryColor),
//         value: 4,
//         groupValue: AppSettings.selectComments.value,
//         onChanged: (value) => AppSettings.selectComments.value = value!)),
//     Text(AppSettings.commentCollection[4],
//         style: GoogleFonts.urbanist(fontWeight: FontWeight.bold, fontSize: 16)),
//   ],
// ),
// Row(
//   children: [
//     Obx(() => Radio(
//         fillColor: const MaterialStatePropertyAll(AppColors.primaryColor),
//         value: 2,
//         groupValue: AppSettings.selectComments.value,
//         onChanged: (value) => AppSettings.selectComments.value = value!)),
//     Text(AppSettings.commentCollection[2],
//         style: GoogleFonts.urbanist(fontWeight: FontWeight.bold, fontSize: 16)),
//   ],
// ),
