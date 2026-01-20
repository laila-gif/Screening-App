import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import '../services/language_service.dart';
import 'package:uuid/uuid.dart';
import '../models/chat_message_model.dart';
import '../services/ai_service.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/typing_indicator.dart';
import 'doctor_list_screen.dart';

class AIChatScreen extends StatefulWidget {
  const AIChatScreen({Key? key}) : super(key: key);

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final AIService _aiService = AIService();
  final List<ChatMessage> _messages = [];
  final Uuid _uuid = const Uuid();
  
  bool _isLoading = false;
  bool _showEmergencyBanner = false;

  @override
  void initState() {
    super.initState();
    // defer adding initial message so LanguageService is available
    WidgetsBinding.instance.addPostFrameCallback((_) => _addInitialMessage());
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _addInitialMessage() {
    final languageService = Provider.of<LanguageService>(context, listen: false);
    String code = languageService.currentLanguageCode;
    if (code == 'system') code = languageService.currentLocale.languageCode;

    String content;
    String sender = 'AI Assistant';

    if (code.startsWith('en')) {
      content = 'Hello! I\'m Serene AI Assistant.\n\n'
          'I\'m here to listen and help you. '
          'Tell me how you are feeling or what you\'re experiencing right now.\n\n'
          'Everything you share will be kept confidential.';
    } else if (code.startsWith('zh')) {
      content = '你好！我是 Serene AI 助手。\n\n'
          '我在这里倾听并帮助您。请告诉我您现在的感受或正在经历的事情。\n\n'
          '您分享的一切将被保密。';
      sender = 'AI 助手';
    } else if (code.startsWith('ar')) {
      content = 'مرحبًا! أنا مساعد Serene الذكي.\n\n'
          'أنا هنا للاستماع ومساعدتك. أخبرني بما تشعر به أو تواجهه الآن.\n\n'
          'كل ما تشاركه سيبقى سريًا.';
      sender = 'مساعد AI';
    } else {
      content = 'Halo! Saya Serene AI Assistant.\n\n'
          'Saya di sini untuk mendengarkan dan membantu Anda. '
          'Ceritakan apa yang sedang Anda rasakan atau alami saat ini.\n\n'
          'Semua yang Anda ceritakan akan dijaga kerahasiaannya.';
    }

    final initialMessage = ChatMessage(
      id: _uuid.v4(),
      content: content,
      type: MessageType.ai,
      timestamp: DateTime.now(),
      senderName: sender,
    );
    
    setState(() {
      _messages.add(initialMessage);
    });
  }

  void _handleSendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty || _isLoading) return;

    // Check for emergency keywords
    if (_aiService.isEmergency(text)) {
      setState(() {
        _showEmergencyBanner = true;
      });
      _scrollToBottom();
    }

    // Add user message
    final userMessage = ChatMessage(
      id: _uuid.v4(),
      content: text,
      type: MessageType.user,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMessage);
      _isLoading = true;
    });
    _textController.clear();
    _scrollToBottom();

    // Get AI response
    try {
      String response;
      
      if (_aiService.isEmergency(text)) {
        response = _aiService.getEmergencyResponse();
      } else {
        response = await _aiService.sendMessage(text);
      }

      final aiMessage = ChatMessage(
        id: _uuid.v4(),
        content: response,
        type: MessageType.ai,
        timestamp: DateTime.now(),
        senderName: 'AI Assistant',
      );

      setState(() {
        _messages.add(aiMessage);
        _isLoading = false;
      });
      _scrollToBottom();

    } catch (e) {
      final languageService = Provider.of<LanguageService>(context, listen: false);
      String code = languageService.currentLanguageCode;
      if (code == 'system') code = languageService.currentLocale.languageCode;

      final String errContent = code.startsWith('en')
          ? 'Sorry, an error occurred. Please try again or contact our doctor.'
          : code.startsWith('zh')
              ? '抱歉，发生错误。请重试或联系我们的医生。'
              : code.startsWith('ar')
                  ? 'عذرًا، حدث خطأ. الرجاء المحاولة مرة أخرى أو الاتصال بطبيبنا.'
                  : 'Maaf, terjadi kesalahan. Silakan coba lagi atau hubungi dokter kami.';

      final errorMessage = ChatMessage(
        id: _uuid.v4(),
        content: errContent,
        type: MessageType.ai,
        timestamp: DateTime.now(),
        senderName: 'AI Assistant',
      );

      setState(() {
        _messages.add(errorMessage);
        _isLoading = false;
      });
      _scrollToBottom();
    }
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

  void _startNewChat() {
    setState(() {
      _messages.clear();
      _isLoading = false;
      _showEmergencyBanner = false;
    });
    _aiService.resetChat();
    _addInitialMessage();
  }

  void _goToDoctorList() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DoctorListScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageService>(
      builder: (context, languageService, child) {
        String code = languageService.currentLanguageCode;
        if (code == 'system') code = languageService.currentLocale.languageCode;

        // localized labels
        final String appBarTitle = code.startsWith('en')
            ? 'AI Assistant'
            : code.startsWith('zh')
                ? 'AI 助手'
                : code.startsWith('ar')
                    ? 'مساعد AI'
                    : 'AI Assistant';

        final String appBarSubtitle = code.startsWith('en')
            ? 'Online 24/7'
            : code.startsWith('zh')
                ? '全天候在线'
                : code.startsWith('ar')
                    ? 'متصل 24/7'
                    : 'Online 24/7';

        final String popupDoctor = code.startsWith('en')
            ? 'Consult Doctor'
            : code.startsWith('zh')
                ? '咨询医生'
                : code.startsWith('ar')
                    ? 'استشر الطبيب'
                    : 'Konsultasi Dokter';

        final String popupNew = code.startsWith('en')
            ? 'New Chat'
            : code.startsWith('zh')
                ? '新对话'
                : code.startsWith('ar')
                    ? 'دردشة جديدة'
                    : 'Chat Baru';

        final String refreshTooltip = code.startsWith('en')
            ? 'New Chat'
            : code.startsWith('zh')
                ? '新对话'
                : code.startsWith('ar')
                    ? 'دردشة جديدة'
                    : 'Chat Baru';

        final String emergencyTitle = code.startsWith('en')
            ? 'Emergency Detected'
            : code.startsWith('zh')
                ? '检测到紧急情况'
                : code.startsWith('ar')
                    ? 'اكتشاف حالة طارئة'
                    : 'Situasi Darurat Terdeteksi';

        final String hotlineText = code.startsWith('en')
            ? 'Please contact hotline: 119 ext 8'
            : code.startsWith('zh')
                ? '请联系热线：119 转 8'
                : code.startsWith('ar')
                    ? 'يرجى الاتصال بالخط الساخن: 119 تحويلة 8'
                    : 'Segera hubungi hotline: 119 ext 8';

        final String doctorButtonText = code.startsWith('en')
            ? 'Doctor'
            : code.startsWith('zh')
                ? '医生'
                : code.startsWith('ar')
                    ? 'طبيب'
                    : 'Dokter';

        final String typingHint = code.startsWith('en')
            ? 'AI is typing...'
            : code.startsWith('zh')
                ? 'AI 正在输入...'
                : code.startsWith('ar')
                    ? 'المساعد يكتب...'
                    : 'AI sedang mengetik...';

        final String inputHint = code.startsWith('en')
            ? 'Type your message...'
            : code.startsWith('zh')
                ? '输入您的消息...'
                : code.startsWith('ar')
                    ? 'اكتب رسالتك...'
                    : 'Ketik pesan Anda...';

        final String errorText = code.startsWith('en')
            ? 'Sorry, an error occurred. Please try again or contact our doctor.'
            : code.startsWith('zh')
                ? '抱歉，发生错误。请重试或联系我们的医生。'
                : code.startsWith('ar')
                    ? 'عذرًا، حدث خطأ. الرجاء المحاولة مرة أخرى أو الاتصال بطبيبنا.'
                    : 'Maaf, terjadi kesalahan. Silakan coba lagi atau hubungi dokter kami.';

        return Scaffold(
      backgroundColor: const Color(0xFFF5EFD0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5EFD0),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Color(0xFF6B9080),
              radius: 18,
              child: Icon(Icons.psychology, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appBarTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  appBarSubtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black54),
            onPressed: _startNewChat,
            tooltip: refreshTooltip,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.black54),
            onSelected: (value) {
              if (value == 'doctor') {
                _goToDoctorList();
              } else if (value == 'new') {
                _startNewChat();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'doctor',
                child: Row(
                  children: [
                    const Icon(Icons.local_hospital, size: 20),
                    const SizedBox(width: 12),
                    Text(popupDoctor),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'new',
                child: Row(
                  children: [
                    const Icon(Icons.add_comment, size: 20),
                    const SizedBox(width: 12),
                    Text(popupNew),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Emergency Banner
          if (_showEmergencyBanner)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: const Color(0xFFFFEBEE),
              child: Row(
                children: [
                  const Icon(Icons.warning, color: Color(0xFFC62828)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          emergencyTitle,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFC62828),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          hotlineText,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: _goToDoctorList,
                    child: Text(
                      doctorButtonText,
                      style: const TextStyle(
                        color: Color(0xFFC62828),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isLoading) {
                  return const TypingIndicator();
                }
                
                return ChatBubble(
                  message: _messages[index],
                  showTimestamp: true,
                );
              },
            ),
          ),

          // Input Area
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                          hintText: _isLoading ? typingHint : inputHint,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                          hintStyle: const TextStyle(color: Colors.black45),
                        ),
                        onSubmitted: _isLoading ? null : (_) => _handleSendMessage(),
                        enabled: !_isLoading,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Material(
                    color: _isLoading ? Colors.grey : const Color(0xFF6B9080),
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