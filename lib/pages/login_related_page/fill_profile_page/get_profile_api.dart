import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:metube/database/database.dart';
import 'package:metube/pages/admin_settings/admin_settings_api.dart';
import 'package:metube/pages/login_related_page/fill_profile_page/get_profile_model.dart';
import 'package:metube/pages/login_related_page/fill_profile_page/get_profile_modell.dart';
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
          if (profileModel?.user?.image != null) {
            String image =
                await ConvertToNetwork.convert(profileModel!.user!.image!);

            AppSettings.showLog("Profile Image => $image");
            Database.onSetProfileImage(image);
            AppSettings.profileImage.value = image;
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
      Database.purchasedPlanBadgeRx.value = "";
      print("No premium plan — badge cleared");
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
