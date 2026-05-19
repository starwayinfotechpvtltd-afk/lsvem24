import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:metube/database/database.dart';
import 'package:metube/pages/custom_pages/file_upload_page/file_upload_model.dart';
import 'package:metube/utils/constant/app_constant.dart';
import 'package:metube/utils/settings/app_settings.dart';

class CreateAdsApi {
  static bool? status;
  static String? message;

  static Future<bool> callApi({
    String? title,
    String? description,
    String? country,
    String? state,
    String? type,
    String? category,
    String? adRuns,
    String? city,
    String? budget,
    File? image,
    File? video,
  }) async {
    status = null;
    message = "";
    AppSettings.showLog("Create Ads Api Calling...");
    print("Ads calling..");
    print(video);

    try {
      String? imageUrl;

      if (image != null) {
        imageUrl = await _uploadFile(
          file: image,
          folderStructure: "${Constant.folderStructurePath}/adsImage",
          extension: "jpg",
        );

        if (imageUrl == null) {
          message = "Image upload failed";
          return false;
        }
      } else {
        imageUrl = "";
      }

      String? videoUrl;

      if (video != null) {
        videoUrl = await _uploadFile(
          file: video,
          folderStructure: "${Constant.folderStructurePath}/adsVideo",
          extension: "mp4",
        );

        if (videoUrl == null) {
          message = "Video upload failed";
          return false;
        }
      } else {
        videoUrl = "";
      }

      print(
          'URI: ${Constant.baseURL + Constant.createAds}?userId=${Database.loginUserId}');
      final uri = Uri.parse(
          '${Constant.baseURL + Constant.createAds}?userId=${Database.loginUserId}');

      final headers = {
        "key": Constant.secretKey,
        "Content-Type": "application/json",
      };

      final body = jsonEncode({
        "title": title ?? "",
        "description": description ?? "",
        "country": country ?? "",
        "state": state ?? "",
        "city": city ?? "",
        "type": type ?? "",
        "category": category ?? "",
        "budget": budget ?? "",
        "adRuns": adRuns ?? "",
        "image": imageUrl ?? "",
        "video": videoUrl ?? "",
      });

      AppSettings.showLog("Create Ads Api Request => $body");

      final response = await http.post(uri, headers: headers, body: body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = json.decode(response.body);

        status = jsonResponse["status"];
        message = jsonResponse["message"];

        AppSettings.showLog("Create Ads Api Response => ${response.body}");
        return status == true;
      } else {
        print("STATUS CODE => ${response.statusCode}");
        print("RESPONSE => ${response.body}");

        message = response.body;
        AppSettings.showLog(
            "Create Ads Api Error => ${response.statusCode} ${response.reasonPhrase}");
      }
    } catch (e) {
      message = e.toString();
      AppSettings.showLog("Create Ads Api Error => $e");
    }

    return false;
  }

  static Future<String?> _uploadFile({
    required File file,
    required String folderStructure,
    required String extension,
  }) async {
    try {
      final request = http.MultipartRequest(
        "PUT",
        Uri.parse(Constant.baseURL + Constant.fileUpload),
      );

      request.headers.addAll({"key": Constant.secretKey});
      request.fields.addAll({
        "folderStructure": folderStructure,
        "keyName": "${DateTime.now().millisecondsSinceEpoch}.$extension",
      });
      request.files
          .add(await http.MultipartFile.fromPath("content", file.path));

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final fileUploadModel =
            FileUploadModel.fromJson(jsonDecode(responseBody));
        AppSettings.showLog("Create Ads File Upload => ${fileUploadModel.url}");
        return fileUploadModel.url;
      }

      AppSettings.showLog(
          "Create Ads File Upload Error => ${response.statusCode} $responseBody");
    } catch (e) {
      AppSettings.showLog("Create Ads File Upload Error => $e");
    }

    return null;
  }
}
