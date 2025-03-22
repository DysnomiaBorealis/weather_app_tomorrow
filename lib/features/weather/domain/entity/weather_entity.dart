import 'package:equatable/equatable.dart';
import 'package:weather_app_tommorow/common/app_constant.dart';

class WeatherEntity extends Equatable {
  final int id;
  final String main;
  final String description;
  final String icon;
  final num temperature;
  final num pressureSurfaceLevel;
  final num humidity;
  final num wind;
  final DateTime dateTime;
  final String? cityName;

  const WeatherEntity({
    required this.id,
    required this.main,
    required this.description,
    required this.icon,
    required this.temperature,
    required this.pressureSurfaceLevel,
    required this.humidity,
    required this.wind,
    required this.dateTime,
    this.cityName,
  });

  factory WeatherEntity.fromJson(Map<String, dynamic> json) {
    final currentWeather = json['currentWeather'] as Map<String, dynamic>;
    final data = currentWeather['data'] as Map<String, dynamic>;
    final values = data['values'] as Map<String, dynamic>;
    final location = currentWeather['location'] as Map<String, dynamic>;

    // Extract weather code from JSON.
    final int weatherCode = values['weatherCode'] as int;

    // Retrieve weather description from the iconMappings.
    final iconMappings = json['iconMappings'] as Map<String, dynamic>;
    final weatherCodeFullDay = iconMappings['weatherCodeFullDay'] as Map<String, dynamic>;
    final String weatherDescription = weatherCodeFullDay[weatherCode.toString()] as String;

    // Use the AppConstant mapping to get the adjacent image/icon.
    final String iconAsset = AppConstant.weatherIconMapper[weatherDescription] ?? 'assets/icons/default.png';

    return WeatherEntity(
      id: weatherCode,
      // Since your JSON doesn't supply a "main", you can assign the description to both.
      main: weatherDescription,
      description: weatherDescription,
      icon: iconAsset,
      temperature: values['temperature'] as num,
      pressureSurfaceLevel: values['pressureSurfaceLevel'] as num,
      humidity: values['humidity'] as num,
      wind: values['windSpeed'] as num,
      dateTime: DateTime.parse(data['time'] as String),
      cityName: location['name'] as String?,
    );
  }

  @override
  List<Object?> get props {
    return [
      id,
      main,
      description,
      icon,
      temperature,
      pressureSurfaceLevel,
      humidity,
      wind,
      dateTime,
      cityName,
    ];
  }
}