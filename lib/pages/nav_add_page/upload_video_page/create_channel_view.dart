import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:metube/custom/custom_method/custom_toast.dart';
import 'package:metube/custom/custom_ui/loader_ui.dart';
import 'package:metube/database/database.dart';
import 'package:metube/main.dart';
import 'package:metube/pages/login_related_page/fill_profile_page/get_profile_api.dart';
import 'package:metube/pages/nav_add_page/upload_video_page/check_channel_name_api.dart';
import 'package:metube/pages/nav_add_page/upload_video_page/upload_video_controller.dart';
import 'package:metube/utils/colors/app_color.dart';
import 'package:metube/utils/config/size_config.dart';
import 'package:metube/utils/settings/app_settings.dart';
import 'package:metube/utils/string/app_string.dart';
import 'package:metube/utils/style/app_style.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:metube/utils/utils.dart';

class CreateChannelView extends StatelessWidget {
  const CreateChannelView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UploadVideoController>();
    List channelTypes = [1, 2];
    return Scaffold(
      appBar: AppBar(
        // leading: Container(
        //   padding: EdgeInsets.only(left: SizeConfig.blockSizeHorizontal * 2),
        //   alignment: Alignment.topLeft,
        //   child: IconButton(
        //     icon: Image(
        //       image: const AssetImage(AppIcons.arrowBack),
        //       height: 18,
        //       width: 18,
        //       color: isDarkMode.value ? AppColors.white : AppColors.black,
        //     ),
        //     onPressed: () => Get.back(),
        //   ),
        // ),
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: AppSettings.isCenterTitle,
        title: Text(
          AppStrings.createYourChannel.tr,
          style: GoogleFonts.urbanist(
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      bottomNavigationBar: GestureDetector(
        onTap: () async {
          AppSettings.showLog("Create Channel Method Called");
          if (controller.channelName.text.trim().isEmpty ||
              controller.channelDescription.text.trim().isEmpty) {
            CustomToast.show(AppStrings.pleaseFillUpDetails.tr);
          } else {
            FocusScope.of(context).requestFocus(FocusNode());

            Get.dialog(const LoaderUi(color: AppColor.white),
                barrierDismissible: false);

            final status = await CheckChannelNameApi.callApi(
                controller.channelName.text.trim());

            if (status == null) {
              Get.back();
              CustomToast.show(AppStrings.someThingWentWrong.tr);
            } else if (status == false) {
              Get.back();
              CustomToast.show(
                  "The provided channelName is already in use. Please choose a different one.");
            } else {
              await GetProfileApi.callApi(Database.loginUserId!);
              Get.close(2);
            }
          }
        },
        child: Container(
          alignment: Alignment.center,
          height: Get.height / 15,
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: BoxDecoration(
              color: AppColor.primaryColor,
              borderRadius: BorderRadius.circular(30)),
          child: Text(AppStrings.continueString.tr, style: getStartStyle),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        child: SizedBox(
          height: Get.height,
          width: Get.width,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: SizeConfig.screenHeight / 60),
                  ChannelNameField(controller: controller.channelName),
                  SizedBox(height: SizeConfig.screenHeight / 30),
                  ChannelDescriptionField(
                      controller: controller.channelDescription),
                  SizedBox(height: SizeConfig.screenHeight / 30),
                  Container(
                    height: Get.height / 16,
                    width: Get.width / 1.1,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      color: isDarkMode.value
                          ? AppColor.secondDarkMode
                          : AppColor.grey_100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: DropdownButtonFormField2(
                      value: AppSettings.channelType.value,
                      decoration: const InputDecoration(
                        isDense: true,
                        suffixIconConstraints:
                            BoxConstraints(minWidth: 2, minHeight: 2),
                        prefixIconConstraints:
                            BoxConstraints(minWidth: 2, minHeight: 2),
                        contentPadding: EdgeInsets.zero,
                        border: InputBorder.none,
                      ),
                      isExpanded: true,
                      hint: Text("${AppStrings.channelType.tr} *",
                          style: fillYourProfileStyle),
                      items: channelTypes
                          .map(
                            (item) => DropdownMenuItem<int>(
                              value: item,
                              child: Text(
                                item == 1
                                    ? AppStrings.public.tr
                                    : AppStrings.private.tr,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        AppSettings.channelType.value = value ?? 0;
                        Utils.showLog(
                            "Channel Type => ${AppSettings.channelType.value}");
                      },
                    ),
                  ),
                  SizedBox(height: SizeConfig.screenHeight / 40),
                  SocialTextField(
                    hintText: AppStrings.instagram.tr,
                    controller: AppSettings.instagramController,
                    prefixIcon: Icons.camera_alt_outlined, // ✅
                    inputFormatter: [LengthLimitingTextInputFormatter(50)],
                  ),
                  SizedBox(height: SizeConfig.screenHeight / 40),
                  SocialTextField(
                    hintText: AppStrings.facebook.tr,
                    controller: AppSettings.facebookController,
                    prefixIcon: Icons.facebook, // ✅
                    inputFormatter: [LengthLimitingTextInputFormatter(50)],
                  ),
                  SizedBox(height: SizeConfig.screenHeight / 40),
                  SocialTextField(
                    hintText: AppStrings.twitter.tr,
                    controller: AppSettings.twitterController,
                    prefixIcon: Icons.alternate_email, // ✅ X/Twitter
                    inputFormatter: [LengthLimitingTextInputFormatter(50)],
                  ),
                  SizedBox(height: SizeConfig.screenHeight / 40),
                  SocialTextField(
                    hintText: AppStrings.website.tr,
                    controller: AppSettings.websiteController,
                    prefixIcon: Icons.language, // ✅
                    inputFormatter: [LengthLimitingTextInputFormatter(50)],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ChannelNameField extends StatelessWidget {
  const ChannelNameField({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: SizeConfig.screenHeight / 16,
      width: SizeConfig.screenWidth / 1.1,
      alignment: Alignment.center,
      padding: const EdgeInsets.only(left: 20),
      decoration: BoxDecoration(
        color: isDarkMode.value ? AppColor.secondDarkMode : AppColor.grey_100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextFormField(
        controller: controller,
        inputFormatters: [LengthLimitingTextInputFormatter(20)],
        decoration: InputDecoration(
          hintText: AppStrings.channelName.tr,
          hintStyle: fillYourProfileStyle,
          isDense: true,
          suffixIconConstraints: const BoxConstraints(
            minWidth: 2,
            minHeight: 2,
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 2,
            minHeight: 2,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }
}

class ChannelDescriptionField extends StatelessWidget {
  const ChannelDescriptionField({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: SizeConfig.screenHeight / 6,
      width: SizeConfig.screenWidth / 1.1,
      alignment: Alignment.center,
      padding: const EdgeInsets.only(left: 20),
      decoration: BoxDecoration(
        color: isDarkMode.value ? AppColor.secondDarkMode : AppColor.grey_100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextFormField(
        onEditingComplete: () => FocusScope.of(context).unfocus(),
        controller: controller,
        style: const TextStyle(
          decoration: TextDecoration.none,
          fontSize: 16,
        ),
        maxLines: 7,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.only(top: 10),
          border: InputBorder.none,
          hintText: "Tell us about yourself...",
          hintStyle: fillYourProfileStyle,
        ),
      ),
    );
  }
}

class SocialTextField extends StatelessWidget {
  const SocialTextField({
    super.key,
    required this.hintText,
    required this.controller,
    this.keyboardType,
    this.isReadOnly,
    this.inputFormatter,
    this.prefixIcon,
  });

  final String hintText;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final bool? isReadOnly;
  final List<TextInputFormatter>? inputFormatter;
  final IconData? prefixIcon;

  @override
  Widget build(BuildContext context) {
    return Obx(() => Container( // ✅ KEY FIX — Obx makes it reactive
      height: SizeConfig.screenHeight / 16,
      width: SizeConfig.screenWidth / 1.1,
      alignment: Alignment.center,
      padding: const EdgeInsets.only(left: 12),
      decoration: BoxDecoration(
        color: isDarkMode.value ? AppColor.secondDarkMode : AppColor.grey_100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextFormField(
        cursorColor: isDarkMode.value ? AppColor.white : AppColor.black,
        style: GoogleFonts.urbanist(
          color: isDarkMode.value ? AppColor.white : AppColor.black,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
        controller: controller,
        keyboardType: keyboardType ?? TextInputType.url,
        readOnly: isReadOnly ?? false,
        inputFormatters: inputFormatter,
        decoration: InputDecoration(
          isDense: true,
          hintText: hintText,
          border: InputBorder.none,
          prefixIcon: prefixIcon != null
              ? Icon(prefixIcon, color: AppColor.primaryColor, size: 20)
              : null,
          prefixIconConstraints:
              const BoxConstraints(minWidth: 40, minHeight: 0),
          hintStyle: GoogleFonts.urbanist(
            color: isDarkMode.value
                ? AppColor.white.withOpacity(0.4)
                : AppColor.grey,
            fontWeight: FontWeight.w400,
            fontSize: 15,
          ),
        ),
      ),
    ));
  }
}
