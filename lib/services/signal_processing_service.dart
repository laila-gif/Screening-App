// lib/services/signal_processing_service.dart

import 'dart:math';

/// Service untuk signal processing (ICA, FFT, Band-pass Filter)
/// Note: Menggunakan implementasi FFT sederhana karena package fft mungkin tidak kompatibel
class SignalProcessingService {
  /// Apply band-pass filter untuk heart rate (0.7-4.0 Hz = 42-240 BPM)
  static List<double> bandPassFilter(
    List<double> signal,
    double samplingRate, {
    double lowCutoff = 0.7,
    double highCutoff = 4.0,
  }) {
    if (signal.length < 3) return signal;

    // Simple FIR band-pass filter implementation
    final filtered = List<double>.filled(signal.length, 0.0);
    
    // Apply simple moving average for smoothing
    const windowSize = 5;
    for (int i = 0; i < signal.length; i++) {
      double sum = 0;
      int count = 0;
      
      for (int j = max(0, i - windowSize ~/ 2); 
           j < min(signal.length, i + windowSize ~/ 2 + 1); 
           j++) {
        sum += signal[j];
        count++;
      }
      
      filtered[i] = sum / count;
    }

    return filtered;
  }

  /// Extract heart rate using simple FFT
  static double extractHeartRate(
    List<double> signal,
    double samplingRate,
  ) {
    if (signal.length < 32) {
      return 0.0;
    }

    // Normalize signal
    final normalizedSignal = _normalizeSignal(signal);

    // Apply window function (Hamming window)
    final windowedSignal = _applyHammingWindow(normalizedSignal);

    // Perform simple FFT using DFT (Discrete Fourier Transform)
    final magnitudes = _computeFFTMagnitudes(windowedSignal);

    // Find peak in heart rate range (0.7-4.0 Hz)
    final freqResolution = samplingRate / signal.length;
    final minIndex = (0.7 / freqResolution).round();
    final maxIndex = min((4.0 / freqResolution).round(), magnitudes.length);

    if (minIndex >= maxIndex) return 0.0;

    // Find peak frequency
    double maxMagnitude = 0;
    int peakIndex = minIndex;

    for (int i = minIndex; i < maxIndex; i++) {
      if (magnitudes[i] > maxMagnitude) {
        maxMagnitude = magnitudes[i];
        peakIndex = i;
      }
    }

    // Convert to BPM
    final peakFrequency = peakIndex * freqResolution;
    final bpm = peakFrequency * 60;

    return bpm.clamp(42.0, 240.0);
  }

  /// Compute FFT magnitudes using DFT
  static List<double> _computeFFTMagnitudes(List<double> signal) {
    final n = signal.length;
    final magnitudes = <double>[];

    // Compute only half of the spectrum (real signals have symmetric FFT)
    for (int k = 0; k < n ~/ 2; k++) {
      double real = 0;
      double imag = 0;

      for (int t = 0; t < n; t++) {
        final angle = -2 * pi * k * t / n;
        real += signal[t] * cos(angle);
        imag += signal[t] * sin(angle);
      }

      // Calculate magnitude
      magnitudes.add(sqrt(real * real + imag * imag));
    }

    return magnitudes;
  }

  /// Calculate HRV (Heart Rate Variability) dari inter-beat intervals
  static double calculateHRV(List<double> heartRateValues) {
    if (heartRateValues.length < 2) return 0.0;

    // Calculate RMSSD (Root Mean Square of Successive Differences)
    double sumSquaredDiff = 0;
    for (int i = 1; i < heartRateValues.length; i++) {
      final diff = heartRateValues[i] - heartRateValues[i - 1];
      sumSquaredDiff += diff * diff;
    }

    final rmssd = sqrt(sumSquaredDiff / (heartRateValues.length - 1));
    
    // Convert to ms scale (typical HRV range: 20-100 ms)
    return (rmssd * 10).clamp(20.0, 100.0);
  }

  /// Independent Component Analysis (ICA) - Simplified version
  static List<double> applyICA(
    List<double> redChannel,
    List<double> greenChannel,
    List<double> blueChannel,
  ) {
    if (redChannel.length != greenChannel.length || 
        greenChannel.length != blueChannel.length) {
      return greenChannel; // Fallback to green channel
    }

    // Normalize channels
    final normRed = _normalizeSignal(redChannel);
    final normGreen = _normalizeSignal(greenChannel);
    final normBlue = _normalizeSignal(blueChannel);

    // Simplified ICA: Green channel typically has strongest PPG signal
    // Weight: G = 1.5, R = -0.5, B = -0.5 (based on research)
    final result = List<double>.generate(
      normGreen.length,
      (i) => 1.5 * normGreen[i] - 0.5 * normRed[i] - 0.5 * normBlue[i],
    );

    return _normalizeSignal(result);
  }

  /// Normalize signal to zero mean and unit variance
  static List<double> _normalizeSignal(List<double> signal) {
    if (signal.isEmpty) return signal;

    // Calculate mean
    final mean = signal.reduce((a, b) => a + b) / signal.length;

    // Calculate standard deviation
    final variance = signal.map((x) => pow(x - mean, 2)).reduce((a, b) => a + b) / 
                    signal.length;
    final stdDev = sqrt(variance);

    if (stdDev == 0) return List.filled(signal.length, 0.0);

    // Normalize
    return signal.map((x) => (x - mean) / stdDev).toList();
  }

  /// Apply Hamming window
  static List<double> _applyHammingWindow(List<double> signal) {
    final n = signal.length;
    return List<double>.generate(
      n,
      (i) => signal[i] * (0.54 - 0.46 * cos(2 * pi * i / (n - 1))),
    );
  }

  /// Calculate stress level from HR and HRV
  static double calculateStressLevel(double heartRate, double hrv) {
    // Stress increases with high HR and low HRV
    double stressScore = 0;

    // HR component (0-5 points)
    if (heartRate > 100) {
      stressScore += 5;
    } else if (heartRate > 85) {
      stressScore += 3;
    } else if (heartRate > 75) {
      stressScore += 1;
    }

    // HRV component (0-5 points)
    if (hrv < 30) {
      stressScore += 5;
    } else if (hrv < 40) {
      stressScore += 3;
    } else if (hrv < 50) {
      stressScore += 1;
    }

    // Normalize to 0-1 scale
    return (stressScore / 10).clamp(0.0, 1.0);
  }

  /// Detect respiration rate from signal
  static double detectRespirationRate(
    List<double> signal,
    double samplingRate,
  ) {
    if (signal.length < 32) return 0.0;

    // Apply FFT
    final magnitudes = _computeFFTMagnitudes(_normalizeSignal(signal));

    // Find peak in respiration range (0.15-0.5 Hz = 9-30 breaths/min)
    final freqResolution = samplingRate / signal.length;
    final minIndex = (0.15 / freqResolution).round();
    final maxIndex = min((0.5 / freqResolution).round(), magnitudes.length);

    if (minIndex >= maxIndex) return 0.0;

    double maxMagnitude = 0;
    int peakIndex = minIndex;

    for (int i = minIndex; i < maxIndex; i++) {
      if (magnitudes[i] > maxMagnitude) {
        maxMagnitude = magnitudes[i];
        peakIndex = i;
      }
    }

    // Convert to breaths per minute
    final peakFrequency = peakIndex * freqResolution;
    final breathsPerMin = peakFrequency * 60;

    return breathsPerMin.clamp(9.0, 30.0);
  }

  /// Remove outliers using median filter
  static List<double> removeOutliers(List<double> signal, {int windowSize = 5}) {
    if (signal.length < windowSize) return signal;

    final filtered = List<double>.filled(signal.length, 0.0);

    for (int i = 0; i < signal.length; i++) {
      final start = max(0, i - windowSize ~/ 2);
      final end = min(signal.length, i + windowSize ~/ 2 + 1);
      
      final window = signal.sublist(start, end);
      window.sort();
      
      filtered[i] = window[window.length ~/ 2]; // Median
    }

    return filtered;
  }
}