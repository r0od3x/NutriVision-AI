import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/prediction.dart';

class ApiService {
  // API address, set at build time:
  //   flutter run --dart-define=API_URL=http://192.168.1.20:8000
  // Default 10.0.2.2 is the host machine as seen from the Android emulator
  // (use http://localhost:8000 on the iOS simulator).
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://10.0.2.2:8000',
  );

  /// Vérifie que l'API est accessible.
  static Future<bool> healthCheck() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/health'))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Envoie une image et reçoit les prédictions nutritionnelles.
  static Future<PredictionResult> predict(File imageFile) async {
    final uri = Uri.parse('$baseUrl/predict');

    final request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    final streamedResponse = await request.send().timeout(
      const Duration(seconds: 30),
    );

    if (streamedResponse.statusCode != 200) {
      final body = await streamedResponse.stream.bytesToString();
      throw Exception('Erreur API (${streamedResponse.statusCode}): $body');
    }

    final responseBody = await streamedResponse.stream.bytesToString();
    final json = jsonDecode(responseBody) as Map<String, dynamic>;
    return PredictionResult.fromJson(json);
  }
}
