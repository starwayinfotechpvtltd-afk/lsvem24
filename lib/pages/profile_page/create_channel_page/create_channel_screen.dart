import 'dart:developer';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:metube/custom/basic_button.dart';
import 'package:metube/custom/custom_method/custom_toast.dart';
import 'package:metube/custom/custom_ui/loader_ui.dart';
import 'package:metube/database/database.dart';
import 'package:metube/main.dart';
import 'package:metube/pages/login_related_page/fill_profile_page/get_profile_api.dart';
import 'package:metube/pages/profile_page/create_channel_page/create_channel_api.dart';
import 'package:metube/utils/colors/app_color.dart';
import 'package:metube/utils/config/size_config.dart';
import 'package:metube/utils/icons/app_icons.dart';
import 'package:metube/utils/settings/app_settings.dart';
import 'package:metube/utils/string/app_string.dart';
import 'package:metube/utils/style/app_style.dart';
import 'package:metube/utils/utils.dart';
import 'package:flutter/services.dart';
import 'package:metube/utils/auth/auth_service.dart';

class CreateChannelScreen extends StatefulWidget {
  const CreateChannelScreen({super.key});

  @override
  State<CreateChannelScreen> createState() => _CreateChannelScreenState();
}

class _CreateChannelScreenState extends State<CreateChannelScreen> {
  @override
  Widget build(BuildContext context) {
    List channelTypes = [1, 2];

    return Scaffold(
      appBar: AppBar(
        leading: Container(
          padding: EdgeInsets.only(left: SizeConfig.blockSizeHorizontal * 2),
          alignment: Alignment.topLeft,
          child: IconButton(
            icon: Image(
              image: const AssetImage(AppIcons.arrowBack),
              height: 18,
              width: 18,
              color: isDarkMode.value ? AppColor.white : AppColor.black,
            ),
            onPressed: () {
              Get.back();
            },
          ),
        ),
        elevation: 0,
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
          if (!AuthService.checkLogin()) return;
          AppSettings.showLog("Create Channel Method Called");
          if (AppSettings.nameController.text.isEmpty || AppSettings.channelDescriptionController.text.isEmpty) {
            CustomToast.show(AppStrings.pleaseFillUpDetails.tr);
          } else {
            Get.dialog(const LoaderUi(color: AppColor.white), barrierDismissible: false);
            await CreateChannelApi.callApi();
            if (CreateChannelApi.status != null && CreateChannelApi.status == true) {
              await GetProfileApi.callApi(Database.loginUserId!);
              CustomToast.show(AppStrings.channelCreated.tr);
              Get.close(2);
            } else if (CreateChannelApi.message == "The provided channelName is already in use. Please choose a different one.") {
              Get.back();
              CustomToast.show(CreateChannelApi.message.toString());
            } else {
              Get.back();
              CustomToast.show(AppStrings.someThingWentWrong.tr);
            }
          }
        },
        child: Container(
          alignment: Alignment.center,
          height: Get.height / 15,
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: BoxDecoration(color: AppColor.primaryColor, borderRadius: BorderRadius.circular(30)),
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
                  const ChannelNameTextFormField(),
                  SizedBox(height: SizeConfig.screenHeight / 30),
                  const DescriptionOfChannelTextFormField(),
                  SizedBox(height: SizeConfig.screenHeight / 30),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  //     Transform.scale(
                  //       scale: 1.2,
                  //       child: Radio(
                  //         fillColor: const WidgetStatePropertyAll(AppColor.primaryColor),
                  //         value: 1,
                  //         groupValue: AppSettings.channelType.value,
                  //         onChanged: (value) => AppSettings.channelType.value = value ?? 0,
                  //       ),
                  //     ),
                  //     Text(
                  //       AppStrings.public.tr,
                  //       style: GoogleFonts.urbanist(fontSize: 18, color: isDarkMode.value ? AppColor.white : AppColor.black, fontWeight: FontWeight.bold),
                  //     ),
                  //     15.width,
                  //     Transform.scale(
                  //       scale: 1.2,
                  //       child: Radio(
                  //         fillColor: const WidgetStatePropertyAll(AppColor.primaryColor),
                  //         value: 2,
                  //         groupValue: AppSettings.channelType.value,
                  //         onChanged: (value) => AppSettings.channelType.value = value ?? 0,
                  //       ),
                  //     ),
                  //     Text(
                  //       AppStrings.private.tr,
                  //       style: GoogleFonts.urbanist(fontSize: 18, color: isDarkMode.value ? AppColor.white : AppColor.black, fontWeight: FontWeight.bold),
                  //     ),
                  //   ],
                  // )
                  // Container(
                  //   height: Get.height / 16,
                  //   width: Get.width / 1.1,
                  //   alignment: Alignment.center,
                  //   padding: EdgeInsets.only(right: SizeConfig.blockSizeHorizontal * 3),
                  //   decoration: BoxDecoration(
                  //     color: isDarkMode.value ? AppColor.secondDarkMode : AppColor.grey_100,
                  //     borderRadius: BorderRadius.circular(10),
                  //   ),
                  //   child: DropdownButtonFormField2(
                  //     value: AppSettings.selectedGender,
                  //     decoration: const InputDecoration(
                  //       isDense: true,
                  //       suffixIconConstraints: BoxConstraints(minWidth: 2, minHeight: 2),
                  //       prefixIconConstraints: BoxConstraints(minWidth: 2, minHeight: 2),
                  //       contentPadding: EdgeInsets.zero,
                  //       border: InputBorder.none,
                  //     ),
                  //     isExpanded: true,
                  //     hint: Text("${AppStrings.gender.tr} *", style: fillYourProfileStyle),
                  //     items: channelTypes
                  //         .map(
                  //           (item) => DropdownMenuItem<String>(
                  //             value: item,
                  //             child: Row(
                  //               children: [
                  //                 Text(
                  //                   item,
                  //                   style: const TextStyle(
                  //                     fontSize: 14,
                  //                   ),
                  //                 ),
                  //               ],
                  //             ),
                  //           ),
                  //         )
                  //         .toList(),
                  //     onChanged: (value) {
                  //       if (value == AppStrings.public.tr) {
                  //         AppSettings.channelType.value = 1;
                  //       } else if (value == AppStrings.private.tr) {
                  //         AppSettings.channelType.value = 2;
                  //       }
                  //       log("Channel Type => ${AppSettings.channelType}");
                  //     },
                  //     onSaved: (value) {
                  //       if (value == AppStrings.public.tr) {
                  //         AppSettings.channelType.value = 1;
                  //       } else if (value == AppStrings.private.tr) {
                  //         AppSettings.channelType.value = 2;
                  //       }
                  //     },
                  //   ),
                  // ),

                  Container(
                    height: Get.height / 16,
                    width: Get.width / 1.1,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      color: isDarkMode.value ? AppColor.secondDarkMode : AppColor.grey_100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: DropdownButtonFormField2(
                      value: AppSettings.channelType.value,
                      decoration: const InputDecoration(
                        isDense: true,
                        suffixIconConstraints: BoxConstraints(minWidth: 2, minHeight: 2),
                        prefixIconConstraints: BoxConstraints(minWidth: 2, minHeight: 2),
                        contentPadding: EdgeInsets.zero,
                        border: InputBorder.none,
                      ),
                      isExpanded: true,
                      hint: Text("${AppStrings.channelType.tr} *", style: fillYourProfileStyle),
                      items: channelTypes
                          .map(
                            (item) => DropdownMenuItem<int>(
                              value: item,
                              child: Text(
                                item == 1 ? AppStrings.public.tr : AppStrings.private.tr,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        AppSettings.channelType.value = value ?? 0;
                        Utils.showLog("Channel Type => ${AppSettings.channelType.value}");
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
