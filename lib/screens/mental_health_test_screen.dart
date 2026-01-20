import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/language_service.dart';
import 'test_result_screen.dart';

class MentalHealthTestScreen extends StatefulWidget {
  const MentalHealthTestScreen({Key? key}) : super(key: key);

  @override
  State<MentalHealthTestScreen> createState() => _MentalHealthTestScreenState();
}

class _MentalHealthTestScreenState extends State<MentalHealthTestScreen> {
  int currentQuestion = 0;
  Map<int, int> answers = {};

  final List<Map<String, dynamic>> baseQuestions = [
    {
      'question':
          'Seberapa sering Anda merasa sedih atau murung dalam 2 minggu terakhir?',
      'options': [
        'Tidak pernah',
        'Beberapa hari',
        'Lebih dari seminggu',
        'Hampir setiap hari',
      ],
    },
    {
      'question':
          'Apakah Anda mengalami kesulitan tidur atau tidur berlebihan?',
      'options': ['Tidak', 'Kadang-kadang', 'Sering', 'Sangat sering'],
    },
    {
      'question': 'Seberapa sering Anda merasa lelah atau kehilangan energi?',
      'options': ['Jarang', 'Kadang-kadang', 'Sering', 'Hampir setiap hari'],
    },
    {
      'question':
          'Apakah Anda kehilangan minat pada aktivitas yang biasanya Anda nikmati?',
      'options': [
        'Tidak sama sekali',
        'Sedikit',
        'Cukup banyak',
        'Sangat banyak',
      ],
    },
    {
      'question': 'Seberapa sering Anda merasa cemas atau khawatir berlebihan?',
      'options': [
        'Tidak pernah',
        'Beberapa kali',
        'Sering',
        'Hampir setiap saat',
      ],
    },
    {
      'question':
          'Apakah Anda mengalami kesulitan berkonsentrasi atau membuat keputusan?',
      'options': ['Tidak', 'Kadang-kadang', 'Sering', 'Sangat sering'],
    },
    {
      'question': 'Seberapa sering Anda merasa tidak berharga atau bersalah?',
      'options': ['Tidak pernah', 'Jarang', 'Kadang-kadang', 'Sering'],
    },
    {
      'question':
          'Apakah Anda mengalami perubahan nafsu makan yang signifikan?',
      'options': [
        'Tidak',
        'Sedikit perubahan',
        'Perubahan sedang',
        'Perubahan drastis',
      ],
    },
    {
      'question':
          'Seberapa sering Anda merasa tegang atau gelisah secara fisik?',
      'options': ['Tidak pernah', 'Kadang-kadang', 'Sering', 'Hampir selalu'],
    },
    {
      'question':
          'Apakah Anda pernah berpikir untuk menyakiti diri sendiri atau lebih baik tidak ada?',
      'options': ['Tidak pernah', 'Sangat jarang', 'Kadang-kadang', 'Sering'],
    },
  ];

  List<Map<String, dynamic>> _localizedQuestions() {
    final ls = Provider.of<LanguageService>(context, listen: false);
    String code = ls.currentLanguageCode == 'system'
        ? ls.currentLocale.languageCode
        : ls.currentLanguageCode;

    if (code.startsWith('en')) {
      return [
        {
          'question':
              'How often have you felt sad or down in the past 2 weeks?',
          'options': [
            'Not at all',
            'Several days',
            'More than a week',
            'Nearly every day',
          ],
        },
        {
          'question':
              'Have you experienced trouble sleeping or sleeping too much?',
          'options': ['No', 'Sometimes', 'Often', 'Very often'],
        },
        {
          'question': 'How often have you felt tired or had little energy?',
          'options': ['Rarely', 'Sometimes', 'Often', 'Nearly every day'],
        },
        {
          'question': 'Have you lost interest in activities you usually enjoy?',
          'options': ['Not at all', 'A little', 'Quite a bit', 'A lot'],
        },
        {
          'question': 'How often have you felt anxious or excessively worried?',
          'options': ['Never', 'A few times', 'Often', 'Almost always'],
        },
        {
          'question':
              'Do you have difficulty concentrating or making decisions?',
          'options': ['No', 'Sometimes', 'Often', 'Very often'],
        },
        {
          'question': 'How often have you felt worthless or guilty?',
          'options': ['Never', 'Rarely', 'Sometimes', 'Often'],
        },
        {
          'question': 'Have you experienced significant changes in appetite?',
          'options': [
            'No',
            'Slight changes',
            'Moderate changes',
            'Drastic changes',
          ],
        },
        {
          'question': 'How often have you felt tense or physically restless?',
          'options': ['Never', 'Sometimes', 'Often', 'Almost always'],
        },
        {
          'question':
              "Have you ever thought about harming yourself or that you'd be better off dead?",
          'options': ['Never', 'Very rarely', 'Sometimes', 'Often'],
        },
      ];
    }

    if (code.startsWith('zh')) {
      return [
        {
          'question': '在过去两周里，您多经常感到悲伤或沮丧？',
          'options': ['从不', '几天', '超过一周', '几乎每天'],
        },
        {
          'question': '您是否有睡眠困难或睡眠过多？',
          'options': ['没有', '有时', '经常', '非常经常'],
        },
        {
          'question': '您多经常感到疲倦或精力不足？',
          'options': ['很少', '有时', '经常', '几乎每天'],
        },
        {
          'question': '您是否对通常喜欢的活动失去兴趣？',
          'options': ['完全没有', '有点', '相当多', '很多'],
        },
        {
          'question': '您多经常感到焦虑或过度担心？',
          'options': ['从不', '几次', '经常', '几乎总是'],
        },
        {
          'question': '您是否难以集中注意力或做决定？',
          'options': ['没有', '有时', '经常', '非常经常'],
        },
        {
          'question': '您多经常感到没有价值或内疚？',
          'options': ['从不', '很少', '有时', '经常'],
        },
        {
          'question': '您是否经历了明显的食欲变化？',
          'options': ['没有', '轻微变化', '中度变化', '剧烈变化'],
        },
        {
          'question': '您多经常感到紧张或身体不安？',
          'options': ['从不', '有时', '经常', '几乎总是'],
        },
        {
          'question': '您是否曾想过伤害自己或认为没有您会更好？',
          'options': ['从不', '很少', '有时', '经常'],
        },
      ];
    }

    if (code.startsWith('ar')) {
      return [
        {
          'question': 'كم مرة شعرت بالحزن أو الكآبة خلال الأسبوعين الماضيين؟',
          'options': ['أبداً', 'عدة أيام', 'أكثر من أسبوع', 'تقريبًا كل يوم'],
        },
        {
          'question': 'هل تواجه صعوبة في النوم أو فرط النوم؟',
          'options': ['لا', 'أحيانًا', 'غالبًا', 'كثيرًا'],
        },
        {
          'question': 'كم مرة شعرت بالتعب أو فقدان الطاقة؟',
          'options': ['نادرًا', 'أحيانًا', 'غالبًا', 'تقريبًا كل يوم'],
        },
        {
          'question': 'هل فقدت الاهتمام بالأنشطة التي تستمتع بها عادة؟',
          'options': ['لا على الإطلاق', 'قليلاً', 'إلى حد كبير', 'كثيرًا'],
        },
        {
          'question': 'كم مرة شعرت بالقلق أو الخوف المفرط؟',
          'options': ['لا أبدًا', 'بضع مرات', 'غالبًا', 'تقريبًا دائمًا'],
        },
        {
          'question': 'هل تواجه صعوبة في التركيز أو اتخاذ القرارات؟',
          'options': ['لا', 'أحيانًا', 'غالبًا', 'كثيرًا'],
        },
        {
          'question': 'كم مرة شعرت بأنك بلا قيمة أو تشعر بالذنب؟',
          'options': ['لا أبدًا', 'نادرًا', 'أحيانًا', 'غالبًا'],
        },
        {
          'question': 'هل لاحظت تغييرات كبيرة في الشهية؟',
          'options': ['لا', 'تغييرات بسيطة', 'تغييرات متوسطة', 'تغييرات كبيرة'],
        },
        {
          'question': 'كم مرة شعرت بالتوتر أو الأرق الجسدي؟',
          'options': ['لا أبدًا', 'أحيانًا', 'غالبًا', 'تقريبًا دائمًا'],
        },
        {
          'question':
              'هل فكرت يومًا في إيذاء نفسك أو أن يكون من الأفضل لو لم تكن موجودًا؟',
          'options': ['لا أبدًا', 'نادراً جداً', 'أحيانًا', 'غالبًا'],
        },
      ];
    }

    return baseQuestions;
  }

  List<Map<String, dynamic>> get questions => _localizedQuestions();

  Map<String, String> _L() {
    final ls = Provider.of<LanguageService>(context, listen: false);
    String code = ls.currentLanguageCode == 'system'
        ? ls.currentLocale.languageCode
        : ls.currentLanguageCode;
    return {
      'screen_title': code.startsWith('en')
          ? 'Mental Health Test'
          : code.startsWith('zh')
          ? '心理健康测试'
          : code.startsWith('ar')
          ? 'اختبار الصحة العقلية'
          : 'Tes Kesehatan Mental',
      'question_word': code.startsWith('en')
          ? 'Question'
          : code.startsWith('zh')
          ? '问题'
          : code.startsWith('ar')
          ? 'السؤال'
          : 'Pertanyaan',
      'of': code.startsWith('en')
          ? 'of'
          : code.startsWith('zh')
          ? '共'
          : code.startsWith('ar')
          ? 'من'
          : 'dari',
      'back': code.startsWith('en')
          ? 'Back'
          : code.startsWith('zh')
          ? '返回'
          : code.startsWith('ar')
          ? 'عودة'
          : 'Kembali',
      'next': code.startsWith('en')
          ? 'Next'
          : code.startsWith('zh')
          ? '下一步'
          : code.startsWith('ar')
          ? 'التالي'
          : 'Lanjut',
      'finish': code.startsWith('en')
          ? 'Finish'
          : code.startsWith('zh')
          ? '完成'
          : code.startsWith('ar')
          ? 'إنهاء'
          : 'Selesai',
    };
  }

  void _selectAnswer(int optionIndex) {
    setState(() {
      answers[currentQuestion] = optionIndex;
    });
  }

  void _nextQuestion() {
    if (currentQuestion < questions.length - 1) {
      setState(() {
        currentQuestion++;
      });
    } else {
      _submitTest();
    }
  }

  void _previousQuestion() {
    if (currentQuestion > 0) {
      setState(() {
        currentQuestion--;
      });
    }
  }

  void _submitTest() {
    int totalScore = 0;
    answers.forEach((key, value) {
      totalScore += value;
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            TestResultScreen(score: totalScore, maxScore: questions.length * 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLastQuestion = currentQuestion == questions.length - 1;
    final hasAnswer = answers.containsKey(currentQuestion);

    return Scaffold(
      backgroundColor: const Color(0xFFE8E8E8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2937)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _L()['screen_title']!,
          style: const TextStyle(
            color: Color(0xFF1F2937),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // Progress bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_L()['question_word']} ${currentQuestion + 1} ${_L()['of']} ${questions.length}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${((currentQuestion + 1) / questions.length * 100).toInt()}%',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF2D4A3E),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: (currentQuestion + 1) / questions.length,
                    backgroundColor: const Color(0xFFE5E7EB),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF2D4A3E),
                    ),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Question card
                  Container(
                    width: double.infinity,
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
                    child: Text(
                      questions[currentQuestion]['question'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Options
                  ...List.generate(
                    questions[currentQuestion]['options'].length,
                    (index) {
                      final isSelected = answers[currentQuestion] == index;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GestureDetector(
                          onTap: () => _selectAnswer(index),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFFE6E0F8)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF2D4A3E)
                                    : const Color(0xFFE5E7EB),
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected
                                          ? const Color(0xFF2D4A3E)
                                          : const Color(0xFFE5E7EB),
                                      width: 2,
                                    ),
                                    color: isSelected
                                        ? const Color(0xFF2D4A3E)
                                        : Colors.transparent,
                                  ),
                                  child: isSelected
                                      ? const Icon(
                                          Icons.check,
                                          size: 16,
                                          color: Colors.white,
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    questions[currentQuestion]['options'][index],
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: isSelected
                                          ? const Color(0xFF1F2937)
                                          : const Color(0xFF6B7280),
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // Navigation buttons
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                if (currentQuestion > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _previousQuestion,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF2D4A3E),
                        side: const BorderSide(color: Color(0xFF2D4A3E)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        _L()['back']!,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                if (currentQuestion > 0) const SizedBox(width: 12),
                Expanded(
                  flex: currentQuestion > 0 ? 1 : 1,
                  child: ElevatedButton(
                    onPressed: hasAnswer ? _nextQuestion : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2D4A3E),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFFE5E7EB),
                      disabledForegroundColor: const Color(0xFF9CA3AF),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      isLastQuestion ? _L()['finish']! : _L()['next']!,
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
        ],
      ),
    );
  }
}
