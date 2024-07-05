import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import 'weather_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController cityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final weatherProvider = Provider.of<WeatherProvider>(context, listen: false);
      await weatherProvider.loadLastSearchedCity();
      if (weatherProvider.lastSearchedCity != null && weatherProvider.errorMessage == null) {
        cityController.text = weatherProvider.lastSearchedCity!;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const WeatherDetailsScreen()),
        );
      } else if (weatherProvider.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${weatherProvider.errorMessage}')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width >= 600;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('Weather App', style: TextStyle(fontSize: isTablet ? 28 : 20, color: Colors.white)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background image with transparency
          Positioned.fill(
            child: Opacity(
              opacity: 1, // Adjust the opacity to your preference
              child: Image.network(
                'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRTdTdQlJqi-0h8cggRE6pDNJ7JWK7gC9PVJXDTrXpFm6_BNsr4oyeUMyw5SkyhuXccXo0', // Replace with your image path
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Foreground content
          Center(
            child: Padding(
              padding: EdgeInsets.all(isTablet ? 32.0 : 16.0),
              child: Consumer<WeatherProvider>(
                builder: (context, weatherProvider, child) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Card(
                        elevation: 8.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
                          child: Column(
                            children: [
                              TextField(
                                controller: cityController,
                                decoration: InputDecoration(
                                  labelText: 'Enter city name',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.location_city),
                                ),
                              ),
                              SizedBox(height: isTablet ? 20 : 10),
                              ElevatedButton(
                                onPressed: () async {
                                  String city = cityController.text;
                                  if (city.isNotEmpty) {
                                    await weatherProvider.fetchWeather(city);
                                    if (weatherProvider.errorMessage == null) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => WeatherDetailsScreen()),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Error: ${weatherProvider.errorMessage}')),
                                      );
                                    }
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Please enter a city name')),
                                    );
                                  }
                                },
                                child: Text('Get Weather'),
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(horizontal: isTablet ? 32.0 : 16.0, vertical: isTablet ? 16.0 : 12.0),
                                  textStyle: TextStyle(fontSize: isTablet ? 24 : 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                ),
                              ),
                              if (weatherProvider.isLoading)
                                Padding(
                                  padding: const EdgeInsets.only(top: 20.0),
                                  child: CircularProgressIndicator(),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
