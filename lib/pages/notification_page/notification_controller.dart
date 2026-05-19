import 'package:get/get.dart';
import 'package:metube/pages/notification_page/notification_api.dart';
import 'package:metube/pages/notification_page/notification_model.dart';
import 'package:metube/utils/settings/app_settings.dart';

class NotificationController extends GetxController {
  List<Notification>? mainNotifications;

  void onGetNotification() async {
    mainNotifications = (await NotificationApiClass.callApi()) ?? [];
    AppSettings.showLog("Notification Length => ${mainNotifications!.length}");
    update(["onGetNotification"]);
  }
}
