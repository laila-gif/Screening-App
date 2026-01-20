import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/translation_service.dart';
import '../services/language_service.dart';
import 'meditation_detail_screen.dart';

class MeditationScreen extends StatefulWidget {
  const MeditationScreen({Key? key}) : super(key: key);

  @override
  State<MeditationScreen> createState() => _MeditationScreenState();
}

class _MeditationScreenState extends State<MeditationScreen> {
  String selectedCategory = 'Semua';
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  final List<Map<String, dynamic>> allMeditations = [
    {
      'title': 'Tenang di Pagi Hari',
      'title_en': 'Calm Morning',
      'title_zh': '清晨宁静',
      'title_ar': 'هدوء الصباح',
      'duration': '10 Menit',
      'imagePath': 'assets/images/Pagi_Hari.jpg',
      'color': Color(0xFFFFB84D),
      'category': 'Fokus',
      'description':
          'Mulai hari Anda dengan ketenangan dan energi positif melalui meditasi pagi yang menyegarkan.',
      'description_en':
          'Start your day with calm and positive energy through a refreshing morning meditation.',
      'description_zh': '以清新的晨间冥想开始你的一天，带来平静和积极的能量。',
      'description_ar':
          'ابدأ يومك بالهدوء والطاقة الإيجابية من خلال تأمل صباحي منعش.',
      'benefits': [
        'Meningkatkan fokus',
        'Energi positif',
        'Mengurangi stres pagi',
      ],
      'benefits_en': [
        'Improves focus',
        'Positive energy',
        'Reduces morning stress',
      ],
      'benefits_zh': ['提高专注力', '积极能量', '减少晨间压力'],
      'benefits_ar': ['يعزز التركيز', 'طاقة إيجابية', 'يقلل التوتر الصباحي'],
      'audioUrl': 'audio/sunday_driver_loop_401994.mp3',
    },
    {
      'title': 'Pengantar Tidur Lelap',
      'title_en': 'Deep Sleep Guide',
      'title_zh': '安眠导引',
      'title_ar': 'مقدمة للنوم العميق',
      'duration': '15 Menit',
      'imagePath': 'assets/images/Tidur_Lelap.webp',
      'color': Color(0xFF2C3E50),
      'category': 'Tidur',
      'description':
          'Meditasi khusus untuk membantu Anda rileks dan mendapatkan tidur yang berkualitas.',
      'description_en':
          'A meditation designed to help you relax and achieve quality sleep.',
      'description_zh': '旨在帮助您放松并获得高质量睡眠的冥想。',
      'description_ar':
          'تأمل لمساعدتك على الاسترخاء والحصول على نوم جيد الجودة.',
      'benefits': [
        'Tidur lebih nyenyak',
        'Mengurangi insomnia',
        'Relaksasi mendalam',
      ],
      'benefits_en': ['Sleep better', 'Reduce insomnia', 'Deep relaxation'],
      'benefits_zh': ['睡眠更好', '减少失眠', '深度放松'],
      'benefits_ar': ['تحسين النوم', 'تقليل الأرق', 'استرخاء عميق'],
      'audioUrl': 'audio/meditation-background-music-383120.mp3',
    },
    {
      'title': 'Fokus Sepenuhnya',
      'title_en': 'Full Focus',
      'title_zh': '完全专注',
      'title_ar': 'تركيز كامل',
      'duration': '5 Menit',
      'imagePath': 'assets/images/Fokus_Sepenuhnya.jpg',
      'color': Color(0xFF6B9080),
      'category': 'Fokus',
      'description':
          'Meditasi singkat untuk meningkatkan konsentrasi dan produktivitas Anda.',
      'description_en':
          'A short meditation to boost concentration and productivity.',
      'description_zh': '提高专注力并提升工作效率的简短冥想。',
      'description_ar': 'تأمل قصير لتعزيز التركيز والإنتاجية.',
      'benefits': [
        'Konsentrasi maksimal',
        'Produktivitas meningkat',
        'Pikiran jernih',
      ],
      'benefits_en': [
        'Maximum concentration',
        'Increased productivity',
        'Clear mind',
      ],
      'benefits_zh': ['极高的专注力', '生产力提高', '头脑清晰'],
      'benefits_ar': ['تركيز عالٍ', 'زيادة الإنتاجية', 'ذهن صافٍ'],
      'audioUrl': 'audio/meditation-music-338902.mp3',
    },
    {
      'title': 'Meditasi Pemula',
      'title_en': 'Beginner Meditation',
      'title_zh': '初学者冥想',
      'title_ar': 'تأمل للمبتدئين',
      'duration': '10 Menit',
      'imagePath': 'assets/images/Meditasi_Pemula.jpg',
      'color': Color(0xFF8B9D77),
      'category': 'Semua',
      'description':
          'Panduan meditasi untuk pemula yang ingin memulai perjalanan mindfulness.',
      'description_en':
          'A beginner-friendly meditation guide to start your mindfulness journey.',
      'description_zh': '面向初学者的冥想指南，帮助开始正念之旅。',
      'description_ar': 'دليل تأمل للمبتدئين لبدء رحلة اليقظة الذهنية.',
      'benefits': ['Mudah dipahami', 'Dasar meditasi', 'Relaksasi'],
      'benefits_en': ['Easy to follow', 'Meditation basics', 'Relaxation'],
      'benefits_zh': ['易于理解', '冥想基础', '放松'],
      'benefits_ar': ['سهل الفهم', 'أساسيات التأمل', 'استرخاء'],
      'audioUrl': 'audio/meditation-music-427644.mp3',
    },
    {
      'title': 'Mengatasi Kecemasan',
      'title_en': 'Overcoming Anxiety',
      'title_zh': '克服焦虑',
      'title_ar': 'التغلب على القلق',
      'duration': '12 Menit',
      'imagePath': 'assets/images/Mengatasi_Kecemasan.jpg',
      'color': Color(0xFF9B6B9E),
      'category': 'Stres',
      'description':
          'Teknik meditasi untuk meredakan kecemasan dan memberikan ketenangan pikiran.',
      'description_en': 'Meditation techniques to ease anxiety and bring calm.',
      'description_zh': '缓解焦虑并带来平静的冥想技巧。',
      'description_ar': 'تقنيات تأمل لتهدئة القلق وجلب الطمأنينة.',
      'benefits': ['Mengurangi kecemasan', 'Pikiran tenang', 'Emosi stabil'],
      'benefits_en': ['Reduce anxiety', 'Calm mind', 'Stable emotions'],
      'benefits_zh': ['减少焦虑', '内心平静', '情绪稳定'],
      'benefits_ar': ['تقليل القلق', 'هدوء العقل', 'استقرار المشاعر'],
      'audioUrl': 'audio/meditation-yoga-relaxing-music-380330.mp3',
    },
    {
      'title': 'Meditasi Pernapasan',
      'title_en': 'Breathing Meditation',
      'title_zh': '呼吸冥想',
      'title_ar': 'تأمل التنفس',
      'duration': '8 Menit',
      'imagePath': 'assets/images/Meditasi_Pernapasan.webp',
      'color': Color(0xFF5DADE2),
      'category': 'Stres',
      'description':
          'Fokus pada pernapasan untuk mencapai ketenangan dan mengurangi stres.',
      'description_en': 'Focus on breathing to achieve calm and reduce stress.',
      'description_zh': '专注于呼吸以达到平静并减轻压力。',
      'description_ar': 'التركيز على التنفس لتحقيق الهدوء وتقليل التوتر.',
      'benefits': ['Pernapasan teratur', 'Stres berkurang', 'Relaksasi otot'],
      'benefits_en': [
        'Regular breathing',
        'Reduced stress',
        'Muscle relaxation',
      ],
      'benefits_zh': ['呼吸有序', '压力降低', '肌肉放松'],
      'benefits_ar': ['تنفس منتظم', 'انخفاض التوتر', 'استرخاء العضلات'],
      'audioUrl': 'audio/sleep-music-vol16-195422.mp3',
    },
    {
      'title': 'Energi Pagi',
      'title_en': 'Morning Energy',
      'title_zh': '晨间能量',
      'title_ar': 'طاقة الصباح',
      'duration': '7 Menit',
      'imagePath': 'assets/images/Energi_Pagi.jpg',
      'color': Color(0xFFF39C12),
      'category': 'Fokus',
      'description':
          'Bangkitkan energi positif di pagi hari dengan meditasi yang membangkitkan semangat.',
      'description_en': 'Energize your morning with an uplifting meditation.',
      'description_zh': '通过提神的冥想唤起晨间的积极能量。',
      'description_ar': 'أيقظ طاقة الصباح بتأمل يرفع المعنويات.',
      'benefits': ['Energi meningkat', 'Semangat pagi', 'Motivasi tinggi'],
      'benefits_en': [
        'Increased energy',
        'Morning enthusiasm',
        'High motivation',
      ],
      'benefits_zh': ['能量提高', '晨间热情', '高度动力'],
      'benefits_ar': ['زيادة الطاقة', 'حماس الصباح', 'دافع عالي'],
      'audioUrl': 'audio/morning_energy.mp3',
    },
    {
      'title': 'Tidur Cepat',
      'title_en': 'Quick Sleep',
      'title_zh': '快速入睡',
      'title_ar': 'النوم السريع',
      'duration': '10 Menit',
      'imagePath': 'assets/images/Tidur_Cepat.webp',
      'color': Color(0xFF34495E),
      'category': 'Tidur',
      'description':
          'Meditasi singkat untuk membantu Anda tertidur dengan cepat dan nyenyak.',
      'description_en':
          'A short meditation to help you fall asleep quickly and deeply.',
      'description_zh': '帮助您快速且深度入睡的简短冥想。',
      'description_ar': 'تأمل قصير لمساعدتك على النوم بسرعة ونوم عميق.',
      'benefits': ['Tertidur cepat', 'Tidur berkualitas', 'Mimpi indah'],
      'benefits_en': ['Fall asleep fast', 'Quality sleep', 'Sweet dreams'],
      'benefits_zh': ['快速入睡', '高质量睡眠', '美好梦境'],
      'benefits_ar': ['النوم بسرعة', 'نوم ذو جودة', 'أحلام سعيدة'],
      'audioUrl': 'audio/quick_sleep.mp3',
    },
    {
      'title': 'Meditasi Gratitude',
      'title_en': 'Gratitude Meditation',
      'title_zh': '感恩冥想',
      'title_ar': 'تأمل الامتنان',
      'duration': '12 Menit',
      'imagePath': 'assets/images/Meditasi_Gratitude.jpg',
      'color': Color(0xFFE74C3C),
      'category': 'Semua',
      'description':
          'Latihan rasa syukur untuk meningkatkan kebahagiaan dan kepuasan hidup.',
      'description_en':
          'A gratitude practice to boost happiness and life satisfaction.',
      'description_zh': '练习感恩以提升幸福感和生活满足感。',
      'description_ar': 'تمرين الامتنان لزيادة السعادة والرضا عن الحياة.',
      'benefits': ['Rasa syukur', 'Kebahagiaan', 'Positif thinking'],
      'benefits_en': ['Gratitude', 'Happiness', 'Positive thinking'],
      'benefits_zh': ['感恩', '幸福', '积极思维'],
      'benefits_ar': ['الامتنان', 'السعادة', 'تفكير إيجابي'],
      'audioUrl': 'audio/gratitude.mp3',
    },
    {
      'title': 'Konsentrasi Belajar',
      'title_en': 'Study Concentration',
      'title_zh': '学习专注',
      'title_ar': 'تركيز الدراسة',
      'duration': '15 Menit',
      'imagePath': 'assets/images/Konsentrasi_Belajar.jpg',
      'color': Color(0xFF16A085),
      'category': 'Fokus',
      'description':
          'Meditasi untuk meningkatkan fokus dan daya ingat saat belajar atau bekerja.',
      'description_en':
          'Meditation to improve focus and memory while studying or working.',
      'description_zh': '在学习或工作时提高专注力和记忆力的冥想。',
      'description_ar': 'تأمل لتحسين التركيز والذاكرة أثناء الدراسة أو العمل.',
      'benefits': ['Fokus belajar', 'Daya ingat kuat', 'Efisiensi kerja'],
      'benefits_en': ['Study focus', 'Strong memory', 'Work efficiency'],
      'benefits_zh': ['学习专注', '记忆力强', '工作效率'],
      'benefits_ar': ['تركيز الدراسة', 'ذاكرة قوية', 'كفاءة العمل'],
      'audioUrl': 'audio/study_focus.mp3',
    },
    {
      'title': 'Relaksasi Mendalam',
      'title_en': 'Deep Relaxation',
      'title_zh': '深度放松',
      'title_ar': 'استرخاء عميق',
      'duration': '20 Menit',
      'imagePath': 'assets/images/Relaksasi_Mendalam.jpg',
      'color': Color(0xFF7D3C98),
      'category': 'Stres',
      'description':
          'Meditasi relaksasi mendalam untuk melepaskan ketegangan tubuh dan pikiran.',
      'description_en':
          'Deep relaxation meditation to release tension from body and mind.',
      'description_zh': '深度放松冥想，释放身心紧张。',
      'description_ar': 'تأمل استرخاء عميق لإزالة التوتر من الجسم والعقل.',
      'benefits': ['Relaksasi total', 'Ketegangan hilang', 'Damai'],
      'benefits_en': ['Total relaxation', 'Tension release', 'Peace'],
      'benefits_zh': ['完全放松', '释放紧张', '宁静'],
      'benefits_ar': ['استرخاء تام', 'إطلاق التوتر', 'سلام'],
      'audioUrl': 'audio/deep_relaxation.mp3',
    },
    {
      'title': 'Tidur Restoratif',
      'title_en': 'Restorative Sleep',
      'title_zh': '恢复性睡眠',
      'title_ar': 'نوم استشفائي',
      'duration': '18 Menit',
      'imagePath': 'assets/images/Tidur_Restoratif.jpg',
      'color': Color(0xFF1C2833),
      'category': 'Tidur',
      'description':
          'Meditasi untuk tidur yang memulihkan dan menyegarkan tubuh sepenuhnya.',
      'description_en':
          'Meditation for restorative sleep that refreshes the body fully.',
      'description_zh': '用于恢复性睡眠的冥想，使身体完全恢复。',
      'description_ar': 'تأمل لنوم استشفائي يجدد الجسم بالكامل.',
      'benefits': ['Pemulihan tubuh', 'Tidur nyenyak', 'Segar bangun'],
      'benefits_en': ['Body recovery', 'Deep sleep', 'Wake refreshed'],
      'benefits_zh': ['身体恢复', '深度睡眠', '醒来神清气爽'],
      'benefits_ar': ['استشفاء الجسم', 'نوم عميق', 'الاستيقاظ منتعش'],
      'audioUrl': 'audio/restorative_sleep.mp3',
    },
  ];

  List<Map<String, dynamic>> get filteredMeditations {
    final ls = Provider.of<LanguageService>(context);
    String code = ls.currentLanguageCode == 'system'
        ? ls.currentLocale.languageCode
        : ls.currentLanguageCode;
    final lang = code.startsWith('en')
        ? 'en'
        : code.startsWith('zh')
        ? 'zh'
        : code.startsWith('ar')
        ? 'ar'
        : 'id';

    return allMeditations.where((meditation) {
      final matchesCategory =
          selectedCategory == 'Semua' ||
          meditation['category'] == selectedCategory;
      final titleKey = 'title_$lang';
      final title =
          (meditation.containsKey(titleKey) && meditation[titleKey] != null)
          ? meditation[titleKey].toString()
          : meditation['title'].toString();
      final matchesSearch =
          searchQuery.isEmpty ||
          title.toLowerCase().contains(searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  Map<String, String> _L() {
    // listen to LanguageService so this widget rebuilds when language changes
    final ls = Provider.of<LanguageService>(context);
    String code = ls.currentLanguageCode == 'system'
        ? ls.currentLocale.languageCode
        : ls.currentLanguageCode;
    return {
      'title': code.startsWith('en')
          ? 'Meditations'
          : code.startsWith('zh')
          ? '冥想'
          : code.startsWith('ar')
          ? 'تأمل'
          : 'Meditasi',
      'search_hint': code.startsWith('en')
          ? 'Search meditations...'
          : code.startsWith('zh')
          ? '搜索冥想...'
          : code.startsWith('ar')
          ? 'ابحث عن التأملات...'
          : 'Cari meditasi...',
      'meditation_plural': code.startsWith('en')
          ? 'Meditations'
          : code.startsWith('zh')
          ? '冥想'
          : code.startsWith('ar')
          ? 'تأملات'
          : 'Meditasi',
      'cat_Semua': code.startsWith('en')
          ? 'All'
          : code.startsWith('zh')
          ? '全部'
          : code.startsWith('ar')
          ? 'الكل'
          : 'Semua',
      'cat_Tidur': code.startsWith('en')
          ? 'Sleep'
          : code.startsWith('zh')
          ? '睡眠'
          : code.startsWith('ar')
          ? 'نوم'
          : 'Tidur',
      'cat_Stres': code.startsWith('en')
          ? 'Stress'
          : code.startsWith('zh')
          ? '压力'
          : code.startsWith('ar')
          ? 'توتر'
          : 'Stres',
      'cat_Fokus': code.startsWith('en')
          ? 'Focus'
          : code.startsWith('zh')
          ? '专注'
          : code.startsWith('ar')
          ? 'تركيز'
          : 'Fokus',
      'minutes': code.startsWith('en')
          ? 'minutes'
          : code.startsWith('zh')
          ? '分钟'
          : code.startsWith('ar')
          ? 'دقائق'
          : 'Menit',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EFD0),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _L()['title']!,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Translate all',
                      onPressed: () async {
                        await _translateAllMeditions();
                      },
                      icon: const Icon(Icons.translate),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Search Bar
                Container(
                  height: 45,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8E4CC),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: Colors.black54, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: searchController,
                          onChanged: (value) {
                            setState(() {
                              searchQuery = value;
                            });
                          },
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black87,
                          ),
                          decoration: InputDecoration(
                            hintText: _L()['search_hint'],
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            hintStyle: const TextStyle(
                              color: Colors.black45,
                              fontSize: 13,
                            ),
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                            filled: false,
                          ),
                        ),
                      ),
                      if (searchQuery.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              searchController.clear();
                              searchQuery = '';
                            });
                          },
                          child: const Padding(
                            padding: EdgeInsets.only(left: 6),
                            child: Icon(
                              Icons.clear,
                              color: Colors.black54,
                              size: 18,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Category Filters
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildCategoryChip('Semua', display: _L()['cat_Semua']),
                      _buildCategoryChip('Tidur', display: _L()['cat_Tidur']),
                      _buildCategoryChip('Stres', display: _L()['cat_Stres']),
                      _buildCategoryChip('Fokus', display: _L()['cat_Fokus']),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Results count
                Text(
                  '${filteredMeditations.length} ${_L()['meditation_plural']}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),

                // Meditation Grid
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: filteredMeditations.length,
                  itemBuilder: (context, index) {
                    return _buildMeditationCard(filteredMeditations[index]);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String key, {String? display}) {
    final isSelected = selectedCategory == key;
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedCategory = key;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF6B9080) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? const Color(0xFF6B9080) : Colors.black12,
            ),
          ),
          child: Text(
            display ?? key,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black54,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMeditationCard(Map<String, dynamic> meditation) {
    String getLocalizedField(Map<String, dynamic> med, String base) {
      final ls = Provider.of<LanguageService>(context, listen: false);
      String code = ls.currentLanguageCode == 'system'
          ? ls.currentLocale.languageCode
          : ls.currentLanguageCode;
      String lang = code.startsWith('en')
          ? 'en'
          : code.startsWith('zh')
          ? 'zh'
          : code.startsWith('ar')
          ? 'ar'
          : 'id';
      final key = '${base}_$lang';
      if (med.containsKey(key) &&
          med[key] != null &&
          med[key].toString().isNotEmpty) {
        return med[key].toString();
      }
      if (med.containsKey(base) && med[base] != null) {
        return med[base].toString();
      }
      return '';
    }

    void ensureLocalized(Map<String, dynamic> med) {
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
        TranslationService.translate(
          med['description'].toString(),
          target,
        ).then((t) {
          med[descKey] = t;
          if (mounted) setState(() {});
        });
      }
      if ((!med.containsKey(benefitsKey) || med[benefitsKey] == null) &&
          med.containsKey('benefits') &&
          med['benefits'] is List) {
        final List benefits = med['benefits'] as List;
        Future.wait(
          benefits.map(
            (b) => TranslationService.translate(b.toString(), target),
          ),
        ).then((translated) {
          med[benefitsKey] = translated;
          if (mounted) setState(() {});
        });
      }
    }

    ensureLocalized(meditation);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                MeditationDetailScreen(meditation: meditation),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              Positioned.fill(
                child: (() {
                  final imagePath = meditation['imagePath'] as String?;
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
                            ),
                          ),
                        ),
                      );
                    },
                  );
                })(),
              ),

              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        getLocalizedField(meditation, 'title'),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        // Parse minutes from duration like '10 Menit' and localize unit
                        (() {
                          final L = _L();
                          final dur = meditation['duration']?.toString() ?? '';
                          final match = RegExp(r"(\d+)").firstMatch(dur);
                          if (match != null) {
                            final mins = match.group(1);
                            return '$mins ${L['minutes']!}';
                          }
                          return dur;
                        })(),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _translateAllMeditions() async {
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

    for (final med in allMeditations) {
      final title = med['title']?.toString() ?? '';
      final desc = med['description']?.toString() ?? '';
      if (title.isNotEmpty) {
        final t = await TranslationService.translate(title, target);
        med['title_$target'] = t;
      }
      if (desc.isNotEmpty) {
        final d = await TranslationService.translate(desc, target);
        med['description_$target'] = d;
      }
      if (med['benefits'] is List) {
        final List benefits = med['benefits'] as List;
        final List<String> translated = [];
        for (final b in benefits) {
          final tb = await TranslationService.translate(b.toString(), target);
          translated.add(tb);
        }
        med['benefits_$target'] = translated;
      }
    }
    setState(() {});
  }
}
