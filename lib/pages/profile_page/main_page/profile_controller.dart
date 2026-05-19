import 'package:get/get.dart';
import 'package:metube/database/database.dart';
import 'package:metube/pages/profile_page/earn_reward_page/get_daily_reward_api.dart';
import 'package:metube/pages/profile_page/earn_reward_page/get_daily_reward_model.dart';
import 'package:metube/pages/profile_page/my_wallet_page/get_wallet_history_api.dart';
import 'package:metube/pages/profile_page/my_wallet_page/get_wallet_history_model.dart';
import 'package:metube/pages/profile_page/setting_page/premium_purchase_history_page/get_premium_plan_purchase_history_model.dart';
import 'package:metube/pages/profile_page/setting_page/premium_purchase_history_page/get_premium_purchase_history_api.dart';

class ProfileController extends GetxController {
  List<PlanHistory>? premiumPurchaseHistory;
  List<CoinplanHistory>? coinPurchaseHistory;

  GetDailyRewardModel? getDailyRewardModel;
  GetWalletHistoryModel? getWalletHistoryModel;

  RxInt rewardCoins = 0.obs;
  RxInt myBalance = 0.obs;

  @override
  void onInit() {
    onGetRewardCoin();
    super.onInit();
  }

  Future<void> onGetPurchaseHistory() async {
    premiumPurchaseHistory = null;
    await GetPremiumPlanHistoryApi.callApi(Database.loginUserId!);

    premiumPurchaseHistory = [];
    coinPurchaseHistory = [];
    premiumPurchaseHistory?.addAll(GetPremiumPlanHistoryApi.historyModel?.planHistory ?? []);
    coinPurchaseHistory?.addAll(GetPremiumPlanHistoryApi.historyModel?.coinplanHistory ?? []);
    update(["onGetPurchaseHistory"]);
  }

  void onGetRewardCoin() async {
    getDailyRewardModel = await GetDailyRewardApi.callApi(loginUserId: Database.loginUserId ?? "");
    getWalletHistoryModel = await GetWalletHistoryApi.callApi(loginUserId: Database.loginUserId ?? "", startDate: "All", endDate: "All");
    rewardCoins.value = getDailyRewardModel?.totalCoins ?? 0;
    myBalance.value = (getWalletHistoryModel?.total ?? 0).toInt();
  }
}
