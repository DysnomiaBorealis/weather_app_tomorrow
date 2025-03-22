part of 'current_weather_bloc.dart';

sealed class CurrentWeatherState extends Equatable {
  const CurrentWeatherState();
  
  @override
  List<Object> get props => [];
}

final class CurrentWeatherInitial extends CurrentWeatherState {}

class CurrentWeatherLoading extends CurrentWeatherState {}

class CurrentWeatherFailure extends CurrentWeatherState {
  final String message;

  const CurrentWeatherFailure(this.message);

  @override
  List<Object> get props => [message];
}

class CurrentWeatherLoaded extends CurrentWeatherState {
  final WeatherEntity data;

  const CurrentWeatherLoaded(this.data);

  @override
  List<Object> get props => [data];
}

