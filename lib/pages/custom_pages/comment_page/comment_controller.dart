import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:metube/database/database.dart';
import 'package:metube/pages/custom_pages/comment_page/get_all_comment_api.dart';
import 'package:metube/pages/custom_pages/comment_page/get_all_comment_model.dart';
import 'package:metube/pages/custom_pages/comment_page/like_dislike_comment_api.dart';
import 'package:metube/utils/settings/app_settings.dart';
import 'package:metube/utils/utils.dart';

class CommentController extends GetxController {
  TextEditingController commentController = TextEditingController();

  List<List<VideoComment>> mainComments = [[], [], []];
  List<bool> isCommentRefresh = [false, false, false];
  List<List> customChanges = <List>[[], [], []];

  int selectedCommentType = 0;
  bool isCommentAvailable = true;

  /// After [typeWiseGetComment] finishes for the current request (empty list is valid).
  bool commentInitialLoadDone = false;

  void onChangeCommentAvailable(bool value) {
    isCommentAvailable = value;
    update(["onChangeCommentAvailable"]);
  }

  Future<void> typeWiseGetComment(int commentType, String videoId) async {
    commentInitialLoadDone = false;
    update(["onChangeShimmer"]);
    try {
      mainComments[commentType] = (await GetAllCommentApi.callApi(videoId, commentType)) ?? [];
      final list = mainComments[commentType];
      if (list.isNotEmpty) {
        Utils.showLog("COMMENT WISE ==> ${list.first.commentText} Name : ${list.first.fullName}");
      }
      customChanges[commentType].clear();

      for (int index = 0; index < list.length; index++) {
        insertIntoCustomChanges(commentType, index);
      }
    } finally {
      commentInitialLoadDone = true;
      update(["onChangeShimmer", "onChangeCommentAvailable"]);
    }
  }

  void onChangeCommentType(int index, String videoId) {
    selectedCommentType = index;
    if (mainComments[0].isEmpty || mainComments[1].isEmpty || mainComments[2].isEmpty) {
      if (mainComments[selectedCommentType].isEmpty) {
        typeWiseGetComment(selectedCommentType, videoId);
      }
    }

    update(["onChangeCommentType", "onChangeCommentList"]);

    if (mainComments[0].isEmpty || mainComments[1].isEmpty || mainComments[2].isEmpty) {
      update(["onChangeShimmer"]);
    }
  }

  // Future getAllComment(String videoId) async {
  //   if (mainComments[0].isEmpty) {
  //     for (int commentType = 0; commentType < mainComments.length; commentType++) {
  //       mainComments[commentType] = (await GetAllCommentApi.callApi(videoId, commentType)) ?? [];
  //       update(["onChangeShimmer"]);
  //       customChanges[commentType].clear();
  //
  //       for (int index = 0; index < mainComments[commentType].length; index++) {
  //         insertIntoCustomChanges(commentType, index);
  //       }
  //     }
  //   } else {
  //     for (int commentType = 0; commentType < mainComments.length; commentType++) {
  //       mainComments[commentType] = (await GetAllCommentApi.callApi(videoId, commentType)) ?? [];
  //
  //       customChanges[commentType].clear();
  //
  //       for (int index = 0; index < mainComments[commentType].length; index++) {
  //         insertIntoCustomChanges(commentType, index);
  //       }
  //     }
  //     update(["onChangeShimmer"]);
  //   }
  //   if (mainComments[0].isEmpty) {
  //     isCommentAvailable = false;
  //     update(["onChangeCommentAvailable"]);
  //   }
  //
  //   update(["onChangeDisLike"]);
  // }

  void insertIntoCustomChanges(int commentType, int index) {
    customChanges[commentType].add({
      "isLike": bool.parse(mainComments[commentType][index].isLike.toString()),
      "isDisLike": bool.parse(mainComments[commentType][index].isDislike.toString()),
      "like": mainComments[commentType][index].like,
      "disLike": mainComments[commentType][index].dislike,
      "reply": mainComments[commentType][index].totalReplies
    });
  }

  void advanceCustomChanges() {
    customChanges[0].add({"isLike": false, "isDisLike": false, "like": 0, "disLike": 0, "reply": 0});
    customChanges[1].insert(0, {"isLike": false, "isDisLike": false, "like": 0, "disLike": 0, "reply": 0});
    customChanges[2].add({"isLike": false, "isDisLike": false, "like": 0, "disLike": 0, "reply": 0});
  }

  void onChangeReplies() {
    update(["onChangeReplies"]);
  }

  void onPressLike(String videoId, int index) async {
    AppSettings.showLog("Comment Id => ${mainComments[selectedCommentType][index].id}");

    if (!customChanges[selectedCommentType][index]["isLike"]) {
      AppSettings.showLog("Is Already Not Liked");
      if (customChanges[selectedCommentType][index]["isDisLike"] == true) {
        AppSettings.showLog("Remove DisLike");
        customChanges[selectedCommentType][index]["isDisLike"] = false;
        customChanges[selectedCommentType][index]["disLike"]--;
        update(["onChangeDisLike"]);
      } else {
        AppSettings.showLog("No DisLike Available");
      }
      customChanges[selectedCommentType][index]["isLike"] = true;
      customChanges[selectedCommentType][index]["like"]++;
      update(["onChangeLike"]);
      await LikeDisLikeCommentApi.callApi(
        Database.loginUserId!,
        mainComments[selectedCommentType][index].id!,
        true,
      );
      typeWiseGetComment(selectedCommentType, videoId);
      if (selectedCommentType != 0) {
        // isCommentRefresh[0] = true;
        mainComments[0].clear();
      }
      if (selectedCommentType != 1) {
        // isCommentRefresh[1] = true;
        mainComments[1].clear();
      }
      if (selectedCommentType != 2) {
        // isCommentRefresh[2] = true;
        mainComments[2].clear();
      }
    } else {
      AppSettings.showLog("Is Already Liked");
    }
  }

  void onPressDisLike(String videoId, int index) async {
    AppSettings.showLog("Comment Id => ${mainComments[selectedCommentType][index].id}");
    if (!customChanges[selectedCommentType][index]["isDisLike"]) {
      AppSettings.showLog("Is Already Not DisLiked");
      if (customChanges[selectedCommentType][index]["isLike"] == true) {
        AppSettings.showLog("Remove Like");
        customChanges[selectedCommentType][index]["isLike"] = false;
        customChanges[selectedCommentType][index]["like"]--;
        update(["onChangeLike"]);
      } else {
        AppSettings.showLog("No Like Available");
      }
      customChanges[selectedCommentType][index]["isDisLike"] = true;
      customChanges[selectedCommentType][index]["disLike"]++;
      update(["onChangeDisLike"]);
      await LikeDisLikeCommentApi.callApi(
        Database.loginUserId!,
        mainComments[selectedCommentType][index].id!,
        false,
      );
      typeWiseGetComment(selectedCommentType, videoId);
      if (selectedCommentType != 0) {
        // isCommentRefresh[0] = true;
        mainComments[0].clear();
      }
      if (selectedCommentType != 1) {
        // isCommentRefresh[1] = true;
        mainComments[1].clear();
      }
      if (selectedCommentType != 2) {
        // isCommentRefresh[2] = true;
        mainComments[2].clear();
      }
    } else {
      AppSettings.showLog("Is Already DisLiked");
    }
  }

  void customAddComment(String messageText) {
    mainComments[0].add(VideoComment(
      isLike: false,
      isDislike: false,
      like: 0,
      dislike: 0,
      totalReplies: 0,
      time: "now",
      commentText: messageText,
      userImage: AppSettings.profileImage.value,
      fullName: AppSettings.channelName.value,
    ));
    mainComments[1].insert(
        0,
        VideoComment(
          isLike: false,
          isDislike: false,
          like: 0,
          dislike: 0,
          totalReplies: 0,
          time: "now",
          commentText: messageText,
          userImage: AppSettings.profileImage.value,
          fullName: AppSettings.channelName.value,
        ));
    mainComments[2].add(VideoComment(
      isLike: false,
      isDislike: false,
      like: 0,
      dislike: 0,
      totalReplies: 0,
      time: "now",
      commentText: messageText,
      userImage: AppSettings.profileImage.value,
      fullName: AppSettings.channelName.value,
    ));
    update(["onChangeCommentList"]);
  }
}
