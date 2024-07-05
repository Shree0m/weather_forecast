import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Weather {
  final String cityName;
  final double temperature;
  final String weatherCondition;
  final String weatherIcon;
  final int humidity;
  final double windSpeed;

  Weather({
    required this.cityName,
    required this.temperature,
    required this.weatherCondition,
    required this.weatherIcon,
    required this.humidity,
    required this.windSpeed,
  });
}

class WeatherProvider with ChangeNotifier {
  Weather? _weather;
  bool _isLoading = false;
  String? _errorMessage;
  String? _lastSearchedCity;

  Weather? get weather => _weather;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get lastSearchedCity => _lastSearchedCity;

  Future<void> fetchWeather(String city) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final url = 'https://api.openweathermap.org/data/2.5/weather?q=$city&units=metric&appid=bcf82f05b149098f6866f4c40f5ae91b';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _weather = Weather(
          cityName: data['name'],
          temperature: data['main']['temp'].toDouble(),
          weatherCondition: data['weather'][0]['description'],
          weatherIcon: data['weather'][0]['icon'],
          humidity: data['main']['humidity'],
          windSpeed: data['wind']['speed'].toDouble(),
        );
        _lastSearchedCity = city;
        await _saveLastSearchedCity(city);
      } else {
        _handleHttpError(response);
      }
    } catch (error) {
      _errorMessage = 'Failed to load weather data';
      print(_errorMessage); // Log the error for debugging
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _handleHttpError(http.Response response) {
    switch (response.statusCode) {
      case 400:
        _errorMessage = 'Bad request. Please check the city name.';
        break;
      case 401:
        _errorMessage = 'Unauthorized. Please check your API key.';
        break;
      case 404:
        _errorMessage = 'City not found. Please enter a valid city name.';
        break;
      case 500:
        _errorMessage = 'Server error. Please try again later.';
        break;
      default:
        _errorMessage = 'Unexpected error: ${response.statusCode}';
    }
    print(_errorMessage); // Log the error for debugging
  }

  Future<void> _saveLastSearchedCity(String city) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('lastSearchedCity', city);
    } catch (e) {
      print('Failed to save last searched city: $e');
    }
  }

  Future<void> loadLastSearchedCity() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _lastSearchedCity = prefs.getString('lastSearchedCity');
      if (_lastSearchedCity != null) {
        await fetchWeather(_lastSearchedCity!);
      }
    } catch (e) {
      print('Failed to load last searched city: $e');
    }
  }
}
