import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:metube/custom/custom_method/custom_range_picker.dart';
import 'package:metube/database/database.dart';
import 'package:metube/pages/profile_page/coin_history_page/get_coin_history_api.dart';
import 'package:metube/pages/profile_page/coin_history_page/get_coin_history_model.dart';

class CoinHistoryController extends GetxController {
  bool isLoadingHistory = false;
  GetCoinHistoryModel? getConvertCoinHistoryModel;
  List<Data> convertedCoinHistory = [];

  String startDate = "All";
  String endDate = "All";
  String selectDateRange = "All";

  @override
  void onInit() {
    init();
    super.onInit();
  }

  void init() {
    convertedCoinHistory.clear();
    isLoadingHistory = true;
    update(["onGetConvertedCoinHistory"]);
    onGetConvertedCoinHistory();
  }

  Future<void> onGetConvertedCoinHistory() async {
    getConvertCoinHistoryModel = await GetCoinHistoryApi.callApi(loginUserId: Database.loginUserId ?? "", startDate: startDate, endDate: endDate);

    if (getConvertCoinHistoryModel?.data != null) {
      final data = getConvertCoinHistoryModel?.data ?? [];
      convertedCoinHistory.clear();
      convertedCoinHistory.addAll(data);
      isLoadingHistory = false;
      update(["onGetConvertedCoinHistory"]);
    }
  }

  void onChangeDateRange(BuildContext context) async {
    DateTimeRange? dateTimeRange = await CustomRangePicker.onPick(context);
    if (dateTimeRange != null) {
      startDate = DateFormat('yyyy-MM-dd').format(dateTimeRange.start);
      endDate = DateFormat('yyyy-MM-dd').format(dateTimeRange.end);
      selectDateRange = "${DateFormat('dd/MM/yy').format(dateTimeRange.start)} - ${DateFormat('dd/MM/yy').format(dateTimeRange.end)}";
      init();
      update(["onChangeDateRange"]);
    }
  }
}
