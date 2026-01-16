// lib/models/health_analysis_model.dart

/// Model untuk hasil analisis kesehatan mental
class HealthAnalysisResult {
  final double skdScore;          // Skor Kebutuhan Dukungan (1-10)
  final StressLevel stressLevel;
  final List<HealthIndicator> indicators;
  final List<String> recommendations;
  final bool needsProfessionalHelp;
  final DateTime analysisTime;
  final SensorDataSummary sensorSummary;

  HealthAnalysisResult({
    required this.skdScore,
    required this.stressLevel,
    required this.indicators,
    required this.recommendations,
    required this.needsProfessionalHelp,
    required this.analysisTime,
    required this.sensorSummary,
  });

  String get skdCategory {
    if (skdScore <= 3) return 'Baik';
    if (skdScore <= 5) return 'Normal';
    if (skdScore <= 7) return 'Perlu Perhatian';
    return 'Perlu Bantuan Profesional';
  }

  Map<String, dynamic> toJson() {
    return {
      'skdScore': skdScore,
      'stressLevel': stressLevel.toString().split('.').last,
      'indicators': indicators.map((i) => i.toJson()).toList(),
      'recommendations': recommendations,
      'needsProfessionalHelp': needsProfessionalHelp,
      'analysisTime': analysisTime.toIso8601String(),
      'sensorSummary': sensorSummary.toJson(),
    };
  }

  factory HealthAnalysisResult.fromJson(Map<String, dynamic> json) {
    return HealthAnalysisResult(
      skdScore: json['skdScore'] ?? 0.0,
      stressLevel: StressLevel.values.firstWhere(
        (e) => e.toString() == 'StressLevel.${json['stressLevel']}',
        orElse: () => StressLevel.normal,
      ),
      indicators: (json['indicators'] as List?)
              ?.map((i) => HealthIndicator.fromJson(i))
              .toList() ??
          [],
      recommendations: List<String>.from(json['recommendations'] ?? []),
      needsProfessionalHelp: json['needsProfessionalHelp'] ?? false,
      analysisTime: DateTime.parse(json['analysisTime']),
      sensorSummary: SensorDataSummary.fromJson(json['sensorSummary']),
    );
  }
}

/// Level stress
enum StressLevel {
  low,      // Rendah
  normal,   // Normal
  moderate, // Sedang
  high,     // Tinggi
  veryHigh, // Sangat Tinggi
}

/// Indikator kesehatan individual
class HealthIndicator {
  final String name;
  final double value;
  final IndicatorStatus status;
  final String unit;
  final String interpretation;
  final double weight; // Bobot untuk SKD calculation

  HealthIndicator({
    required this.name,
    required this.value,
    required this.status,
    required this.unit,
    required this.interpretation,
    required this.weight,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'value': value,
      'status': status.toString().split('.').last,
      'unit': unit,
      'interpretation': interpretation,
      'weight': weight,
    };
  }

  factory HealthIndicator.fromJson(Map<String, dynamic> json) {
    return HealthIndicator(
      name: json['name'] ?? '',
      value: json['value'] ?? 0.0,
      status: IndicatorStatus.values.firstWhere(
        (e) => e.toString() == 'IndicatorStatus.${json['status']}',
        orElse: () => IndicatorStatus.normal,
      ),
      unit: json['unit'] ?? '',
      interpretation: json['interpretation'] ?? '',
      weight: json['weight'] ?? 1.0,
    );
  }
}

/// Status indikator
enum IndicatorStatus {
  good,     // Baik
  normal,   // Normal
  warning,  // Perlu Perhatian
  critical, // Kritis
}

/// Summary dari data sensor untuk analisis
class SensorDataSummary {
  final double avgHeartRate;
  final double avgHRV;
  final double avgStress;
  final MovementPattern movementPattern;
  final EmotionPattern emotionPattern;
  final int dataPoints;
  final Duration monitoringDuration;

  SensorDataSummary({
    required this.avgHeartRate,
    required this.avgHRV,
    required this.avgStress,
    required this.movementPattern,
    required this.emotionPattern,
    required this.dataPoints,
    required this.monitoringDuration,
  });

  Map<String, dynamic> toJson() {
    return {
      'avgHeartRate': avgHeartRate,
      'avgHRV': avgHRV,
      'avgStress': avgStress,
      'movementPattern': movementPattern.toString().split('.').last,
      'emotionPattern': emotionPattern.toString().split('.').last,
      'dataPoints': dataPoints,
      'monitoringDuration': monitoringDuration.inSeconds,
    };
  }

  factory SensorDataSummary.fromJson(Map<String, dynamic> json) {
    return SensorDataSummary(
      avgHeartRate: json['avgHeartRate'] ?? 0.0,
      avgHRV: json['avgHRV'] ?? 0.0,
      avgStress: json['avgStress'] ?? 0.0,
      movementPattern: MovementPattern.values.firstWhere(
        (e) => e.toString() == 'MovementPattern.${json['movementPattern']}',
        orElse: () => MovementPattern.normal,
      ),
      emotionPattern: EmotionPattern.values.firstWhere(
        (e) => e.toString() == 'EmotionPattern.${json['emotionPattern']}',
        orElse: () => EmotionPattern.neutral,
      ),
      dataPoints: json['dataPoints'] ?? 0,
      monitoringDuration: Duration(seconds: json['monitoringDuration'] ?? 0),
    );
  }
}

/// Pola gerakan selama monitoring
enum MovementPattern {
  calm,      // Tenang
  normal,    // Normal
  restless,  // Gelisah
  agitated,  // Sangat gelisah
}

/// Pola emosi selama monitoring
enum EmotionPattern {
  positive,  // Positif
  neutral,   // Netral
  negative,  // Negatif
  anxious,   // Cemas
  mixed,     // Campuran
}