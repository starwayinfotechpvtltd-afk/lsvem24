import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:metube/custom/custom_method/custom_range_picker.dart';
import 'package:metube/database/database.dart';
import 'package:metube/pages/profile_page/referral_history_page/get_referral_history_api.dart';
import 'package:metube/pages/profile_page/referral_history_page/get_referral_history_model.dart';

class ReferralHistoryController extends GetxController {
  bool isLoadingHistory = false;
  GetReferralHistoryModel? getReferralHistoryModel;
  List<Data> referralHistory = [];

  String startDate = "All";
  String endDate = "All";
  String selectDateRange = "All";

  @override
  void onInit() {
    init();
    super.onInit();
  }

  void init() {
    referralHistory.clear();
    isLoadingHistory = true;
    update(["onGetReferralHistory"]);
    onGetReferralHistory();
  }

  Future<void> onGetReferralHistory() async {
    getReferralHistoryModel = await ReferralHistoryApi.callApi(loginUserId: Database.loginUserId ?? "", startDate: startDate, endDate: endDate);

    if (getReferralHistoryModel?.data != null) {
      final data = getReferralHistoryModel?.data ?? [];
      referralHistory.clear();
      referralHistory.addAll(data);
      isLoadingHistory = false;
      update(["onGetReferralHistory"]);
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
