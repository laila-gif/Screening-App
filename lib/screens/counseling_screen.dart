import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/language_service.dart';
// import 'ai_chat_screen.dart';
import 'ai_sensor_screen.dart'; // TAMBAHAN BARU
import 'doctor_list_screen.dart';

class CounselingScreen extends StatefulWidget {
  const CounselingScreen({Key? key}) : super(key: key);

  @override
  State<CounselingScreen> createState() => _CounselingScreenState();
}

class _CounselingScreenState extends State<CounselingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String _effectiveCode(LanguageService ls) {
    final code = ls.currentLanguageCode == 'system'
        ? ls.currentLocale.languageCode
        : ls.currentLanguageCode;
    return code;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageService>(
      builder: (context, ls, child) {
        final code = _effectiveCode(ls);

        // localized strings
        final header = code.startsWith('en')
            ? 'Counseling'
            : code.startsWith('zh')
            ? '咨询'
            : code.startsWith('ar')
            ? 'الاستشارة'
            : 'Konseling';
        final subtitle = code.startsWith('en')
            ? 'Choose the type of counseling you need'
            : code.startsWith('zh')
            ? '选择您需要的咨询类型'
            : code.startsWith('ar')
            ? 'اختر نوع الاستشارة التي تحتاجها'
            : 'Pilih jenis konseling yang Anda butuhkan';

        final aiTitle = code.startsWith('en')
            ? 'AI Sensor Check'
            : code.startsWith('zh')
            ? 'AI 传感器检查'
            : code.startsWith('ar')
            ? 'فحص المستشعر بالذكاء الاصطناعي'
            : 'Pemeriksaan AI dengan Sensor';
        final aiSubtitle = code.startsWith('en')
            ? 'rPPG & Accelerometer'
            : code.startsWith('zh')
            ? 'rPPG & 加速度计'
            : code.startsWith('ar')
            ? 'rPPG & التسارع'
            : 'Teknologi rPPG & Accelerometer';
        final aiDescription = code.startsWith('en')
            ? 'Use camera and sensors for a more accurate mental health check. AI analyzes heart rate, HRV and movement patterns.'
            : code.startsWith('zh')
            ? '使用摄像头和传感器进行更准确的心理健康检测。AI 会分析心率、HRV 和运动模式。'
            : code.startsWith('ar')
            ? 'استخدم الكاميرا والمستشعرات لفحص صحة نفسية أكثر دقة. يقوم الذكاء الاصطناعي بتحليل معدل ضربات القلب وHRV ونمط الحركة.'
            : 'Gunakan kamera dan sensor untuk pemeriksaan kesehatan mental yang lebih akurat. AI akan menganalisis detak jantung, HRV, dan pola gerakan Anda.';
        final aiButton = code.startsWith('en')
            ? 'Start Sensor Check'
            : code.startsWith('zh')
            ? '开始'
            : code.startsWith('ar')
            ? 'ابدأ'
            : 'Mulai Pemeriksaan Sensor';

        final profTitle = code.startsWith('en')
            ? 'Professional Consultation'
            : code.startsWith('zh')
            ? '专业咨询'
            : code.startsWith('ar')
            ? 'الاستشارة المهنية'
            : 'Konsultasi Profesional';
        final profSubtitle = code.startsWith('en')
            ? 'Licensed psychologists & psychiatrists'
            : code.startsWith('zh')
            ? '持证心理学家与精神科医生'
            : code.startsWith('ar')
            ? 'أطباء نفسيون ومعالجون مرخصون'
            : 'Ahli Psikologi dengan Psikiater & Psikolog';
        final profDescription = code.startsWith('en')
            ? 'Get help from licensed professionals for deeper, effective care.'
            : code.startsWith('zh')
            ? '从持证专业人士处获得更深入、有效的帮助。'
            : code.startsWith('ar')
            ? 'احصل على مساعدة من مختصين مرخصين لتلقي رعاية متعمقة وفعالة.'
            : 'Dapatkan bantuan dari para psikolog dan psikiater berlisensi untuk perawatan mendalam dan efektif.';
        final profButton = code.startsWith('en')
            ? 'Find Professionals'
            : code.startsWith('zh')
            ? '查找'
            : code.startsWith('ar')
            ? 'ابحث'
            : 'Cari Profesional Kami';

        final infoTitle = code.startsWith('en')
            ? 'When to Consider Seeking Help?'
            : code.startsWith('zh')
            ? '什么时候应该寻求帮助？'
            : code.startsWith('ar')
            ? 'متى ينبغي التفكير في طلب المساعدة؟'
            : 'Kapan Seharusnya Mempertimbangkan Bantuan?';
        final infoBody = code.startsWith('en')
            ? 'Seeking help is a brave and wise action. If symptoms persist or interfere with daily life, mental health professionals can provide the support you need.'
            : code.startsWith('zh')
            ? '寻求帮助是一种勇敢且明智的行为。如果症状持续或干扰日常生活，专业人员可以提供支持。'
            : code.startsWith('ar')
            ? 'طلب المساعدة فعل شجاع وحكيم. إذا استمرت الأعراض أو أثرت على الحياة اليومية، يمكن للمتخصصين تقديم الدعم الذي تحتاجه.'
            : 'Mencari bantuan adalah tindakan berani dan bijak. Ketika gejala berlanjut atau mengganggu kehidupan sehari-hari, profesional kesehatan mental dapat memberikan dukungan yang Anda butuhkan.';

        final orLabel = code.startsWith('en')
            ? 'OR'
            : code.startsWith('zh')
            ? '或'
            : code.startsWith('ar')
            ? 'أو'
            : 'ATAU';

        // features per language (for AI card)
        final aiFeatures = code.startsWith('en')
            ? [
                ['Camera heart-rate detection', 'HRV & stress analysis'],
                ['Accelerometer sensor', 'Face & emotion detection'],
                ['SKD score (1-10)', 'Personal recommendations'],
              ]
            : code.startsWith('zh')
            ? [
                ['通过摄像头检测心跳', 'HRV 与 压力分析'],
                ['加速度计传感器', '面部与情绪检测'],
                ['SKD 得分 (1-10)', '个性化建议'],
              ]
            : code.startsWith('ar')
            ? [
                ['كشف معدل ضربات القلب عبر الكاميرا', 'تحليل HRV والضغط'],
                ['مستشعر التسارع', 'كشف الوجه والعاطفة'],
                ['نتيجة SKD (1-10)', 'توصيات شخصية'],
              ]
            : [
                [
                  'Deteksi Detak Jantung via Kamera',
                  'Analisis HRV & Stress Level',
                ],
                ['Sensor Accelerometer', 'Face & Emotion Detection'],
                ['Hasil SKD (1-10)', 'Rekomendasi Personal'],
              ];

        return Scaffold(
          backgroundColor: const Color(0xFFF5F0E8),
          body: SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFF2D5F4C), Color(0xFF5A8C73)],
                      ).createShader(bounds),
                      child: Text(
                        header,
                        style: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black.withOpacity(0.6),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // AI sensor card
                    _buildExactCard(
                      context,
                      backgroundColor: const Color(0xFFE8F5E9),
                      iconBackgroundColor: const Color(0xFF4CAF50),
                      icon: Icons.sensors,
                      title: aiTitle,
                      subtitle: aiSubtitle,
                      description: aiDescription,
                      features: aiFeatures,
                      buttonText: aiButton,
                      buttonColor: const Color(0xFF4CAF50),
                      isNew: true,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AISensorScreen(),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Center(
                      child: Text(
                        orLabel,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.black.withOpacity(0.45),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Professional card
                    _buildExactCard(
                      context,
                      backgroundColor: const Color(0xFFD8E3F0),
                      iconBackgroundColor: const Color(0xFF4A6FA5),
                      icon: Icons.local_hospital_rounded,
                      title: profTitle,
                      subtitle: profSubtitle,
                      description: profDescription,
                      features: code.startsWith('en')
                          ? [
                              ['Certified professionals', 'Quality assurance'],
                              ['Private sessions', 'Trusted doctors'],
                              ['Comprehensive care', null],
                            ]
                          : code.startsWith('zh')
                          ? [
                              ['持证专业人士', '质量保证'],
                              ['私人会诊', '可信医生'],
                              ['综合护理', null],
                            ]
                          : code.startsWith('ar')
                          ? [
                              ['مهنيون معتمدون', 'ضمان الجودة'],
                              ['جلسات خاصة', 'أطباء موثوقون'],
                              ['رعاية شاملة', null],
                            ]
                          : [
                              [
                                'Profesional Tersertifikasi',
                                'Memastikan Efisien',
                              ],
                              ['Sesi Konsultasi Privat', 'Dokter & Terpercaya'],
                              ['Perawatan Komprehensif', null],
                            ],
                      buttonText: profButton,
                      buttonColor: const Color(0xFF4A6FA5),
                      isPremium: true,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DoctorListScreen(),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.black.withOpacity(0.08),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.info_outline,
                              color: Colors.grey[600],
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  infoTitle,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                    height: 1.3,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  infoBody,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.black.withOpacity(0.65),
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildExactCard(
    BuildContext context, {
    required Color backgroundColor,
    required Color iconBackgroundColor,
    required IconData icon,
    required String title,
    required String subtitle,
    required String description,
    required List<List<String?>> features,
    required String buttonText,
    required Color buttonColor,
    required VoidCallback onTap,
    bool isPremium = false,
    bool isNew = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: iconBackgroundColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 20, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              title,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                                height: 1.2,
                              ),
                            ),
                          ),
                          if (isPremium) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFD700),
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: const Text(
                                'PRO',
                                style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                          if (isNew) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4CAF50),
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: const Text(
                                'NEW',
                                style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.black.withOpacity(0.6),
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Text(
              description,
              style: TextStyle(
                fontSize: 11,
                color: Colors.black.withOpacity(0.65),
                height: 1.4,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: features.map((featurePair) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 1),
                              child: Icon(
                                Icons.check_circle,
                                size: 12,
                                color: iconBackgroundColor,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                featurePair[0] ?? '',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w500,
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (featurePair.length > 1 && featurePair[1] != null)
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 1),
                                child: Icon(
                                  Icons.check_circle,
                                  size: 12,
                                  color: iconBackgroundColor,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  featurePair[1] ?? '',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w500,
                                    height: 1.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        const Expanded(child: SizedBox()),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.chat_bubble_outline, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      buttonText,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
