import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import '../services/language_service.dart';
import '../services/health_data_service.dart';

class TestResultScreen extends StatefulWidget {
  final int score;
  final int maxScore;

  const TestResultScreen({
    Key? key,
    required this.score,
    required this.maxScore,
  }) : super(key: key);

  @override
  State<TestResultScreen> createState() => _TestResultScreenState();
}

class _TestResultScreenState extends State<TestResultScreen>
    with SingleTickerProviderStateMixin {
  final HealthDataService _healthService = HealthDataService();

  bool _localeInitialized = false;
  bool _isSaving = true;
  double skdScore = 0;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _initializeLocale();
    _saveResult();
  }

  void _initAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _animationController.forward();
  }

  Future<void> _initializeLocale() async {
    if (!_localeInitialized) {
      await initializeDateFormatting('id_ID', null);
      _localeInitialized = true;
    }
  }

  Future<void> _saveResult() async {
    setState(() {
      _isSaving = true;
    });

    final percentage = (widget.score / widget.maxScore * 100).toInt();
    String category = _getCategory();

    await _healthService.saveTestResult(
      score: widget.score,
      maxScore: widget.maxScore,
      category: category,
    );

    final currentSKD = await _healthService.getCurrentSKD();

    setState(() {
      skdScore = currentSKD;
      _isSaving = false;
    });
  }

  String _getCategory() {
    final percentage = (widget.score / widget.maxScore) * 100;

    if (percentage < 25) {
      return 'Sangat Baik';
    } else if (percentage < 45) {
      return 'Baik';
    } else if (percentage < 65) {
      return 'Perlu Perhatian';
    } else {
      return 'Perlu Bantuan Profesional';
    }
  }

  Color _getCategoryColor() {
    final percentage = (widget.score / widget.maxScore) * 100;

    if (percentage < 25) {
      return const Color(0xFF10B981);
    } else if (percentage < 45) {
      return const Color(0xFF3B82F6);
    } else if (percentage < 65) {
      return const Color(0xFFF59E0B);
    } else {
      return const Color(0xFFEF4444);
    }
  }

  String _getSKDCategory(double score) {
    if (score <= 3) return 'Baik';
    if (score <= 5) return 'Normal';
    if (score <= 7) return 'Perlu Perhatian';
    return 'Tinggi';
  }

  Color _getSKDColor(double score) {
    if (score <= 3) return const Color(0xFF10B981);
    if (score <= 5) return const Color(0xFF3B82F6);
    if (score <= 7) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  String _getAdvice() {
    final percentage = (widget.score / widget.maxScore) * 100;

    if (percentage < 25) {
      return 'Kondisi mental Anda sangat baik! Terus pertahankan pola hidup sehat, olahraga teratur, dan jaga keseimbangan hidup Anda.';
    } else if (percentage < 45) {
      return 'Kondisi mental Anda cukup baik. Lakukan meditasi rutin, jaga pola tidur, dan luangkan waktu untuk diri sendiri.';
    } else if (percentage < 65) {
      return 'Anda mungkin mengalami stres atau tekanan. Pertimbangkan untuk berbicara dengan orang terdekat, lakukan aktivitas yang menenangkan, dan jangan ragu mencari bantuan profesional jika diperlukan.';
    } else {
      return 'Hasil tes menunjukkan Anda mungkin memerlukan bantuan profesional. Sangat disarankan untuk berkonsultasi dengan psikolog atau psikiater untuk mendapatkan penanganan yang tepat.';
    }
  }

  IconData _getCategoryIcon() {
    final percentage = (widget.score / widget.maxScore) * 100;

    if (percentage < 25) {
      return Icons.sentiment_very_satisfied;
    } else if (percentage < 45) {
      return Icons.sentiment_satisfied;
    } else if (percentage < 65) {
      return Icons.sentiment_neutral;
    } else {
      return Icons.sentiment_very_dissatisfied;
    }
  }

  // PDF Color helpers
  PdfColor _getCategoryColorPDF() {
    final percentage = (widget.score / widget.maxScore) * 100;
    if (percentage < 25) return PdfColor.fromHex('#10B981');
    if (percentage < 45) return PdfColor.fromHex('#3B82F6');
    if (percentage < 65) return PdfColor.fromHex('#F59E0B');
    return PdfColor.fromHex('#EF4444');
  }

  PdfColor _getSKDColorPDF(double score) {
    if (score <= 3) return PdfColor.fromHex('#10B981');
    if (score <= 5) return PdfColor.fromHex('#3B82F6');
    if (score <= 7) return PdfColor.fromHex('#F59E0B');
    return PdfColor.fromHex('#EF4444');
  }

  Future<void> _generateAndSharePDF() async {
    try {
      final languageService = Provider.of<LanguageService>(
        context,
        listen: false,
      );
      final L = _L(languageService);

      await _initializeLocaleForLanguage(languageService);

      final percentage = (widget.score / widget.maxScore * 100).toInt();
      final categoryKey = _getCategoryKey();
      final category = L[categoryKey] ?? _getCategory();
      final advice = _getAdviceForLanguage(languageService);
      final dateFormat = DateFormat(
        'dd MMMM yyyy, HH:mm',
        _localeForLanguageCode(languageService),
      );
      final formattedDate = dateFormat.format(DateTime.now());

      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Center(
                  child: pw.Column(
                    children: [
                      pw.Text(
                        L['pdf_title']!,
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.grey800,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        L['app_name']!,
                        style: pw.TextStyle(
                          fontSize: 16,
                          color: PdfColors.grey600,
                        ),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 32),

                // Tanggal
                pw.Text(
                  '${L['date_label']!}: $formattedDate',
                  style: pw.TextStyle(fontSize: 11, color: PdfColors.grey600),
                ),
                pw.SizedBox(height: 24),

                // HASIL TES BOX
                pw.Container(
                  padding: const pw.EdgeInsets.all(28),
                  decoration: pw.BoxDecoration(
                    color: _getCategoryColorPDF().shade(0.05),
                    border: pw.Border.all(
                      color: _getCategoryColorPDF(),
                      width: 2,
                    ),
                    borderRadius: pw.BorderRadius.circular(12),
                  ),
                  child: pw.Column(
                    children: [
                      pw.Text(
                        category,
                        style: pw.TextStyle(
                          fontSize: 26,
                          fontWeight: pw.FontWeight.bold,
                          color: _getCategoryColorPDF(),
                        ),
                      ),
                      pw.SizedBox(height: 16),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.center,
                        children: [
                          pw.Column(
                            children: [
                              pw.Text(
                                L['score_label']!,
                                style: pw.TextStyle(
                                  fontSize: 11,
                                  color: PdfColors.grey600,
                                ),
                              ),
                              pw.SizedBox(height: 4),
                              pw.Text(
                                '${widget.score} / ${widget.maxScore}',
                                style: pw.TextStyle(
                                  fontSize: 16,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.grey800,
                                ),
                              ),
                            ],
                          ),
                          pw.SizedBox(width: 40),
                          pw.Column(
                            children: [
                              pw.Text(
                                L['percentage_label']!,
                                style: pw.TextStyle(
                                  fontSize: 11,
                                  color: PdfColors.grey600,
                                ),
                              ),
                              pw.SizedBox(height: 4),
                              pw.Text(
                                '$percentage%',
                                style: pw.TextStyle(
                                  fontSize: 36,
                                  fontWeight: pw.FontWeight.bold,
                                  color: _getCategoryColorPDF(),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),

                // SKOR KEBUTUHAN DUKUNGAN (SKD) BOX
                pw.Container(
                  padding: const pw.EdgeInsets.all(24),
                  decoration: pw.BoxDecoration(
                    gradient: pw.LinearGradient(
                      colors: [
                        _getSKDColorPDF(skdScore).shade(0.8),
                        _getSKDColorPDF(skdScore),
                      ],
                    ),
                    borderRadius: pw.BorderRadius.circular(12),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      // Left side
                      pw.Expanded(
                        flex: 2,
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              L['skd_title']!,
                              style: pw.TextStyle(
                                fontSize: 14,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.white,
                              ),
                            ),
                            pw.Text(
                              L['skd_sub']!,
                              style: pw.TextStyle(
                                fontSize: 14,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.white,
                              ),
                            ),
                            pw.SizedBox(height: 8),
                            pw.Text(
                              L['scale_label']!,
                              style: pw.TextStyle(
                                fontSize: 9,
                                color: PdfColors.white.shade(0.9),
                              ),
                            ),
                            pw.Text(
                              L['lower_better']!,
                              style: pw.TextStyle(
                                fontSize: 9,
                                color: PdfColors.white.shade(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Right side
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text(
                            skdScore.toStringAsFixed(1),
                            style: pw.TextStyle(
                              fontSize: 48,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.white,
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Container(
                            padding: const pw.EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: pw.BoxDecoration(
                              color: PdfColors.white.shade(0.2),
                              borderRadius: pw.BorderRadius.circular(8),
                            ),
                            child: pw.Text(
                              _getSKDCategory(skdScore),
                              style: pw.TextStyle(
                                fontSize: 12,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),

                // SARAN BOX
                pw.Container(
                  padding: const pw.EdgeInsets.all(20),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey100,
                    borderRadius: pw.BorderRadius.circular(12),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Row(
                        children: [
                          pw.Container(
                            width: 28,
                            height: 28,
                            decoration: pw.BoxDecoration(
                              color: PdfColor.fromHex('#F59E0B').shade(0.2),
                              borderRadius: pw.BorderRadius.circular(6),
                            ),
                            child: pw.Center(
                              child: pw.Text(
                                '💡',
                                style: const pw.TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                          pw.SizedBox(width: 12),
                          pw.Text(
                            L['advice_title']!,
                            style: pw.TextStyle(
                              fontSize: 16,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.grey800,
                            ),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 12),
                      pw.Text(
                        advice,
                        style: pw.TextStyle(
                          fontSize: 11,
                          color: PdfColors.grey700,
                          lineSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),

                // REKOMENDASI BOX
                pw.Container(
                  padding: const pw.EdgeInsets.all(20),
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('#F0FDF4'),
                    border: pw.Border.all(
                      color: PdfColor.fromHex('#10B981'),
                      width: 1,
                    ),
                    borderRadius: pw.BorderRadius.circular(12),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Row(
                        children: [
                          pw.Container(
                            width: 28,
                            height: 28,
                            decoration: pw.BoxDecoration(
                              color: PdfColor.fromHex('#10B981').shade(0.2),
                              borderRadius: pw.BorderRadius.circular(6),
                            ),
                            child: pw.Center(
                              child: pw.Text(
                                '✓',
                                style: pw.TextStyle(
                                  fontSize: 16,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColor.fromHex('#10B981'),
                                ),
                              ),
                            ),
                          ),
                          pw.SizedBox(width: 12),
                          pw.Text(
                            L['recommendations_title']!,
                            style: pw.TextStyle(
                              fontSize: 16,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.grey800,
                            ),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 12),
                      ..._getRecommendationsList().map(
                        (rec) => pw.Padding(
                          padding: const pw.EdgeInsets.only(bottom: 8),
                          child: pw.Row(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Container(
                                width: 5,
                                height: 5,
                                margin: const pw.EdgeInsets.only(top: 4),
                                decoration: pw.BoxDecoration(
                                  color: PdfColor.fromHex('#10B981'),
                                  shape: pw.BoxShape.circle,
                                ),
                              ),
                              pw.SizedBox(width: 10),
                              pw.Expanded(
                                child: pw.Text(
                                  rec,
                                  style: pw.TextStyle(
                                    fontSize: 10,
                                    color: PdfColors.grey700,
                                    lineSpacing: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // EMERGENCY
                if (percentage >= 65) ...[
                  pw.SizedBox(height: 20),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(16),
                    decoration: pw.BoxDecoration(
                      color: PdfColor.fromHex('#FEE2E2'),
                      border: pw.Border.all(
                        color: PdfColor.fromHex('#EF4444'),
                        width: 1,
                      ),
                      borderRadius: pw.BorderRadius.circular(12),
                    ),
                    child: pw.Row(
                      children: [
                        pw.Container(
                          width: 32,
                          height: 32,
                          decoration: pw.BoxDecoration(
                            color: PdfColor.fromHex('#EF4444'),
                            shape: pw.BoxShape.circle,
                          ),
                          child: pw.Center(
                            child: pw.Text(
                              '!',
                              style: pw.TextStyle(
                                fontSize: 20,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.white,
                              ),
                            ),
                          ),
                        ),
                        pw.SizedBox(width: 12),
                        pw.Expanded(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                L['emergency_help_title']!,
                                style: pw.TextStyle(
                                  fontSize: 13,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColor.fromHex('#EF4444'),
                                ),
                              ),
                              pw.SizedBox(height: 4),
                              pw.Text(
                                L['hotline_text']!,
                                style: pw.TextStyle(
                                  fontSize: 10,
                                  color: PdfColors.grey700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                pw.Spacer(),

                // Footer
                pw.Divider(color: PdfColors.grey300),
                pw.SizedBox(height: 10),
                pw.Center(
                  child: pw.Column(
                    children: [
                      pw.Text(
                        'Dokumen ini dibuat secara otomatis oleh aplikasi Insight Mind',
                        style: pw.TextStyle(
                          fontSize: 9,
                          color: PdfColors.grey500,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Untuk konsultasi lebih lanjut, hubungi profesional kesehatan mental',
                        style: pw.TextStyle(
                          fontSize: 9,
                          color: PdfColors.grey500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      );

      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename:
            'hasil_tes_mental_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membuat PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _printPDF() async {
    try {
      await _initializeLocale();
      final percentage = (widget.score / widget.maxScore * 100).toInt();

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async {
          final pdf = pw.Document();
          final category = _getCategory();
          final advice = _getAdvice();
          final dateFormat = DateFormat('dd MMMM yyyy, HH:mm', 'id_ID');
          final formattedDate = dateFormat.format(DateTime.now());

          pdf.addPage(
            pw.Page(
              pageFormat: format,
              margin: const pw.EdgeInsets.all(40),
              build: (pw.Context context) {
                return pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Center(
                      child: pw.Column(
                        children: [
                          pw.Text(
                            'HASIL TES KESEHATAN MENTAL',
                            style: pw.TextStyle(
                              fontSize: 24,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.Text('Insight Mind'),
                        ],
                      ),
                    ),
                    pw.SizedBox(height: 30),
                    pw.Text('Tanggal: $formattedDate'),
                    pw.SizedBox(height: 20),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(28),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(
                          color: _getCategoryColorPDF(),
                          width: 2,
                        ),
                        borderRadius: pw.BorderRadius.circular(12),
                      ),
                      child: pw.Column(
                        children: [
                          pw.Text(
                            category,
                            style: pw.TextStyle(
                              fontSize: 26,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.Text(
                            '$percentage%',
                            style: pw.TextStyle(fontSize: 36),
                          ),
                        ],
                      ),
                    ),
                    pw.SizedBox(height: 20),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(20),
                      decoration: pw.BoxDecoration(
                        color: _getSKDColorPDF(skdScore),
                        borderRadius: pw.BorderRadius.circular(12),
                      ),
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                'Skor Kebutuhan Dukungan (SKD)',
                                style: pw.TextStyle(
                                  color: PdfColors.white,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                              pw.Text(
                                'Skala 1-10 • Semakin rendah semakin baik',
                                style: pw.TextStyle(
                                  fontSize: 9,
                                  color: PdfColors.white,
                                ),
                              ),
                            ],
                          ),
                          pw.Text(
                            skdScore.toStringAsFixed(1),
                            style: pw.TextStyle(
                              fontSize: 42,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    pw.SizedBox(height: 20),
                    pw.Text(
                      'Saran:',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(advice),
                  ],
                );
              },
            ),
          );
          return pdf.save();
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  List<String> _getRecommendationsList() {
    final percentage = (widget.score / widget.maxScore * 100).toInt();

    if (percentage < 25) {
      return [
        'Pertahankan pola hidup sehat Anda',
        'Terus lakukan aktivitas yang Anda nikmati',
        'Jaga koneksi sosial dengan teman dan keluarga',
        'Lakukan meditasi rutin untuk menjaga ketenangan',
      ];
    } else if (percentage < 45) {
      return [
        'Pertimbangkan untuk berbicara dengan teman atau keluarga',
        'Lakukan aktivitas relaksasi seperti meditasi',
        'Jaga pola tidur dan olahraga teratur',
        'Luangkan waktu untuk hobi yang menyenangkan',
      ];
    } else if (percentage < 65) {
      return [
        'Sangat disarankan untuk berbicara dengan konselor',
        'Praktikkan teknik manajemen stres secara rutin',
        'Pertimbangkan untuk mengurangi beban kerja',
        'Jaga pola makan dan tidur yang teratur',
        'Cari dukungan dari orang-orang terdekat',
      ];
    } else {
      return [
        'Segera hubungi profesional kesehatan mental',
        'Jangan ragu untuk meminta bantuan',
        'Hubungi hotline krisis jika diperlukan: 119',
        'Ceritakan perasaan Anda pada orang yang dipercaya',
        'Pertimbangkan konseling atau terapi profesional',
      ];
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final languageService = Provider.of<LanguageService>(context);
    final L = _L(languageService);
    final percentage = (widget.score / widget.maxScore * 100).toInt();

    if (_isSaving) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5EFD0),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Color(0xFF2D4A3E)),
              const SizedBox(height: 16),
              Text(
                L['saving_results']!,
                style: const TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5EFD0),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2937)),
          onPressed: () =>
              Navigator.of(context).popUntil((route) => route.isFirst),
        ),
        title: Text(
          L['test_result_title']!,
          style: const TextStyle(
            color: Color(0xFF1F2937),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.print, color: Color(0xFF1F2937)),
            onPressed: _printPDF,
            tooltip: L['print_pdf']!,
          ),
          IconButton(
            icon: const Icon(Icons.share, color: Color(0xFF1F2937)),
            onPressed: _generateAndSharePDF,
            tooltip: L['share_pdf']!,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HASIL TES CARD
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _getCategoryColor().withOpacity(0.1),
                        _getCategoryColor().withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _getCategoryColor().withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        _getCategoryIcon(),
                        size: 80,
                        color: _getCategoryColor(),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        L[_getCategoryKey()] ?? _getCategory(),
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: _getCategoryColor(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${L['score_label']!}: ${widget.score} / ${widget.maxScore}',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Color(0xFF6B7280),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$percentage%',
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: _getCategoryColor(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // SKOR KEBUTUHAN DUKUNGAN CARD
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _getSKDColor(skdScore).withOpacity(0.85),
                      _getSKDColor(skdScore),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: _getSKDColor(skdScore).withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Left side - Title
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Skor Kebutuhan',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const Text(
                            'Dukungan (SKD)',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Skala 1-10',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                          Text(
                            'Semakin rendah semakin baik',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Right side - Score
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          skdScore.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 56,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _getSKDCategory(skdScore),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // SARAN CARD
              Container(
                padding: const EdgeInsets.all(24),
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
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.lightbulb_outline,
                            color: Color(0xFFF59E0B),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Text(
                          L['advice_title']!,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _getAdviceForLanguage(languageService),
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF6B7280),
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // REKOMENDASI CARD
              Container(
                padding: const EdgeInsets.all(24),
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
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6B9080).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.check_circle_outline,
                            color: Color(0xFF6B9080),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Text(
                          L['recommendations_title']!,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    ..._getRecommendationsListLocalized(languageService).map((
                      rec,
                    ) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 6),
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Color(0xFF6B9080),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                rec,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF4B5563),
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // INFO TEXT
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFF5A7B6A).withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Color(0xFF5A7B6A),
                      size: 22,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        L['view_history_info']!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF2D4A3E),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // EMERGENCY HELP (jika skor tinggi)
              if (percentage >= 65)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFFEF4444),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          color: Color(0xFFEF4444),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.emergency,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              L['emergency_help_title']!,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFEF4444),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              L['hotline_text']!,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[800],
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              if (percentage >= 65) const SizedBox(height: 24),

              // EXPORT BUTTONS
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _printPDF,
                      icon: const Icon(Icons.print, size: 20),
                      label: Text(L['print_pdf']!),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF2D4A3E),
                        side: const BorderSide(
                          color: Color(0xFF2D4A3E),
                          width: 1.5,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _generateAndSharePDF,
                      icon: const Icon(Icons.share, size: 20),
                      label: Text(L['share_pdf']!),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2D4A3E),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // BACK TO HOME BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2D4A3E),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    L['back_home']!,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getCategoryKey() {
    final percentage = (widget.score / widget.maxScore) * 100;
    if (percentage < 25) {
      return 'category_very_good';
    }
    if (percentage < 45) {
      return 'category_good';
    }
    if (percentage < 65) {
      return 'category_attention';
    }
    return 'category_professional';
  }

  String _getSKDCategoryKey(double score) {
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

  String _localeForLanguageCode(LanguageService ls) {
    final code = ls.currentLanguageCode == 'system'
        ? ls.currentLocale.languageCode
        : ls.currentLanguageCode;
    if (code.startsWith('en')) return 'en_US';
    if (code.startsWith('zh')) return 'zh_CN';
    if (code.startsWith('ar')) return 'ar_SA';
    return 'id_ID';
  }

  Future<void> _initializeLocaleForLanguage(LanguageService ls) async {
    if (!_localeInitialized) {
      final locale = _localeForLanguageCode(ls);
      await initializeDateFormatting(locale, null);
      _localeInitialized = true;
    }
  }

  String _getAdviceForLanguage(LanguageService ls) {
    final code = ls.currentLanguageCode == 'system'
        ? ls.currentLocale.languageCode
        : ls.currentLanguageCode;
    final percentage = (widget.score / widget.maxScore) * 100;

    if (code.startsWith('en')) {
      if (percentage < 25) {
        return 'Your mental condition is excellent! Keep up healthy habits, exercise regularly, and maintain life balance.';
      }
      if (percentage < 45) {
        return 'Your mental condition is good. Practice regular meditation, maintain sleep hygiene, and take time for yourself.';
      }
      if (percentage < 65) {
        return 'You may be experiencing stress. Consider talking to someone close, do calming activities, and seek professional help if needed.';
      }
      return 'Your results suggest you may need professional support. Consult a psychologist or psychiatrist for proper care.';
    }

    if (code.startsWith('zh')) {
      if (percentage < 25) {
        return '您的心理状况非常好！保持健康的生活方式，定期锻炼，保持生活平衡。';
      }
      if (percentage < 45) {
        return '您的心理状况良好。定期冥想，保持良好睡眠，给自己留出时间。';
      }
      if (percentage < 65) {
        return '您可能正在经历压力。考虑与亲近的人交谈，做一些让人平静的活动，如有需要请寻求专业帮助。';
      }
      return '您的结果表明您可能需要专业支持。建议咨询心理学家或精神科医生以获得适当的帮助。';
    }

    if (code.startsWith('ar')) {
      if (percentage < 25) {
        return 'حالتك النفسية جيدة جداً! حافظ على نمط حياة صحي ومارس الرياضة بانتظام.';
      }
      if (percentage < 45) {
        return 'حالتك النفسية جيدة. مارس التأمل بانتظام واهتم بنومك وخذ وقتًا لنفسك.';
      }
      if (percentage < 65) {
        return 'قد تكون تحت ضغط نفسي. فكر في التحدث مع شخص مقرب وممارسة أنشطة مهدئة واطلب مساعدة متخصصة إذا لزم الأمر.';
      }
      return 'تشير النتيجة إلى أنك قد تحتاج إلى دعم متخصص. يُنصح باستشارة أخصائي نفسي أو طبيب نفسي.';
    }

    // Default Indonesian
    if (percentage < 25) {
      return 'Kondisi mental Anda sangat baik! Terus pertahankan pola hidup sehat, olahraga teratur, dan jaga keseimbangan hidup Anda.';
    }
    if (percentage < 45) {
      return 'Kondisi mental Anda cukup baik. Lakukan meditasi rutin, jaga pola tidur, dan luangkan waktu untuk diri sendiri.';
    }
    if (percentage < 65) {
      return 'Anda mungkin mengalami stres atau tekanan. Pertimbangkan untuk berbicara dengan orang terdekat, lakukan aktivitas yang menenangkan, dan jangan ragu mencari bantuan profesional jika diperlukan.';
    }
    return 'Hasil tes menunjukkan Anda mungkin memerlukan bantuan profesional. Sangat disarankan untuk berkonsultasi dengan psikolog atau psikiater untuk mendapatkan penanganan yang tepat.';
  }

  List<String> _getRecommendationsListLocalized(LanguageService ls) {
    final code = ls.currentLanguageCode == 'system'
        ? ls.currentLocale.languageCode
        : ls.currentLanguageCode;
    final percentage = (widget.score / widget.maxScore * 100).toInt();

    if (code.startsWith('en')) {
      if (percentage < 25) {
        return [
          'Maintain healthy habits',
          'Keep doing activities you enjoy',
          'Stay socially connected with friends and family',
          'Practice regular meditation',
        ];
      }
      if (percentage < 45) {
        return [
          'Talk to a friend or family member',
          'Practice relaxation like meditation',
          'Maintain sleep and exercise routines',
          'Make time for enjoyable hobbies',
        ];
      }
      if (percentage < 65) {
        return [
          'Consider speaking with a counselor',
          'Practice stress management techniques',
          'Consider reducing workload',
          'Maintain healthy eating and sleep patterns',
          'Seek support from loved ones',
        ];
      }
      return [
        'Contact a mental health professional immediately',
        'Do not hesitate to ask for help',
        'Call crisis hotline if needed',
        'Share your feelings with a trusted person',
        'Consider professional counseling or therapy',
      ];
    }

    if (code.startsWith('zh')) {
      if (percentage < 25) {
        return ['保持健康的生活方式', '继续从事让您愉快的活动', '与朋友和家人保持联系', '定期练习冥想'];
      }
      if (percentage < 45) {
        return ['与朋友或家人谈谈', '练习放松方法，如冥想', '保持睡眠和运动规律', '为爱好留出时间'];
      }
      if (percentage < 65) {
        return ['考虑与咨询师交谈', '定期练习压力管理技巧', '考虑减少工作负担', '保持健康的饮食和睡眠', '寻求亲友支持'];
      }
      return [
        '立即联系心理健康专业人员',
        '不要犹豫寻求帮助',
        '如有需要请拨打危机热线',
        '与可信赖的人分享感受',
        '考虑专业咨询或治疗',
      ];
    }

    if (code.startsWith('ar')) {
      if (percentage < 25) {
        return [
          'حافظ على نمط حياة صحي',
          'استمر في الأنشطة التي تستمتع بها',
          'حافظ على علاقاتك الاجتماعية',
          'مارس التأمل بانتظام',
        ];
      }
      if (percentage < 45) {
        return [
          'تحدث مع صديق أو فرد من العائلة',
          'مارس أساليب الاسترخاء مثل التأمل',
          'حافظ على نمط نوم وممارسة رياضة منتظم',
          'خصص وقتًا لهواياتك',
        ];
      }
      if (percentage < 65) {
        return [
          'فكر في التحدث مع مستشار',
          'مارس تقنيات إدارة الإجهاد بانتظام',
          'فكر في تقليل عبء العمل',
          'حافظ على نظام غذائي ونوم صحي',
          'اطلب دعم من الأشخاص المقربين',
        ];
      }
      return [
        'اتصل بمحترف صحة نفسية فورًا',
        'لا تتردد في طلب المساعدة',
        'اتصل بخط الطوارئ إذا لزم الأمر',
        'تحدث مع شخص موثوق',
        'فكر في الاستشارة أو العلاج المهني',
      ];
    }

    // Default Indonesian
    if (percentage < 25) {
      return [
        'Pertahankan pola hidup sehat Anda',
        'Terus lakukan aktivitas yang Anda nikmati',
        'Jaga koneksi sosial dengan teman dan keluarga',
        'Lakukan meditasi rutin untuk menjaga ketenangan',
      ];
    }
    if (percentage < 45) {
      return [
        'Pertimbangkan untuk berbicara dengan teman atau keluarga',
        'Lakukan aktivitas relaksasi seperti meditasi',
        'Jaga pola tidur dan olahraga teratur',
        'Luangkan waktu untuk hobi yang menyenangkan',
      ];
    }
    if (percentage < 65) {
      return [
        'Sangat disarankan untuk berbicara dengan konselor',
        'Praktikkan teknik manajemen stres secara rutin',
        'Pertimbangkan untuk mengurangi beban kerja',
        'Jaga pola makan dan tidur yang teratur',
        'Cari dukungan dari orang-orang terdekat',
      ];
    }
    return [
      'Segera hubungi profesional kesehatan mental',
      'Jangan ragu untuk meminta bantuan',
      'Hubungi hotline krisis jika diperlukan: 119',
      'Ceritakan perasaan Anda pada orang yang dipercaya',
      'Pertimbangkan konseling atau terapi profesional',
    ];
  }

  Map<String, String> _L(LanguageService ls) {
    final code = ls.currentLanguageCode == 'system'
        ? ls.currentLocale.languageCode
        : ls.currentLanguageCode;

    if (code.startsWith('en')) {
      return {
        'saving_results': 'Saving test results...',
        'test_result_title': 'Test Results',
        'pdf_title': 'MENTAL HEALTH TEST RESULTS',
        'app_name': 'Insight Mind',
        'date_label': 'Test Date',
        'score_label': 'Score',
        'percentage_label': 'Percentage',
        'skd_title': 'Support Score',
        'skd_sub': 'Support (SKD)',
        'scale_label': 'Scale 1-10',
        'lower_better': 'Lower is better',
        'advice_title': 'Advice for You',
        'recommendations_title': 'Recommended Actions',
        'view_history_info':
            'See full test history in Quick Access on the home page',
        'emergency_help_title': 'Need Immediate Help?',
        'hotline_text': 'Crisis Hotline: 119 or 0804-1-500-454',
        'print_pdf': 'Print PDF',
        'share_pdf': 'Share PDF',
        'back_home': 'Back to Home',
        'category_very_good': 'Very Good',
        'category_good': 'Good',
        'category_attention': 'Needs Attention',
        'category_professional': 'Needs Professional Help',
        'skd_baik': 'Good',
        'skd_normal': 'Normal',
        'skd_attention': 'Needs Attention',
        'skd_high': 'High',
      };
    }

    if (code.startsWith('zh')) {
      return {
        'saving_results': '正在保存测试结果...',
        'test_result_title': '测试结果',
        'pdf_title': '心理健康测试结果',
        'app_name': 'Insight Mind',
        'date_label': '测试日期',
        'score_label': '分数',
        'percentage_label': '百分比',
        'skd_title': '需求得分',
        'skd_sub': '支持 (SKD)',
        'scale_label': '1-10 量表',
        'lower_better': '越低越好',
        'advice_title': '给您的建议',
        'recommendations_title': '推荐的行动',
        'view_history_info': '在主页的快速访问中查看完整测试历史',
        'emergency_help_title': '需要立即帮助？',
        'hotline_text': '危机热线：119 或 0804-1-500-454',
        'print_pdf': '打印 PDF',
        'share_pdf': '分享 PDF',
        'back_home': '返回首页',
        'category_very_good': '非常好',
        'category_good': '良好',
        'category_attention': '需注意',
        'category_professional': '需专业帮助',
        'skd_baik': '良好',
        'skd_normal': '正常',
        'skd_attention': '需注意',
        'skd_high': '高',
      };
    }

    if (code.startsWith('ar')) {
      return {
        'saving_results': 'جارٍ حفظ نتائج الاختبار...',
        'test_result_title': 'نتائج الاختبار',
        'pdf_title': 'نتائج اختبار الصحة النفسية',
        'app_name': 'Insight Mind',
        'date_label': 'تاريخ الاختبار',
        'score_label': 'النتيجة',
        'percentage_label': 'النسبة',
        'skd_title': 'درجة الاحتياج',
        'skd_sub': 'الدعم (SKD)',
        'scale_label': 'المقياس 1-10',
        'lower_better': 'الأقل أفضل',
        'advice_title': 'نصائح لك',
        'recommendations_title': 'التوصيات',
        'view_history_info':
            'راجع سجل الاختبارات الكامل في الوصول السريع على الصفحة الرئيسية',
        'emergency_help_title': 'هل تحتاج مساعدة فورية؟',
        'hotline_text': 'الخط الساخن للأزمات: 119 أو 0804-1-500-454',
        'print_pdf': 'طباعة PDF',
        'share_pdf': 'مشاركة PDF',
        'back_home': 'العودة إلى الصفحة الرئيسية',
        'category_very_good': 'جيد جدًا',
        'category_good': 'جيد',
        'category_attention': 'يحتاج انتباه',
        'category_professional': 'يحتاج مساعدة محترفة',
        'skd_baik': 'جيد',
        'skd_normal': 'طبيعي',
        'skd_attention': 'يحتاج انتباه',
        'skd_high': 'مرتفع',
      };
    }

    // Default Indonesian
    return {
      'saving_results': 'Menyimpan hasil tes...',
      'test_result_title': 'Hasil Tes',
      'pdf_title': 'HASIL TES KESEHATAN MENTAL',
      'app_name': 'Insight Mind',
      'date_label': 'Tanggal Tes',
      'score_label': 'Skor',
      'percentage_label': 'Persentase',
      'skd_title': 'Skor Kebutuhan',
      'skd_sub': 'Dukungan (SKD)',
      'scale_label': 'Skala 1-10',
      'lower_better': 'Semakin rendah semakin baik',
      'advice_title': 'Saran untuk Anda',
      'recommendations_title': 'Rekomendasi Tindakan',
      'view_history_info':
          'Lihat riwayat tes lengkap di Akses Cepat pada halaman beranda',
      'emergency_help_title': 'Butuh Bantuan Segera?',
      'hotline_text': 'Hubungi Hotline Krisis: 119 atau 0804-1-500-454',
      'print_pdf': 'Cetak PDF',
      'share_pdf': 'Bagikan PDF',
      'back_home': 'Kembali ke Beranda',
      'category_very_good': 'Sangat Baik',
      'category_good': 'Baik',
      'category_attention': 'Perlu Perhatian',
      'category_professional': 'Perlu Bantuan Profesional',
      'skd_baik': 'Baik',
      'skd_normal': 'Normal',
      'skd_attention': 'Perlu Perhatian',
      'skd_high': 'Tinggi',
    };
  }
}
