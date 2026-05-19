import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:metube/custom/custom_method/custom_range_picker.dart';
import 'package:metube/database/database.dart';
import 'package:metube/pages/buy_coin_history_page/api/fetch_buy_coin_history_api.dart';
import 'package:metube/pages/buy_coin_history_page/model/fetch_buy_coin_history_model.dart';
import 'package:metube/utils/utils.dart';

class BuyCoinHistoryController extends GetxController {
  bool isLoading = false;
  FetchBuyCoinHistoryModel? buyCoinHistoryModel;

  List<Data> coinHistory = [];

  String startDate = "All";
  String endDate = "All";
  String selectDateRange = "All";

  int selectedPlanIndex = 0;

  @override
  void onInit() {
    Utils.showLog("Buy Coin History Controller Initialize Success");
    onGetCoinHistory();
    super.onInit();
  }

  @override
  void onClose() {
    Utils.showLog("Buy Coin History Controller Dispose Success");
    super.onClose();
  }

  Future<void> onGetCoinHistory() async {
    isLoading = true;
    update(["onGetCoinHistory"]);

    buyCoinHistoryModel = await FetchBuyCoinHistoryApi.callApi(loginUserId: Database.loginUserId ?? "", startDate: startDate, endDate: endDate);
    coinHistory.clear();
    coinHistory.addAll(buyCoinHistoryModel?.data ?? []);

    isLoading = false;
    update(["onGetCoinHistory"]);
  }

  void onChangeDateRange(BuildContext context) async {
    DateTimeRange? dateTimeRange = await CustomRangePicker.onPick(context);
    if (dateTimeRange != null) {
      startDate = DateFormat('yyyy-MM-dd').format(dateTimeRange.start);
      endDate = DateFormat('yyyy-MM-dd').format(dateTimeRange.end);
      selectDateRange = "${DateFormat('dd/MM/yy').format(dateTimeRange.start)} - ${DateFormat('dd/MM/yy').format(dateTimeRange.end)}";
      onGetCoinHistory();
      update(["onChangeDateRange"]);
    }
  }
}
