import 'package:flutter/material.dart';
// import 'ai_chat_screen.dart';
import 'ai_sensor_screen.dart'; // TAMBAHAN BARU
import 'doctor_list_screen.dart';

class CounselingScreen extends StatefulWidget {
  const CounselingScreen({Key? key}) : super(key: key);

  @override
  State<CounselingScreen> createState() => _CounselingScreenState();
}

class _CounselingScreenState extends State<CounselingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                const SizedBox(height: 8),
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFF2D5F4C), Color(0xFF5A8C73)],
                  ).createShader(bounds),
                  child: const Text(
                    'Konseling',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Pilih jenis konseling yang Anda butuhkan',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black.withOpacity(0.6),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 32),

                // ======= TAMBAHAN BARU: AI SENSOR CARD =======
                _buildExactCard(
                  context,
                  backgroundColor: const Color(0xFFE8F5E9), // Hijau muda
                  iconBackgroundColor: const Color(0xFF4CAF50),
                  icon: Icons.sensors,
                  title: 'Pemeriksaan AI dengan Sensor',
                  subtitle: 'Teknologi rPPG & Accelerometer',
                  description: 'Gunakan kamera dan sensor untuk pemeriksaan kesehatan mental yang lebih akurat. AI akan menganalisis detak jantung, HRV, dan pola gerakan Anda.',
                  features: [
                    ['Deteksi Detak Jantung via Kamera', 'Analisis HRV & Stress Level'],
                    ['Sensor Accelerometer', 'Face & Emotion Detection'],
                    ['Hasil SKD (1-10)', 'Rekomendasi Personal'],
                  ],
                  buttonText: 'Mulai Pemeriksaan Sensor',
                  buttonColor: const Color(0xFF4CAF50),
                  isNew: true, // Badge "NEW"
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AISensorScreen(),
                      ),
                    );
                  },
                ),




                const SizedBox(height: 20),

                // Divider
                Center(
                  child: Text(
                    'ATAU',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.black.withOpacity(0.4),
                      letterSpacing: 1.2,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Professional Consultation Card
                _buildExactCard(
                  context,
                  backgroundColor: const Color(0xFFD8E3F0),
                  iconBackgroundColor: const Color(0xFF4A6FA5),
                  icon: Icons.local_hospital_rounded,
                  title: 'Konsultasi Profesional',
                  subtitle: 'Ahli Psikologi dengan Psikiater & Psikolog',
                  description: 'Dapatkan bantuan dari para psikolog dan psikiater berlisensi untuk perawatan mendalam dan efektif.',
                  features: [
                    ['Profesional Tersertifikasi', 'Memastikan Efisien'],
                    ['Sesi Konsultasi Privat', 'Dokter & Terpercaya'],
                    ['Perawatan Komprehensif', null],
                    ['Data Medis Aman & Terenkripsi', null],
                  ],
                  buttonText: 'Cari Profesional Kami',
                  buttonColor: const Color(0xFF4A6FA5),
                  isPremium: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DoctorListScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),

                // Info Banner
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
                            const Text(
                              'Kapan Seharusnya Mempertimbangkan Bantuan?',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Mencari bantuan adalah tindakan berani dan bijak. Ketika gejala berlanjut atau mengganggu kehidupan sehari-hari, profesional kesehatan mental dapat memberikan dukungan yang Anda butuhkan. Jangan ragu untuk meminta bantuan, kesehatan mental Anda penting.',
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
    bool isNew = false, // TAMBAHAN: Parameter untuk badge NEW
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
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: iconBackgroundColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                // Title & Subtitle
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
                          // TAMBAHAN: Badge PRO atau NEW
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
                      const SizedBox(height: 2),
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

          // Description
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

          // Features (2 columns layout like the image)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: features.map((featurePair) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      // Left feature
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
                      // Right feature (if exists)
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

          // Button
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