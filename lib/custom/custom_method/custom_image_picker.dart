import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:metube/custom/custom_ui/loader_ui.dart';
import 'package:metube/utils/colors/app_color.dart';
import 'package:metube/utils/settings/app_settings.dart';

class CustomImagePicker {
  static Future<void> pickImage(ImageSource imageSource) async {
    try {
      Get.dialog(const LoaderUi(color: AppColor.white), barrierDismissible: false);
      final image = await ImagePicker().pickImage(source: imageSource);
      if (image != null) {
        AppSettings.showLog("Pick Image Path => ${image.path}");
        AppSettings.pickImagePath.value = image.path;
        Get.close(2);
      } else {
        Get.close(2);
      }
    } catch (e) {
      Get.close(2);
      AppSettings.showLog("Image Picker Error => $e");
    }
  }
}
