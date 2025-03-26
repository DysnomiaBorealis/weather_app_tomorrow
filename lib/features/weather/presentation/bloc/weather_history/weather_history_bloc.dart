import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:weather_app_tommorow/common/app_session.dart';
import 'package:weather_app_tommorow/features/weather/domain/entity/weather_entity.dart';
import 'package:weather_app_tommorow/features/weather/domain/usecase/get_weather_history_use_case.dart';

part 'weather_history_event.dart';
part 'weather_history_state.dart';

class WeatherHistoryBloc
    extends Bloc<WeatherHistoryEvent, WeatherHistoryState> {
  final GetWeatherHistoryUseCase _useCase;
  final AppSession _appSession;

  WeatherHistoryBloc(this._useCase, this._appSession)
      : super(WeatherHistoryInitial()) {
    on<OnGetWeatherHistory>((event, emit) async {
      String? cityName = _appSession.cityName;

      if (cityName != null && cityName.isNotEmpty) {
        emit(WeatherHistoryLoading());
        final result = await _useCase(cityName);
        result.fold(
          (failure) => emit(WeatherHistoryFailure(failure.message)),
          (data) => emit(WeatherHistoryLoaded(data)),
        );
      }
    });
  }
}
