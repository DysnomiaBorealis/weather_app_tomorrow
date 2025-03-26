class URLs {
  static const base = 'https://api.tomorrow.io/v4/weather/';
  static const weatherIconPath = 'assets/icons/';

  // Helper for generating complete URLs
  static Uri getRealtimeWeatherUrl(String cityName, String apiKey) {
    return Uri.parse('${base}realtime?location=$cityName&apikey=$apiKey');
  }

  static Uri getForecastWeatherUrl(String cityName, String apiKey) {
    return Uri.parse(
      '${base}forecast?location=${Uri.encodeComponent(cityName)}&apikey=$apiKey',
    );
  }

  static Uri getRecentHistoryUrl(String cityName, String apiKey) {
    return Uri.parse(
      '${base}history/recent?location=${Uri.encodeComponent(cityName)}&apikey=$apiKey',
    );
  }
}
