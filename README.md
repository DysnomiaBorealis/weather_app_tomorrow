# Weather App

A beautiful and functional weather application built with Flutter that provides current and forecast weather information for locations worldwide using the Tomorrow.io API.

## Features

- Real-time weather information including temperature, humidity, wind speed, etc.
- 5-day weather forecasts
- Weather condition visualizations with corresponding icons
- Location-based weather services
- Ability to search for weather in different cities
- Beautiful UI with smooth transitions and animations
- Light and dark theme support

## Screenshots

https://github.com/user-attachments/assets/e267abd7-546a-41d2-b482-8845fda81f40


## Technologies Used

- Flutter
- Dart
- Tomorrow.io API for weather data
- BLoC pattern for state management
- Optional: Geolocator for device location services (omit if using only API-provided locations)
- HTTP package for API requests
- Shared preferences for local storage

## Getting Started

### Prerequisites

- Flutter SDK
- Android Studio / VS Code
- Tomorrow.io API key

### Installation

1. Clone the repository
   ```
   git clone [https://github.com/yourusername/weather_app.git](https://github.com/DysnomiaBorealis/weather_app_tomorrow)
   ```

2. Navigate to the project directory
   ```
   cd weather_app
   ```

3. Install dependencies
   ```
   flutter pub get
   ```

4. Run the app
   ```
   flutter run
   ```

## Usage

- Upon launching the app, it will request permission to access your location
- The app will display the current weather for your location
- Use the search bar to check weather information for other cities
- Swipe down to refresh the weather data
- Toggle between light and dark themes in the settings

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgements

- Weather data provided by [Tomorrow.io](https://www.tomorrow.io/)
- Icons designed by [Your Icon Source]
- Special thanks to all contributors and testers
