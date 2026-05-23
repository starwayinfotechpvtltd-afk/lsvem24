import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:metube/main.dart';
import 'package:metube/utils/colors/app_color.dart';

class LoaderUi extends StatelessWidget {
  const LoaderUi({super.key, this.color, this.message});

  final Color? color;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SpinKitCircle(
              color: isDarkMode.value
                  ? AppColor.white
                  : (color ?? AppColor.primaryColor),
              size: 60,
            ),
            if (message != null && message!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  message!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isDarkMode.value ? AppColor.white : AppColor.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
