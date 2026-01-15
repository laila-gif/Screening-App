import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
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
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
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
      await _initializeLocale();

      final percentage = (widget.score / widget.maxScore * 100).toInt();
      final category = _getCategory();
      final advice = _getAdvice();
      final dateFormat = DateFormat('dd MMMM yyyy, HH:mm', 'id_ID');
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
                        'HASIL TES KESEHATAN MENTAL',
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.grey800,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        'Insight Mind',
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
                  'Tanggal Tes: $formattedDate',
                  style: pw.TextStyle(
                    fontSize: 11,
                    color: PdfColors.grey600,
                  ),
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
                                'Skor',
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
                                'Persentase',
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
                              'Skor Kebutuhan',
                              style: pw.TextStyle(
                                fontSize: 14,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.white,
                              ),
                            ),
                            pw.Text(
                              'Dukungan (SKD)',
                              style: pw.TextStyle(
                                fontSize: 14,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.white,
                              ),
                            ),
                            pw.SizedBox(height: 8),
                            pw.Text(
                              'Skala 1-10',
                              style: pw.TextStyle(
                                fontSize: 9,
                                color: PdfColors.white.shade(0.9),
                              ),
                            ),
                            pw.Text(
                              'Semakin rendah semakin baik',
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
                            'Saran untuk Anda',
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
                            'Rekomendasi Tindakan',
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
                                'Butuh Bantuan Segera?',
                                style: pw.TextStyle(
                                  fontSize: 13,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColor.fromHex('#EF4444'),
                                ),
                              ),
                              pw.SizedBox(height: 4),
                              pw.Text(
                                'Hubungi Hotline Krisis: 119 atau 0804-1-500-454',
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
        filename: 'hasil_tes_mental_${DateTime.now().millisecondsSinceEpoch}.pdf',
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
                          pw.Text('HASIL TES KESEHATAN MENTAL', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
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
                        border: pw.Border.all(color: _getCategoryColorPDF(), width: 2),
                        borderRadius: pw.BorderRadius.circular(12),
                      ),
                      child: pw.Column(
                        children: [
                          pw.Text(category, style: pw.TextStyle(fontSize: 26, fontWeight: pw.FontWeight.bold)),
                          pw.Text('$percentage%', style: pw.TextStyle(fontSize: 36)),
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
                              pw.Text('Skor Kebutuhan Dukungan (SKD)', style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold)),
                              pw.Text('Skala 1-10 • Semakin rendah semakin baik', style: pw.TextStyle(fontSize: 9, color: PdfColors.white)),
                            ],
                          ),
                          pw.Text(skdScore.toStringAsFixed(1), style: pw.TextStyle(fontSize: 42, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
                        ],
                      ),
                    ),
                    pw.SizedBox(height: 20),
                    pw.Text('Saran:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
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
    final percentage = (widget.score / widget.maxScore * 100).toInt();

    if (_isSaving) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5EFD0),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Color(0xFF2D4A3E)),
              SizedBox(height: 16),
              Text('Menyimpan hasil tes...', style: TextStyle(fontSize: 16, color: Color(0xFF6B7280))),
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
          onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
        ),
        title: const Text('Hasil Tes', style: TextStyle(color: Color(0xFF1F2937), fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.print, color: Color(0xFF1F2937)), onPressed: _printPDF, tooltip: 'Cetak PDF'),
          IconButton(icon: const Icon(Icons.share, color: Color(0xFF1F2937)), onPressed: _generateAndSharePDF, tooltip: 'Bagikan PDF'),
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
                      colors: [_getCategoryColor().withOpacity(0.1), _getCategoryColor().withOpacity(0.05)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _getCategoryColor().withOpacity(0.3), width: 2),
                  ),
                  child: Column(
                    children: [
                      Icon(_getCategoryIcon(), size: 80, color: _getCategoryColor()),
                      const SizedBox(height: 20),
                      Text(_getCategory(), style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: _getCategoryColor())),
                      const SizedBox(height: 12),
                      Text('Skor: ${widget.score} dari ${widget.maxScore}', style: const TextStyle(fontSize: 18, color: Color(0xFF6B7280), fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      Text('$percentage%', style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: _getCategoryColor())),
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
                    colors: [_getSKDColor(skdScore).withOpacity(0.85), _getSKDColor(skdScore)],
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
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
                        const Text(
                          'Saran untuk Anda',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _getAdvice(),
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
                        const Text(
                          'Rekomendasi Tindakan',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    ..._getRecommendationsList().map((rec) {
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
                  children: const [
                    Icon(Icons.info_outline, color: Color(0xFF5A7B6A), size: 22),
                    SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        'Lihat riwayat tes lengkap di Akses Cepat pada halaman beranda',
                        style: TextStyle(
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
                            const Text(
                              'Butuh Bantuan Segera?',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFEF4444),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Hubungi Hotline Krisis: 119 atau 0804-1-500-454',
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
                      label: const Text('Cetak PDF'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF2D4A3E),
                        side: const BorderSide(color: Color(0xFF2D4A3E), width: 1.5),
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
                      label: const Text('Bagikan PDF'),
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
                  child: const Text(
                    'Kembali ke Beranda',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}