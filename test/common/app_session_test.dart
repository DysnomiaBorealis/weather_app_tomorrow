import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_app_tommorow/common/app_session.dart';

class MockSahredPreference extends Mock implements SharedPreferences {}

void main() {
  late MockSahredPreference mockSahredPreference;
  late AppSession appSession;

  setUp(() {
    mockSahredPreference = MockSahredPreference();
    appSession = AppSession(mockSahredPreference);
  });

  test(
    'should return city name when session is present',
    () async {
      // arrange
      when(
        () => mockSahredPreference.getString(any()),
      ).thenReturn('Zocco');

      // act
      final result = appSession.cityName;

      // assert
      verify(
        () => mockSahredPreference.getString('cityName'),
      );
      expect(result, 'Zocco');
    },
  );

  test(
    'should return null name when session is not present',
    () async {
      // arrange
      when(
        () => mockSahredPreference.getString(any()),
      ).thenReturn(null);

      // act
      final result = appSession.cityName;

      // assert
      verify(
        () => mockSahredPreference.getString('cityName'),
      );
      expect(result, '');
    },
  );

  test(
    'should return true when success cache session',
    () async {
      // arrange
      when(
        () => mockSahredPreference.setString(any(), any()),
      ).thenAnswer((_) async => true);

      // act
      final result = await appSession.saveCityName('Zocco');

      // assert
      verify(
        () => mockSahredPreference.setString('cityName', 'Zocco'),
      );
      expect(result, true);
    },
  );

  test(
    'should return false when failed cache session',
    () async {
      // arrange
      when(
        () => mockSahredPreference.setString(any(), any()),
      ).thenAnswer((_) async => false);

      // act
      final result = await appSession.saveCityName('Zocco');

      // assert
      verify(
        () => mockSahredPreference.setString('cityName', 'Zocco'),
      );
      expect(result, false);
    },
  );
}
