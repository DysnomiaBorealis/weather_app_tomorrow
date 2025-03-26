import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:weather_app_tommorow/common/app_session.dart';
import 'package:weather_app_tommorow/features/weather/domain/entity/weather_entity.dart';
import 'package:weather_app_tommorow/features/weather/domain/usecase/get_hourly_forecast_use_case.dart';

part 'hourly_forecast_event.dart';
part 'hourly_forecast_state.dart';

class HourlyForecastBloc
    extends Bloc<HourlyForecastEvent, HourlyForecastState> {
  final GetHourlyForecastUseCase _useCase;
  final AppSession _appSession;
  HourlyForecastBloc(this._useCase, this._appSession)
      : super(HourlyForecastInitial()) {
    on<OnGetHourlyForecast>((event, emit) async {
      String? cityName = _appSession.cityName;

      if (cityName != null && cityName.isNotEmpty) {
        emit(HourlyForecastLoading());
        final result = await _useCase(cityName);
        result.fold(
          (failure) => emit(HourlyForecastFailure(failure.message)),
          (data) {
            // Sort the data by dateTime to ensure chronological order
            final sortedData = List<WeatherEntity>.from(data)
              ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

            // Debug print timestamps to verify order
            print('Hourly forecast timestamps sorted:');
            for (var weather in sortedData) {
              print('${weather.dateTime}: ${weather.temperature}°C');
            }

            emit(HourlyForecastLoaded(sortedData));
          },
        );
      }
    });
  }
}
