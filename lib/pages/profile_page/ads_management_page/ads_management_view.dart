import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:metube/custom/custom_method/custom_toast.dart';
import 'package:metube/custom/custom_ui/loader_ui.dart';
import 'package:country_state_city/country_state_city.dart' as csc;
import 'package:metube/main.dart';
import 'package:metube/pages/profile_page/ads_management_page/create_ads_api.dart';
import 'package:metube/utils/colors/app_color.dart';
import 'package:metube/utils/config/size_config.dart';
import 'package:metube/utils/icons/app_icons.dart';
import 'package:metube/utils/settings/app_settings.dart';
import 'package:metube/utils/string/app_string.dart';
import 'package:metube/utils/style/app_style.dart';
import 'package:metube/utils/utils.dart';
import 'package:flutter/services.dart';
import 'package:country_picker/country_picker.dart' as cp;
import 'package:metube/utils/auth/auth_service.dart';

class AdsManagementScreen extends StatefulWidget {
  const AdsManagementScreen({super.key});

  @override
  State<AdsManagementScreen> createState() => _AdsManagementScreenState();
}

class _AdsManagementScreenState extends State<AdsManagementScreen> {
  final TextEditingController adsTitleController = TextEditingController();
  final TextEditingController adsDescriptionController =
      TextEditingController();
  final TextEditingController adsBudgetController = TextEditingController();
  final TextEditingController cityController = TextEditingController();

  File? selectedImage;
  File? selectedVideo;
  final ImagePicker picker = ImagePicker();

  final List<String> adsTypes = [
    "skippable",
    "non-skippable",
    "banner",
    "overlay",
  ];

  final List<String> adsCategories = [
    "Entertainment",
    "Education",
    "Gaming",
    "Lifestyle",
    "Music",
    "News",
    "Sports",
    "Technology",
  ];

  final List<String> adsRuns = ["long videos", "short videos", "both videos"];

  String? selectedAdsType;
  String? selectedAdsCategory;
  String? selectedAdsRuns;

  // String? selectedCountry;
  cp.Country? selectedCountry;

  List<csc.State> states = [];
  csc.State? selectedState;

  @override
  void dispose() {
    adsTitleController.dispose();
    adsDescriptionController.dispose();
    adsBudgetController.dispose();
    super.dispose();
  }

  Future<void> pickImage() async {
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
      });
    }
  }

  Future<void> pickVideo() async {
    final XFile? video = await picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      setState(() {
        selectedVideo = File(video.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
          "Manage Your ADS",
          style: GoogleFonts.urbanist(
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      bottomNavigationBar: GestureDetector(
        onTap: () async {
          if (!AuthService.checkLogin()) return;
          AppSettings.showLog("Create Ads Method Called");
          // if (adsTitleController.text.trim().isEmpty ||
          //     adsDescriptionController.text.trim().isEmpty ||
          //     selectedCountry == null ||
          //     selectedState == null ||
          //     selectedAdsType == null ||
          //     selectedAdsCategory == null ||
          //     selectedAdsRuns == null ||
          //     cityController.text.trim().isEmpty ||
          //     adsBudgetController.text.trim().isEmpty ||
          //     selectedImage == null ||
          //     selectedVideo == null) {
          //   CustomToast.show(AppStrings.pleaseFillUpDetails.tr);
          // } else {
            Get.dialog(
              PopScope(
                canPop: false,
                child: Obx(
                  () => LoaderUi(
                    color: AppColor.white,
                    message: CreateAdsApi.uploadStatusRx.value.isNotEmpty
                        ? CreateAdsApi.uploadStatusRx.value
                        : 'Creating ad...',
                  ),
                ),
              ),
              barrierDismissible: false,
            );

            final isSuccess = await CreateAdsApi.callApi(
              title: adsTitleController.text.trim(),
              description: adsDescriptionController.text.trim(),
              country: selectedCountry?.name,
              state: selectedState?.name,
              type: selectedAdsType,
              category: selectedAdsCategory,
              adRuns: selectedAdsRuns,
              city: cityController.text.trim(),
              budget: adsBudgetController.text.trim(),
              image: selectedImage,
              video: selectedVideo,
            );

            Get.back();

            if (isSuccess) {
              CustomToast.show(CreateAdsApi.message?.isNotEmpty == true
                  ? CreateAdsApi.message.toString()
                  : "Ads uploaded successfully");
              Get.back();
            } else {
              CustomToast.show(CreateAdsApi.message?.isNotEmpty == true
                  ? CreateAdsApi.message.toString()
                  : AppStrings.someThingWentWrong.tr);
            }
          // }
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
                  Container(
                    height: SizeConfig.screenHeight / 16,
                    width: SizeConfig.screenWidth / 1.1,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.only(left: 20),
                    decoration: BoxDecoration(
                      color: isDarkMode.value
                          ? AppColor.secondDarkMode
                          : AppColor.grey_100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextFormField(
                      controller: adsTitleController,
                      inputFormatters: [LengthLimitingTextInputFormatter(20)],
                      decoration: InputDecoration(
                        hintText: "Ads Title",
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
                  ),
                  SizedBox(height: SizeConfig.screenHeight / 30),
                  Container(
                    height: SizeConfig.screenHeight / 6,
                    width: SizeConfig.screenWidth / 1.1,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.only(left: 20),
                    decoration: BoxDecoration(
                      color: isDarkMode.value
                          ? AppColor.secondDarkMode
                          : AppColor.grey_100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextFormField(
                      onEditingComplete: () => FocusScope.of(context).unfocus(),
                      controller: adsDescriptionController,
                      style: const TextStyle(
                        decoration: TextDecoration.none,
                        fontSize: 16,
                      ),
                      maxLines: 7,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.only(top: 10),
                        border: InputBorder.none,
                        hintText: "Ads description...",
                        hintStyle: fillYourProfileStyle,
                      ),
                    ),
                  ),
                  SizedBox(height: SizeConfig.screenHeight / 30),
                  GestureDetector(
                    onTap: () {
                      cp.showCountryPicker(
                        context: context,
                        showPhoneCode: false,
                        onSelect: (cp.Country country) async {
                          setState(() {
                            selectedCountry = country;
                            selectedState = null;
                            states = [];
                          });

                          try {
                            List<csc.State> fetchedStates = await csc
                                .getStatesOfCountry(country.countryCode);

                            setState(() {
                              states = fetchedStates;
                            });

                            Utils.showLog("States loaded: ${states.length}");
                          } catch (e) {
                            Utils.showLog("Error loading states: $e");
                          }
                        },
                      );
                    },
                    child: Container(
                      height: Get.height / 16,
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      decoration: BoxDecoration(
                        color: isDarkMode.value
                            ? AppColor.secondDarkMode
                            : AppColor.grey_100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: selectedCountry != null
                          ? Row(
                              key: ValueKey(selectedCountry!.countryCode),
                              children: [
                                Text(selectedCountry!.flagEmoji,
                                    style: const TextStyle(fontSize: 20)),
                                const SizedBox(width: 10),
                                Text(selectedCountry!.name),
                              ],
                            )
                          : Text("Select Country *",
                              style: fillYourProfileStyle),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    height: Get.height / 16,
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      color: isDarkMode.value
                          ? AppColor.secondDarkMode
                          : AppColor.grey_100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: DropdownButtonFormField2<csc.State>(
                      value: selectedState,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      hint: Text("Select State *", style: fillYourProfileStyle),
                      items: states.map((state) {
                        return DropdownMenuItem<csc.State>(
                          value: state,
                          child: Text(state.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedState = value;
                        });
                        Utils.showLog("State => ${value?.name}");
                      },
                    ),
                  ),
                  SizedBox(height: SizeConfig.screenHeight / 30),
                  Container(
                    height: SizeConfig.screenHeight / 16,
                    width: SizeConfig.screenWidth / 1.1,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.only(left: 20),
                    decoration: BoxDecoration(
                      color: isDarkMode.value
                          ? AppColor.secondDarkMode
                          : AppColor.grey_100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextFormField(
                      controller: cityController,
                      decoration: InputDecoration(
                        hintText: "City",
                        hintStyle: fillYourProfileStyle,
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  SizedBox(height: SizeConfig.screenHeight / 30),
                  Text(
                    "Select Your ADS Type",
                    style: GoogleFonts.urbanist(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
                    child: DropdownButtonFormField2<String>(
                      value: selectedAdsType,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                      ),
                      hint: Text("Select Ads Type *",
                          style: fillYourProfileStyle),
                      items: adsTypes.map((type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedAdsType = value;
                        });
                      },
                    ),
                  ),
                  SizedBox(height: SizeConfig.screenHeight / 30),
                  Text(
                    "Select Your ADS Category",
                    style: GoogleFonts.urbanist(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
                    child: DropdownButtonFormField2<String>(
                      value: selectedAdsCategory,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                      ),
                      hint: Text("Select Ads Category *",
                          style: fillYourProfileStyle),
                      items: adsCategories.map((category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedAdsCategory = value;
                        });
                      },
                    ),
                  ),
                  SizedBox(height: SizeConfig.screenHeight / 30),
                  Text(
                    "Ads runs In",
                    style: GoogleFonts.urbanist(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
                    child: DropdownButtonFormField2<String>(
                      value: selectedAdsRuns,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                      ),
                      hint: Text("Select Ads Runs *",
                          style: fillYourProfileStyle),
                      items: adsRuns.map((category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedAdsRuns = value;
                        });
                      },
                    ),
                  ),
                  SizedBox(height: SizeConfig.screenHeight / 30),
                  Container(
                    height: SizeConfig.screenHeight / 16,
                    width: SizeConfig.screenWidth / 1.1,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.only(left: 20),
                    decoration: BoxDecoration(
                      color: isDarkMode.value
                          ? AppColor.secondDarkMode
                          : AppColor.grey_100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextFormField(
                      controller: adsBudgetController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                      decoration: InputDecoration(
                        hintText: "ADS Budget",
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
                  ),
                  SizedBox(height: SizeConfig.screenHeight / 30),
                  Text(
                    "Upload Image",
                    style: GoogleFonts.urbanist(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: pickImage,
                    child: Container(
                      height: 150,
                      decoration: BoxDecoration(
                        color: isDarkMode.value
                            ? AppColor.secondDarkMode
                            : AppColor.grey_100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: selectedImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child:
                                  Image.file(selectedImage!, fit: BoxFit.cover),
                            )
                          : const Center(child: Text("Tap to upload image")),
                    ),
                  ),
                  SizedBox(height: SizeConfig.screenHeight / 30),
                  Text(
                    "Upload Video",
                    style: GoogleFonts.urbanist(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: pickVideo,
                    child: Container(
                      height: 150,
                      decoration: BoxDecoration(
                        color: isDarkMode.value
                            ? AppColor.secondDarkMode
                            : AppColor.grey_100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: selectedVideo != null
                          ? const Center(
                              child: Icon(Icons.video_file, size: 50))
                          : const Center(child: Text("Tap to upload video")),
                    ),
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
    return Obx(() => Container(
          // ✅ KEY FIX — Obx makes it reactive
          height: SizeConfig.screenHeight / 16,
          width: SizeConfig.screenWidth / 1.1,
          alignment: Alignment.center,
          padding: const EdgeInsets.only(left: 12),
          decoration: BoxDecoration(
            color:
                isDarkMode.value ? AppColor.secondDarkMode : AppColor.grey_100,
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
                    ? AppColor.white.withValues(alpha: 0.4)
                    : AppColor.grey,
                fontWeight: FontWeight.w400,
                fontSize: 15,
              ),
            ),
          ),
        ));
  }
}
