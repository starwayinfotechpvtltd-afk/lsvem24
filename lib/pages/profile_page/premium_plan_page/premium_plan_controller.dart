import 'package:get/get.dart';
import 'package:metube/pages/profile_page/premium_plan_page/get_premium_plan_api.dart';
import 'package:metube/pages/profile_page/premium_plan_page/get_premium_plan_model.dart';

class PremiumPlanController extends GetxController {
  List<PremiumPlan>? mainPremiumPlans;

  @override
  void onInit() {
    if (mainPremiumPlans == null) {
      onGetPremiumPlan();
    }
    super.onInit();
  }

  void onGetPremiumPlan() async {
    mainPremiumPlans = await GetPremiumPlanApi.callApi() ?? [];
    update(["onGetPremiumPlan"]);
  }
}
