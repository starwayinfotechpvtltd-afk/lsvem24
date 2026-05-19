import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:metube/main.dart';
import 'package:metube/utils/colors/app_color.dart';
import 'package:metube/utils/icons/app_icons.dart';
import 'package:metube/utils/services/convert_to_network.dart';

class PreviewProfileImage extends StatelessWidget {
  const PreviewProfileImage({
    super.key,
    required this.id,
    required this.image,
    required this.size,
    required this.fit,
  });

  final String id;
  final String image;
  final double size;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      height: size,
      width: size,
      decoration: const BoxDecoration(shape: BoxShape.circle),
      child: CachedNetworkImage(
        imageUrl: ConvertToNetwork.resolve(image),
        fit: fit,
        // imageBuilder: (context, imageProvider) => Image(
        //   image: ResizeImage(imageProvider, width: 600, height: 500),
        //   fit: fit,
        // ),
        placeholder: (context, url) => Image.asset(AppIcons.profileImage, fit: fit),
        errorWidget: (context, url, error) => Image.asset(AppIcons.profileImage, fit: fit),
      ),
    );
  }
}

class PreviewVideoImage extends StatelessWidget {
  const PreviewVideoImage({super.key, required this.videoId, required this.videoImage, this.fit});

  final String videoId;
  final String videoImage;
  final BoxFit? fit;

  @override
  Widget build(BuildContext context) {
    final imageUrl = ConvertToNetwork.resolve(videoImage);
    if (imageUrl.isEmpty) {
      return _placeholder();
    }

    return SizedBox.expand(
      child: CachedNetworkImage(
        fit: fit ?? BoxFit.cover,
        imageUrl: imageUrl,
        useOldImageOnUrlChange: true,
        placeholder: (context, url) => _placeholder(),
        errorWidget: (context, string, dynamic) => _placeholder(),
      ),
    );
  }

  Widget _placeholder() {
    return Center(
      child: Image.asset(
        AppIcons.logo,
        color: isDarkMode.value ? AppColor.primaryColor : AppColor.white,
        width: 50,
      ),
    );
  }
}

class PreviewNetworkImage extends StatelessWidget {
  const PreviewNetworkImage({super.key, required this.image, required this.id, required this.fit});

  final String id;
  final String image;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return image == ""
        ? fit == BoxFit.contain
            ? Image.asset(AppIcons.profileImage, fit: BoxFit.cover)
            : const Offstage()
        : CachedNetworkImage(
            imageUrl: ConvertToNetwork.resolve(image),
            fit: fit,
            errorWidget: (context, url, error) => fit == BoxFit.contain ? Image.asset(AppIcons.profileImage, fit: BoxFit.cover) : const Offstage(),
          );
  }
}

// _onConvertVideo(videoId: videoId, videoImage: videoImage);
// return Database.onGetImageUrl(videoId) != null || (Database.onGetImageUrl(videoId)?.isNotEmpty ?? false)
//     ? CachedNetworkImage(
//         height: Get.height,
//         width: Get.width,
//         fit: BoxFit.cover,
//         imageUrl: Database.onGetImageUrl(videoId)!,
//         useOldImageOnUrlChange: true,
//         placeholder: (context, url) => Center(child: Image.asset(AppIcons.logo, color: isDarkMode.value ? AppColors.primaryColor : AppColors.white, width: 50)),
//         errorWidget: (context, string, dynamic) => Center(child: Image.asset(AppIcons.logo, color: isDarkMode.value ? AppColors.primaryColor : AppColors.white, width: 50)),
//       )
//     : FutureBuilder(
//         future: ConvertToNetwork.convert(videoImage),
//         builder: (context, snapshot) {
//           if (snapshot.hasData) {
//             if (snapshot.data!.isEmpty) {
//               return Center(child: Image.asset(AppIcons.logo, color: isDarkMode.value ? AppColors.primaryColor : AppColors.white, width: 50));
//             } else {
//               Database.onSetImageUrl(videoId, snapshot.data!);
//               return CachedNetworkImage(
//                 height: Get.height,
//                 width: Get.width,
//                 fit: BoxFit.cover,
//                 imageUrl: snapshot.data!,
//                 useOldImageOnUrlChange: false,
//                 placeholder: (context, url) => Center(child: Image.asset(AppIcons.logo, color: isDarkMode.value ? AppColors.primaryColor : AppColors.white, width: 50)),
//                 errorWidget: (context, string, dynamic) => Center(child: Image.asset(AppIcons.logo, color: isDarkMode.value ? AppColors.primaryColor : AppColors.white, width: 50)),
//               );
//             }
//           }
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: Image.asset(AppIcons.logo, color: isDarkMode.value ? AppColors.primaryColor : AppColors.white, width: 50));
//           }
//           return const Offstage();
//         },
//       );

// void onConvertShorts({required channelId, required channelImage}) async {
//   final imagePath = await ConvertToNetwork.convert(channelImage);
//
//   if (imagePath != "") {
//     Database.onSetChannelImageUrl(channelId, imagePath);
//   }
// }
//
// void onConvertVideo({required videoId, required videoImage}) async {
//   final imagePath = await ConvertToNetwork.convert(videoImage);
//
//   if (imagePath != "") {
//     Database.onSetImageUrl(videoId, imagePath);
//   }
// }

// class PreviewChannelImage extends StatelessWidget {
//   const PreviewChannelImage({super.key, required this.channelId, required this.channelImage, this.fit});
//
//   final String channelId;
//   final String channelImage;
//   final BoxFit? fit;
//
//   @override
//   Widget build(BuildContext context) {
//     return CachedNetworkImage(
//       height: Get.height,
//       width: Get.width,
//       fit: fit ?? BoxFit.cover,
//       imageUrl: channelImage,
//       useOldImageOnUrlChange: true,
//       placeholder: (context, url) => Center(child: Image.asset(AppIcons.profileImage, color: isDarkMode.value ? AppColors.primaryColor : AppColors.white, width: 50)),
//       errorWidget: (context, string, dynamic) => Center(child: Image.asset(AppIcons.profileImage, color: isDarkMode.value ? AppColors.primaryColor : AppColors.white, width: 50)),
//     );
//     //
//     // // AppSettings.showLog("Channel Id => $channelId : Channel Image => $channelImage");
//     //
//     // _onConvertShorts(channelId: channelId, channelImage: channelImage);
//     //
//     // return Database.onGetChannelImageUrl(channelId) != null
//     //     ? CachedNetworkImage(
//     //         height: Get.height,
//     //         width: Get.width,
//     //         fit:fit ?? BoxFit.cover,
//     //         imageUrl: Database.onGetChannelImageUrl(channelId)!,
//     //         useOldImageOnUrlChange: true,
//     //         placeholder: (context, url) => Center(child: Image.asset(AppIcons.profileImage, fit: BoxFit.cover)),
//     //         errorWidget: (context, string, dynamic) => Center(child: Image.asset(AppIcons.profileImage, fit: BoxFit.cover)),
//     //       )
//     //     : FutureBuilder(
//     //         future: ConvertToNetwork.convert(channelImage),
//     //         builder: (context, snapshot) {
//     //           if (snapshot.hasData) {
//     //             if (snapshot.data!.isEmpty) {
//     //               return Center(child: Image.asset(AppIcons.profileImage, fit: BoxFit.cover));
//     //             } else {
//     //               Database.onSetChannelImageUrl(channelId, snapshot.data!);
//     //
//     //               return CachedNetworkImage(
//     //                 height: Get.height,
//     //                 width: Get.width,
//     //                 fit: fit ?? BoxFit.cover,
//     //                 imageUrl: snapshot.data!,
//     //                 useOldImageOnUrlChange: false,
//     //                 placeholder: (context, url) => Center(child: Image.asset(AppIcons.profileImage, fit: BoxFit.cover)),
//     //                 errorWidget: (context, string, dynamic) => Center(child: Image.asset(AppIcons.profileImage, fit: BoxFit.cover)),
//     //               );
//     //             }
//     //           }
//     //           if (snapshot.hasError) {
//     //             return Center(child: Image.asset(AppIcons.profileImage, fit: BoxFit.cover));
//     //           }
//     //           if (snapshot.connectionState == ConnectionState.waiting) {
//     //             return Center(child: Image.asset(AppIcons.profileImage, fit: BoxFit.cover));
//     //           }
//     //           return const Offstage();
//     //         },
//     //       );
//   }
// }

//----------------------

// Stack(
// children: [
// AspectRatio(
// aspectRatio: 1,
// child: Container(
// height: size,
// width: size,
// decoration: const BoxDecoration(shape: BoxShape.circle),
// child: Image.asset(AppIcons.profileImage, fit: BoxFit.cover),
// ),
// ),
// AspectRatio(
// aspectRatio: 1,
// child: Container(
// height: size,
// width: size,
// decoration: BoxDecoration(
// shape: BoxShape.circle,
// color: fit == BoxFit.contain ? AppColors.white : null,
// ),
// child: PreviewNetworkImage(image: image, id: id, fit: fit),
// ),
// ),
// ],
// ),
