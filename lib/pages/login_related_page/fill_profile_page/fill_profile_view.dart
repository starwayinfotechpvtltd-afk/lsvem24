// ignore_for_file: avoid_print

import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart' as dio;
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field2/intl_phone_field.dart';
import 'package:metube/custom/basic_button.dart';
import 'package:metube/custom/custom_method/custom_dialog.dart';
import 'package:metube/custom/custom_method/custom_filled_button.dart';
import 'package:metube/custom/custom_method/custom_image_picker.dart';
import 'package:metube/custom/custom_method/custom_toast.dart';
import 'package:metube/custom/custom_ui/loader_ui.dart';
import 'package:metube/database/database.dart';
import 'package:metube/main.dart';
import 'package:metube/pages/admin_settings/admin_settings_api.dart';
import 'package:metube/pages/custom_pages/file_upload_page/convert_channel_image_api.dart';
import 'package:metube/pages/login_related_page/fill_profile_page/edit_profile_api.dart';
import 'package:metube/pages/login_related_page/fill_profile_page/get_profile_api.dart';
import 'package:metube/pages/main_home_page/main_home_view.dart';
import 'package:metube/utils/colors/app_color.dart';
import 'package:metube/utils/config/size_config.dart';
import 'package:metube/utils/icons/app_icons.dart';
import 'package:metube/utils/settings/app_settings.dart';
import 'package:metube/utils/string/app_string.dart';
import 'package:metube/utils/style/app_style.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class FillProfileView extends StatelessWidget {
  const FillProfileView({
    super.key,
    required this.email,
    required this.loginUserId,
    this.username,
    this.profileImage,
  });

  final String email;
  final String loginUserId;
  final String? username;
  final String? profileImage;

  @override
  Widget build(BuildContext context) {
    List genderItems = ['male'.tr, 'female'.tr];
    AppSettings.nameController.text = username ?? "";

    // Set initial profile image if provided
    if (profileImage != null && profileImage!.isNotEmpty) {
      AppSettings.pickImagePath.value = profileImage!;
    }

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.dark,
      ),
    );

    AppSettings.showLog("Username: $username");
    AppSettings.showLog("Profile Image: $profileImage");

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        leadingWidth: 60,
        title: Text(
          AppStrings.fillProfile.tr,
          style: GoogleFonts.urbanist(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: Column(
            children: [
              SizedBox(height: SizeConfig.screenHeight / 40),

              // Profile Image Picker
              GestureDetector(
                onTap: chooseImageBottomSheet,
                child: Stack(
                  children: [
                    Obx(() {
                      final imagePath = AppSettings.pickImagePath.value;
                      final bool isNetwork = imagePath.startsWith('http://') ||
                          imagePath.startsWith('https://');
                      final bool hasImage = imagePath.isNotEmpty;

                      return Container(
                        height: 125,
                        width: 125,
                        decoration: BoxDecoration(
                          color: isDarkMode.value
                              ? AppColor.secondDarkMode
                              : AppColor.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColor.grey_300),
                          image: hasImage
                              ? isNetwork
                                  ? DecorationImage(
                                      image: NetworkImage(imagePath),
                                      fit: BoxFit.cover,
                                    )
                                  : DecorationImage(
                                      image: FileImage(File(imagePath)),
                                      fit: BoxFit.cover,
                                    )
                              : const DecorationImage(
                                  image: AssetImage(AppIcons.profileImage),
                                ),
                        ),
                      );
                    }),
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
                        child: const Center(
                          child: Image(
                            image: AssetImage(AppIcons.editButton),
                            height: 16,
                            width: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: SizeConfig.screenHeight / 40),
              ProfileTextFieldView(
                hintText: "${AppStrings.fullName.tr} *",
                controller: AppSettings.nameController,
                inputFormatter: [LengthLimitingTextInputFormatter(50)],
              ),
              SizedBox(height: SizeConfig.screenHeight / 40),
              ProfileTextFieldView(
                hintText: "${AppStrings.nickName.tr} *",
                controller: AppSettings.nickNameController,
                inputFormatter: [LengthLimitingTextInputFormatter(20)],
              ),
              SizedBox(height: SizeConfig.screenHeight / 40),
              ProfileTextFieldView(
                hintText: AppStrings.email.tr,
                controller: TextEditingController(text: email),
                isReadOnly: true,
              ),
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

              // Gender Dropdown
              Container(
                height: Get.height / 16,
                width: Get.width / 1.1,
                alignment: Alignment.center,
                padding:
                    EdgeInsets.only(right: SizeConfig.blockSizeHorizontal * 3),
                decoration: BoxDecoration(
                  color: isDarkMode.value
                      ? AppColor.secondDarkMode
                      : AppColor.grey_100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButtonFormField2(
                  value: AppSettings.selectedGender,
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
                  hint: Text(AppStrings.gender.tr, style: fillYourProfileStyle),
                  items: genderItems
                      .map(
                        (item) => DropdownMenuItem<String>(
                          value: item,
                          child: Row(
                            children: [
                              Icon(item == "male".tr
                                  ? Icons.male
                                  : Icons.female),
                              const SizedBox(width: 8),
                              Text(item, style: const TextStyle(fontSize: 14)),
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
                    log("Selected Gender: ${AppSettings.selectedGender}");
                  },
                  onSaved: (value) {
                    AppSettings.selectedGender = value.toString();
                  },
                ),
              ),

              SizedBox(height: SizeConfig.screenHeight / 40),
              const CountryTextFormField(),
              SizedBox(height: SizeConfig.screenHeight / 20),

              // Submit Button
              CustomFilledButton(
                title: AppStrings.continueString.tr,
                callback: () async {
                  print("🔴 Continue button clicked");

                  // ✅ Validate required fields
                  if (AppSettings.pickImagePath.isEmpty) {
                    CustomToast.show("Please select profile image!");
                    return;
                  }

                  if (AppSettings.nameController.text.trim().isEmpty) {
                    CustomToast.show("Please enter full name!");
                    return;
                  }

                  if (AppSettings.nickNameController.text.trim().isEmpty) {
                    CustomToast.show(AppStrings.pleaseEnterNickName.tr);
                    return;
                  }

                  try {
                    // Show loading
                    Get.dialog(
                      const LoaderUi(color: AppColor.white),
                      barrierDismissible: false,
                    );

                    print("✅ Validation passed");
                    print("📤 Processing profile data...");

                    // Convert URL to file if needed
                    String imagePath = AppSettings.pickImagePath.value;
                    if (imagePath.startsWith('https://') ||
                        imagePath.startsWith('http://')) {
                      print("🔄 Converting URL to file...");
                      imagePath = await urlToFile(imagePath);
                      print("✅ Image converted: $imagePath");
                    }

                    // Upload image
                    print("📤 Uploading image...");
                    final url = await ConvertChannelImageApi.callApi(imagePath);
                    print("✅ Image uploaded: $url");

                    if (url == null || url.isEmpty) {
                      Get.back();
                      CustomToast.show(
                          "Failed to upload image. Please try again.");
                      return;
                    }

                    // Update profile
                    print("📤 Updating profile...");
                    final isSuccess = await EditProfileApi.callApi(
                      loginUserId: loginUserId,
                      profileImage: url,
                      gender: AppSettings.selectedGender,
                    );

                    print("📥 Profile update result: $isSuccess");

                    // Close loading
                    Get.back();

                    if (!isSuccess) {
                      CustomToast.show(
                          "Failed to update profile. Please try again.");
                      return;
                    }

                    // ✅ Show success dialog with manual close
                    await Get.dialog(
                      WillPopScope(
                        onWillPop: () async => false,
                        child: Dialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(
                                  AppIcons.profileDoneLogo1,
                                  height: 120,
                                  width: 120,
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  AppStrings.congratulations.tr,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  AppStrings.congratulationsNote.tr,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const SizedBox(height: 30),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColor.primaryColor,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 15),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    onPressed: () {
                                      Get.back(); // Close dialog
                                    },
                                    child: const Text(
                                      "Continue",
                                      style: TextStyle(
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

                    // ✅ Get profile after dialog is dismissed
                    Get.offAll(() => const MainHomePageView());

// Fetch profile in background
                    Future.microtask(() async {
                      try {
                        await GetProfileApi.callApi(loginUserId);
                      } catch (e) {
                        print("Background profile fetch failed: $e");
                      }
                    });
                  } catch (e, stackTrace) {
                    // Close any open dialogs
                    if (Get.isDialogOpen ?? false) {
                      Get.back();
                    }

                    print("❌ Error in profile submission: $e");
                    print("Stack trace: $stackTrace");
                    CustomToast.show("An error occurred. Please try again.");
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

// Helper function to convert URL to File
Future<String> urlToFile(String imageUrl) async {
  try {
    final response = await http.get(Uri.parse(imageUrl));

    if (response.statusCode == 200) {
      final tempDir = await getTemporaryDirectory();
      final fileName = basename(imageUrl).split('?')[0]; // Remove query params
      final filePath = '${tempDir.path}/$fileName';

      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      return file.path;
    } else {
      throw Exception("Failed to download image: ${response.statusCode}");
    }
  } catch (e) {
    print("❌ Error converting URL to file: $e");
    throw Exception("Failed to download image from $imageUrl");
  }
}

// Bottom sheet for image picker
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
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(60),
              color: AppColor.grey_300,
            ),
          ),
          const SizedBox(height: 10),
          Text(AppStrings.chooseImage.tr, style: titalstyle1),
          const SizedBox(height: 5),
          Divider(
            indent: 25,
            endIndent: 25,
            color: AppColor.grey_300.withOpacity(0.8),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GestureDetector(
              onTap: () => CustomImagePicker.pickImage(ImageSource.camera),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Image.asset(
                    AppIcons.camera,
                    color: isDarkMode.value
                        ? AppColor.white.withOpacity(0.5)
                        : AppColor.black,
                    height: 30,
                    width: 30,
                  ),
                  const SizedBox(width: 15),
                  Text("Take a photo", style: bottomstyle),
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
                  Image.asset(
                    AppIcons.gallery,
                    color: isDarkMode.value
                        ? AppColor.white.withOpacity(0.5)
                        : AppColor.black,
                    height: 25,
                    width: 25,
                  ).paddingOnly(left: 3),
                  const SizedBox(width: 15),
                  Text("Choose from your file", style: bottomstyle),
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

// Profile Text Field Widget
class ProfileTextFieldView extends StatefulWidget {
  const ProfileTextFieldView({
    super.key,
    required this.hintText,
    required this.controller,
    this.keyboardType,
    this.isReadOnly,
    this.inputFormatter,
  });

  final String hintText;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final bool? isReadOnly;
  final List<TextInputFormatter>? inputFormatter;

  @override
  State<ProfileTextFieldView> createState() => _ProfileTextFieldViewState();
}

class _ProfileTextFieldViewState extends State<ProfileTextFieldView> {
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
        style: GoogleFonts.urbanist(
          textStyle: const TextStyle(
            color: AppColor.black,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        cursorColor: isDarkMode.value ? AppColor.white : AppColor.black,
        controller: widget.controller,
        keyboardType: widget.keyboardType,
        readOnly: widget.isReadOnly ?? false,
        inputFormatters: widget.inputFormatter,
        decoration: InputDecoration(
          isDense: true,
          hintText: widget.hintText,
          border: InputBorder.none,
          hintStyle: GoogleFonts.urbanist(
            textStyle: const TextStyle(
              color: AppColor.grey,
              fontWeight: FontWeight.w400,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }
}

// Phone Number Field Widget
class PhoneNumberTextFormField extends StatelessWidget {
  const PhoneNumberTextFormField({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = isDarkMode.value ?? false;
    return SizedBox(
      height: SizeConfig.screenHeight / 11,
      width: SizeConfig.screenWidth / 1.1,
      child: IntlPhoneField(
        flagsButtonPadding: const EdgeInsets.all(8),
        dropdownIconPosition: IconPosition.trailing,
        controller: AppSettings.phoneController,
        obscureText: false,
        cursorColor: isDark ? AppColor.white : AppColor.black,
        dropdownTextStyle: TextStyle(
          color: isDark ? AppColor.white : AppColor.black,
          fontSize: 15,
        ),
        keyboardType: TextInputType.number,
        showCountryFlag: true,
        style: GoogleFonts.urbanist(
          textStyle: const TextStyle(
            color: AppColor.black,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onTap: () {},
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
          filled: true,
          fillColor: isDark ? AppColor.secondDarkMode : AppColor.grey_100,
          hintStyle: GoogleFonts.urbanist(
            textStyle: const TextStyle(
              color: AppColor.grey,
              fontWeight: FontWeight.w400,
              fontSize: 15,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: AppColor.transparent),
            borderRadius: BorderRadius.circular(8),
          ),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: AppColor.transparent),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        initialCountryCode: 'IN',
      ),
    );
  }
}
