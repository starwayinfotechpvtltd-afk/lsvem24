import 'package:fluttertoast/fluttertoast.dart';
import 'package:metube/utils/colors/app_color.dart';

class CustomToast {
  static void show(String title) {
    Fluttertoast.showToast(
      msg: title,
      backgroundColor: AppColor.grey.withOpacity(0.9),
      textColor: AppColor.white,
      gravity: ToastGravity.BOTTOM,
    );
  }
}
