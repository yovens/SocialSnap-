import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ImgBBService {
  final String _apiKey = "6af56b5d2a71117a5a3e330a2e3ac5bc"; // Mete API Key ou a la

  /// Upload senp, san pwogresyon (kenbe pou retwokonpatibilite ak lòt kòd).
  Future<String?> uploadImage(File imageFile) async {
    return uploadImageWithProgress(imageFile);
  }

  /// 🟢 Upload ak yon vrè pousantaj pwogresyon (0.0 → 1.0), kalkile sou kantite
  /// bytes ki reyèlman voye pandan http ap anvwaye rekèt la, san nou pa bezwen
  /// ajoute yon lòt package (dio, elatriye) — 'http' ase.
  Future<String?> uploadImageWithProgress(
    File imageFile, {
    void Function(double progress)? onProgress,
  }) async {
    final url = Uri.parse("https://api.imgbb.com/1/upload?key=$_apiKey");

    final multipartRequest = http.MultipartRequest('POST', url);
    multipartRequest.files.add(
      await http.MultipartFile.fromPath('image', imageFile.path),
    );

    final totalBytes = multipartRequest.contentLength;
    int bytesSent = 0;

    // Byte stream final ki gen antèt miltipart + kò fichye a.
    final finalizedStream = multipartRequest.finalize();

    // Nou entèsepte chak moso (chunk) pou konte konbyen bytes ki soti deja,
    // epi nou rapòte pousantaj la bay `onProgress`.
    final trackedStream = finalizedStream.transform<List<int>>(
      StreamTransformer.fromHandlers(
        handleData: (List<int> chunk, EventSink<List<int>> sink) {
          bytesSent += chunk.length;
          if (onProgress != null && totalBytes > 0) {
            onProgress((bytesSent / totalBytes).clamp(0.0, 1.0));
          }
          sink.add(chunk);
        },
      ),
    );

    final streamedRequest = http.StreamedRequest('POST', url)
      ..headers.addAll(multipartRequest.headers)
      ..contentLength = totalBytes;

    trackedStream.listen(
      (chunk) => streamedRequest.sink.add(chunk),
      onDone: () => streamedRequest.sink.close(),
      onError: (e, st) => streamedRequest.sink.addError(e, st),
      cancelOnError: true,
    );

    final client = http.Client();
    try {
      final response = await client.send(streamedRequest);
      final responseBody = await http.Response.fromStream(response);

      if (response.statusCode == 200) {
        final json = jsonDecode(responseBody.body);
        return json['data']['url']; // Sa a se URL piblik la!
      }
      return null;
    } finally {
      client.close();
    }
  }
}
