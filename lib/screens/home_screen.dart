import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/language_service.dart';
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

  // Map SKD numeric score to translation keys
  String skdKey(double score) {
    if (score <= 3) {
      return 'skd_baik';
    }
    if (score <= 5) {
      return 'skd_normal';
    }
    if (score <= 7) {
      return 'skd_attention';
    }
    return 'skd_high';
  }

  // Localize recommendation text coming from backend (which may be in Indonesian)
  String _localizeRecommendationText(
    Map<String, dynamic> rec,
    Map<String, String> L,
  ) {
    final raw = (rec['text'] ?? '').toString();
    final lower = raw.toLowerCase();

    // Match common patterns from health_data_service defaults
    if (lower.contains('medit') ||
        lower.contains('meditasi') ||
        lower.contains('meditation') ||
        lower.contains('冥想')) {
      return L['rec_meditation'] ?? raw;
    }
    if (lower.contains('jurnal') ||
        lower.contains('journal') ||
        lower.contains('日记') ||
        lower.contains('日志')) {
      return L['rec_journal'] ?? raw;
    }

    // Fallback: if recommendation already seems localized (contains english/zh/ar keywords), return L keys where possible
    return raw;
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
          child: CircularProgressIndicator(color: Color(0xFF6B9080)),
        ),
      );
    }

    final ls = Provider.of<LanguageService>(context, listen: false);
    String code = ls.currentLanguageCode == 'system'
        ? ls.currentLocale.languageCode
        : ls.currentLanguageCode;

    // localized strings
    String localizedGreeting() {
      final hour = DateTime.now().hour;
      if (code.startsWith('en')) {
        if (hour >= 5 && hour < 11) return 'Good morning';
        if (hour >= 11 && hour < 15) return 'Good afternoon';
        if (hour >= 15 && hour < 18) return 'Good evening';
        return 'Good night';
      }
      if (code.startsWith('zh')) {
        if (hour >= 5 && hour < 11) return '早上好';
        if (hour >= 11 && hour < 15) return '下午好';
        if (hour >= 15 && hour < 18) return '晚上好';
        return '晚安';
      }
      if (code.startsWith('ar')) {
        if (hour >= 5 && hour < 11) return 'صباح الخير';
        if (hour >= 11 && hour < 15) return 'مساء الخير';
        if (hour >= 15 && hour < 18) return 'مساء الخير';
        return 'تصبح على خير';
      }
      // default Indonesian
      return _getGreeting();
    }

    final Map<String, String> L = {
      'howAreYou': code.startsWith('en')
          ? 'How are you today?'
          : code.startsWith('zh')
          ? '今天你怎么样？'
          : code.startsWith('ar')
          ? 'كيف حالك اليوم؟'
          : 'Bagaimana kabar Anda hari ini?',
      'moodQuestion': code.startsWith('en')
          ? 'How are you feeling today?'
          : code.startsWith('zh')
          ? '你今天感觉如何？'
          : code.startsWith('ar')
          ? 'كيف تشعر اليوم؟'
          : 'Bagaimana perasaanmu hari ini?',
      'mood_happy': code.startsWith('en')
          ? 'Happy'
          : code.startsWith('zh')
          ? '开心'
          : code.startsWith('ar')
          ? 'سعيد'
          : 'Senang',
      'mood_sad': code.startsWith('en')
          ? 'Sad'
          : code.startsWith('zh')
          ? '难过'
          : code.startsWith('ar')
          ? 'حزين'
          : 'Sedih',
      'mood_anxious': code.startsWith('en')
          ? 'Anxious'
          : code.startsWith('zh')
          ? '焦虑'
          : code.startsWith('ar')
          ? 'قلق'
          : 'Cemas',
      'mood_angry': code.startsWith('en')
          ? 'Angry'
          : code.startsWith('zh')
          ? '生气'
          : code.startsWith('ar')
          ? 'غاضب'
          : 'Marah',
      'mental_check_title': code.startsWith('en')
          ? 'Check Your Mental State'
          : code.startsWith('zh')
          ? '检查你的心理状态'
          : code.startsWith('ar')
          ? 'تحقق من حالتك العقلية'
          : 'Cek Kondisi Mentalmu',
      'mental_check_sub': code.startsWith('en')
          ? 'Take a short test to better understand yourself.'
          : code.startsWith('zh')
          ? '进行简短测试以更好地了解自己。'
          : code.startsWith('ar')
          ? 'قم بإجراء اختبار قصير لفهم نفسك بشكل أفضل.'
          : 'Ikuti tes singkat untuk lebih memahami dirimu.',
      'start_test': code.startsWith('en')
          ? 'Start Test'
          : code.startsWith('zh')
          ? '开始测试'
          : code.startsWith('ar')
          ? 'ابدأ الاختبار'
          : 'Mulai Tes',
      'health_status': code.startsWith('en')
          ? 'Health Status'
          : code.startsWith('zh')
          ? '健康状态'
          : code.startsWith('ar')
          ? 'حالة الصحة'
          : 'Status Kesehatan',
      'trend_title': code.startsWith('en')
          ? 'SKD Score Trend (7 Days)'
          : code.startsWith('zh')
          ? 'SKD 评分趋势（7天）'
          : code.startsWith('ar')
          ? 'اتجاه درجة SKD (7 أيام)'
          : 'Tren Skor SKD (7 Hari)',
      'legend_good': code.startsWith('en')
          ? 'Good'
          : code.startsWith('zh')
          ? '良好'
          : code.startsWith('ar')
          ? 'جيد'
          : 'Baik',
      'legend_normal': code.startsWith('en')
          ? 'Normal'
          : code.startsWith('zh')
          ? '正常'
          : code.startsWith('ar')
          ? 'طبيعي'
          : 'Normal',
      'legend_attention': code.startsWith('en')
          ? 'Attention'
          : code.startsWith('zh')
          ? '注意'
          : code.startsWith('ar')
          ? 'انتباه'
          : 'Perhatian',
      'legend_high': code.startsWith('en')
          ? 'High'
          : code.startsWith('zh')
          ? '高'
          : code.startsWith('ar')
          ? 'مرتفع'
          : 'Tinggi',
      'meditation_progress': code.startsWith('en')
          ? 'Meditation Progress'
          : code.startsWith('zh')
          ? '冥想进展'
          : code.startsWith('ar')
          ? 'تقدم التأمل'
          : 'Progress Meditasi',
      'days_label': code.startsWith('en')
          ? 'days'
          : code.startsWith('zh')
          ? '天'
          : code.startsWith('ar')
          ? 'أيام'
          : 'hari',
      'of_minutes': code.startsWith('en')
          ? 'of'
          : code.startsWith('zh')
          ? '的'
          : code.startsWith('ar')
          ? 'من'
          : 'dari',
      'recommendations': code.startsWith('en')
          ? 'Recommendations Today'
          : code.startsWith('zh')
          ? '今日推荐'
          : code.startsWith('ar')
          ? 'توصيات اليوم'
          : 'Rekomendasi Hari Ini',
      'rec_meditation': code.startsWith('en')
          ? 'Do a 10-minute meditation to stay calm'
          : code.startsWith('zh')
          ? '进行10分钟冥想以保持平静'
          : code.startsWith('ar')
          ? 'قم بالتأمل لمدة 10 دقائق للحفاظ على الهدوء'
          : 'Lakukan meditasi 10 menit untuk menjaga ketenangan',
      'rec_journal': code.startsWith('en')
          ? 'Write a journal for self-reflection'
          : code.startsWith('zh')
          ? '写日记以自我反思'
          : code.startsWith('ar')
          ? 'اكتب مذكّرة للتأمل الذاتي'
          : 'Tulis jurnal untuk refleksi diri',
      'quick_access': code.startsWith('en')
          ? 'Quick Access'
          : code.startsWith('zh')
          ? '快捷访问'
          : code.startsWith('ar')
          ? 'وصول سريع'
          : 'Akses Cepat',
      'quick_meditation': code.startsWith('en')
          ? 'Quick Meditation'
          : code.startsWith('zh')
          ? '快速冥想'
          : code.startsWith('ar')
          ? 'تأمل سريع'
          : 'Meditasi Cepat',
      'quick_history': code.startsWith('en')
          ? 'Test History'
          : code.startsWith('zh')
          ? '测试历史'
          : code.startsWith('ar')
          ? 'تاريخ الاختبار'
          : 'Riwayat Hasil Tes',
      'quick_journal': code.startsWith('en')
          ? 'Daily Journal'
          : code.startsWith('zh')
          ? '每日日志'
          : code.startsWith('ar')
          ? 'اليوميات اليومية'
          : 'Jurnal Harian',
      'no_history': code.startsWith('en')
          ? 'No test history'
          : code.startsWith('zh')
          ? '没有测试历史'
          : code.startsWith('ar')
          ? 'لا يوجد سجل اختبار'
          : 'Belum ada riwayat tes',
      'history_title': code.startsWith('en')
          ? 'Test History'
          : code.startsWith('zh')
          ? '测试历史'
          : code.startsWith('ar')
          ? 'سجل الاختبار'
          : 'Riwayat Tes',
      // Additional keys for localized labels used across HomeScreen
      'skd_score': code.startsWith('en')
          ? 'SKD Score'
          : code.startsWith('zh')
          ? 'SKD 分数'
          : code.startsWith('ar')
          ? 'درجة SKD'
          : 'Skor SKD',
      'bpm': code.startsWith('en')
          ? 'BPM'
          : code.startsWith('zh')
          ? '每分钟心跳'
          : code.startsWith('ar')
          ? 'نبضة/د'
          : 'BPM',
      'ms': code.startsWith('en')
          ? 'ms'
          : code.startsWith('zh')
          ? '毫秒'
          : code.startsWith('ar')
          ? 'مللي ث'
          : 'ms',
      'heart_rate': code.startsWith('en')
          ? 'Heart Rate'
          : code.startsWith('zh')
          ? '心率'
          : code.startsWith('ar')
          ? 'معدل ضربات القلب'
          : 'Detak Jantung',
      'hrv': code.startsWith('en')
          ? 'HRV'
          : code.startsWith('zh')
          ? 'HRV'
          : code.startsWith('ar')
          ? 'تقلب معدل ضربات القلب'
          : 'HRV',
      'stress': code.startsWith('en')
          ? 'Stress'
          : code.startsWith('zh')
          ? '压力'
          : code.startsWith('ar')
          ? 'الإجهاد'
          : 'Stress',
      'normal': code.startsWith('en')
          ? 'Normal'
          : code.startsWith('zh')
          ? '正常'
          : code.startsWith('ar')
          ? 'طبيعي'
          : 'Normal',
      'high': code.startsWith('en')
          ? 'High'
          : code.startsWith('zh')
          ? '高'
          : code.startsWith('ar')
          ? 'مرتفع'
          : 'Tinggi',
      'trend_stable': code.startsWith('en')
          ? 'Stable'
          : code.startsWith('zh')
          ? '稳定'
          : code.startsWith('ar')
          ? 'مستقر'
          : 'Stabil',
      'trend_improving': code.startsWith('en')
          ? 'Improving'
          : code.startsWith('zh')
          ? '改善中'
          : code.startsWith('ar')
          ? 'يتحسن'
          : 'Membaik',
      'trend_attention': code.startsWith('en')
          ? 'Needs Attention'
          : code.startsWith('zh')
          ? '需注意'
          : code.startsWith('ar')
          ? 'يحتاج انتباه'
          : 'Perlu Perhatian',
      // SKD labels
      'skd_baik': code.startsWith('en')
          ? 'Good'
          : code.startsWith('zh')
          ? '良好'
          : code.startsWith('ar')
          ? 'جيد'
          : 'Baik',
      'skd_normal': code.startsWith('en')
          ? 'Normal'
          : code.startsWith('zh')
          ? '正常'
          : code.startsWith('ar')
          ? 'طبيعي'
          : 'Normal',
      'skd_attention': code.startsWith('en')
          ? 'Needs Attention'
          : code.startsWith('zh')
          ? '需注意'
          : code.startsWith('ar')
          ? 'يحتاج انتباه'
          : 'Perlu Perhatian',
      'skd_high': code.startsWith('en')
          ? 'High'
          : code.startsWith('zh')
          ? '高'
          : code.startsWith('ar')
          ? 'مرتفع'
          : 'Tinggi',
      'minutes': code.startsWith('en')
          ? 'minutes'
          : code.startsWith('zh')
          ? '分钟'
          : code.startsWith('ar')
          ? 'دقائق'
          : 'menit',
      'weekly_target': code.startsWith('en')
          ? 'weekly target'
          : code.startsWith('zh')
          ? '每周目标'
          : code.startsWith('ar')
          ? 'الهدف الأسبوعي'
          : 'target mingguan',
      'quick_meditation_sub': code.startsWith('en')
          ? 'Instant relaxation'
          : code.startsWith('zh')
          ? '即时放松'
          : code.startsWith('ar')
          ? 'استرخاء فوري'
          : 'Relaksasi instan',
      'quick_journal_sub': code.startsWith('en')
          ? 'Daily reflection'
          : code.startsWith('zh')
          ? '每日反思'
          : code.startsWith('ar')
          ? 'تأمل يومي'
          : 'Refleksi harian',
      'history_items': code.startsWith('en')
          ? 'records'
          : code.startsWith('zh')
          ? '条'
          : code.startsWith('ar')
          ? 'سجلات'
          : 'riwayat',
    };

    // no local helpers here; use class-level `skdKey` instead

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
                    localizedGreeting(),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    L['howAreYou']!,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 24),

                  // 1. CEK KONDISI MENTALMU
                  _buildMoodCheckSection(L),
                  const SizedBox(height: 24),

                  // 2. STATUS KESEHATAN
                  _buildQuickStatsSection(L),
                  const SizedBox(height: 24),

                  // 3. TREN SKOR SKD
                  _buildSKDTrendChart(L),
                  const SizedBox(height: 24),

                  // 4. PROGRESS MEDITASI
                  _buildMeditationProgressSection(L),
                  const SizedBox(height: 24),

                  // 5. REKOMENDASI HARI INI
                  _buildRecommendationsCard(L),
                  const SizedBox(height: 24),

                  // 6. AKSES CEPAT
                  _buildQuickAccessSection(L),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============= 1. CEK KONDISI MENTALMU SECTION =============
  Widget _buildMoodCheckSection(Map<String, String> L) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          L['moodQuestion']!,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildMoodButton('😊', L['mood_happy']!, 'senang'),
            _buildMoodButton('😔', L['mood_sad']!, 'sedih'),
            _buildMoodButton('😰', L['mood_anxious']!, 'cemas'),
            _buildMoodButton('😡', L['mood_angry']!, 'marah'),
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
              Text(
                L['mental_check_title']!,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                L['mental_check_sub']!,
                style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      L['start_test']!,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward, size: 18),
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
                color: isSelected
                    ? const Color(0xFF6B9080)
                    : Colors.transparent,
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
              child: Text(emoji, style: const TextStyle(fontSize: 32)),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: isSelected
                  ? const Color(0xFF1F2937)
                  : const Color(0xFF9CA3AF),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  // ============= 2. STATUS KESEHATAN SECTION =============
  Widget _buildQuickStatsSection(Map<String, String> L) {
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
        Text(
          L['health_status']!,
          style: const TextStyle(
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
                title: L['skd_score']!,
                value: currentSKD.toStringAsFixed(1),
                subtitle: L[skdKey(currentSKD)] ?? _getSKDCategory(currentSKD),
                trend: skdTrend,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.favorite,
                iconColor: Colors.red,
                title: L['heart_rate']!,
                value: '$currentHeartRate',
                subtitle: L['bpm']!,
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
                title: L['hrv']!,
                value: '$currentHRV',
                subtitle: L['ms']!,
                trend: null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.wb_sunny,
                iconColor: Colors.orange,
                title: L['stress']!,
                value: '${currentStress.toInt()}%',
                subtitle: currentStress < 40 ? L['normal']! : L['high']!,
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: trend > 0
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
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
            style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
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
            style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
          ),
        ],
      ),
    );
  }

  // ============= 3. TREN SKOR SKD =============
  Widget _buildSKDTrendChart(Map<String, String> L) {
    final ls = Provider.of<LanguageService>(context, listen: false);
    final code = ls.currentLanguageCode == 'system'
        ? ls.currentLocale.languageCode
        : ls.currentLanguageCode;
    List<String> days;
    if (code.startsWith('en')) {
      days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    } else if (code.startsWith('zh')) {
      days = ['一', '二', '三', '四', '五', '六', '日'];
    } else if (code.startsWith('ar')) {
      days = ['اث', 'ثل', 'أر', 'خ', 'جم', 'سب', 'أحد'];
    } else {
      days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    }
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
          skdSpots.add(
            FlSpot(i.toDouble(), matchingData.last['score'] as double),
          );
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
    String trendStatusKey = 'trend_stable';
    Color trendColor = const Color(0xFF3B82F6);

    if (skdSpots.length >= 2) {
      final diff = skdSpots.first.y - skdSpots.last.y;
      if (diff > 1) {
        trendStatusKey = 'trend_improving';
        trendColor = const Color(0xFF10B981);
      } else if (diff < -1) {
        trendStatusKey = 'trend_attention';
        trendColor = const Color(0xFFF59E0B);
      }
    }
    final trendStatus = L[trendStatusKey] ?? L['trend_stable']!;

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
              Text(
                L['trend_title']!,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
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
              _buildLegendItem(L['legend_good']!, const Color(0xFF10B981)),
              _buildLegendItem(L['legend_normal']!, const Color(0xFF3B82F6)),
              _buildLegendItem(L['legend_attention']!, const Color(0xFFF59E0B)),
              _buildLegendItem(L['legend_high']!, const Color(0xFFEF4444)),
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
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280)),
        ),
      ],
    );
  }

  // ============= 4. PROGRESS MEDITASI =============
  Widget _buildMeditationProgressSection(Map<String, String> L) {
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
              Text(
                L['meditation_progress']!,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Text('🔥', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 4),
                    Text(
                      '$meditationStreak ${L['days_label']}',
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
                '$meditationMinutes ${L['minutes']!}',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                '${L['of_minutes']} $weeklyGoal ${L['minutes']!}',
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
            '${(progress * 100).clamp(0, 100).toInt()}% ${L['of_minutes']} ${L['weekly_target']}',
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
  Widget _buildRecommendationsCard(Map<String, String> L) {
    if (recommendations.isEmpty) {
      recommendations = [
        {'icon': '🧘', 'text': L['rec_meditation']!},
        {'icon': '📝', 'text': L['rec_journal']!},
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
          Text(
            '💡 ${L['recommendations']!}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          ...recommendations.take(2).map((rec) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildRecommendationItem(
                rec['icon'] ?? '💡',
                _localizeRecommendationText(rec, L),
              ),
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
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // ============= 6. AKSES CEPAT SECTION =============
  Widget _buildQuickAccessSection(Map<String, String> L) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          L['quick_access']!,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 16),
        _buildQuickAccessCard(
          icon: Icons.spa,
          iconColor: const Color(0xFF6B9080),
          title: L['quick_meditation']!,
          subtitle: L['quick_meditation_sub']!,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MeditationScreen()),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildQuickAccessCard(
          icon: Icons.history,
          iconColor: const Color(0xFF3B82F6),
          title: L['quick_history']!,
          subtitle: testHistory.isEmpty
              ? L['no_history']!
              : '${testHistory.length} ${L['history_items']!}',
          onTap: () {
            _showHistoryBottomSheet(L);
          },
        ),
        const SizedBox(height: 12),
        _buildQuickAccessCard(
          icon: Icons.book,
          iconColor: const Color(0xFFF59E0B),
          title: L['quick_journal']!,
          subtitle: L['quick_journal_sub']!,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const JournalScreen()),
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
              child: Icon(icon, color: iconColor, size: 24),
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
  void _showHistoryBottomSheet(Map<String, String> L) {
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
                children: [
                  const Icon(Icons.history, color: Color(0xFF1F2937), size: 24),
                  const SizedBox(width: 8),
                  Text(
                    L['history_title']!,
                    style: const TextStyle(
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
                        children: [
                          const Icon(
                            Icons.assignment_outlined,
                            size: 64,
                            color: Color(0xFF9CA3AF),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            L['no_history']!,
                            style: const TextStyle(
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
                        final dateStr =
                            '${date.day}/${date.month}/${date.year}';
                        final timeStr =
                            '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
                        final historyPercentage =
                            (item['score'] / item['maxScore'] * 100).toInt();
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
                                  color: _getTestColor(
                                    historyPercentage,
                                  ).withOpacity(0.1),
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
                                  color: _getTestColor(
                                    historyPercentage,
                                  ).withOpacity(0.1),
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
