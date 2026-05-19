import 'package:get/get.dart';
import 'package:metube/pages/profile_page/help_center_page/get_contact_api.dart';
import 'package:metube/pages/profile_page/help_center_page/get_faq_model.dart';
import 'package:url_launcher/url_launcher.dart';

import 'get_contact_model.dart';
import 'get_faq_api.dart';

class HelpCenterController extends GetxController {
  List<FaQ>? faqCollection;
  List<Contact>? contactCollection;

  @override
  void onInit() {
    onGetFAQ();
    onGetContact();
    super.onInit();
  }

  void onGetFAQ() async {
    faqCollection = await GetFAQApi.callApi() ?? [];
    update(["onGetFAQ"]);
  }

  void onGetContact() async {
    contactCollection = await GetContactApi.callApi() ?? [];
    update(["onGetContact"]);
  }

  Future<void> onTapContact(Uri url) async {
    if (!await launchUrl(url, mode: LaunchMode.inAppWebView)) {
      throw Exception('Could not launch $url');
    }
  }
}
