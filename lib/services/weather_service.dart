import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  final String apiKey = "d6a524e325a8eeffa9f05d6578716208"; // Put your key here
  final String city = "Yogyakarta"; // You can change this to your city

  Future<Map<String, dynamic>> fetchWeather() async {
    final url = Uri.parse(
      'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception("Gagal mengambil data cuaca");
      }
    } catch (e) {
      rethrow;
    }
  }
}
