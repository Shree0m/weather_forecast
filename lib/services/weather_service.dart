import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather.dart';

class WeatherService {
  static const String apiKey = 'bcf82f05b149098f6866f4c40f5ae91b';
  static const String apiUrl = 'https://api.openweathermap.org/data/2.5/weather';

  static Future<Weather?> fetchWeather(String cityName) async {
    try {
      final response = await http.get(Uri.parse('$apiUrl?q=$cityName&appid=$apiKey&units=metric'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Weather.fromJson(data);
      } else {
        throw Exception('Failed to load weather');
      }
    } catch (e) {
      throw Exception('Error fetching weather data: $e');
    }
  }
}
