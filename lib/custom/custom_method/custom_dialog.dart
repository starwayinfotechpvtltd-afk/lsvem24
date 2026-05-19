import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:metube/custom/custom_ui/loader_ui.dart';
import 'package:metube/main.dart';
import 'package:metube/utils/colors/app_color.dart';
import 'package:metube/utils/config/size_config.dart';
import 'package:metube/utils/style/app_style.dart';

class CustomDialog {
  // ✅ Original show method with auto-close loader
  static void show(String image, String title, String subTitle) {
    Get.defaultDialog(
      title: "",
      barrierDismissible: false,
      backgroundColor: isDarkMode.value ? AppColor.secondDarkMode : AppColor.white,
      content: Container(
        height: Get.height / 2.15,
        padding: EdgeInsets.only(
          left: SizeConfig.blockSizeHorizontal * 2,
          right: SizeConfig.blockSizeHorizontal * 2,
        ),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
        child: Column(
          children: [
            Container(
              height: Get.height / 5.6,
              width: Get.width / 1.9,
              decoration: BoxDecoration(
                image: DecorationImage(image: AssetImage(image)),
              ),
            ),
            const SizedBox(height: 10),
            Text(title, style: congratulationsStyle, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            Text(subTitle, style: createPinNoteStyle, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            const LoaderUi(),
          ],
        ),
      ),
    );
  }

  // ✅ NEW: Show dialog with Continue button (no auto-close)
  static Future<void> showWithButton(
    String image,
    String title,
    String subTitle, {
    String buttonText = "Continue",
    VoidCallback? onPressed,
  }) async {
    await Get.dialog(
      WillPopScope(
        onWillPop: () async => false, // Prevent back button dismiss
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: isDarkMode.value ? AppColor.secondDarkMode : AppColor.white,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: SizeConfig.blockSizeHorizontal * 5,
              vertical: SizeConfig.blockSizeVertical * 3,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Image
                Container(
                  height: Get.height / 5.6,
                  width: Get.width / 1.9,
                  decoration: BoxDecoration(
                    image: DecorationImage(image: AssetImage(image)),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Title
                Text(
                  title,
                  style: congratulationsStyle,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 15),
                
                // Subtitle
                Text(
                  subTitle,
                  style: createPinNoteStyle,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                
                // Continue Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      Get.back(); // Close dialog
                      if (onPressed != null) {
                        onPressed();
                      }
                    },
                    child: Text(
                      buttonText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  // ✅ NEW: Show dialog with auto-close after delay
  static Future<void> showWithDelay(
    String image,
    String title,
    String subTitle, {
    Duration delay = const Duration(seconds: 2),
  }) async {
    Get.defaultDialog(
      title: "",
      barrierDismissible: false,
      backgroundColor: isDarkMode.value ? AppColor.secondDarkMode : AppColor.white,
      content: Container(
        height: Get.height / 2.15,
        padding: EdgeInsets.only(
          left: SizeConfig.blockSizeHorizontal * 2,
          right: SizeConfig.blockSizeHorizontal * 2,
        ),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
        child: Column(
          children: [
            Container(
              height: Get.height / 5.6,
              width: Get.width / 1.9,
              decoration: BoxDecoration(
                image: DecorationImage(image: AssetImage(image)),
              ),
            ),
            const SizedBox(height: 10),
            Text(title, style: congratulationsStyle, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            Text(subTitle, style: createPinNoteStyle, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            const LoaderUi(),
          ],
        ),
      ),
    );

    // Wait for delay then close
    await Future.delayed(delay);
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }
}
