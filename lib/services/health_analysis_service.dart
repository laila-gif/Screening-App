// lib/services/health_analysis_service.dart

import 'dart:math';
import '../models/sensor_data_model.dart';
import '../models/health_analysis_model.dart';

/// Service untuk analisis kesehatan mental menggunakan data sensor
class HealthAnalysisService {
  /// Analyze sensor data dan hitung SKD (Skor Kebutuhan Dukungan)
  static HealthAnalysisResult analyzeHealth(
    List<SensorData> sensorDataHistory,
    MovementPattern movementPattern,
  ) {
    if (sensorDataHistory.isEmpty) {
      return _getDefaultResult();
    }

    // Calculate averages
    final avgHeartRate = _calculateAverage(
      sensorDataHistory.map((d) => d.heartRate).toList(),
    );
    final avgHRV = _calculateAverage(
      sensorDataHistory.map((d) => d.hrv).toList(),
    );
    final avgStress = _calculateAverage(
      sensorDataHistory.map((d) => d.stressLevel).toList(),
    );

    // Analyze emotion pattern
    final emotionPattern = _analyzeEmotionPattern(sensorDataHistory);

    // Create indicators
    final indicators = _createHealthIndicators(
      avgHeartRate,
      avgHRV,
      avgStress,
      movementPattern,
      emotionPattern,
    );

    // Calculate SKD using Weighted Regression Model
    final skdScore = _calculateSKD(indicators);

    // Determine stress level
    final stressLevel = _determineStressLevel(skdScore, avgStress);

    // Generate recommendations
    final recommendations = _generateRecommendations(
      skdScore,
      indicators,
      stressLevel,
    );

    // Check if professional help is needed
    final needsProfessional = skdScore >= 7 || 
                              avgStress > 0.8 ||
                              movementPattern == MovementPattern.agitated;

    // Create summary
    final summary = SensorDataSummary(
      avgHeartRate: avgHeartRate,
      avgHRV: avgHRV,
      avgStress: avgStress,
      movementPattern: movementPattern,
      emotionPattern: emotionPattern,
      dataPoints: sensorDataHistory.length,
      monitoringDuration: sensorDataHistory.last.timestamp
          .difference(sensorDataHistory.first.timestamp),
    );

    return HealthAnalysisResult(
      skdScore: skdScore,
      stressLevel: stressLevel,
      indicators: indicators,
      recommendations: recommendations,
      needsProfessionalHelp: needsProfessional,
      analysisTime: DateTime.now(),
      sensorSummary: summary,
    );
  }

  /// Calculate SKD using Weighted Regression Model
  /// Formula: SKD = 1 + 9 / (1 + e^(-(β₁F₁ + β₂F₂ + ... + βₙFₙ)))
  static double _calculateSKD(List<HealthIndicator> indicators) {
    // Calculate weighted sum
    double weightedSum = 0;
    
    for (final indicator in indicators) {
      // Normalize indicator value to 0-1 scale based on status
      double normalizedValue = 0;
      switch (indicator.status) {
        case IndicatorStatus.good:
          normalizedValue = 0.1;
          break;
        case IndicatorStatus.normal:
          normalizedValue = 0.3;
          break;
        case IndicatorStatus.warning:
          normalizedValue = 0.7;
          break;
        case IndicatorStatus.critical:
          normalizedValue = 0.9;
          break;
      }
      
      weightedSum += indicator.weight * normalizedValue;
    }

    // Apply sigmoid function to map to 1-10 scale
    final sigmoid = 1 / (1 + exp(-weightedSum));
    final skd = 1 + 9 * sigmoid;

    return skd.clamp(1.0, 10.0);
  }

  /// Create health indicators from sensor data
  static List<HealthIndicator> _createHealthIndicators(
    double avgHeartRate,
    double avgHRV,
    double avgStress,
    MovementPattern movementPattern,
    EmotionPattern emotionPattern,
  ) {
    final indicators = <HealthIndicator>[];

    // 1. Heart Rate Indicator
    IndicatorStatus hrStatus;
    String hrInterpretation;
    if (avgHeartRate < 60 || avgHeartRate > 100) {
      hrStatus = IndicatorStatus.warning;
      hrInterpretation = avgHeartRate < 60
          ? 'Detak jantung rendah, mungkin menandakan kelelahan'
          : 'Detak jantung tinggi, menandakan stres atau kecemasan';
    } else if (avgHeartRate > 85) {
      hrStatus = IndicatorStatus.normal;
      hrInterpretation = 'Detak jantung sedikit meningkat, perhatikan tingkat stres';
    } else {
      hrStatus = IndicatorStatus.good;
      hrInterpretation = 'Detak jantung dalam rentang normal';
    }

    indicators.add(HealthIndicator(
      name: 'Heart Rate',
      value: avgHeartRate,
      status: hrStatus,
      unit: 'BPM',
      interpretation: hrInterpretation,
      weight: 2.5, // High weight - important indicator
    ));

    // 2. HRV Indicator
    IndicatorStatus hrvStatus;
    String hrvInterpretation;
    if (avgHRV < 30) {
      hrvStatus = IndicatorStatus.critical;
      hrvInterpretation = 'HRV sangat rendah, menandakan stres tinggi';
    } else if (avgHRV < 40) {
      hrvStatus = IndicatorStatus.warning;
      hrvInterpretation = 'HRV rendah, tubuh dalam kondisi stres';
    } else if (avgHRV < 50) {
      hrvStatus = IndicatorStatus.normal;
      hrvInterpretation = 'HRV normal, kondisi tubuh cukup baik';
    } else {
      hrvStatus = IndicatorStatus.good;
      hrvInterpretation = 'HRV baik, tubuh dalam kondisi rileks';
    }

    indicators.add(HealthIndicator(
      name: 'HRV (Heart Rate Variability)',
      value: avgHRV,
      status: hrvStatus,
      unit: 'ms',
      interpretation: hrvInterpretation,
      weight: 3.0, // Highest weight - most important
    ));

    // 3. Stress Level Indicator
    IndicatorStatus stressStatus;
    String stressInterpretation;
    if (avgStress > 0.7) {
      stressStatus = IndicatorStatus.critical;
      stressInterpretation = 'Tingkat stres sangat tinggi, butuh intervensi segera';
    } else if (avgStress > 0.5) {
      stressStatus = IndicatorStatus.warning;
      stressInterpretation = 'Tingkat stres tinggi, perlu teknik relaksasi';
    } else if (avgStress > 0.3) {
      stressStatus = IndicatorStatus.normal;
      stressInterpretation = 'Tingkat stres sedang, masih dapat dikelola';
    } else {
      stressStatus = IndicatorStatus.good;
      stressInterpretation = 'Tingkat stres rendah, kondisi mental baik';
    }

    indicators.add(HealthIndicator(
      name: 'Stress Level',
      value: avgStress * 100,
      status: stressStatus,
      unit: '%',
      interpretation: stressInterpretation,
      weight: 2.8,
    ));

    // 4. Movement Pattern Indicator
    IndicatorStatus movementStatus;
    String movementInterpretation;
    double movementValue;
    
    switch (movementPattern) {
      case MovementPattern.calm:
        movementStatus = IndicatorStatus.good;
        movementInterpretation = 'Gerakan tenang, kondisi mental stabil';
        movementValue = 10;
        break;
      case MovementPattern.normal:
        movementStatus = IndicatorStatus.normal;
        movementInterpretation = 'Gerakan normal, tidak ada tanda kegelisahan';
        movementValue = 30;
        break;
      case MovementPattern.restless:
        movementStatus = IndicatorStatus.warning;
        movementInterpretation = 'Gerakan gelisah, menandakan kecemasan';
        movementValue = 70;
        break;
      case MovementPattern.agitated:
        movementStatus = IndicatorStatus.critical;
        movementInterpretation = 'Gerakan sangat gelisah, kecemasan tinggi';
        movementValue = 90;
        break;
    }

    indicators.add(HealthIndicator(
      name: 'Pola Gerakan',
      value: movementValue,
      status: movementStatus,
      unit: '',
      interpretation: movementInterpretation,
      weight: 2.0,
    ));

    // 5. Emotion Pattern Indicator
    IndicatorStatus emotionStatus;
    String emotionInterpretation;
    double emotionValue;

    switch (emotionPattern) {
      case EmotionPattern.positive:
        emotionStatus = IndicatorStatus.good;
        emotionInterpretation = 'Ekspresi emosi positif, kondisi mental baik';
        emotionValue = 80;
        break;
      case EmotionPattern.neutral:
        emotionStatus = IndicatorStatus.normal;
        emotionInterpretation = 'Ekspresi emosi netral, kondisi stabil';
        emotionValue = 50;
        break;
      case EmotionPattern.negative:
        emotionStatus = IndicatorStatus.warning;
        emotionInterpretation = 'Ekspresi emosi negatif, perlu perhatian';
        emotionValue = 30;
        break;
      case EmotionPattern.anxious:
        emotionStatus = IndicatorStatus.critical;
        emotionInterpretation = 'Ekspresi kecemasan terdeteksi, butuh dukungan';
        emotionValue = 10;
        break;
      case EmotionPattern.mixed:
        emotionStatus = IndicatorStatus.normal;
        emotionInterpretation = 'Ekspresi emosi bervariasi';
        emotionValue = 40;
        break;
    }

    indicators.add(HealthIndicator(
      name: 'Pola Emosi',
      value: emotionValue,
      status: emotionStatus,
      unit: '',
      interpretation: emotionInterpretation,
      weight: 1.5,
    ));

    return indicators;
  }

  /// Analyze emotion pattern from sensor data
  static EmotionPattern _analyzeEmotionPattern(List<SensorData> history) {
    final emotions = history
        .where((d) => d.faceData != null && d.faceData!.emotion != null)
        .map((d) => d.faceData!.emotion!)
        .toList();

    if (emotions.isEmpty) return EmotionPattern.neutral;

    final happyCount = emotions.where((e) => e == EmotionType.happy).length;
    final sadCount = emotions.where((e) => e == EmotionType.sad).length;
    final anxiousCount = emotions.where((e) => e == EmotionType.anxious).length;
    final neutralCount = emotions.where((e) => e == EmotionType.neutral).length;

    if (anxiousCount > emotions.length * 0.5) {
      return EmotionPattern.anxious;
    } else if (happyCount > emotions.length * 0.5) {
      return EmotionPattern.positive;
    } else if (sadCount > emotions.length * 0.4) {
      return EmotionPattern.negative;
    } else if (neutralCount > emotions.length * 0.6) {
      return EmotionPattern.neutral;
    } else {
      return EmotionPattern.mixed;
    }
  }

  /// Determine stress level from SKD and stress value
  static StressLevel _determineStressLevel(double skd, double stressValue) {
    if (skd >= 8 || stressValue > 0.8) {
      return StressLevel.veryHigh;
    } else if (skd >= 6 || stressValue > 0.6) {
      return StressLevel.high;
    } else if (skd >= 4 || stressValue > 0.4) {
      return StressLevel.moderate;
    } else if (skd >= 2.5 || stressValue > 0.2) {
      return StressLevel.normal;
    } else {
      return StressLevel.low;
    }
  }

  /// Generate recommendations based on analysis
  static List<String> _generateRecommendations(
    double skdScore,
    List<HealthIndicator> indicators,
    StressLevel stressLevel,
  ) {
    final recommendations = <String>[];

    // General recommendations based on SKD
    if (skdScore >= 7) {
      recommendations.add(
        '⚠️ Sangat disarankan untuk berkonsultasi dengan psikolog atau psikiater profesional',
      );
      recommendations.add(
        '📞 Pertimbangkan untuk menghubungi hotline kesehatan mental 24/7',
      );
    } else if (skdScore >= 5) {
      recommendations.add(
        '💬 Berbicara dengan konselor atau terapis dapat sangat membantu',
      );
    }

    // Recommendations based on specific indicators
    for (final indicator in indicators) {
      if (indicator.status == IndicatorStatus.critical ||
          indicator.status == IndicatorStatus.warning) {
        if (indicator.name == 'Heart Rate') {
          recommendations.add(
            '🧘 Praktikkan teknik pernapasan dalam untuk menurunkan detak jantung',
          );
        } else if (indicator.name.contains('HRV')) {
          recommendations.add(
            '😌 Lakukan meditasi atau yoga untuk meningkatkan HRV Anda',
          );
        } else if (indicator.name == 'Stress Level') {
          recommendations.add(
            '🎵 Dengarkan musik yang menenangkan atau lakukan aktivitas yang Anda nikmati',
          );
        } else if (indicator.name == 'Pola Gerakan') {
          recommendations.add(
            '🚶 Cobalah berjalan kaki ringan atau stretching untuk mengurangi ketegangan',
          );
        }
      }
    }

    // General wellness recommendations
    if (stressLevel == StressLevel.low || stressLevel == StressLevel.normal) {
      recommendations.add(
        '✨ Pertahankan pola hidup sehat dengan tidur cukup dan olahraga teratur',
      );
    }

    recommendations.add(
      '📝 Coba tulis jurnal harian untuk mengekspresikan perasaan Anda',
    );

    return recommendations;
  }

  /// Calculate average from list of doubles
  static double _calculateAverage(List<double> values) {
    if (values.isEmpty) return 0;
    final validValues = values.where((v) => v > 0).toList();
    if (validValues.isEmpty) return 0;
    return validValues.reduce((a, b) => a + b) / validValues.length;
  }

  /// Get default result when no data available
  static HealthAnalysisResult _getDefaultResult() {
    return HealthAnalysisResult(
      skdScore: 5.0,
      stressLevel: StressLevel.normal,
      indicators: [],
      recommendations: [
        'Mulai monitoring untuk mendapatkan analisis yang akurat',
      ],
      needsProfessionalHelp: false,
      analysisTime: DateTime.now(),
      sensorSummary: SensorDataSummary(
        avgHeartRate: 0,
        avgHRV: 0,
        avgStress: 0,
        movementPattern: MovementPattern.normal,
        emotionPattern: EmotionPattern.neutral,
        dataPoints: 0,
        monitoringDuration: Duration.zero,
      ),
    );
  }
}