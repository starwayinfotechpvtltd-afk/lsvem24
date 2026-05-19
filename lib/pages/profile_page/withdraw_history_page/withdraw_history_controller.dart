import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:metube/custom/custom_method/custom_range_picker.dart';
import 'package:metube/database/database.dart';
import 'package:metube/pages/profile_page/withdraw_history_page/get_withdraw_history_api.dart';
import 'package:metube/pages/profile_page/withdraw_history_page/get_withdraw_history_model.dart';

class WithdrawHistoryController extends GetxController {
  bool isLoadingHistory = false;
  GetWithdrawHistoryModel? getWithdrawHistoryModel;
  List<WithDrawRequests> withdrawHistory = [];

  String startDate = "All";
  String endDate = "All";
  String selectDateRange = "All";

  @override
  void onInit() {
    init();
    super.onInit();
  }

  void init() {
    withdrawHistory.clear();
    isLoadingHistory = true;
    update(["onGetWithdrawHistory"]);
    onGetWithdrawHistory();
  }

  Future<void> onGetWithdrawHistory() async {
    getWithdrawHistoryModel = await GetWithdrawHistoryApi.callApi(loginUserId: Database.loginUserId ?? "", startDate: startDate, endDate: endDate);

    if (getWithdrawHistoryModel?.withDrawRequests != null) {
      final data = getWithdrawHistoryModel?.withDrawRequests ?? [];
      withdrawHistory.clear();
      withdrawHistory.addAll(data);
      isLoadingHistory = false;
      update(["onGetWithdrawHistory"]);
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
