import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather by IP',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: const WeatherScreen(),
    );
  }
}

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});
  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  String weatherInfo = 'Loading...';
  bool loading = true;

  final String apiKey = '7fcf7e2dc57bb07d5cdec6faadb72ae2';

  @override
  void initState() {
    super.initState();
    fetchLocationAndWeather();
  }

  Future<void> fetchLocationAndWeather() async {
    setState(() {
      loading = true;
    });

    try {
      final locationResponse = await http.get(Uri.parse('http://ip-api.com/json'));

      if (locationResponse.statusCode != 200) {
        throw 'Could not fetch location';
      }

      final locationData = jsonDecode(locationResponse.body);
      final lat = locationData['lat'];
      final lon = locationData['lon'];
      final city = locationData['city'];

      final weatherResponse = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric&lang=en',
      ));

      if (weatherResponse.statusCode != 200) {
        throw 'Could not fetch weather data';
      }

      final weatherData = jsonDecode(weatherResponse.body);
      final temp = weatherData['main']['temp'];
      final description = weatherData['weather'][0]['description'];

      setState(() {
        weatherInfo = '📍 $city\n🌡 $temp°C\n🌥 $description';
        loading = false;
      });
    } catch (e) {
      setState(() {
        weatherInfo = 'Error: $e';
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Weather by IP')),
      body: Center(
        child: loading
            ? const CircularProgressIndicator()
            : Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  weatherInfo,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: fetchLocationAndWeather,
        tooltip: 'Refresh',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
