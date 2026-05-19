import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:metube/pages/admin_settings/admin_settings_api.dart';
import 'package:metube/pages/admin_settings/admin_settings_model.dart';
import 'package:metube/utils/icons/app_icons.dart';
import 'package:metube/utils/parse_setting_bool.dart';
import 'package:metube/utils/settings/app_settings.dart';
import 'package:metube/utils/string/app_string.dart';

extension PaymentGatewaySetting on Setting {
  bool get isRazorPayEnabled => parseSettingBool(razorPaySwitch);
  bool get isStripeEnabled => parseSettingBool(stripeSwitch);
  bool get isFlutterWaveEnabled => parseSettingBool(flutterWaveSwitch);
  bool get isGooglePlayEnabled => parseSettingBool(googlePlaySwitch);
}

class PaymentMethodOption {
  const PaymentMethodOption({
    required this.title,
    required this.leading,
    required this.iconSize,
  });

  final String title;
  final String leading;
  final double iconSize;
}

List<PaymentMethodOption> availablePaymentMethods() {
  final setting = AdminSettingsApi.adminSettingsModel?.setting;
  if (setting == null) return [];

  final methods = <PaymentMethodOption>[];

  if (setting.isRazorPayEnabled) {
    methods.add(PaymentMethodOption(
      title: AppStrings.razorPay.tr,
      leading: AppIcons.razorPay,
      iconSize: 40,
    ));
  }

  if (setting.isGooglePlayEnabled && !kIsWeb && Platform.isAndroid) {
    methods.add(PaymentMethodOption(
      title: AppStrings.googlePay.tr,
      leading: AppIcons.googleLogo,
      iconSize: 25,
    ));
  }

  if (setting.isGooglePlayEnabled && !kIsWeb && Platform.isIOS) {
    methods.add(PaymentMethodOption(
      title: AppStrings.applePay.tr,
      leading: AppIcons.appleLogo,
      iconSize: 25,
    ));
  }

  if (setting.isStripeEnabled) {
    methods.add(PaymentMethodOption(
      title: AppStrings.stripe.tr,
      leading: AppIcons.stripe,
      iconSize: 45,
    ));
  }

  if (setting.isFlutterWaveEnabled) {
    methods.add(PaymentMethodOption(
      title: AppStrings.flutterWave.tr,
      leading: AppIcons.flutterWaveIcon,
      iconSize: 45,
    ));
  }

  return methods;
}

void selectDefaultPaymentMethodIfNeeded() {
  final methods = availablePaymentMethods();
  if (methods.isEmpty) return;

  final current = AppSettings.paymentType.value;
  final titles = methods.map((m) => m.title).toSet();
  if (current.isEmpty || !titles.contains(current)) {
    AppSettings.paymentType(methods.first.title);
  }
}
