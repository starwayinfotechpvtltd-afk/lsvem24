import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:metube/custom/custom_method/custom_toast.dart';
import 'package:metube/custom/custom_ui/loader_ui.dart';
import 'package:metube/utils/settings/app_settings.dart';
import 'package:metube/utils/string/app_string.dart';

class CustomVideoPicker {
  static Future<String?> pickVideo() async {
    try {
      Get.dialog(barrierDismissible: false, const LoaderUi());
      final videoPath = await ImagePicker().pickVideo(source: ImageSource.gallery);
      if (videoPath != null) {
        Get.back();
        return videoPath.path;
      } else {
        Get.back();
        CustomToast.show(AppStrings.pleaseSelectVideo.tr);
        return null;
      }
    } catch (e) {
      Get.back();
      AppSettings.showLog("Error => Video Picker Error");
      return null;
    }
  }
}
