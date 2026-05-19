import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:metube/custom/custom_method/custom_filled_button.dart';
import 'package:metube/custom/custom_method/custom_toast.dart';
import 'package:metube/custom/custom_ui/loader_ui.dart';
import 'package:metube/database/database.dart';
import 'package:metube/main.dart';
import 'package:metube/pages/admin_settings/admin_settings_api.dart';
import 'package:metube/pages/buy_coin_page/api/purchase_coin_plan_api.dart';
import 'package:metube/pages/buy_coin_page/model/purchase_coin_plan_model.dart';
import 'package:metube/pages/profile_page/payment_page/flutter_wave/flutter_wave_services.dart';
import 'package:metube/pages/profile_page/payment_page/in_app_purchase/iap_callback.dart';
import 'package:metube/pages/profile_page/payment_page/in_app_purchase/in_app_purchase_helper.dart';
import 'package:metube/pages/profile_page/payment_page/razor_pay/create_razorpay_order_api.dart';
import 'package:metube/pages/profile_page/payment_page/razor_pay/get_razorpay_config_api.dart';
import 'package:metube/pages/profile_page/payment_page/razor_pay/razor_pay_view.dart';
import 'package:metube/pages/profile_page/payment_page/stripe_pay/stripe_service.dart';
import 'package:metube/utils/colors/app_color.dart';
import 'package:metube/utils/config/size_config.dart';
import 'package:metube/utils/icons/app_icons.dart';
import 'package:metube/utils/settings/app_settings.dart';
import 'package:metube/utils/string/app_string.dart';
import 'package:metube/utils/style/app_style.dart';
import 'package:metube/utils/utils.dart';
import 'package:flutter/foundation.dart';

class CoinPaymentView extends StatefulWidget {
  const CoinPaymentView(
      {super.key,
      required this.amount,
      required this.premiumPlanId,
      required this.productKey});
  final double amount;
  final String premiumPlanId;
  final String productKey;

  @override
  State<CoinPaymentView> createState() => _CoinPaymentViewState();
}

class _CoinPaymentViewState extends State<CoinPaymentView>
    implements IAPCallback {
  Map<String, PurchaseDetails>? purchases;
  bool isClicked = false;
  @override
  void initState() {
    AppSettings.paymentType(AppStrings.razorPay.tr);
    // InAppPurchaseHelper().getAlreadyPurchaseItems(this);
    // purchases = InAppPurchaseHelper().getPurchases();
    // InAppPurchaseHelper().clearTransactions();

    super.initState();
  }

  PurchaseCoinPlanModel? purchaseCoinPlanModel;

  Future<void> onPurchaseCoinPlan({required String paymentGateway}) async {
    Get.dialog(const LoaderUi(), barrierDismissible: false);
    purchaseCoinPlanModel = await PurchaseCoinPlanApi.callApi(
        loginUserId: Database.loginUserId ?? "",
        coinPlanId: widget.premiumPlanId,
        paymentGateway: paymentGateway);
    Get.back();
    if (purchaseCoinPlanModel?.status == true) {
      CustomToast.show("Coin Plan Purchase Success");
      Get.close(2);
    } else {
      CustomToast.show(purchaseCoinPlanModel?.message ?? "");
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarBrightness: Brightness.dark),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
            child: Image.asset(AppIcons.arrowBack,
                    color: isDarkMode.value ? AppColor.white : AppColor.black)
                .paddingOnly(left: 15),
            onTap: () => Get.back()),
        leadingWidth: 33,
        centerTitle: AppSettings.isCenterTitle,
        title: Text(AppStrings.payments.tr,
            style: GoogleFonts.urbanist(
                fontSize: 18, fontWeight: FontWeight.bold)),
      ),
      bottomNavigationBar: CustomFilledButton(
        title: AppStrings.continueString.tr,
        callback: () async {
          Utils.showLog("IS Clicked ==> $isClicked ");
          if (isClicked) {
            return;
          }
          isClicked = true;

          setState(() {});
          // Buy coins: Razorpay only
          final razorpayReady = await GetRazorpayConfigApi.callApi();
            if (!razorpayReady || GetRazorpayConfigApi.keyId == null) {
              CustomToast.show('Razorpay is not available');
              isClicked = false;
              setState(() {});
              return;
            }
            final order = await CreateRazorpayOrderApi.callApi(
              userId: Database.loginUserId ?? '',
              purpose: 'coin_plan',
              coinPlanId: widget.premiumPlanId,
            );
            if (order == null || order.orderId.isEmpty) {
              CustomToast.show('Could not create payment order');
              isClicked = false;
              setState(() {});
              return;
            }
            RazorPayService().init(
              razorKey: order.keyId ?? GetRazorpayConfigApi.keyId!,
              callback: () async {
                AppSettings.showLog('Razorpay verified — coins credited');
                CustomToast.show('Coin Plan Purchase Success');
                Get.close(2);
              },
            );
            await 1.seconds.delay();
            RazorPayService().razorPayCheckout(
              amount: order.amount,
              orderId: order.orderId,
              currency: order.currency,
            );

          // >>>>>>>>>>>>>>>>>>>> Stripe Payment <<<<<<<<<<<<<<<<<<<
          // } else if (AppSettings.paymentType.value == AppStrings.stripe.tr) {
          //   AppSettings.showLog(
          //       "Stripe Payment Success Method Called...sad.${widget.premiumPlanId}::");

          //   await CoinStripeService().init(isTest: true);
          //   await 1.seconds.delay();
          //   CoinStripeService()
          //       .stripePay((widget.amount * 100).toInt(), widget.premiumPlanId);

          //   // >>>>>>>>>>>>>>>>>>>> In App Purchase Payment <<<<<<<<<<<<<<<<<<<
          // } else if (AppSettings.paymentType.value == AppStrings.googlePay.tr) {
          //   // List<String> productKey = <String>[widget.productKey];

          //   List<String> kProductIds = <String>[widget.productKey];
          //   InAppPurchaseHelper().init(
          //     paymentType: "In App Purchase",
          //     userId: Database.loginUserId!,
          //     productKey: kProductIds,
          //     rupee: widget.amount,
          //     callBack: () async {
          //       AppSettings.showLog("In App Purchase Payment Successfully");

          //       await onPurchaseCoinPlan(paymentGateway: "In App Purchase");
          //     },
          //   );
          //   log("Initialization completed");
          //   InAppPurchaseHelper().initStoreInfo();

          //   await Future.delayed(const Duration(seconds: 3));

          //   ProductDetails? product =
          //       InAppPurchaseHelper().getProductDetail(widget.productKey);
          //   log("Product is :: $product");
          //   if (product != null) {
          //     log("Product details retrieved successfully for :: ${product.id}");
          //     InAppPurchaseHelper().buySubscription(product, purchases!);
          //   } else {
          //     log("Product is null for :: ${widget.productKey}");
          //   }
          // } 
          // else if (AppSettings.paymentType.value ==
          //     AppStrings.flutterWave.tr) {
          //   FlutterWaveService.init(
          //     amount: widget.amount.toString(),
          //     onPaymentComplete: () async {
          //       AppSettings.showLog("***** Flutter Wave Payment Success *****");

          //       await onPurchaseCoinPlan(paymentGateway: "Flutter Wave");
          //     },
          //   );
          // } else {
          //   AppSettings.showLog("Please Select Payment Type");
          //   CustomToast.show("Please select payment type");
          // }


          await Future.delayed(const Duration(seconds: 3));

          isClicked = false;
          setState(() {});
        },
      ).paddingAll(20),
      body: Stack(children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: SizeConfig.blockSizeVertical * 2),
            Text(
              AppStrings.paymentNote.tr,
              style: GoogleFonts.urbanist(
                  fontSize: 14, fontWeight: FontWeight.w500),
            ).paddingOnly(left: 20),
            SizedBox(height: SizeConfig.blockSizeVertical * 2),
            PaymentItemView(
              title: AppStrings.razorPay.tr,
              leading: AppIcons.razorPay,
              iconSize: 40,
            ),
            // ((AdminSettingsApi.adminSettingsModel?.setting!.googlePlaySwitch ??
            //             false) &&
            //         Platform.isAndroid)
            //     ? PaymentItemView(
            //         title: AppStrings.googlePay.tr,
            //         leading: AppIcons.googleLogo,
            //         iconSize: 25,
            //       )
            //     : const Offstage(),
            // ((AdminSettingsApi.adminSettingsModel?.setting!.googlePlaySwitch ??
            //             false) &&
            //         !kIsWeb && Platform.isIOS)
            //     ? PaymentItemView(
            //         title: AppStrings.applePay.tr,
            //         leading: AppIcons.appleLogo,
            //         iconSize: 25,
            //       )
            //     : const Offstage(),
            // (AdminSettingsApi.adminSettingsModel?.setting?.stripeSwitch ??
            //         false)
            //     ? PaymentItemView(
            //         title: AppStrings.stripe.tr,
            //         leading: AppIcons.stripe,
            //         iconSize: 45,
            //       )
            //     : const Offstage(),
            // (AdminSettingsApi.adminSettingsModel?.setting?.flutterWaveSwitch ??
            //         false)
            //     ? PaymentItemView(
            //         title: AppStrings.flutterWave.tr,
            //         leading: AppIcons.flutterWaveIcon,
            //         iconSize: 45,
            //       )
            //     : const Offstage(),
            SizedBox(height: SizeConfig.blockSizeVertical * 2),
            const Spacer(),
            SizedBox(height: SizeConfig.blockSizeVertical * 3),
          ],
        ),
        if (isClicked)
          const Center(
            child: LoaderUi(), // Your loader widget
          ),
      ]),
    );
  }

  @override
  void onBillingError(error) {}

  @override
  void onLoaded(bool initialized) {}

  @override
  void onPending(PurchaseDetails product) {}

  @override
  void onSuccessPurchase(PurchaseDetails product) {}
}

class PaymentItemView extends StatelessWidget {
  const PaymentItemView(
      {super.key,
      required this.title,
      required this.leading,
      required this.iconSize});

  final String title;
  final String leading;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => AppSettings.paymentType(title),
      child: Container(
        height: 65,
        width: Get.width,
        margin: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
        decoration: BoxDecoration(
          color: isDarkMode.value ? AppColor.secondDarkMode : AppColor.grey_100,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: ListTile(
          leading: SizedBox(
              width: 50,
              child: Center(
                  child: Image(
                      image: AssetImage(leading),
                      height: iconSize,
                      width: iconSize))),
          title: Text(title, style: paymentNameStyle),
          trailing: Obx(
            () => Radio(
              fillColor: WidgetStateColor.resolveWith(
                  (states) => AppColor.primaryColor),
              activeColor: AppColor.primaryColor,
              value: title,
              groupValue: AppSettings.paymentType.value,
              onChanged: (value) => AppSettings.paymentType(value),
            ),
          ),
        ),
      ),
    );
  }
}
