// lib/screens/ai_sensor_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/language_service.dart';
import 'package:camera/camera.dart';
import 'dart:async';
import '../services/camera_service.dart';
import '../services/rppg_service.dart';
import '../services/accelerometer_service.dart';
import '../services/health_analysis_service.dart';
import '../models/sensor_data_model.dart';
import '../models/health_analysis_model.dart';
import 'doctor_list_screen.dart';
import 'ai_chat_screen.dart';

class AISensorScreen extends StatefulWidget {
  const AISensorScreen({Key? key}) : super(key: key);

  @override
  State<AISensorScreen> createState() => _AISensorScreenState();
}

class _AISensorScreenState extends State<AISensorScreen> {
  // Services
  late CameraService _cameraService;
  late RPPGService _rppgService;
  late AccelerometerService _accelerometerService;

  // State
  bool _isInitialized = false;
  bool _isMonitoring = false;
  bool _showResult = false;

  SensorData _currentSensorData = SensorData.initial();
  final List<SensorData> _sensorHistory = [];
  HealthAnalysisResult? _analysisResult;

  Timer? _monitoringTimer;
  int _elapsedSeconds = 0;
  static const int _minMonitoringTime = 30; // Minimum 30 seconds

  // --- START PERBAIKAN 1: Menambah flag untuk mengendalikan penghentian otomatis
  bool _autoStopTriggered = false;
  // --- END PERBAIKAN 1

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  @override
  void dispose() {
    _stopMonitoring();
    _cameraService.dispose();
    _rppgService.stopMonitoring();
    _accelerometerService.dispose();
    _monitoringTimer?.cancel();
    super.dispose();
  }

  Future<void> _initializeServices() async {
    try {
      _cameraService = CameraService();
      await _cameraService.initialize();

      _rppgService = RPPGService(_cameraService);
      _accelerometerService = AccelerometerService();

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      final languageService = Provider.of<LanguageService>(
        context,
        listen: false,
      );
      String code = languageService.currentLanguageCode;
      if (code == 'system') code = languageService.currentLocale.languageCode;
      final msg = code.startsWith('en')
          ? 'Failed to initialize camera: $e'
          : code.startsWith('zh')
          ? '无法初始化相机：$e'
          : code.startsWith('ar')
          ? 'فشل تهيئة الكاميرا: $e'
          : 'Gagal menginisialisasi kamera: $e';
      _showError(msg);
    }
  }

  Future<void> _startMonitoring() async {
    setState(() {
      _isMonitoring = true;
      _showResult = false;
      _elapsedSeconds = 0;
      _sensorHistory.clear();
      // --- START PERBAIKAN 2
      _autoStopTriggered = false;
      // --- END PERBAIKAN 2
    });

    // Start rPPG monitoring
    await _rppgService.startMonitoring((sensorData) {
      if (!mounted) return;

      // Combine with accelerometer data
      final accelData = _accelerometerService.getCurrentData();
      if (accelData != null) {
        sensorData = SensorData(
          heartRate: sensorData.heartRate,
          hrv: sensorData.hrv,
          respirationRate: sensorData.respirationRate,
          stressLevel: sensorData.stressLevel,
          accelerometer: accelData,
          faceData: sensorData.faceData,
          timestamp: sensorData.timestamp,
        );
      }

      if (mounted) {
        setState(() {
          _currentSensorData = sensorData;
          _sensorHistory.add(sensorData);

          // --- START PERBAIKAN 3: Cek kondisi stop setelah data diterima
          if (_isMonitoring &&
              !_autoStopTriggered &&
              _elapsedSeconds >= _minMonitoringTime &&
              _rppgService.hasEnoughData) {
            _autoStopTriggered = true;
            _stopMonitoring(); // Panggil stopMonitoring() secara otomatis
          }
          // --- END PERBAIKAN 3
        });
      }
    });

    // Start accelerometer monitoring
    _accelerometerService.startMonitoring((accelData) {
      // Already handled in rPPG callback
    });

    // Start timer
    _monitoringTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _elapsedSeconds++;
      });

      // --- START PERBAIKAN 4: Cek kondisi stop di timer sebagai backup
      if (_isMonitoring &&
          !_autoStopTriggered &&
          _elapsedSeconds >= _minMonitoringTime &&
          _rppgService.hasEnoughData) {
        _autoStopTriggered = true;
        _stopMonitoring(); // Panggil stopMonitoring() secara otomatis
      }
      // --- END PERBAIKAN 4
    });
  }

  Future<void> _stopMonitoring() async {
    // Pastikan hanya di-stop jika sedang monitoring
    if (!_isMonitoring) return;

    _monitoringTimer?.cancel();
    await _rppgService.stopMonitoring();
    _accelerometerService.stopMonitoring();

    // Pastikan data cukup dan minimum waktu tercapai sebelum analisis
    if (_sensorHistory.isNotEmpty && _elapsedSeconds >= _minMonitoringTime) {
      // Tunggu sebentar untuk memastikan semua data frame terakhir masuk
      await Future.delayed(const Duration(milliseconds: 500));
      _analyzeResults();
    } else {
      // Jika dihentikan secara manual sebelum 30 detik, reset state monitoring
      if (mounted) {
        final languageService = Provider.of<LanguageService>(
          context,
          listen: false,
        );
        String code = languageService.currentLanguageCode;
        if (code == 'system') code = languageService.currentLocale.languageCode;
        final stopMsg = code.startsWith('en')
            ? 'Monitoring stopped. Minimum ${_minMonitoringTime} seconds not reached.'
            : code.startsWith('zh')
            ? '监测已停止。未达到至少 ${_minMonitoringTime} 秒。'
            : code.startsWith('ar')
            ? 'تم إيقاف المراقبة. لم يتم الوصول إلى الحد الأدنى ${_minMonitoringTime} ثانية.'
            : 'Monitoring dihentikan. Data minimal ${_minMonitoringTime} detik tidak tercapai.';
        _showError(stopMsg);
      }
    }

    if (mounted) {
      setState(() {
        _isMonitoring = false;
        // Reset auto stop flag jika dihentikan secara manual
        _autoStopTriggered = false;
      });
    }
  }

  void _analyzeResults() {
    final movementPattern = _accelerometerService.getMovementPattern();
    final result = HealthAnalysisService.analyzeHealth(
      _sensorHistory,
      movementPattern,
    );

    if (mounted) {
      setState(() {
        _analysisResult = result;
        _showResult = true;
      });
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageService>(
      builder: (context, languageService, child) {
        String code = languageService.currentLanguageCode;
        if (code == 'system') code = languageService.currentLocale.languageCode;

        // localized labels
        final String appBarTitle = code.startsWith('en')
            ? 'AI Sensor Check'
            : code.startsWith('zh')
            ? 'AI 传感器检查'
            : code.startsWith('ar')
            ? 'فحص المستشعر بالذكاء الاصطناعي'
            : 'Pemeriksaan AI dengan Sensor';

        return Scaffold(
          backgroundColor: const Color(0xFFF5EFD0),
          appBar: AppBar(
            backgroundColor: const Color(0xFFF5EFD0),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black87),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              appBarTitle,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          body: !_isInitialized
              ? const Center(child: CircularProgressIndicator())
              : _showResult && _analysisResult != null
              ? _buildResultView()
              : _buildMonitoringView(),
        );
      },
    );
  }

  Widget _buildMonitoringView() {
    return Column(
      children: [
        // Camera Preview
        Expanded(flex: 3, child: _buildCameraPreview()),

        // Sensor Data Display
        Expanded(flex: 2, child: _buildSensorDataDisplay()),

        // Control Panel
        _buildControlPanel(),
      ],
    );
  }

  Widget _buildCameraPreview() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Camera Preview
            if (_cameraService.isInitialized)
              CameraPreview(_cameraService.cameraController!)
            else
              const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),

            // Face Detection Overlay
            if (_currentSensorData.faceData != null &&
                _currentSensorData.faceData!.faceDetected)
              CustomPaint(
                painter: FaceOverlayPainter(_currentSensorData.faceData!),
                child: Container(),
              ),

            // Status Indicator
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _currentSensorData.faceData?.faceDetected == true
                      ? Colors.green.withOpacity(0.9)
                      : Colors.red.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _currentSensorData.faceData?.faceDetected == true
                          ? Icons.check_circle
                          : Icons.warning,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Builder(
                      builder: (context) {
                        final languageService = Provider.of<LanguageService>(
                          context,
                          listen: false,
                        );
                        String code = languageService.currentLanguageCode;
                        if (code == 'system') {
                          code = languageService.currentLocale.languageCode;
                        }
                        final detected =
                            _currentSensorData.faceData?.faceDetected == true;
                        final text = detected
                            ? (code.startsWith('en')
                                  ? 'Face Detected'
                                  : code.startsWith('zh')
                                  ? '检测到人脸'
                                  : code.startsWith('ar')
                                  ? 'تم اكتشاف الوجه'
                                  : 'Wajah Terdeteksi')
                            : (code.startsWith('en')
                                  ? 'Position Face'
                                  : code.startsWith('zh')
                                  ? '请调整人脸位置'
                                  : code.startsWith('ar')
                                  ? 'ضع وجهك'
                                  : 'Posisikan Wajah');

                        return Text(
                          text,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Timer
            if (_isMonitoring)
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.timer, color: Colors.white, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        '${_elapsedSeconds ~/ 60}:${(_elapsedSeconds % 60).toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Instructions
            if (!_isMonitoring)
              Center(
                child: Container(
                  margin: const EdgeInsets.all(24),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Builder(
                    builder: (context) {
                      final languageService = Provider.of<LanguageService>(
                        context,
                        listen: false,
                      );
                      String code = languageService.currentLanguageCode;
                      if (code == 'system') {
                        code = languageService.currentLocale.languageCode;
                      }
                      final instr = code.startsWith('en')
                          ? '📸 Position your face in the center of the camera\n💡 Ensure enough lighting\n🧘 Sit comfortably and relax'
                          : code.startsWith('zh')
                          ? '📸 将面部放在摄像头中央\n💡 确保光线充足\n🧘 坐姿舒适并放松'
                          : code.startsWith('ar')
                          ? '📸 ضع وجهك في وسط الكاميرا\n💡 تأكد من وجود إضاءة كافية\n🧘 اجلس بشكل مريح واسترخِ'
                          : '📸 Posisikan wajah Anda di tengah kamera\n💡 Pastikan pencahayaan cukup\n🧘 Duduk dengan nyaman dan rileks';

                      return Text(
                        instr,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      );
                    },
                  ),
                ),
              ),

            // --- START PERBAIKAN 5: Ganti 'Posisi Wajah' menjadi indikator yang lebih jelas
            if (_isMonitoring &&
                _currentSensorData.faceData?.faceDetected != true)
              Positioned.fill(
                child: Container(
                  color: Colors.black54,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Builder(
                        builder: (context) {
                          final languageService = Provider.of<LanguageService>(
                            context,
                            listen: false,
                          );
                          String code = languageService.currentLanguageCode;
                          if (code == 'system') {
                            code = languageService.currentLocale.languageCode;
                          }
                          final warn = code.startsWith('en')
                              ? '⚠️ Position face in the center of the camera'
                              : code.startsWith('zh')
                              ? '⚠️ 请将面部置于摄像头中央'
                              : code.startsWith('ar')
                              ? '⚠️ ضع وجهك في وسط الكاميرا'
                              : '⚠️ Posisikan Wajah di Tengah Kamera';

                          return Text(
                            warn,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            // --- END PERBAIKAN 5
          ],
        ),
      ),
    );
  }

  Widget _buildSensorDataDisplay() {
    return Builder(
      builder: (context) {
        final languageService = Provider.of<LanguageService>(
          context,
          listen: false,
        );
        String code = languageService.currentLanguageCode;
        if (code == 'system') code = languageService.currentLocale.languageCode;

        final analysisReadyText = code.startsWith('en')
            ? 'Analysis Ready!'
            : code.startsWith('zh')
            ? '分析准备就绪！'
            : code.startsWith('ar')
            ? 'التحليل جاهز!'
            : 'Analisis Siap!';

        String minimalTimeText(int seconds) {
          if (code.startsWith('en')) {
            return 'Minimum $seconds seconds...';
          }
          if (code.startsWith('zh')) {
            return '最少 $seconds 秒...';
          }
          if (code.startsWith('ar')) {
            return 'الحد الأدنى $seconds ثانية...';
          }
          return 'Minimal $seconds detik...';
        }

        final labelHeart = code.startsWith('en')
            ? 'Heart Rate'
            : code.startsWith('zh')
            ? '心率'
            : code.startsWith('ar')
            ? 'معدل ضربات القلب'
            : 'Detak Jantung';
        final labelHRV = 'HRV';
        final labelStress = code.startsWith('en')
            ? 'Stress Level'
            : code.startsWith('zh')
            ? '压力水平'
            : code.startsWith('ar')
            ? 'مستوى التوتر'
            : 'Tingkat Stres';
        final labelResp = code.startsWith('en')
            ? 'Respiration'
            : code.startsWith('zh')
            ? '呼吸'
            : code.startsWith('ar')
            ? 'التنفس'
            : 'Pernapasan';

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              // Progress Bar
              if (_isMonitoring) ...[
                LinearProgressIndicator(
                  value: _rppgService.bufferFillPercentage,
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF6B9080),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${(_rppgService.bufferFillPercentage * 100).toInt()}% - Mengumpulkan data (${_rppgService.bufferFillPercentage >= 1.0 ? analysisReadyText : minimalTimeText(_minMonitoringTime)})', // Menambahkan indikator status analisis
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
                const SizedBox(height: 16),
              ],

              // Sensor Cards
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  childAspectRatio: 1.3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  children: [
                    _buildSensorCard(
                      icon: Icons.favorite,
                      label: labelHeart,
                      value: _currentSensorData.heartRate.toInt().toString(),
                      unit: 'BPM',
                      color: Colors.red,
                    ),
                    _buildSensorCard(
                      icon: Icons.auto_graph,
                      label: labelHRV,
                      value: _currentSensorData.hrv.toInt().toString(),
                      unit: 'ms',
                      color: Colors.blue,
                    ),
                    _buildSensorCard(
                      icon: Icons.psychology,
                      label: labelStress,
                      value:
                          '${(_currentSensorData.stressLevel * 100).toInt()}',
                      unit: '%',
                      color: Colors.orange,
                    ),
                    _buildSensorCard(
                      icon: Icons.air,
                      label: labelResp,
                      value: _currentSensorData.respirationRate
                          .toInt()
                          .toString(),
                      unit: '/min',
                      color: Colors.teal,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSensorCard({
    required IconData icon,
    required String label,
    required String value,
    required String unit,
    required Color color,
  }) {
    final hasValue = value != '0';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: hasValue ? color : Colors.grey, size: 28),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.black.withOpacity(0.6),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: hasValue ? color : Colors.grey,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  unit,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black.withOpacity(0.5),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlPanel() {
    // Tombol 'Stop' hanya aktif jika waktu minimal sudah tercapai
    final bool canStop = _isMonitoring && _elapsedSeconds >= _minMonitoringTime;

    // Tombol 'Mulai' nonaktif saat monitoring
    final bool canStart = !_isMonitoring;

    return Builder(
      builder: (context) {
        final languageService = Provider.of<LanguageService>(
          context,
          listen: false,
        );
        String code = languageService.currentLanguageCode;
        if (code == 'system') code = languageService.currentLocale.languageCode;

        final minimalMsg = code.startsWith('en')
            ? 'Minimum $_minMonitoringTime seconds for accurate analysis'
            : code.startsWith('zh')
            ? '至少 $_minMonitoringTime 秒以获得准确分析'
            : code.startsWith('ar')
            ? 'الحد الأدنى $_minMonitoringTime ثانية لتحليل دقيق'
            : 'Minimal $_minMonitoringTime detik untuk analisis akurat';

        final startLabel = code.startsWith('en')
            ? 'Start Monitoring'
            : code.startsWith('zh')
            ? '开始监测'
            : code.startsWith('ar')
            ? 'ابدأ المراقبة'
            : 'Mulai Monitoring';

        final stopTooltip = code.startsWith('en')
            ? 'Stop'
            : code.startsWith('zh')
            ? '停止'
            : code.startsWith('ar')
            ? 'إيقاف'
            : 'Stop';

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Column(
              children: [
                if (_isMonitoring && !canStop)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      minimalMsg,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.orange,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: canStart ? _startMonitoring : null,
                        icon: const Icon(Icons.play_arrow),
                        label: Text(startLabel),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6B9080),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                    if (_isMonitoring) ...[
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: canStop
                            ? _stopMonitoring
                            : null, // Hanya aktif jika waktu minimal tercapai
                        style: ElevatedButton.styleFrom(
                          backgroundColor: canStop
                              ? Colors.red
                              : Colors.grey, // Warna abu-abu jika tidak aktif
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Icon(Icons.stop, semanticLabel: stopTooltip),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildResultView() {
    final result = _analysisResult!;
    return Builder(
      builder: (context) {
        final languageService = Provider.of<LanguageService>(
          context,
          listen: false,
        );
        String code = languageService.currentLanguageCode;
        if (code == 'system') code = languageService.currentLocale.languageCode;

        final skdTitle = code.startsWith('en')
            ? 'Support Needs Score (SKD)'
            : code.startsWith('zh')
            ? '支持需求评分 (SKD)'
            : code.startsWith('ar')
            ? 'مؤشر احتياج الدعم (SKD)'
            : 'Skor Kebutuhan Dukungan (SKD)';

        final indicatorsTitle = code.startsWith('en')
            ? 'Health Indicators'
            : code.startsWith('zh')
            ? '健康指标'
            : code.startsWith('ar')
            ? 'مؤشرات الصحة'
            : 'Indikator Kesehatan';

        final recommendationsTitle = code.startsWith('en')
            ? 'Recommendations'
            : code.startsWith('zh')
            ? '建议'
            : code.startsWith('ar')
            ? 'توصيات'
            : 'Rekomendasi';

        final consultLabel = code.startsWith('en')
            ? 'Consult a Doctor'
            : code.startsWith('zh')
            ? '咨询医生'
            : code.startsWith('ar')
            ? 'استشارة طبيب'
            : 'Konsultasi dengan Dokter';

        final talkAI = code.startsWith('en')
            ? 'Talk to AI Assistant'
            : code.startsWith('zh')
            ? '与 AI 助手对话'
            : code.startsWith('ar')
            ? 'التحدث مع مساعد AI'
            : 'Bicara dengan AI Assistant';

        final retryLabel = code.startsWith('en')
            ? 'Retry Monitoring'
            : code.startsWith('zh')
            ? '重新监测'
            : code.startsWith('ar')
            ? 'إعادة المراقبة'
            : 'Monitoring Ulang';

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // SKD Score Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _getSKDGradientColors(result.skdScore),
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      skdTitle,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      result.skdScore.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 56,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      result.skdCategory,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Indicators
              Text(
                indicatorsTitle,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              ...result.indicators.map(
                (indicator) => _buildIndicatorCard(indicator),
              ),

              const SizedBox(height: 24),

              // Recommendations
              Text(
                recommendationsTitle,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: result.recommendations.map((rec) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• ', style: TextStyle(fontSize: 16)),
                          Expanded(
                            child: Text(
                              rec,
                              style: const TextStyle(
                                fontSize: 14,
                                height: 1.4,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 24),

              // Action Buttons
              if (result.needsProfessionalHelp)
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DoctorListScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.local_hospital),
                  label: Text(consultLabel),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),

              const SizedBox(height: 12),

              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AIChatScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.chat),
                label: Text(talkAI),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6B9080),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),

              const SizedBox(height: 12),

              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _showResult = false;
                    _sensorHistory.clear();
                    _elapsedSeconds = 0;
                  });
                },
                icon: const Icon(Icons.refresh),
                label: Text(retryLabel),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF6B9080),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  Widget _buildIndicatorCard(HealthIndicator indicator) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getStatusColor(indicator.status).withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: _getStatusColor(indicator.status).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Icon(
                _getStatusIcon(indicator.status),
                color: _getStatusColor(indicator.status),
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  indicator.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  indicator.interpretation,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${indicator.value.toStringAsFixed(0)} ${indicator.unit}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _getStatusColor(indicator.status),
            ),
          ),
        ],
      ),
    );
  }

  List<Color> _getSKDGradientColors(double skd) {
    if (skd < 3) {
      return [const Color(0xFF10B981), const Color(0xFF34D399)];
    } else if (skd < 5) {
      return [const Color(0xFF3B82F6), const Color(0xFF60A5FA)];
    } else if (skd < 7) {
      return [const Color(0xFFF59E0B), const Color(0xFFFBBF24)];
    } else {
      return [const Color(0xFFEF4444), const Color(0xFFF87171)];
    }
  }

  Color _getStatusColor(IndicatorStatus status) {
    switch (status) {
      case IndicatorStatus.good:
        return const Color(0xFF10B981);
      case IndicatorStatus.normal:
        return const Color(0xFF3B82F6);
      case IndicatorStatus.warning:
        return const Color(0xFFF59E0B);
      case IndicatorStatus.critical:
        return const Color(0xFFEF4444);
    }
  }

  IconData _getStatusIcon(IndicatorStatus status) {
    switch (status) {
      case IndicatorStatus.good:
        return Icons.check_circle;
      case IndicatorStatus.normal:
        return Icons.info;
      case IndicatorStatus.warning:
        return Icons.warning;
      case IndicatorStatus.critical:
        return Icons.error;
    }
  }
}

// Custom painter for face detection overlay
class FaceOverlayPainter extends CustomPainter {
  final FaceDetectionData faceData;

  FaceOverlayPainter(this.faceData);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.greenAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final rect = Rect.fromLTWH(
      faceData.position.x,
      faceData.position.y,
      faceData.position.width,
      faceData.position.height,
    );

    canvas.drawRect(rect, paint);

    // Draw emotion label
    if (faceData.emotion != null) {
      final textSpan = TextSpan(
        text: faceData.emotion.toString().split('.').last.toUpperCase(),
        style: const TextStyle(
          color: Colors.greenAccent,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(rect.left, rect.top - 25));
    }
  }

  @override
  bool shouldRepaint(FaceOverlayPainter oldDelegate) => true;
}
