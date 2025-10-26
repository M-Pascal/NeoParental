# Quick Start Guide - Firebase Integration

## What's New?

Your NeoParental app now uses **real Firebase services** instead of mock authentication and local storage.

## Key Changes

### 1. Authentication (Real Firebase Auth)

- ✅ Users must create real accounts
- ✅ Email verification available
- ✅ Password reset functionality
- ✅ Secure authentication with Firebase
- ❌ No more "bypass mode" - real accounts required

### 2. Audio Storage (Firebase Storage + Firestore)

- ✅ Audio files stored in cloud (Firebase Storage)
- ✅ Upload history saved to database (Firestore)
- ✅ Real-time sync across devices
- ✅ 50MB file size limit
- ✅ Automatic file organization by user

## Before You Can Use the App

### Required: Firebase Project Setup

**You MUST complete these steps before the app will work:**

1. **Install Firebase CLI** (if not already installed):

   ```bash
   npm install -g firebase-tools
   ```

2. **Install FlutterFire CLI**:

   ```bash
   dart pub global activate flutterfire_cli
   ```

3. **Login to Firebase**:

   ```bash
   firebase login
   ```

4. **Create Firebase Project**:

   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Click "Add project"
   - Name it "NeoParental"
   - Follow the wizard

5. **Configure FlutterFire** (from `parent/` directory):

   ```bash
   flutterfire configure
   ```

   - Select your Firebase project
   - Select platforms: Android, iOS, Web
   - This generates `lib/firebase_options.dart`

6. **Enable Firebase Services**:

   a. **Enable Authentication**:

   - Go to Firebase Console > Authentication
   - Click "Get started"
   - Enable "Email/Password" sign-in method

   b. **Enable Firestore**:

   - Go to Firebase Console > Firestore Database
   - Click "Create database"
   - Choose "Start in test mode"
   - Click "Next" and "Enable"

   c. **Enable Storage**:

   - Go to Firebase Console > Storage
   - Click "Get started"
   - Choose "Start in test mode"
   - Click "Next" and "Done"

7. **Deploy Security Rules**:

   ```bash
   firebase deploy --only firestore:rules
   firebase deploy --only storage:rules
   ```

8. **Update main.dart**:

   ```dart
   // Uncomment these lines in lib/main.dart:
   import 'firebase_options.dart';

   // And change:
   await Firebase.initializeApp();
   // To:
   await Firebase.initializeApp(
     options: DefaultFirebaseOptions.currentPlatform,
   );
   ```

## Platform-Specific Setup

### Android Setup

1. **Download google-services.json**:

   - Firebase Console > Project Settings
   - Under "Your apps", select Android app
   - Download `google-services.json`
   - Place in `android/app/` directory

2. **Update build files** - Already done! ✓

### iOS Setup

1. **Download GoogleService-Info.plist**:

   - Firebase Console > Project Settings
   - Under "Your apps", select iOS app
   - Download `GoogleService-Info.plist`
   - Place in `ios/Runner/` directory

2. **Install pods**:
   ```bash
   cd ios
   pod install
   cd ..
   ```

## How to Use the New Features

### Sign Up (New Users)

```dart
// In your app, users can now sign up:
1. Open the app
2. Click "Sign Up"
3. Enter email, password, full name
4. Click "Create Account"
5. Account is created in Firebase
```

### Sign In

```dart
// Existing users sign in:
1. Open the app
2. Enter email and password
3. Click "Sign In"
4. Authenticated with Firebase
```

### Upload Audio Files

```dart
// Upload audio with automatic cloud storage:
1. Go to "Audio" tab
2. Click "Select Audio File"
3. Choose an audio file
4. Click "Upload"
5. File is uploaded to Firebase Storage
6. History is saved to Firestore
```

### View History

```dart
// History is now real-time from Firestore:
1. Go to "History" tab
2. See all uploaded audio files
3. Data syncs automatically across devices
```

## Testing the Integration

### Quick Test:

1. **Run the app**:

   ```bash
   flutter run
   ```

2. **Create an account**:

   - Use a real email (e.g., test@example.com)
   - Use a password (min 6 characters)

3. **Upload an audio file**:

   - Select any audio file
   - Click upload
   - Wait for success message

4. **Verify in Firebase Console**:
   - Check Authentication > Users (should see new user)
   - Check Firestore > users > {userId} > audio_history (should see upload)
   - Check Storage > users > {userId} > audio_files (should see file)

## Troubleshooting

### Error: "Firebase not configured"

**Solution**: Run `flutterfire configure` and follow setup steps above

### Error: "google-services.json not found"

**Solution**: Download from Firebase Console and place in `android/app/`

### Error: "Permission denied"

**Solution**: Check that:

- User is signed in
- Security rules are deployed
- Email/Password auth is enabled

### Error: "File upload failed"

**Solution**:

- Check internet connection
- Verify file is under 50MB
- Ensure file is an audio type

### App crashes on startup

**Solution**:

- Ensure all Firebase setup steps are complete
- Check that Firebase services are enabled
- Run `flutter clean` and `flutter pub get`

## Files You Need to Create

After running `flutterfire configure`, you should have:

- ✅ `lib/firebase_options.dart` (auto-generated)
- ✅ `android/app/google-services.json` (download from Firebase)
- ✅ `ios/Runner/GoogleService-Info.plist` (download from Firebase)

## What Happens Behind the Scenes

### When User Signs Up:

1. Firebase Auth creates account
2. User record stored in Firebase Authentication
3. User can now access protected features

### When User Uploads Audio:

1. File uploaded to Firebase Storage: `users/{userId}/audio_files/audio_xxx.mp3`
2. History record created in Firestore: `users/{userId}/audio_history/{historyId}`
3. Record contains: audioUrl, fileName, analysis data, timestamps
4. Real-time updates sent to all devices

### Security:

- Users can only access their own files
- All operations require authentication
- Server-side validation via security rules
- 50MB file size limit enforced
- Only audio files allowed

## Cost (Free Tier Limits)

Firebase free tier includes:

- ✅ 10,000 phone auth verifications/month
- ✅ 50,000 document reads/day
- ✅ 20,000 document writes/day
- ✅ 5GB Storage
- ✅ 1GB/day downloads

This is plenty for development and testing!

## Next Steps

1. ✅ Complete Firebase setup (see steps above)
2. ✅ Test authentication
3. ✅ Test file upload
4. 🔲 Integrate ML model for audio analysis
5. 🔲 Add offline support
6. 🔲 Add push notifications
7. 🔲 Deploy to production

## Need Help?

- 📖 Read `FIREBASE_SETUP.md` for detailed setup
- 📖 Read `IMPLEMENTATION_GUIDE.md` for technical details
- 🌐 Visit [Firebase Documentation](https://firebase.google.com/docs)
- 🌐 Visit [FlutterFire Documentation](https://firebase.flutter.dev/)

## Important Notes

⚠️ **The app will NOT work until you complete the Firebase setup steps above!**

⚠️ **Test mode security rules are NOT for production!** Change to production rules before deploying.

⚠️ **Monitor your Firebase usage** to avoid unexpected charges.

✅ **All your data is now stored in the cloud** and syncs automatically!

✅ **You can access your data from any device** after signing in!
