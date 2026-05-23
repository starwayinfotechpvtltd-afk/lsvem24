import 'package:flutter_image_compress/flutter_image_compress.dart';

class ImageCompressor {

static Future<String?> compress(
String path,
) async {

final output =
"${path}_small.jpg";

final result =
await FlutterImageCompress.compressAndGetFile(
path,
output,
quality: 92,
minWidth: 1280,
minHeight: 720,
);

return result?.path;

}
}