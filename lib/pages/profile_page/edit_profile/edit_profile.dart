// ignore_for_file: avoid_print

import 'dart:developer';
import 'dart:io';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field2/intl_phone_field.dart';
// import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:metube/custom/basic_button.dart';
import 'package:metube/custom/custom_method/custom_filled_button.dart';
import 'package:metube/custom/custom_method/custom_image_picker.dart';
import 'package:metube/custom/custom_method/custom_toast.dart';
import 'package:metube/custom/custom_ui/loader_ui.dart';
import 'package:metube/database/database.dart';
import 'package:metube/main.dart';
import 'package:metube/pages/custom_pages/file_upload_page/convert_channel_image_api.dart';
import 'package:metube/pages/login_related_page/fill_profile_page/edit_profile_api.dart';
import 'package:metube/pages/login_related_page/fill_profile_page/get_profile_api.dart';
import 'package:metube/pages/nav_shorts_page/nav_shorts_details_view.dart';
import 'package:metube/utils/colors/app_color.dart';
import 'package:metube/utils/config/size_config.dart';
import 'package:metube/utils/icons/app_icons.dart';
import 'package:metube/utils/settings/app_settings.dart';
import 'package:metube/utils/string/app_string.dart';
import 'package:metube/utils/style/app_style.dart';
import 'package:metube/utils/utils.dart';
import 'package:metube/utils/auth/auth_service.dart';

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  List channelTypes = [1, 2];
  @override
  void initState() {
    AppSettings.pickImagePath.value = "";

    print("AppSettings.nameController${AppSettings.nameController}");

    AppSettings.nameController = TextEditingController(text: GetProfileApi.profileModel?.user?.fullName ?? "");
    AppSettings.nickNameController = TextEditingController(text: GetProfileApi.profileModel?.user?.nickName ?? "");
    AppSettings.phoneController = TextEditingController(text: GetProfileApi.profileModel?.user?.mobileNumber ?? "");
    AppSettings.ageController = TextEditingController(text: GetProfileApi.profileModel?.user?.age.toString() ?? "");
    AppSettings.selectedGender = GetProfileApi.profileModel?.user?.gender ?? 'male'.tr;
    AppSettings.instagramController = TextEditingController(text: GetProfileApi.profileModel?.user?.socialMediaLinks?.instagramLink ?? "");
    AppSettings.facebookController = TextEditingController(text: GetProfileApi.profileModel?.user?.socialMediaLinks?.facebookLink ?? "");
    AppSettings.twitterController = TextEditingController(text: GetProfileApi.profileModel?.user?.socialMediaLinks?.twitterLink ?? "");
    AppSettings.websiteController = TextEditingController(text: GetProfileApi.profileModel?.user?.socialMediaLinks?.websiteLink ?? "");
    AppSettings.countryController = TextEditingController(text: GetProfileApi.profileModel?.user?.country ?? "");

    AppSettings.channelType.value = GetProfileApi.profileModel?.user?.channelType ?? 1;
    super.initState();
  }

  List genderItems = ['male'.tr, 'female'.tr];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: AppSettings.isCenterTitle,
        leadingWidth: 60,
        leading: IconButtonUi(
          callback: () => Get.back(),
          icon: Obx(
            () => Image.asset(AppIcons.arrowBack, height: 20, width: 20, color: isDarkMode.value ? AppColor.white : AppColor.black),
          ),
        ),
        title: Text("Edit Profile", style: profileTitleStyle),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: Column(
            children: [
              SizedBox(height: SizeConfig.screenHeight / 40),
              GestureDetector(
                onTap: chooseImageBottomSheet,
                child: Stack(
                  children: [
                    Obx(
                      () => Container(
                        height: 125,
                        width: 125,
                        decoration: BoxDecoration(
                          color: isDarkMode.value ? AppColor.secondDarkMode : AppColor.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColor.grey_300),
                          image: AppSettings.pickImagePath.isEmpty
                              ? AppSettings.profileImage.isNotEmpty
                                  ? DecorationImage(image: NetworkImage(AppSettings.profileImage.value), fit: BoxFit.cover)
                                  : const DecorationImage(image: AssetImage(AppIcons.profileImage), fit: BoxFit.cover)
                              : DecorationImage(image: FileImage(File(AppSettings.pickImagePath.value)), fit: BoxFit.cover),
                        ),
                      ),
                    ),
                    Positioned(
                        bottom: 6,
                        right: 6,
                        child: Container(
                            height: 28,
                            width: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColor.white,
                              boxShadow: [
                                BoxShadow(color: AppColor.grey_200, blurRadius: 1),
                              ],
                            ),
                            child: const Center(child: Image(image: AssetImage(AppIcons.editButton), height: 16, width: 16)))),
                  ],
                ),
              ),
              SizedBox(height: SizeConfig.screenHeight / 40),
              ProfileTextFieldView(hintText: "${AppStrings.fullName.tr} *", controller: AppSettings.nameController, inputFormatter: [LengthLimitingTextInputFormatter(50)]),
              SizedBox(height: SizeConfig.screenHeight / 40),
              ProfileTextFieldView(hintText: "${AppStrings.nickName.tr} *", controller: AppSettings.nickNameController, inputFormatter: [LengthLimitingTextInputFormatter(20)]),
              SizedBox(height: SizeConfig.screenHeight / 40),
              ProfileTextFieldView(hintText: "${AppStrings.email.tr} *", controller: TextEditingController(text: GetProfileApi.profileModel?.user?.email ?? ""), isReadOnly: true),
              SizedBox(height: SizeConfig.screenHeight / 40),
              const PhoneNumberTextFormField(),
              SizedBox(height: SizeConfig.screenHeight / 40),
              ProfileTextFieldView(
                hintText: AppStrings.age.tr,
                controller: AppSettings.ageController,
                keyboardType: TextInputType.number,
                inputFormatter: [LengthLimitingTextInputFormatter(3)],
              ),
              SizedBox(height: SizeConfig.screenHeight / 40),
              Container(
                height: Get.height / 16,
                width: Get.width / 1.1,
                alignment: Alignment.center,
                padding: EdgeInsets.only(right: SizeConfig.blockSizeHorizontal * 3),
                decoration: BoxDecoration(
                  color: isDarkMode.value ? AppColor.secondDarkMode : AppColor.grey_100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButtonFormField2(
                  value: AppSettings.selectedGender,
                  decoration: const InputDecoration(
                    isDense: true,
                    suffixIconConstraints: BoxConstraints(minWidth: 2, minHeight: 2),
                    prefixIconConstraints: BoxConstraints(minWidth: 2, minHeight: 2),
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                  ),
                  isExpanded: true,
                  hint: Text("${AppStrings.gender.tr} *", style: fillYourProfileStyle),
                  items: genderItems
                      .map(
                        (item) => DropdownMenuItem<String>(
                          value: item,
                          child: Row(
                            children: [
                              Icon(item == "male".tr ? Icons.male : Icons.female),
                              const SizedBox(width: 8),
                              Text(
                                item,
                                style: const TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                  validator: (value) {
                    if (value == null) {
                      return 'Please select gender.';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    AppSettings.selectedGender = value.toString();
                    log("selectedValue $AppSettings.selectedGender");
                  },
                  onSaved: (value) {
                    AppSettings.selectedGender = value.toString();
                  },
                ),
              ),
              SizedBox(height: SizeConfig.screenHeight / 40),
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
              ProfileTextFieldView(hintText: AppStrings.instagram.tr, controller: AppSettings.instagramController, inputFormatter: [LengthLimitingTextInputFormatter(50)]),
              SizedBox(height: SizeConfig.screenHeight / 40),
              ProfileTextFieldView(hintText: AppStrings.facebook.tr, controller: AppSettings.facebookController, inputFormatter: [LengthLimitingTextInputFormatter(50)]),
              SizedBox(height: SizeConfig.screenHeight / 40),
              ProfileTextFieldView(hintText: AppStrings.twitter.tr, controller: AppSettings.twitterController, inputFormatter: [LengthLimitingTextInputFormatter(50)]),
              SizedBox(height: SizeConfig.screenHeight / 40),
              ProfileTextFieldView(hintText: AppStrings.website.tr, controller: AppSettings.websiteController, inputFormatter: [LengthLimitingTextInputFormatter(50)]),
              SizedBox(height: SizeConfig.screenHeight / 40),
              const CountryTextFormField(),
              SizedBox(height: SizeConfig.screenHeight / 20),
              CustomFilledButton(
                title: AppStrings.save.tr,
                callback: () async {
                  if (!AuthService.checkLogin()) return;
                  if ((GetProfileApi.profileModel?.user?.image != null || AppSettings.pickImagePath.isNotEmpty) &&
                          AppSettings.nameController.text.trim().isNotEmpty &&
                          AppSettings.nickNameController.text.trim().isNotEmpty
                      // AppSettings.phoneController.text.trim().isNotEmpty &&
                      // AppSettings.ageController.text.isNotEmpty &&
                      // AppSettings.selectedGender != null &&
                      // AppSettings.countryController.text.isNotEmpty
                      ) {
                    AppSettings.showLog("Fill Profile Complete");

                    if (AppSettings.pickImagePath.value == "" &&
                        AppSettings.nameController.text == (GetProfileApi.profileModel?.user?.fullName ?? "") &&
                        AppSettings.nickNameController.text == (GetProfileApi.profileModel?.user?.nickName ?? "") &&
                        AppSettings.phoneController.text == (GetProfileApi.profileModel?.user?.mobileNumber ?? "") &&
                        AppSettings.ageController.text == (GetProfileApi.profileModel?.user?.age.toString() ?? "") &&
                        AppSettings.selectedGender == GetProfileApi.profileModel?.user?.gender &&
                        AppSettings.instagramController.text == (GetProfileApi.profileModel?.user?.socialMediaLinks?.instagramLink ?? "") &&
                        AppSettings.facebookController.text == (GetProfileApi.profileModel?.user?.socialMediaLinks?.facebookLink ?? "") &&
                        AppSettings.twitterController.text == (GetProfileApi.profileModel?.user?.socialMediaLinks?.twitterLink ?? "") &&
                        AppSettings.websiteController.text == (GetProfileApi.profileModel?.user?.socialMediaLinks?.websiteLink ?? "") &&
                        AppSettings.countryController.text == (GetProfileApi.profileModel?.user?.country ?? "") &&
                        AppSettings.channelType.value == (GetProfileApi.profileModel?.user?.channelType ?? 1)) {
                      Get.back();
                      AppSettings.showLog("Direct Back");
                    } else {
                      Get.dialog(const LoaderUi(color: AppColor.white), barrierDismissible: false);
                      if (AppSettings.pickImagePath.isNotEmpty) {
                        final url = await ConvertChannelImageApi.callApi(AppSettings.pickImagePath.value);
                        final isSuccess = await EditProfileApi.callApi(loginUserId: Database.loginUserId!, profileImage: url ?? "", gender: AppSettings.selectedGender);
                        if (isSuccess) {
                          Get.close(2);
                          await GetProfileApi.callApi(Database.loginUserId!);
                        } else {
                          Get.back();
                        }
                      } else {
                        final isSuccess = await EditProfileApi.callApi(loginUserId: Database.loginUserId!, profileImage: null, gender: AppSettings.selectedGender);
                        if (isSuccess) {
                          Get.close(2);
                          await GetProfileApi.callApi(Database.loginUserId!);
                        } else {
                          Get.back();
                        }
                      }
                    }
                  } else {
                    CustomToast.show(AppStrings.pleaseFillUpDetails.tr);
                    AppSettings.showLog("Please Fill Up Details...");
                  }
                },
              ),
              SizedBox(height: Get.height * 0.015),
            ],
          ),
        ),
      ),
    );
  }
}

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

class ProfileTextFieldView extends StatelessWidget {
  const ProfileTextFieldView({super.key, required this.hintText, required this.controller, this.keyboardType, this.isReadOnly, this.inputFormatter});

  final String hintText;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final bool? isReadOnly;
  final List<TextInputFormatter>? inputFormatter;

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
        cursorColor: isDarkMode.value ? AppColor.white : AppColor.black,
        style: GoogleFonts.urbanist(textStyle: const TextStyle(color: AppColor.black, fontWeight: FontWeight.w600, fontSize: 16)),
        controller: controller,
        keyboardType: keyboardType,
        readOnly: isReadOnly ?? false,
        inputFormatters: inputFormatter,
        decoration: InputDecoration(
          isDense: true,
          hintText: hintText,
          border: InputBorder.none,
          hintStyle: GoogleFonts.urbanist(textStyle: const TextStyle(color: AppColor.grey, fontWeight: FontWeight.w400, fontSize: 15)),
          // hintStyle: GoogleFonts.urbanist(textStyle: const TextStyle(color: AppColors.grey, fontSize: 15)),
        ),
      ),
    );
  }
}

class PhoneNumberTextFormField extends StatelessWidget {
  const PhoneNumberTextFormField({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: SizeConfig.screenHeight / 13,
      width: SizeConfig.screenWidth / 1.1,
      child: IntlPhoneField(
        flagsButtonPadding: const EdgeInsets.all(8),
        dropdownIconPosition: IconPosition.trailing,
        controller: AppSettings.phoneController,
        obscureText: false,
        cursorColor: isDarkMode.value ? AppColor.white : AppColor.black,
        dropdownTextStyle: TextStyle(color: isDarkMode.value ? AppColor.white : AppColor.black, fontSize: 15),
        keyboardType: TextInputType.number,
        showCountryFlag: true,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: GoogleFonts.urbanist(textStyle: const TextStyle(color: AppColor.black, fontWeight: FontWeight.w600, fontSize: 16)),
        decoration: InputDecoration(
          hintText: "Phone*",
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
          filled: true,
          fillColor: isDarkMode.value ? AppColor.secondDarkMode : AppColor.grey_100,
          hintStyle: GoogleFonts.urbanist(textStyle: const TextStyle(color: AppColor.grey, fontSize: 14)),
          focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: AppColor.transparent), borderRadius: BorderRadius.circular(8)),
          border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
          enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: AppColor.transparent), borderRadius: BorderRadius.circular(8)),
        ),
        initialCountryCode: 'IN',
      ),
    );
  }
}
