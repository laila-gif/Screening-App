import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/journal_screen.dart';
import 'package:flutter_application_1/screens/mental_health_test_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'mental_health_test_screen.dart';
import 'meditation_screen.dart';
import 'journal_screen.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;
import '../services/health_data_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final HealthDataService _healthService = HealthDataService();
  
  String selectedMood = '';
  List<Map<String, dynamic>> testHistory = [];
  List<Map<String, dynamic>> skdTrendData = [];
  List<Map<String, dynamic>> recommendations = [];
  
  // Data dari service
  double currentSKD = 5.0;
  int currentHeartRate = 75;
  int currentHRV = 45;
  double currentStress = 35;
  int meditationMinutes = 0;
  int meditationStreak = 0;
  int weeklyGoal = 300;
  
  bool _isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadAllData();
  }

  void _initAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  Future<void> _loadAllData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load semua data secara parallel
      final results = await Future.wait([
        _healthService.getTestHistory(),
        _healthService.getCurrentSKD(),
        _healthService.getSKDTrend7Days(),
        _healthService.getCurrentSensorData(),
        _healthService.getMeditationData(),
        _healthService.getTodayMood(),
        _healthService.getRecommendations(),
      ]);

      if (mounted) {
        setState(() {
          testHistory = results[0] as List<Map<String, dynamic>>;
          currentSKD = results[1] as double;
          skdTrendData = results[2] as List<Map<String, dynamic>>;
          
          final sensorData = results[3] as Map<String, dynamic>?;
          if (sensorData != null) {
            currentHeartRate = sensorData['heartRate'] ?? 75;
            currentHRV = sensorData['hrv'] ?? 45;
            currentStress = sensorData['stress'] ?? 35.0;
          }
          
          final meditationData = results[4] as Map<String, dynamic>;
          meditationMinutes = meditationData['weeklyMinutes'] ?? 0;
          meditationStreak = meditationData['streak'] ?? 0;
          
          selectedMood = results[5] as String? ?? '';
          recommendations = results[6] as List<Map<String, dynamic>>;
          
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveMood(String mood) async {
    await _healthService.saveMood(mood);
    setState(() {
      selectedMood = mood;
    });
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 11) return 'Selamat pagi';
    if (hour >= 11 && hour < 15) return 'Selamat siang';
    if (hour >= 15 && hour < 18) return 'Selamat sore';
    return 'Selamat malam';
  }

  Color _getSKDColor(double score) {
    if (score <= 3) return const Color(0xFF10B981);
    if (score <= 5) return const Color(0xFF3B82F6);
    if (score <= 7) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  String _getSKDCategory(double score) {
    if (score <= 3) return 'Baik';
    if (score <= 5) return 'Normal';
    if (score <= 7) return 'Perlu Perhatian';
    return 'Tinggi';
  }

  Color _getTestColor(int percentage) {
    if (percentage < 25) return const Color(0xFF10B981);
    if (percentage < 45) return const Color(0xFF3B82F6);
    if (percentage < 65) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF5EFD0),
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF6B9080),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5EFD0),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadAllData,
          color: const Color(0xFF6B9080),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20.0),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Greeting
                  Text(
                    _getGreeting(),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Bagaimana kabar Anda hari ini?',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 1. CEK KONDISI MENTALMU
                  _buildMoodCheckSection(),
                  const SizedBox(height: 24),

                  // 2. STATUS KESEHATAN
                  _buildQuickStatsSection(),
                  const SizedBox(height: 24),

                  // 3. TREN SKOR SKD
                  _buildSKDTrendChart(),
                  const SizedBox(height: 24),

                  // 4. PROGRESS MEDITASI
                  _buildMeditationProgressSection(),
                  const SizedBox(height: 24),

                  // 5. REKOMENDASI HARI INI
                  _buildRecommendationsCard(),
                  const SizedBox(height: 24),

                  // 6. AKSES CEPAT
                  _buildQuickAccessSection(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============= 1. CEK KONDISI MENTALMU SECTION =============
  Widget _buildMoodCheckSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Bagaimana perasaanmu hari ini?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildMoodButton('😊', 'Senang', 'senang'),
            _buildMoodButton('😔', 'Sedih', 'sedih'),
            _buildMoodButton('😰', 'Cemas', 'cemas'),
            _buildMoodButton('😡', 'Marah', 'marah'),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFE0E7FF),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Cek Kondisi Mentalmu',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Ikuti tes singkat untuk lebih memahami dirimu.',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MentalHealthTestScreen(),
                    ),
                  );
                  _loadAllData(); // Refresh semua data setelah tes
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF374151),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      'Mulai Tes',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, size: 18),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMoodButton(String emoji, String label, String moodValue) {
    final isSelected = selectedMood == moodValue;
    return GestureDetector(
      onTap: () {
        _saveMood(moodValue);
      },
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? const Color(0xFF6B9080) : Colors.transparent,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 32),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: isSelected ? const Color(0xFF1F2937) : const Color(0xFF9CA3AF),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  // ============= 2. STATUS KESEHATAN SECTION =============
  Widget _buildQuickStatsSection() {
    // Hitung trend SKD dari history
    double? skdTrend;
    if (skdTrendData.length >= 2) {
      final latest = skdTrendData.last['score'] as double;
      final previous = skdTrendData[skdTrendData.length - 2]['score'] as double;
      skdTrend = ((previous - latest) / previous * 100); // Positif = membaik
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Status Kesehatan',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.psychology,
                iconColor: _getSKDColor(currentSKD),
                title: 'Skor SKD',
                value: currentSKD.toStringAsFixed(1),
                subtitle: _getSKDCategory(currentSKD),
                trend: skdTrend,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.favorite,
                iconColor: Colors.red,
                title: 'Heart Rate',
                value: '$currentHeartRate',
                subtitle: 'BPM',
                trend: null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.trending_up,
                iconColor: Colors.blue,
                title: 'HRV',
                value: '$currentHRV',
                subtitle: 'ms',
                trend: null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.wb_sunny,
                iconColor: Colors.orange,
                title: 'Stress',
                value: '${currentStress.toInt()}%',
                subtitle: currentStress < 40 ? 'Normal' : 'Tinggi',
                trend: null,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String subtitle,
    double? trend,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              if (trend != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: trend > 0 ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        trend > 0 ? Icons.arrow_downward : Icons.arrow_upward,
                        size: 12,
                        color: trend > 0 ? Colors.green : Colors.red,
                      ),
                      Text(
                        '${trend.abs().toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: trend > 0 ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF9CA3AF),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }

  // ============= 3. TREN SKOR SKD =============
  Widget _buildSKDTrendChart() {
    // Konversi data SKD ke FlSpot untuk chart
    List<FlSpot> skdSpots = [];
    
    if (skdTrendData.isEmpty) {
      // Dummy data jika belum ada
      skdSpots = [
        FlSpot(0, 5.2),
        FlSpot(1, 4.8),
        FlSpot(2, 6.1),
        FlSpot(3, 5.5),
        FlSpot(4, 4.2),
        FlSpot(5, 3.8),
        FlSpot(6, currentSKD),
      ];
    } else {
      // Pastikan ada 7 data points
      final now = DateTime.now();
      for (int i = 0; i < 7; i++) {
        final targetDate = now.subtract(Duration(days: 6 - i));
        
        // Cari data yang match dengan tanggal
        final matchingData = skdTrendData.where((data) {
          final dataDate = DateTime.parse(data['date']);
          return dataDate.year == targetDate.year &&
                 dataDate.month == targetDate.month &&
                 dataDate.day == targetDate.day;
        }).toList();
        
        if (matchingData.isNotEmpty) {
          // Ambil data terakhir di hari itu
          skdSpots.add(FlSpot(i.toDouble(), matchingData.last['score'] as double));
        } else {
          // Interpolasi atau gunakan data terdekat
          if (skdSpots.isNotEmpty) {
            skdSpots.add(FlSpot(i.toDouble(), skdSpots.last.y));
          } else {
            skdSpots.add(FlSpot(i.toDouble(), 5.0));
          }
        }
      }
    }

    // Tentukan status trend
    String trendStatus = 'Stabil';
    Color trendColor = const Color(0xFF3B82F6);
    
    if (skdSpots.length >= 2) {
      final diff = skdSpots.first.y - skdSpots.last.y;
      if (diff > 1) {
        trendStatus = 'Membaik';
        trendColor = const Color(0xFF10B981);
      } else if (diff < -1) {
        trendStatus = 'Perlu Perhatian';
        trendColor = const Color(0xFFF59E0B);
      }
    }

    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tren Skor SKD (7 Hari)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: trendColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  trendStatus,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: trendColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 2,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.withOpacity(0.2),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 2,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF9CA3AF),
                          ),
                        );
                      },
                      reservedSize: 30,
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
                        if (value.toInt() >= 0 && value.toInt() < days.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              days[value.toInt()],
                              style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFF9CA3AF),
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 6,
                minY: 0,
                maxY: 10,
                lineBarsData: [
                  LineChartBarData(
                    spots: skdSpots,
                    isCurved: true,
                    color: const Color(0xFF3B82F6),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFF3B82F6).withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLegendItem('Baik', const Color(0xFF10B981)),
              _buildLegendItem('Normal', const Color(0xFF3B82F6)),
              _buildLegendItem('Perhatian', const Color(0xFFF59E0B)),
              _buildLegendItem('Tinggi', const Color(0xFFEF4444)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  // ============= 4. PROGRESS MEDITASI =============
  Widget _buildMeditationProgressSection() {
    final progress = meditationMinutes / weeklyGoal;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6B9080), Color(0xFF5A7B6A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6B9080).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Progress Meditasi',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Text(
                      '🔥',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$meditationStreak hari',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$meditationMinutes menit',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                'dari $weeklyGoal menit',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 12,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '${(progress * 100).clamp(0, 100).toInt()}% dari target mingguan',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  // ============= 5. REKOMENDASI HARI INI =============
  Widget _buildRecommendationsCard() {
    if (recommendations.isEmpty) {
      recommendations = [
        {'icon': '🧘', 'text': 'Lakukan meditasi 10 menit untuk menjaga ketenangan'},
        {'icon': '📝', 'text': 'Tulis jurnal untuk refleksi diri'},
      ];
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF9333EA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '💡 Rekomendasi Hari Ini',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          ...recommendations.take(2).map((rec) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildRecommendationItem(rec['icon'] ?? '💡', rec['text'] ?? ''),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildRecommendationItem(String emoji, String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============= 6. AKSES CEPAT SECTION =============
  Widget _buildQuickAccessSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Akses Cepat',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 16),
        _buildQuickAccessCard(
          icon: Icons.spa,
          iconColor: const Color(0xFF6B9080),
          title: 'Meditasi Cepat',
          subtitle: 'Relaksasi instan',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const MeditationScreen(),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildQuickAccessCard(
          icon: Icons.history,
          iconColor: const Color(0xFF3B82F6),
          title: 'Riwayat Hasil Tes',
          subtitle: testHistory.isEmpty ? 'Belum ada tes' : '${testHistory.length} riwayat',
          onTap: () {
            _showHistoryBottomSheet();
          },
        ),
        const SizedBox(height: 12),
        _buildQuickAccessCard(
          icon: Icons.book,
          iconColor: const Color(0xFFF59E0B),
          title: 'Jurnal Harian',
          subtitle: 'Refleksi harian',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const JournalScreen(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildQuickAccessCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
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
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Color(0xFF9CA3AF),
            ),
          ],
        ),
      ),
    );
  }

  // ============= HISTORY BOTTOM SHEET =============
  void _showHistoryBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Color(0xFFF5EFD0),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 20),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF9CA3AF),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: const [
                  Icon(
                    Icons.history,
                    color: Color(0xFF1F2937),
                    size: 24,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Riwayat Tes',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: testHistory.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.assignment_outlined,
                            size: 64,
                            color: Color(0xFF9CA3AF),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Belum ada riwayat tes',
                            style: TextStyle(
                              color: Color(0xFF9CA3AF),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: testHistory.length,
                      itemBuilder: (context, index) {
                        final item = testHistory[index];
                        final date = DateTime.parse(item['date']);
                        final dateStr = '${date.day}/${date.month}/${date.year}';
                        final timeStr = '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
                        final historyPercentage = (item['score'] / item['maxScore'] * 100).toInt();
                        final skdScore = item['skdScore'] ?? 0.0;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: _getTestColor(historyPercentage).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      skdScore.toStringAsFixed(1),
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: _getTestColor(historyPercentage),
                                      ),
                                    ),
                                    Text(
                                      'SKD',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: _getTestColor(historyPercentage),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['category'],
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF1F2937),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '$dateStr • $timeStr',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF9CA3AF),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: _getTestColor(historyPercentage).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '$historyPercentage%',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: _getTestColor(historyPercentage),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}