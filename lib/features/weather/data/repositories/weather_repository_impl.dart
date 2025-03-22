import 'dart:io';
import 'package:weather_app_tommorow/core/error/failure.dart';
import 'package:weather_app_tommorow/core/error/exception.dart';
import 'package:weather_app_tommorow/features/weather/data/model/weather_model.dart';
import 'package:weather_app_tommorow/features/weather/domain/entity/weather_entity.dart';
import 'package:weather_app_tommorow/features/weather/domain/repository/weather_repository.dart';
import 'package:weather_app_tommorow/features/weather/data/datasource/weather_remote_data_source.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';

class WeatherRepositoryImpl implements WeatherRepository {
  final WeatherRemoteDataSource remoteDataSource;
  WeatherRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, WeatherEntity>> getCurrentWeather(
    String cityName,
  ) async {
    try {
      final WeatherModel result =
          await remoteDataSource.getCurrentWeather(cityName);
      return Right(result.toEntity);
    } on NotFoundException {
      return const Left(NotFoundFailure('Not found'));
    } on ServerException {
      return const Left(ServerFailure('Server error'));
    } on SocketException {
      return const Left(ConnectionFailure('Failed connect to the network'));
    } catch (e) {
      debugPrint('Something Failure: $e');
      return const Left(SomethingFailure('Something wrong has occcured'));
    }
  }

  @override
  Future<Either<Failure, List<WeatherEntity>>> getHourlyForecast(cityName) async {
    try {
      final List<WeatherModel> result =
          await remoteDataSource.getHourlyForecast(cityName);
      return Right(result.map((model) => model.toEntity).toList());
    } on NotFoundException {
      return const Left(NotFoundFailure('Not found'));
    } on ServerException {
      return const Left(ServerFailure('Server error'));
    } on SocketException {
      return const Left(ConnectionFailure('Failed connect to the network'));
    } catch (e) {
      debugPrint('Something Failure in forecast: $e');
      return const Left(SomethingFailure('Something wrong has occcured'));
    }
  }
}
