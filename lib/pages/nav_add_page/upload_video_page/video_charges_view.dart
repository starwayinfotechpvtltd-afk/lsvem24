import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:metube/main.dart';
import 'package:metube/pages/nav_add_page/upload_video_page/upload_video_controller.dart';
import 'package:metube/utils/colors/app_color.dart';
import 'package:metube/utils/icons/app_icons.dart';
import 'package:metube/utils/utils.dart';

class VideoChargesView extends StatelessWidget {
  const VideoChargesView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UploadVideoController>();
    return Scaffold(
      body: Column(
        children: [
          const VideoChargesAppbar(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  10.height,
                  Center(
                    child: Text(
                      "Select the video chargges method you want to use.",
                      style: GoogleFonts.urbanist(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ),
                  15.height,
                  GestureDetector(
                    onTap: () => controller.videoChargeType.value = 1,
                    child: Container(
                      height: 55,
                      width: Get.width,
                      margin: const EdgeInsets.symmetric(horizontal: 15),
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      decoration: BoxDecoration(
                        color: isDarkMode.value ? AppColor.mainDark : AppColor.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: AppColor.grey_200,
                            blurRadius: 2,
                          )
                        ],
                      ),
                      child: Row(
                        children: [
                          Image.asset(AppIcons.free, color: isDarkMode.value ? AppColor.white : AppColor.black, width: 25),
                          15.width,
                          Text(
                            "Free",
                            style: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.w700),
                          ),
                          const Spacer(),
                          Obx(
                            () => Transform.scale(
                              scale: 1.1,
                              child: Radio(
                                fillColor: const WidgetStatePropertyAll(AppColor.primaryColor),
                                value: 1,
                                groupValue: controller.videoChargeType.value,
                                onChanged: (value) {},
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  15.height,
                  GestureDetector(
                    onTap: () => controller.videoChargeType.value = 2,
                    child: Container(
                      height: 55,
                      width: Get.width,
                      margin: const EdgeInsets.symmetric(horizontal: 15),
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      decoration: BoxDecoration(
                        color: isDarkMode.value ? AppColor.mainDark : AppColor.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: AppColor.grey_200,
                            blurRadius: 2,
                          )
                        ],
                      ),
                      child: Row(
                        children: [
                          Image.asset(AppIcons.paid, color: isDarkMode.value ? AppColor.white : AppColor.black, width: 25),
                          15.width,
                          Text(
                            "Paid",
                            style: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.w700),
                          ),
                          const Spacer(),
                          Obx(
                            () => Transform.scale(
                              scale: 1.1,
                              child: Radio(
                                fillColor: const WidgetStatePropertyAll(AppColor.primaryColor),
                                value: 2,
                                groupValue: controller.videoChargeType.value,
                                onChanged: (value) {},
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: GestureDetector(
        onTap: () => Get.back(),
        child: Container(
          height: 55,
          width: Get.width,
          alignment: Alignment.center,
          margin: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: AppColor.primaryColor,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Text(
            "Apply",
            style: GoogleFonts.urbanist(fontSize: 16, color: AppColor.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

class VideoChargesAppbar extends StatelessWidget {
  const VideoChargesAppbar({super.key});

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
              "Video Charges",
              style: GoogleFonts.urbanist(fontSize: 20, color: isDarkMode.value ? AppColor.white : AppColor.black, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
