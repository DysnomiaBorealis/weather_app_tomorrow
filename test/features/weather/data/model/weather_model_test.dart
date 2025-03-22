import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';

import 'package:weather_app_tommorow/features/weather/data/model/weather_model.dart';
import 'package:weather_app_tommorow/features/weather/domain/entity/weather_entity.dart';

import '../../../../helpers/dummydata/weather_data.dart';
import '../../../../helpers/json_reader.dart';

void main() {
  test(
    'should be a subclass of WeatherEntity',
    () async {
      // assert
      expect(tWeatherModel, isA<WeatherEntity>());
    },
  );

  test(
    'should return a valid model from JSON',
    () async {
      // arrange
      final String jsonString = readJson('currentweather.json');
      final Map<String, dynamic> jsonMap = jsonDecode(jsonString);

      // act
      final result = WeatherModel.fromJson(jsonMap);

      // assert
      expect(result, tWeatherModel);
    },
  );

  test(
    'should return a valid JSON map',
    () async {
      // act
      final result = tWeatherModel.toJson();

      // assert
      expect(result, tWeatherJsonMap);
    },
  );

  test(
    'should return a valid WeatherEntity using toEntity',
    () async {
      // act
      final result = tWeatherModel.toEntity;

      // assert
      expect(result, tWeatherEntity);
    },
  );
}