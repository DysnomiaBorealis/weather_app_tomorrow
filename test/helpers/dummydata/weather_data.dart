import 'package:weather_app_tommorow/features/weather/domain/entity/weather_entity.dart';
import 'package:weather_app_tommorow/features/weather/data/model/weather_model.dart';

const tCityName = 'Zocca';

final tWeatherEntity = WeatherEntity(
  id: 1100,
  main: 'Mostly Clear',
  description: 'Mostly Clear',
  icon: 'assets/icons/Mostly Clear.png',
  temperature: 25,
  pressureSurfaceLevel: 1000,
  humidity: 50,
  wind: 5,
  dateTime: DateTime.parse('2023-01-26T07:48:00Z'),
  cityName: tCityName,
);

final tWeatherModel = WeatherModel(
  id: 1100,
  main: 'Mostly Clear',
  description: 'Mostly Clear',
  icon: 'assets/icons/Mostly Clear.png',
  temperature: 25,
  pressureSurfaceLevel: 1000,
  humidity: 50,
  wind: 5,
  dateTime: DateTime.parse('2023-01-26T07:48:00Z'),
  cityName: tCityName,
);

final Map<String, dynamic> tWeatherJsonMap = {
  "currentWeather": {
    "data": {
      "time": "2023-01-26T07:48:00Z",
      "values": {
        "temperature": 25,
        "pressureSurfaceLevel": 1000,
        "humidity": 50,
        "windSpeed": 5,
        // Use 1100 as the weather code
        "weatherCode": 1100,
      }
    },
    "location": {
      "name": tCityName,
    },
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
  
  }
};