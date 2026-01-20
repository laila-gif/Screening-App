// lib/services/accelerometer_service.dart

import 'dart:async';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';
import '../models/sensor_data_model.dart';
import '../models/health_analysis_model.dart';

/// Service untuk mengelola accelerometer sensor
class AccelerometerService {
  StreamSubscription<AccelerometerEvent>? _subscription;
  final List<AccelerometerData> _dataHistory = [];
  final int _maxHistorySize = 100; // Keep last 100 readings
  
  Function(AccelerometerData)? _onDataCallback;

  /// Start monitoring accelerometer
  void startMonitoring(Function(AccelerometerData) onData) {
    _onDataCallback = onData;
    
    _subscription = accelerometerEventStream(
      samplingPeriod: const Duration(milliseconds: 200), // 5 Hz sampling
    ).listen((AccelerometerEvent event) {
      final data = _processAccelerometerEvent(event);
      
      // Add to history
      _dataHistory.add(data);
      if (_dataHistory.length > _maxHistorySize) {
        _dataHistory.removeAt(0);
      }

      // Callback
      _onDataCallback?.call(data);
    });
  }

  /// Process accelerometer event
  AccelerometerData _processAccelerometerEvent(AccelerometerEvent event) {
    final x = event.x;
    final y = event.y;
    final z = event.z;

    // Calculate magnitude
    final magnitude = sqrt(x * x + y * y + z * z);

    // Classify movement type
    final movementType = _classifyMovement(magnitude);

    return AccelerometerData(
      x: x,
      y: y,
      z: z,
      magnitude: magnitude,
      movementType: movementType,
    );
  }

  /// Classify movement based on magnitude and patterns
  MovementType _classifyMovement(double magnitude) {
    // Analyze recent history for patterns
    if (_dataHistory.length < 5) {
      return MovementType.stable;
    }

    final recentMagnitudes = _dataHistory
        .sublist(max(0, _dataHistory.length - 10))
        .map((d) => d.magnitude)
        .toList();

    final avgMagnitude = recentMagnitudes.reduce((a, b) => a + b) / 
                        recentMagnitudes.length;
    
    final variance = _calculateVariance(recentMagnitudes, avgMagnitude);

    // Classification thresholds
    const double stableThreshold = 0.5;
    const double walkingThreshold = 2.0;
    const double restlessThreshold = 1.0;
    const double tremorVarianceThreshold = 0.8;

    // High variance = tremor (rapid small movements)
    if (variance > tremorVarianceThreshold && avgMagnitude < walkingThreshold) {
      return MovementType.tremor;
    }

    // High magnitude = walking
    if (avgMagnitude > walkingThreshold) {
      return MovementType.walking;
    }

    // Moderate variance = restless
    if (variance > stableThreshold) {
      return MovementType.restless;
    }

    // Low variance = stable
    return MovementType.stable;
  }

  /// Calculate variance of magnitudes
  double _calculateVariance(List<double> values, double mean) {
    if (values.isEmpty) return 0;
    
    double sumSquaredDiff = 0;
    for (final value in values) {
      final diff = value - mean;
      sumSquaredDiff += diff * diff;
    }
    
    return sumSquaredDiff / values.length;
  }

  /// Get movement pattern over time
  MovementPattern getMovementPattern() {
    if (_dataHistory.length < 20) {
      return MovementPattern.normal;
    }

    final recentData = _dataHistory.sublist(_dataHistory.length - 20);
    
    final tremorCount = recentData.where((d) => d.movementType == MovementType.tremor).length;
    final restlessCount = recentData.where((d) => d.movementType == MovementType.restless).length;
    final stableCount = recentData.where((d) => d.movementType == MovementType.stable).length;

    // Classification based on counts
    if (tremorCount > 10) {
      return MovementPattern.agitated;
    } else if (restlessCount > 12) {
      return MovementPattern.restless;
    } else if (stableCount > 15) {
      return MovementPattern.calm;
    } else {
      return MovementPattern.normal;
    }
  }

  /// Calculate stress indicator from movement (0-1 scale)
  double getStressIndicatorFromMovement() {
    if (_dataHistory.isEmpty) return 0.0;

    final pattern = getMovementPattern();
    
    switch (pattern) {
      case MovementPattern.calm:
        return 0.2;
      case MovementPattern.normal:
        return 0.4;
      case MovementPattern.restless:
        return 0.7;
      case MovementPattern.agitated:
        return 0.9;
    }
  }

  /// Get current accelerometer data
  AccelerometerData? getCurrentData() {
    return _dataHistory.isNotEmpty ? _dataHistory.last : null;
  }

  /// Get data history
  List<AccelerometerData> getHistory() {
    return List.unmodifiable(_dataHistory);
  }

  /// Stop monitoring
  void stopMonitoring() {
    _subscription?.cancel();
    _subscription = null;
  }

  /// Clear history
  void clearHistory() {
    _dataHistory.clear();
  }

  /// Check if monitoring is active
  bool get isMonitoring => _subscription != null;

  /// Dispose resources
  void dispose() {
    stopMonitoring();
    _dataHistory.clear();
  }
}