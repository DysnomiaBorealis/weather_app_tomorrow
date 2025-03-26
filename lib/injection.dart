import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_app_tommorow/common/app_session.dart';
import 'package:weather_app_tommorow/features/pick_place/presentation/cubit/city_cubit.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app_tommorow/features/weather/data/datasource/weather_remote_data_source.dart';
import 'package:weather_app_tommorow/features/weather/data/repositories/weather_repository_impl.dart';
import 'package:weather_app_tommorow/features/weather/domain/repository/weather_repository.dart';
import 'package:weather_app_tommorow/features/weather/domain/usecase/get_current_weather_use_case.dart';
import 'package:weather_app_tommorow/features/weather/domain/usecase/get_hourly_forecast_use_case.dart';
import 'package:weather_app_tommorow/features/weather/domain/usecase/get_weather_history_use_case.dart';
import 'package:weather_app_tommorow/features/weather/presentation/bloc/current_weather/current_weather_bloc.dart';
import 'package:weather_app_tommorow/features/weather/presentation/bloc/hourly_forecast/hourly_forecast_bloc.dart';
import 'package:weather_app_tommorow/features/weather/presentation/bloc/weather_history/weather_history_bloc.dart';

final locator = GetIt.instance;

Future<void> initLocator() async {
  // cubit / bloc
  locator.registerFactory(() => CityCubit(locator()));
  locator.registerFactory(() => CurrentWeatherBloc(locator(), locator()));
  locator.registerFactory(() => HourlyForecastBloc(locator(), locator()));
  locator.registerFactory(() => WeatherHistoryBloc(locator(), locator()));

  // usecase
  locator.registerLazySingleton(() => GetCurrentWeatherUseCase(locator()));
  locator.registerLazySingleton(() => GetHourlyForecastUseCase(locator()));
  locator.registerLazySingleton(() => GetWeatherHistoryUseCase(locator()));

  // datasource
  locator.registerLazySingleton<WeatherRemoteDataSource>(
    () => WeatherRemoteDataSourceImpl(locator()),
  );

  // repository
  locator.registerLazySingleton<WeatherRepository>(
    () => WeatherRepositoryImpl(locator()),
  );

  // common
  locator.registerLazySingleton(() => AppSession(locator()));

  // external
  final pref = await SharedPreferences.getInstance();
  locator.registerLazySingleton(() => pref);
  locator.registerLazySingleton(() => http.Client());
}
