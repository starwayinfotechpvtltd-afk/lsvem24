import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:metube/utils/icons/app_icons.dart';
import 'package:metube/utils/settings/app_settings.dart';

class CustomProfileImage extends StatelessWidget {
  const CustomProfileImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => AppSettings.profileImage.isEmpty
          ? Center(child: Image.asset(AppIcons.profileImage, fit: BoxFit.cover))
          : CachedNetworkImage(
              height: Get.height,
              width: Get.width,
              fit: BoxFit.cover,
              imageUrl: AppSettings.profileImage.value,
              useOldImageOnUrlChange: true,
              placeholder: (context, url) => Center(child: Image.asset(AppIcons.profileImage, fit: BoxFit.cover)),
              errorWidget: (context, string, dynamic) => Center(child: Image.asset(AppIcons.profileImage, fit: BoxFit.cover)),
            ),
    );
  }
}
