// lib/models/sensor_data_model.dart

/// Model untuk data sensor real-time
class SensorData {
  final double heartRate;
  final double hrv;
  final double respirationRate;
  final double stressLevel;
  final AccelerometerData accelerometer;
  final FaceDetectionData? faceData;
  final DateTime timestamp;

  SensorData({
    required this.heartRate,
    required this.hrv,
    required this.respirationRate,
    required this.stressLevel,
    required this.accelerometer,
    this.faceData,
    required this.timestamp,
  });

  factory SensorData.initial() {
    return SensorData(
      heartRate: 0,
      hrv: 0,
      respirationRate: 0,
      stressLevel: 0,
      accelerometer: AccelerometerData.initial(),
      faceData: null,
      timestamp: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'heartRate': heartRate,
      'hrv': hrv,
      'respirationRate': respirationRate,
      'stressLevel': stressLevel,
      'accelerometer': accelerometer.toJson(),
      'faceData': faceData?.toJson(),
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      heartRate: json['heartRate'] ?? 0.0,
      hrv: json['hrv'] ?? 0.0,
      respirationRate: json['respirationRate'] ?? 0.0,
      stressLevel: json['stressLevel'] ?? 0.0,
      accelerometer: AccelerometerData.fromJson(json['accelerometer']),
      faceData: json['faceData'] != null 
          ? FaceDetectionData.fromJson(json['faceData']) 
          : null,
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

/// Data dari accelerometer
class AccelerometerData {
  final double x;
  final double y;
  final double z;
  final double magnitude;
  final MovementType movementType;

  AccelerometerData({
    required this.x,
    required this.y,
    required this.z,
    required this.magnitude,
    required this.movementType,
  });

  factory AccelerometerData.initial() {
    return AccelerometerData(
      x: 0,
      y: 0,
      z: 9.8,
      magnitude: 9.8,
      movementType: MovementType.stable,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'x': x,
      'y': y,
      'z': z,
      'magnitude': magnitude,
      'movementType': movementType.toString().split('.').last,
    };
  }

  factory AccelerometerData.fromJson(Map<String, dynamic> json) {
    return AccelerometerData(
      x: json['x'] ?? 0.0,
      y: json['y'] ?? 0.0,
      z: json['z'] ?? 9.8,
      magnitude: json['magnitude'] ?? 9.8,
      movementType: MovementType.values.firstWhere(
        (e) => e.toString() == 'MovementType.${json['movementType']}',
        orElse: () => MovementType.stable,
      ),
    );
  }
}

/// Tipe gerakan dari accelerometer
enum MovementType {
  stable,      // Stabil/tidak bergerak
  walking,     // Berjalan
  restless,    // Gelisah
  tremor,      // Tremor/getaran
}

/// Data dari face detection
class FaceDetectionData {
  final bool faceDetected;
  final double faceConfidence;
  final EmotionType? emotion;
  final double emotionConfidence;
  final FacePosition position;

  FaceDetectionData({
    required this.faceDetected,
    required this.faceConfidence,
    this.emotion,
    required this.emotionConfidence,
    required this.position,
  });

  Map<String, dynamic> toJson() {
    return {
      'faceDetected': faceDetected,
      'faceConfidence': faceConfidence,
      'emotion': emotion?.toString().split('.').last,
      'emotionConfidence': emotionConfidence,
      'position': position.toJson(),
    };
  }

  factory FaceDetectionData.fromJson(Map<String, dynamic> json) {
    return FaceDetectionData(
      faceDetected: json['faceDetected'] ?? false,
      faceConfidence: json['faceConfidence'] ?? 0.0,
      emotion: json['emotion'] != null
          ? EmotionType.values.firstWhere(
              (e) => e.toString() == 'EmotionType.${json['emotion']}',
              orElse: () => EmotionType.neutral,
            )
          : null,
      emotionConfidence: json['emotionConfidence'] ?? 0.0,
      position: FacePosition.fromJson(json['position']),
    );
  }
}

/// Tipe emosi yang terdeteksi
enum EmotionType {
  neutral,
  happy,
  sad,
  anxious,
  angry,
  surprised,
}

/// Posisi wajah dalam frame
class FacePosition {
  final double x;
  final double y;
  final double width;
  final double height;

  FacePosition({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  Map<String, dynamic> toJson() {
    return {
      'x': x,
      'y': y,
      'width': width,
      'height': height,
    };
  }

  factory FacePosition.fromJson(Map<String, dynamic> json) {
    return FacePosition(
      x: json['x'] ?? 0.0,
      y: json['y'] ?? 0.0,
      width: json['width'] ?? 0.0,
      height: json['height'] ?? 0.0,
    );
  }
}

/// Data untuk signal processing (RGB values dari frame)
class RGBSignalData {
  final List<double> redChannel;
  final List<double> greenChannel;
  final List<double> blueChannel;
  final DateTime startTime;
  final DateTime endTime;

  RGBSignalData({
    required this.redChannel,
    required this.greenChannel,
    required this.blueChannel,
    required this.startTime,
    required this.endTime,
  });

  int get sampleCount => redChannel.length;
  
  Duration get duration => endTime.difference(startTime);
  
  double get samplingRate => sampleCount / duration.inSeconds;
}