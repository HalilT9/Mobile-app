// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/meal_provider.dart';
import '../widgets/meal_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final meals = Provider.of<MealProvider>(context).meals;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(bottom: bottomPadding + 240),
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
          // App Bar with Profile
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFF4CAF50).withOpacity(0.1),
                child: const Icon(
                  Icons.person,
                  color: Color(0xFF4CAF50),
                  size: 24,
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: Color(0xFF2C3E50)),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 70, bottom: 16, right: 60),
              title: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Hello,',
                      style: TextStyle(
                        color: Color(0xFF2C3E50),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const Text(
                      'Hasan!',
                      style: TextStyle(
                        color: Color(0xFF2C3E50),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Main Calorie Display
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Consumer<MealProvider>(
                builder: (context, provider, child) {
                  final todayEaten = provider.totalCaloriesEatenToday;
                  final dailyGoal = provider.dailyCalorieGoal;
                  final progress = (todayEaten / dailyGoal).clamp(0.0, 1.0);
                  
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF4CAF50).withOpacity(0.1),
                          const Color(0xFF81C784).withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Large Calorie Number
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: todayEaten.toDouble()),
                          duration: const Duration(milliseconds: 1500),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, child) {
                            return FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                '${value.toInt()}',
                                style: const TextStyle(
                                  fontSize: 56,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2C3E50),
                                  letterSpacing: -2,
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'kcal',
                          style: TextStyle(
                            fontSize: 18,
                            color: Color(0xFF2C3E50),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Progress Bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 8,
                            backgroundColor: const Color(0xFF4CAF50).withOpacity(0.1),
                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Goal Breakdown - Responsive
                        LayoutBuilder(
                          builder: (context, constraints) {
                            if (constraints.maxWidth < 360) {
                              // Stack vertically on small screens
                              return Column(
                                children: [
                                  _buildGoalBox('Goal', dailyGoal.toString()),
                                  const SizedBox(height: 8),
                                  _buildGoalBox('Eaten', todayEaten.toString()),
                                  const SizedBox(height: 8),
                                  _buildGoalBox('Left', (dailyGoal - todayEaten).clamp(0, dailyGoal).toString()),
                                ],
                              );
                            } else {
                              // Lay out horizontally on larger screens
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Expanded(child: _buildGoalBox('Goal', dailyGoal.toString())),
                                  const SizedBox(width: 8),
                                  Expanded(child: _buildGoalBox('Eaten', todayEaten.toString())),
                                  const SizedBox(width: 8),
                                  Expanded(child: _buildGoalBox('Left', (dailyGoal - todayEaten).clamp(0, dailyGoal).toString())),
                                ],
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),

          // Next Meal Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Next Meal',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMealCard(
                          'Snacks',
                          Icons.fastfood_outlined,
                          const Color(0xFF42A5F5), // Light blue
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMealCard(
                          'Dinner',
                          Icons.restaurant_outlined,
                          const Color(0xFF4CAF50), // Light green
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),

          // Meals Section Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  const Text(
                    'Today\'s Meals',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${meals.length} items',
                    style: TextStyle(
                      color: const Color(0xFF2C3E50).withOpacity(0.5),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),

            // Meals List
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: Duration(milliseconds: 300 + (index * 50)),
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
                      child: MealTile(meal: meals[index]),
                    );
                  },
                  childCount: meals.length,
                ),
              ),
            ),
            // Extra bottom space to avoid overflow with FAB/nav bars
            const SliverToBoxAdapter(
              child: SizedBox(height: 60),
            ),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildGoalBox(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: const Color(0xFF2C3E50).withOpacity(0.6),
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '$value',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'kcal',
            style: TextStyle(
              fontSize: 10,
              color: const Color(0xFF2C3E50).withOpacity(0.6),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealCard(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C3E50),
            ),
          ),
        ],
      ),
    );
  }
}
