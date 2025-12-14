// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/meal_provider.dart';
import 'screens/home_screen.dart';
import 'screens/statistics_screen.dart';
import 'screens/camera_screen.dart';

void main() {
  runApp(const CalorieTrackerApp());
}

class CalorieTrackerApp extends StatelessWidget {
  const CalorieTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MealProvider(),
      child: MaterialApp(
        title: 'FeedMe',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF4CAF50), // Light green
            brightness: Brightness.light,
            primary: const Color(0xFF4CAF50), // Light green
            secondary: const Color(0xFF81C784), // Light green tone
            tertiary: const Color(0xFF66BB6A), // Green tone
          ),
          scaffoldBackgroundColor: Colors.white,
          cardTheme: const CardThemeData(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            color: Colors.white,
          ),
          appBarTheme: const AppBarTheme(
            elevation: 0,
            centerTitle: true,
            backgroundColor: Colors.transparent,
            foregroundColor: const Color(0xFF2C3E50), // Dark gray
            titleTextStyle: const TextStyle(
              color: Color(0xFF2C3E50), // Dark gray
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          fontFamily: 'Inter',
        ),
        home: const TabScreen(),
      ),
    );
  }
}

// Bottom navigation structure (TabScreen)
class TabScreen extends StatefulWidget {
  const TabScreen({super.key});

  @override
  State<TabScreen> createState() => _TabScreenState();
}

class _TabScreenState extends State<TabScreen> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _fabAnimationController;
  
  final List<Widget> _screens = [
    const HomeScreen(),
    const StatisticsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..forward();
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }
  
  // Opens the camera screen
  void _openCameraScreen() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const CameraScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 0.3),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: Offset(_selectedIndex == 0 ? -0.1 : 0.1, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOutCubic,
              )),
              child: child,
            ),
          );
        },
        child: _screens[_selectedIndex],
      ),
      
      // Camera button with a gradient FAB
      floatingActionButton: ScaleTransition(
        scale: Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _fabAnimationController,
            curve: Curves.elasticOut,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF4CAF50), Color(0xFF81C784)], // Light green gradient
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4CAF50).withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: FloatingActionButton(
            onPressed: _openCameraScreen,
            backgroundColor: Colors.transparent,
            elevation: 0,
            tooltip: 'Capture photo and log calories',
            child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 28),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          child: BottomAppBar(
            shape: const CircularNotchedRectangle(),
            notchMargin: 8.0,
            padding: EdgeInsets.zero,
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                _buildNavItem(Icons.restaurant_menu_rounded, 'Meals', 0),
                const SizedBox(width: 60), // FAB spacing
                _buildNavItem(Icons.insights_rounded, 'Stats', 1),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => _onItemTapped(index),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF4CAF50).withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: isSelected
                      ? const Color(0xFF4CAF50) // Light green
                      : const Color(0xFF9E9E9E), // Gray
                  size: 24,
                ),
              ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected
                      ? const Color(0xFF4CAF50) // Light green
                      : const Color(0xFF9E9E9E), // Gray
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}