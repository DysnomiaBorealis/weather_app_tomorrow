import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app_tommorow/features/weather/domain/repository/weather_repository.dart';

@GenerateNiceMocks([
  MockSpec<WeatherRepository>(as: #MockWeatherRepository),
  MockSpec<http.Client>(as: #MockHttpClient)
])
void main() {}
