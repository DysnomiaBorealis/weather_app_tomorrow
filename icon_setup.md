# App Icon Setup Instructions

To update the app icon:

1. Make sure "Light Rain.png" is placed in the assets/images/ directory.
   - If the directory doesn't exist yet, create it.
   - The image should be at least 1024x1024 pixels for best results.

2. Run the following command to generate icons:
   ```
   flutter pub get
   flutter pub run flutter_launcher_icons
   ```

3. The icons will automatically be generated for both Android and iOS platforms.

4. Rebuild the app:
   ```
   flutter clean
   flutter build apk  # for Android
   flutter build ios  # for iOS (on macOS only)
   ```

Note: Make sure the "Light Rain.png" file is high quality and suitable for an app icon. Square images work best.
