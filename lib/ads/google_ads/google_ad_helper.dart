import 'dart:io';

import 'package:flutter/foundation.dart'; // ✅ import kIsWeb
import 'package:metube/pages/admin_settings/admin_settings_api.dart';

class GoogleAdHelper {
  static String get nativeAdUnitId {
    if (kIsWeb) return ""; // ✅ Web doesn't support Google Mobile Ads
    if (Platform.isAndroid) {
      return AdminSettingsApi.adminSettingsModel?.setting?.android?.google?.native ?? "";
    } else if (Platform.isIOS) {
      return AdminSettingsApi.adminSettingsModel?.setting?.ios?.google?.native ?? "";
    } else {
      return "";
    }
  }

  static String get nativeVideoAdUnitId {
    if (kIsWeb) return "";
    if (Platform.isAndroid) {
      return AdminSettingsApi.adminSettingsModel?.setting?.android?.google?.nativeAdVideo ?? "";
    } else if (Platform.isIOS) {
      return AdminSettingsApi.adminSettingsModel?.setting?.ios?.google?.nativeAdVideo ?? "";
    } else {
      return "";
    }
  }

  static String get interstitialAdUnitId {
    if (kIsWeb) return "";
    if (Platform.isAndroid) {
      return AdminSettingsApi.adminSettingsModel?.setting?.android?.google?.interstitial ?? "";
    } else if (Platform.isIOS) {
      return AdminSettingsApi.adminSettingsModel?.setting?.ios?.google?.interstitial ?? "";
    } else {
      return "";
    }
  }

  static String get rewardedAd {
    if (kIsWeb) return "";
    return Platform.isAndroid
        ? (AdminSettingsApi.adminSettingsModel?.setting?.android?.google?.reward ?? "")
        : Platform.isIOS
            ? (AdminSettingsApi.adminSettingsModel?.setting?.ios?.google?.reward ?? "")
            : "";
  }

  static String get googleVideoAd {
    if (kIsWeb) return "";
    return Platform.isAndroid
        ? (AdminSettingsApi.adminSettingsModel?.setting?.android?.google?.videoAdUrl ?? "")
        : Platform.isIOS
            ? (AdminSettingsApi.adminSettingsModel?.setting?.android?.google?.videoAdUrl ?? "")
            : "";
  }
}