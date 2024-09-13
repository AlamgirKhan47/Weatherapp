import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class WeatherService with ChangeNotifier {
  String _apiKey = 'YOUR_API_KEY';
  Map<String, dynamic> _weatherData = {};

  Map<String, dynamic> get weatherData => _weatherData;

  Future<void> fetchWeather(String city) async {
    final response = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$_apiKey&units=metric'));
    if (response.statusCode == 200) {
      _weatherData = json.decode(response.body);
      notifyListeners();
    } else {
      throw Exception('Failed to load weather data');
    }
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => WeatherService(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'WeatherX',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: WeatherDashboard(),
        routes: {
          '/forecast': (context) => ForecastScreen(),
          '/search': (context) => SearchScreen(),
        },
      ),
    );
  }
}

class WeatherDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final weatherService = Provider.of<WeatherService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Weather Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () => Navigator.pushNamed(context, '/search'),
          ),
        ],
      ),
      body: Center(
        child: weatherService.weatherData.isEmpty
            ? Text('No weather data available')
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Temperature: ${weatherService.weatherData['main']['temp']}°C',
                    style: TextStyle(fontSize: 24),
                  ),
                  Text(
                    'Condition: ${weatherService.weatherData['weather'][0]['description']}',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
      ),
    );
  }
}

class ForecastScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('7-Day Forecast'),
      ),
      body: Center(
        child: Text('Forecast data will be shown here'),
      ),
    );
  }
}

class SearchScreen extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final weatherService = Provider.of<WeatherService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Search City'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(labelText: 'Enter city name'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await weatherService.fetchWeather(_controller.text);
                Navigator.pop(context);
              },
              child: Text('Get Weather'),
            ),
          ],
        ),
      ),
    );
  }
}
