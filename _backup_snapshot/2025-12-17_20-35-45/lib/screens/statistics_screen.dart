// lib/screens/statistics_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/meal_provider.dart';
import '../providers/theme_provider.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
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
    return Consumer<MealProvider>(
      builder: (context, provider, child) {
        final scheme = Theme.of(context).colorScheme;
        final themeProvider = context.watch<ThemeProvider>();
        final weeklyEaten = provider.totalCaloriesEatenThisWeek;
        final weeklyGoal = provider.weeklyCalorieGoal;
        final monthlyEaten = provider.totalCaloriesEatenThisMonth;
        final monthlyGoal = provider.monthlyCalorieGoal;
        final todayEaten = provider.totalCaloriesEatenToday;
        final dailyGoal = provider.dailyCalorieGoal;

        final bottomPadding = MediaQuery.of(context).padding.bottom;

        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.only(bottom: bottomPadding + 32),
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
              // Modern App Bar
              SliverAppBar(
                expandedHeight: 120,
                floating: false,
                pinned: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                actions: [
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
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
                      child: Icon(
                        themeProvider.isDarkMode
                            ? Icons.light_mode_rounded
                            : Icons.dark_mode_rounded,
                        color: scheme.onSurface,
                        size: 24,
                      ),
                    ),
                    onPressed: themeProvider.toggleTheme,
                    tooltip: themeProvider.isDarkMode
                        ? 'Switch to light mode'
                        : 'Switch to dark mode',
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
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
                      child: Icon(
                        Icons.settings_rounded,
                        color: scheme.primary,
                        size: 24,
                      ),
                    ),
                    onPressed: () => _showGoalSettingsDialog(context, provider),
                    tooltip: 'Calorie goal settings',
                  ),
                  const SizedBox(width: 8),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  title: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Text(
                      'Statistics',
                      style: TextStyle(
                        color: scheme.onSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  centerTitle: true,
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          scheme.surfaceContainerHighest,
                          scheme.surface,
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Content
              SliverPadding(
                padding: const EdgeInsets.all(20.0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Today's summary
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildTodayCard(todayEaten),
                    ),
                    const SizedBox(height: 24),

                    // Daily goal analysis
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildAnalysisCard(
                        context,
                        title: 'Daily Calorie Goal',
                        icon: Icons.today_rounded,
                        eaten: todayEaten,
                        goal: dailyGoal,
                        gradient: const [Color(0xFF4CAF50), Color(0xFF81C784)], // Light green
                        index: 0,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Weekly analysis
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildAnalysisCard(
                        context,
                        title: 'Weekly Calories',
                        icon: Icons.calendar_view_week_rounded,
                        eaten: weeklyEaten,
                        goal: weeklyGoal,
                        gradient: const [Color(0xFF66BB6A), Color(0xFF81C784)], // Green tones
                        index: 1,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Monthly analysis
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildAnalysisCard(
                        context,
                        title: 'Monthly Calories',
                        icon: Icons.calendar_month_rounded,
                        eaten: monthlyEaten,
                        goal: monthlyGoal,
                        gradient: const [Color(0xFF4CAF50), Color(0xFF66BB6A)], // Light green
                        index: 2,
                      ),
                    ),
                    const SizedBox(height: 100),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
      },
    );
  }

  Widget _buildTodayCard(int todayEaten) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF4CAF50), // Light green
            const Color(0xFF556B2F), // DarkOliveGreen
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6B8E23).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Today',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: todayEaten.toDouble()),
                  duration: const Duration(milliseconds: 1500),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Text(
                      '${value.toInt()}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -1,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 4),
                const Text(
                  'kcal consumed',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.today_rounded,
              color: Colors.white,
              size: 40,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required int eaten,
    required int goal,
    required List<Color> gradient,
    required int index,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final difference = goal - eaten;
    final progress = (eaten / goal).clamp(0.0, 1.0);
    final percentage = (progress * 100).toInt();

    // Status analysis
    Color statusColor = const Color(0xFF4CAF50); // Light green
    String statusText = '$difference kcal left to goal';
    IconData statusIcon = Icons.trending_up_rounded;

    if (difference < 0) {
      statusColor = const Color(0xFFEF4444);
      statusText = '${difference.abs()} kcal over goal';
      statusIcon = Icons.trending_down_rounded;
    } else if (difference < (goal * 0.1)) {
      statusColor = const Color(0xFFF59E0B);
      statusText = 'You are very close to your goal!';
      statusIcon = Icons.celebration_rounded;
    }

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: progress),
      duration: Duration(milliseconds: 1500 + (index * 200)),
      curve: Curves.easeOutCubic,
      builder: (context, animatedProgress, child) {
        return Container(
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: gradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(icon, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2C3E50), // Dark gray
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$eaten / $goal kcal',
                          style: TextStyle(
                            fontSize: 14,
                            color: const Color(0xFF8D6E63), // Brown grey
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: gradient[0].withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '%$percentage',
                      style: TextStyle(
                        color: gradient[0],
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: animatedProgress),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return LinearProgressIndicator(
                      value: value,
                      minHeight: 12,
                      backgroundColor: const Color(0xFFE2E8F0),
                      valueColor: AlwaysStoppedAnimation<Color>(gradient[0]),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Status
              Row(
                children: [
                  Icon(statusIcon, color: statusColor, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // Calorie goal settings dialog
  void _showGoalSettingsDialog(BuildContext context, MealProvider provider) {
    final dailyController = TextEditingController(text: provider.dailyCalorieGoal.toString());
    final weeklyController = TextEditingController(text: provider.weeklyCalorieGoal.toString());
    final monthlyController = TextEditingController(text: provider.monthlyCalorieGoal.toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 24,
          right: 24,
          top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [const Color(0xFF4CAF50), const Color(0xFF81C784)], // Light green
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.track_changes_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'Calorie Goal Settings',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3E2723),
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                  color: const Color(0xFF8D6E63),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Daily goal input
            _buildGoalInputField(
              label: 'Daily Calorie Goal',
              icon: Icons.today_rounded,
              controller: dailyController,
              hint: '2000',
              color: const Color(0xFF6B8E23),
            ),
            const SizedBox(height: 20),

            // Weekly goal input
            _buildGoalInputField(
              label: 'Weekly Calorie Goal',
              icon: Icons.calendar_view_week_rounded,
              controller: weeklyController,
              hint: '14000',
              color: const Color(0xFF4CAF50), // Light green
            ),
            const SizedBox(height: 20),

            // Monthly goal input
            _buildGoalInputField(
              label: 'Monthly Calorie Goal',
              icon: Icons.calendar_month_rounded,
              controller: monthlyController,
              hint: '60000',
              color: const Color(0xFF66BB6A), // Green tone
            ),
            const SizedBox(height: 32),

            // Save button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFA0522D), Color(0xFF8B4513)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFA0522D).withValues(alpha: 0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      final daily = int.tryParse(dailyController.text) ?? provider.dailyCalorieGoal;
                      final weekly = int.tryParse(weeklyController.text) ?? provider.weeklyCalorieGoal;
                      final monthly = int.tryParse(monthlyController.text) ?? provider.monthlyCalorieGoal;

                      provider.updateDailyCalorieGoal(daily);
                      provider.updateWeeklyCalorieGoal(weekly);
                      provider.updateMonthlyCalorieGoal(monthly);

                      Navigator.pop(context);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Row(
                            children: [
                              Icon(Icons.check_circle_rounded, color: Colors.white),
                              SizedBox(width: 12),
                              Text(
                                'Goals updated successfully!',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          backgroundColor: const Color(0xFF4CAF50), // Light green
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          margin: const EdgeInsets.all(16),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: const Center(
                      child: Text(
                        'Save',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalInputField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    required String hint,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF3E2723),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5DC),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF3E2723),
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: const Color(0xFF8D6E63).withOpacity(0.5),
                fontSize: 18,
              ),
              prefixIcon: Icon(Icons.local_fire_department_rounded, color: color),
              suffixText: 'kcal',
              suffixStyle: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
