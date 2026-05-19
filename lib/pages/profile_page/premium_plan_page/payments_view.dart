import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:metube/custom/custom_method/custom_filled_button.dart';
import 'package:metube/custom/custom_method/custom_toast.dart';
import 'package:metube/database/database.dart';
import 'package:metube/main.dart';
import 'package:metube/custom/custom_ui/loader_ui.dart';
import 'package:metube/pages/admin_settings/admin_settings_api.dart';
import 'package:metube/pages/profile_page/payment_page/flutter_wave/flutter_wave_services.dart';
import 'package:metube/pages/profile_page/premium_plan_page/payment_gateway_helper.dart';
import 'package:metube/pages/profile_page/payment_page/in_app_purchase/iap_callback.dart';
import 'package:metube/pages/profile_page/payment_page/in_app_purchase/in_app_purchase_helper.dart';
import 'package:metube/pages/login_related_page/fill_profile_page/get_profile_api.dart';
import 'package:metube/pages/main_home_page/main_home_view.dart';
import 'package:metube/pages/profile_page/payment_page/razor_pay/create_razorpay_order_api.dart';
import 'package:metube/pages/profile_page/payment_page/razor_pay/get_razorpay_config_api.dart';
import 'package:metube/pages/profile_page/payment_page/razor_pay/razor_pay_view.dart';
import 'package:metube/pages/profile_page/payment_page/stripe_pay/stripe_service.dart';
import 'package:metube/pages/profile_page/premium_plan_page/create_premium_plan_api.dart';
import 'package:metube/utils/colors/app_color.dart';
import 'package:metube/utils/config/size_config.dart';
import 'package:metube/utils/icons/app_icons.dart';
import 'package:metube/utils/settings/app_settings.dart';
import 'package:metube/utils/string/app_string.dart';
import 'package:metube/utils/style/app_style.dart';
import 'package:metube/utils/utils.dart';

class PaymentView extends StatefulWidget {
  const PaymentView(
      {super.key,
      required this.amount,
      required this.premiumPlanId,
      required this.productKey});
  final double amount;
  final String premiumPlanId;
  final String productKey;

  @override
  State<PaymentView> createState() => _PaymentViewState();
}

class _PaymentViewState extends State<PaymentView> implements IAPCallback {
  Map<String, PurchaseDetails>? purchases;
  bool isClicked = false;
  bool _loadingSettings = true;

  @override
  void initState() {
    super.initState();
    InAppPurchaseHelper().getAlreadyPurchaseItems(this);
    purchases = InAppPurchaseHelper().getPurchases();
    InAppPurchaseHelper().clearTransactions();
    _loadPaymentSettings();
  }

  Future<void> _loadPaymentSettings() async {
    await AdminSettingsApi.callApi();
    selectDefaultPaymentMethodIfNeeded();
    if (mounted) {
      setState(() => _loadingSettings = false);
    }
  }

  String _getBadgeLabel(String productKey) {
    const badgeMap = {
      'business_plan_30d': 'Business',
      'influencer_plan_30d': 'Influencer',
      'celebrity_plan_30d': 'Celebrity',
    };
    return badgeMap[productKey] ?? '';
  }

  Future<void> _saveBadgeAfterPurchase() async {
    final badge = _getBadgeLabel(widget.productKey);
    if (badge.isNotEmpty) {
      await Database.onSetPurchasedPlan(widget.productKey, badge);
    }
  }

  @override
  Widget build(BuildContext context) {
    final paymentMethods = availablePaymentMethods()
    .where((method) => method.title == AppStrings.razorPay.tr)
    .toList();

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
          // >>>>>>>>>>>>>>>>>>>> Razor Payment <<<<<<<<<<<<<<<<<<<
          if (AppSettings.paymentType.value == AppStrings.razorPay.tr) {
            final razorpayReady = await GetRazorpayConfigApi.callApi();
            if (!razorpayReady || GetRazorpayConfigApi.keyId == null) {
              CustomToast.show('Razorpay is not available');
              isClicked = false;
              setState(() {});
              return;
            }
            final order = await CreateRazorpayOrderApi.callApi(
              userId: Database.loginUserId!,
              purpose: 'premium_plan',
              premiumPlanId: widget.premiumPlanId,
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
                AppSettings.showLog('Razorpay verified on server');
                await _saveBadgeAfterPurchase();
                CustomToast.show('Payment Success');
                await GetProfileApi.callApi(Database.loginUserId!);
                Get.offAll(const MainHomePageView());
              },
            );
            await 1.seconds.delay();
            RazorPayService().razorPayCheckout(
              amount: order.amount,
              orderId: order.orderId,
              currency: order.currency,
            );
            // >>>>>>>>>>>>>>>>>>>> Stripe Payment <<<<<<<<<<<<<<<<<<<
          } else if (AppSettings.paymentType.value == AppStrings.stripe.tr) {
            AppSettings.showLog(
                "Stripe Payment Success Method Called...sad.${widget.premiumPlanId}::");
            await StripeService().init(
              isTest: true,
              callback: () async {
                AppSettings.showLog("Stripe Payment Success Method Called....");
                AppSettings.showLog("Stripe Payment Successfully");
                await CreatePremiumPlanApi.callApi(
                    Database.loginUserId!, widget.premiumPlanId, "Stripe");
                await _saveBadgeAfterPurchase();
              },
            );
            await 1.seconds.delay();
            StripeService()
                .stripePay((widget.amount * 100).toInt(), widget.premiumPlanId);
            // >>>>>>>>>>>>>>>>>>>> In App Purchase Payment <<<<<<<<<<<<<<<<<<<
          } else if (AppSettings.paymentType.value == AppStrings.googlePay.tr) {
            // List<String> productKey = <String>[widget.productKey];

            List<String> kProductIds = <String>[widget.productKey];
            InAppPurchaseHelper().init(
              paymentType: "In App Purchase",
              userId: Database.loginUserId!,
              productKey: kProductIds,
              rupee: widget.amount,
              callBack: () async {
                AppSettings.showLog("In App Purchase Payment Successfully");
                await CreatePremiumPlanApi.callApi(Database.loginUserId!,
                    widget.premiumPlanId, "In App Purchase");
                await _saveBadgeAfterPurchase();
              },
            );
            log("Initialization completed");
            InAppPurchaseHelper().initStoreInfo();

            await Future.delayed(const Duration(seconds: 1));

            ProductDetails? product =
                InAppPurchaseHelper().getProductDetail(widget.productKey);
            log("Product is :: $product");
            if (product != null) {
              log("Product details retrieved successfully for :: ${product.id}");
              InAppPurchaseHelper().buySubscription(product, purchases!);
            } else {
              log("Product is null for :: ${widget.productKey}");
            }
          } else if (AppSettings.paymentType.value ==
              AppStrings.flutterWave.tr) {
            FlutterWaveService.init(
              amount: widget.amount.toString(),
              onPaymentComplete: () async {
                AppSettings.showLog("***** Flutter Wave Payment Success *****");
                await CreatePremiumPlanApi.callApi(Database.loginUserId ?? "",
                    widget.premiumPlanId, "Flutter Wave");
                await _saveBadgeAfterPurchase();
              },
            );
          } else {
            AppSettings.showLog("Please Select Payment Type");
            CustomToast.show("Please select payment type");
          }
          await Future.delayed(const Duration(seconds: 3));
          isClicked = false;
          setState(() {});
        },
      ).paddingAll(20),
      body: _loadingSettings
          ? const Center(child: LoaderUi())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: SizeConfig.blockSizeVertical * 2),
                Text(
                  AppStrings.paymentNote.tr,
                  style: GoogleFonts.urbanist(
                      fontSize: 14, fontWeight: FontWeight.w500),
                ).paddingOnly(left: 20, right: 20),
                SizedBox(height: SizeConfig.blockSizeVertical * 2),
                Expanded(
                  child: paymentMethods.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Text(
                              'No payment methods are available. Enable gateways in admin settings or pull to refresh.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.urbanist(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: isDarkMode.value
                                    ? AppColor.white.withValues(alpha: 0.7)
                                    : AppColor.black.withValues(alpha: 0.6),
                              ),
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 16),
                          itemCount: paymentMethods.length,
                          itemBuilder: (context, index) {
                            final method = paymentMethods[index];
                            return PaymentItemView(
                              title: method.title,
                              leading: method.leading,
                              iconSize: method.iconSize,
                            );
                          },
                        ),
                ),
              ],
            ),
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
