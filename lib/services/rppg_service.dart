// lib/services/rppg_service.dart

import 'dart:async';
import 'package:camera/camera.dart';
import '../models/sensor_data_model.dart';
import 'camera_service.dart';
import 'signal_processing_service.dart';

/// Service untuk rPPG (Remote Photoplethysmography)
class RPPGService {
  final CameraService _cameraService;
  
  // Signal buffers
  final List<double> _redSignal = [];
  final List<double> _greenSignal = [];
  final List<double> _blueSignal = [];
  final List<DateTime> _timestamps = [];
  
  // Results
  double _currentHeartRate = 0;
  double _currentHRV = 0;
  double _currentRespiration = 0;
  double _currentStress = 0;
  
  // Configuration
  // --- START PERBAIKAN 6: Mengatur jumlah minimal sampel yang konsisten
  static const int _minSamplesForAnalysis = 150; // ~30 seconds at 5 FPS
  // --- END PERBAIKAN 6
  static const int _maxBufferSize = 300; // ~60 seconds
  static const Duration _frameInterval = Duration(milliseconds: 200); // 5 FPS
  
  DateTime? _lastFrameTime;
  bool _isProcessing = false;
  
  Function(SensorData)? _onDataCallback;

  RPPGService(this._cameraService);

  /// Start rPPG monitoring
  Future<void> startMonitoring(Function(SensorData) onData) async {
    _onDataCallback = onData;
    _clearBuffers();
    
    _cameraService.startStreaming((CameraImage image, FaceDetectionData? faceData) {
      _processFrame(image, faceData);
    });
  }

  /// Process camera frame
  void _processFrame(CameraImage image, FaceDetectionData? faceData) async {
    // Rate limiting
    final now = DateTime.now();
    if (_lastFrameTime != null && 
        now.difference(_lastFrameTime!) < _frameInterval) {
      return;
    }
    _lastFrameTime = now;

    if (_isProcessing || faceData == null || !faceData.faceDetected) {
      // Jika wajah tidak terdeteksi, tetap kirim data kosong/default
      _sendCurrentData(faceData ?? FaceDetectionData(
        faceDetected: false, faceConfidence: 0, emotionConfidence: 0, position: FacePosition(x: 0, y: 0, width: 0, height: 0),
      ));
      return;
    }

    _isProcessing = true;

    try {
      // Extract RGB from face ROI
      final rgb = _cameraService.extractRGBFromROI(image, faceData.position);
      
      // Add to buffers
      _redSignal.add(rgb[0]);
      _greenSignal.add(rgb[1]);
      _blueSignal.add(rgb[2]);
      _timestamps.add(now);

      // Maintain buffer size
      if (_redSignal.length > _maxBufferSize) {
        _redSignal.removeAt(0);
        _greenSignal.removeAt(0);
        _blueSignal.removeAt(0);
        _timestamps.removeAt(0);
      }

      // Analyze if we have enough samples
      if (_redSignal.length >= _minSamplesForAnalysis) {
        await _analyzeSignals();
      }

      // Send current data
      _sendCurrentData(faceData);
    } catch (e) {
      print('Error processing frame: $e');
    } finally {
      _isProcessing = false;
    }
  }

  /// Analyze RGB signals to extract vital signs
  Future<void> _analyzeSignals() async {
    try {
      // Calculate sampling rate
      final duration = _timestamps.last.difference(_timestamps.first);
      // Cek untuk menghindari pembagian dengan nol atau durasi yang sangat kecil
      final samplingRate = duration.inSeconds > 0 
          ? _redSignal.length / duration.inSeconds 
          : 5.0; // Default 5 FPS

      // Apply ICA to separate heart signal from noise
      final heartSignal = SignalProcessingService.applyICA(
        _redSignal,
        _greenSignal,
        _blueSignal,
      );

      // Apply band-pass filter (0.7-4.0 Hz for heart rate)
      final filteredSignal = SignalProcessingService.bandPassFilter(
        heartSignal,
        samplingRate,
      );

      // Remove outliers
      final cleanedSignal = SignalProcessingService.removeOutliers(filteredSignal);

      // Extract heart rate using FFT
      _currentHeartRate = SignalProcessingService.extractHeartRate(
        cleanedSignal,
        samplingRate,
      );

      // Calculate HRV from recent heart rates
      final recentHR = _getRecentHeartRates();
      if (recentHR.length >= 5) {
        _currentHRV = SignalProcessingService.calculateHRV(recentHR);
      }

      // Detect respiration rate
      _currentRespiration = SignalProcessingService.detectRespirationRate(
        heartSignal,
        samplingRate,
      );

      // Calculate stress level
      _currentStress = SignalProcessingService.calculateStressLevel(
        _currentHeartRate,
        _currentHRV,
      );

    } catch (e) {
      print('Error analyzing signals: $e');
    }
  }

  /// Get recent heart rate values for HRV calculation
  List<double> _getRecentHeartRates() {
    // Return last 20 heart rate values (simplified)
    const historySize = 20;
    if (_redSignal.length < historySize) return [];
    
    // Menggunakan sinyal yang sudah diolah untuk mendekati heart rate data
    final recent = _redSignal.sublist(_redSignal.length - historySize);
    return recent;
  }

  /// Send current data via callback
  void _sendCurrentData(FaceDetectionData faceData) {
    if (_onDataCallback == null) return;

    // Hanya menggunakan hasil analisis jika sudah ada cukup data
    final double hr = hasEnoughData ? _currentHeartRate : 0.0;
    final double hrv = hasEnoughData ? _currentHRV : 0.0;
    final double resp = hasEnoughData ? _currentRespiration : 0.0;
    final double stress = hasEnoughData ? _currentStress : 0.0;
    
    final sensorData = SensorData(
      heartRate: hr,
      hrv: hrv,
      respirationRate: resp,
      stressLevel: stress,
      accelerometer: AccelerometerData.initial(), // Akan diisi oleh accelerometer service
      faceData: faceData,
      timestamp: DateTime.now(),
    );

    _onDataCallback!(sensorData);
  }

  /// Stop monitoring
  Future<void> stopMonitoring() async {
    await _cameraService.stopStreaming();
    _onDataCallback = null;
  }

  /// Clear all buffers
  void _clearBuffers() {
    _redSignal.clear();
    _greenSignal.clear();
    _blueSignal.clear();
    _timestamps.clear();
    _currentHeartRate = 0;
    _currentHRV = 0;
    _currentRespiration = 0;
    _currentStress = 0;
    _lastFrameTime = null;
  }

  /// Get current vital signs
  Map<String, double> getCurrentVitalSigns() {
    return {
      'heartRate': _currentHeartRate,
      'hrv': _currentHRV,
      'respiration': _currentRespiration,
      'stress': _currentStress,
    };
  }

  /// Check if enough data for analysis
  bool get hasEnoughData => _redSignal.length >= _minSamplesForAnalysis;

  /// Get buffer fill percentage
  double get bufferFillPercentage => 
      (_redSignal.length / _minSamplesForAnalysis).clamp(0.0, 1.0);

  /// Get RGB signal data (for debugging/visualization)
  RGBSignalData? getRGBSignalData() {
    if (_redSignal.isEmpty) return null;

    return RGBSignalData(
      redChannel: List.from(_redSignal),
      greenChannel: List.from(_greenSignal),
      blueChannel: List.from(_blueSignal),
      startTime: _timestamps.first,
      endTime: _timestamps.last,
    );
  }
}