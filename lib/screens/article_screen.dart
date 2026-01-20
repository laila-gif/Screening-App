import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/language_service.dart';
import 'article_detail_screen.dart';

class ArticleScreen extends StatefulWidget {
  const ArticleScreen({super.key});

  @override
  State<ArticleScreen> createState() => _ArticleScreenState();
}

class _ArticleScreenState extends State<ArticleScreen> {
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  final Map<String, dynamic> featuredArticle = {
    'title': '5 Cara Mengelola Stres di Tempat Kerja',
    'title_en': '5 Ways to Manage Work Stress',
    'title_zh': '在职场管理压力的5种方法',
    'title_ar': '5 طرق لإدارة التوتر في العمل',
    'description': 'Temukan strategi efektif untuk menjaga ketenangan Anda...',
    'description_en': 'Find effective strategies to keep your calm...',
    'description_zh': '找到有效策略以保持冷静...',
    'description_ar': 'اكتشف استراتيجيات فعالة للحفاظ على هدوئك...',
    'icon': Icons.work,
    'color': Color(0xFF4A90A4),
    'imagePath': 'assets/images/meditasi_stress_tempat_kerja.jpg',
    'content': '''
  Stres di tempat kerja adalah hal yang umum terjadi. Tuntutan pekerjaan, tenggat waktu yang ketat, dan dinamika interpersonal dapat memicu tekanan. Namun, ada strategi efektif untuk mengelolanya.
  (Konten artikel Anda di sini...)
  ''',
    'content_en': '''
  Workplace stress is common. Job demands, tight deadlines, and interpersonal dynamics can create pressure. Here are effective strategies to manage it.
  (Your article content here...)
  ''',
    'content_zh': '''
  职场压力很常见。工作要求、紧迫的截止日期和人际关系动态可能导致压力。以下是有效的管理策略。
  （在此处填写文章内容...）
  ''',
    'content_ar': '''
  الضغط في مكان العمل أمر شائع. متطلبات الوظيفة والمواعيد النهائية الضيقة والديناميكيات بين الأشخاص يمكن أن تخلق ضغطًا. فيما يلي استراتيجيات فعالة لإدارته.
  (أضف محتوى المقال هنا...)
  ''',
  };

  final List<Map<String, dynamic>> otherArticles = [
    {
      'title': 'Mengenal Mindfulness',
      'title_en': 'Understanding Mindfulness',
      'title_zh': '认识正念',
      'title_ar': 'معرفة اليقظة الذهنية',
      'description': 'Latihan sederhana untuk memulai hari dengan tenang.',
      'description_en': 'Simple practices to start the day calmly.',
      'description_zh': '开始一天的简单练习，带来平静。',
      'description_ar': 'ممارسات بسيطة لبدء اليوم بهدوء.',
      'icon': Icons.spa,
      'color': const Color(0xFF8FAD88),
      'imagePath': 'assets/images/Mengenal_Mindfulness.jpg',
      'content':
          'Mindfulness adalah praktik menyadari momen saat ini tanpa penilaian...',
      'content_en':
          'Mindfulness is the practice of noticing the present moment without judgment...',
      'content_zh': '正念是观察当下而不加评判的练习...',
      'content_ar': 'اليقظة الذهنية هي ممارسة ملاحظة اللحظة الحالية دون حكم...',
    },
    {
      'title': 'Manfaat Menulis Jurnal',
      'title_en': 'Benefits of Journaling',
      'title_zh': '写日记的好处',
      'title_ar': 'فوائد كتابة اليوميات',
      'description': 'Ekspresikan perasaan dan temukan pola pikir positif.',
      'description_en': 'Express feelings and find positive thought patterns.',
      'description_zh': '表达情感并发现积极的思维模式。',
      'description_ar': 'عبر عن مشاعرك وابحث عن أنماط تفكير إيجابية.',
      'icon': Icons.book,
      'color': const Color(0xFFD4A574),
      'imagePath': 'assets/images/Menulis_Jurnal.jpg',
      'content':
          'Menulis jurnal setiap hari dapat menjadi alat terapi yang kuat...',
      'content_en': 'Daily journaling can be a powerful therapeutic tool...',
      'content_zh': '每天写日记可以成为强大的治疗工具...',
      'content_ar': 'يمكن أن تكون كتابة اليوميات اليومية أداة علاجية قوية...',
    },
    {
      'title': 'Membangun Hubungan Sehat',
      'title_en': 'Building Healthy Relationships',
      'title_zh': '建立健康关系',
      'title_ar': 'بناء علاقات صحية',
      'description': 'Tips komunikasi untuk koneksi yang lebih dalam.',
      'description_en': 'Communication tips for deeper connections.',
      'description_zh': '更深层次连接的沟通技巧。',
      'description_ar': 'نصائح تواصل لروابط أعمق.',
      'icon': Icons.people,
      'color': const Color(0xFF8B9D77),
      'imagePath': 'assets/images/Hubungan_Sehat.jpg',
      'content':
          'Hubungan yang sehat dibangun di atas komunikasi yang jujur dan empati...',
      'content_en':
          'Healthy relationships are built on honest communication and empathy...',
      'content_zh': '健康的关系建立在诚实沟通和同理心之上...',
      'content_ar': 'العلاقات الصحية تُبنى على التواصل الصادق والتعاطف...',
    },
    {
      'title': 'Mengatasi Kecemasan Sosial',
      'title_en': 'Overcoming Social Anxiety',
      'title_zh': '克服社交焦虑',
      'title_ar': 'التغلب على القلق الاجتماعي',
      'description': 'Langkah kecil untuk merasa lebih nyaman di keramaian.',
      'description_en': 'Small steps to feel more comfortable in crowds.',
      'description_zh': '在拥挤人群中感到更舒适的小步骤。',
      'description_ar': 'خطوات صغيرة للشعور براحة أكبر في التجمعات.',
      'icon': Icons.forum,
      'color': const Color(0xFF7D3C98),
      'imagePath': 'assets/images/Kecemasan_Sosial.jpg',
      'content':
          'Kecemasan sosial lebih dari sekadar rasa malu. Ini adalah ketakutan yang intens...',
      'content_en':
          'Social anxiety is more than shyness; it is an intense fear...',
      'content_zh': '社交焦虑不仅仅是害羞；它是一种强烈的恐惧...',
      'content_ar': 'القلق الاجتماعي أكثر من خجل؛ إنه خوف شديد...',
    },
    {
      'title': 'Pentingnya Tidur Berkualitas',
      'title_en': 'The Importance of Quality Sleep',
      'title_zh': '优质睡眠的重要性',
      'title_ar': 'أهمية النوم الجيد',
      'description': 'Bagaimana tidur memengaruhi kesehatan mental Anda.',
      'description_en': 'How sleep affects your mental health.',
      'description_zh': '睡眠如何影响你的心理健康。',
      'description_ar': 'كيف يؤثر النوم على صحتك العقلية.',
      'icon': Icons.bedtime,
      'color': const Color(0xFF34495E),
      'imagePath': 'assets/images/Tidur_Berkualitas.webp',
      'content':
          'Tidur bukan hanya istirahat fisik. Selama tidur, otak Anda memproses emosi...',
      'content_en':
          'Sleep is not just physical rest. During sleep your brain processes emotions...',
      'content_zh': '睡眠不仅仅是身体休息。睡眠期间，大脑会处理情绪...',
      'content_ar':
          'النوم ليس مجرد راحة جسدية. أثناء النوم، يعالج دماغك المشاعر...',
    },
    {
      'title': 'Meditasi emang berpengaruh ya ?',
      'title_en': 'Does Meditation Really Help?',
      'title_zh': '冥想真的有用吗？',
      'title_ar': 'هل للتأمل تأثير فعلاً؟',
      'description': 'Menyelami manfaat meditasi untuk kesehatan mental.',
      'description_en': 'Exploring meditation benefits for mental health.',
      'description_zh': '探索冥想对心理健康的益处。',
      'description_ar': 'استكشاف فوائد التأمل للصحة العقلية.',
      'icon': Icons.bedtime,
      'color': const Color(0xFF34495E),
      'imagePath': 'assets/images/Meditasi_emang_berpengaruh.webp',
      'content':
          'Meditasi adalah praktik yang telah digunakan selama ribuan tahun untuk meningkatkan kesehatan mental dan fisik. Dengan meditasi, kita dapat mengurangi stres, meningkatkan konsentrasi, dan meningkatkan kesadaran diri. Berikut beberapa manfaat meditasi untuk kesehatan mental',
      'content_en':
          'Meditation has been used for thousands of years to improve mental and physical health...',
      'content_zh': '冥想已被使用数千年以改善心理和身体健康...',
      'content_ar':
          'استخدم التأمل لآلاف السنين لتحسين الصحة العقلية والجسدية...',
    },
    {
      'title': 'Lakukan Meditasi Sebelum Belajar Agar Bisa Meningkatkan Fokus',
      'title_en': 'Meditate Before Studying To Improve Focus',
      'title_zh': '学习前冥想以提高专注力',
      'title_ar': 'تأمل قبل الدراسة لتحسين التركيز',
      'description':
          'Bagaimana meditasi dapat membantu meningkatkan fokus saat belajar.',
      'description_en': 'How meditation can help improve focus while studying.',
      'description_zh': '冥想如何帮助在学习时提高专注力。',
      'description_ar': 'كيف يساعد التأمل على تحسين التركيز أثناء الدراسة.',
      'icon': Icons.bedtime,
      'color': const Color(0xFF34495E),
      'imagePath': 'assets/images/Lakukan_Meditasi_Sebelum_Belajar.webp',
      'content':
          'Meditasi sebelum belajar dapat membantu menenangkan pikiran dan meningkatkan konsentrasi. Dengan meluangkan waktu sejenak untuk bermeditasi, Anda dapat mempersiapkan diri secara mental untuk sesi belajar yang lebih produktif.',
      'content_en':
          'Meditating before study can calm the mind and boost concentration for more productive sessions.',
      'content_zh': '在学习前冥想可以平静心智并提高专注力，从而更高效学习。',
      'content_ar':
          'التأمل قبل الدراسة يمكن أن يهدئ العقل ويعزز التركيز لجلسات أكثر إنتاجية.',
    },
    {
      'title':
          'Pengaruh Meditasi Terhadap Penyembuhan Penyakit: Menjelajahi Kekuatan Pikiran dan Tubuh',
      'title_en':
          'The Effect of Meditation on Healing: Exploring Mind-Body Power',
      'title_zh': '冥想对治愈的影响：探索身心力量',
      'title_ar': 'تأثير التأمل على الشفاء: استكشاف قوة العقل والجسد',
      'description': 'Bagaimana meditasi dapat memengaruhi proses penyembuhan.',
      'description_en': 'How meditation can influence the healing process.',
      'description_zh': '冥想如何影响治愈过程。',
      'description_ar': 'كيف يمكن أن يؤثر التأمل على عملية الشفاء.',
      'icon': Icons.bedtime,
      'color': const Color(0xFF34495E),
      'imagePath': 'assets/images/Meditasi_Penyembuhan_Penyakit.jpg',
      'content':
          'Meditasi telah terbukti memiliki dampak positif pada kesehatan fisik dan mental. Dengan mengurangi stres dan meningkatkan relaksasi, meditasi dapat mempercepat proses penyembuhan dan meningkatkan kualitas hidup secara keseluruhan.',
      'content_en':
          'Meditation has been shown to positively impact physical and mental health. By reducing stress and increasing relaxation, it can speed healing and improve quality of life.',
      'content_zh': '研究表明，冥想对身心健康具有积极影响。通过减轻压力并增加放松，它可以加快康复并提高生活质量。',
      'content_ar':
          'أظهرت الدراسات أن التأمل يؤثر إيجابياً على الصحة الجسدية والعقلية. من خلال تقليل التوتر وزيادة الاسترخاء، يمكن أن يسرع الشفاء ويحسن جودة الحياة.',
    },
  ];

  List<Map<String, dynamic>> get filteredOtherArticles {
    if (searchQuery.isEmpty) {
      return otherArticles;
    }
    // fallback: filter by base title if localization not applied
    return otherArticles.where((article) {
      final titleLower = (article['title'] as String).toLowerCase();
      final searchLower = searchQuery.toLowerCase();
      return titleLower.contains(searchLower);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageService>(
      builder: (context, languageService, child) {
        String code = languageService.currentLanguageCode;
        if (code == 'system') code = languageService.currentLocale.languageCode;
        String langShort = 'id';
        if (code.startsWith('en')) {
          langShort = 'en';
        } else if (code.startsWith('zh')) {
          langShort = 'zh';
        } else if (code.startsWith('ar')) {
          langShort = 'ar';
        } else if (code.startsWith('id')) {
          langShort = 'id';
        }

        String headerTitle = code.startsWith('en')
            ? 'Articles'
            : code.startsWith('zh')
            ? '文章'
            : code.startsWith('ar')
            ? 'مقالات'
            : 'Artikel';

        String searchHint = code.startsWith('en')
            ? 'Search articles...'
            : code.startsWith('zh')
            ? '搜索文章...'
            : code.startsWith('ar')
            ? 'ابحث في المقالات...'
            : 'Cari artikel...';

        String sectionTitle = code.startsWith('en')
            ? 'Other Reads'
            : code.startsWith('zh')
            ? '其他阅读'
            : code.startsWith('ar')
            ? 'قراءات أخرى'
            : 'Bacaan Lainnya';

        String featuredLabel = code.startsWith('en')
            ? 'Featured'
            : code.startsWith('zh')
            ? '推荐'
            : code.startsWith('ar')
            ? 'مميز'
            : 'Unggulan';

        // helper to get localized field like title_en, content_zh, etc.
        String localizedField(Map<String, dynamic> article, String base) {
          final key = '${base}_$langShort';
          if (article.containsKey(key) &&
              (article[key] is String) &&
              (article[key] as String).isNotEmpty) {
            return article[key] as String;
          }
          return (article[base] is String) ? (article[base] as String) : '';
        }

        List<Map<String, dynamic>> filtered = (searchQuery.isEmpty)
            ? otherArticles
            : otherArticles.where((article) {
                final t = localizedField(article, 'title').toLowerCase();
                final s = searchQuery.toLowerCase();
                return t.contains(s);
              }).toList();

        return Scaffold(
          backgroundColor: const Color(0xFFF5EFD0),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                    child: Text(
                      headerTitle,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),

                  // Search Bar - TANPA BORDER
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Container(
                      height: 45,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8E4CC),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.search,
                            color: Colors.black54,
                            size: 18,
                          ),
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
                                hintText: searchHint,
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                hintStyle: TextStyle(
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
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Kartu Unggulan
                        _buildArticleBannerCard(
                          context,
                          featuredArticle,
                          isFeatured: true,
                          langShort: langShort,
                          featuredLabel: featuredLabel,
                        ),

                        // Section Title
                        Padding(
                          padding: const EdgeInsets.only(top: 24, bottom: 16),
                          child: Text(
                            sectionTitle,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),

                        // Daftar Artikel
                        Column(
                          children: filtered.map((article) {
                            return _buildArticleBannerCard(
                              context,
                              article,
                              isFeatured: false,
                              langShort: langShort,
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildArticleBannerCard(
    BuildContext context,
    Map<String, dynamic> article, {
    bool isFeatured = false,
    String langShort = 'id',
    String featuredLabel = 'Unggulan',
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ArticleDetailScreen(article: article),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 200,
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
                  child: Image.asset(
                    article['imagePath'],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: Icon(
                          Icons.image_not_supported,
                          color: Colors.grey[600],
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.8),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isFeatured)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              featuredLabel,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        if (isFeatured) const SizedBox(height: 8),
                        Text(
                          (article['title_$langShort'] is String &&
                                  (article['title_$langShort'] as String)
                                      .isNotEmpty)
                              ? article['title_$langShort'] as String
                              : article['title'] as String,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          (article['description_$langShort'] is String &&
                                  (article['description_$langShort'] as String)
                                      .isNotEmpty)
                              ? article['description_$langShort'] as String
                              : article['description'] as String,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.white70,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
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
