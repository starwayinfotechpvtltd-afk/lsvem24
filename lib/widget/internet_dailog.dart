import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InternetController extends GetxController {
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _subscription;

  @override
  void onInit() {
    super.onInit();
    _subscription = _connectivity.onConnectivityChanged.listen(_updateStatus);
  }

  void _updateStatus(ConnectivityResult result) {
    if (result == ConnectivityResult.none) {
      _showNoInternetDialog();
    } else {
      if (Get.isDialogOpen == true) {
        Get.back(); // close dialog if internet is back
      }
    }
  }

  void _showNoInternetDialog() {
    if (Get.isDialogOpen != true) {
      Get.dialog(
        AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("No Internet Connection"),
          content: const Text("Please check your internet settings and try again."),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text("OK"),
            ),
          ],
        ),
        barrierDismissible: false, // user must wait for internet
      );
    }
  }

  @override
  void onClose() {
    _subscription.cancel();
    super.onClose();
  }
}
