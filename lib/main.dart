import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'; // Web kontrolü için (kIsWeb)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/meal_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/login_screen.dart';
import 'screens/tab_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 IDENTITY CARD REGISTRATION FOR THE WEB 🔥
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        // 👇Paste the values you got from Firebase HERE :
        apiKey: "AIzaSyBx1wyJXMT03AuC3NsFwWyXxsjHlLX2Fp8",
        appId: "1:848889595194:web:ddcfa86bd290db8ebc7c03",
        messagingSenderId: "848889595194",
        projectId: "feedme-2e389",

        // These are optional, but if available, paste them.:
        authDomain: "feedme-2e389.firebaseapp.com",
        storageBucket: "feedme-2e389.firebasestorage.app",
      ),
    );
  } else {
    // Mobile (Android/iOS)
    await Firebase.initializeApp();
  }

  runApp(const CalorieTrackerApp());
}

class CalorieTrackerApp extends StatelessWidget {
  const CalorieTrackerApp({super.key});

  ThemeData _buildTheme(Brightness brightness) {
    const green = Color(0xFF2E7D32);
    const yellow = Color(0xFFFBC02D);
    final base = ColorScheme.fromSeed(seedColor: green, brightness: brightness);
    final scheme = base.copyWith(
        primary: green, secondary: yellow, onSecondary: Colors.black);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      cardTheme: CardThemeData(
        elevation: 0,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20))),
        color: scheme.surface,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
        titleTextStyle: TextStyle(
            color: scheme.onSurface, fontSize: 22, fontWeight: FontWeight.bold),
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
        if (!auth.isReady) {
          return const Scaffold(
              body: Center(
                  child: CircularProgressIndicator(color: Colors.green)));
        }
        if (!auth.isLoggedIn) {
          return const LoginScreen();
        }
        return const TabScreen();
      },
    );
  }
}
