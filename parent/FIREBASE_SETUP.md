# Firebase Setup Guide for NeoParental

This guide will walk you through setting up Firebase for the NeoParental app, including Authentication, Firestore, and Storage.

## Prerequisites

1. A Google account
2. Flutter installed on your system
3. Firebase CLI installed (optional but recommended)

## Step 1: Create a Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Enter project name: `NeoParental` (or your preferred name)
4. Follow the setup wizard:
   - Enable/Disable Google Analytics (your choice)
   - Click "Create project"
   - Wait for the project to be created

## Step 2: Register Your Apps

### For Android:

1. In Firebase Console, click the Android icon
2. Enter package name: `com.example.parent` (or your actual package name from `android/app/build.gradle.kts`)
3. Enter app nickname: `NeoParental Android`
4. Download the `google-services.json` file
5. Place it in `android/app/` directory

### For iOS:

1. In Firebase Console, click the iOS icon
2. Enter iOS bundle ID: `com.example.parent` (or your actual bundle ID from `ios/Runner.xcodeproj`)
3. Enter app nickname: `NeoParental iOS`
4. Download the `GoogleService-Info.plist` file
5. Place it in `ios/Runner/` directory

### For Web:

1. In Firebase Console, click the Web icon
2. Enter app nickname: `NeoParental Web`
3. Copy the Firebase configuration object
4. Create a `firebase_options.dart` file (see below)

## Step 3: Configure Firebase in Your Flutter App

### Option A: Using FlutterFire CLI (Recommended)

1. Install FlutterFire CLI:

   ```bash
   dart pub global activate flutterfire_cli
   ```

2. Run the configuration command from your project root:

   ```bash
   flutterfire configure
   ```

3. Select your Firebase project
4. Select the platforms you want to support (Android, iOS, Web)
5. This will automatically generate `firebase_options.dart`

### Option B: Manual Configuration

If you prefer manual setup, create `lib/firebase_options.dart` with your Firebase config.

## Step 4: Enable Firebase Services

### Enable Firebase Authentication:

1. In Firebase Console, go to "Authentication"
2. Click "Get started"
3. Go to "Sign-in method" tab
4. Enable "Email/Password" provider
5. Click "Save"

### Enable Cloud Firestore:

1. In Firebase Console, go to "Firestore Database"
2. Click "Create database"
3. Choose "Start in test mode" (for development)
   - **Note:** Change to production rules before deploying!
4. Select your preferred location
5. Click "Enable"

### Configure Firestore Security Rules:

Replace the default rules with:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // User data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;

      // Audio history subcollection
      match /audio_history/{historyId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
}
```

### Enable Firebase Storage:

1. In Firebase Console, go to "Storage"
2. Click "Get started"
3. Start in test mode (for development)
4. Select your preferred location
5. Click "Done"

### Configure Storage Security Rules:

Replace the default rules with:

```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /users/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## Step 5: Install Dependencies

Run the following command in your project directory:

```bash
flutter pub get
```

This will install:

- `firebase_core`: Core Firebase SDK
- `firebase_auth`: Authentication
- `firebase_storage`: File storage
- `cloud_firestore`: NoSQL database

## Step 6: Update Platform-Specific Configuration

### Android Configuration:

1. Open `android/build.gradle.kts`
2. Ensure you have the Google services plugin:

```kotlin
dependencies {
    classpath("com.android.tools.build:gradle:8.1.0")
    classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.9.0")
    classpath("com.google.gms:google-services:4.4.0")
}
```

3. Open `android/app/build.gradle.kts`
4. Add at the bottom:

```kotlin
apply(plugin = "com.google.gms.google-services")
```

5. Set minimum SDK version to 21 or higher:

```kotlin
minSdk = 21
```

### iOS Configuration:

1. Ensure minimum iOS version is 13.0+ in `ios/Podfile`:

```ruby
platform :ios, '13.0'
```

2. Run:

```bash
cd ios
pod install
cd ..
```

## Step 7: Test Your Setup

1. Run the app:

   ```bash
   flutter run
   ```

2. Try signing up with a new account
3. Check Firebase Console to verify:
   - New user appears in Authentication
   - User document is created in Firestore (when you upload audio)
   - Files appear in Storage (when you upload audio)

## Common Issues and Solutions

### Issue: Google Services plugin error

**Solution:** Make sure `google-services.json` (Android) or `GoogleService-Info.plist` (iOS) is in the correct location.

### Issue: Multidex error on Android

**Solution:** Enable multidex in `android/app/build.gradle.kts`:

```kotlin
android {
    defaultConfig {
        multiDexEnabled = true
    }
}

dependencies {
    implementation("androidx.multidex:multidex:2.0.1")
}
```

### Issue: Permission denied on Firestore/Storage

**Solution:** Check your security rules and ensure the user is authenticated.

### Issue: iOS build fails

**Solution:**

- Delete `ios/Podfile.lock`
- Delete `ios/Pods` folder
- Run `cd ios && pod install && cd ..`

## Data Structure

### Firestore Collections:

```
users (collection)
  └── {userId} (document)
      └── audio_history (subcollection)
          └── {historyId} (document)
              - audioUrl: string
              - fileName: string
              - analysis: string
              - confidence: number
              - duration: number
              - status: string
              - notes: string
              - uploadedAt: timestamp
              - createdAt: timestamp
```

### Storage Structure:

```
users/
  └── {userId}/
      └── audio_files/
          └── audio_1234567890.mp3
          └── audio_1234567891.wav
          └── ...
```

## Production Checklist

Before deploying to production:

- [ ] Update Firestore security rules to production mode
- [ ] Update Storage security rules to production mode
- [ ] Set up proper indexes for Firestore queries
- [ ] Configure Firebase Authentication email templates
- [ ] Set up Firebase Analytics (optional)
- [ ] Configure proper CORS for Storage (if using web)
- [ ] Enable Firebase App Check for security
- [ ] Set up budget alerts in Google Cloud Console
- [ ] Configure proper backup strategies

## Support

For more information, visit:

- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Firebase Console](https://console.firebase.google.com/)

## Additional Features (Optional)

### Enable Firebase Analytics:

```bash
flutter pub add firebase_analytics
```

### Enable Cloud Functions:

See the `functions/` directory for Cloud Functions setup.

### Enable FCM (Push Notifications):

```bash
flutter pub add firebase_messaging
```
