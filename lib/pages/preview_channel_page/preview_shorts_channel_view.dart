// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:metube/custom/custom_ui/data_not_found_ui.dart';
// import 'package:metube/custom/shimmer/channel_profile_shimmer_ui.dart';
// import 'package:metube/custom/shimmer/shorts_list_shimmer_ui.dart';
// import 'package:metube/database/database.dart';
// import 'package:metube/main.dart';
// import 'package:metube/pages/custom_pages/report_page/custom_channel_report_view.dart';
// import 'package:metube/pages/nav_subscription_page/subscribe_channel_api.dart';
// import 'package:metube/pages/preview_channel_page/get_shorts_channel_details_api.dart';
// import 'package:metube/pages/preview_channel_page/get_shorts_channel_details_model.dart';
// import 'package:metube/pages/video_details_page/shorts_video_details_view.dart';
// import 'package:metube/utils/colors/app_color.dart';
// import 'package:metube/utils/config/size_config.dart';
// import 'package:metube/utils/icons/app_icons.dart';
// import 'package:metube/utils/services/preview_image.dart';
// import 'package:metube/utils/settings/app_settings.dart';
// import 'package:metube/utils/string/app_string.dart';
// import 'package:metube/utils/style/app_style.dart';
//
// class PreviewShortsChannelView extends StatefulWidget {
//   const PreviewShortsChannelView({super.key, required this.channelId});
//
//   final String channelId;
//
//   @override
//   State<PreviewShortsChannelView> createState() => _PreviewShortsChannelViewState();
// }
//
// class _PreviewShortsChannelViewState extends State<PreviewShortsChannelView> {
//   RxList<DetailsOfShorts> channelVideos = <DetailsOfShorts>[].obs;
//   GetShortsChannelDetailsModel? _getShortsChannelDetailsModel;
//   ScrollController scrollController = ScrollController();
//   RxBool isSubscribe = false.obs;
//   RxBool isLoading = false.obs;
//   RxBool isPaginationLoading = false.obs;
//
//   RxInt subscriber = 0.obs;
//
//   @override
//   void initState() {
//     GetShortsChannelDetailsApi.startPagination = 0;
//     init();
//     scrollController.addListener(onScrolling);
//     super.initState();
//   }
//
//   void init() async {
//     isLoading.value = true;
//     await getChannelDetails();
//     isLoading.value = false;
//   }
//
//   Future<void> getChannelDetails() async {
//     _getShortsChannelDetailsModel = await GetShortsChannelDetailsApi.callApi(widget.channelId);
//
//     isSubscribe.value = _getShortsChannelDetailsModel!.isSubscribed!;
//     subscriber.value = _getShortsChannelDetailsModel!.totalSubscribers!;
//     if (_getShortsChannelDetailsModel?.detailsOfShorts != null && _getShortsChannelDetailsModel!.detailsOfShorts!.isNotEmpty) {
//       channelVideos.addAll(_getShortsChannelDetailsModel!.detailsOfShorts!);
//       AppSettings.showLog("Channel Video Length => ${channelVideos.length}");
//     } else {
//       GetShortsChannelDetailsApi.startPagination--;
//       AppSettings.showLog("Get Shorts Channel Details Api IsEmpty");
//     }
//   }
//
//   void onScrolling() async {
//     if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
//       isPaginationLoading.value = true;
//       await getChannelDetails();
//       isPaginationLoading.value = false;
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         elevation: 0,
//         leading: GestureDetector(child: Image.asset(AppIcons.arrowBack, color: isDarkMode.value ? AppColor.white : AppColor.black).paddingOnly(left: 15), onTap: () => Get.back()),
//         leadingWidth: 33,
//         centerTitle: AppSettings.isCenterTitle,
//         title: Text(
//           AppStrings.channelDetails.tr,
//           style: GoogleFonts.urbanist(
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         actions: [
//           Visibility(
//             visible: (widget.channelId != Database.channelId),
//             child: Padding(
//               padding: const EdgeInsets.only(right: 20),
//               child: GestureDetector(
//                 onTap: () {
//                   CustomChannelReportView.show();
//                 },
//                 child: Icon(
//                   Icons.more_vert,
//                   size: 25,
//                   color: isDarkMode.value ? AppColor.white : AppColor.black,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//       bottomNavigationBar: Obx(() => Visibility(visible: isPaginationLoading.value, child: const LinearProgressIndicator(color: AppColor.primaryColor))),
//       body: SingleChildScrollView(
//         controller: scrollController,
//         physics: const BouncingScrollPhysics(),
//         child: Obx(
//           () => isLoading.value
//               ? Center(
//                   child: SingleChildScrollView(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: [
//                         const ChannelProfileShimmerUi(),
//                         Divider(
//                           indent: 20,
//                           endIndent: 20,
//                           color: AppColor.grey_200,
//                         ),
//                         const ShortsListShimmerUi(),
//                       ],
//                     ),
//                   ),
//                 )
//               : Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     children: [
//                       const SizedBox(height: 10),
//                       PreviewProfileImage(
//                         size: 125,
//                         id: widget.channelId,
//                         image: _getShortsChannelDetailsModel?.channelImage ?? "",
//                         fit: BoxFit.cover,
//                       ),
//                       SizedBox(height: SizeConfig.blockSizeVertical * 1),
//                       Text(
//                         _getShortsChannelDetailsModel!.channelName!,
//                         style: GoogleFonts.urbanist(fontSize: 22, fontWeight: FontWeight.bold),
//                       ),
//                       Text("$subscriber subscribes • ${_getShortsChannelDetailsModel!.totalShortsOfChannel!} videos", style: GoogleFonts.urbanist()),
//                       SizedBox(height: SizeConfig.blockSizeVertical * 2),
//                       Obx(
//                         () => GestureDetector(
//                           onTap: () async {
//                             if (isSubscribe.value) {
//                               isSubscribe.value = false;
//                               subscriber--;
//                             } else {
//                               isSubscribe.value = true;
//                               subscriber++;
//                             }
//                             await SubscribeChannelApiClass.callApi(widget.channelId);
//                           },
//                           child: Container(
//                             padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
//                             decoration: BoxDecoration(
//                               color: (isSubscribe.value) ? Colors.transparent : AppColor.primaryColor,
//                               borderRadius: BorderRadius.circular(25),
//                               border: Border.all(color: AppColor.primaryColor, width: 2),
//                             ),
//                             child: Text(
//                               (isSubscribe.value) ? AppStrings.subscribed.tr : AppStrings.subscribe.tr,
//                               style: GoogleFonts.urbanist(
//                                 color: (isSubscribe.value) ? AppColor.primaryColor : AppColor.white,
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                       SizedBox(height: SizeConfig.blockSizeVertical * 1),
//                       Divider(
//                         indent: 20,
//                         endIndent: 20,
//                         color: AppColor.grey_200,
//                       ),
//                       (channelVideos.isEmpty)
//                           ? Padding(
//                               padding: EdgeInsets.symmetric(vertical: Get.height / 10),
//                               child: DataNotFoundUi(title: AppStrings.shortsNotAvailable),
//                             )
//                           : GridView.builder(
//                               itemCount: channelVideos.length,
//                               padding: const EdgeInsets.all(10),
//                               shrinkWrap: true,
//                               physics: const BouncingScrollPhysics(),
//                               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10, mainAxisExtent: 250),
//                               itemBuilder: (context, index) => GestureDetector(
//                                 onTap: () => Get.to(() => ShortsVideoDetailsView(videoId: channelVideos[index].id!, videoUrl: channelVideos[index].videoUrl!)),
//                                 child: Container(
//                                   height: 250,
//                                   width: 165,
//                                   clipBehavior: Clip.antiAlias,
//                                   decoration: BoxDecoration(color: isDarkMode.value ? AppColor.secondDarkMode : AppColor.grey_400, borderRadius: BorderRadius.circular(20)),
//                                   child: Stack(
//                                     children: [
//                                       PreviewVideoImage(
//                                         videoId: channelVideos[index].id!,
//                                         videoImage: channelVideos[index].videoImage!,
//                                       ),
//                                       // ConvertedPathView(imageVideoPath: channelVideos[index].videoImage.toString()),
//                                       const Positioned(
//                                         top: 10,
//                                         right: 10,
//                                         child: Icon(Icons.more_vert, color: AppColor.white),
//                                       ),
//                                       Positioned(
//                                         bottom: 0,
//                                         left: 10,
//                                         child: Column(
//                                           crossAxisAlignment: CrossAxisAlignment.start,
//                                           children: [
//                                             SizedBox(
//                                               width: 145,
//                                               child: Text(
//                                                 channelVideos[index].title.toString(),
//                                                 maxLines: 3,
//                                                 style: shortsStyle,
//                                               ),
//                                             ),
//                                             const SizedBox(height: 10),
//                                             Text(
//                                               "${channelVideos[index].views.toString()} views",
//                                               style: shortsStyle,
//                                             ),
//                                             const SizedBox(height: 10),
//                                           ],
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ),
//                     ],
//                   ),
//                 ),
//         ),
//       ),
//     );
//   }
// }
