import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:metube/pages/custom_pages/comment_page/get_all_reply_api.dart';
import 'package:metube/pages/custom_pages/comment_page/get_all_reply_model.dart';
import 'package:metube/pages/custom_pages/comment_page/like_dislike_comment_api.dart';
import 'package:metube/utils/settings/app_settings.dart';

class RepliesController extends GetxController {
  GetAllReplyModel? getAllReplyModel;
  // final _commentController = Get.find<CommentController>();

  List<RepliesOfComment> mainReplies = [];

  //  This Code Use To Changes in Comment....

  // bool isLikeComment = false;
  // bool isDisLikeComment = false;
  // Map customChangeComment = {"likes": 0, "disLikes": 0, "replies": 0};
  //
  // void onAddCustomChangeComment(int commentType, int commentIndex) {
  //   isLikeComment = _commentController.mainComments[commentType][commentIndex].isLike!;
  //   isDisLikeComment = _commentController.mainComments[commentType][commentIndex].isDislike!;
  //   customChangeComment["likes"] = _commentController.mainComments[commentType][commentIndex].like;
  //   customChangeComment["disLikes"] = _commentController.mainComments[commentType][commentIndex].dislike;
  //   customChangeComment["replies"] = _commentController.mainComments[commentType][commentIndex].totalReplies;
  //   update(["onCustomComment"]);
  // }
  //
  // void onLikeComment(String loginUserId, String commentId) async {
  //   if (isLikeComment) {
  //     isLikeComment = !isLikeComment;
  //     customChangeComment["likes"]--;
  //   } else {
  //     isLikeComment = !isLikeComment;
  //     customChangeComment["likes"]++;
  //     if (isDisLikeComment) {
  //       isDisLikeComment = !isDisLikeComment;
  //       customChangeComment["disLikes"]--;
  //     }
  //     update(["onCustomComment"]);
  //     await LikeDisLikeCommentApi.callApi(loginUserId, commentId, true);
  //   }
  // }
  //
  // void onDisLikeComment(String loginUserId, String commentId) async {
  //   if (isDisLikeComment) {
  //     isDisLikeComment = !isDisLikeComment;
  //     customChangeComment["disLikes"]--;
  //   } else {
  //     isDisLikeComment = !isDisLikeComment;
  //     customChangeComment["disLikes"]++;
  //     if (isLikeComment) {
  //       isLikeComment = !isLikeComment;
  //       customChangeComment["likes"]--;
  //     }
  //     update(["onCustomComment"]);
  //     await LikeDisLikeCommentApi.callApi(loginUserId, commentId, false);
  //   }
  // }

  // ------------------

  List customChanges = [];

  bool isRepliesAvailable = true;

  final ScrollController scrollController = ScrollController();

  TextEditingController repliesController = TextEditingController();

  Future<void> getAllReplies(String loginUserId, String videoId, String commentId) async {
    getAllReplyModel = await GetAllReplyApi.callApi(loginUserId, videoId, commentId);

    if (getAllReplyModel != null) {
      mainReplies = getAllReplyModel?.repliesOfComment ?? [];
      update(["onChangeRepliesAvailable"]);

      for (int index = 0; index < mainReplies.length; index++) {
        insertIntoCustomChanges(index);
      }
      update(["onChangeReplyList"]);
    }
    AppSettings.showLog("Custom Changes =>  $customChanges");

    AppSettings.showLog("Total Reply => ${mainReplies.length}");
  }

  void insertIntoCustomChanges(int index) {
    customChanges.add({
      "isLike": bool.parse(mainReplies[index].isLike.toString()),
      "isDisLike": bool.parse(mainReplies[index].isDislike.toString()),
      "like": mainReplies[index].like,
      "disLike": mainReplies[index].dislike,
    });
  }

  void onPressLike(String loginUserId, String videoId, String commentId, int index) async {
    AppSettings.showLog("Comment Id => ${mainReplies[index].id}");

    if (!customChanges[index]["isLike"]) {
      AppSettings.showLog("Is Already Not Liked");
      if (customChanges[index]["isDisLike"] == true) {
        AppSettings.showLog("Remove DisLike");
        customChanges[index]["isDisLike"] = false;
        customChanges[index]["disLike"]--;
        update(["onChangeDisLike"]);
      } else {
        AppSettings.showLog("No DisLike Available");
      }
      customChanges[index]["isLike"] = true;
      customChanges[index]["like"]++;
      update(["onChangeLike"]);
      await LikeDisLikeCommentApi.callApi(
        loginUserId,
        mainReplies[index].id!,
        true,
      );
      getAllReplies(loginUserId, videoId, commentId);
    } else {
      AppSettings.showLog("Is Already Liked");
    }
  }

  void onPressDisLike(String loginUserId, String videoId, String commentId, int index) async {
    AppSettings.showLog("Comment Id => ${mainReplies[index].id}");
    if (!(customChanges[index]["isDisLike"] ?? false)) {
      AppSettings.showLog("Is Already Not DisLiked");
      if (customChanges[index]["isLike"] == true) {
        AppSettings.showLog("Remove Like");
        customChanges[index]["isLike"] = false;
        customChanges[index]["like"]--;
        update(["onChangeLike"]);
      } else {
        AppSettings.showLog("No Like Available");
      }
      customChanges[index]["isDisLike"] = true;
      customChanges[index]["disLike"]++;
      update(["onChangeDisLike"]);
      await LikeDisLikeCommentApi.callApi(
        loginUserId,
        mainReplies[index].id!,
        false,
      );
      getAllReplies(loginUserId, videoId, commentId);
    } else {
      AppSettings.showLog("Is Already DisLiked");
    }
  }

  void customAddComment(String loginUserImage, String loginUserName, String messageText) {
    mainReplies.insert(
        0,
        RepliesOfComment(
          isLike: false,
          isDislike: false,
          like: 0,
          dislike: 0,
          totalReplies: 0,
          time: "now",
          commentText: messageText,
          userImage: loginUserImage,
          fullName: loginUserName,
        ));
    update(["onChangeReplyList"]);
  }

  void onCheckReplies(bool value) {
    isRepliesAvailable = value;
    update(["onChangeRepliesAvailable"]);
  }

  void advanceChanges() {
    customChanges.add({"isLike": false, "like": 0, "disLike": 0});
  }
}
