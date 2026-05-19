import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:metube/custom/custom_method/custom_image_picker.dart';
import 'package:metube/main.dart';
import 'package:metube/utils/colors/app_color.dart';
import 'package:metube/utils/config/size_config.dart';
import 'package:metube/utils/icons/app_icons.dart';
import 'package:metube/utils/string/app_string.dart';
import 'package:metube/utils/style/app_style.dart';

void chooseImageBottomSheet() {
  Get.bottomSheet(
    backgroundColor: isDarkMode.value ? AppColor.secondDarkMode : Colors.white,
    SizedBox(
      height: 160,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 8),
          Container(
            width: SizeConfig.blockSizeHorizontal * 12,
            height: 3,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(60), color: AppColor.grey_300),
          ),
          const SizedBox(height: 10),
          Text(AppStrings.chooseImage.tr, style: titalstyle1),
          const SizedBox(height: 5),
          Divider(indent: 25, endIndent: 25, color: AppColor.grey_300.withOpacity(0.8)),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GestureDetector(
              onTap: () => CustomImagePicker.pickImage(ImageSource.camera),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Image.asset(AppIcons.camera, color: isDarkMode.value ? AppColor.white.withOpacity(0.5) : AppColor.black, height: 30, width: 30),
                  const SizedBox(width: 15),
                  Text("Take a photo", style: bottomstyle)
                ],
              ),
            ),
          ),
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GestureDetector(
              onTap: () => CustomImagePicker.pickImage(ImageSource.gallery),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Image.asset(AppIcons.gallery, color: isDarkMode.value ? AppColor.white.withOpacity(0.5) : AppColor.black, height: 25, width: 25).paddingOnly(left: 3),
                  const SizedBox(width: 15),
                  Text("Choose from your file", style: bottomstyle)
                ],
              ),
            ),
          ),
          const SizedBox(height: 15),
        ],
      ),
    ),
  );
}
