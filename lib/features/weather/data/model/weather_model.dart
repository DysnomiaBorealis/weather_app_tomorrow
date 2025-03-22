import 'package:weather_app_tommorow/features/weather/domain/entity/weather_entity.dart';
import 'package:weather_app_tommorow/common/app_constant.dart';

class WeatherModel extends WeatherEntity {
  const WeatherModel({
    required super.id,
    required super.main,
    required super.description,
    required super.icon,
    required super.temperature,
    required super.pressureSurfaceLevel,
    required super.humidity,
    required super.wind,
    required super.dateTime,
    required super.cityName,
  });

  // This method is used for current weather data
  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    try {
      if (json.containsKey('time')) {
        // This is hourly forecast data format
        return WeatherModel.fromHourlyJson(json);
      }

      // The Tomorrow.io API response structure for current weather
      final data = json['data'] as Map<String, dynamic>;
      final values = data['values'] as Map<String, dynamic>;
      final location = json['location'] as Map<String, dynamic>;

      // Get weather code from values
      final int weatherCode = values['weatherCode'] as int;
      final String weatherDescription = getWeatherDescription(weatherCode);
      final String iconAsset = getWeatherIcon(weatherDescription);

      return WeatherModel(
        id: weatherCode,
        main: weatherDescription,
        description: weatherDescription,
        icon: iconAsset,
        temperature: values['temperature'] as num,
        pressureSurfaceLevel: values['pressureSurfaceLevel'] as num? ?? 0,
        humidity: values['humidity'] as num,
        wind: values['windSpeed'] as num,
        dateTime: DateTime.parse(data['time'] as String),
        cityName: location['name'] as String,
      );
    } catch (e) {
      print('Error in fromJson: $e');
      print('Problem with JSON: $json');
      rethrow;
    }
  }

  // New method for hourly forecast data
  factory WeatherModel.fromHourlyJson(Map<String, dynamic> json) {
    try {
      final String time = json['time'] as String;
      final Map<String, dynamic> values =
          json['values'] as Map<String, dynamic>;

      final int weatherCode = values['weatherCode'] as int;
      final String weatherDescription = getWeatherDescription(weatherCode);
      final String iconAsset = getWeatherIcon(weatherDescription);

      // Handle missing fields with defaults
      num pressureSurface = 0;
      if (values.containsKey('pressureSurfaceLevel')) {
        pressureSurface = values['pressureSurfaceLevel'] as num;
      }

      return WeatherModel(
        id: weatherCode,
        main: weatherDescription,
        description: weatherDescription,
        icon: iconAsset,
        temperature: values['temperature'] as num,
        pressureSurfaceLevel: pressureSurface,
        humidity: values['humidity'] as num,
        wind: values['windSpeed'] as num,
        dateTime: DateTime.parse(time),
        cityName: "N/A", // Cityname might not be available in hourly data
      );
    } catch (e) {
      print('Error in fromHourlyJson: $e');
      print('Problem with JSON: $json');
      rethrow;
    }
  }

  // Helper method to get weather description
  static String getWeatherDescription(int code) {
    final Map<String, String> weatherCodeMap = {
      '1000': 'Clear, Sunny',
      '1100': 'Mostly Clear',
      '1101': 'Partly Cloudy',
      '1102': 'Mostly Cloudy',
      '1001': 'Cloudy',
      '1103': 'Partly Cloudy and Mostly Clear',
      '2100': 'Light Fog',
      '2000': 'Fog',
      '4000': 'Drizzle',
      '4001': 'Rain',
      '4200': 'Light Rain',
      '4201': 'Heavy Rain',
      '5000': 'Snow',
      '5001': 'Flurries',
      '5100': 'Light Snow',
      '5101': 'Heavy Snow',
      '6000': 'Freezing Drizzle',
      '6001': 'Freezing Rain',
      '6200': 'Light Freezing Rain',
      '6201': 'Heavy Freezing Rain',
      '7000': 'Ice Pellets',
      '7101': 'Heavy Ice Pellets',
      '7102': 'Light Ice Pellets',
      '8000': 'Thunderstorm',
    };

    return weatherCodeMap[code.toString()] ?? 'Unknown';
  }

  // Helper method to get weather icon
  static String getWeatherIcon(String description) {
    return AppConstant.weatherIconMapper[description] ??
        'assets/icons/Unknown.png';
  }

  Map<String, dynamic> toJson() => {
        "currentWeather": {
          "data": {
            "time": dateTime.toUtc().toIso8601String().replaceAll('.000Z', 'Z'),
            "values": {
              "temperature": temperature,
              "pressureSurfaceLevel": pressureSurfaceLevel,
              "humidity": humidity,
              "windSpeed": wind,
              // Use id to represent the weather code
              "weatherCode": id,
            }
          },
          "location": {
            "name": cityName,
          }
        },
        "iconMappings": {
          "weatherCodeFullDay": {
            "0": "Unknown",
            "1000": "Clear, Sunny",
            "1100": "Mostly Clear",
            "1101": "Partly Cloudy",
            "1102": "Mostly Cloudy",
            "1001": "Cloudy",
            "1103": "Partly Cloudy and Mostly Clear",
            "2100": "Light Fog",
            "8000": "Thunderstorm",
          },
        },
      };

  WeatherEntity get toEntity => WeatherEntity(
        id: id,
        main: main,
        description: description,
        icon: icon,
        temperature: temperature,
        pressureSurfaceLevel: pressureSurfaceLevel,
        humidity: humidity,
        wind: wind,
        dateTime: dateTime,
        cityName: cityName,
      );
}
