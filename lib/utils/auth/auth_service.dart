import 'package:get/get.dart';
import 'package:metube/custom/custom_method/custom_toast.dart';
import 'package:metube/database/database.dart';
import 'package:metube/pages/login_related_page/login_page/login_view.dart';

class AuthService {

  static bool checkLogin() {

    // Check invalid values
    if (Database.loginUserId == null ||
        Database.loginUserId.toString().trim().isEmpty ||
        Database.loginUserId.toString() == "null") {

      print("USER NOT LOGGED IN");

      CustomToast.show("Please login first");

      Get.to(() => const LoginView());

      return false;
    }

    print("USER IS LOGGED IN");

    return true;
  }
}