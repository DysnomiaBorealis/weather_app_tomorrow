import 'package:dartz/dartz.dart';
import 'package:weather_app_tommorow/core/error/failure.dart';
import 'package:weather_app_tommorow/features/weather/domain/entity/weather_entity.dart';
import 'package:weather_app_tommorow/features/weather/domain/repository/weather_repository.dart';

class GetHourlyForecastUseCase {
  final WeatherRepository _repository;

  GetHourlyForecastUseCase(this._repository);

  Future<Either<Failure, List<WeatherEntity>>> call(String cityName) {
    return _repository.getHourlyForecast(cityName);
  }
}
