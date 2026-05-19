import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_typedefs/rx_typedefs.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:metube/utils/config/size_config.dart';
import 'package:metube/utils/string/app_string.dart';
import 'package:metube/utils/style/app_style.dart';

class GeneralView extends StatelessWidget {
  const GeneralView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: const SystemUiOverlayStyle(statusBarColor: Colors.transparent, statusBarBrightness: Brightness.dark),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          child: const Icon(Icons.arrow_back, size: 25),
          onTap: () => Get.back(),
        ),
        leadingWidth: 50,
        title: Text(AppStrings.general.tr, style: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              GeneralItemUi(
                title: AppStrings.uploads.tr,
                subTitle: AppStrings.anyNetwork.tr,
                callback: () {},
              ),
              GeneralItemUi(
                title: AppStrings.language.tr,
                subTitle: AppStrings.english.tr,
                callback: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GeneralItemUi extends StatelessWidget {
  const GeneralItemUi({super.key, required this.title, required this.subTitle, this.trailing, required this.callback});

  final String title;
  final String? subTitle;
  final Widget? trailing;
  final Callback callback;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: callback,
      child: Padding(
        padding: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 2.5),
        child: Row(
          children: [
            Text(title, style: settingsStyle),
            const Spacer(),
            Text(subTitle ?? "", style: settingsStyle),
            SizedBox(width: SizeConfig.blockSizeHorizontal * 2),
            trailing ?? const Icon(Icons.arrow_forward_ios_rounded, size: 15),
          ],
        ),
      ),
    );
  }
}

// GeneralModal(
//   onTap: () {},
//   widget: const Icon(
//     Icons.arrow_forward_ios_rounded,
//     size: 15,
//   ),
//   tital: AppStrings.takeABreak,
// ),
// GeneralModal(
//   onTap: () {},
//   widget: const Icon(
//     Icons.arrow_forward_ios_rounded,
//     size: 15,
//   ),
//   tital: AppStrings.itsBedTime,
// ),
// GeneralModal(
//   onTap: () {},
//   widget: const Icon(
//     Icons.arrow_forward_ios_rounded,
//     size: 15,
//   ),
//   subTital: AppStrings.off,
//   tital: AppStrings.playbackFeed,
// ),
// GeneralModal(
//   onTap: () {},
//   widget: const Icon(
//     Icons.arrow_forward_ios_rounded,
//     size: 15,
//   ),
//   subTital: AppStrings.tenS,
//   tital: AppStrings.doubleTapToSeek,
// ),
// GeneralModal(
//   onTap: () {},
//   widget: const Icon(
//     Icons.arrow_forward_ios_rounded,
//     size: 15,
//   ),
//   tital: AppStrings.zoomToFill,
// ),
// GeneralModal(
//   onTap: () {},
//   widget: const Icon(
//     Icons.arrow_forward_ios_rounded,
//     size: 15,
//   ),
//   tital: AppStrings.pip,
// ),

// GeneralModal(
//   onTap: () {},
//   widget: const Icon(
//     Icons.arrow_forward_ios_rounded,
//     size: 15,
//   ),
//   tital: AppStrings.restrictedMode,
// ),
// GeneralModal(
//   onTap: () {},
//   widget: const Icon(
//     Icons.arrow_forward_ios_rounded,
//     size: 15,
//   ),
//   tital: AppStrings.enableState,
// ),
