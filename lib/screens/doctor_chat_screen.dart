import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:uuid/uuid.dart';
import 'package:provider/provider.dart';

import '../models/doctor_model.dart';
import '../models/chat_message_model.dart';
import '../models/consultation_model.dart';
import '../services/doctor_service.dart';
import '../services/language_service.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/typing_indicator.dart';

/// Localized DoctorChatScreen — reads `LanguageService` to adapt UI strings.
class DoctorChatScreen extends StatefulWidget {
  final Doctor doctor;

  const DoctorChatScreen({Key? key, required this.doctor}) : super(key: key);

  @override
  State<DoctorChatScreen> createState() => _DoctorChatScreenState();
}

class _DoctorChatScreenState extends State<DoctorChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final DoctorService _doctorService = DoctorService();
  final Uuid _uuid = const Uuid();

  late Consultation _consultation;
  bool _isLoading = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _initializeConsultation();
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _saveConsultation();
    super.dispose();
  }

  void _initializeConsultation() {
    _consultation = Consultation(
      id: _uuid.v4(),
      type: ConsultationType.doctor,
      status: ConsultationStatus.active,
      startTime: DateTime.now(),
      messages: [],
      doctor: widget.doctor,
      topic: 'Konsultasi dengan ${widget.doctor.name}',
    );

    final welcomeMessage = ChatMessage(
      id: _uuid.v4(),
      content:
          'Halo! Saya ${widget.doctor.name}.\n\n'
          'Senang bisa membantu Anda hari ini. Silakan ceritakan apa yang ingin Anda sampaikan — informasi Anda akan dijaga kerahasiaannya.',
      type: MessageType.doctor,
      timestamp: DateTime.now(),
      senderName: widget.doctor.name,
      senderAvatar: widget.doctor.imageUrl,
    );

    setState(() => _consultation.messages.add(welcomeMessage));
  }

  Future<void> _saveConsultation() async {
    if (!_isSaving) {
      _isSaving = true;
      await _doctorService.saveConsultation(_consultation);
      _isSaving = false;
    }
  }

  void _handleSendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty || _isLoading) return;

    final userMessage = ChatMessage(
      id: _uuid.v4(),
      content: text,
      type: MessageType.user,
      timestamp: DateTime.now(),
    );

    setState(() {
      _consultation.messages.add(userMessage);
      _isLoading = true;
    });
    _textController.clear();
    _scrollToBottom();

    await _saveConsultation();

    await Future.delayed(const Duration(seconds: 2));

    final doctorResponse = _generateDoctorResponse(text);
    final doctorMessage = ChatMessage(
      id: _uuid.v4(),
      content: doctorResponse,
      type: MessageType.doctor,
      timestamp: DateTime.now(),
      senderName: widget.doctor.name,
      senderAvatar: widget.doctor.imageUrl,
    );

    setState(() {
      _consultation.messages.add(doctorMessage);
      _isLoading = false;
    });
    _scrollToBottom();

    await _saveConsultation();
  }

  String _generateDoctorResponse(String userMessage) {
    final lower = userMessage.toLowerCase();
    if (lower.contains('cemas') || lower.contains('anxiety')) {
      return 'Saya mendengar Anda sedang mengalami kecemasan. Bisakah Anda ceritakan lebih detail kapan dan bagaimana gejala muncul?';
    }
    if (lower.contains('tidur') || lower.contains('insomnia')) {
      return 'Masalah tidur dapat sangat mempengaruhi kualitas hidup. Sejak kapan Anda mengalami kesulitan tidur?';
    }
    if (lower.contains('depresi') || lower.contains('sedih')) {
      return 'Terima kasih sudah berbagi. Sudah berapa lama Anda merasakan hal ini dan apakah ada pemicu yang jelas?';
    }
    return 'Terima kasih sudah bercerita. Bisa ceritakan lebih lanjut apa yang paling mengganggu Anda saat ini?';
  }

  void _scrollToBottom() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _endConsultation() async {
    final ls = Provider.of<LanguageService>(context, listen: false);
    final code = ls.currentLanguageCode == 'system'
        ? ls.currentLocale.languageCode
        : ls.currentLanguageCode;

    final title = code.startsWith('en')
        ? 'End Consultation?'
        : code.startsWith('zh')
        ? '结束咨询？'
        : code.startsWith('ar')
        ? 'إنهاء الاستشارة؟'
        : 'Akhiri Konsultasi?';
    final content = code.startsWith('en')
        ? 'Are you sure you want to end this consultation?'
        : code.startsWith('zh')
        ? 'Apakah Anda yakin ingin mengakhiri sesi konsultasi ini?'
        : code.startsWith('ar')
        ? 'هل أنت متأكد أنك تريد إنهاء هذه الجلسة؟'
        : 'Apakah Anda yakin ingin mengakhiri sesi konsultasi ini?';
    final cancel = code.startsWith('en')
        ? 'Cancel'
        : code.startsWith('zh')
        ? '取消'
        : code.startsWith('ar')
        ? 'إلغاء'
        : 'Batal';
    final confirm = code.startsWith('en')
        ? 'Yes, End'
        : code.startsWith('zh')
        ? 'Ya, Akhiri'
        : code.startsWith('ar')
        ? 'نعم، أنهِ'
        : 'Ya, Akhiri';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6B9080),
            ),
            child: Text(confirm),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      _consultation = Consultation(
        id: _consultation.id,
        type: _consultation.type,
        status: ConsultationStatus.completed,
        startTime: _consultation.startTime,
        endTime: DateTime.now(),
        messages: _consultation.messages,
        doctor: _consultation.doctor,
        topic: _consultation.topic,
      );

      await _saveConsultation();

      if (mounted) {
        Navigator.pop(context);
        final snack = code.startsWith('en')
            ? 'Consultation ended'
            : code.startsWith('zh')
            ? '咨询已结束'
            : code.startsWith('ar')
            ? 'انتهت الجلسة'
            : 'Konsultasi telah berakhir';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(snack),
            backgroundColor: const Color(0xFF6B9080),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageService>(
      builder: (context, ls, child) {
        final code = ls.currentLanguageCode == 'system'
            ? ls.currentLocale.languageCode
            : ls.currentLanguageCode;

        final hintTyping = code.startsWith('en')
            ? 'Doctor is typing...'
            : code.startsWith('zh')
            ? '医生正在输入...'
            : code.startsWith('ar')
            ? 'الطبيب يكتب...'
            : 'Dokter sedang mengetik...';
        final hintInput = code.startsWith('en')
            ? 'Type your message...'
            : code.startsWith('zh')
            ? '输入消息...'
            : code.startsWith('ar')
            ? 'اكتب رسالتك...'
            : 'Ketik pesan Anda...';
        final endLabel = code.startsWith('en')
            ? 'End Consultation'
            : code.startsWith('zh')
            ? '结束咨询'
            : code.startsWith('ar')
            ? 'إنهاء الاستشارة'
            : 'Akhiri Konsultasi';

        return Scaffold(
          backgroundColor: const Color(0xFFF5EFD0),
          appBar: AppBar(
            backgroundColor: const Color(0xFF6B9080),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundImage: NetworkImage(widget.doctor.imageUrl),
                  backgroundColor: Colors.white,
                  onBackgroundImageError: (_, __) {},
                  child: widget.doctor.imageUrl.isEmpty
                      ? const Icon(Icons.person, size: 20)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.doctor.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        widget.doctor.specialization,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onSelected: (value) {
                  if (value == 'end') _endConsultation();
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'end',
                    child: Row(
                      children: [
                        const Icon(
                          Icons.stop_circle_outlined,
                          size: 20,
                          color: Colors.red,
                        ),
                        const SizedBox(width: 12),
                        Text(endLabel),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                color: const Color(0xFFE8F5E9),
                child: Row(
                  children: [
                    const Icon(Icons.lock, size: 16, color: Color(0xFF2E7D32)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        code.startsWith('en')
                            ? 'This session is end-to-end encrypted'
                            : code.startsWith('zh')
                            ? '会话已端到端加密'
                            : code.startsWith('ar')
                            ? 'هذه الجلسة مشفرة من طرف إلى طرف'
                            : 'Sesi ini terenkripsi end-to-end',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black.withOpacity(0.7),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  itemCount:
                      _consultation.messages.length + (_isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _consultation.messages.length && _isLoading) {
                      return TypingIndicator(isDoctor: true);
                    }
                    return ChatBubble(
                      message: _consultation.messages[index],
                      showAvatar: true,
                      showTimestamp: true,
                    );
                  },
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F0F0),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: TextField(
                            controller: _textController,
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: InputDecoration(
                              hintText: _isLoading ? hintTyping : hintInput,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 14,
                              ),
                              hintStyle: const TextStyle(color: Colors.black45),
                            ),
                            onSubmitted: _isLoading
                                ? null
                                : (_) => _handleSendMessage(),
                            enabled: !_isLoading,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Material(
                        color: _isLoading
                            ? Colors.grey
                            : const Color(0xFF6B9080),
                        borderRadius: BorderRadius.circular(24),
                        child: InkWell(
                          onTap: _isLoading ? null : _handleSendMessage,
                          borderRadius: BorderRadius.circular(24),
                          child: const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Icon(
                              Icons.send,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
