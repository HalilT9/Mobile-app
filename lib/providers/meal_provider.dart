// lib/providers/meal_provider.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/meal.dart';

class MealProvider with ChangeNotifier {
  // ⚠️ DİKKAT: Telefonun ve bilgisayarın aynı Wi-Fi'da olduğundan emin ol.
  // Backend'de "Running on http://10.207.23.213:5000" yazıyorsa burası doğrudur.
  static const String _baseUrl = 'http://10.78.171.213:5000/api';

  List<Meal> _meals = [];

  // Kullanıcı Hedefleri
  int _dailyCalorieGoal = 2000;
  int _weeklyCalorieGoal = 14000;
  int _monthlyCalorieGoal = 60000;

  // --- GETTERS ---
  List<Meal> get meals {
    // Tarihe göre tersten sırala (En yeni en üstte)
    _meals.sort((a, b) => b.date.compareTo(a.date));
    return [..._meals];
  }

  int get dailyCalorieGoal => _dailyCalorieGoal;
  int get weeklyCalorieGoal => _weeklyCalorieGoal;
  int get monthlyCalorieGoal => _monthlyCalorieGoal;

  // --- BACKEND ENTEGRASYONU ---

  /// Backend'den tüm verileri (Yemekler + Kullanıcı Hedefleri) çeker
  Future<void> fetchUserData(String userId) async {
    try {
      final mealUrl = Uri.parse('$_baseUrl/meals/$userId');
      final mealResponse = await http.get(mealUrl);

      if (mealResponse.statusCode == 200) {
        final List<dynamic> data = json.decode(mealResponse.body);
        _meals = data
            .map((jsonItem) => Meal(
                  id: jsonItem['id'].toString(), // ID'yi String'e çeviriyoruz
                  name: jsonItem['name'],
                  calories: jsonItem['calories'],
                  date: DateTime.parse(jsonItem['date']), // Tarih parsing
                  isEaten: jsonItem['isEaten'],
                ))
            .toList();
      }
      notifyListeners();
    } catch (error) {
      print("Veri çekme hatası: $error");
      // Hata olsa bile uygulamayı kırmamak için rethrow yapmıyoruz,
      // sadece logluyoruz. Gerekirse açabilirsin.
    }
  }

  /// Yeni yemek ekler (Kamera veya Manuel)
  /// BU FONKSİYON DÜZELTİLDİ ✅
  Future<void> addMeal(String userId, String name, int calories) async {
    print("YEMEK GÖNDERİLİYOR! Hedef Adres: $_baseUrl/meals/add");
    final url = Uri.parse('$_baseUrl/meals/add');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': userId,
          'name': name,
          'calories': calories,
          'isEaten': true,
          // Tarihi buradan gönderiyoruz ki Backend geri gönderebilsin
          'date': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        // --- KRİTİK DÜZELTME ---
        // Backend veriyi direkt gönderiyor, 'meal' kutusu yok.
        // responseData['meal'] DEĞİL, direkt responseData kullanıyoruz.
        final newMealJson = responseData;

        final newMeal = Meal(
          id: newMealJson['id']
              .toString(), // Backend int gönderiyor, String yapıyoruz
          name: newMealJson['name'],
          calories: newMealJson['calories'],
          date: DateTime.parse(newMealJson['date']),
          isEaten: newMealJson['isEaten'],
        );

        _meals.add(newMeal);
        notifyListeners();
      } else {
        print("Server hatası: ${response.statusCode}");
      }
    } catch (error) {
      print("Yemek ekleme hatası: $error");
      rethrow;
    }
  }

  /// Yendi/Yenmedi durumunu değiştirir
  Future<void> toggleMealEatenStatus(String mealId) async {
    final url = Uri.parse('$_baseUrl/meals/toggle/$mealId');

    final mealIndex = _meals.indexWhere((meal) => meal.id == mealId);
    if (mealIndex >= 0) {
      // Önce arayüzde değiştir
      _meals[mealIndex].isEaten = !_meals[mealIndex].isEaten;
      notifyListeners();

      try {
        // Sonra backend'e haber ver (Şimdilik backend'de bu endpoint yoksa hata verebilir,
        // ama arayüz çalışmaya devam eder)
        // final response = await http.post(url);
      } catch (e) {
        // Hata olursa geri al
        _meals[mealIndex].isEaten = !_meals[mealIndex].isEaten;
        notifyListeners();
        print("Toggle hatası: $e");
      }
    }
  }

  // --- HEDEF GÜNCELLEME ---

  Future<void> updateDailyCalorieGoal(String userId, int goal) async {
    if (goal > 0 && goal <= 10000) {
      _dailyCalorieGoal = goal;
      notifyListeners();
      await _updateGoalOnServer(userId, {'dailyCalorieGoal': goal});
    }
  }

  Future<void> updateWeeklyCalorieGoal(String userId, int goal) async {
    if (goal > 0 && goal <= 100000) {
      _weeklyCalorieGoal = goal;
      notifyListeners();
      await _updateGoalOnServer(userId, {'weeklyCalorieGoal': goal});
    }
  }

  Future<void> updateMonthlyCalorieGoal(String userId, int goal) async {
    if (goal > 0 && goal <= 500000) {
      _monthlyCalorieGoal = goal;
      notifyListeners();
      await _updateGoalOnServer(userId, {'monthlyCalorieGoal': goal});
    }
  }

  Future<void> _updateGoalOnServer(
      String userId, Map<String, dynamic> data) async {
    final url = Uri.parse('$_baseUrl/goals/update');
    try {
      await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'userId': userId, ...data}),
      );
    } catch (e) {
      print("Hedef güncelleme hatası: $e");
    }
  }

  // --- ANALİZ FONKSİYONLARI ---

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

  int get totalCaloriesEatenThisWeek {
    final lastWeek = DateTime.now().subtract(const Duration(days: 7));
    return _meals
        .where((meal) => meal.isEaten && meal.date.isAfter(lastWeek))
        .fold(0, (sum, meal) => sum + meal.calories);
  }

  int get totalCaloriesEatenThisMonth {
    final lastMonth = DateTime.now().subtract(const Duration(days: 30));
    return _meals
        .where((meal) => meal.isEaten && meal.date.isAfter(lastMonth))
        .fold(0, (sum, meal) => sum + meal.calories);
  }
}
