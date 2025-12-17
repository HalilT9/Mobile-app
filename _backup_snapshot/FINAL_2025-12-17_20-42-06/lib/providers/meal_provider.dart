// lib/providers/meal_provider.dart
import 'package:flutter/foundation.dart';
import '../models/meal.dart';

class MealProvider with ChangeNotifier {
  // Mock data: extended list with varied dates for performance testing
  final List<Meal> _meals = [
    Meal(id: 'm1', name: 'Breakfast Bowl', calories: 450, date: DateTime.now().subtract(const Duration(hours: 3)), isEaten: true),
    Meal(id: 'm2', name: 'Salad Lunch', calories: 350, date: DateTime.now().subtract(const Duration(hours: 1))),
    Meal(id: 'm3', name: 'Steak Dinner', calories: 600, date: DateTime.now().subtract(const Duration(days: 1)), isEaten: true),
    Meal(id: 'm4', name: 'Midweek Meal', calories: 500, date: DateTime.now().subtract(const Duration(days: 4))),
    Meal(id: 'm5', name: 'Monthly Special', calories: 800, date: DateTime.now().subtract(const Duration(days: 35))),
    // Additional meals for stress testing
    for (var i = 6; i < 36; i++)
      Meal(id: 'm$i', name: 'Sample Meal $i', calories: 150 + i * 10, date: DateTime.now().subtract(Duration(days: i % 10))),
  ];

  // User goals (mutable)
  int _dailyCalorieGoal = 2000; // Daily calorie goal
  int _weeklyCalorieGoal = 14000;
  int _monthlyCalorieGoal = 60000;

  // Getters
  int get dailyCalorieGoal => _dailyCalorieGoal;
  int get weeklyCalorieGoal => _weeklyCalorieGoal;
  int get monthlyCalorieGoal => _monthlyCalorieGoal;

  // Setters - goal update helpers
  void updateDailyCalorieGoal(int goal) {
    if (goal > 0 && goal <= 10000) {
      _dailyCalorieGoal = goal;
      notifyListeners();
    }
  }

  void updateWeeklyCalorieGoal(int goal) {
    if (goal > 0 && goal <= 100000) {
      _weeklyCalorieGoal = goal;
      notifyListeners();
    }
  }

  void updateMonthlyCalorieGoal(int goal) {
    if (goal > 0 && goal <= 500000) {
      _monthlyCalorieGoal = goal;
      notifyListeners();
    }
  }

  List<Meal> get meals {
    _meals.sort((a, b) => b.date.compareTo(a.date));
    return [..._meals];
  }

  // Adds a meal coming from the camera-only flow
  void addMealFromCameraResult({required String name, required int calories}) {
    final newMeal = Meal(
      id: DateTime.now().toString(),
      name: name,
      calories: calories,
      date: DateTime.now(),
      isEaten: true,
    );
    _meals.add(newMeal);
    notifyListeners();
  }

  // Toggle mechanism for eaten status
  void toggleMealEatenStatus(String mealId) {
    final meal = _meals.firstWhere((meal) => meal.id == mealId);
    meal.isEaten = !meal.isEaten;
    notifyListeners();
  }

  // --- Weekly and monthly analysis helpers ---

  // Returns calories consumed today
  int get totalCaloriesEatenToday {
    final now = DateTime.now();
    return _meals
        .where((meal) =>
            meal.isEaten &&
            meal.date.year == now.year &&
            meal.date.month == now.month &&
            meal.date.day == now.day)
        .fold(0, (sum, meal) => sum + meal.calories);
  }

  // Total calories in the last 7 days
  int get totalCaloriesEatenThisWeek {
    final lastWeek = DateTime.now().subtract(const Duration(days: 7));
    return _meals
        .where((meal) => meal.isEaten && meal.date.isAfter(lastWeek))
        .fold(0, (sum, meal) => sum + meal.calories);
  }

  // Total calories in the last 30 days
  int get totalCaloriesEatenThisMonth {
    final lastMonth = DateTime.now().subtract(const Duration(days: 30));
    return _meals
        .where((meal) => meal.isEaten && meal.date.isAfter(lastMonth))
        .fold(0, (sum, meal) => sum + meal.calories);
  }
}