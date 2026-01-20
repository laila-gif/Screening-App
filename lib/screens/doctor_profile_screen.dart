import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/doctor_model.dart';
import '../services/language_service.dart';
import 'doctor_chat_screen.dart';

class DoctorProfileScreen extends StatelessWidget {
  final Doctor doctor;

  const DoctorProfileScreen({Key? key, required this.doctor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageService>(
      builder: (context, ls, child) {
        final code = ls.currentLanguageCode == 'system'
            ? ls.currentLocale.languageCode
            : ls.currentLanguageCode;

        final ratingLabel = code.startsWith('en')
            ? 'Rating'
            : code.startsWith('zh')
            ? '评分'
            : code.startsWith('ar')
            ? 'التقييم'
            : 'Rating';

        final yearsLabel = code.startsWith('en')
            ? 'Years'
            : code.startsWith('zh')
            ? '年'
            : code.startsWith('ar')
            ? 'سنوات'
            : 'Tahun';

        final patientsLabel = code.startsWith('en')
            ? 'Patients'
            : code.startsWith('zh')
            ? '患者'
            : code.startsWith('ar')
            ? 'المرضى'
            : 'Pasien';

        final statusTitle = code.startsWith('en')
            ? 'Status'
            : code.startsWith('zh')
            ? '状态'
            : code.startsWith('ar')
            ? 'الحالة'
            : 'Status';

        final availableText = code.startsWith('en')
            ? 'Available for consultation'
            : code.startsWith('zh')
            ? '可供咨询'
            : code.startsWith('ar')
            ? 'متاح للاستشارة'
            : 'Tersedia untuk konsultasi';

        final unavailableText = code.startsWith('en')
            ? 'Currently unavailable'
            : code.startsWith('zh')
            ? '当前不可用'
            : code.startsWith('ar')
            ? 'غير متوفر حالياً'
            : 'Sedang tidak tersedia';

        final aboutTitle = code.startsWith('en')
            ? 'About'
            : code.startsWith('zh')
            ? '关于'
            : code.startsWith('ar')
            ? 'حول'
            : 'Tentang';

        final educationTitle = code.startsWith('en')
            ? 'Education'
            : code.startsWith('zh')
            ? '教育'
            : code.startsWith('ar')
            ? 'التعليم'
            : 'Pendidikan';

        final skillsTitle = code.startsWith('en')
            ? 'Skills'
            : code.startsWith('zh')
            ? '技能'
            : code.startsWith('ar')
            ? 'المهارات'
            : 'Keahlian';

        final workingHoursTitle = code.startsWith('en')
            ? 'Working Hours'
            : code.startsWith('zh')
            ? '工作时间'
            : code.startsWith('ar')
            ? 'ساعات العمل'
            : 'Jam Kerja';

        final feeTitle = code.startsWith('en')
            ? 'Consultation Fee'
            : code.startsWith('zh')
            ? '咨询费用'
            : code.startsWith('ar')
            ? 'رسوم الاستشارة'
            : 'Biaya Konsultasi';

        final perSessionLabel = code.startsWith('en')
            ? 'Per Session (60 mins)'
            : code.startsWith('zh')
            ? '每次（60分钟）'
            : code.startsWith('ar')
            ? 'لكل جلسة (60 دقيقة)'
            : 'Per Sesi (60 menit)';

        final startConsultLabel = code.startsWith('en')
            ? 'Start Consultation'
            : code.startsWith('zh')
            ? '开始咨询'
            : code.startsWith('ar')
            ? 'ابدأ الاستشارة'
            : 'Mulai Konsultasi';

        return Scaffold(
          backgroundColor: const Color(0xFFF5EFD0),
          body: CustomScrollView(
            slivers: [
              // App Bar with image
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                backgroundColor: const Color(0xFF6B9080),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF6B9080), Color(0xFF4A6FA5)],
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.network(
                              doctor.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.white,
                                  child: const Icon(
                                    Icons.person,
                                    size: 60,
                                    color: Color(0xFF6B9080),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          doctor.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          doctor.specialization,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status & Rating Card
                      Container(
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
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildInfoColumn(
                              Icons.star,
                              doctor.rating.toString(),
                              ratingLabel,
                              Colors.amber,
                            ),
                            _buildDivider(),
                            _buildInfoColumn(
                              Icons.work_outline,
                              '${doctor.experience}',
                              yearsLabel,
                              const Color(0xFF6B9080),
                            ),
                            _buildDivider(),
                            _buildInfoColumn(
                              Icons.people_outline,
                              '${doctor.totalPatients}+',
                              patientsLabel,
                              const Color(0xFF4A6FA5),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Status Badge
                      _buildSectionTitle(statusTitle),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: doctor.isAvailable
                              ? const Color(0xFFE8F5E9)
                              : const Color(0xFFFFEBEE),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: doctor.isAvailable
                                    ? const Color(0xFF2E7D32)
                                    : const Color(0xFFC62828),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                doctor.isAvailable
                                    ? availableText
                                    : unavailableText,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: doctor.isAvailable
                                      ? const Color(0xFF2E7D32)
                                      : const Color(0xFFC62828),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // About
                      _buildSectionTitle(aboutTitle),
                      const SizedBox(height: 12),
                      _buildCard(
                        child: Text(
                          doctor.description,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                            height: 1.6,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Education
                      _buildSectionTitle(educationTitle),
                      const SizedBox(height: 12),
                      _buildCard(
                        child: Row(
                          children: [
                            const Icon(
                              Icons.school,
                              color: Color(0xFF6B9080),
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                doctor.education,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Skills
                      _buildSectionTitle(skillsTitle),
                      const SizedBox(height: 12),
                      _buildCard(
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: doctor.expertise.map((expertise) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF6B9080).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(
                                    0xFF6B9080,
                                  ).withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                expertise,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF6B9080),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Working Hours
                      _buildSectionTitle(workingHoursTitle),
                      const SizedBox(height: 12),
                      _buildCard(
                        child: Row(
                          children: [
                            const Icon(
                              Icons.access_time,
                              color: Color(0xFF6B9080),
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                doctor.workingHours,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Fee
                      _buildSectionTitle(feeTitle),
                      const SizedBox(height: 12),
                      _buildCard(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.monetization_on,
                                  color: Color(0xFF6B9080),
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  perSessionLabel,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              NumberFormat.currency(
                                locale: 'id_ID',
                                symbol: 'Rp ',
                                decimalDigits: 0,
                              ).format(doctor.consultationPrice),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF6B9080),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Floating Action Button
          floatingActionButton: doctor.isAvailable
              ? Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: FloatingActionButton.extended(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              DoctorChatScreen(doctor: doctor),
                        ),
                      );
                    },
                    backgroundColor: const Color(0xFF6B9080),
                    icon: const Icon(Icons.chat_bubble_outline),
                    label: Text(
                      startConsultLabel,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
              : null,
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
        );
      },
    );
  }

  Widget _buildInfoColumn(
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(width: 1, height: 50, color: Colors.black12);
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
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
      child: child,
    );
  }
}
