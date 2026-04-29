import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AiRecommendationService {
  final String _apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';

  final String _baseUrl =
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-lite:generateContent";
  Future<String> getRecommendation({
    required List<Map<String, dynamic>> kalisthenicHistory,
  }) async {
    try {
      if (_apiKey.isEmpty) return "API Key tidak ditemukan di .env";

      final prompt = _buildPrompt(kalisthenicHistory: kalisthenicHistory);

      final response = await http.post(
        Uri.parse("$_baseUrl?key=$_apiKey"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": prompt},
              ],
            },
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'];
      } else {
        print("Error API: ${response.body}");
        return "Coach AI lagi sibuk, coba bentar lagi ya!";
      }
    } catch (e) {
      print("Error Connection: $e");
      return "Gagal terhubung ke Coach AI.";
    }
  }

  String _buildPrompt({
    required List<Map<String, dynamic>> kalisthenicHistory,
  }) {
    // ... (samakan dengan kode buildPrompt kamu yang lama) ...
    final summary = kalisthenicHistory.isEmpty
        ? "Belum ada sesi"
        : kalisthenicHistory
              .map((e) => "- ${e['level_nama']}, progress ${e['progress']}%")
              .join('\n');

    return "Kamu adalah coach fitness FluxFit. Berikan analisis dan motivasi singkat untuk data ini:\n$summary";
  }
}
