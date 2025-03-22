import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weather_app_tommorow/core/error/failure.dart';
import 'package:weather_app_tommorow/core/error/exception.dart';
import 'package:weather_app_tommorow/features/weather/data/repositories/weather_repository_impl.dart';
import 'package:weather_app_tommorow/features/weather/data/datasource/weather_remote_data_source.dart';

import '../../../../helpers/dummydata/weather_data.dart';

class MockWeatherRemoteDataSource extends Mock
    implements WeatherRemoteDataSource {}

void main() {
  late MockWeatherRemoteDataSource mockWeatherRemoteDataSource;
  late WeatherRepositoryImpl repositoryImpl;

  setUp(() {
    mockWeatherRemoteDataSource = MockWeatherRemoteDataSource();
    repositoryImpl = WeatherRepositoryImpl(mockWeatherRemoteDataSource);
  });

  test(
    'should return [WeatherEntity] when remoteDataSource is success',
    () async {
      // arrange
      when(
        () => mockWeatherRemoteDataSource.getCurrentWeather(any()),
      ).thenAnswer((_) async => tWeatherModel);

      // act
      final result = await repositoryImpl.getCurrentWeather(tCityName);

      // assert
      verify(
        () => mockWeatherRemoteDataSource.getCurrentWeather(tCityName),
      );
      expect(result, Right(tWeatherEntity));
    },
  );

  test(
    'should return [NotFoundFailure] '
    'when remoteDataSource throw [NotFoundException]',
    () async {
      // arrange
      when(
        () => mockWeatherRemoteDataSource.getCurrentWeather(any()),
      ).thenThrow(NotFoundException());

      // act
      final result = await repositoryImpl.getCurrentWeather(tCityName);

      // assert
      verify(
        () => mockWeatherRemoteDataSource.getCurrentWeather(tCityName),
      );
      expect(result, const Left(NotFoundFailure('Not found')));
    },
  );

  test(
    'should return [ServerFailure] '
    'when remoteDataSource throw [ServerException]',
    () async {
      // arrange
      when(
        () => mockWeatherRemoteDataSource.getCurrentWeather(any()),
      ).thenThrow(ServerException());

      // act
      final result = await repositoryImpl.getCurrentWeather(tCityName);

      // assert
      verify(
        () => mockWeatherRemoteDataSource.getCurrentWeather(tCityName),
      );
      expect(result, const Left(ServerFailure('Server error')));
    },
  );

  test(
    'should return [ConnectionFailure] '
    'when remoteDataSource throw [SocketException]',
    () async {
      // arrange
      when(
        () => mockWeatherRemoteDataSource.getCurrentWeather(any()),
      ).thenThrow(
        const SocketException('Failed connect to the network'),
      );

      // act
      final result = await repositoryImpl.getCurrentWeather(tCityName);

      // assert
      verify(
        () => mockWeatherRemoteDataSource.getCurrentWeather(tCityName),
      );
      expect(
        result,
        const Left(ConnectionFailure('Failed connect to the network')),
      );
    },
  );

  test(
    'should return [SomethingFailure] '
    'when remoteDataSource throw [ClientException]',
    () async {
      // arrange
      when(
        () => mockWeatherRemoteDataSource.getCurrentWeather(any()),
      ).thenThrow(ClientException('client error'));

      // act
      final result = await repositoryImpl.getCurrentWeather(tCityName);

      // assert
      verify(
        () => mockWeatherRemoteDataSource.getCurrentWeather(tCityName),
      );
      expect(
        result,
        const Left(SomethingFailure('Something wrong has occcured')),
      );
    },
  );
}



