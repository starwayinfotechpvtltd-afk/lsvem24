// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:metube/custom/basic_button.dart';
// import 'package:metube/utils/colors/app_color.dart';
// import 'package:metube/utils/config/size_config.dart';
// import 'package:metube/utils/string/app_string.dart';
//
// class DataSavingScreen extends StatefulWidget {
//   const DataSavingScreen({super.key});
//
//   @override
//   State<DataSavingScreen> createState() => _DataSavingScreenState();
// }
//
// class _DataSavingScreenState extends State<DataSavingScreen> {
//   bool switch1 = false;
//   bool switch2 = false;
//   bool switch3 = false;
//   bool switch4 = false;
//   bool switch5 = false;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           BasicAppBar(title: AppStrings.dataSaving.tr),
//           BasicDataSavingSwitch(
//             title: AppStrings.dataSavingMode.tr,
//             widget: Transform.scale(
//               scale: 0.7,
//               child: CupertinoSwitch(
//                 activeColor: AppColors.primaryColor,
//                 value: switch1,
//                 onChanged: (val) {
//                   setState(() {
//                     switch1 = val;
//                   });
//                 },
//               ),
//             ),
//           ),
//           SizedBox(
//             height: SizeConfig.blockSizeVertical * 1,
//           ),
//           Divider(endIndent: SizeConfig.blockSizeHorizontal * 8, indent: SizeConfig.blockSizeHorizontal * 7),
//           BasicDataSavingSwitch(
//             title: AppStrings.reduceVideoQuality.tr,
//             widget: Transform.scale(
//               scale: 0.7,
//               child: CupertinoSwitch(
//                 activeColor: AppColors.primaryColor,
//                 value: switch2,
//                 onChanged: (val) {
//                   setState(() {
//                     switch2 = val;
//                   });
//                 },
//               ),
//             ),
//           ),
//           BasicDataSavingSwitch(
//             title: AppStrings.reduceDownloadQuality.tr,
//             widget: Transform.scale(
//               scale: 0.7,
//               child: CupertinoSwitch(
//                 activeColor: AppColors.primaryColor,
//                 value: switch3,
//                 onChanged: (val) {
//                   setState(() {
//                     switch3 = val;
//                   });
//                 },
//               ),
//             ),
//           ),
//           BasicDataSavingSwitch(
//             title: AppStrings.restrictedMobileData.tr,
//             widget: Transform.scale(
//               scale: 0.7,
//               child: CupertinoSwitch(
//                 activeColor: AppColors.primaryColor,
//                 value: switch4,
//                 onChanged: (val) {
//                   setState(() {
//                     switch4 = val;
//                   });
//                 },
//               ),
//             ),
//           ),
//           BasicDataSavingSwitch(
//             title: AppStrings.uploadOverWiFiOnly.tr,
//             widget: Transform.scale(
//               scale: 0.7,
//               child: CupertinoSwitch(
//                 activeColor: AppColors.primaryColor,
//                 value: switch5,
//                 onChanged: (val) {
//                   setState(() {
//                     switch5 = val;
//                   });
//                 },
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
