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
import 'package:metube/pages/profile_page/ads_management_page/calculate_budget_api.dart';
import 'package:metube/pages/login_related_page/fill_profile_page/get_profile_api.dart';
import 'package:video_player/video_player.dart';
import 'package:metube/database/database.dart';
import 'package:video_player/video_player.dart';
import 'package:metube/utils/navigation/navigation_observer.dart';

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
  VideoPlayerController? previewVideoController;
  final ImagePicker picker = ImagePicker();

  final List<String> adsTypes = [
    "skippable",
    "non-skippable",
    "banner"
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

  final List<String> placementOptions = ["pre-roll", "mid-roll", "both"];

  String? selectedAdsType;
  String? selectedAdsCategory;
  String? selectedAdsRuns;
  String? selectedPlacement;

  int videoDurationSeconds = 0;
  bool isCalculatingBudget = false;

  // String? selectedCountry;
  cp.Country? selectedCountry;

  List<csc.State> states = [];
  csc.State? selectedState;

  double generatedBudget = 0;
  double availableCoin = 0;
  double purchasedCoin = 0;

  int _budgetRequestId = 0;

  @override
  void initState() {
    super.initState();
    selectedAdsType = adsTypes.first;
    selectedPlacement = placementOptions.first;
    selectedAdsRuns = adsRuns.first;
    _loadUserCoins();
  }

  void _loadUserCoins() {
    availableCoin =
        (GetProfileApi.profileModel?.user?.currentCoin ?? 0).toDouble();
    purchasedCoin =
        (GetProfileApi.profileModel?.user?.totalPurchasedCoin ?? 0).toDouble();
  }

  @override
  void dispose() {
    adsTitleController.dispose();
    adsDescriptionController.dispose();
    adsBudgetController.dispose();
    previewVideoController?.dispose();
    super.dispose();
  }

  Future<void> pickImage() async {
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      await previewVideoController?.dispose();

      setState(() {
        selectedImage = File(image.path);

        // Remove video
        selectedVideo = null;
        previewVideoController = null;
        videoDurationSeconds = 0;

        // Image ads are always banner
        selectedAdsType = "banner";

        // Placement not required for banner image
        selectedPlacement = "pre-roll";
      });
      await calculateBudget();
    }
  }

  Future<void> pickVideo() async {
    final XFile? video = await picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      int durationSec = 0;
      try {
        final controller = VideoPlayerController.file(File(video.path));
        await controller.initialize();
        durationSec = controller.value.duration.inSeconds;
        await controller.dispose();
      } catch (e) {
        AppSettings.showLog('Ad video duration read failed => $e');
      }

      // Restrict ad video length to 30 seconds
      if (durationSec > 30) {
        CustomToast.show(
          'Ad video duration cannot exceed 30 seconds',
        );
        return;
      }
      selectedVideo = File(video.path);

      await previewVideoController?.dispose();

      previewVideoController = VideoPlayerController.file(selectedVideo!);

      await previewVideoController!.initialize();

      setState(() {
        videoDurationSeconds = durationSec;

        // Remove image
        selectedImage = null;

        // Restore defaults if image banner was selected
        if (selectedAdsType == "banner") {
          selectedAdsType = "skippable";
        }
      });
      await calculateBudget();
    }
  }

  Future<int> _readVideoDurationSeconds(File file) async {
    try {
      final controller = VideoPlayerController.file(file);
      await controller.initialize();
      final sec = controller.value.duration.inSeconds;
      await controller.dispose();
      return sec;
    } catch (_) {
      return videoDurationSeconds;
    }
  }

  Future<void> calculateBudget() async {
    if (selectedVideo == null && selectedImage == null) {
      return;
    }

    setState(() => isCalculatingBudget = true);
    final requestId = ++_budgetRequestId;

    try {
      double sizeMB = 0;
      if (selectedImage != null) {
        sizeMB += await selectedImage!.length() / (1024 * 1024);
      }

      if (selectedVideo != null) {
        sizeMB += await selectedVideo!.length() / (1024 * 1024);
      }
      String mediaType = selectedVideo != null ? "video" : "image";

      var durationSec = videoDurationSeconds;
      if (selectedVideo != null && durationSec <= 0) {
        durationSec = await _readVideoDurationSeconds(selectedVideo!);
        videoDurationSeconds = durationSec;
      }

      final result = await CalculateBudgetApi.callApi(
        fileSizeMB: sizeMB,
        durationSeconds: durationSec,
        type: selectedAdsType ?? 'skippable',
        placement: selectedPlacement ?? 'pre-roll',
        mediaType: mediaType,
      );
      if (requestId != _budgetRequestId) {
        return;
      }

      if (!mounted) return;

      if (result.status && result.budget > 0) {
        setState(() {
          generatedBudget = result.budget.toDouble();
          availableCoin = result.currentCoin.toDouble();
          purchasedCoin = result.totalPurchasedCoin.toDouble();
          adsBudgetController.text = result.budget.toString();
        });
        if (result.fromLocalFallback) {
          CustomToast.show(
            'Budget estimated offline. Connect to server for exact pricing.',
          );
        }
      } else {
        CustomToast.show(
          result.message ?? 'Could not calculate ad budget',
        );
      }
    } finally {
      if (mounted) {
        setState(() => isCalculatingBudget = false);
      }
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
              if (!NavigationObserver.isNavigating &&
    (Get.isDialogOpen ?? false || Get.key.currentState?.canPop() == true)) {
  Get.back();
}
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

          if (selectedImage == null && selectedVideo == null) {
            CustomToast.show('Please select an image or video for the ad');
            return;
          }

          if (generatedBudget <= 0) {
            await calculateBudget();
          }

          if (generatedBudget <= 0) {
            CustomToast.show('Please wait for ad budget to be calculated');
            return;
          }

          final budgetCoins = generatedBudget.toInt();
          final walletCoins = availableCoin.toInt();

          if (budgetCoins > walletCoins) {
            CustomToast.show(
              'Insufficient coins. You need $budgetCoins coins but have $walletCoins.',
            );
            return;
          }

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

          final mediaFile = selectedVideo ?? selectedImage!;
          final sizeMB = (await mediaFile.length()) / (1024 * 1024);

          if (selectedVideo != null && videoDurationSeconds > 30) {
            CustomToast.show(
              'Ad video duration cannot exceed 30 seconds',
            );
            return;
          }
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
            placement: selectedPlacement ?? 'pre-roll',
            durationSeconds: videoDurationSeconds,
            fileSizeMB: sizeMB,
            image: selectedImage,
            video: selectedVideo,
          );

          if (Get.isDialogOpen ?? false) {
 if (!NavigationObserver.isNavigating &&
    (Get.isDialogOpen ?? false || Get.key.currentState?.canPop() == true)) {
  Get.back();
}
}

if (isSuccess) {
  await GetProfileApi.callApi(Database.loginUserId ?? '');
  _loadUserCoins();

  CustomToast.show(
    CreateAdsApi.message?.isNotEmpty == true
        ? CreateAdsApi.message!
        : "Ads uploaded successfully",
  );

  await Future.delayed(const Duration(milliseconds: 250));

  if (!NavigationObserver.isNavigating &&
    (Get.isDialogOpen ?? false || Get.key.currentState?.canPop() == true)) {
  Get.back();
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
                  Container(
                    height: SizeConfig.screenHeight / 16,
                    width: SizeConfig.screenWidth / 1.1,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.only(left: 20),
                    decoration: BoxDecoration(
                      color: selectedImage != null
                          ? Colors.grey.shade300
                          : (isDarkMode.value
                              ? AppColor.secondDarkMode
                              : AppColor.grey_100),
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
                      color: selectedImage != null
                          ? Colors.grey.shade300
                          : (isDarkMode.value
                              ? AppColor.secondDarkMode
                              : AppColor.grey_100),
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
                        color: selectedImage != null
                            ? Colors.grey.shade300
                            : (isDarkMode.value
                                ? AppColor.secondDarkMode
                                : AppColor.grey_100),
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
                      color: selectedImage != null
                          ? Colors.grey.shade300
                          : (isDarkMode.value
                              ? AppColor.secondDarkMode
                              : AppColor.grey_100),
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
                      color: selectedImage != null
                          ? Colors.grey.shade300
                          : (isDarkMode.value
                              ? AppColor.secondDarkMode
                              : AppColor.grey_100),
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
                      color: selectedImage != null
                          ? Colors.grey.shade300
                          : (isDarkMode.value
                              ? AppColor.secondDarkMode
                              : AppColor.grey_100),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: DropdownButtonFormField2<String>(
                      value: selectedImage != null ? "banner" : selectedAdsType,
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
                      onChanged: selectedImage != null
                          ? null
                          : (value) async {
                              setState(() {
                                selectedAdsType = value;
                              });

                              await calculateBudget();
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
                      color: selectedImage != null
                          ? Colors.grey.shade300
                          : (isDarkMode.value
                              ? AppColor.secondDarkMode
                              : AppColor.grey_100),
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
                      color: selectedImage != null
                          ? Colors.grey.shade300
                          : (isDarkMode.value
                              ? AppColor.secondDarkMode
                              : AppColor.grey_100),
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
                  Text(
                    'Ad placement',
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
                      color: selectedImage != null
                          ? Colors.grey.shade300
                          : (isDarkMode.value
                              ? AppColor.secondDarkMode
                              : AppColor.grey_100),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: DropdownButtonFormField2<String>(
                      value: selectedPlacement,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                      ),
                      hint: Text('Select placement *',
                          style: fillYourProfileStyle),
                      items: placementOptions.map((p) {
                        return DropdownMenuItem<String>(
                          value: p,
                          child: Text(p),
                        );
                      }).toList(),
                      onChanged: selectedImage != null
                          ? null
                          : (value) async {
                              setState(() {
                                selectedPlacement = value;
                              });
                              await calculateBudget();
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
                      color: selectedImage != null
                          ? Colors.grey.shade300
                          : (isDarkMode.value
                              ? AppColor.secondDarkMode
                              : AppColor.grey_100),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextFormField(
                      controller: adsBudgetController,
                      readOnly: true,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                      decoration: InputDecoration(
                        hintText: generatedBudget > 0
                            ? '${generatedBudget.toInt()} coins'
                            : 'ADS Budget (auto)',
                        hintStyle: fillYourProfileStyle,
                        isDense: true,
                        suffixIcon: isCalculatingBudget
                            ? const Padding(
                                padding: EdgeInsets.all(12),
                                child: SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              )
                            : generatedBudget > 0
                                ? const Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                    size: 20,
                                  )
                                : null,
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
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
                    onTap: selectedVideo != null ? null : pickImage,
                    child: Opacity(
                      opacity: selectedVideo != null ? 0.5 : 1,
                      child: Container(
                        height: 150,
                        decoration: BoxDecoration(
                          color: selectedImage != null
                              ? Colors.grey.shade300
                              : (isDarkMode.value
                                  ? AppColor.secondDarkMode
                                  : AppColor.grey_100),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: selectedImage != null
                            ? Stack(
                                children: [
                                  Positioned.fill(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.file(
                                        selectedImage!,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: GestureDetector(
                                      onTap: () async {
                                        setState(() {
                                          selectedImage = null;

                                          selectedAdsType = "skippable";
                                          selectedPlacement = "pre-roll";
                                        });

                                        if (selectedVideo == null) {
                                          adsBudgetController.clear();
                                          generatedBudget = 0;
                                        } else {
                                          await calculateBudget();
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.delete,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : const Center(
                                child: Text("Tap to upload image"),
                              ),
                      ),
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
                    onTap: selectedImage != null ? null : pickVideo,
                    child: Opacity(
                      opacity: selectedImage != null ? 0.5 : 1,
                      child: Container(
                        height: 150,
                        decoration: BoxDecoration(
                          color: selectedImage != null
                              ? Colors.grey.shade300
                              : (isDarkMode.value
                                  ? AppColor.secondDarkMode
                                  : AppColor.grey_100),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: selectedVideo != null
                            ? Stack(
                                children: [
                                  previewVideoController != null &&
                                          previewVideoController!
                                              .value.isInitialized
                                      ? Positioned.fill(
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: FittedBox(
                                              fit: BoxFit.cover,
                                              child: SizedBox(
                                                width: previewVideoController!
                                                    .value.size.width,
                                                height: previewVideoController!
                                                    .value.size.height,
                                                child: VideoPlayer(
                                                  previewVideoController!,
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                      : const Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: GestureDetector(
                                      onTap: () async {
                                        await previewVideoController?.dispose();

                                        setState(() {
                                          selectedVideo = null;
                                          previewVideoController = null;
                                          videoDurationSeconds = 0;
                                        });

                                        await calculateBudget();
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.delete,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : const Center(
                                child: Text("Tap to upload video"),
                              ),
                      ),
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
