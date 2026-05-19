import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:metube/main.dart';
import 'package:metube/pages/custom_pages/comment_page/comment_controller.dart';
import 'package:metube/pages/custom_pages/comment_page/comment_sheet_panel.dart';
import 'package:metube/utils/colors/app_color.dart';
import 'package:metube/utils/config/size_config.dart';
import 'package:metube/utils/settings/app_settings.dart';

class CommentBottomSheet {
  static final _commentController = Get.find<CommentController>();

  /// Safe parse for counts stored in [RxMap] / JSON (avoids cast errors).
  static int commentCountFrom(dynamic raw) {
    if (raw == null) return 0;
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    return int.tryParse(raw.toString()) ?? 0;
  }

  /// Clears cached lists and loads comments for [videoId]. Call before showing inline or modal UI.
  static void prepareCommentsForVideo(String videoId, int previousTotalComment) {
    CommentSheetSession.latestTotalComments = previousTotalComment;

    _commentController.customChanges[0].clear();
    _commentController.customChanges[1].clear();
    _commentController.customChanges[2].clear();

    _commentController.mainComments[0].clear();
    _commentController.mainComments[1].clear();
    _commentController.mainComments[2].clear();

    _commentController.commentInitialLoadDone = false;
    _commentController.onChangeCommentAvailable(true);
    _commentController.selectedCommentType = 0;
    _commentController.typeWiseGetComment(0, videoId);
  }

  /// Prefer tab 0 length when dismissing (matches previous modal behavior).
  static int syncLatestCommentTotal() {
    if (_commentController.mainComments[0].isNotEmpty) {
      CommentSheetSession.latestTotalComments = _commentController.mainComments[0].length;
    }
    return CommentSheetSession.latestTotalComments;
  }

  static Future<int> show(BuildContext context, String videoId, String channelId, int previousTotalComment, {VoidCallback? callback}) async {
    prepareCommentsForVideo(videoId, previousTotalComment);

    await Get.bottomSheet(
      Builder(
        builder: (ctx) {
          final mq = MediaQuery.of(ctx);
          final h = mq.size.height;
          final kb = mq.viewInsets.bottom;
          final preferred = SizeConfig.screenHeight * 0.58;
          final maxWhenTyping = h - kb - h * 0.22;
          final sheetH = math.min(preferred, maxWhenTyping).clamp(200.0, h);
          return Container(
            padding: EdgeInsets.only(left: SizeConfig.blockSizeHorizontal * 4, right: SizeConfig.blockSizeHorizontal * 3),
            height: sheetH,
            child: CommentSheetPanel(
              videoId: videoId,
              channelId: channelId,
              onClose: () {
                AppSettings.showLog("TAPP PERFECT ${callback != null}");
                Get.back();
                callback?.call();
              },
            ),
          );
        },
      ),
      isScrollControlled: true,
      persistent: false,
      barrierColor: Colors.transparent,
      backgroundColor: isDarkMode.value ? AppColor.secondDarkMode : AppColor.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
    );

    return syncLatestCommentTotal();
  }
}
