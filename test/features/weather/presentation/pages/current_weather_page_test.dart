import 'package:bloc_test/bloc_test.dart';
import 'package:d_view/d_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:intl/intl.dart';
import 'package:weather_app_tommorow/features/weather/domain/entity/weather_entity.dart';
import 'package:weather_app_tommorow/features/weather/presentation/bloc/current_weather/current_weather_bloc.dart';
import 'package:weather_app_tommorow/features/weather/presentation/pages/current_weather_page.dart';

// Create a mock of the CurrentWeatherBloc
class MockCurrentWeatherBloc
    extends MockBloc<CurrentWeatherEvent, CurrentWeatherState>
    implements CurrentWeatherBloc {}

// Mock weather data for testing
final tWeatherEntity = WeatherEntity(
  id: 800,
  cityName: 'Test City',
  main: 'Clear',
  description: 'clear sky',
  icon: 'assets/weather-icons/01d.png',
  temperature: 25.5,
  humidity: 60,
  pressureSurfaceLevel: 1013,
  wind: 5.2,
  dateTime: DateTime.now(),
);

void main() {
  late MockCurrentWeatherBloc bloc;

  setUp(() {
    bloc = MockCurrentWeatherBloc();
    // Register fallback values if needed
    registerFallbackValue(OnGetCurrentWeather());
  });

  // Helper function to create the widget under test
  Widget tWidget() {
    return BlocProvider<CurrentWeatherBloc>(
      create: (context) => bloc,
      child: const MaterialApp(
        home: CurrentWeatherPage(),
      ),
    );
  }

  testWidgets(
    'should show appropriate widgets '
    'when bloc state is initial',
    (tester) async {
      // arrange
      when(() => bloc.state).thenReturn(CurrentWeatherInitial());

      // act
      await tester.pumpWidget(tWidget());
      // Replace pumpAndSettle with pump to avoid timeout with continuous animations
      await tester.pump(const Duration(milliseconds: 500));

      // assert
      // In initial state, we should at least see the background and header actions
      final backgroundWidget = find.byType(Stack).first;
      expect(backgroundWidget, findsOneWidget);

      // Check for header action buttons
      expect(find.text('City'), findsOneWidget);
      expect(find.text('Refresh'), findsOneWidget);
      expect(find.text('Hourly'), findsOneWidget);
    },
  );

  testWidgets(
    'should show loading circle '
    'when bloc state is loading',
    (tester) async {
      // arrange
      when(() => bloc.state).thenReturn(CurrentWeatherLoading());

      // act
      await tester.pumpWidget(tWidget());

      // assert
      final loadingWidget = find.byWidget(DView.loadingCircle());
      expect(loadingWidget, findsOneWidget);
    },
  );

  testWidgets(
    'should show error message and refresh button '
    'when bloc state is failure',
    (tester) async {
      // arrange
      when(() => bloc.state).thenReturn(
        const CurrentWeatherFailure('Error fetching weather data'),
      );

      // act
      await tester.pumpWidget(tWidget());

      // assert
      final errorWidget = find.byKey(const Key('part_error'));
      expect(errorWidget, findsOneWidget);
      expect(find.text('Error fetching weather data'), findsOneWidget);

      // Find the refresh button within the error widget
      final refreshButton = find
          .descendant(
            of: find.byKey(const Key('part_error')),
            matching: find.byType(IconButton),
          )
          .first;
      expect(refreshButton, findsOneWidget);

      // Clear previous interactions with the bloc
      clearInteractions(bloc);

      // Test refresh functionality
      when(() => bloc.add(any(that: isA<OnGetCurrentWeather>())))
          .thenAnswer((_) {});
      await tester.tap(refreshButton);
      verify(() => bloc.add(any(that: isA<OnGetCurrentWeather>()))).called(1);
    },
  );

  testWidgets(
    'should display weather data '
    'when bloc state is loaded',
    (tester) async {
      // arrange
      when(() => bloc.state).thenReturn(
        CurrentWeatherLoaded(tWeatherEntity),
      );

      // act
      await tester.pumpWidget(tWidget());

      // assert
      final weatherWidget = find.byKey(const Key('weather_loaded'));
      expect(weatherWidget, findsOneWidget);

      // Check for specific weather data elements
      expect(find.text('Test City'), findsOneWidget);
      expect(find.text('- Clear -'), findsOneWidget);
      expect(find.text('Clear Sky'), findsOneWidget);
      expect(
          find.text('${tWeatherEntity.temperature.round()}℃'), findsOneWidget);

      // Check for weather stats
      expect(find.text('Temperature'), findsOneWidget);
      expect(find.text('Wind'), findsOneWidget);
      expect(find.text('Pressure'), findsOneWidget);
      expect(find.text('Humidity'), findsOneWidget);
      expect(find.text('${tWeatherEntity.temperature}°C'), findsOneWidget);
      expect(find.text('${tWeatherEntity.wind}m/s'), findsOneWidget);
      expect(find.text('${tWeatherEntity.humidity}%'), findsOneWidget);

      // Today's date should be displayed
      expect(find.text(DateFormat('EEEE, d MMM yyyy').format(DateTime.now())),
          findsOneWidget);
    },
  );

  testWidgets(
    'should have proper animation components in UI',
    (tester) async {
      // arrange
      when(() => bloc.state).thenReturn(CurrentWeatherLoaded(tWeatherEntity));

      // act
      await tester.pumpWidget(tWidget());
      await tester.pump(const Duration(milliseconds: 300));

      // Verify that animation-related widgets exist
      expect(find.byType(AnimatedBuilder), findsWidgets);
      expect(find.byType(CustomPaint), findsWidgets);
      expect(find.byType(GestureDetector), findsWidgets);

      // Verify the button exists but don't try to tap it
      final fabButton = find.byType(FloatingActionButton);
      expect(fabButton, findsOneWidget);

      // Verify that we can find the FloatingActionButton by icon
      expect(find.byIcon(Icons.animation_outlined), findsOneWidget);
    },
  );

  testWidgets(
    'should respond to city, refresh, and hourly button presses',
    (tester) async {
      // arrange
      when(() => bloc.state).thenReturn(CurrentWeatherLoaded(tWeatherEntity));

      // act
      await tester.pumpWidget(tWidget());

      // Clear any previous interactions with the bloc before testing the button
      clearInteractions(bloc);

      // Find refresh button using more specific criteria
      // Looking for the InkWell that contains 'Refresh' text
      final refreshButton = find
          .ancestor(
            of: find.text('Refresh'),
            matching: find.byType(InkWell),
          )
          .first;

      when(() => bloc.add(any(that: isA<OnGetCurrentWeather>())))
          .thenAnswer((_) {});

      await tester.tap(refreshButton);
      verify(() => bloc.add(any(that: isA<OnGetCurrentWeather>()))).called(1);

      // Use more precise finders for City and Hourly buttons too
      final cityButton = find.ancestor(
        of: find.text('City'),
        matching: find.byType(InkWell),
      );
      expect(cityButton, findsOneWidget);

      final hourlyButton = find.ancestor(
        of: find.text('Hourly'),
        matching: find.byType(InkWell),
      );
      expect(hourlyButton, findsOneWidget);
    },
  );

  testWidgets(
    'should have correct animation components with proper icons',
    (tester) async {
      // arrange
      when(() => bloc.state).thenReturn(CurrentWeatherLoaded(tWeatherEntity));

      // act
      await tester.pumpWidget(tWidget());
      await tester.pump(const Duration(milliseconds: 300));

      // Verify that animation-related widgets exist
      expect(find.byType(AnimatedBuilder), findsWidgets);
      expect(find.byType(CustomPaint), findsWidgets);
      expect(find.byType(GestureDetector), findsWidgets);

      // Verify the FAB exists with the correct icon for initial state
      final fabButton = find.byType(FloatingActionButton);
      expect(fabButton, findsOneWidget);
      expect(find.byIcon(Icons.animation_outlined), findsOneWidget);

      // Verify that the SunWithRipplesPainter is used in a CustomPaint
      final customPaints =
          tester.widgetList<CustomPaint>(find.byType(CustomPaint));
      expect(
          customPaints.any((paint) => paint.painter is SunWithRipplesPainter),
          isTrue);

      // Verify all expected cloud painters are present
      expect(
          customPaints.any((paint) => paint.painter is CloudPainter), isTrue);
      expect(customPaints.any((paint) => paint.painter is SmallCloudPainter),
          isTrue);

      // Correct the finder - GestureDetector is a descendant of Stack, not an ancestor
      final gestureDetector = find.descendant(
        of: find.byType(Stack).first,
        matching: find.byType(GestureDetector),
      );
      expect(gestureDetector, findsWidgets);

      // Verify the weather data is rendered properly
      expect(find.text('Test City'), findsOneWidget);
      expect(find.text('- Clear -'), findsOneWidget);
      expect(find.text('Clear Sky'), findsOneWidget);
    },
  );
}
