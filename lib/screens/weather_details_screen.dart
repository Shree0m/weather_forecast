import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';

class WeatherDetailsScreen extends StatelessWidget {
  const WeatherDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width >= 600;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: const BackButton(color: Colors.white),
        centerTitle: true,
        title: Text('Weather Details', style: TextStyle(fontSize: isTablet ? 28 : 20, color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () async {
              final provider = Provider.of<WeatherProvider>(context, listen: false);
              if (provider.lastSearchedCity != null) {
                await provider.fetchWeather(provider.lastSearchedCity!);
                if (provider.errorMessage != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${provider.errorMessage}')),
                  );
                }
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.home, color: Colors.white),
            onPressed: () {
              Navigator.pop(context); // Navigate back to the HomeScreen
            },
          ),
        ],
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black.withOpacity(0.6), Colors.transparent],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      body: Consumer<WeatherProvider>(
        builder: (context, weatherProvider, child) {
          if (weatherProvider.isLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (weatherProvider.weather == null) {
            return Center(child: Text('No weather data available.'));
          } else {
            final weather = weatherProvider.weather!;
            final backgroundImageUrl = _getBackgroundImageUrl(weather.weatherCondition ?? '');

            return Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  backgroundImageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    // Handle image loading error
                    return Container(
                      color: Colors.grey,
                      child: Center(
                        child: Text(
                          'Failed to load image',
                          style: TextStyle(color: Colors.white, fontSize: isTablet ? 28 : 20),
                        ),
                      ),
                    );
                  },
                ),
                Center(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(isTablet ? 32.0 : 16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          weather.cityName ?? 'Unknown City',
                          style: TextStyle(fontSize: isTablet ? 36 : 24, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        SizedBox(height: 10),
                        Text(
                          '${weather.temperature ?? '--'} °C',
                          style: TextStyle(fontSize: isTablet ? 48 : 36, color: Colors.white),
                        ),
                        SizedBox(height: 10),
                        Text(
                          weather.weatherCondition ?? 'Unknown Condition',
                          style: TextStyle(fontSize: isTablet ? 28 : 20, color: Colors.white),
                        ),
                        SizedBox(height: 10),
                        if (weather.weatherIcon != null)
                          Image.network(
                            'http://openweathermap.org/img/wn/${weather.weatherIcon}@2x.png',
                            width: isTablet ? 150 : 100,
                            height: isTablet ? 150 : 100,
                            color: Colors.white,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(Icons.image_not_supported, size: isTablet ? 150 : 100, color: Colors.white);
                            },
                          ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _WeatherInfoTile(
                              icon: Icons.opacity,
                              label: 'Humidity',
                              value: '${weather.humidity ?? '--'}%',
                            ),
                            SizedBox(width: isTablet ? 40 : 20),
                            _WeatherInfoTile(
                              icon: Icons.speed,
                              label: 'Wind Speed',
                              value: '${weather.windSpeed ?? '--'} m/s',
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context); // Navigate back to the HomeScreen
                          },
                          icon: Icon(Icons.home),
                          label: Text('Back to Home'),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              horizontal: isTablet ? 32.0 : 16.0,
                              vertical: isTablet ? 20.0 : 16.0,
                            ),
                            textStyle: TextStyle(fontSize: isTablet ? 24 : 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  String _getBackgroundImageUrl(String weatherCondition) {
    // Map weather conditions to appropriate background image URLs
    switch (weatherCondition.toLowerCase()) {
      case 'clear sky':
        return 'https://media.istockphoto.com/id/491701259/photo/blue-sky-with-sun.jpg?s=612x612&w=0&k=20&c=aB7c-e0YFezBb8cgSykiEcAh_2fXEie3inIudnsNa9g=';
      case 'clouds':
      case 'overcast clouds':
        return 'https://www.shutterstock.com/image-photo/dark-sky-heavy-clouds-converging-600nw-2220607227.jpg';
      case 'rain':
      case 'moderate rain':
        return 'https://i.pinimg.com/564x/fd/31/1c/fd311c46fc22e9f7ecc35cdb40741462.jpg';
      case 'thunderstorm':
        return 'https://png.pngtree.com/thumb_back/fw800/background/20240104/pngtree-thunderstorm-clouds-in-the-sky-with-lighting-bad-weather-image_15563127.jpg';
      case 'light intensity shower rain':
        return 'https://www.metoffice.gov.uk/binaries/content/gallery/metofficegovuk/images/weather/learn-about/weather/rain-storm.jpg';
      case 'fog':
      case 'mist':
      case 'haze':
        return 'https://media.kvue.com/assets/KVUE/images/fa1d778e-df02-4de0-92eb-73a26c90b463/fa1d778e-df02-4de0-92eb-73a26c90b463_750x422.jpg';
      case 'few clouds':
        return 'https://i.pinimg.com/originals/bd/62/e0/bd62e0fca42b5f52dcc81091dfe7a317.jpg';
      case 'broken clouds':
        return 'https://static.vecteezy.com/system/resources/previews/015/127/111/large_2x/scattered-clouds-in-the-sky-indicating-a-change-in-weather-free-photo.jpg';
      case 'snow':
        return 'https://c1.wallpaperflare.com/preview/595/440/866/snow-winter-white-cold.jpg';
      default:
        return 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQhM45QcQdWHbBl-NvOekgO8CvEmMJAlMYeMA&s';
    }
  }
}

class _WeatherInfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _WeatherInfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.black.withOpacity(0.5), // Semi-transparent background for better readability
      ),
      child: Row(
        children: [
          Icon(icon, size: 24, color: Colors.white),
          SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 16, color: Colors.white)),
              Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          ),
        ],
      ),
    );
  }
}
