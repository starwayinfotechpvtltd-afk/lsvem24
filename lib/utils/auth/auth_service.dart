import 'package:get/get.dart';
import 'package:metube/custom/custom_method/custom_toast.dart';
import 'package:metube/database/database.dart';
import 'package:metube/pages/login_related_page/login_page/login_view.dart';

class AuthService {
  static bool get isLoggedIn {
    final id = Database.loginUserId;
    return id != null &&
        id.toString().trim().isNotEmpty &&
        id.toString() != 'null';
  }

  static bool checkLogin() {
    if (isLoggedIn) {
      return true;
    }

    CustomToast.show('Please login first');
    Get.to(() => const LoginView());
    return false;
  }
}