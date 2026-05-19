// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:metube/custom/basic_button.dart';
// import 'package:metube/utils/colors/app_color.dart';
// import 'package:metube/utils/config/size_config.dart';
// import 'package:metube/utils/string/app_string.dart';
// import 'package:metube/utils/style/app_style.dart';
//
// class VideoQualityPreferencesScreen extends StatefulWidget {
//   const VideoQualityPreferencesScreen({super.key});
//
//   @override
//   State<VideoQualityPreferencesScreen> createState() => _VideoQualityPreferencesScreenState();
// }
//
// class _VideoQualityPreferencesScreenState extends State<VideoQualityPreferencesScreen> {
//   bool switch1 = false;
//   bool switch2 = false;
//   bool switch3 = false;
//   bool switch4 = false;
//   bool switch5 = false;
//   bool switch6 = false;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           BasicAppBar(title: AppStrings.videoQuality.tr),
//           SizedBox(
//             height: SizeConfig.blockSizeVertical * 2,
//           ),
//           Padding(
//             padding: EdgeInsets.only(
//               left: SizeConfig.blockSizeHorizontal * 7,
//               right: SizeConfig.blockSizeHorizontal * 5,
//             ),
//             child: Text(
//               AppStrings.onMobile.tr,
//               style: paymentNameStyle,
//             ),
//           ),
//           BasicDataSavingSwitch(
//             title: AppStrings.auto.tr,
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
//           BasicDataSavingSwitch(
//             title: AppStrings.highPic.tr,
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
//             title: AppStrings.dataSaver.tr,
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
//           SizedBox(
//             height: SizeConfig.blockSizeVertical * 1,
//           ),
//           Divider(endIndent: SizeConfig.blockSizeHorizontal * 8, indent: SizeConfig.blockSizeHorizontal * 7),
//           SizedBox(
//             height: SizeConfig.blockSizeVertical * 2,
//           ),
//           Padding(
//             padding: EdgeInsets.only(
//               left: SizeConfig.blockSizeHorizontal * 7,
//               right: SizeConfig.blockSizeHorizontal * 5,
//             ),
//             child: Text(
//               AppStrings.onWiFi.tr,
//               style: paymentNameStyle,
//             ),
//           ),
//           BasicDataSavingSwitch(
//             title: AppStrings.auto.tr,
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
//             title: AppStrings.highPic.tr,
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
//           BasicDataSavingSwitch(
//             title: AppStrings.dataSaver.tr,
//             widget: Transform.scale(
//               scale: 0.7,
//               child: CupertinoSwitch(
//                 activeColor: AppColors.primaryColor,
//                 value: switch6,
//                 onChanged: (val) {
//                   setState(() {
//                     switch6 = val;
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
