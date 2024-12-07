import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ImageKitService {
  final String apiKey = "private_nIpg06eAsJ8uHraR9e54BV+ijro=";
  final String uploadUrl = "https://upload.imagekit.io/api/v1/files/upload";

  Future<String?> uploadImage(File imageFile) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
      request.fields['fileName'] =
          'image_${DateTime.now().millisecondsSinceEpoch}';
      request.fields['useUniqueFileName'] = 'true';
      request.fields['folder'] = '/barang';
      request.headers['Authorization'] =
          'Basic ${base64Encode(utf8.encode(apiKey + ':'))}';

      request.files
          .add(await http.MultipartFile.fromPath('file', imageFile.path));

      final response = await request.send();
      final responseBody = await http.Response.fromStream(response);

      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody.body);
        return data['url'];
      } else {
        print('Error uploading image: ${responseBody.body}');
        return null;
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }
}
