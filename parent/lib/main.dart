import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/navigation_provider.dart';
import 'providers/data_provider.dart';
import 'screens/welcome_screen.dart';
import 'utils/app_theme.dart';
import 'utils/app_strings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const NeoParentalApp());
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
        home: const WelcomeScreen(),
      ),
    );
  }
}
