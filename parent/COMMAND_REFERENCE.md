# Quick Command Reference - Firebase Integration

## 🚀 Essential Commands

### Firebase Setup (One-time)

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Login to Firebase
firebase login

# Configure Flutter app with Firebase
cd parent
flutterfire configure

# Deploy security rules
firebase deploy --only firestore:rules
firebase deploy --only storage:rules
```

### Flutter Development

```bash
# Install dependencies
flutter pub get

# Clean build
flutter clean

# Run on connected device
flutter run

# Run on specific device
flutter devices                    # List devices
flutter run -d <device-id>        # Run on specific device

# Build for Android
flutter build apk --release        # Release APK
flutter build appbundle            # Android App Bundle

# Build for iOS
flutter build ios --release

# Analyze code
flutter analyze

# Format code
dart format lib/

# Check for outdated packages
flutter pub outdated
```

### Testing

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/widget_test.dart

# Run with coverage
flutter test --coverage
```

### Firebase Management

```bash
# View project list
firebase projects:list

# Switch project
firebase use <project-id>

# View current project
firebase projects:list

# Deploy functions
firebase deploy --only functions

# Deploy hosting
firebase deploy --only hosting

# View Firebase logs
firebase functions:log
```

### Debugging

```bash
# Run with verbose logging
flutter run -v

# Clear app data (Android)
flutter run --clear-data

# Enable device logging
flutter run --enable-software-rendering

# Check Flutter doctor
flutter doctor -v
```

## 🔧 Common Tasks

### Reset Firebase Configuration

```bash
# If you need to reconfigure Firebase
rm lib/firebase_options.dart
flutterfire configure
```

### Clear Flutter Cache

```bash
flutter clean
flutter pub get
cd ios && pod install && cd ..  # iOS only
flutter run
```

### Update Firebase Packages

```bash
flutter pub upgrade
flutter pub get
```

### Check Firebase Connection

```dart
// Add to your app temporarily
import 'package:parent/screens/firebase_test_screen.dart';

// Navigate to test screen
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const FirebaseTestScreen(),
  ),
);
```

## 📱 Platform-Specific

### Android

```bash
# Build debug APK
cd android
./gradlew assembleDebug
cd ..

# Build release APK
flutter build apk --release

# Install on device
flutter install
```

### iOS

```bash
# Update pods
cd ios
pod install
pod update
cd ..

# Open in Xcode
open ios/Runner.xcworkspace

# Build
flutter build ios --release
```

## 🐛 Troubleshooting Commands

### Firebase Issues

```bash
# Reinstall FlutterFire CLI
dart pub global deactivate flutterfire_cli
dart pub global activate flutterfire_cli

# Reconfigure Firebase
flutterfire configure --force

# Check Firebase status
firebase projects:list
firebase use <project-id>
```

### Build Issues

```bash
# Complete clean rebuild
flutter clean
rm -rf build/
rm -rf .dart_tool/
rm pubspec.lock
flutter pub get

# Android only
cd android
./gradlew clean
cd ..

# iOS only
cd ios
rm -rf Pods/
rm Podfile.lock
pod install
cd ..
```

### Package Issues

```bash
# Clear pub cache
flutter pub cache repair

# Get specific package version
flutter pub add firebase_auth:^5.3.1
```

## 📊 Monitoring

### View Firebase Console

```bash
# Open project in browser
firebase open

# Open specific service
firebase open auth        # Authentication
firebase open firestore   # Firestore Database
firebase open storage     # Storage
firebase open hosting     # Hosting
```

### Check App Performance

```bash
# Profile app
flutter run --profile

# Performance overlay
# In app: Press 'P' key (in debug mode)

# Memory usage
# In app: Press 'M' key (in debug mode)
```

## 🔒 Security

### Deploy Rules

```bash
# Deploy all rules
firebase deploy --only firestore:rules,storage:rules

# Deploy specific rule
firebase deploy --only firestore:rules
firebase deploy --only storage:rules
```

### Validate Rules

```bash
# Test Firestore rules
firebase firestore:rules:test

# Test Storage rules
firebase storage:rules:test
```

## 📦 Dependencies

### Current Firebase Packages

```yaml
firebase_core: ^3.6.0
firebase_auth: ^5.3.1
firebase_storage: ^12.3.4
cloud_firestore: ^5.4.4
```

### Update Single Package

```bash
flutter pub add firebase_auth:^5.3.1
```

## 🎯 Quick Fixes

### "Firebase not configured" Error

```bash
flutterfire configure
flutter pub get
flutter run
```

### "google-services.json not found" Error

```bash
# Download from Firebase Console
# Place in: android/app/google-services.json
flutter clean
flutter run
```

### "Pod install failed" Error

```bash
cd ios
rm -rf Pods Podfile.lock
pod install --repo-update
cd ..
flutter run
```

### "Multidex error" on Android

Add to `android/app/build.gradle.kts`:

```kotlin
defaultConfig {
    multiDexEnabled = true
}

dependencies {
    implementation("androidx.multidex:multidex:2.0.1")
}
```

## 📝 Git Commands (Optional)

```bash
# Commit Firebase configuration
git add .
git commit -m "Add Firebase integration"

# Create branch for Firebase work
git checkout -b feature/firebase-auth

# Ignore Firebase config files (if needed)
echo "lib/firebase_options.dart" >> .gitignore
echo "android/app/google-services.json" >> .gitignore
echo "ios/Runner/GoogleService-Info.plist" >> .gitignore
```

## 🚀 Deployment

### Android Release

```bash
# Build release APK
flutter build apk --release

# Build App Bundle (for Play Store)
flutter build appbundle --release

# Find build
# APK: build/app/outputs/flutter-apk/app-release.apk
# Bundle: build/app/outputs/bundle/release/app-release.aab
```

### iOS Release

```bash
# Build for App Store
flutter build ios --release

# Archive in Xcode
open ios/Runner.xcworkspace
# Product > Archive in Xcode
```

## 📚 Helpful Resources

```bash
# Open documentation
flutter doc

# Check Flutter version
flutter --version

# Check Dart version
dart --version

# List all Flutter commands
flutter help

# Get help for specific command
flutter help run
```

## 🔄 Regular Maintenance

```bash
# Weekly/Monthly tasks
flutter upgrade                    # Update Flutter
flutter pub upgrade               # Update packages
flutter doctor                    # Check setup
flutter analyze                   # Check code quality
```

## 💡 Pro Tips

```bash
# Hot reload: Press 'r' (while app is running)
# Hot restart: Press 'R'
# Open DevTools: Press 'h'
# Enable performance overlay: Press 'P'
# Take screenshot: Press 's'
# Quit: Press 'q'

# Run in release mode (faster)
flutter run --release

# Profile mode (for performance testing)
flutter run --profile
```

---

## 🎯 Most Used Commands

```bash
# Development cycle
flutter pub get
flutter run
# ... make changes ...
# Hot reload with 'r'
# Hot restart with 'R'

# Testing cycle
flutter clean
flutter pub get
flutter run
flutter analyze

# Deployment
flutter build apk --release        # Android
flutter build ios --release        # iOS
```

---

Keep this file handy for quick reference! 🚀
