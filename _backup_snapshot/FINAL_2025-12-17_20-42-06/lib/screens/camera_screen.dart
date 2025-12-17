// lib/screens/camera_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/meal_provider.dart';
import 'dart:math' as math;

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainAnimationController;
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();

    // Primary animation controller
    _mainAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Pulse animation controller (looping)
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    // Rotation animation controller
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();

    _fadeAnimation = CurvedAnimation(
      parent: _mainAnimationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainAnimationController,
        curve: const Interval(0.0, 0.8, curve: Curves.elasticOut),
      ),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(
        parent: _rotationController,
        curve: Curves.linear,
      ),
    );

    _mainAnimationController.forward();
  }

  @override
  void dispose() {
    _mainAnimationController.dispose();
    _pulseController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  // Simulates the AI analysis process and returns sample data
  Future<Map<String, dynamic>> _simulateAIScan() async {
    await Future.delayed(const Duration(seconds: 2));

    final results = [
      {'name': 'AI: Grilled Chicken & Broccoli', 'calories': 450},
      {'name': 'AI: Extra Cheese Pizza', 'calories': 800},
      {'name': 'AI: Yogurt & Fruit', 'calories': 180},
      {'name': 'AI: Salmon & Veggies', 'calories': 520},
      {'name': 'AI: Carbonara Pasta', 'calories': 650},
    ];

    final randomResult = results[DateTime.now().second % results.length];
    return randomResult;
  }

  Future<void> _startScan() async {
    setState(() {
      _isScanning = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            SizedBox(width: 16),
            Text('AI scan started...'),
          ],
        ),
        backgroundColor: const Color(0xFF4CAF50), // Light green
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );

    final result = await _simulateAIScan();

    if (!mounted) return;

    final provider = Provider.of<MealProvider>(context, listen: false);
    provider.addMealFromCameraResult(
      name: result['name'] as String,
      calories: result['calories'] as int,
    );

    setState(() {
      _isScanning = false;
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Success! ${result['name']} saved.',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF4CAF50), // Light green
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );

    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.5,
            colors: [
              scheme.primary.withValues(alpha: 0.12),
              scheme.surfaceContainerHighest,
              scheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.only(bottom: bottomPadding + 32),
            child: Column(
              children: [
                // Modern app bar
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: scheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.arrow_back_rounded,
                            color: scheme.onSurface,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'AI Calorie Analysis',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: scheme.onSurface,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Main content
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 20),

                            // Large camera icon with burst animation
                            AnimatedBuilder(
                              animation: Listenable.merge([
                                _scaleAnimation,
                                _pulseAnimation,
                                _rotationAnimation,
                              ]),
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _scaleAnimation.value *
                                      _pulseAnimation.value,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      // Outer glow rings (three layers)
                                      ...List.generate(3, (index) {
                                        return Transform.scale(
                                          scale: 1.0 +
                                              (index * 0.15) +
                                              (_pulseAnimation.value * 0.1),
                                          child: Container(
                                            width: 220 + (index * 40),
                                            height: 220 + (index * 40),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              gradient: RadialGradient(
                                                colors: [
                                                  const Color(0xFF6366F1)
                                                      .withOpacity(
                                                          0.1 - (index * 0.03)),
                                                  Colors.transparent,
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      }),

                                      // Primary camera container - gradient
                                      Container(
                                        width: 200,
                                        height: 200,
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Color(0xFF4CAF50), // Light green
                                              Color(
                                                  0xFF81C784), // Light green tone
                                              Color(0xFF66BB6A), // Green tone
                                            ],
                                          ),
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFF4CAF50)
                                                  .withOpacity(0.5),
                                              blurRadius: 40,
                                              spreadRadius: 10,
                                              offset: const Offset(0, 20),
                                            ),
                                            BoxShadow(
                                              color: const Color(0xFF66BB6A)
                                                  .withOpacity(0.3),
                                              blurRadius: 60,
                                              spreadRadius: 20,
                                              offset: const Offset(0, 30),
                                            ),
                                          ],
                                        ),
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            // Inner glow effect
                                            Container(
                                              width: 180,
                                              height: 180,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                gradient: RadialGradient(
                                                  colors: [
                                                    Colors.white
                                                        .withOpacity(0.3),
                                                    Colors.transparent,
                                                  ],
                                                ),
                                              ),
                                            ),

                                            // Camera icon
                                            Transform.rotate(
                                              angle: _rotationAnimation.value *
                                                  0.1,
                                              child: const Icon(
                                                Icons.camera_alt_rounded,
                                                color: Colors.white,
                                                size: 90,
                                                weight: 100,
                                              ),
                                            ),

                                            // Highlight flare
                                            Positioned(
                                              top: 20,
                                              left: 20,
                                              child: Container(
                                                width: 60,
                                                height: 60,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  gradient: RadialGradient(
                                                    colors: [
                                                      Colors.white
                                                          .withOpacity(0.4),
                                                      Colors.transparent,
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Rotating particle effects
                                      ...List.generate(8, (index) {
                                        final angle =
                                            (index * math.pi * 2 / 8) +
                                                _rotationAnimation.value;
                                        final radius = 130.0;
                                        return Positioned(
                                          left: 100 + math.cos(angle) * radius,
                                          top: 100 + math.sin(angle) * radius,
                                          child: Transform.scale(
                                            scale: 0.5 +
                                                (_pulseAnimation.value * 0.2),
                                            child: Container(
                                              width: 12,
                                              height: 12,
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF4CAF50)
                                                    .withOpacity(0.6),
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color:
                                                        const Color(0xFF4CAF50)
                                                            .withOpacity(0.8),
                                                    blurRadius: 8,
                                                    spreadRadius: 2,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                                    ],
                                  ),
                                );
                              },
                            ),

                            const SizedBox(height: 50),

                            // Animated title
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.0, end: 1.0),
                              duration: const Duration(milliseconds: 800),
                              curve: Curves.easeOut,
                              builder: (context, value, child) {
                                return Opacity(
                                  opacity: value,
                                  child: Transform.translate(
                                    offset: Offset(0, 20 * (1 - value)),
                                    child: child,
                                  ),
                                );
                              },
                              child: Column(
                                children: [
                                  const Text(
                                    'Take a Photo',
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF3E2723), // Brown
                                      letterSpacing: -1,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Capture your meal photo,\nAI will calculate calories automatically',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color:
                                          const Color(0xFF8D6E63), // Brown grey
                                      height: 1.0,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 50),

                            // Scan button
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: double.infinity,
                              height: 64,
                              decoration: BoxDecoration(
                                gradient: _isScanning
                                    ? null
                                    : const LinearGradient(
                                        colors: [
                                          Color(0xFFA0522D), // Sienna
                                          Color(0xFF8B4513), // SaddleBrown
                                          Color(0xFFCD853F), // Peru
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                color: _isScanning
                                    ? const Color(0xFF94A3B8)
                                    : null,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: _isScanning
                                    ? null
                                    : [
                                        BoxShadow(
                                          color: const Color(0xFF6366F1)
                                              .withOpacity(0.5),
                                          blurRadius: 25,
                                          spreadRadius: 5,
                                          offset: const Offset(0, 12),
                                        ),
                                        BoxShadow(
                                          color: const Color(0xFFEC4899)
                                              .withOpacity(0.3),
                                          blurRadius: 35,
                                          spreadRadius: 10,
                                          offset: const Offset(0, 15),
                                        ),
                                      ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: _isScanning ? null : _startScan,
                                  borderRadius: BorderRadius.circular(20),
                                  child: Center(
                                    child: _isScanning
                                        ? const SizedBox(
                                            width: 28,
                                            height: 28,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 3,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                            ),
                                          )
                                        : const Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.document_scanner_rounded,
                                                color: Colors.white,
                                                size: 28,
                                              ),
                                              SizedBox(width: 16),
                                              Text(
                                                'Start AI Scan',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                            ],
                                          ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 32),

                            // Info card
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFFFEE2E2),
                                          Color(0xFFFECACA),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: const Icon(
                                      Icons.info_rounded,
                                      color: Color(0xFFEF4444),
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: Text(
                                      'Calorie entries are only allowed through this screen. Manual entry is disabled.',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: const Color(
                                            0xFF8D6E63), // Brown grey
                                        height: 1.0,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
