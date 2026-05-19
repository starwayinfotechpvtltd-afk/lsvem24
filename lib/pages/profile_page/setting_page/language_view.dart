import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:metube/localization/localizations_delegate.dart';
import 'package:metube/main.dart';
import 'package:metube/utils/colors/app_color.dart';
import 'package:metube/utils/icons/app_icons.dart';
import 'package:metube/utils/settings/app_settings.dart';
import 'package:metube/utils/string/app_string.dart';

import '../../../utils/prefrens.dart';

class LanguageView extends StatefulWidget {
  const LanguageView({super.key});

  @override
  State<LanguageView> createState() => _LanguageViewState();
}

class _LanguageViewState extends State<LanguageView> {
  @override
  void initState() {
    getLanguageData();
    // TODO: implement initState
    super.initState();
  }

  LanguageModel? languagesChosenValue;
  String? prefLanguageCode;
  String? prefCountryCode;
  getLanguageData() {
    prefLanguageCode = Preference.shared.getString(Preference.selectedLanguage) ?? 'en';
    prefCountryCode = Preference.shared.getString(Preference.selectedCountryCode) ?? 'US';
    languagesChosenValue = languages.where((element) => (element.languageCode == prefLanguageCode && element.countryCode == prefCountryCode)).toList()[0];
    setState(() {});
  }

  onLanguageSave() {
    Preference.shared.setString(Preference.selectedLanguage, languagesChosenValue!.languageCode);
    Preference.shared.setString(Preference.selectedCountryCode, languagesChosenValue!.countryCode);
    Get.updateLocale(Locale(languagesChosenValue!.languageCode, languagesChosenValue!.countryCode));
    Get.back();
  }

  onChangeLanguage(LanguageModel value) {
    languagesChosenValue = value;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: const SystemUiOverlayStyle(statusBarColor: Colors.transparent, statusBarBrightness: Brightness.dark),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(child: Image.asset(AppIcons.arrowBack, color: isDarkMode.value ? AppColor.white : AppColor.black).paddingOnly(left: 15), onTap: () => Get.back()),
        leadingWidth: 33,
        centerTitle: AppSettings.isCenterTitle,
        title: Text(AppStrings.language.tr, style: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
              onPressed: () {
                onLanguageSave();
              },
              icon: const Icon(Icons.done))
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            for (int i = 0; i < languages.length; i++)
              Padding(
                padding: const EdgeInsets.only(left: 10, bottom: 0),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      onChangeLanguage(languages[i]);
                    });
                  },
                  child: Container(
                    color: AppColor.transparent,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        // Container(height: 35, width: 35, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.primaryColor)),
                        // const SizedBox(width: 20),
                        Text(languages[i].language, style: GoogleFonts.urbanist(fontSize: 16, fontWeight: FontWeight.bold)),
                        const Spacer(),
                        Radio(
                            value: languages[i],
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            activeColor: AppColor.primaryColor,
                            groupValue: languagesChosenValue,
                            onChanged: (value) {
                              setState(() {
                                onChangeLanguage(value as LanguageModel);
                              });
                            }),
                      ],
                    ).paddingOnly(bottom: 15, left: 15, right: 15),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
