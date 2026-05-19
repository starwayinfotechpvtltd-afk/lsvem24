// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:intl/intl.dart';
// import 'package:metube/custom/custom_method/custom_range_picker.dart';
// import 'package:metube/custom/shimmer/container_shimmer_ui.dart';
// import 'package:metube/database/database.dart';
// import 'package:metube/main.dart';
// import 'package:metube/pages/nav_shorts_page/nav_shorts_details_view.dart';
// import 'package:metube/pages/profile_page/monetization_page/with_draw_history_api.dart';
// import 'package:metube/pages/profile_page/monetization_page/with_draw_history_model.dart';
// import 'package:metube/pages/profile_page/monetization_page/withdraw_view.dart';
// import 'package:metube/utils/colors/app_color.dart';
// import 'package:metube/utils/icons/app_icons.dart';
// import 'package:metube/utils/settings/app_settings.dart';
// import 'package:metube/utils/string/app_string.dart';
//
// class WalletView extends StatefulWidget {
//   const WalletView({super.key, required this.balance});
//   final double balance;
//
//   @override
//   State<WalletView> createState() => _WalletViewState();
// }
//
// class _WalletViewState extends State<WalletView> {
//   RxBool isLoading = false.obs;
//   WithDrawHistoryModel? withDraw;
//
//   RxString startDate = "All".obs;
//   RxString endDate = "All".obs;
//
//   RxString selectedRange = AppStrings.last28Days.tr.obs;
//
//   @override
//   void initState() {
//     onGetData();
//     super.initState();
//   }
//
//   void onGetData() async {
//     withDraw = null;
//     isLoading.value = true;
//
//     withDraw = await WithDrawHistoryApi.callApi(loginUserId: Database.loginUserId!, startDate: startDate.value, endDate: endDate.value);
//     // if (withDraw != null) {
//     isLoading.value = false;
//     // }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         systemOverlayStyle: const SystemUiOverlayStyle(statusBarColor: Colors.transparent, statusBarBrightness: Brightness.dark),
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leadingWidth: 60,
//         leading: IconButtonUi(
//           callback: () => Get.back(),
//           icon: Obx(
//             () => Image.asset(AppIcons.arrowBack, height: 20, width: 20, color: isDarkMode.value ? AppColors.white : AppColors.black),
//           ),
//         ),
//         centerTitle: AppSettings.isCenterTitle,
//         title: Text(AppStrings.myWallet.tr, style: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.bold)),
//       ),
//       body: Obx(
//         () => isLoading.value
//             ? SingleChildScrollView(
//                 physics: const NeverScrollableScrollPhysics(),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   children: [
//                     const ContainerShimmerUi(height: 180, radius: 20).paddingSymmetric(horizontal: 15),
//                     const ContainerShimmerUi(height: 40, radius: 30).paddingSymmetric(horizontal: 15, vertical: 10),
//                     // ContainerShimmerUi(height: Get.height / 2, radius: 20).paddingSymmetric(horizontal: 15),
//                     for (int i = 0; i < 6; i++)
//                       Column(
//                         children: [
//                           Row(
//                             children: [
//                               Expanded(child: const ContainerShimmerUi(height: 25, width: 0, radius: 30).paddingOnly(left: 15, right: 5)),
//                               Expanded(child: const ContainerShimmerUi(height: 25, width: 0, radius: 30).paddingOnly(right: 15, left: 5)),
//                             ],
//                           ),
//                           Row(
//                             children: [
//                               Expanded(child: const ContainerShimmerUi(height: 25, width: 0, radius: 30).paddingOnly(left: 15, right: 5)),
//                               Expanded(child: const ContainerShimmerUi(height: 25, width: 0, radius: 30).paddingOnly(right: 15, left: 5)),
//                             ],
//                           ),
//                         ],
//                       ).paddingOnly(bottom: 12),
//
//                     const ContainerShimmerUi(height: 48, radius: 30).paddingSymmetric(horizontal: 15, vertical: 10),
//                   ],
//                 ),
//               )
//             : Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const SizedBox(height: 10),
//                   Container(
//                     height: 135,
//                     width: Get.width,
//                     padding: const EdgeInsets.only(left: 20, top: 10, bottom: 10),
//                     margin: const EdgeInsets.symmetric(horizontal: 15),
//                     decoration: BoxDecoration(
//                       color: AppColors.grey_50,
//                       borderRadius: BorderRadius.circular(25),
//                       image: const DecorationImage(image: AssetImage(AppIcons.walletImage), fit: BoxFit.cover),
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                       children: [
//                         Text(
//                           AppStrings.myBalance.tr,
//                           style: GoogleFonts.urbanist(fontSize: 16, color: AppColors.white, fontWeight: FontWeight.bold),
//                         ),
//                         Text(
//                           "\$ ${widget.balance.toStringAsFixed(2)}",
//                           style: GoogleFonts.urbanist(fontSize: 34, color: AppColors.white, fontWeight: FontWeight.w900),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   Row(
//                     children: [
//                       Text(
//                         AppStrings.history.tr,
//                         style: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.bold),
//                       ),
//                       const Spacer(),
//                       GestureDetector(
//                         onTap: () async {
//                           DateTimeRange? dateTimeRange = await CustomRangePicker.onPick(context);
//                           if (dateTimeRange != null) {
//                             startDate.value = DateFormat('yyyy-MM-dd').format(dateTimeRange.start);
//                             endDate.value = DateFormat('yyyy-MM-dd').format(dateTimeRange.end);
//
//                             selectedRange.value = "${DateFormat('dd/MM/yy').format(dateTimeRange.start)} - ${DateFormat('dd/MM/yy').format(dateTimeRange.end)}";
//                             onGetData();
//                           }
//                         },
//                         child: Row(
//                           children: [
//                             Obx(
//                               () => Text(
//                                 selectedRange.value,
//                                 style: GoogleFonts.urbanist(fontSize: 12, color: AppColors.primaryColor, fontWeight: FontWeight.bold),
//                               ),
//                             ),
//                             Image.asset(
//                               AppIcons.downArrowBold,
//                               width: 20,
//                             ),
//                           ],
//                         ),
//                       )
//                     ],
//                   ).paddingSymmetric(horizontal: 15),
//                   const SizedBox(height: 10),
//                   Expanded(
//                     child: (withDraw?.withDrawRequests?.isEmpty ?? true)
//                         ? const Center(child: Text("No History Found"))
//                         : ListView.builder(
//                             itemCount: withDraw?.withDrawRequests?.length ?? 0,
//                             shrinkWrap: true,
//                             itemBuilder: (context, index) => historyItem(
//                               id: withDraw?.withDrawRequests?[index].uniqueId ?? "",
//                               amount: withDraw?.withDrawRequests?[index].requestAmount.toString() ?? "",
//                               status: withDraw?.withDrawRequests?[index].status ?? 0,
//                               time: withDraw?.withDrawRequests?[index].requestDate ?? "",
//                             ),
//                           ),
//                   ),
//                 ],
//               ),
//       ),
//       bottomNavigationBar: Obx(
//         () => isLoading.value
//             ? const Offstage()
//             : GestureDetector(
//                 onTap: () async {
//                   Get.to(WithdrawView(balance: widget.balance));
//                 },
//                 child: Container(
//                   height: 48,
//                   width: MediaQuery.of(context).size.width,
//                   alignment: Alignment.center,
//                   decoration: BoxDecoration(
//                     color: AppColors.primaryColor,
//                     borderRadius: BorderRadius.circular(100),
//                   ),
//                   child: Text(
//                     AppStrings.withdraw.tr,
//                     textAlign: TextAlign.center,
//                     style: GoogleFonts.urbanist(
//                       fontWeight: FontWeight.w600,
//                       fontSize: 16,
//                       color: AppColors.white,
//                     ),
//                   ),
//                 ),
//               ).paddingAll(15),
//       ),
//     );
//   }
// }
//
// Widget historyItem({required int status, required String amount, required String id, required String time}) => SizedBox(
//       height: 75,
//       width: Get.width,
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Row(
//             children: [
//               Text(
//                 status == 1
//                     ? AppStrings.pendingMoney.tr
//                     : status == 2
//                         ? AppStrings.receiveMoney.tr
//                         : AppStrings.declineMoney.tr,
//                 style: GoogleFonts.urbanist(fontSize: 16, color: AppColors.primaryColor, fontWeight: FontWeight.bold),
//               ),
//               const Spacer(),
//               Text(
//                 status == 2 ? "+ $amount" : amount,
//                 style: GoogleFonts.urbanist(
//                   fontSize: 16,
//                   color: status == 2
//                       ? Colors.green
//                       : status == 1
//                           ? isDarkMode.value
//                               ? Colors.white
//                               : AppColors.black
//                           : Colors.red,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 3),
//           Row(
//             children: [
//               Text(
//                 "ID : $id",
//                 style: GoogleFonts.urbanist(fontSize: 12, color: AppColors.grey, fontWeight: FontWeight.w600),
//               ),
//               const Spacer(),
//               Image.asset(
//                 width: 16,
//                 AppIcons.timeCircle,
//                 color: AppColors.grey,
//               ).paddingOnly(right: 3),
//               Text(
//                 time,
//                 style: GoogleFonts.urbanist(fontSize: 12, color: AppColors.grey, fontWeight: FontWeight.w600),
//               ),
//             ],
//           ),
//           const SizedBox(height: 3),
//           Divider(color: AppColors.grey_300),
//         ],
//       ).paddingSymmetric(horizontal: 15),
//     );
