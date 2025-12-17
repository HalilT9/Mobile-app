// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/meal_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/login_screen.dart';
import 'screens/tab_screen.dart';

void main() {
  runApp(const CalorieTrackerApp());
}

/// Root widget that wires up Providers and app-wide theming.
///
/// Navigation is decided by [_AuthGate] based on persisted auth state.
class CalorieTrackerApp extends StatelessWidget {
  const CalorieTrackerApp({super.key});

  /// Builds a Material 3 theme for the given brightness.
  ///
  /// Primary/secondary are set explicitly (green/yellow) so the in-app branding
  /// and gradients stay consistent.
  ThemeData _buildTheme(Brightness brightness) {
    const green = Color(0xFF2E7D32);
    const yellow = Color(0xFFFBC02D);
    final base = ColorScheme.fromSeed(
      seedColor: green,
      brightness: brightness,
    );
    final scheme = base.copyWith(
      primary: green,
      secondary: yellow,
      onSecondary: Colors.black,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      cardTheme: CardThemeData(
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        color: scheme.surface,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
        titleTextStyle: TextStyle(
          color: scheme.onSurface,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
      ),
      fontFamily: 'Inter',
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MealProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'FeedMe',
            debugShowCheckedModeBanner: false,
            theme: _buildTheme(Brightness.light),
            darkTheme: _buildTheme(Brightness.dark),
            themeMode: themeProvider.themeMode,
            home: const _AuthGate(),
          );
        },
      ),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        // During startup we wait until SharedPreferences has been loaded.
        if (!auth.isReady) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // First launch (or after user switch) shows the login screen.
        if (!auth.isLoggedIn) {
          return const LoginScreen();
        }

        // Main app shell: bottom navigation + camera FAB.
        return const TabScreen();
      },
    );
  }
}
