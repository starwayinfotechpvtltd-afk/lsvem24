import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:metube/custom/custom_ui/loader_ui.dart';
import 'package:metube/custom/shimmer/comment_shimmer_ui.dart';
import 'package:metube/database/database.dart';
import 'package:metube/main.dart';
import 'package:metube/pages/custom_pages/comment_page/comment_controller.dart';
import 'package:metube/pages/custom_pages/comment_page/create_comment_api.dart';
import 'package:metube/pages/custom_pages/comment_page/reply_bottom_sheet.dart';
import 'package:metube/utils/colors/app_color.dart';
import 'package:metube/utils/config/size_config.dart';
import 'package:metube/utils/icons/app_icons.dart';
import 'package:metube/utils/services/preview_image.dart';
import 'package:metube/utils/settings/app_settings.dart';
import 'package:metube/utils/string/app_string.dart';
import 'package:metube/utils/style/app_style.dart';
import 'package:video_player/video_player.dart';
import 'package:metube/utils/auth/auth_service.dart';

/// Latest total comment count after opening / posting (read on sheet dismiss).
class CommentSheetSession {
  CommentSheetSession._();

  static int latestTotalComments = 0;
}

/// Shared comment list + composer (used by [CommentBottomSheet.show] and shorts inline overlay).
class CommentSheetPanel extends StatelessWidget {
  const CommentSheetPanel({
    super.key,
    required this.videoId,
    required this.channelId,
    required this.onClose,
  });

  final String videoId;
  final String channelId;
  final VoidCallback onClose;

  static final _commentController = Get.find<CommentController>();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        Container(
          width: SizeConfig.blockSizeHorizontal * 12,
          height: 3,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(60),
            color: AppColor.grey_100,
          ),
        ),
        SizedBox(height: SizeConfig.blockSizeVertical * 1),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(AppStrings.comments.tr, style: profileTitleStyle),
            IconButton(
              onPressed: () {
                AppSettings.showLog("CommentSheetPanel close");
                onClose();
              },
              icon: const ImageIcon(AssetImage(AppIcons.remove), size: 30),
            ),
          ],
        ),
        const Divider(indent: 5, endIndent: 5),
        SizedBox(
          height: 30,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.zero,
            itemCount: _commentTypeLabels().length,
            itemBuilder: (context, index) {
              return GetBuilder<CommentController>(
                id: "onChangeCommentType",
                builder: (controller) => GestureDetector(
                  onTap: () => controller.onChangeCommentType(index, videoId),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 2),
                    margin: const EdgeInsets.only(right: 5),
                    decoration: BoxDecoration(
                      color: controller.selectedCommentType != index
                          ? isDarkMode.value
                              ? Colors.transparent
                              : AppColor.white
                          : AppColor.primaryColor,
                      border: Border.all(color: AppColor.primaryColor),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Center(
                      child: Text(
                        _commentTypeLabels()[index],
                        textAlign: TextAlign.center,
                        style: GoogleFonts.urbanist(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: controller.selectedCommentType == index ? AppColor.white : AppColor.primaryColor,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: SizeConfig.blockSizeVertical * 1),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Obx(
              () => PreviewProfileImage(
                size: 40,
                id: Database.channelId ?? "",
                image: AppSettings.profileImage.value,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextFormField(
                controller: _commentController.commentController,
                keyboardType: TextInputType.multiline,
                minLines: 1,
                maxLines: 4,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: isDarkMode.value ? AppColor.secondDarkMode : AppColor.grey_200,
                  contentPadding: const EdgeInsets.only(left: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  hintText: AppStrings.addComments.tr,
                  hintStyle: GoogleFonts.urbanist(color: Colors.grey, fontSize: 14),
                  suffixIcon: IconButton(
                    onPressed: () async {
                      if (!AuthService.checkLogin()) return;
                      if (_commentController.commentController.text.isNotEmpty) {
                        FocusScope.of(context).requestFocus(FocusNode());

                        final messageText = _commentController.commentController.text;
                        _commentController.commentController.clear();

                        Get.dialog(barrierDismissible: false, const LoaderUi());
                        _commentController.advanceCustomChanges();
                        _commentController.customAddComment(messageText);
                        if (_commentController.isCommentAvailable == false) {
                          _commentController.onChangeCommentAvailable(true);
                        }

                        Get.back();

                        await CreateCommentApiClass.callApi(videoId, messageText);

                        await _commentController.typeWiseGetComment(_commentController.selectedCommentType, videoId);

                        if (_commentController.selectedCommentType != 0) {
                          _commentController.mainComments[0].clear();
                        }
                        if (_commentController.selectedCommentType != 1) {
                          _commentController.mainComments[1].clear();
                        }
                        if (_commentController.selectedCommentType != 2) {
                          _commentController.mainComments[2].clear();
                        }

                        CommentSheetSession.latestTotalComments =
                            _commentController.mainComments[_commentController.selectedCommentType].length;
                      } else {
                        AppSettings.showLog("Please enter your comment !!");
                      }
                    },
                    icon: const Icon(Icons.send_rounded, color: Colors.grey),
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: SizeConfig.blockSizeVertical * 0.5),
        const Divider(indent: 5, endIndent: 5),
        Expanded(
          child: SizedBox(
            height: 200,
            child: GetBuilder<CommentController>(
              id: "onChangeCommentAvailable",
              builder: (controller) => controller.isCommentAvailable == false
                  ? Center(child: Text(AppStrings.commentsNotAvailable.tr))
                  : GetBuilder<CommentController>(
                      id: "onChangeShimmer",
                      builder: (controller) {
                        if (!controller.commentInitialLoadDone) {
                          return const CommentShimmerUi();
                        }
                        final list = controller.mainComments[controller.selectedCommentType];
                        if (list.isEmpty) {
                          return Center(child: Text(AppStrings.dataNotFound.tr, style: GoogleFonts.urbanist(color: AppColor.grey)));
                        }
                        return SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              child: GetBuilder<CommentController>(
                                id: "onChangeCommentList",
                                builder: (controller) => ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: controller.mainComments[controller.selectedCommentType].length,
                                  padding: const EdgeInsets.only(left: 5),
                                  itemBuilder: (context, index) {
                                    return Column(
                                      children: [
                                        Row(
                                          children: [
                                            PreviewProfileImage(
                                              size: 30,
                                              id: controller.mainComments[controller.selectedCommentType][index].id ?? "",
                                              image: controller.mainComments[controller.selectedCommentType][index].userImage ?? "",
                                              fit: BoxFit.cover,
                                            ),
                                            SizedBox(width: SizeConfig.blockSizeHorizontal * 3),
                                            Flexible(
                                              fit: FlexFit.loose,
                                              child: Text(
                                                controller.mainComments[controller.selectedCommentType][index].fullName.toString(),
                                                style: GoogleFonts.urbanist(fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                            SizedBox(width: SizeConfig.blockSizeHorizontal * 3),
                                            Text(
                                              " •  ${controller.mainComments[controller.selectedCommentType][index].time}",
                                              style: GoogleFonts.urbanist(fontSize: 13),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: SizeConfig.blockSizeVertical * 2),
                                        SizedBox(
                                          width: SizeConfig.screenWidth / 1.1,
                                          child: Text(controller.mainComments[controller.selectedCommentType][index].commentText.toString(),
                                              style: GoogleFonts.urbanist(), maxLines: 3, overflow: TextOverflow.ellipsis),
                                        ),
                                        Row(
                                          children: [
                                            GetBuilder<CommentController>(
                                              id: "onChangeLike",
                                              builder: (controller) => GestureDetector(
                                                onTap: () async => controller.onPressLike(videoId, index),
                                                child: Container(
                                                  width: 50,
                                                  height: 50,
                                                  color: Colors.transparent,
                                                  child: Row(
                                                    children: [
                                                      ImageIcon(
                                                        AssetImage(controller.customChanges[controller.selectedCommentType][index]["isLike"] == true ? AppIcons.likeBold : AppIcons.like),
                                                        color: controller.customChanges[controller.selectedCommentType][index]["isLike"] == true ? AppColor.primaryColor : null,
                                                        size: 17,
                                                      ),
                                                      SizedBox(width: SizeConfig.blockSizeHorizontal * 3),
                                                      Text(
                                                        controller.customChanges[controller.selectedCommentType][index]["like"].toString(),
                                                        style: GoogleFonts.urbanist(fontSize: 13),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            GetBuilder<CommentController>(
                                              id: "onChangeDisLike",
                                              builder: (controller) => GestureDetector(
                                                onTap: () async => controller.onPressDisLike(videoId, index),
                                                child: Container(
                                                  width: 50,
                                                  height: 50,
                                                  color: Colors.transparent,
                                                  child: Row(
                                                    children: [
                                                      ImageIcon(
                                                        AssetImage(controller.customChanges[controller.selectedCommentType][index]["isDisLike"] ? AppIcons.disLikeBold : AppIcons.disLike),
                                                        color: controller.customChanges[controller.selectedCommentType][index]["isDisLike"] ? AppColor.primaryColor : null,
                                                        size: 17,
                                                      ),
                                                      SizedBox(width: SizeConfig.blockSizeHorizontal * 3),
                                                      Text(
                                                        controller.customChanges[controller.selectedCommentType][index]["disLike"].toString(),
                                                        style: GoogleFonts.urbanist(fontSize: 13),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            GetBuilder<CommentController>(
                                              id: "onChangeReplies",
                                              builder: (controller) => GestureDetector(
                                                onTap: () async {
                                                  final commentId = controller
                                                      .mainComments[controller.selectedCommentType][index].id;
                                                  if (commentId == null || commentId.isEmpty) {
                                                    AppSettings.showLog("Reply skipped: missing comment id");
                                                    return;
                                                  }
                                                  controller.customChanges[controller.selectedCommentType][index]["reply"] = await ReplyBottomSheet.show(
                                                    context,
                                                    index,
                                                    videoId,
                                                    commentId,
                                                    controller.customChanges[controller.selectedCommentType][index]["reply"],
                                                  );

                                                  controller.onChangeReplies();
                                                },
                                                child: Container(
                                                  width: 50,
                                                  height: 50,
                                                  color: Colors.transparent,
                                                  child: Row(
                                                    children: [
                                                      const ImageIcon(AssetImage(AppIcons.reply), size: 17),
                                                      SizedBox(width: SizeConfig.blockSizeHorizontal * 3),
                                                      Text(
                                                        controller.customChanges[controller.selectedCommentType][index]["reply"].toString(),
                                                        style: GoogleFonts.urbanist(fontSize: 13),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const Divider(indent: 5, endIndent: 5),
                                        SizedBox(height: SizeConfig.blockSizeVertical * 1),
                                      ],
                                    );
                                  },
                                ),
                              ),
                        );
                      },
                    ),
                  ),
                ),
              ),
          ],
    );
  }

  List<String> _commentTypeLabels() => ["top".tr, "newest".tr, "mostLiked".tr];
}

/// Inline comments + mini shorts preview (single [Chewie] — hide full-screen player while this is visible).
class ShortsCommentsWithMiniPlayer extends StatelessWidget {
  const ShortsCommentsWithMiniPlayer({
    super.key,
    required this.videoPlayerController,
    required this.chewieController,
    required this.videoId,
    required this.channelId,
    required this.onClose,
  });

  final VideoPlayerController videoPlayerController;
  final ChewieController chewieController;
  final String videoId;
  final String channelId;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.sizeOf(context).height;
    final miniH = (h * 0.30).clamp(160.0, 280.0);
    final v = videoPlayerController.value;
    final double videoW;
    final double videoH;
    if (v.isInitialized && v.size.width > 0 && v.size.height > 0) {
      videoW = v.size.width;
      videoH = v.size.height;
    } else {
      videoW = 9;
      videoH = 16;
    }
    return SafeArea(
      child: Column(
        children: [
          SizedBox(
            height: miniH,
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: ColoredBox(
                  color: Colors.black,
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: videoW,
                      height: videoH,
                      child: Chewie(controller: chewieController),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Material(
              color: isDarkMode.value ? AppColor.secondDarkMode : AppColor.white,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              clipBehavior: Clip.antiAlias,
              child: Padding(
                padding: EdgeInsets.only(
                  left: SizeConfig.blockSizeHorizontal * 4,
                  right: SizeConfig.blockSizeHorizontal * 3,
                ),
                child: CommentSheetPanel(
                  videoId: videoId,
                  channelId: channelId,
                  onClose: onClose,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
