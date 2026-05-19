import 'dart:convert';
import 'dart:developer';

import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_typedefs/rx_typedefs.dart';
import 'package:http/http.dart' as http;
import 'package:metube/custom/custom_method/custom_toast.dart';
import 'package:metube/database/database.dart';
import 'package:metube/pages/buy_coin_page/api/purchase_coin_plan_api.dart';
import 'package:metube/pages/buy_coin_page/model/purchase_coin_plan_model.dart';
import 'package:metube/pages/profile_page/payment_page/stripe_pay/stripe_pay_model.dart';
import 'package:metube/pages/profile_page/premium_plan_page/create_premium_plan_api.dart';
import 'package:metube/utils/colors/app_color.dart';
import 'package:metube/utils/settings/app_settings.dart';
import 'package:metube/utils/string/app_string.dart';

class StripeService {
  bool isTest = false;
  Callback onComplete = () {};

  init({
    required bool isTest,
    required Callback callback,
  }) async {
    Stripe.publishableKey = AppStrings.stripeTestPublicKey;
    Stripe.merchantIdentifier = 'merchant.flutter.stripe.test';
    await Stripe.instance.applySettings().catchError((e) {
      log("Stripe Apply Settings => $e");
      throw e.toString();
    });

    this.isTest = isTest;
    onComplete = () => callback.call();
  }

  Future<dynamic> stripePay(int amount, String premiumPlanId) async {
    log("*********-$premiumPlanId");

    try {
      Map<String, dynamic> body = {
        'amount': amount.toString(),
        'currency': AppStrings.stripeCurrencyCode,
        'description': 'Name: "omSai" - Email: "omsai@gmail.com"',
      };

      log("Start Payment Intent Http Request.....");

      var response = await http.post(Uri.parse(AppStrings.stripeUrl),
          body: body, headers: {"Authorization": "Bearer ${AppStrings.stripeTestSecretKey}", "Content-Type": 'application/x-www-form-urlencoded'});

      log("End Payment Intent Http Request.....");

      log("Payment Intent Http Response => ${response.body}");

      if (response.statusCode == 200) {
        StripePayModel result = StripePayModel.fromJson(jsonDecode(response.body));

        log("Stripe Payment Response => $result");

        SetupPaymentSheetParameters setupPaymentSheetParameters = SetupPaymentSheetParameters(
          paymentIntentClientSecret: result.clientSecret,
          appearance: const PaymentSheetAppearance(colors: PaymentSheetAppearanceColors(primary: AppColor.primaryColor)),
          applePay: PaymentSheetApplePay(merchantCountryCode: AppStrings.stripeMerchantCountryCode),
          googlePay: PaymentSheetGooglePay(merchantCountryCode: AppStrings.stripeMerchantCountryCode, testEnv: isTest),
          merchantDisplayName: AppStrings.appName,
          customerId: Database.loginUserId,
          billingDetails: const BillingDetails(name: "Hello", email: "hello@gmail.com"),
        );

        await Stripe.instance.initPaymentSheet(paymentSheetParameters: setupPaymentSheetParameters).then((value) async {
          await Stripe.instance.presentPaymentSheet().then((value) async {
            log("***** Payment Done *****");
            // onComplete();
            AppSettings.showLog("Stripe Payment Success Method Called....");
            AppSettings.showLog("Stripe Payment Successfully");
            await CreatePremiumPlanApi.callApi(Database.loginUserId!, premiumPlanId, "Stripe");
          }).catchError((e) {
            log("Init Payment Sheet Error => $e");
          });
        }).catchError((e) {
          log("Something Went Wrong => $e");
        });
      } else if (response.statusCode == 401) {
        // appStore.setLoading(false);
        log("Error During Stripe Payment");
      }
      return jsonDecode(response.body);
    } catch (e) {
      log('Error Charging User: ${e.toString()}');
    }
  }
}

class CoinStripeService {
  static PurchaseCoinPlanModel? purchaseCoinPlanModel;

  bool isTest = false;

  init({
    required bool isTest,
  }) async {
    Stripe.publishableKey = AppStrings.stripeTestPublicKey;
    Stripe.merchantIdentifier = 'merchant.flutter.stripe.test';
    await Stripe.instance.applySettings().catchError((e) {
      log("Stripe Apply Settings => $e");
      throw e.toString();
    });

    this.isTest = isTest;
  }

  Future<dynamic> stripePay(int amount, String premiumPlanId) async {
    log("*********-$premiumPlanId");

    try {
      Map<String, dynamic> body = {
        'amount': amount.toString(),
        'currency': AppStrings.stripeCurrencyCode,
        'description': 'Name: "omSai" - Email: "omsai@gmail.com"',
      };

      log("Start Payment Intent Http Request.....");

      var response = await http.post(Uri.parse(AppStrings.stripeUrl),
          body: body, headers: {"Authorization": "Bearer ${AppStrings.stripeTestSecretKey}", "Content-Type": 'application/x-www-form-urlencoded'});

      log("End Payment Intent Http Request.....");

      log("Payment Intent Http Response => ${response.body}");

      if (response.statusCode == 200) {
        StripePayModel result = StripePayModel.fromJson(jsonDecode(response.body));

        log("Stripe Payment Response => $result");

        SetupPaymentSheetParameters setupPaymentSheetParameters = SetupPaymentSheetParameters(
          paymentIntentClientSecret: result.clientSecret,
          appearance: const PaymentSheetAppearance(colors: PaymentSheetAppearanceColors(primary: AppColor.primaryColor)),
          applePay: PaymentSheetApplePay(merchantCountryCode: AppStrings.stripeMerchantCountryCode),
          googlePay: PaymentSheetGooglePay(merchantCountryCode: AppStrings.stripeMerchantCountryCode, testEnv: isTest),
          merchantDisplayName: AppStrings.appName,
          customerId: Database.loginUserId,
          billingDetails: const BillingDetails(name: "Hello", email: "hello@gmail.com"),
        );

        await Stripe.instance.initPaymentSheet(paymentSheetParameters: setupPaymentSheetParameters).then((value) async {
          await Stripe.instance.presentPaymentSheet().then((value) async {
            log("***** Payment Done *****");

            await CreatePremiumPlanApi.callApi(Database.loginUserId!, premiumPlanId, "Stripe");
            purchaseCoinPlanModel = await PurchaseCoinPlanApi.callApi(loginUserId: Database.loginUserId ?? "", coinPlanId: premiumPlanId, paymentGateway: "Stripe");

            if (purchaseCoinPlanModel?.status == true) {
              CustomToast.show("Coin Plan Purchase Success");
              Get.close(2);
            } else {
              CustomToast.show(purchaseCoinPlanModel?.message ?? "");
            }
          }).catchError((e) {
            log("Init Payment Sheet Error => $e");
          });
        }).catchError((e) {
          log("Something Went Wrong => $e");
        });
      } else if (response.statusCode == 401) {
        // appStore.setLoading(false);
        log("Error During Stripe Payment");
      }
      return jsonDecode(response.body);
    } catch (e) {
      log('Error Charging User: ${e.toString()}');
    }
  }
}
