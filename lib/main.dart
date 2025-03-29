import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather_app_tommorow/common/enum.dart';
import 'package:weather_app_tommorow/features/pick_place/presentation/pages/pick_place_page.dart';
import 'package:weather_app_tommorow/features/setting/setting_page.dart';
import 'package:weather_app_tommorow/features/weather/presentation/bloc/current_weather/current_weather_bloc.dart';
import 'package:weather_app_tommorow/features/weather/presentation/bloc/hourly_forecast/hourly_forecast_bloc.dart';
import 'package:weather_app_tommorow/features/weather/presentation/bloc/weather_history/weather_history_bloc.dart';
import 'package:weather_app_tommorow/features/weather/presentation/pages/current_weather_page.dart';
import 'package:weather_app_tommorow/features/weather/presentation/pages/weather_history_page.dart';
import 'package:weather_app_tommorow/injection.dart';
import 'package:weather_app_tommorow/features/pick_place/presentation/cubit/city_cubit.dart';
import 'package:weather_app_tommorow/features/onboarding/pages/onboarding_page.dart';
import 'package:weather_app_tommorow/features/weather/presentation/pages/hourly_forecast_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initLocator();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => locator<CityCubit>()),
          BlocProvider(create: (context) => locator<CurrentWeatherBloc>()),
          BlocProvider(create: (context) => locator<HourlyForecastBloc>()),
          BlocProvider(create: (context) => locator<WeatherHistoryBloc>())
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            textTheme: GoogleFonts.overpassTextTheme(),
            progressIndicatorTheme: const ProgressIndicatorThemeData(
              color: Colors.white,
            ),
          ),
          initialRoute: AppRoute.onboarding.name,
          routes: {
            '/': (context) => const CurrentWeatherPage(),
            AppRoute.onboarding.name: (context) => const OnboardingScreen(),
            AppRoute.pickPlace.name: (context) => const PickPlacePage(),
            AppRoute.hourlyForecast.name: (context) =>
                const HourlyForecastPage(),
            AppRoute.weatherDetail.name: (context) => const WeatherHistoryPage(),
            AppRoute.settings.name : (context) => const SettingPage()
          },
        ));
  }
}
