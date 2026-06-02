import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
 
  // - Real Android phone → use your WiFi IP (run ipconfig on Windows)
  // - Example: static const String baseUrl = 'http://192.168.1.5:5000';
  static const String baseUrl = 'http://172.31.98.152:5000';

  /// 📤 Upload video to Flask and get analysis result
  static Future<Map<String, dynamic>> analyzeVideo({
    required File videoFile,
    required String exerciseType,
  }) async {
    try {
      // Create multipart request
      final uri = Uri.parse('$baseUrl/analyze_video');
      final request = http.MultipartRequest('POST', uri);

      // Attach video file
      request.files.add(
        await http.MultipartFile.fromPath('video', videoFile.path),
      );

      // Attach exercise type
      request.fields['exercise'] = exerciseType;

      // Send request
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 120), // 2 min timeout for video processing
      );

      // Parse response
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['error'] ?? 'Server error: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('Cannot connect to server. Make sure Flask is running.');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  /// 🏓 Check if Flask server is running
  static Future<bool> pingServer() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/ping'))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}