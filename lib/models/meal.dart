// lib/models/meal.dart

class Meal {
  final String id;
  final String name;
  final int calories;
  final DateTime date; // Timestamp used for weekly/monthly analysis
  bool isEaten;

  Meal({
    required this.id,
    required this.name,
    required this.calories,
    required this.date,
    this.isEaten = false,
  });
}