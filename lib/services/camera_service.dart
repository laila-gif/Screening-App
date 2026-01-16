// lib/services/camera_service.dart

import 'dart:typed_data';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;
import '../models/sensor_data_model.dart';

/// Service untuk mengelola kamera dan face detection
class CameraService {
  CameraController? _cameraController;
  final FaceDetector _faceDetector;
  bool _isProcessing = false;

  CameraService()
      : _faceDetector = FaceDetector(
          options: FaceDetectorOptions(
            enableLandmarks: true,
            enableContours: true,
            enableClassification: true,
            enableTracking: true,
            performanceMode: FaceDetectorMode.accurate,
          ),
        );

  /// Inisialisasi kamera
  Future<void> initialize() async {
    try {
      final cameras = await availableCameras();
      
      // Gunakan front camera untuk face detection
      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await _cameraController!.initialize();
      
      // Set flash off untuk rPPG
      await _cameraController!.setFlashMode(FlashMode.off);
    } catch (e) {
      throw Exception('Camera initialization failed: $e');
    }
  }

  /// Start streaming frames untuk processing
  void startStreaming(Function(CameraImage, FaceDetectionData?) onFrame) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      throw Exception('Camera not initialized. Call initialize() first');
    }

    _cameraController!.startImageStream((CameraImage image) async {
      if (_isProcessing) return;
      _isProcessing = true;

      try {
        // Detect face
        final faceData = await _detectFace(image);
        
        // Callback dengan frame dan face data
        onFrame(image, faceData);
      } catch (e) {
        print('Error processing frame: $e');
      } finally {
        _isProcessing = false;
      }
    });
  }

  /// Stop streaming
  Future<void> stopStreaming() async {
    if (_cameraController != null && _cameraController!.value.isStreamingImages) {
      await _cameraController!.stopImageStream();
    }
  }

  /// Detect face dari camera image
  Future<FaceDetectionData?> _detectFace(CameraImage image) async {
    try {
      // Convert CameraImage to InputImage for MLKit
      final inputImage = _convertToInputImage(image);
      if (inputImage == null) return null;

      // Detect faces
      final faces = await _faceDetector.processImage(inputImage);
      
      if (faces.isEmpty) {
        return null;
      }

      final face = faces.first;
      final boundingBox = face.boundingBox;

      // Classify emotion (simplified based on smile probability)
      EmotionType emotion = EmotionType.neutral;
      double emotionConfidence = 0.5;

      if (face.smilingProbability != null) {
        final smileProb = face.smilingProbability!;
        if (smileProb > 0.7) {
          emotion = EmotionType.happy;
          emotionConfidence = smileProb;
        } else if (smileProb < 0.3) {
          emotion = EmotionType.sad;
          emotionConfidence = 1 - smileProb;
        }
      }

      return FaceDetectionData(
        faceDetected: true,
        faceConfidence: face.headEulerAngleY != null ? 0.9 : 0.7,
        emotion: emotion,
        emotionConfidence: emotionConfidence,
        position: FacePosition(
          x: boundingBox.left,
          y: boundingBox.top,
          width: boundingBox.width,
          height: boundingBox.height,
        ),
      );
    } catch (e) {
      print('Error detecting face: $e');
      return null;
    }
  }

  /// Convert CameraImage to InputImage for MLKit
  InputImage? _convertToInputImage(CameraImage image) {
    try {
      final WriteBuffer allBytes = WriteBuffer();
      for (final plane in image.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      final bytes = allBytes.done().buffer.asUint8List();

      const imageRotation = InputImageRotation.rotation0deg;

      final inputImageData = InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: imageRotation,
        format: InputImageFormat.yuv420,
        bytesPerRow: image.planes[0].bytesPerRow,
      );

      return InputImage.fromBytes(
        bytes: bytes,
        metadata: inputImageData,
      );
    } catch (e) {
      print('Error converting image: $e');
      return null;
    }
  }

  /// Extract RGB values dari ROI (Region of Interest - area wajah)
  List<double> extractRGBFromROI(CameraImage image, FacePosition facePosition) {
    try {
      // Convert YUV to RGB
      final rgbImage = _convertYUVtoRGB(image);
      if (rgbImage == null) return [0, 0, 0];

      // Calculate ROI bounds
      final roiX = facePosition.x.toInt().clamp(0, rgbImage.width - 1);
      final roiY = facePosition.y.toInt().clamp(0, rgbImage.height - 1);
      final roiWidth = facePosition.width.toInt().clamp(1, rgbImage.width - roiX);
      final roiHeight = facePosition.height.toInt().clamp(1, rgbImage.height - roiY);

      // Average RGB values in ROI
      double avgRed = 0, avgGreen = 0, avgBlue = 0;
      int pixelCount = 0;

      for (int y = roiY; y < roiY + roiHeight; y++) {
        for (int x = roiX; x < roiX + roiWidth; x++) {
          final pixel = rgbImage.getPixel(x, y);
          avgRed += pixel.r.toDouble();
          avgGreen += pixel.g.toDouble();
          avgBlue += pixel.b.toDouble();
          pixelCount++;
        }
      }

      if (pixelCount == 0) return [0, 0, 0];

      return [
        avgRed / pixelCount,
        avgGreen / pixelCount,
        avgBlue / pixelCount,
      ];
    } catch (e) {
      print('Error extracting RGB: $e');
      return [0, 0, 0];
    }
  }

  /// Convert YUV420 to RGB
  img.Image? _convertYUVtoRGB(CameraImage image) {
    try {
      final int width = image.width;
      final int height = image.height;
      final int uvRowStride = image.planes[1].bytesPerRow;
      final int uvPixelStride = image.planes[1].bytesPerPixel ?? 1;

      final rgbImage = img.Image(width: width, height: height);

      for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
          final int uvIndex = uvPixelStride * (x / 2).floor() + 
                             uvRowStride * (y / 2).floor();
          final int index = y * width + x;

          final yp = image.planes[0].bytes[index];
          final up = image.planes[1].bytes[uvIndex];
          final vp = image.planes[2].bytes[uvIndex];

          // Convert YUV to RGB
          int r = (yp + vp * 1436 / 1024 - 179).round().clamp(0, 255);
          int g = (yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91)
              .round()
              .clamp(0, 255);
          int b = (yp + up * 1814 / 1024 - 227).round().clamp(0, 255);

          rgbImage.setPixelRgb(x, y, r, g, b);
        }
      }

      return rgbImage;
    } catch (e) {
      print('Error converting YUV to RGB: $e');
      return null;
    }
  }

  /// Get camera controller untuk preview
  CameraController? get cameraController => _cameraController;

  /// Check if camera is initialized
  bool get isInitialized => 
      _cameraController != null && _cameraController!.value.isInitialized;

  /// Dispose resources
  Future<void> dispose() async {
    await stopStreaming();
    await _cameraController?.dispose();
    await _faceDetector.close();
  }
}