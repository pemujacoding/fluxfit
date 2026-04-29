import 'dart:convert';
import 'package:http/http.dart' as http;
//import 'package:flutter_dotenv/flutter_dotenv.dart';

class AiRecommendationService {
  final String _apiKey = 'AIzaSyBfhVv-xIEwSr-eISFw4L7ucJJ8oo4tcn4';
  final String _baseUrl =
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-lite:generateContent";

  Future<String> getRecommendation({
    required List<Map<String, dynamic>> checkInHistory,
    required List<Map<String, dynamic>> joggingHistory,
    required List<Map<String, dynamic>> kalisthenicHistory,
  }) async {
    try {
      if (_apiKey.isEmpty) return "API Key tidak ditemukan di .env";

      final prompt = _buildPrompt(
        checkInHistory: checkInHistory,
        joggingHistory: joggingHistory,
        kalisthenicHistory: kalisthenicHistory,
      );

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
    required List<Map<String, dynamic>> checkInHistory,
    required List<Map<String, dynamic>> joggingHistory,
    required List<Map<String, dynamic>> kalisthenicHistory,
  }) {
    final checkInSummary = checkInHistory.isEmpty
        ? "Belum ada check-in"
        : "${checkInHistory.length} hari check-in tercatat, "
              "terakhir: ${checkInHistory.first['datetime']}";

    final joggingSummary = joggingHistory.isEmpty
        ? "Belum ada sesi jogging"
        : joggingHistory
              .map((e) {
                final jarak = e['jarak'] != null
                    ? "${e['jarak']} km"
                    : "jarak tidak tercatat";
                final langkah = e['langkah'] != null
                    ? "${e['langkah']} langkah"
                    : "";
                return "- ${e['datetime']}: $jarak${langkah.isNotEmpty ? ', $langkah' : ''}";
              })
              .join('\n');

    final kalisthenicSummary = kalisthenicHistory.isEmpty
        ? "Belum ada sesi kalistenik"
        : kalisthenicHistory
              .map(
                (e) =>
                    "- ${e['datetime']}: level ${e['level_nama']}, selesai ${e['progress']}%",
              )
              .join('\n');

    return """
Kamu adalah AI fitness coach aplikasi FluxFit. Analisis data latihan pengguna berikut dan berikan rekomendasi personal.

CHECK-IN (7 hari terakhir):
$checkInSummary

JOGGING (3 sesi terakhir):
$joggingSummary

KALISTENIK (3 sesi terakhir):
$kalisthenicSummary

Balas dalam format ini, singkat dan langsung ke poin:
📊 ANALISIS: (2 kalimat ringkasan performa)
🏃 JOGGING: (saran sesi berikutnya berdasarkan data)
💪 KALISTENIK: (saran sesuai level dan progress)
🔥 MOTIVASI: (1 kalimat motivasi personal)

Bahasa Indonesia, ramah, tidak bertele-tele.
""";
  }
}
