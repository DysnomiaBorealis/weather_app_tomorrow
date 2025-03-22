import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:weather_app_tommorow/common/app_session.dart';
import 'package:weather_app_tommorow/core/error/failure.dart';
import 'package:weather_app_tommorow/features/weather/domain/usecase/get_current_weather_use_case.dart';
import 'package:weather_app_tommorow/features/weather/presentation/bloc/current_weather/current_weather_bloc.dart';

import '../../../../../helpers/dummydata/weather_data.dart';

class MockAppSession extends Mock implements AppSession {}

class MockGetCurrentWeatherUseCase extends Mock
    implements GetCurrentWeatherUseCase {}

void main() {
  late MockAppSession mockAppSession;
  late MockGetCurrentWeatherUseCase mockGetCurrentWeatherUseCase;
  late CurrentWeatherBloc bloc;

  setUp(() {
    mockAppSession = MockAppSession();
    mockGetCurrentWeatherUseCase = MockGetCurrentWeatherUseCase();
    bloc = CurrentWeatherBloc(mockGetCurrentWeatherUseCase, mockAppSession);
  });

  blocTest<CurrentWeatherBloc, CurrentWeatherState>(
    'emits [CurentWeatherLoading, CurrentWeatherLoaded] '
    'when usecase success',
    build: () {
      when(() => mockAppSession.cityName).thenReturn(tCityName);
      when(
        () => mockGetCurrentWeatherUseCase(any()),
      ).thenAnswer((_) async => Right(tWeatherEntity));

      return bloc;
    },
    act: (bloc) => bloc.add(OnGetCurrentWeather()),
    expect: () => [
      CurrentWeatherLoading(),
      CurrentWeatherLoaded(tWeatherEntity),
    ],
  );

  blocTest<CurrentWeatherBloc, CurrentWeatherState>(
    'emits [CurentWeatherLoading, CurrentWeatherFailure] '
    'when usecase failed',
    build: () {
      when(() => mockAppSession.cityName).thenReturn(tCityName);
      when(
        () => mockGetCurrentWeatherUseCase(any()),
      ).thenAnswer((_) async => const Left(NotFoundFailure('not found')));

      return bloc;
    },
    act: (bloc) => bloc.add(OnGetCurrentWeather()),
    expect: () => [
      CurrentWeatherLoading(),
      const CurrentWeatherFailure('not found'),
    ],
  );

  blocTest<CurrentWeatherBloc, CurrentWeatherState>(
    'emits [] '
    'when appsession return null',
    build: () {
      when(() => mockAppSession.cityName).thenReturn(null);
      when(
        () => mockGetCurrentWeatherUseCase(any()),
      ).thenAnswer((_) async => const Left(NotFoundFailure('not found')));

      return bloc;
    },
    act: (bloc) => bloc.add(OnGetCurrentWeather()),
    expect: () => [],
  );
}
