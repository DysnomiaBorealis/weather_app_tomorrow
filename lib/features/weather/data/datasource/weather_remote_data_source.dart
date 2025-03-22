import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:weather_app_tommorow/api/key.dart';
import 'package:weather_app_tommorow/api/urls.dart';
import 'package:weather_app_tommorow/core/error/exception.dart';
import 'package:weather_app_tommorow/features/weather/data/model/weather_model.dart';

abstract class WeatherRemoteDataSource {
  Future<WeatherModel> getCurrentWeather(String cityName);
  Future<List<WeatherModel>> getHourlyForecast(String cityName);
}

class WeatherRemoteDataSourceImpl implements WeatherRemoteDataSource {
  final http.Client client;

  WeatherRemoteDataSourceImpl(this.client);

  @override
  Future<WeatherModel> getCurrentWeather(String cityName) async {
    try {
      final Uri url = URLs.getRealtimeWeatherUrl(cityName, apiKey);
      print('Calling API: $url'); // Debug URL

      final response = await client.get(url);
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        // Success handling
        final Map<String, dynamic> jsonMap = json.decode(response.body);
        return WeatherModel.fromJson(jsonMap);
      } else if (response.statusCode == 404) {
        throw NotFoundException();
      } else {
        print('Server error with code: ${response.statusCode}');
        throw ServerException();
      }
    } catch (e) {
      print('Error type: ${e.runtimeType}');
      print('Error details: $e');
      throw ServerException();
    }
  }

  @override
  Future<List<WeatherModel>> getHourlyForecast(String cityName) async {
    try {
      final Uri url = URLs.getForecastWeatherUrl(cityName, apiKey);
      print('Calling Forecast API: $url'); // Debug URL

      final response = await client.get(url);
      print('Forecast Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonMap = json.decode(response.body);
        print('API response structure: ${jsonMap.keys}'); // Log the structure

        // Check if response contains expected structure
        if (!jsonMap.containsKey('timelines')) {
          print('Error: Missing "timelines" key in response');
          throw ServerException();
        }

        final Map<String, dynamic> timelines = jsonMap['timelines'];
        print('Timelines structure: ${timelines.keys}'); // Log timeline keys

        if (!timelines.containsKey('hourly')) {
          print('Error: Missing "hourly" key in timelines');
          throw ServerException();
        }

        final List<dynamic> hourlyData = timelines['hourly'];
        print('Found ${hourlyData.length} hourly entries');

        // Log first item structure to debug format
        if (hourlyData.isNotEmpty) {
          print('First hourly item structure: ${hourlyData.first.keys}');
          print('First hourly values: ${hourlyData.first['values']}');
        }

        // Extract location information for setting city name
        String localCityName = cityName;
        if (jsonMap.containsKey('location') && jsonMap['location'] is Map) {
          final location = jsonMap['location'] as Map<String, dynamic>;
          if (location.containsKey('name')) {
            localCityName = location['name'] as String;
          }
        }

        return hourlyData.map<WeatherModel>((hourData) {
          try {
            final model = WeatherModel.fromHourlyJson(hourData);
            // Set the city name from the parent response
            return WeatherModel(
              id: model.id,
              main: model.main,
              description: model.description,
              icon: model.icon,
              temperature: model.temperature,
              pressureSurfaceLevel: model.pressureSurfaceLevel,
              humidity: model.humidity,
              wind: model.wind,
              dateTime: model.dateTime,
              cityName: localCityName,
            );
          } catch (e) {
            print('Error parsing hourly item: $e');
            print('Problematic data: $hourData');
            throw ServerException();
          }
        }).toList();
      } else if (response.statusCode == 404) {
        throw NotFoundException();
      } else {
        print('Server error with code: ${response.statusCode}');
        throw ServerException();
      }
    } catch (e) {
      print('Error type: ${e.runtimeType}');
      print('Error details: $e');
      throw ServerException();
    }
  }
}
