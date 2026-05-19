import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:metube/custom/basic_button.dart';
import 'package:metube/custom/custom_method/custom_filled_button.dart';
import 'package:metube/pages/nav_add_page/upload_video_page/upload_video_controller.dart';
import 'package:metube/utils/colors/app_color.dart';
import 'package:metube/utils/string/app_string.dart';

class AudiencePageView extends GetView<UploadVideoController> {
  const AudiencePageView({super.key});

  @override
  Widget build(BuildContext context) {
    final List audienceCollection = [
      AppStrings.itsMadeForKids.tr,
      AppStrings.itsMadeFor18Adult.tr,
      AppStrings.itsMadeForBothKids18Adult.tr,
    ];
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BasicAppBar(title: AppStrings.selectAudience.tr),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int i = 0; i < audienceCollection.length; i++)
                  GestureDetector(
                    onTap: () => controller.selectAudience.value = i,
                    child: Container(
                      height: 50,
                      width: Get.width,
                      color: Colors.transparent,
                      child: Row(
                        children: [
                          Obx(() =>
                              Radio(fillColor: const WidgetStatePropertyAll(AppColor.primaryColor), value: i, groupValue: controller.selectAudience.value, onChanged: (value) {})),
                          Expanded(
                              child: Text(audienceCollection[i],
                                  maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.urbanist(fontWeight: FontWeight.bold, fontSize: 16))),
                        ],
                      ),
                    ),
                  ),
                // Container(
                //   height: 50,
                //   width: Get.width,
                //   color: Colors.red,
                //   child: Row(
                //     children: [
                //       Obx(
                //         () => Radio(
                //             fillColor: const MaterialStatePropertyAll(AppColors.primaryColor),
                //             value: 1,
                //             groupValue: controller.selectAudience.value,
                //             onChanged: (value) => controller.selectAudience.value = value!),
                //       ),
                //       Text(controller.audienceCollection[1], style: GoogleFonts.urbanist(fontWeight: FontWeight.bold, fontSize: 16)),
                //     ],
                //   ),
                // ),
                // Container(
                //   height: 50,
                //   width: Get.width,
                //   color: Colors.red,
                //   child: Row(
                //     children: [
                //       Obx(
                //         () => Radio(
                //             fillColor: const MaterialStatePropertyAll(AppColors.primaryColor),
                //             value: 2,
                //             groupValue: controller.selectAudience.value,
                //             onChanged: (value) => controller.selectAudience.value = value!),
                //       ),
                //       Text(controller.audienceCollection[2], style: GoogleFonts.urbanist(fontWeight: FontWeight.bold, fontSize: 16)),
                //     ],
                //   ),
                // ),
                const SizedBox(height: 10),
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
