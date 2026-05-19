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
import 'package:metube/pages/login_related_page/google_login_page/google_login.dart';
import 'package:metube/pages/login_related_page/lets_you_in_page/lets_you_in_view.dart';
import 'package:metube/pages/login_related_page/login_page/login_api.dart';
import 'package:metube/pages/login_related_page/login_page/login_model.dart';
import 'package:metube/pages/login_related_page/login_page/login_view.dart';
import 'package:metube/pages/login_related_page/otp_page/sign_up_otp_view.dart';
import 'package:metube/pages/login_related_page/otp_page/sign_up_send_otp_api.dart';
import 'package:metube/pages/login_related_page/sign_up_page/sign_up_api.dart';
import 'package:metube/pages/login_related_page/sign_up_page/sign_up_model.dart';
import 'package:metube/pages/main_home_page/main_home_view.dart';
import 'package:metube/utils/colors/app_color.dart';
import 'package:metube/utils/config/size_config.dart';
import 'package:metube/utils/icons/app_icons.dart';
import 'package:metube/utils/settings/app_settings.dart';
import 'package:metube/utils/string/app_string.dart';
import 'package:metube/utils/style/app_style.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  SignUpModel? _signUpModel;
  LoginModel? _loginModel;
  RxBool isShowPassword = false.obs;
  RxBool isShowConfirmPassword = false.obs;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  FocusNode emailFocusNode = FocusNode();
  FocusNode passwordFocusNode = FocusNode();
  FocusNode confirmPasswordFocusNode = FocusNode();

  // ✅ Safe platform getter
  bool get _isIOS => !kIsWeb && Platform.isIOS;

  @override
  void initState() {
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    isShowPassword.value = false;

    super.initState();

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
    confirmPasswordFocusNode.addListener(() {
      if (confirmPasswordFocusNode.hasFocus) {
        setState(() => color = const Color(0xFFFCE7E9));
      } else {
        color = AppColor.grey_100;
      }
    });
  }

  // ─── Reusable Google Login Logic ─────────────────────────────────────────
  Future<void> _handleGoogleLogin() async {
    Get.dialog(const LoaderUi(color: AppColor.white), barrierDismissible: false);
    dynamic response;
    try {
      response = await GoogleLogin.signInWithGoogle();
    } catch (e) {
      AppSettings.showLog("GOOGLE ERROR $e");
    }

    if (response != null && response.user?.email != null) {
      _signUpModel = await SignUpApi.callApi(
          response.user!.email!, null, 2, Database.fcmToken!, Database.deviceId!);

      if (_signUpModel != null && _signUpModel?.user?.id != null) {
        AppSettings.onLoginWithReferral(loginUserId: _signUpModel?.user?.id ?? "");

        if (_signUpModel?.status == true &&
            _signUpModel?.user?.ipAddress == null &&
            _signUpModel?.user?.country == null) {
          Get.back();
          Get.offAll(FillProfileView(
            email: response.user!.email!,
            loginUserId: _signUpModel!.user!.id!,
            profileImage: response.user!.photoURL,
            username: response.user!.displayName,
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

  // ─── Reusable Apple Login Logic ──────────────────────────────────────────
  Future<void> _handleAppleLogin() async {
    try {
      Get.dialog(const LoaderUi(color: AppColor.white), barrierDismissible: false);

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
          AppSettings.showLog("APP LOGIN Apple SignUp");
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
          child: Column(
            children: [
              SizedBox(height: Get.height * 0.10),
              Image.asset(AppIcons.logo, width: Get.height * 0.20),
              SizedBox(height: Get.height / 25),
              Text(
                AppStrings.createYourAccount.tr,
                textAlign: TextAlign.center,
                style: createAccountStyle,
              ),
              SizedBox(height: Get.height / 35),
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
                  SizedBox(height: SizeConfig.screenHeight / 50),
                  Obx(
                    () => CustomTextFieldView(
                      width: Get.width,
                      hintText: AppStrings.conformPassword.tr,
                      obscureText: !isShowConfirmPassword.value,
                      prefixIconPath: AppIcons.password,
                      controller: confirmPasswordController,
                      suffixIconPath: isShowConfirmPassword.value
                          ? AppIcons.show
                          : AppIcons.hide,
                      suffixIconCallback: () => isShowConfirmPassword.value =
                          !isShowConfirmPassword.value,
                      focusNode: confirmPasswordFocusNode,
                      keyboardType: TextInputType.visiblePassword,
                    ),
                  ),
                ],
              ),
              SizedBox(height: SizeConfig.screenHeight / 50),
              BasicButton(
                width: Get.width,
                title: AppStrings.signUp.tr,
                callback: () async {
                  if (emailController.text.isEmpty ||
                      passwordController.text.isEmpty) {
                    CustomToast.show(AppStrings.pleaseFillUpDetails.tr);
                    return;
                  }

                  if (passwordController.text !=
                      confirmPasswordController.text) {
                    CustomToast.show(AppStrings.passwordNotMatch.tr);
                    return;
                  }

                  AppSettings.showLog("🚀 Starting signup process...");
                  Get.dialog(const LoaderUi(color: AppColor.white),
                      barrierDismissible: false);

                  _loginModel = await LoginApi.callApi(
                      emailController.text.trim(),
                      passwordController.text.trim(),
                      4);

                  Get.back();

                  if (_loginModel == null) {
                    AppSettings.showLog("❌ No response from server");
                    CustomToast.show(
                        "Connection error. Please check your internet and try again.");
                    return;
                  }

                  AppSettings.showLog(
                      "📊 status: ${_loginModel?.status}, isLogin: ${_loginModel?.isLogin}, message: ${_loginModel?.message}");

                  if (_loginModel?.status == true &&
                      _loginModel?.isLogin == false) {
                    AppSettings.showLog("✅ New user - sending OTP");
                    await SignUpSendOtpApi.callApi(emailController.text.trim());
                    Get.to(SignUpOtpView(
                        email: emailController.text.trim(),
                        password: passwordController.text.trim()));
                  } else if (_loginModel?.isLogin == true) {
                    AppSettings.showLog("⚠️ User already exists");
                    CustomToast.show(AppStrings.userAlreadyExist.tr);
                    await Future.delayed(const Duration(milliseconds: 500));
                    Get.off(() => const LoginView());
                  } else {
                    AppSettings.showLog("❌ Signup check failed");
                    CustomToast.show(_loginModel?.message ??
                        AppStrings.someThingWentWrong.tr);
                  }
                },
              ),
              SizedBox(height: Get.height / 20),
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
              SizedBox(height: Get.height / 35),

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

              SizedBox(height: Get.height / 35),
              LoginScreenBottomText(
                text1: AppStrings.alreadyHaveAnAccount.tr,
                text2: AppStrings.signIN.tr,
                onTap: () => Get.to(() => const LoginView()),
              ),
              SizedBox(height: Get.height / 35),
            ],
          ),
        ),
      ),
    );
  }
}