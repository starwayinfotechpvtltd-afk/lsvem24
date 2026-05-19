import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:metube/utils/settings/app_settings.dart';

class GoogleLogin {
  static Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
      final credential = GoogleAuthProvider.credential(accessToken: googleAuth?.accessToken, idToken: googleAuth?.idToken);
      final result = await FirebaseAuth.instance.signInWithCredential(credential);

      AppSettings.showLog("Google Login Email => ${result.user?.email}");

      AppSettings.showLog("Google Login isNewUser => ${result.additionalUserInfo?.isNewUser}");

      return result;
    } catch (error, stackTrace) {
      AppSettings.showLog("Google Login Error => $error");
      AppSettings.showLog("Stack Trace => $stackTrace");
    }
    return null;
  }
}
