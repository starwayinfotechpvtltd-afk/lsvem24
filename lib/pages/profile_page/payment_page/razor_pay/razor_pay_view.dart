import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_typedefs/rx_typedefs.dart';
import 'package:metube/custom/custom_method/custom_toast.dart';
import 'package:metube/database/database.dart';
import 'package:metube/pages/profile_page/payment_page/razor_pay/verify_razorpay_payment_api.dart';
import 'package:metube/utils/string/app_string.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:metube/pages/login_related_page/fill_profile_page/get_profile_api.dart';

typedef RazorpayPaymentSuccessCallback = Future<void> Function();

class RazorPayService {
  static late Razorpay razorPay;
  static late String razorKeys;
  static String? _pendingOrderId;
  RazorpayPaymentSuccessCallback onComplete = () async {};

  void init({
    required String razorKey,
    required RazorpayPaymentSuccessCallback callback,
  }) {
    razorPay = Razorpay();
    razorPay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlePaymentSuccess);
    razorPay.on(Razorpay.EVENT_PAYMENT_ERROR, handlePaymentError);
    razorPay.on(Razorpay.EVENT_EXTERNAL_WALLET, handleExternalWallet);
    razorKeys = razorKey;
    onComplete = callback;
  }

  Future<void> handlePaymentSuccess(PaymentSuccessResponse response) async {
    final paymentId = response.paymentId ?? '';
    final orderId = response.orderId ?? _pendingOrderId ?? '';
    final signature = response.signature ?? '';

    if (paymentId.isEmpty || orderId.isEmpty || signature.isEmpty) {
      CustomToast.show('Invalid payment response');
      return;
    }

    final userId = Database.loginUserId ?? '';
    if (userId.isEmpty) {
      CustomToast.show('User not logged in');
      return;
    }

    final verified = await VerifyRazorpayPaymentApi.callApi(
      userId: userId,
      razorpayOrderId: orderId,
      razorpayPaymentId: paymentId,
      razorpaySignature: signature,
    );

    if (verified?.status == true) {
      await onComplete();
    } else {
      CustomToast.show(verified?.message ?? 'Payment verification failed');
    }
  }

  void razorPayCheckout({
    required int amount,
    required String orderId,
    String? currency,
  }) {
    debugPrint('Razorpay checkout amount=$amount orderId=$orderId');
    if (razorKeys.isEmpty) {
      CustomToast.show('Razorpay is not configured');
      return;
    }
    if (orderId.isEmpty) {
      CustomToast.show('Invalid payment order');
      return;
    }

    _pendingOrderId = orderId;

    final options = {
      'key': razorKeys,
      'amount': amount,
      'order_id': orderId,
      'name': AppStrings.appName,
      'theme.color': '#FF4D67',
      'description': AppStrings.appName,
      'image': 'https://razorpay.com/assets/razorpay-glyph.svg',
      'currency': currency ?? 'INR',
      'prefill': {
        'contact': GetProfileApi.profileModel?.user?.mobileNumber ?? '',
        'email': GetProfileApi.profileModel?.user?.email ?? '',
      },
      'external': {
        'wallets': ['paytm'],
      },
    };

    try {
      razorPay.open(options);
    } catch (e) {
      debugPrint('Razor Payment Error => $e');
      CustomToast.show('Could not open Razorpay');
    }
  }

  void handlePaymentError(PaymentFailureResponse response) {
    CustomToast.show(response.message ?? 'Payment failed');
  }

  void handleExternalWallet(ExternalWalletResponse response) {
    CustomToast.show('External wallet: ${response.walletName!}');
  }
}
