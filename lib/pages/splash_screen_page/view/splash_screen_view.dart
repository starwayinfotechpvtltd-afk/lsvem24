import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:metube/custom/custom_method/custom_toast.dart';
import 'package:metube/database/database.dart';
import 'package:metube/main.dart';
import 'package:metube/pages/admin_settings/admin_settings_api.dart';
import 'package:metube/pages/login_related_page/fill_profile_page/get_profile_api.dart';
import 'package:metube/pages/main_home_page/main_home_view.dart';
import 'package:metube/pages/nav_add_page/live_page/widget/device_orientation.dart';
import 'package:metube/utils/branch_io_services.dart';
import 'package:metube/utils/colors/app_color.dart';
import 'package:metube/utils/config/size_config.dart';
import 'package:metube/utils/icons/app_icons.dart';
import 'package:metube/utils/settings/app_settings.dart';
import 'package:quick_actions/quick_actions.dart';

class SplashScreenView extends StatefulWidget {
  const SplashScreenView({super.key});

  @override
  State<SplashScreenView> createState() => _SplashScreenViewState();
}

class _SplashScreenViewState extends State<SplashScreenView> {
  final quickAction = const QuickActions();

  @override
  void initState() {
    super.initState();
    splashScreen();
  }

  void splashScreen() async {
    AppSettings.showLog("🚀 Splash screen started");

    try {
      // ✅ Load admin settings first
      AppSettings.showLog("⏳ Loading admin settings...");
      final success = await AdminSettingsApi.callApi();

      if (!success) {
        AppSettings.showLog("❌ Failed to load admin settings");
        Timer(const Duration(seconds: 1), () {
          _showSettingsError();
        });
        return;
      }

      AppSettings.showLog("✅ Admin settings loaded");
      AppSettings.showLog("📊 Checking user login status...");
      AppSettings.showLog("  - loginUserId: ${Database.loginUserId}");
      AppSettings.showLog("  - isNewUser: ${Database.isNewUser}");

      // ✅ Check if user is logged in
      if (Database.loginUserId != null && Database.loginUserId!.isNotEmpty) {
        AppSettings.showLog("👤 User is logged in, loading profile...");

        // Load user profile
        await GetProfileApi.callApi(Database.loginUserId!);

        AppSettings.showLog("📊 Profile loaded:");
        AppSettings.showLog(
            "  - Profile exists: ${GetProfileApi.profileModel?.user != null}");
        AppSettings.showLog(
            "  - Is blocked: ${GetProfileApi.profileModel?.user?.isBlock}");

        // Wait 2 seconds then navigate
        Timer(const Duration(seconds: 2), () {
          BranchIoServices.onListenBranchIoLinks();
          _navigateToNextScreen();
        });
      } else {
        AppSettings.showLog("👤 User not logged in");

        // Wait 3 seconds then navigate to login
        Timer(const Duration(seconds: 3), () {
          BranchIoServices.onListenBranchIoLinks();
          _navigateToNextScreen();
        });
      }
    } catch (e, stackTrace) {
      AppSettings.showLog("❌ Exception: $e");
      AppSettings.showLog("Stack: $stackTrace");
      Timer(const Duration(seconds: 1), () {
        _showSettingsError();
      });
    }
  }

  void _navigateToNextScreen() {
    AppSettings.showLog("🔀 Determining navigation destination...");

    // ✅ Check if user is logged in with valid profile
    if (Database.loginUserId != null &&
        GetProfileApi.profileModel?.user != null) {
      // Check if user is blocked
      if (GetProfileApi.profileModel?.user?.isBlock == true) {
        AppSettings.showLog("🚫 User is blocked by admin");
        CustomToast.show("You are blocked by admin!");
        Database.logOut();
        Get.offAll(() => const MainHomePageView());
        return;
      }

      // Check if admin settings are loaded
      if (AdminSettingsApi.adminSettingsModel == null) {
        AppSettings.showLog("❌ Admin settings not loaded");
        CustomToast.show("Failed to load settings. Please try again.");
        Get.offAll(() => const MainHomePageView());
        return;
      }

      // ✅ Everything is good - go to home
      AppSettings.showLog("🏠 Navigating to home page");
      Get.offAll(() => const MainHomePageView());
      return;
    }

    // AppSettings.showLog("🏠 Navigating to home page (guest)");
    // Get.offAll(() => const MainHomePageView());

    // ✅ User not logged in - check onboarding status
    if (Database.isNewUser) {
      if (Database.isOnBoarding) {
        AppSettings.showLog("📱 Going to LetsYouIn page");
        Get.offAll(() => const MainHomePageView());
      } else {
        AppSettings.showLog("📱 Going to OnBoarding page");
        Get.offAll(() => const MainHomePageView());
      }
    } else {
      AppSettings.showLog("🔐 Going to Login page");
      Get.offAll(() => const MainHomePageView());
    }
  }

  void _showSettingsError() {
    Get.dialog(
      AlertDialog(
        title: const Text("Connection Error"),
        content: const Text(
          "Failed to load app settings. Please check your internet connection and try again.",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              splashScreen(); // Retry
            },
            child: const Text("Retry"),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              Get.offAll(
                  () => const MainHomePageView()); // ← changed from LoginView
            },
            child: const Text("Continue Anyway"),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    Timer(const Duration(milliseconds: 150), () {
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.light,
          statusBarColor: Colors.transparent,
          systemNavigationBarIconBrightness:
              isDarkMode.value ? Brightness.dark : Brightness.light,
        ),
      );
    });

    AppSettings.showLog(
      "Screen Height => ${Get.height}  Screen Width => ${Get.width}",
    );

    SizeConfig().init(context);

    return Scaffold(
      backgroundColor: isDarkMode.value ? AppColor.mainDark : Colors.white,
      body: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const Offstage(),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Image(
                  image: AssetImage(AppIcons.appLogo),
                  height: 300,
                  width: 300,
                  fit: BoxFit.contain,
                ),
                SizedBox(width: SizeConfig.blockSizeHorizontal * 4),
              ],
            ),
            const SpinKitCircle(
              color: Color(0xFFe7671e),
              size: 60,
            ),
          ],
        ),
      ),
    );
  }
}
