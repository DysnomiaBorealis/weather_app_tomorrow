part of 'hourly_forecast_bloc.dart';

sealed class HourlyForecastEvent extends Equatable {
  const HourlyForecastEvent();

  @override
  List<Object> get props => [];
}

class OnGetHourlyForecast extends HourlyForecastEvent {}
