import 'package:weather_app_tommorow/features/weather/domain/entity/weather_entity.dart';
import 'package:weather_app_tommorow/features/weather/domain/repository/weather_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:weather_app_tommorow/core/error/failure.dart';

class GetCurrentWeatherUseCase {
  final WeatherRepository _repository;
   GetCurrentWeatherUseCase(this._repository);

  Future<Either<Failure, WeatherEntity>> call(String cityName) {
    return _repository.getCurrentWeather(cityName);
  }
}