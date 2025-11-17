# Beritaku(Technical Test PT. Bionic Technologi Indonesia)

A modern Flutter news application with Firebase authentication, offline capability, and favorite features.

## Features

- Latest news from various categories (Indonesian sources)
- Google Sign-In authentication with Firebase
- Save favorite articles locally with Hive
- Calendar view to browse news by date
- Search and filter news by category
- Offline mode with cached articles and images
- User profile with account information
- Modern UI

## Tech Stack

- **Framework**: Flutter 3.29.3, Dart 3.7.2
- **Authentication**: Firebase Auth, Google Sign-In
- **State Management**: GetX
- **Local Database**: Hive
- **API**: NewsAPI.org
- **Caching**: cached_network_image, sqflite
- **UI Components**: table_calendar, Material Design

## Prerequisites

Before running this project, make sure you have:

- Flutter SDK (3.29.3 or higher) installed
- Dart SDK (3.7.2 or higher)
- iOS deployment target 15.0 or higher (for iOS)
- Android Studio or Xcode (for emulators)
- NewsAPI key ([https://newsapi.org](https://newsapi.org))
- Firebase project configured (see Firebase Setup below)

## Installation Instructions

### 1. Clone the Repository

```bash
git clone https://github.com/DhikaNino/technical_test_bti.git
cd technical_test_bti
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Firebase Setup

1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Add iOS and Android apps to your Firebase project
3. Download and place configuration files:
   - iOS: `GoogleService-Info.plist` in `ios/Runner/`
   - Android: `google-services.json` in `android/app/`
4. Enable **Authentication** > **Sign-in method** > **Google** in Firebase Console
5. For Android: Register your SHA-1 certificate fingerprint in Firebase Console

### 4. Get SHA-1 Fingerprint (Android Only)

```bash
# Option 1: Using keytool (requires Java)
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android

# Option 2: Using Gradle
cd android
./gradlew signingReport
```

Copy the SHA-1 fingerprint and add it to Firebase Console > Project Settings > Your Android App.

### 5. Configure API Keys

The app uses centralized configuration in `lib/config/app_config.dart`. Update the following if needed:

```dart
class AppConfig {
  static const String newsApiKey = 'YOUR_NEWS_API_KEY';
  static const String googleWebClientId = 'YOUR_WEB_CLIENT_ID';
  static const String googleIosClientId = 'YOUR_IOS_CLIENT_ID';
  // ...
}
```

**Note**: The current configuration already includes working API keys and OAuth IDs for development.

## Run Instructions

### Run on Android Emulator/Device

```bash
flutter run
```

### Run on iOS Simulator/Device

```bash
flutter run
```

**Important for iOS Simulator**: Google Sign-In has limitations on iOS Simulator due to Safari/keychain restrictions. Use the "Bypass Login (Simulator Only)" button for testing, or test on a real iOS device.

### Run on Chrome (Web)

```bash
flutter run -d chrome
```

### Build for Production

#### Android APK

```bash
flutter build apk --release
```

#### iOS IPA

```bash
flutter build ios --release
```

## Project Structure

```
lib/
├── config/
│   └── app_config.dart          # Centralized configuration
├── controllers/
│   ├── auth_controller.dart     # Authentication logic
│   ├── news_controller.dart     # News state management
│   ├── favorite_controller.dart # Favorite articles
│   └── cache_controller.dart    # Offline caching
├── models/
│   └── news_article.dart        # News data model
├── screens/
│   ├── auth_wrapper.dart        # Auth state router
│   ├── start_screen.dart        # Welcome screen
│   ├── login_screen.dart        # Login with Google
│   ├── main_screen.dart         # Bottom navigation container
│   ├── home_screen.dart         # News list with search/filter
│   ├── favorite_screen.dart     # Saved articles
│   ├── calendar_screen.dart     # Calendar view of news
│   ├── profile_screen.dart      # User profile
│   └── news_detail_screen.dart  # Article detail
├── services/
│   ├── auth_service.dart        # Firebase auth service
│   └── news_service.dart        # NewsAPI HTTP client
└── main.dart                    # App entry point
```

## Additional Notes

### iOS Simulator Limitations

- **Google Sign-In doesn't work** on iOS Simulator due to platform restrictions
- **Workaround**: Use the "Bypass Login (Simulator Only)" button for anonymous authentication
- **For production testing**: Use a real iOS device or test on Android/Chrome

### Android SHA-1 Registration

- Google Sign-In on Android requires SHA-1 certificate fingerprint registered in Firebase Console
- Without it, you'll get `ApiException: 10` error
- Get SHA-1 using methods described in Installation Instructions step 4

### Offline Mode

- The app automatically caches news articles and images
- When offline, cached content is displayed with an orange banner
- Cache expires after 24 hours (configurable in `app_config.dart`)

### API Rate Limits

- NewsAPI free tier has request limits
- If you exceed the limit, articles won't load
- Consider upgrading your NewsAPI plan for production use

### Hive Database

- First run will initialize Hive boxes for favorites and cache
- Data persists across app restarts
- Clear app data to reset local database

## Troubleshooting

### "Failed to load news"

- Check your internet connection
- Verify NewsAPI key in `app_config.dart`
- Check if NewsAPI rate limit is exceeded

### "Google Sign-In Failed" (iOS Simulator)

- This is expected behavior on iOS Simulator
- Use "Bypass Login" button or test on real device

### "ApiException: 10" (Android)

- SHA-1 fingerprint not registered in Firebase Console
- Follow step 4 in Installation Instructions

### Build Errors

```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

## Firebase Configuration Files

Make sure these files are properly configured:

- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`
- `ios/Runner/Info.plist` (NSAppTransportSecurity configured)

## License

This project is intended for technical testing by PT. Bionic Technology Indonesia.
