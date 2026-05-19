import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:metube/custom/basic_button.dart';
import 'package:metube/custom/custom_method/custom_toast.dart';
import 'package:metube/main.dart';
import 'package:metube/pages/login_related_page/create_new_password_page/set_password_api.dart';
import 'package:metube/pages/login_related_page/login_page/login_view.dart';
import 'package:metube/utils/colors/app_color.dart';
import 'package:metube/utils/icons/app_icons.dart';
import 'package:metube/utils/string/app_string.dart';
import 'package:metube/utils/style/app_style.dart';

class CreateNewPasswordView extends StatefulWidget {
  const CreateNewPasswordView({super.key, required this.email});
  final String email;
  @override
  State<CreateNewPasswordView> createState() => _CreateNewPasswordViewState();
}

class _CreateNewPasswordViewState extends State<CreateNewPasswordView> {
  RxBool isRememberMe = false.obs;
  RxBool isShowPassword = false.obs;
  RxBool isShowConfirmPassword = false.obs;

  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  @override
  void initState() {
    passwordController.clear();
    confirmPasswordController.clear();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(AppStrings.createNewPassword.tr, style: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.bold)),
        automaticallyImplyLeading: false,
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: BasicButton(
          title: AppStrings.continueString.tr,
          callback: () async {
            FocusManager.instance.primaryFocus?.unfocus();
            if (passwordController.text.isNotEmpty) {
              if (passwordController.text == confirmPasswordController.text) {
                final status = await SetPasswordApi.callApi(widget.email, passwordController.text, confirmPasswordController.text);
                if (status != null && status == true) {
                  Get.offAll(() => const LoginView());
                  // basicDialog(AppIcons.profileDoneLogo1, AppStrings.congratulations.tr, AppStrings.congratulationsNote.tr);
                }
              } else {
                CustomToast.show(AppStrings.passwordNotMatch.tr);
              }
            } else {
              CustomToast.show(AppStrings.pleaseEnterPassword.tr);
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: Column(
            children: [
              SizedBox(height: Get.height / 8),
              SizedBox(
                height: Get.height / 3.5,
                child: Image(
                  image: isDarkMode.value ? const AssetImage(AppIcons.darkNewPasswordLogo) : const AssetImage(AppIcons.newPasswordLogo),
                ),
              ),
              SizedBox(height: Get.height / 12),
              Padding(
                padding: const EdgeInsets.only(right: 120),
                child: Text(
                  AppStrings.createYourNewPassword.tr,
                  style: GoogleFonts.urbanist(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
              SizedBox(height: Get.height / 35),
              Container(
                height: Get.height / 15.5,
                width: Get.width,
                alignment: Alignment.center,
                padding: const EdgeInsets.only(left: 10, right: 10),
                margin: const EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  color: isDarkMode.value ? AppColor.secondDarkMode : AppColor.grey_100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Obx(
                  () => TextFormField(
                    controller: passwordController,
                    obscureText: !isShowPassword.value,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      suffixIconConstraints: const BoxConstraints(minWidth: 2, minHeight: 2),
                      prefixIconConstraints: const BoxConstraints(minWidth: 2, minHeight: 2),
                      suffixIcon: GestureDetector(
                        onTap: () => isShowPassword.value = !isShowPassword.value,
                        child: Image.asset(
                          isShowPassword.value ? AppIcons.show : AppIcons.hide,
                          color: Colors.grey,
                          width: 24,
                          height: 24,
                        ),
                      ),
                      icon: const ImageIcon(AssetImage(AppIcons.password), size: 20).paddingOnly(left: 5),
                      hintText: AppStrings.password.tr,
                      hintStyle: fillYourProfileStyle,
                    ),
                  ),
                ),
              ),
              SizedBox(height: Get.height / 35),
              Container(
                height: Get.height / 15.5,
                width: Get.width,
                alignment: Alignment.center,
                margin: const EdgeInsets.symmetric(horizontal: 5),
                padding: const EdgeInsets.only(left: 10, right: 10),
                decoration: BoxDecoration(color: isDarkMode.value ? AppColor.secondDarkMode : AppColor.grey_100, borderRadius: BorderRadius.circular(10)),
                child: Obx(
                  () => TextFormField(
                    controller: confirmPasswordController,
                    obscureText: !isShowConfirmPassword.value,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      suffixIconConstraints: const BoxConstraints(minWidth: 2, minHeight: 2),
                      prefixIconConstraints: const BoxConstraints(minWidth: 2, minHeight: 2),
                      suffixIcon: GestureDetector(
                        onTap: () => isShowConfirmPassword.value = !isShowConfirmPassword.value,
                        child: Image.asset(isShowConfirmPassword.value ? AppIcons.show : AppIcons.hide, color: Colors.grey, width: 24, height: 24),
                      ),
                      icon: const ImageIcon(AssetImage(AppIcons.password), size: 20).paddingOnly(left: 5),
                      hintText: AppStrings.conformPassword.tr,
                      hintStyle: fillYourProfileStyle,
                    ),
                  ),
                ),
              ),
              SizedBox(height: Get.height / 10),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   crossAxisAlignment: CrossAxisAlignment.center,
              //   children: [
              //     SizedBox(
              //       height: 5,
              //       width: 5,
              //       child: Checkbox(
              //         activeColor: AppColors.primaryColor,
              //         value: isRememberMe.value,
              //         onChanged: (value) => isRememberMe(value),
              //         shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
              //         side: const BorderSide(color: AppColors.primaryColor, width: 1.5),
              //       ),
              //     ),
              //     const SizedBox(width: 15),
              //     Text(
              //       AppStrings.rememberMe,
              //       textAlign: TextAlign.center,
              //       style: rememberStyle,
              //     ),
              //   ],
              // ),
            ],
          ),
        ),
      ),
    );
  }
}

// TextEditingController passwordController = TextEditingController();
// TextEditingController conformPasswordController = TextEditingController();

//
// if (forgetPasswordController.newpasswordController.text.isEmpty &&
// forgetPasswordController.conformPasswordController.text.isEmpty) {
// Fluttertoast.showToast(
// msg: "Please, Enter Password",
// backgroundColor: Colors.red,
// textColor: AppColors.white,
// gravity: ToastGravity.BOTTOM,
// );
// } else {
// forgetPasswordController.setpassword();
//
// basicDialog(AppIcons.profileDoneLogo1, AppStrings.congratulations.tr,
// AppStrings.congratulationsNote.tr);
// Timer(
// const Duration(seconds: 1),
// () {
// Get.to(
// () => MainHomePageView(),
// );
// },
// );
// }
