import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:weather_app_tommorow/common/app_session.dart';
import 'package:weather_app_tommorow/features/weather/domain/entity/weather_entity.dart';
import 'package:weather_app_tommorow/features/weather/domain/usecase/get_current_weather_use_case.dart';

part 'current_weather_event.dart';
part 'current_weather_state.dart';

class CurrentWeatherBloc
    extends Bloc<CurrentWeatherEvent, CurrentWeatherState> {
  final GetCurrentWeatherUseCase _useCase;
  final AppSession _appSession;
  CurrentWeatherBloc(this._useCase, this._appSession)
      : super(CurrentWeatherInitial()) {
    on<OnGetCurrentWeather>((event, emit) async {
      String? cityName = _appSession.cityName;

      if (cityName != null && cityName.isNotEmpty) {
        emit(CurrentWeatherLoading());
        final result = await _useCase(cityName); 
        result.fold(
          (failure) => emit(CurrentWeatherFailure(failure.message)),
          (data) => emit(CurrentWeatherLoaded(data)),
        );
      }
    });
  }
}