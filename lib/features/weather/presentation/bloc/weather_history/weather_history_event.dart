part of 'weather_history_bloc.dart';

sealed class WeatherHistoryEvent extends Equatable {
  const WeatherHistoryEvent();

  @override
  List<Object> get props => [];
}

class OnGetWeatherHistory extends WeatherHistoryEvent {}
