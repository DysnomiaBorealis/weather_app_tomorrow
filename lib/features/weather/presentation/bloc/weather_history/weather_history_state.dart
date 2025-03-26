part of 'weather_history_bloc.dart';

sealed class WeatherHistoryState extends Equatable {
  const WeatherHistoryState();

  @override
  List<Object> get props => [];
}

final class WeatherHistoryInitial extends WeatherHistoryState {}

class WeatherHistoryLoading extends WeatherHistoryState {}

class WeatherHistoryFailure extends WeatherHistoryState {
  final String message;

  const WeatherHistoryFailure(this.message);

  @override
  List<Object> get props => [message];
}

class WeatherHistoryLoaded extends WeatherHistoryState {
  final List<WeatherEntity> data;

  const WeatherHistoryLoaded(this.data);

  @override
  List<Object> get props => [data];
}
