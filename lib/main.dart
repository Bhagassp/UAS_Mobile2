import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_svg/flutter_svg.dart';

class WeatherApi {
  static const String apiKey = 'f34f0ef2d5844346b6970552230707';

  static Future<Map<String, dynamic>> fetchWeather(String city) async {
    final response = await http.get(Uri.parse(
        'http://api.weatherapi.com/v1/current.json?key=$apiKey&q=$city'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch weather');
    }
  }
}

class WeatherForecastApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather Forecast',
      theme: ThemeData(
        primarySwatch: Colors.grey,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: WeatherForecastScreen(),
    );
  }
}

class WeatherForecastScreen extends StatefulWidget {
  @override
  _WeatherForecastScreenState createState() => _WeatherForecastScreenState();
}

class _WeatherForecastScreenState extends State<WeatherForecastScreen> {
  TextEditingController _textEditingController = TextEditingController();
  Map<String, dynamic>? _weatherData;

  void _fetchWeatherData(String city) {
    WeatherApi.fetchWeather(city)
        .then((data) => setState(() => _weatherData = data))
        .catchError((error) => print(error));
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  String getWeatherIconUrl(String iconCode) {
    return 'http:${iconCode.substring(2)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather Forecast'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: TextField(
              controller: _textEditingController,
              decoration: InputDecoration(
                labelText: 'Enter city name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _fetchWeatherData(_textEditingController.text),
              child: Text('Get Weather'),
            ),
          ),
          SizedBox(height: 20.0),
          if (_weatherData != null)
            Column(
              children: [
                Text(
                  'City: ${_weatherData!['location']['name']}',
                  style: TextStyle(fontSize: 24.0),
                ),
                Text(
                  'Country: ${_weatherData!['location']['country']}',
                  style: TextStyle(fontSize: 20.0),
                ),
                SizedBox(height: 10.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.network(
                      getWeatherIconUrl(
                          _weatherData!['current']['condition']['icon']),
                      height: 60.0,
                      width: 60.0,
                    ),
                    SizedBox(width: 10.0),
                    Text(
                      '${_weatherData!['current']['temp_c']}°C',
                      style: TextStyle(fontSize: 48.0),
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }
}

void main() {
  runApp(WeatherForecastApp());
}
