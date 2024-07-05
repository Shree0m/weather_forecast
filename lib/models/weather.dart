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

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      cityName: json['name'],
      temperature: json['main']['temp'],
      weatherCondition: json['weather'][0]['main'],
      weatherIcon: json['weather'][0]['icon'],
      humidity: json['main']['humidity'],
      windSpeed: json['wind']['speed'],
    );
  }
}
