import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:provider/provider.dart';

import '../services/language_service.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({Key? key}) : super(key: key);

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  List<Map<String, dynamic>> journals = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadJournals();
  }

  Map<String, String> _L() {
    final ls = Provider.of<LanguageService>(context, listen: false);
    String code = ls.currentLanguageCode == 'system'
        ? ls.currentLocale.languageCode
        : ls.currentLanguageCode;
    return {
      'app_title': code.startsWith('en')
          ? 'Journal'
          : code.startsWith('zh')
          ? '日记'
          : code.startsWith('ar')
          ? 'مذكرات يومية'
          : 'Jurnal Harian',
      'new_journal': code.startsWith('en')
          ? 'Write New Journal'
          : code.startsWith('zh')
          ? '写新日记'
          : code.startsWith('ar')
          ? 'اكتب مذكّرة جديدة'
          : 'Tulis Jurnal Baru',
      'saved_snack': code.startsWith('en')
          ? 'Journal saved! 🎉'
          : code.startsWith('zh')
          ? '日记已保存！🎉'
          : code.startsWith('ar')
          ? 'تم حفظ المذكرة! 🎉'
          : 'Jurnal berhasil disimpan! 🎉',
      'no_journal_title': code.startsWith('en')
          ? 'No Journals Yet'
          : code.startsWith('zh')
          ? '还没有日记'
          : code.startsWith('ar')
          ? 'لا توجد مذكرات بعد'
          : 'Belum Ada Jurnal',
      'no_journal_sub': code.startsWith('en')
          ? 'Start writing your feelings and thoughts today. Journaling can help you understand emotions and improve mental health.'
          : code.startsWith('zh')
          ? '开始书写你的感受和想法。写日记有助于理解情绪并改善心理健康。'
          : code.startsWith('ar')
          ? 'ابدأ بكتابة مشاعرك وأفكارك اليوم. يمكن للمذكرة أن تساعدك على فهم العواطف وتحسين الصحة العقلية.'
          : 'Mulai tulis perasaan dan pikiran Anda hari ini. Menulis jurnal dapat membantu Anda memahami emosi dan meningkatkan kesehatan mental.',
      'write_journal_title': code.startsWith('en')
          ? 'Write Journal'
          : code.startsWith('zh')
          ? '写日记'
          : code.startsWith('ar')
          ? 'اكتب مذكّرة'
          : 'Tulis Jurnal',
      'hint_title': code.startsWith('en')
          ? 'Journal title...'
          : code.startsWith('zh')
          ? '日记标题...'
          : code.startsWith('ar')
          ? 'عنوان المذكرة...'
          : 'Judul jurnal...',
      'hint_content': code.startsWith('en')
          ? 'Write your feelings...'
          : code.startsWith('zh')
          ? '写下你的感受...'
          : code.startsWith('ar')
          ? 'اكتب مشاعرك...'
          : 'Tulis perasaanmu...',
      'title_required': code.startsWith('en')
          ? 'Title cannot be empty'
          : code.startsWith('zh')
          ? '标题不能为空'
          : code.startsWith('ar')
          ? 'لا يمكن ترك العنوان فارغًا'
          : 'Judul tidak boleh kosong',
      'content_required': code.startsWith('en')
          ? 'Content cannot be empty'
          : code.startsWith('zh')
          ? '内容不能为空'
          : code.startsWith('ar')
          ? 'لا يمكن ترك المحتوى فارغًا'
          : 'Konten tidak boleh kosong',
      'discard_title': code.startsWith('en')
          ? 'Discard Journal?'
          : code.startsWith('zh')
          ? '放弃日记？'
          : code.startsWith('ar')
          ? 'إلغاء المذكرة؟'
          : 'Buang Jurnal?',
      'discard_sub': code.startsWith('en')
          ? 'Unsaved journal will be lost. Are you sure?'
          : code.startsWith('zh')
          ? '未保存的日记将丢失。确定要退出吗？'
          : code.startsWith('ar')
          ? 'سيتم فقدان المذكرة غير المحفوظة. هل أنت متأكد؟'
          : 'Jurnal yang belum disimpan akan hilang. Yakin ingin keluar?',
      'cancel': code.startsWith('en')
          ? 'Cancel'
          : code.startsWith('zh')
          ? '取消'
          : code.startsWith('ar')
          ? 'إلغاء'
          : 'Batal',
      'discard': code.startsWith('en')
          ? 'Discard'
          : code.startsWith('zh')
          ? '放弃'
          : code.startsWith('ar')
          ? 'تخلص'
          : 'Buang',
      'saved_update': code.startsWith('en')
          ? 'Journal updated! ✓'
          : code.startsWith('zh')
          ? '日记已更新！✓'
          : code.startsWith('ar')
          ? 'تم تحديث المذكرة! ✓'
          : 'Jurnal berhasil diperbarui! ✓',
      'deleted': code.startsWith('en')
          ? 'Journal deleted'
          : code.startsWith('zh')
          ? '日记已删除'
          : code.startsWith('ar')
          ? 'تم حذف المذكرة'
          : 'Jurnal berhasil dihapus',
      'delete_confirm_title': code.startsWith('en')
          ? 'Delete Journal?'
          : code.startsWith('zh')
          ? '删除日记？'
          : code.startsWith('ar')
          ? 'حذف المذكرة؟'
          : 'Hapus Jurnal?',
      'delete_confirm_sub': code.startsWith('en')
          ? 'Deleted journals cannot be recovered. Are you sure?'
          : code.startsWith('zh')
          ? '删除的日记无法恢复。确定要删除吗？'
          : code.startsWith('ar')
          ? 'لا يمكن استعادة المذكرات المحذوفة. هل أنت متأكد؟'
          : 'Jurnal yang dihapus tidak dapat dikembalikan. Yakin ingin menghapus?',
      'edit': code.startsWith('en')
          ? 'Edit'
          : code.startsWith('zh')
          ? '编辑'
          : code.startsWith('ar')
          ? 'تعديل'
          : 'Edit',
      'delete': code.startsWith('en')
          ? 'Delete'
          : code.startsWith('zh')
          ? '删除'
          : code.startsWith('ar')
          ? 'حذف'
          : 'Hapus',
      'tips_title': code.startsWith('en')
          ? 'Journaling Tips'
          : code.startsWith('zh')
          ? '写日记小贴士'
          : code.startsWith('ar')
          ? 'نصائح التدوين'
          : 'Tips Menulis Jurnal',
      'tips_sub': code.startsWith('en')
          ? 'Write honestly and openly. It does not have to be perfect; what matters is expressing what you feel.'
          : code.startsWith('zh')
          ? '诚实并开放地写作。不必完美，重要的是表达你的感受。'
          : code.startsWith('ar')
          ? 'اكتب بصدق وبانفتاح. لا يلزم أن يكون مثاليًا؛ المهم هو التعبير عما تشعر به.'
          : 'Tulis dengan jujur dan terbuka. Tidak perlu sempurna, yang penting adalah mengekspresikan apa yang kamu rasakan.',
    };
  }

  Future<void> _loadJournals() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> savedJournals = prefs.getStringList('journals') ?? [];

    setState(() {
      journals = savedJournals.map((item) {
        return jsonDecode(item) as Map<String, dynamic>;
      }).toList();
      isLoading = false;
    });
  }

  Future<void> _saveJournals() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> journalsToSave = journals.map((journal) {
      return jsonEncode(journal);
    }).toList();
    await prefs.setStringList('journals', journalsToSave);
  }

  void _addJournal() {
    final L = _L();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddJournalScreen(
          onSave: (title, content, mood) {
            setState(() {
              journals.insert(0, {
                'id': DateTime.now().millisecondsSinceEpoch.toString(),
                'title': title,
                'content': content,
                'mood': mood,
                'date': DateTime.now().toIso8601String(),
              });
            });
            _saveJournals();

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(L['saved_snack']!),
                backgroundColor: const Color(0xFF10B981),
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 2),
              ),
            );
          },
        ),
      ),
    );
  }

  void _viewJournal(Map<String, dynamic> journal) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ViewJournalScreen(
          journal: journal,
          onEdit: (title, content, mood) {
            setState(() {
              final index = journals.indexWhere(
                (j) => j['id'] == journal['id'],
              );
              if (index != -1) {
                journals[index] = {
                  ...journals[index],
                  'title': title,
                  'content': content,
                  'mood': mood,
                };
              }
            });
            _saveJournals();
          },
          onDelete: () {
            setState(() {
              journals.removeWhere((j) => j['id'] == journal['id']);
            });
            _saveJournals();
          },
        ),
      ),
    );
  }

  String _getMoodEmoji(String mood) {
    switch (mood) {
      case 'Senang':
        return '😊';
      case 'Sedih':
        return '😢';
      case 'Cemas':
        return '😰';
      case 'Marah':
        return '😠';
      case 'Tenang':
        return '😌';
      default:
        return '😊';
    }
  }

  Color _getMoodColor(String mood) {
    switch (mood) {
      case 'Senang':
        return const Color(0xFFFDE047);
      case 'Sedih':
        return const Color(0xFF60A5FA);
      case 'Cemas':
        return const Color(0xFFFB923C);
      case 'Marah':
        return const Color(0xFFF87171);
      case 'Tenang':
        return const Color(0xFF86EFAC);
      default:
        return const Color(0xFFFDE047);
    }
  }

  @override
  Widget build(BuildContext context) {
    final L = _L();

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
          L['app_title']!,
          style: const TextStyle(
            color: Color(0xFF1F2937),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : journals.isEmpty
          ? _buildEmptyState(L)
          : _buildJournalList(L),
      floatingActionButton: Container(
        width: double.infinity,
        height: 56,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF4ADE80), // Hijau cerah
              Color(0xFF22C55E), // Hijau sedang
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF22C55E).withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _addJournal,
            borderRadius: BorderRadius.circular(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.edit_note_rounded,
                  color: Colors.white,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  L['new_journal']!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildEmptyState(Map<String, String> L) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(60),
              ),
              child: const Icon(
                Icons.book_outlined,
                size: 60,
                color: Color(0xFF5A7B6A),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              L['no_journal_title']!,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              L['no_journal_sub']!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF6B7280),
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJournalList(Map<String, String> L) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: journals.length,
      itemBuilder: (context, index) {
        final journal = journals[index];
        final date = DateTime.parse(journal['date']);
        final dateStr = '${date.day}/${date.month}/${date.year}';
        final timeStr =
            '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _viewJournal(journal),
              borderRadius: BorderRadius.circular(16),
              child: Container(
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
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: _getMoodColor(
                              journal['mood'],
                            ).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              _getMoodEmoji(journal['mood']),
                              style: const TextStyle(fontSize: 24),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                journal['title'],
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1F2937),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
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
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.grey[400],
                          size: 18,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      journal['content'],
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                        height: 1.5,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ==================== ADD JOURNAL SCREEN ====================
class AddJournalScreen extends StatefulWidget {
  final Function(String title, String content, String mood) onSave;

  const AddJournalScreen({Key? key, required this.onSave}) : super(key: key);

  @override
  State<AddJournalScreen> createState() => _AddJournalScreenState();
}

class _AddJournalScreenState extends State<AddJournalScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _titleFocusNode = FocusNode();
  final _contentFocusNode = FocusNode();
  String selectedMood = 'Senang';
  bool _isSaving = false;

  final List<Map<String, dynamic>> moods = [
    {'name': 'Senang', 'emoji': '😊', 'color': Color(0xFFFDE047)},
    {'name': 'Sedih', 'emoji': '😢', 'color': Color(0xFF60A5FA)},
    {'name': 'Cemas', 'emoji': '😰', 'color': Color(0xFFFB923C)},
    {'name': 'Marah', 'emoji': '😠', 'color': Color(0xFFF87171)},
    {'name': 'Tenang', 'emoji': '😌', 'color': Color(0xFF86EFAC)},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _titleFocusNode.dispose();
    _contentFocusNode.dispose();
    super.dispose();
  }

  Map<String, String> _L() {
    final ls = Provider.of<LanguageService>(context, listen: false);
    String code = ls.currentLanguageCode == 'system'
        ? ls.currentLocale.languageCode
        : ls.currentLanguageCode;
    return {
      'write_journal_title': code.startsWith('en')
          ? 'Write Journal'
          : code.startsWith('zh')
          ? '写日记'
          : code.startsWith('ar')
          ? 'اكتب مذكّرة'
          : 'Tulis Jurnal',
      'title_required': code.startsWith('en')
          ? 'Title cannot be empty'
          : code.startsWith('zh')
          ? '标题不能为空'
          : code.startsWith('ar')
          ? 'لا يمكن ترك العنوان فارغًا'
          : 'Judul tidak boleh kosong',
      'content_required': code.startsWith('en')
          ? 'Content cannot be empty'
          : code.startsWith('zh')
          ? '内容不能为空'
          : code.startsWith('ar')
          ? 'لا يمكن ترك المحتوى فارغًا'
          : 'Konten tidak boleh kosong',
      'discard_title': code.startsWith('en')
          ? 'Discard Journal?'
          : code.startsWith('zh')
          ? '放弃日记？'
          : code.startsWith('ar')
          ? 'إلغاء المذكرة؟'
          : 'Buang Jurnal?',
      'discard_sub': code.startsWith('en')
          ? 'Unsaved journal will be lost. Are you sure?'
          : code.startsWith('zh')
          ? '未保存的日记将丢失。确定要退出吗？'
          : code.startsWith('ar')
          ? 'سيتم فقدان المذكرة غير المحفوظة. هل أنت متأكد؟'
          : 'Jurnal yang belum disimpan akan hilang. Yakin ingin keluar?',
      'cancel': code.startsWith('en')
          ? 'Cancel'
          : code.startsWith('zh')
          ? '取消'
          : code.startsWith('ar')
          ? 'إلغاء'
          : 'Batal',
      'discard': code.startsWith('en')
          ? 'Discard'
          : code.startsWith('zh')
          ? '放弃'
          : code.startsWith('ar')
          ? 'تخلص'
          : 'Buang',
      'save': code.startsWith('en')
          ? 'Save'
          : code.startsWith('zh')
          ? '保存'
          : code.startsWith('ar')
          ? 'حفظ'
          : 'Simpan',
      'how_feel': code.startsWith('en')
          ? 'How are you feeling today?'
          : code.startsWith('zh')
          ? '你今天感觉如何？'
          : code.startsWith('ar')
          ? 'كيف تشعر اليوم؟'
          : 'Bagaimana perasaanmu hari ini?',
      'choose_emoji': code.startsWith('en')
          ? 'Choose an emoji that describes your feeling'
          : code.startsWith('zh')
          ? '选择一个描述你感受的表情'
          : code.startsWith('ar')
          ? 'اختر رمز تعبيري يصف شعورك'
          : 'Pilih emoji yang menggambarkan perasaanmu',
      'title_label': code.startsWith('en')
          ? 'Title'
          : code.startsWith('zh')
          ? '标题'
          : code.startsWith('ar')
          ? 'العنوان'
          : 'Judul',
      'title_hint': code.startsWith('en')
          ? 'Give your journal a title...'
          : code.startsWith('zh')
          ? '为你的日记取个标题...'
          : code.startsWith('ar')
          ? 'اعطِ مذكرتك عنوانًا...'
          : 'Beri judul jurnalmu...',
      'content_label': code.startsWith('en')
          ? 'Tell your feelings'
          : code.startsWith('zh')
          ? '写下你的感受'
          : code.startsWith('ar')
          ? 'اكتب مشاعرك'
          : 'Ceritakan Perasaanmu',
      'content_hint': code.startsWith('en')
          ? 'What are you feeling today?\n\nWrite everything on your mind...'
          : code.startsWith('zh')
          ? '你今天感觉如何？\n\n写下你心中的一切...'
          : code.startsWith('ar')
          ? 'ما الذي تشعر به اليوم؟\n\nاكتب كل ما في بالك...'
          : 'Apa yang kamu rasakan hari ini?\n\nTulis semua yang ada di pikiranmu. Tidak ada yang salah atau benar di sini. Ini adalah ruang amanmu untuk mengekspresikan diri...',
      'tips_title': code.startsWith('en')
          ? 'Journaling Tips'
          : code.startsWith('zh')
          ? '写日记小贴士'
          : code.startsWith('ar')
          ? 'نصائح التدوين'
          : 'Tips Menulis Jurnal',
      'tips_sub': code.startsWith('en')
          ? 'Write honestly and openly. It does not have to be perfect.'
          : code.startsWith('zh')
          ? '诚实并开放地写作。不必完美。'
          : code.startsWith('ar')
          ? 'اكتب بصدق وبانفتاح. لا يلزم أن يكون مثاليًا.'
          : 'Tulis dengan jujur dan terbuka. Tidak perlu sempurna, yang penting adalah mengekspresikan apa yang kamu rasakan.',
    };
  }

  void _save() async {
    final L = _L();

    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text(L['title_required']!)),
            ],
          ),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      _titleFocusNode.requestFocus();
      return;
    }

    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text(L['content_required']!)),
            ],
          ),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      _contentFocusNode.requestFocus();
      return;
    }

    setState(() {
      _isSaving = true;
    });

    await Future.delayed(const Duration(milliseconds: 300));

    widget.onSave(
      _titleController.text.trim(),
      _contentController.text.trim(),
      selectedMood,
    );

    Navigator.pop(context);
  }

  Future<bool> _onWillPop() async {
    if (_titleController.text.isNotEmpty ||
        _contentController.text.isNotEmpty) {
      final L = _L();
      final shouldPop = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(L['discard_title']!),
          content: Text(L['discard_sub']!),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(L['cancel']!),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFEF4444),
              ),
              child: Text(L['discard']!),
            ),
          ],
        ),
      );
      return shouldPop ?? false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final L = _L();

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: const Color(0xFFE8E8E8),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Color(0xFF1F2937)),
            onPressed: () async {
              if (await _onWillPop()) {
                Navigator.pop(context);
              }
            },
          ),
          title: Text(
            L['write_journal_title']!,
            style: const TextStyle(
              color: Color(0xFF1F2937),
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _isSaving
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF2D4A3E),
                            ),
                          ),
                        ),
                      ),
                    )
                  : TextButton(
                      onPressed: _save,
                      child: Text(
                        L['save']!,
                        style: const TextStyle(
                          color: Color(0xFF2D4A3E),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                L['how_feel']!,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                L['choose_emoji']!,
                style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: moods.map((mood) {
                  final isSelected = selectedMood == mood['name'];

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedMood = mood['name'] as String;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      child: Column(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? (mood['color'] as Color).withOpacity(0.15)
                                  : Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? mood['color'] as Color
                                    : const Color(0xFFE5E7EB),
                                width: isSelected ? 3 : 2,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: (mood['color'] as Color)
                                            .withOpacity(0.3),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                  : [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                            ),
                            child: Center(
                              child: Text(
                                mood['emoji'] as String,
                                style: TextStyle(
                                  fontSize: isSelected ? 32 : 28,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            mood['name'] as String,
                            style: TextStyle(
                              fontSize: 13,
                              color: isSelected
                                  ? const Color(0xFF1F2937)
                                  : const Color(0xFF9CA3AF),
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              Text(
                L['title_label']!,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 4,
                ),
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
                child: TextField(
                  controller: _titleController,
                  focusNode: _titleFocusNode,
                  decoration: InputDecoration(
                    hintText: L['title_hint']!,
                    hintStyle: const TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 18,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                  maxLength: 100,
                  buildCounter:
                      (
                        context, {
                        required currentLength,
                        required isFocused,
                        maxLength,
                      }) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8, right: 4),
                          child: Text(
                            '$currentLength/$maxLength',
                            style: TextStyle(
                              fontSize: 12,
                              color: currentLength > 80
                                  ? const Color(0xFFEF4444)
                                  : const Color(0xFF9CA3AF),
                            ),
                          ),
                        );
                      },
                ),
              ),
              const SizedBox(height: 24),
              Text(
                L['content_label']!,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 12),
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
                child: TextField(
                  controller: _contentController,
                  focusNode: _contentFocusNode,
                  decoration: InputDecoration(
                    hintText: L['content_hint']!,
                    hintStyle: const TextStyle(
                      color: Color(0xFF9CA3AF),
                      height: 1.6,
                    ),
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF1F2937),
                    height: 1.8,
                  ),
                  maxLines: 15,
                  minLines: 15,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFBFDBFE), width: 1),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.lightbulb_outline,
                      color: Color(0xFF3B82F6),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            L['tips_title']!,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E40AF),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            L['tips_sub']!,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF1E40AF),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== VIEW JOURNAL SCREEN ====================
class ViewJournalScreen extends StatefulWidget {
  final Map<String, dynamic> journal;
  final Function(String title, String content, String mood) onEdit;
  final VoidCallback onDelete;

  const ViewJournalScreen({
    Key? key,
    required this.journal,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  State<ViewJournalScreen> createState() => _ViewJournalScreenState();
}

class _ViewJournalScreenState extends State<ViewJournalScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late String selectedMood;
  bool isEditing = false;

  final List<Map<String, dynamic>> moods = [
    {'name': 'Senang', 'emoji': '😊', 'color': Color(0xFFFDE047)},
    {'name': 'Sedih', 'emoji': '😢', 'color': Color(0xFF60A5FA)},
    {'name': 'Cemas', 'emoji': '😰', 'color': Color(0xFFFB923C)},
    {'name': 'Marah', 'emoji': '😠', 'color': Color(0xFFF87171)},
    {'name': 'Tenang', 'emoji': '😌', 'color': Color(0xFF86EFAC)},
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.journal['title']);
    _contentController = TextEditingController(text: widget.journal['content']);
    selectedMood = widget.journal['mood'];
  }

  Map<String, String> _L() {
    final ls = Provider.of<LanguageService>(context, listen: false);
    String code = ls.currentLanguageCode == 'system'
        ? ls.currentLocale.languageCode
        : ls.currentLanguageCode;
    return {
      'edit_journal': code.startsWith('en')
          ? 'Edit Journal'
          : code.startsWith('zh')
          ? '编辑日记'
          : code.startsWith('ar')
          ? 'تعديل المذكرة'
          : 'Edit Jurnal',
      'detail_journal': code.startsWith('en')
          ? 'Journal Details'
          : code.startsWith('zh')
          ? '日记详情'
          : code.startsWith('ar')
          ? 'تفاصيل المذكرة'
          : 'Detail Jurnal',
      'save': code.startsWith('en')
          ? 'Save'
          : code.startsWith('zh')
          ? '保存'
          : code.startsWith('ar')
          ? 'حفظ'
          : 'Simpan',
      'edit': code.startsWith('en')
          ? 'Edit'
          : code.startsWith('zh')
          ? '编辑'
          : code.startsWith('ar')
          ? 'تعديل'
          : 'Edit',
      'delete': code.startsWith('en')
          ? 'Delete'
          : code.startsWith('zh')
          ? '删除'
          : code.startsWith('ar')
          ? 'حذف'
          : 'Hapus',
      'delete_confirm_title': code.startsWith('en')
          ? 'Delete Journal?'
          : code.startsWith('zh')
          ? '删除日记？'
          : code.startsWith('ar')
          ? 'حذف المذكرة؟'
          : 'Hapus Jurnal?',
      'delete_confirm_sub': code.startsWith('en')
          ? 'Deleted journals cannot be recovered. Are you sure?'
          : code.startsWith('zh')
          ? '删除的日记无法恢复。确定要删除吗？'
          : code.startsWith('ar')
          ? 'لا يمكن استعادة المذكرات المحذوفة. هل أنت متأكد؟'
          : 'Jurnal yang dihapus tidak dapat dikembalikan. Yakin ingin menghapus?',
      'cancel': code.startsWith('en')
          ? 'Cancel'
          : code.startsWith('zh')
          ? '取消'
          : code.startsWith('ar')
          ? 'إلغاء'
          : 'Batal',
      'deleted': code.startsWith('en')
          ? 'Journal deleted'
          : code.startsWith('zh')
          ? '日记已删除'
          : code.startsWith('ar')
          ? 'تم حذف المذكرة'
          : 'Jurnal berhasil dihapus',
      'date_time': code.startsWith('en')
          ? 'Date & Time'
          : code.startsWith('zh')
          ? '日期和时间'
          : code.startsWith('ar')
          ? 'التاريخ والوقت'
          : 'Tanggal & Waktu',
      'change_feeling': code.startsWith('en')
          ? 'Change Feeling'
          : code.startsWith('zh')
          ? '更改感受'
          : code.startsWith('ar')
          ? 'تغيير الشعور'
          : 'Ubah Perasaan',
      'feeling_label': code.startsWith('en')
          ? 'Feeling'
          : code.startsWith('zh')
          ? '感受'
          : code.startsWith('ar')
          ? 'الشعور'
          : 'Perasaan',
      'title_label': code.startsWith('en')
          ? 'Title'
          : code.startsWith('zh')
          ? '标题'
          : code.startsWith('ar')
          ? 'العنوان'
          : 'Judul',
      'content_label': code.startsWith('en')
          ? 'Journal Content'
          : code.startsWith('zh')
          ? '日记内容'
          : code.startsWith('ar')
          ? 'محتوى المذكرة'
          : 'Isi Jurnal',
      'saved_update': code.startsWith('en')
          ? 'Journal updated! ✓'
          : code.startsWith('zh')
          ? '日记已更新！✓'
          : code.startsWith('ar')
          ? 'تم تحديث المذكرة! ✓'
          : 'Jurnal berhasil diperbarui! ✓',
    };
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    setState(() {
      isEditing = !isEditing;
      if (!isEditing) {
        _titleController.text = widget.journal['title'];
        _contentController.text = widget.journal['content'];
        selectedMood = widget.journal['mood'];
      }
    });
  }

  void _save() {
    final L = _L();

    if (_titleController.text.trim().isEmpty ||
        _contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${L['title_required']} / ${L['content_required']}'),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
      return;
    }

    widget.onEdit(
      _titleController.text.trim(),
      _contentController.text.trim(),
      selectedMood,
    );
    setState(() {
      isEditing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(L['saved_update']!),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _delete() {
    final L = _L();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(L['delete_confirm_title']!),
        content: Text(L['delete_confirm_sub']!),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(L['cancel']!),
          ),
          TextButton(
            onPressed: () {
              widget.onDelete();
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(L['deleted']!),
                  backgroundColor: const Color(0xFFEF4444),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFEF4444),
            ),
            child: Text(L['delete']!),
          ),
        ],
      ),
    );
  }

  String _getMoodEmoji(String mood) {
    final moodData = moods.firstWhere(
      (m) => m['name'] == mood,
      orElse: () => moods[0],
    );
    return moodData['emoji'] as String;
  }

  @override
  Widget build(BuildContext context) {
    final date = DateTime.parse(widget.journal['date']);
    final dateStr = '${date.day}/${date.month}/${date.year}';
    final timeStr =
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

    final L = _L();

    return Scaffold(
      backgroundColor: const Color(0xFFE8E8E8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2937)),
          onPressed: () {
            if (isEditing) {
              _toggleEdit();
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          isEditing ? L['edit_journal']! : L['detail_journal']!,
          style: const TextStyle(
            color: Color(0xFF1F2937),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (isEditing)
            TextButton(
              onPressed: _save,
              child: Text(
                L['save']!,
                style: const TextStyle(
                  color: Color(0xFF2D4A3E),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else ...[
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: Color(0xFF1F2937)),
              onPressed: _toggleEdit,
              tooltip: L['edit']!,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444)),
              onPressed: _delete,
              tooltip: L['delete']!,
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
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
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.calendar_today,
                      size: 20,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        L['date_time']!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$dateStr • $timeStr',
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF1F2937),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (isEditing) ...[
              Text(
                L['change_feeling']!,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: moods.map((mood) {
                    final isSelected = selectedMood == mood['name'];
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedMood = mood['name'] as String;
                          });
                        },
                        child: Column(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? (mood['color'] as Color).withOpacity(0.15)
                                    : Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? mood['color'] as Color
                                      : const Color(0xFFE5E7EB),
                                  width: isSelected ? 3 : 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  mood['emoji'] as String,
                                  style: const TextStyle(fontSize: 28),
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              mood['name'] as String,
                              style: TextStyle(
                                fontSize: 12,
                                color: isSelected
                                    ? const Color(0xFF1F2937)
                                    : const Color(0xFF9CA3AF),
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),
            ] else ...[
              Container(
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
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color:
                            (moods.firstWhere(
                                      (m) => m['name'] == selectedMood,
                                      orElse: () => moods[0],
                                    )['color']
                                    as Color)
                                .withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          _getMoodEmoji(selectedMood),
                          style: const TextStyle(fontSize: 28),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          L['feeling_label']!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          selectedMood,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF1F2937),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
            Text(
              L['title_label']!,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 8),
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
              child: TextField(
                controller: _titleController,
                enabled: isEditing,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: L['hint_title'],
                  hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
                maxLines: null,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              L['content_label']!,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(20),
              constraints: const BoxConstraints(minHeight: 300),
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
              child: TextField(
                controller: _contentController,
                enabled: isEditing,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: L['hint_content'],
                  hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF374151),
                  height: 1.8,
                ),
                maxLines: null,
              ),
            ),
            const SizedBox(height: 24),
            if (!isEditing)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFBBF7D0), width: 1),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.auto_awesome,
                      color: Color(0xFF16A34A),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            L['tips_title']!,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF166534),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            L['tips_sub']!,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF166534),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
