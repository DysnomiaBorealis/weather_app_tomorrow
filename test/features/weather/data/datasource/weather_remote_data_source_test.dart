import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:weather_app_tommorow/api/key.dart';
import 'package:weather_app_tommorow/api/urls.dart';
import 'package:weather_app_tommorow/core/error/exception.dart';
import 'package:weather_app_tommorow/features/weather/data/datasource/weather_remote_data_source.dart';

import '../../../../helpers/weather_mock.mocks.dart';
import '../../../../helpers/dummydata/weather_data.dart';

void main() {
  late MockHttpClient mockHttpClient;
  late WeatherRemoteDataSourceImpl remoteDataSourceImpl;

  setUp(() {
    mockHttpClient = MockHttpClient();
    remoteDataSourceImpl = WeatherRemoteDataSourceImpl(mockHttpClient);
  });

  group('getCurrentWeather', () {
    final Uri tUri =
        Uri.parse('${URLs.base}realtime?location=$tCityName&apikey=$apiKey');

    test(
      'should throw ServerException when status code is not 200 and not 404',
      () async {
        // Arrange
        when(mockHttpClient.get(tUri))
            .thenAnswer((_) async => http.Response('Server error', 500));

        // Act
        final call = remoteDataSourceImpl.getCurrentWeather;

        // Assert
        expect(() => call(tCityName), throwsA(isA<ServerException>()));
      },
    );

    test(
      'should throw NotFoundException when status code is 404',
      () async {
        // Arrange
        when(mockHttpClient.get(tUri))
            .thenAnswer((_) async => http.Response('Not found', 404));

        // Act
        final call = remoteDataSourceImpl.getCurrentWeather;

        // Assert
        expect(() => call(tCityName), throwsA(isA<NotFoundException>()));
      },
    );

    test(
      'should return WeatherModel when status code is 200',
      () async {
        // Arrange
        when(mockHttpClient.get(tUri)).thenAnswer((_) async => http.Response(
              json.encode(tWeatherJsonMap),
              200,
            ));

        // Act
        final result = await remoteDataSourceImpl.getCurrentWeather(tCityName);

        // Assert
        expect(result, equals(tWeatherModel));
      },
    );
  });
}
