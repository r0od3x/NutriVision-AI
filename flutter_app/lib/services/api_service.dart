import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/prediction.dart';

class ApiService {
  // ── Change cette URL selon ton setup ──
  // Local : http://10.0.2.2:8000  (émulateur Android)
  //         http://localhost:8000  (iOS simulator)
  //         http://<IP_LAN>:8000  (device physique)
  // ngrok : https://xxxx.ngrok-free.app
  static String baseUrl = 'http://10.0.2.2:8000';

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
