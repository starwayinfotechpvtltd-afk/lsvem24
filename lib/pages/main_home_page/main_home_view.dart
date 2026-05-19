import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart'; // ✅ Added
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:metube/custom/basic_button.dart';
import 'package:metube/custom/custom_method/custom_check_internet.dart';
import 'package:metube/custom/custom_method/custom_toast.dart';
import 'package:metube/custom/custom_method/custom_video_picker.dart';
import 'package:metube/custom/custom_method/custom_video_size.dart';
import 'package:metube/database/database.dart';
import 'package:metube/main.dart';
import 'package:metube/pages/admin_settings/admin_settings_api.dart';
import 'package:metube/pages/custom_pages/comment_page/comment_controller.dart';
import 'package:metube/pages/custom_pages/comment_page/reply_controller.dart';
import 'package:metube/pages/nav_add_page/create_short_page/create_short_controller.dart';
import 'package:metube/pages/nav_add_page/create_short_page/create_short_view.dart';
import 'package:metube/pages/nav_add_page/live_page/go_live_page/view/go_live_view.dart';
import 'package:metube/pages/nav_add_page/live_page/widget/socket_manager_controller.dart';
import 'package:metube/pages/nav_add_page/upload_video_page/upload_video_controller.dart';
import 'package:metube/pages/nav_add_page/upload_video_page/upload_video_view.dart';
import 'package:metube/pages/nav_home_page/controller/nav_home_controller.dart';
import 'package:metube/pages/nav_home_page/view/nav_home_page.dart';
import 'package:metube/pages/nav_library_page/download_page/download_view.dart';
import 'package:metube/pages/nav_library_page/main_page/nav_library_controller.dart';
import 'package:metube/pages/nav_library_page/main_page/nav_library_page.dart';
import 'package:metube/pages/nav_shorts_page/nav_shorts_controller.dart';
import 'package:metube/pages/nav_shorts_page/nav_shorts_view.dart';
import 'package:metube/pages/nav_subscription_page/nav_subscription_controller.dart';
import 'package:metube/pages/nav_subscription_page/nav_subscription_view.dart';
import 'package:metube/pages/notification_page/notification_controller.dart';
import 'package:metube/pages/profile_page/convert_coin_page/get_my_coin_api.dart';
import 'package:metube/pages/profile_page/main_page/profile_controller.dart';
import 'package:metube/pages/profile_page/withdraw_page/withdraw_setting_api.dart';
import 'package:metube/pages/profile_page/your_channel_page/main_page/your_channel_controller.dart';
import 'package:metube/pages/search_page/search_controller.dart';
import 'package:metube/pages/search_page/search_view.dart';
import 'package:metube/pages/video_details_page/normal_video_details_view.dart';
import 'package:metube/pages/video_details_page/shorts_video_details_view.dart';
import 'package:metube/utils/branch_io_services.dart';
import 'package:metube/utils/colors/app_color.dart';
import 'package:metube/utils/config/size_config.dart';
import 'package:metube/utils/icons/app_icons.dart';
import 'package:metube/utils/settings/app_settings.dart';
import 'package:metube/utils/string/app_string.dart';
import 'package:metube/utils/style/app_style.dart';
import 'package:metube/utils/utils.dart';
import 'package:quick_actions/quick_actions.dart';
import 'package:video_player/video_player.dart';
import 'package:metube/utils/auth/auth_service.dart';

final List navigationPages = [
  const NavHomePageView(),
  const NavShortsView(),
  const NavSubscriptionView(),
  const NavLibraryView(),
];

class MainHomePageView extends StatefulWidget {
  const MainHomePageView({super.key});

  @override
  State<MainHomePageView> createState() => _MainHomePageViewState();
}

class _MainHomePageViewState extends State<MainHomePageView> {
  final quickAction = const QuickActions();
  VideoPlayerController? _homeVideoController;
  bool _isVideoInitialized = false;
  bool _adsPreloaded = false;

  // ✅ Safe platform getters
  bool get _isAndroid => !kIsWeb && Platform.isAndroid;
  bool get _isIOS => !kIsWeb && Platform.isIOS;

  @override
  void initState() {
    Timer(const Duration(milliseconds: 300), () {
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.light,
          statusBarColor: Colors.transparent,
          systemNavigationBarDividerColor: Colors.black,
          systemNavigationBarColor: Colors.black,
        ),
      );
    });

    if (AdminSettingsApi.adminSettingsModel == null) {
      AdminSettingsApi.callApi();
      AppSettings.showLog("Admin Api Second Time Calling...");
    }
    Get.put(NavHomeController());
    Get.put(ProfileController());
    Get.put(NavShortsController());
    Get.put(NavSubscriptionPageController());
    Get.put(NavLibraryPageController());
    Get.put(UploadVideoController());
    Get.put(CommentController());
    Get.put(RepliesController());
    Get.put(YourChannelController());
    Get.put(SearchingController());
    Get.put(NotificationController());
    Get.put(CreateShortController());

    final socketManagerController = Get.put(SocketManagerController());
    socketManagerController.socketConnect();

    WithdrawSettingApi.callApi(loginUserId: Database.loginUserId ?? "");
    AppSettings.onCreateLink();
    GetMyCoinApi.callApi(loginUserId: Database.loginUserId ?? "");

    Timer(const Duration(milliseconds: 300), () {
      if (BranchIoServices.pageRoutes == "NormalVideo") {
        Get.to(NormalVideoDetailsView(
            videoId: BranchIoServices.videoId, videoUrl: BranchIoServices.url));
      } else if (BranchIoServices.pageRoutes == "ShortsVideo") {
        Get.to(() => ShortsVideoDetailsView(
            videoId: BranchIoServices.videoId, videoUrl: BranchIoServices.url));
      }
    });

    Utils.showLog("INTERNET LAGGG");
    Timer(const Duration(milliseconds: 100), () {
      if (!CustomCheckInternet.isConnect.value) {
        AppSettings.navigationIndex.value = 3;
        Get.to(const DownloadView());
      }
    });

    super.initState();

    // ✅ QuickActions only supported on Android/iOS, not web
    if (!kIsWeb) {
      quickAction.setShortcutItems([
        const ShortcutItem(
          type: 'Subscriptions',
          localizedTitle: 'Subscriptions',
          icon: "subscription",
        ),
        const ShortcutItem(
          type: 'Search',
          localizedTitle: 'Search',
          icon: "search",
        ),
        const ShortcutItem(
          type: 'Shorts',
          localizedTitle: 'Shorts',
          icon: "shorts",
        ),
      ]);

      quickAction.initialize((type) {
        if (type == 'Subscriptions') {
          AppSettings.navigationIndex.value = 2;
        } else if (type == 'Search') {
          Get.to(const SearchView(isSearchShorts: false));
        } else if (type == 'Shorts') {
          AppSettings.navigationIndex.value = 1;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(top: 55),
        child: FloatingActionButton(
          heroTag: null,
          hoverColor: Colors.transparent,
          hoverElevation: 0,
          highlightElevation: 0,
          splashColor: Colors.transparent,
          foregroundColor: Colors.transparent,
          focusColor: Colors.transparent,
          elevation: 0,
          backgroundColor: Colors.transparent,
          onPressed: () async {
            Get.bottomSheet(
              elevation: 0,
              backgroundColor:
                  isDarkMode.value ? AppColor.secondDarkMode : AppColor.white,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(30),
                  topLeft: Radius.circular(30),
                ),
              ),
              SizedBox(
                // ✅ Safe height — iOS gets 350, others get 330
                height: _isIOS ? 350 : 330,
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
                    const SizedBox(height: 16),
                    Text(AppStrings.create.tr, style: titalstyle1),
                    const SizedBox(height: 8),
                    Divider(
                        indent: 25,
                        endIndent: 25,
                        color: AppColor.grey_200),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            const SizedBox(height: 8),
                            CreateShortsOption(
                              logo: AppIcons.boldVideo,
                              option: AppStrings.createAShort.tr,
                              onTap: () {
                                if (!AuthService.checkLogin()) return;
                                Get.back();
                                if (AppSettings.isUploading.value) {
                                  CustomToast.show(
                                      "Already video upload running !!");
                                } else {
                                  Get.to(() => CreateShortView());
                                }
                              },
                            ),
                            CreateShortsOption(
                              logo: AppIcons.boldUpload,
                              option: AppStrings.uploadAVideo.tr,
                              onTap: () async {
                                if (!AuthService.checkLogin()) return;
                                Get.back();
                                if (AppSettings.isUploading.value) {
                                  CustomToast.show(
                                      "Already video upload running !!");
                                } else {
                                  AppSettings.showLog(
                                      "Upload View Bottom Sheet On Click");
                                  final pickedVideo =
                                      await CustomVideoPicker.pickVideo();
                                  if (pickedVideo != null) {
                                    AppSettings.showLog(
                                        "Picked Video Url => $pickedVideo");
                                    final response =
                                        await isSupport(pickedVideo);
                                    if (response) {
                                      final videoSize =
                                          await CustomVideoSize.onGet(
                                              pickedVideo);
                                      AppSettings.showLog(
                                          "Picked Video Size => $videoSize");
                                      Get.to(
                                        UploadVideoView(
                                          videoPath: pickedVideo,
                                          loginUserId:
                                              Database.loginUserId ?? "",
                                          loginUserChannelId:
                                              Database.channelId ?? "",
                                          videoType: 1,
                                        ),
                                      );
                                    } else {
                                      CustomToast.show(
                                          AppStrings.videoNotSupport.tr);
                                    }
                                  }
                                }
                              },
                            ),
                            CreateShortsOption(
                              logo: AppIcons.boldPlay,
                              option: AppStrings.goLive.tr,
                              onTap: () async {
                                if (!AuthService.checkLogin()) return;
                                Get.back();
                                if (socket?.connected ?? false) {
                                  Get.to(const GoLiveView());
                                } else {
                                  CustomToast.show(
                                      AppStrings.connectionIssue.tr);
                                }
                              },
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ),
                    // ✅ Extra bottom padding only on non-Android native
                    _isAndroid
                        ? const Offstage()
                        : const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
          child: Container(
            height: 50,
            width: 50,
            margin: const EdgeInsets.only(top: 5),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColor.primaryColor,
            ),
            child: const Icon(Icons.add, color: AppColor.white),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      backgroundColor:
          isDarkMode.value ? AppColor.mainDark : AppColor.white,
      bottomNavigationBar: Obx(
        () => Container(
          // ✅ Safe height — iOS taller, Android shorter, web uses fixed height
          height: _isIOS
              ? Get.height / 9.5
              : _isAndroid
                  ? Get.height / 13.1
                  : 60, // web fallback
          width: Get.width,
          decoration: BoxDecoration(
            color: isDarkMode.value ? AppColor.mainDark : Colors.white,
            boxShadow: [
              BoxShadow(
                color: AppColor.black.withOpacity(0.3),
                blurRadius: 1.5,
                offset: const Offset(0.5, 0.5),
                spreadRadius: 0.3,
              )
            ],
          ),
          child: Row(
            children: [
              BottomBarItemUi(
                activeIcon: AppIcons.boldHome,
                icon: AppIcons.homeLogo,
                title: AppStrings.home.tr,
                index: 0,
              ),
              BottomBarItemUi(
                activeIcon: AppIcons.boldVideo,
                icon: AppIcons.video,
                title: AppStrings.shorts.tr,
                index: 1,
              ),
              const Expanded(child: Offstage()),
              BottomBarItemUi(
                activeIcon: AppIcons.boldPlay,
                icon: AppIcons.videoCircle,
                title: AppStrings.subscription.tr,
                index: 2,
              ),
              BottomBarItemUi(
                activeIcon: AppIcons.boldLibrary,
                icon: AppIcons.libraryLogo,
                title: AppStrings.library.tr,
                index: 3,
              ),
            ],
          ),
        ),
      ),
      body: PageView.builder(
        itemCount: navigationPages.length,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) => Obx(
            () => navigationPages[AppSettings.navigationIndex.value]),
      ),
    );
  }
}

// ✅ isSupport also uses dart:io File — guard for web
Future<bool> isSupport(String path) async {
  if (kIsWeb) return true; // Can't validate via VideoPlayerController.file on web
  try {
    final VideoPlayerController controller =
        VideoPlayerController.file(File(path));
    await controller.initialize();
    final initialized = controller.value.isInitialized;
    await controller.dispose();
    return initialized;
  } catch (e) {
    return false;
  }
}

class BottomBarItemUi extends StatelessWidget {
  const BottomBarItemUi({
    super.key,
    required this.icon,
    required this.title,
    required this.index,
    required this.activeIcon,
  });

  final String activeIcon;
  final String icon;
  final String title;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: GestureDetector(
        onTap: () => AppSettings.navigationIndex.value = index,
        child: Obx(
          () => Container(
            height: 60,
            width: 50,
            color: Colors.transparent,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  AppSettings.navigationIndex.value == index
                      ? activeIcon
                      : icon,
                  height: 22,
                  width: 22,
                  color: AppSettings.navigationIndex.value == index
                      ? AppColor.primaryColor
                      : AppColor.grey,
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: GoogleFonts.urbanist(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppSettings.navigationIndex.value == index
                        ? AppColor.primaryColor
                        : AppColor.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}