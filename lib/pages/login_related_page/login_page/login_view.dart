import 'dart:developer';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart'; // ✅ Added
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:metube/custom/basic_button.dart';
import 'package:metube/custom/custom_method/custom_box_button.dart';
import 'package:metube/custom/custom_method/custom_dialog.dart';
import 'package:metube/custom/custom_method/custom_text_field.dart';
import 'package:metube/custom/custom_method/custom_toast.dart';
import 'package:metube/custom/custom_ui/loader_ui.dart';
import 'package:metube/database/database.dart';
import 'package:metube/main.dart';
import 'package:metube/pages/admin_settings/admin_settings_api.dart';
import 'package:metube/pages/login_related_page/fill_profile_page/fill_profile_view.dart';
import 'package:metube/pages/login_related_page/fill_profile_page/get_profile_api.dart';
import 'package:metube/pages/login_related_page/forgot_password_page/forget_password_view.dart';
import 'package:metube/pages/login_related_page/google_login_page/google_login.dart';
import 'package:metube/pages/login_related_page/lets_you_in_page/lets_you_in_view.dart';
import 'package:metube/pages/login_related_page/login_page/login_api.dart';
import 'package:metube/pages/login_related_page/login_page/login_model.dart';
import 'package:metube/pages/login_related_page/sign_up_page/sign_up_api.dart';
import 'package:metube/pages/login_related_page/sign_up_page/sign_up_model.dart';
import 'package:metube/pages/login_related_page/sign_up_page/sign_up_view.dart';
import 'package:metube/pages/main_home_page/main_home_view.dart';
import 'package:metube/utils/colors/app_color.dart';
import 'package:metube/utils/config/size_config.dart';
import 'package:metube/utils/icons/app_icons.dart';
import 'package:metube/utils/settings/app_settings.dart';
import 'package:metube/utils/string/app_string.dart';
import 'package:metube/utils/style/app_style.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:metube/utils/constant/app_constant.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  LoginModel? _loginModel;
  SignUpModel? _signUpModel;

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  RxBool isShowPassword = false.obs;
  RxBool isRememberMe = false.obs;

  FocusNode passwordFocusNode = FocusNode();
  FocusNode emailFocusNode = FocusNode();

  // ✅ Safe platform getters
  bool get _isIOS => !kIsWeb && Platform.isIOS;

  @override
  void initState() {
    emailController.clear();
    passwordController.clear();
    isShowPassword(false);
    isRememberMe(false);

    emailFocusNode.addListener(() {
      if (emailFocusNode.hasFocus) {
        setState(() => color = const Color(0xFFFCE7E9));
      } else {
        color = AppColor.grey_100;
      }
    });
    passwordFocusNode.addListener(() {
      if (passwordFocusNode.hasFocus) {
        setState(() => color = const Color(0xFFFCE7E9));
      } else {
        color = AppColor.grey_100;
      }
    });
    super.initState();
  }

  // ─── Reusable Google Login Logic ────────────────────────────────────────
  Future<void> _handleGoogleLogin() async {
    Get.dialog(const LoaderUi(color: AppColor.white),
        barrierDismissible: false);
    dynamic response;
    try {
      response = await GoogleLogin.signInWithGoogle();
    } catch (e) {
      AppSettings.showLog("GOOGLE ERROR $e");
    }

    if (response != null && response.user?.email != null) {
      _signUpModel = await SignUpApi.callApi(response.user!.email!, null, 2,
          Database.fcmToken!, Database.deviceId!);

      if (_signUpModel != null && _signUpModel?.user?.id != null) {
        AppSettings.onLoginWithReferral(
            loginUserId: _signUpModel?.user?.id ?? "");

        if (_signUpModel?.status == true &&
            _signUpModel?.user?.ipAddress == null &&
            _signUpModel?.user?.country == null) {
          Get.back();
          AppSettings.showLog("APP LOGIN Google");
          Get.offAll(FillProfileView(
            email: response.user!.email!,
            loginUserId: _signUpModel!.user!.id!,
            username: response.user!.displayName,
            profileImage: response.user!.photoURL,
          ));
        } else {
          Get.back();
          CustomDialog.show(AppIcons.profileDoneLogo1,
              AppStrings.congratulations.tr, AppStrings.congratulationsNote.tr);
          if (_signUpModel?.user?.id != null) {
            await GetProfileApi.callApi(_signUpModel!.user!.id!);
          }
          Get.back();
          if (Database.isNewUser == false &&
              AdminSettingsApi.adminSettingsModel?.setting != null &&
              Database.loginUserId != null &&
              GetProfileApi.profileModel?.user != null) {
            Get.offAll(const MainHomePageView());
          } else {
            CustomToast.show(AppStrings.getProfileFailed.tr);
          }
        }
      } else {
        Get.back();
        if (_signUpModel?.message == "You are blocked by admin!") {
          CustomToast.show(_signUpModel?.message.toString() ??
              AppStrings.someThingWentWrong.tr);
        } else {
          CustomToast.show(AppStrings.googleLoginFailed.tr);
        }
      }
    } else {
      Get.back();
      CustomToast.show(AppStrings.googleLoginFailed.tr);
    }
  }

  // ─── Apple Login Logic ───────────────────────────────────────────────────
  Future<void> _handleAppleLogin() async {
    try {
      Get.dialog(const LoaderUi(color: AppColor.white),
          barrierDismissible: false);

      final isAvailable = await SignInWithApple.isAvailable();
      if (!isAvailable) {
        Get.back();
        CustomToast.show("Apple Sign In is not available on this device");
        return;
      }

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      if (appleCredential.identityToken == null) {
        Get.back();
        CustomToast.show("Failed to get Apple credentials");
        return;
      }

      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      final response =
          await FirebaseAuth.instance.signInWithCredential(oauthCredential);

      if (response.user == null) {
        Get.back();
        CustomToast.show("Authentication failed");
        return;
      }

      String? userEmail = response.user!.email;
      String? userName = response.user!.displayName;
      String? photoURL = response.user!.photoURL;

      if (userEmail == null || userEmail.isEmpty) {
        userEmail = appleCredential.email;
        if (userEmail == null || userEmail.isEmpty) {
          userEmail = "${response.user!.uid}@appleid.private";
        }
      }

      if (userName == null || userName.isEmpty) {
        if (appleCredential.givenName != null ||
            appleCredential.familyName != null) {
          userName =
              "${appleCredential.givenName ?? ''} ${appleCredential.familyName ?? ''}"
                  .trim();
          if (userName.isEmpty) userName = null;
        }
      }

      if (Database.fcmToken == null || Database.deviceId == null) {
        Get.back();
        CustomToast.show(
            "Device information not available. Please restart the app.");
        return;
      }

      _signUpModel = await SignUpApi.callApi(
          userEmail, null, 3, Database.fcmToken!, Database.deviceId!);

      if (_signUpModel != null && _signUpModel?.user?.id != null) {
        AppSettings.onLoginWithReferral(
            loginUserId: _signUpModel?.user?.id ?? "");

        if (_signUpModel?.status == true &&
            _signUpModel?.user?.ipAddress == null &&
            _signUpModel?.user?.country == null) {
          Get.back();
          AppSettings.showLog("APP LOGIN Apple");
          Get.offAll(FillProfileView(
            email: userEmail,
            loginUserId: _signUpModel!.user!.id!,
            username: userName,
            profileImage: photoURL,
          ));
        } else {
          Get.back();
          CustomDialog.show(AppIcons.profileDoneLogo1,
              AppStrings.congratulations.tr, AppStrings.congratulationsNote.tr);
          if (_signUpModel?.user?.id != null) {
            await GetProfileApi.callApi(_signUpModel!.user!.id!);
          }
          Get.back();
          if (Database.isNewUser == false &&
              AdminSettingsApi.adminSettingsModel?.setting != null &&
              Database.loginUserId != null &&
              GetProfileApi.profileModel?.user != null) {
            Get.offAll(const MainHomePageView());
          } else {
            CustomToast.show(AppStrings.getProfileFailed.tr);
          }
        }
      } else {
        Get.back();
        if (_signUpModel?.message == "You are blocked by admin!") {
          CustomToast.show(_signUpModel?.message.toString() ??
              AppStrings.someThingWentWrong.tr);
        } else {
          CustomToast.show(_signUpModel?.message ?? AppStrings.signUpFailed.tr);
        }
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      AppSettings.showLog("Apple Login Error: $e");

      if (e is SignInWithAppleAuthorizationException) {
        switch (e.code) {
          case AuthorizationErrorCode.canceled:
            break; // User canceled — no toast
          case AuthorizationErrorCode.failed:
            CustomToast.show("Apple Sign In failed. Please try again.");
            break;
          case AuthorizationErrorCode.invalidResponse:
            CustomToast.show("Invalid response from Apple. Please try again.");
            break;
          case AuthorizationErrorCode.notHandled:
            CustomToast.show("Apple Sign In not available. Please try again.");
            break;
          default:
            CustomToast.show("Apple Sign In failed. Please try again.");
        }
      } else if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'invalid-credential':
            CustomToast.show("Invalid Apple credentials. Please try again.");
            break;
          case 'account-exists-with-different-credential':
            CustomToast.show(
                "An account already exists with this email using a different sign-in method.");
            break;
          case 'network-request-failed':
            CustomToast.show("Network error. Please check your connection.");
            break;
          default:
            CustomToast.show("Authentication failed: ${e.message}");
        }
      } else {
        CustomToast.show("An unexpected error occurred. Please try again.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              SizedBox(height: Get.height * 0.10),
              Image.asset(AppIcons.logo, width: Get.height * 0.20),
              // SizedBox(height: Get.height / 25),
              Text(AppStrings.loginYourAccount.tr,
                  textAlign: TextAlign.center, style: createAccountStyle),
              SizedBox(height: SizeConfig.screenHeight / 35),
              Column(
                children: [
                  CustomTextFieldView(
                    width: Get.width,
                    hintText: AppStrings.email.tr,
                    prefixIconPath: AppIcons.email,
                    controller: emailController,
                    focusNode: emailFocusNode,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: SizeConfig.screenHeight / 50),
                  Obx(
                    () => CustomTextFieldView(
                      width: Get.width,
                      hintText: AppStrings.password.tr,
                      obscureText: !isShowPassword.value,
                      prefixIconPath: AppIcons.password,
                      controller: passwordController,
                      suffixIconPath:
                          isShowPassword.value ? AppIcons.show : AppIcons.hide,
                      suffixIconCallback: () =>
                          isShowPassword.value = !isShowPassword.value,
                      focusNode: passwordFocusNode,
                      keyboardType: TextInputType.visiblePassword,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () => isRememberMe.value = !isRememberMe.value,
                child: SizedBox(
                  height: 30,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 8,
                        width: 8,
                        child: Obx(
                          () => Checkbox(
                            activeColor: AppColor.primaryColor,
                            checkColor: AppColor.white,
                            value: isRememberMe.value,
                            onChanged: (value) => isRememberMe.value = value!,
                            shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5))),
                            side: const BorderSide(
                                color: AppColor.primaryColor, width: 1.5),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Text(AppStrings.rememberMe.tr,
                          textAlign: TextAlign.center, style: rememberStyle),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              BasicButton(
                width: Get.width,
                title: AppStrings.signIN.tr,
                callback: () async {
                  AppSettings.showLog("🔴 Sign In button clicked");

                  if (emailController.text.isEmpty ||
                      passwordController.text.isEmpty) {
                    CustomToast.show(AppStrings.pleaseFillUpDetails.tr);
                    return;
                  }

                  try {
                    Get.dialog(const LoaderUi(color: AppColor.white),
                        barrierDismissible: false);

                    _loginModel = await LoginApi.callApi(
                      emailController.text.trim(),
                      passwordController.text.trim(),
                      4,
                    );

                    if (_loginModel?.message == "User must have sign up!!") {
                      Get.back();
                      CustomToast.show(
                          "Account not found. Please sign up first.");
                      await Future.delayed(const Duration(milliseconds: 500));
                      emailController.clear();
                      passwordController.clear();
                      Get.off(() => const SignUpView());
                      return;
                    }

                    if (_loginModel?.status != true ||
                        _loginModel?.isLogin != true) {
                      Get.back();
                      CustomToast.show(_loginModel?.message ?? "Login failed");
                      return;
                    }

                    if (Database.deviceId == null ||
                        Database.fcmToken == null) {
                      Get.back();
                      CustomToast.show("Device information missing");
                      return;
                    }

                    _signUpModel = await SignUpApi.callApi(
                      emailController.text.trim(),
                      passwordController.text.trim(),
                      4,
                      Database.fcmToken!,
                      Database.deviceId!,
                    );

                    Get.back();

                    if (_signUpModel == null ||
                        _signUpModel?.user?.id == null) {
                      if (_signUpModel?.message ==
                          "You are blocked by admin!") {
                        CustomToast.show("You are blocked by admin!");
                      } else {
                        CustomToast.show("Login failed. Please try again.");
                      }
                      return;
                    }

                    AppSettings.onLoginWithReferral(
                        loginUserId: _signUpModel?.user?.id ?? "");

                    if (_signUpModel?.user?.ipAddress == null ||
                        _signUpModel?.user?.country == null) {
                      AppSettings.showLog("📝 Profile incomplete");
                      Get.offAll(() => FillProfileView(
                            email: _signUpModel!.user!.email!,
                            loginUserId: _signUpModel!.user!.id!,
                          ));
                      return;
                    }

                    AppSettings.showLog("✅ Profile complete - loading data...");

                    await CustomDialog.showWithButton(
                      AppIcons.profileDoneLogo1,
                      AppStrings.congratulations.tr,
                      AppStrings.congratulationsNote.tr,
                    );

                    Get.dialog(const LoaderUi(color: AppColor.white),
                        barrierDismissible: false);

                    final settingsSuccess = await AdminSettingsApi.callApi();
                    AppSettings.showLog("settingsSuccess => $settingsSuccess");

                    AppSettings.showLog(
                        "adminSettingsModel => ${AdminSettingsApi.adminSettingsModel}");

                    AppSettings.showLog(
                        "setting => ${AdminSettingsApi.adminSettingsModel?.setting}");
                    await GetProfileApi.callApi(_signUpModel!.user!.id!);

                    if (Get.isDialogOpen ?? false) {
                      Get.back();
                    }

                    final hasSettings =
                        AdminSettingsApi.adminSettingsModel?.setting != null;
                    final hasUserId = Database.loginUserId != null;
                    final hasProfile = GetProfileApi.profileModel?.user != null;

                    if (hasSettings && hasUserId && hasProfile) {
                      Get.offAll(() => const MainHomePageView());
                    } else {
                      if (!hasSettings) {
                        AppSettings.showLog(
                            "Settings API returned: $settingsSuccess");
                        CustomToast.show(
                            "Failed to load settings. Please try again.");
                      } else if (!hasProfile) {
                        CustomToast.show(
                            "Failed to load profile. Please try again.");
                      } else {
                        CustomToast.show(
                            "Login incomplete. Please restart the app.");
                      }
                    }
                  } catch (e, stackTrace) {
                    if (Get.isDialogOpen ?? false) Get.back();
                    AppSettings.showLog(
                        "❌ Login error: $e\nStack: $stackTrace");
                    CustomToast.show("An error occurred. Please try again.");
                  }
                },
              ),
              SizedBox(height: SizeConfig.screenHeight / 50),
              GestureDetector(
                child: Text(AppStrings.forgetThePassword.tr,
                    style: forGetPasswordStyle),
                onTap: () {
                  if (emailController.text.isNotEmpty) {
                    Get.to(
                        () => ForgotPasswordView(email: emailController.text));
                  } else {
                    CustomToast.show(AppStrings.pleaseEnterYourEmail.tr);
                  }
                },
              ),
              SizedBox(height: SizeConfig.screenHeight / 20),
              SizedBox(
                width: Get.width,
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 1,
                        margin: const EdgeInsets.only(right: 5),
                        decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    Expanded(
                      child: Text(AppStrings.orContinueWith.tr,
                          textAlign: TextAlign.center, style: titalstyle5),
                    ),
                    Expanded(
                      child: Container(
                        height: 1,
                        margin: const EdgeInsets.only(left: 5),
                        decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: Get.height / 30),

              // ✅ Use _isIOS getter — safely returns false on web
              _isIOS
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CustomBoxButton(
                          child: Image.asset(AppIcons.googleLogo, width: 30),
                          callback: _handleGoogleLogin, // ✅ Reused method
                        ),
                        const SizedBox(width: 20),
                        CustomBoxButton(
                          callback: _handleAppleLogin, // ✅ Reused method
                          child: Image.asset(AppIcons.appleLogo,
                              color: isDarkMode.value
                                  ? AppColor.white
                                  : AppColor.black,
                              width: 30),
                        ),
                      ],
                    )
                  : ButtonItemUi(
                      title: AppStrings.googleLogin.tr,
                      icon: Image.asset(AppIcons.googleLogo, width: 25),
                      callback: _handleGoogleLogin, // ✅ Reused method
                    ),

              SizedBox(height: SizeConfig.screenHeight / 30),
              LoginScreenBottomText(
                text1: AppStrings.dontHaveAnAccount.tr,
                text2: AppStrings.signUp.tr,
                onTap: () => Get.to(() => const SignUpView()),
              ),
              SizedBox(height: SizeConfig.screenHeight / 35),
            ],
          ),
        ),
      ),
    );
  }
}
