import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:metube/custom/custom_method/custom_toast.dart';
import 'package:metube/database/database.dart';
import 'package:metube/pages/admin_settings/admin_settings_api.dart';
import 'package:metube/pages/login_related_page/fill_profile_page/get_profile_model.dart';
import 'package:metube/pages/login_related_page/fill_profile_page/get_profile_modell.dart';
import 'package:metube/pages/profile_page/premium_plan_page/premium_plan_view.dart';
import 'package:metube/utils/constant/app_constant.dart';
import 'package:metube/utils/services/convert_to_network.dart';
import 'package:metube/utils/settings/app_settings.dart';

class GetProfileApi {
  static GetProfileModel? profileModel;
  static Future<void> callApi(String loginUserId) async {
    AppSettings.showLog("GetProfile Api Calling... $loginUserId");

    final uri = Uri.parse(
        "${Constant.baseURL + Constant.getProfile}?userId=$loginUserId");

    AppSettings.showLog("GetProfile Api Calling... $uri");

    final headers = {"key": Constant.secretKey};

    try {
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        profileModel = GetProfileModel.fromJson(jsonResponse);

        if (profileModel != null) {
          Database.onSetIsNewUser(false);
          Database.onSetLoginUserId(profileModel!.user!.id!);

          // Save referral code locally
          await Database.onSetReferralCode(
            profileModel?.user?.referralCode ?? "",
          );

          AppSettings.channelName.value = profileModel?.user?.fullName ?? "";

          AppSettings.isShowAds =
              ((GetProfileApi.profileModel?.user?.isPremiumPlan == false) &&
                  (AdminSettingsApi.adminSettingsModel?.setting?.isGoogle ??
                      false)); // if Premium Plan Not Perches then show ads

          if (profileModel!.user!.channelId != null &&
              profileModel!.user!.isChannel != null) {
            Database.onSetChannelId(profileModel!.user!.channelId!);
            Database.onSetIsChannel(profileModel!.user!.isChannel!);
          }
          final rawImage = profileModel?.user?.image?.trim() ?? '';
          if (rawImage.isNotEmpty) {
            final image = ConvertToNetwork.resolve(rawImage);
            AppSettings.showLog("Profile Image => $image");
            if (image.isNotEmpty) {
              await Database.onSetProfileImage(image);
              AppSettings.profileImage.value = image;
            }
          }
          _syncBadgeFromProfile();
        }
        AppSettings.showLog("GetProfile Response => ${response.body}");
      } else {
        AppSettings.showLog("GetProfile StateCode Error");
      }
    } catch (error) {
      AppSettings.showLog("GetProfile Api Error => $error");
    }
  }

  static void _syncBadgeFromProfile() {
    final user = profileModel?.user;

    print("==== BADGE SYNC START ====");
    print("user is null: ${user == null}");
    print("isPremiumPlan => ${user?.isPremiumPlan}");
    print("plan is null: ${user?.plan == null}");
    print("plan.productKey => ${user?.plan?.productKey}");
    print("plan.premiumPlanId => ${user?.plan?.premiumPlanId}");
    print("plan.amount => ${user?.plan?.amount}");
    print("==========================");

    if (user?.isPremiumPlan == true) {
      final productKey = user?.plan?.productKey ?? "";
      print("productKey to map: '$productKey'");
      String badge = _getBadgeLabel(productKey);
      print("badge result: '$badge'");
      if (badge.isEmpty) {
        badge = _getBadgeLabelFromAmount(user?.plan?.amount ?? 0);
      }

      if (badge.isNotEmpty) {
        Database.onSetPurchasedPlan(productKey, badge);
        print("✅ Badge saved: $badge");
      } else {
        print("❌ No badge mapped — productKey '$productKey' not in badgeMap");
      }
    } else {
      String? oldBadge = Database.purchasedPlanBadge;
      if (oldBadge != null && oldBadge != 'Creator' && oldBadge != '') {
        Database.onSetPurchasedPlan("", "Creator");
        CustomToast.show("Your premium plan has expired.");
        Get.to(() => PremiumPlanView());
        print("Premium plan expired — badge reset and redirected");
      } else {
        Database.onSetPurchasedPlan("", "Creator");
        print("No premium plan — badge set to default Creator");
      }
    }
    print("==========================");
  }

  static String _getBadgeLabelFromAmount(int amount) {
    if (amount == 499) return 'Business';
    if (amount == 999) return 'Influencer';
    if (amount == 1999) return 'Celebrity';
    return '';
  }

  static String _getBadgeLabel(String productKey) {
    const badgeMap = {
      'business_plan_30d': 'Business',
      'influencer_plan_30d': 'Influencer',
      'celebrity_plan_30d': 'Celebrity',
    };
    return badgeMap[productKey] ?? '';
  }
}
