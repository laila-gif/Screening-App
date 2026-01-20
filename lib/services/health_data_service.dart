// lib/services/health_data_service.dart

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Service untuk mengelola semua data kesehatan mental
class HealthDataService {
  static final HealthDataService _instance = HealthDataService._internal();
  factory HealthDataService() => _instance;
  HealthDataService._internal();

  // Keys untuk SharedPreferences
  static const String _keyTestHistory = 'test_history';
  static const String _keySKDHistory = 'skd_history';
  static const String _keyMeditationData = 'meditation_data';
  static const String _keySensorData = 'sensor_data';
  static const String _keyMoodHistory = 'mood_history';
  static const String _keyCurrentSKD = 'current_skd';

  // ==================== SKD & TEST MANAGEMENT ====================
  
  /// Menyimpan hasil tes mental dan menghitung SKD
  Future<void> saveTestResult({
    required int score,
    required int maxScore,
    required String category,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Hitung SKD dari skor tes (0-30 -> 1-10)
    final skdScore = _calculateSKDFromTest(score, maxScore);
    
    // Simpan ke test history
    List<String> history = prefs.getStringList(_keyTestHistory) ?? [];
    final testData = {
      'score': score,
      'maxScore': maxScore,
      'category': category,
      'date': DateTime.now().toIso8601String(),
      'skdScore': skdScore,
    };
    history.insert(0, jsonEncode(testData)); // Insert di awal
    
    // Batasi history max 50 item
    if (history.length > 50) {
      history = history.sublist(0, 50);
    }
    
    await prefs.setStringList(_keyTestHistory, history);
    
    // Simpan SKD history untuk grafik
    await _saveSKDHistory(skdScore);
    
    // Update current SKD
    await prefs.setDouble(_keyCurrentSKD, skdScore);
  }

  /// Menghitung SKD dari hasil tes mental (1-10 scale)
  double _calculateSKDFromTest(int score, int maxScore) {
    final percentage = (score / maxScore) * 100;
    
    // Konversi ke skala 1-10
    // 0-20% = SKD 1-2 (Baik)
    // 21-40% = SKD 3-4 (Normal)
    // 41-60% = SKD 5-6 (Normal-Tinggi)
    // 61-80% = SKD 7-8 (Perlu Perhatian)
    // 81-100% = SKD 9-10 (Tinggi)
    
    if (percentage <= 20) return 1 + (percentage / 20) * 1;
    if (percentage <= 40) return 2 + ((percentage - 20) / 20) * 2;
    if (percentage <= 60) return 4 + ((percentage - 40) / 20) * 2;
    if (percentage <= 80) return 6 + ((percentage - 60) / 20) * 2;
    return 8 + ((percentage - 80) / 20) * 2;
  }

  /// Menyimpan SKD ke history untuk grafik tren
  Future<void> _saveSKDHistory(double skdScore) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList(_keySKDHistory) ?? [];
    
    final skdData = {
      'score': skdScore,
      'date': DateTime.now().toIso8601String(),
    };
    
    history.add(jsonEncode(skdData));
    
    // Batasi 90 hari
    if (history.length > 90) {
      history = history.sublist(history.length - 90);
    }
    
    await prefs.setStringList(_keySKDHistory, history);
  }

  /// Mendapatkan history tes mental
  Future<List<Map<String, dynamic>>> getTestHistory() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList(_keyTestHistory) ?? [];
    
    return history.map((item) {
      return jsonDecode(item) as Map<String, dynamic>;
    }).toList();
  }

  /// Mendapatkan data SKD untuk grafik 7 hari terakhir
  Future<List<Map<String, dynamic>>> getSKDTrend7Days() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList(_keySKDHistory) ?? [];
    
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));
    
    List<Map<String, dynamic>> trendData = history.map((item) {
      return jsonDecode(item) as Map<String, dynamic>;
    }).where((item) {
      final date = DateTime.parse(item['date']);
      return date.isAfter(sevenDaysAgo);
    }).toList();
    
    // Jika tidak ada data, generate dummy data
    if (trendData.isEmpty) {
      return _generateDummySKDData();
    }
    
    return trendData;
  }

  /// Generate dummy SKD data jika belum ada tes
  List<Map<String, dynamic>> _generateDummySKDData() {
    final now = DateTime.now();
    return List.generate(7, (index) {
      return {
        'score': 5.0 - (index * 0.3), // Menurun dari 5.0 ke 3.2
        'date': now.subtract(Duration(days: 6 - index)).toIso8601String(),
      };
    });
  }

  /// Mendapatkan current SKD
  Future<double> getCurrentSKD() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_keyCurrentSKD) ?? 5.0; // Default 5.0
  }

  // ==================== MEDITATION MANAGEMENT ====================
  
  /// Menyimpan sesi meditasi yang selesai
  Future<void> saveMeditationSession({
    required String title,
    required int durationMinutes,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load data meditasi saat ini
    final meditationDataStr = prefs.getString(_keyMeditationData);
    Map<String, dynamic> meditationData;
    
    if (meditationDataStr != null) {
      meditationData = jsonDecode(meditationDataStr);
    } else {
      meditationData = {
        'totalMinutes': 0,
        'weeklyMinutes': 0,
        'streak': 0,
        'lastSessionDate': null,
        'sessions': [],
      };
    }
    
    // Update data
    meditationData['totalMinutes'] = (meditationData['totalMinutes'] ?? 0) + durationMinutes;
    
    // Hitung weekly minutes (7 hari terakhir)
    final sessions = List<Map<String, dynamic>>.from(meditationData['sessions'] ?? []);
    sessions.insert(0, {
      'title': title,
      'duration': durationMinutes,
      'date': DateTime.now().toIso8601String(),
    });
    
    // Batasi 100 sesi terakhir
    if (sessions.length > 100) {
      sessions.removeRange(100, sessions.length);
    }
    
    meditationData['sessions'] = sessions;
    
    // Hitung weekly minutes
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));
    int weeklyMinutes = 0;
    for (var session in sessions) {
      final date = DateTime.parse(session['date']);
      if (date.isAfter(sevenDaysAgo)) {
        weeklyMinutes += session['duration'] as int;
      }
    }
    meditationData['weeklyMinutes'] = weeklyMinutes;
    
    // Update streak
    final lastSessionDate = meditationData['lastSessionDate'];
    if (lastSessionDate != null) {
      final lastDate = DateTime.parse(lastSessionDate);
      final daysDiff = DateTime.now().difference(lastDate).inDays;
      
      if (daysDiff <= 1) {
        meditationData['streak'] = (meditationData['streak'] ?? 0) + 1;
      } else {
        meditationData['streak'] = 1; // Reset streak
      }
    } else {
      meditationData['streak'] = 1;
    }
    
    meditationData['lastSessionDate'] = DateTime.now().toIso8601String();
    
    await prefs.setString(_keyMeditationData, jsonEncode(meditationData));
  }

  /// Mendapatkan data meditasi
  Future<Map<String, dynamic>> getMeditationData() async {
    final prefs = await SharedPreferences.getInstance();
    final dataStr = prefs.getString(_keyMeditationData);
    
    if (dataStr != null) {
      return jsonDecode(dataStr);
    }
    
    // Return default jika belum ada
    return {
      'totalMinutes': 0,
      'weeklyMinutes': 0,
      'streak': 0,
      'lastSessionDate': null,
      'sessions': [],
    };
  }

  // ==================== SENSOR DATA MANAGEMENT ====================
  
  /// Menyimpan data sensor (Heart Rate, HRV, Stress)
  Future<void> saveSensorData({
    required int heartRate,
    required int hrv,
    required double stress,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    final sensorData = {
      'heartRate': heartRate,
      'hrv': hrv,
      'stress': stress,
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    await prefs.setString(_keySensorData, jsonEncode(sensorData));
  }

  /// Mendapatkan data sensor terbaru
  Future<Map<String, dynamic>?> getCurrentSensorData() async {
    final prefs = await SharedPreferences.getInstance();
    final dataStr = prefs.getString(_keySensorData);
    
    if (dataStr != null) {
      return jsonDecode(dataStr);
    }
    
    // Return default values
    return {
      'heartRate': 75,
      'hrv': 45,
      'stress': 35.0,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  // ==================== MOOD TRACKING ====================
  
  /// Menyimpan mood harian
  Future<void> saveMood(String mood) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList(_keyMoodHistory) ?? [];
    
    final moodData = {
      'mood': mood,
      'date': DateTime.now().toIso8601String(),
    };
    
    history.insert(0, jsonEncode(moodData));
    
    // Batasi 90 hari
    if (history.length > 90) {
      history = history.sublist(0, 90);
    }
    
    await prefs.setStringList(_keyMoodHistory, history);
  }

  /// Mendapatkan mood hari ini
  Future<String?> getTodayMood() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList(_keyMoodHistory) ?? [];
    
    if (history.isEmpty) return null;
    
    final latest = jsonDecode(history[0]) as Map<String, dynamic>;
    final latestDate = DateTime.parse(latest['date']);
    final now = DateTime.now();
    
    // Check if same day
    if (latestDate.year == now.year &&
        latestDate.month == now.month &&
        latestDate.day == now.day) {
      return latest['mood'];
    }
    
    return null;
  }

  // ==================== ANALYTICS & RECOMMENDATIONS ====================
  
  /// Mendapatkan rekomendasi berdasarkan data terkini
  Future<List<Map<String, dynamic>>> getRecommendations() async {
    final currentSKD = await getCurrentSKD();
    final sensorData = await getCurrentSensorData();
    final meditationData = await getMeditationData();
    
    List<Map<String, dynamic>> recommendations = [];
    
    // Rekomendasi berdasarkan SKD
    if (currentSKD > 6) {
      recommendations.add({
        'icon': '🧘',
        'text': 'Lakukan meditasi 15 menit untuk mengurangi stres',
        'priority': 'high',
      });
      recommendations.add({
        'icon': '📝',
        'text': 'Tulis jurnal untuk mengekspresikan perasaan',
        'priority': 'high',
      });
    } else if (currentSKD > 4) {
      recommendations.add({
        'icon': '🧘',
        'text': 'Lakukan meditasi 10 menit untuk menjaga ketenangan',
        'priority': 'medium',
      });
    }
    
    // Rekomendasi berdasarkan HRV
    if (sensorData != null && sensorData['hrv'] < 40) {
      recommendations.add({
        'icon': '💓',
        'text': 'Tingkatkan HRV dengan latihan pernapasan',
        'priority': 'medium',
      });
    }
    
    // Rekomendasi berdasarkan meditasi
    final weeklyMinutes = meditationData['weeklyMinutes'] ?? 0;
    if (weeklyMinutes < 100) {
      recommendations.add({
        'icon': '⏰',
        'text': 'Tambah durasi meditasi untuk mencapai target mingguan',
        'priority': 'low',
      });
    }
    
    return recommendations;
  }

  /// Reset semua data (untuk testing)
  Future<void> resetAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyTestHistory);
    await prefs.remove(_keySKDHistory);
    await prefs.remove(_keyMeditationData);
    await prefs.remove(_keySensorData);
    await prefs.remove(_keyMoodHistory);
    await prefs.remove(_keyCurrentSKD);
  }
}