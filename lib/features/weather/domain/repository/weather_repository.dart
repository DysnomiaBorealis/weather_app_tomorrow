import 'package:dartz/dartz.dart';
import 'package:weather_app_tommorow/core/error/failure.dart';
import 'package:weather_app_tommorow/features/weather/domain/entity/weather_entity.dart';

abstract class WeatherRepository {
  Future<Either<Failure, WeatherEntity>> getCurrentWeather(String cityName);
    Future<Either<Failure, List<WeatherEntity>>> getHourlyForecast(
    String cityName,
  );
  Future<Either<Failure, List<WeatherEntity>>> getWeatherHistory(String cityName);
}

