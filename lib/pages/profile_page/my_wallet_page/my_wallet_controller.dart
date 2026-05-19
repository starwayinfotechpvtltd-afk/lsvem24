import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:metube/custom/custom_method/custom_range_picker.dart';
import 'package:metube/database/database.dart';
import 'package:metube/pages/profile_page/my_wallet_page/get_wallet_history_api.dart';
import 'package:metube/pages/profile_page/my_wallet_page/get_wallet_history_model.dart';

class MyWalletController extends GetxController {
  int myBalance = 0;

  bool isLoadingHistory = false;
  GetWalletHistoryModel? getWalletHistoryModel;
  List<Data> walletHistory = [];

  String startDate = "All";
  String endDate = "All";
  String selectDateRange = "All";

  @override
  void onInit() {
    init();
    super.onInit();
  }

  void init() {
    walletHistory.clear();
    isLoadingHistory = true;
    update(["onGetWalletHistory"]);
    onGetWalletHistory();
  }

  Future<void> onGetWalletHistory() async {
    getWalletHistoryModel = await GetWalletHistoryApi.callApi(loginUserId: Database.loginUserId ?? "", startDate: startDate, endDate: endDate);

    if (getWalletHistoryModel?.data != null) {
      myBalance = int.parse((getWalletHistoryModel?.total ?? 0).toString());
      final data = getWalletHistoryModel?.data ?? [];
      walletHistory.clear();
      walletHistory.addAll(data);
      isLoadingHistory = false;
      update(["onGetWalletHistory"]);
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
