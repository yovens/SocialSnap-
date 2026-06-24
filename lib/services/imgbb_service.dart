import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ImgBBService {
  final String _apiKey = "6af56b5d2a71117a5a3e330a2e3ac5bc"; // Mete API Key ou a la

  Future<String?> uploadImage(File imageFile) async {
    final url = Uri.parse("https://api.imgbb.com/1/upload?key=$_apiKey");
    
    var request = http.MultipartRequest('POST', url);
    request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
    
    var response = await request.send();
    if (response.statusCode == 200) {
      var responseData = await response.stream.bytesToString();
      var json = jsonDecode(responseData);
      return json['data']['url']; // Sa a se URL piblik la!
    }
    return null;
  }
}