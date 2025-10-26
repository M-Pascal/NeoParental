import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/navigation_provider.dart';
import 'providers/data_provider.dart';
import 'providers/audio_provider.dart';
import 'screens/auth_wrapper.dart';
import 'utils/app_theme.dart';
import 'utils/app_strings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase with generated options
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    runApp(const NeoParentalApp());
  } catch (e) {
    // If Firebase initialization fails, show error screen
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 80, color: Colors.red),
                  const SizedBox(height: 20),
                  const Text(
                    'Firebase Initialization Failed',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Error: $e',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Please ensure:\n'
                    '1. google-services.json is in android/app/\n'
                    '2. Firebase is properly configured\n'
                    '3. Run: flutterfire configure',
                    style: TextStyle(fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class NeoParentalApp extends StatelessWidget {
  const NeoParentalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Auth provider - manages authentication state
        ChangeNotifierProvider(create: (_) => AuthProvider()),

        // Navigation provider - manages bottom navigation
        ChangeNotifierProvider(create: (_) => NavigationProvider()),

        // Audio provider - manages audio uploads and history
        ChangeNotifierProvider(create: (_) => AudioProvider()),

        // History provider - manages baby cry analysis history
        ChangeNotifierProvider(
          create: (_) => HistoryProvider()..initializeSampleData(),
        ),

        // Parenting skills provider - manages educational content
        ChangeNotifierProvider(
          create: (_) => ParentingSkillsProvider()..initializeSampleData(),
        ),
      ],
      child: MaterialApp(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const AuthWrapper(), // Automatically handles auth state
      ),
    );
  }
}
