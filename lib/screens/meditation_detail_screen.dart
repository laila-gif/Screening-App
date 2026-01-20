import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/language_service.dart';
import '../services/translation_service.dart';
import 'meditation_player_screen.dart';

class MeditationDetailScreen extends StatefulWidget {
  final Map<String, dynamic> meditation;

  const MeditationDetailScreen({Key? key, required this.meditation})
    : super(key: key);

  @override
  State<MeditationDetailScreen> createState() => _MeditationDetailScreenState();
}

class _MeditationDetailScreenState extends State<MeditationDetailScreen> {
  @override
  void initState() {
    super.initState();
    _ensureLocalized();
  }

  void _ensureLocalized() {
    final ls = Provider.of<LanguageService>(context, listen: false);
    String code = ls.currentLanguageCode == 'system'
        ? ls.currentLocale.languageCode
        : ls.currentLanguageCode;
    String target = code.startsWith('en')
        ? 'en'
        : code.startsWith('zh')
        ? 'zh'
        : code.startsWith('ar')
        ? 'ar'
        : 'id';
    if (target == 'id') return;
    final med = widget.meditation;
    final titleKey = 'title_$target';
    final descKey = 'description_$target';
    final benefitsKey = 'benefits_$target';

    if ((!med.containsKey(titleKey) ||
            med[titleKey] == null ||
            med[titleKey].toString().isEmpty) &&
        med.containsKey('title')) {
      TranslationService.translate(med['title'].toString(), target).then((t) {
        med[titleKey] = t;
        if (mounted) setState(() {});
      });
    }
    if ((!med.containsKey(descKey) ||
            med[descKey] == null ||
            med[descKey].toString().isEmpty) &&
        med.containsKey('description')) {
      TranslationService.translate(med['description'].toString(), target).then((
        t,
      ) {
        med[descKey] = t;
        if (mounted) setState(() {});
      });
    }
    if ((!med.containsKey(benefitsKey) || med[benefitsKey] == null) &&
        med.containsKey('benefits') &&
        med['benefits'] is List) {
      final List benefits = med['benefits'] as List;
      Future.wait(
        benefits.map((b) => TranslationService.translate(b.toString(), target)),
      ).then((translated) {
        med[benefitsKey] = translated;
        if (mounted) setState(() {});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ls = Provider.of<LanguageService>(context, listen: false);
    String code = ls.currentLanguageCode == 'system'
        ? ls.currentLocale.languageCode
        : ls.currentLanguageCode;
    Map<String, String> L = {
      'about_title': code.startsWith('en')
          ? 'About Meditation'
          : code.startsWith('zh')
          ? '关于冥想'
          : code.startsWith('ar')
          ? 'حول التأمل'
          : 'Tentang Meditasi',
      'benefits_title': code.startsWith('en')
          ? 'Benefits'
          : code.startsWith('zh')
          ? '好处'
          : code.startsWith('ar')
          ? 'الفوائد'
          : 'Manfaat',
      'tips_title': code.startsWith('en')
          ? 'Meditation Tips'
          : code.startsWith('zh')
          ? '冥想小贴士'
          : code.startsWith('ar')
          ? 'نصائح التأمل'
          : 'Tips Meditasi',
      'tips_text': code.startsWith('en')
          ? '• Find a quiet, comfortable spot\n• Use headphones for best experience\n• Sit or lie in a comfortable position\n• Focus on your breathing'
          : code.startsWith('zh')
          ? '• 找一个安静舒适的地方\n• 使用耳机以获得最佳体验\n• 以舒适的姿势坐下或躺下\n• 专注于你的呼吸'
          : code.startsWith('ar')
          ? '• ابحث عن مكان هادئ ومريح\n• استخدم سماعات الأذن لتجربة أفضل\n• اجلس أو استلقِ بوضعية مريحة\n• ركز على تنفسك'
          : '• Cari tempat yang tenang dan nyaman\n• Gunakan headphone untuk pengalaman terbaik\n• Duduk atau berbaring dengan posisi nyaman\n• Fokus pada pernapasan Anda',
      'start_button': code.startsWith('en')
          ? 'Start Meditation'
          : code.startsWith('zh')
          ? '开始冥想'
          : code.startsWith('ar')
          ? 'ابدأ التأمل'
          : 'Mulai Meditasi',
    };
    String localizeDuration(String? dur) {
      final d = dur ?? '';
      final match = RegExp(r"(\d+)").firstMatch(d);
      if (match != null) {
        final mins = match.group(1);
        return '$mins ${code.startsWith('en')
            ? 'minutes'
            : code.startsWith('zh')
            ? '分钟'
            : code.startsWith('ar')
            ? 'دقائق'
            : 'Menit'}';
      }
      return d;
    }

    String localizeCategory(String? cat) {
      if (cat == null) return '';
      final c = cat.toLowerCase();
      final map = {
        'relaksasi': {
          'en': 'Relaxation',
          'zh': '放松',
          'ar': 'استرخاء',
          'id': 'Relaksasi',
        },
        'tidur': {'en': 'Sleep', 'zh': '睡眠', 'ar': 'نوم', 'id': 'Tidur'},
        'fokus': {'en': 'Focus', 'zh': '专注', 'ar': 'تركيز', 'id': 'Fokus'},
      };
      for (final k in map.keys) {
        if (c.contains(k)) {
          if (code.startsWith('en')) return map[k]!['en']!;
          if (code.startsWith('zh')) return map[k]!['zh']!;
          if (code.startsWith('ar')) return map[k]!['ar']!;
          return map[k]!['id']!;
        }
      }
      return cat;
    }

    String localizeBenefit(String benefit) {
      final b = benefit.toLowerCase();
      if (b.contains('tenang') || b.contains('relaks')) {
        if (code.startsWith('en')) return 'Calmness';
        if (code.startsWith('zh')) return '平静';
        if (code.startsWith('ar')) return 'الهدوء';
        return 'Tenang';
      }
      if (b.contains('tidur') || b.contains('lelap')) {
        if (code.startsWith('en')) return 'Better Sleep';
        if (code.startsWith('zh')) return '更好的睡眠';
        if (code.startsWith('ar')) return 'نوم أفضل';
        return 'Tidur Lebih Baik';
      }
      return benefit;
    }

    String localizeField(String base) {
      final lang = code.startsWith('en')
          ? 'en'
          : code.startsWith('zh')
          ? 'zh'
          : code.startsWith('ar')
          ? 'ar'
          : 'id';
      final key = '${base}_$lang';
      if (widget.meditation.containsKey(key) &&
          widget.meditation[key] != null &&
          widget.meditation[key].toString().isNotEmpty) {
        return widget.meditation[key].toString();
      }
      if (widget.meditation.containsKey(base) &&
          widget.meditation[base] != null) {
        return widget.meditation[base].toString();
      }
      return '';
    }

    List<dynamic> localizeBenefits() {
      final lang = code.startsWith('en')
          ? 'en'
          : code.startsWith('zh')
          ? 'zh'
          : code.startsWith('ar')
          ? 'ar'
          : 'id';
      final key = 'benefits_$lang';
      if (widget.meditation.containsKey(key) &&
          widget.meditation[key] is List &&
          (widget.meditation[key] as List).isNotEmpty) {
        return widget.meditation[key] as List;
      }
      if (widget.meditation.containsKey('benefits') &&
          widget.meditation['benefits'] is List) {
        return widget.meditation['benefits'] as List;
      }
      return <dynamic>[];
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5EFD0),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: widget.meditation['color'],
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // --- PERUBAHAN DI SINI ---
                  // Mengganti Container + CustomPaint dengan Image.asset
                  (() {
                    final imagePath = widget.meditation['imagePath'] as String?;
                    if (imagePath == null || imagePath.isEmpty) {
                      return Container(
                        color: Colors.red,
                        child: const Center(
                          child: Text(
                            'Null check operator used on a null value\nsee also: https://docs.flutter.dev',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.yellow,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      );
                    }
                    return Image.asset(
                      imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.red,
                          child: const Center(
                            child: Text(
                              'Null check operator used on a null value\nsee also: https://docs.flutter.dev',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.yellow,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  })(),
                  // --- AKHIR PERUBAHAN ---

                  // Gradient overlay ini tetap ada agar judul terlihat jelas
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.4),
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and duration
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          localizeField('title'),
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: widget.meditation['color'].withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 16,
                              color: widget.meditation['color'],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              localizeDuration(
                                widget.meditation['duration']?.toString(),
                              ),
                              style: TextStyle(
                                color: widget.meditation['color'],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Category chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6B9080),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      localizeCategory(
                        widget.meditation['category']?.toString(),
                      ),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Description
                  Text(
                    L['about_title']!,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    localizeField('description'),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Benefits
                  Text(
                    L['benefits_title']!,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...localizeBenefits().map<Widget>((benefit) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: widget.meditation['color'],
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              localizeBenefit(benefit.toString()),
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.black87,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 32),

                  // Tips section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8E4CC),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.lightbulb_outline,
                              color: widget.meditation['color'],
                            ),
                            const SizedBox(width: 8),
                            Text(
                              L['tips_title']!,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          L['tips_text']!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                            height: 1.6,
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
      bottomSheet: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Color(0xFFF5EFD0),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      MeditationPlayerScreen(meditation: widget.meditation),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6B9080),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.play_arrow, size: 28),
                const SizedBox(width: 8),
                Text(
                  L['start_button']!,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- CLASS MeditationImagePainter DIHAPUS DARI SINI ---
