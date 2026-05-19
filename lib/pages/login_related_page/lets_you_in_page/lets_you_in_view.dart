import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart'; // ✅ Added
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_typedefs/rx_typedefs.dart';
import 'package:metube/custom/basic_button.dart';
import 'package:metube/custom/custom_method/custom_dialog.dart';
import 'package:metube/custom/custom_method/custom_toast.dart';
import 'package:metube/custom/custom_ui/loader_ui.dart';
import 'package:metube/database/database.dart';
import 'package:metube/main.dart';
import 'package:metube/pages/admin_settings/admin_settings_api.dart';
import 'package:metube/pages/login_related_page/fill_profile_page/fill_profile_view.dart';
import 'package:metube/pages/login_related_page/fill_profile_page/get_profile_api.dart';
import 'package:metube/pages/login_related_page/google_login_page/google_login.dart';
import 'package:metube/pages/login_related_page/sign_up_page/sign_up_api.dart';
import 'package:metube/pages/login_related_page/sign_up_page/sign_up_model.dart';
import 'package:metube/pages/main_home_page/main_home_view.dart';
import 'package:metube/utils/colors/app_color.dart';
import 'package:metube/utils/icons/app_icons.dart';
import 'package:metube/utils/settings/app_settings.dart';
import 'package:metube/utils/string/app_string.dart';
import 'package:metube/utils/style/app_style.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class LetsYouInView extends StatefulWidget {
  const LetsYouInView({super.key});

  @override
  State<LetsYouInView> createState() => _LetsYouInViewState();
}

class _LetsYouInViewState extends State<LetsYouInView> {
  SignUpModel? _signUpModel;

  // ✅ Safe platform checks - never call Platform.isX on web
  bool get _isIOS => !kIsWeb && Platform.isIOS;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.offAll(() => const MainHomePageView());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  alignment: Alignment.center,
                  height: Get.height / 4.5,
                  decoration: const BoxDecoration(),
                  child: const Image(image: AssetImage(AppIcons.loginLogo)),
                ),
                SizedBox(height: Get.height / 35),
                Text(AppStrings.letsYouIn.tr,
                    textAlign: TextAlign.center, style: letsInStyle),
                SizedBox(height: Get.height / 35),

                // ─── Google Login ───────────────────────────────────────
                ButtonItemUi(
                  title: AppStrings.googleLogin.tr,
                  icon: Image.asset(AppIcons.googleLogo, width: 25),
                  callback: () async {
                    Get.dialog(const LoaderUi(color: AppColor.white),
                        barrierDismissible: false);

                    dynamic response;
                    try {
                      response = await GoogleLogin.signInWithGoogle();
                    } catch (e) {
                      AppSettings.showLog("GOOGLE ERROOR $e");
                    }

                    if (response != null && response.user?.email != null) {
                      _signUpModel = await SignUpApi.callApi(
                          response.user!.email!,
                          null,
                          2,
                          Database.fcmToken!,
                          Database.deviceId!);

                      if (_signUpModel != null &&
                          _signUpModel?.user?.id != null) {
                        AppSettings.onLoginWithReferral(
                            loginUserId: _signUpModel?.user?.id ?? "");

                        if (_signUpModel?.status == true &&
                            _signUpModel?.user?.ipAddress == null &&
                            _signUpModel?.user?.country == null) {
                          Get.back();
                          AppSettings.showLog("APP LOGIN Lets Go ");
                          Get.offAll(FillProfileView(
                            email: response.user!.email!,
                            loginUserId: _signUpModel!.user!.id!,
                            profileImage: response.user!.photoURL,
                            username: response.user!.displayName,
                          ));
                        } else {
                          Get.back();
                          CustomDialog.show(
                              AppIcons.profileDoneLogo1,
                              AppStrings.congratulations.tr,
                              AppStrings.congratulationsNote.tr);
                          if (_signUpModel?.user?.id != null) {
                            await GetProfileApi.callApi(
                                _signUpModel!.user!.id!);
                          }
                          Get.back();
                          if (Database.isNewUser == false &&
                              AdminSettingsApi.adminSettingsModel?.setting !=
                                  null &&
                              Database.loginUserId != null &&
                              GetProfileApi.profileModel?.user != null) {
                            Get.offAll(const MainHomePageView());
                          } else {
                            CustomToast.show(AppStrings.getProfileFailed.tr);
                          }
                        }
                      } else {
                        Get.back();
                        if (_signUpModel?.message ==
                            "You are blocked by admin!") {
                          CustomToast.show(_signUpModel?.message.toString() ??
                              AppStrings.someThingWentWrong.tr);
                        } else {
                          CustomToast.show(AppStrings.signUpFailed.tr);
                        }
                      }
                    } else {
                      Get.back();
                      CustomToast.show(AppStrings.googleLoginFailed.tr);
                    }
                  },
                ),
                SizedBox(height: Get.height / 35),

                // ─── Apple Login — only shown on iOS ───────────────────
                // ✅ Use _isIOS getter which safely returns false on web
                _isIOS
                    ? Column(
                        children: [
                          ButtonItemUi(
                            title: AppStrings.appleLogin.tr,
                            icon: Image.asset(AppIcons.appleLogo,
                                width: 28,
                                color: isDarkMode.value
                                    ? AppColor.white
                                    : AppColor.black),
                            callback: () async {
                              try {
                                Get.dialog(
                                    const LoaderUi(color: AppColor.white),
                                    barrierDismissible: false);

                                final isAvailable =
                                    await SignInWithApple.isAvailable();
                                if (!isAvailable) {
                                  Get.back();
                                  CustomToast.show(
                                      "Apple Sign In is not available on this device");
                                  return;
                                }

                                final appleCredential =
                                    await SignInWithApple.getAppleIDCredential(
                                  scopes: [
                                    AppleIDAuthorizationScopes.email,
                                    AppleIDAuthorizationScopes.fullName,
                                  ],
                                );

                                if (appleCredential.identityToken == null) {
                                  Get.back();
                                  CustomToast.show(
                                      "Failed to get Apple credentials");
                                  return;
                                }

                                final oauthCredential =
                                    OAuthProvider("apple.com").credential(
                                  idToken: appleCredential.identityToken,
                                  accessToken:
                                      appleCredential.authorizationCode,
                                );

                                final response = await FirebaseAuth.instance
                                    .signInWithCredential(oauthCredential);

                                if (response.user == null) {
                                  Get.back();
                                  CustomToast.show("Authentication failed");
                                  return;
                                }

                                String? userEmail = response.user!.email;
                                if (userEmail == null || userEmail.isEmpty) {
                                  userEmail = appleCredential.email ??
                                      "${response.user!.uid}@appleid.com";
                                }

                                if (Database.fcmToken == null ||
                                    Database.deviceId == null) {
                                  Get.back();
                                  CustomToast.show(
                                      "Device information not available. Please restart the app.");
                                  return;
                                }

                                _signUpModel = await SignUpApi.callApi(
                                    userEmail,
                                    null,
                                    3,
                                    Database.fcmToken!,
                                    Database.deviceId!);

                                if (_signUpModel != null &&
                                    _signUpModel?.user?.id != null) {
                                  AppSettings.onLoginWithReferral(
                                      loginUserId:
                                          _signUpModel?.user?.id ?? "");

                                  if (_signUpModel?.status == true &&
                                      _signUpModel?.user?.ipAddress == null &&
                                      _signUpModel?.user?.country == null) {
                                    Get.back();
                                    Get.offAll(FillProfileView(
                                        email: userEmail,
                                        loginUserId: _signUpModel!.user!.id!));
                                  } else {
                                    Get.back();
                                    CustomDialog.show(
                                        AppIcons.profileDoneLogo1,
                                        AppStrings.congratulations.tr,
                                        AppStrings.congratulationsNote.tr);

                                    if (_signUpModel?.user?.id != null) {
                                      await GetProfileApi.callApi(
                                          _signUpModel!.user!.id!);
                                    }

                                    Get.back();

                                    if (Database.isNewUser == false &&
                                        AdminSettingsApi
                                                .adminSettingsModel?.setting !=
                                            null &&
                                        Database.loginUserId != null &&
                                        GetProfileApi.profileModel?.user !=
                                            null) {
                                      Get.offAll(const MainHomePageView());
                                    } else {
                                      CustomToast.show(
                                          AppStrings.getProfileFailed.tr);
                                    }
                                  }
                                } else {
                                  Get.back();
                                  if (_signUpModel?.message ==
                                      "You are blocked by admin!") {
                                    CustomToast.show(
                                        _signUpModel?.message.toString() ??
                                            AppStrings.someThingWentWrong.tr);
                                  } else {
                                    CustomToast.show(_signUpModel?.message ??
                                        AppStrings.signUpFailed.tr);
                                  }
                                }
                              } catch (e) {
                                Get.back();
                                AppSettings.showLog("Apple Login Error: $e");
                                if (e
                                    is SignInWithAppleAuthorizationException) {
                                  // User cancelled — no toast needed
                                } else if (e is FirebaseAuthException) {
                                  CustomToast.show(
                                      "Firebase error: ${e.message}");
                                } else {
                                  CustomToast.show(
                                      "An unexpected error occurred");
                                }
                              }
                            },
                          ),
                          SizedBox(height: Get.height / 35),
                        ],
                      )
                    : const Offstage(),

                // ─── OR Divider ─────────────────────────────────────────
                SizedBox(
                  width: Get.width,
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 1,
                          margin: const EdgeInsets.only(right: 15),
                          decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      Text(AppStrings.or.tr,
                          textAlign: TextAlign.center, style: orStyle),
                      Expanded(
                        child: Container(
                          height: 1,
                          margin: const EdgeInsets.only(left: 15),
                          decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: Get.height / 35),
                BasicButton(
                    width: Get.width,
                    title: AppStrings.signWithPassword.tr,
                    callback: () => Get.offAll(() => const MainHomePageView())),
                SizedBox(height: Get.height / 35),
                LoginScreenBottomText(
                  text1: AppStrings.dontHaveAnAccount.tr,
                  text2: AppStrings.signUp.tr,
                  onTap: () => Get.offAll(() => const MainHomePageView()),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ButtonItemUi extends StatelessWidget {
  const ButtonItemUi(
      {super.key,
      required this.title,
      required this.icon,
      required this.callback});

  final String title;
  final Widget icon;
  final Callback callback;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: callback,
      child: Container(
        height: Get.height * 0.064,
        width: Get.width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color:
                  isDarkMode.value ? const Color(0xff35383F) : Colors.black12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                icon,
                const SizedBox(width: 12),
                Text(title, style: loginMethodStyle),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
