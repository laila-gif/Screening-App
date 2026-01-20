// File: lib/screens/profile_screen.dart
// 🎨 MODERN PREMIUM PROFILE SCREEN WITH STUNNING UI

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/auth_service.dart';
import '../services/language_service.dart';
import '../services/cloudinary_service.dart';
import 'dart:ui';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  User? _currentUser;
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // 🎨 Premium Color Palette - Sesuai gambar
  final Color _backgroundColor = const Color(0xFFF5F1E8); // Cream/Beige hangat
  final Color _primaryGreen = const Color(0xFF2D5F3F); // Deep forest green
  final Color _accentGold = const Color(0xFFD4AF37); // Elegant gold
  final Color _cardColor = const Color(0xFFFFFFFF);
  final Color _textPrimary = const Color(0xFF1A1A1A);
  final Color _textSecondary = const Color(0xFF6B7280);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
    _loadUserData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);

    final authService = Provider.of<AuthService>(context, listen: false);
    _currentUser = authService.currentUser;

    if (_currentUser != null) {
      _userData = await authService.getUserData(_currentUser!.uid);
    }

    setState(() => _isLoading = false);
  }

  Future<void> _logout() async {
    final languageService = Provider.of<LanguageService>(
      context,
      listen: false,
    );
    final L = _L(languageService);

    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: _cardColor,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: _primaryGreen.withOpacity(0.15),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: Colors.red,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  L['logout']!,
                  style: TextStyle(
                    color: _textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  L['logout_confirm']!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: _textSecondary, fontSize: 15),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(false),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: _textSecondary.withOpacity(0.3),
                            ),
                          ),
                        ),
                        child: Text(
                          L['cancel']!,
                          style: TextStyle(
                            color: _textSecondary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(dialogContext).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          L['logout']!,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (shouldLogout != true || !mounted) return;

    try {
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          barrierColor: Colors.black54,
          builder: (context) => BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: _cardColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      color: _primaryGreen,
                      strokeWidth: 3,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      L['logging_out']!,
                      style: TextStyle(
                        color: _textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }

      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.logout();

      if (mounted) {
        Navigator.of(context).pop();
      }

      if (mounted) {
        await Future.delayed(const Duration(milliseconds: 300));

        if (mounted) {
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil('/login', (route) => false);
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error logout: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  String _getInitials(String name) {
    List<String> names = name.split(' ');
    String initials = '';

    if (names.isNotEmpty) {
      initials = names[0][0].toUpperCase();
      if (names.length > 1) {
        initials += names[1][0].toUpperCase();
      }
    }

    return initials;
  }

  Map<String, String> _L(LanguageService ls) {
    final code = ls.currentLanguageCode == 'system'
        ? ls.currentLocale.languageCode
        : ls.currentLanguageCode;

    if (code.startsWith('en')) {
      return {
        'loading_profile': 'Loading profile...',
        'not_logged_in': 'You are not logged in',
        'please_login': 'Please login to access your profile',
        'login_now': 'Login Now',
        'account_settings': 'Account Settings',
        'edit_profile': 'Edit Profile',
        'edit_profile_sub': 'Update your information',
        'privacy_security': 'Privacy & Security',
        'privacy_security_sub': 'Change your account password',
        'language': 'Language',
        'others': 'Others',
        'help_support': 'Help & Support',
        'help_sub': 'FAQ & support contacts',
        'about_app': 'About App',
        'about_sub': 'Version 1.0.0',
        'logout': 'Logout',
        'logout_confirm': 'Are you sure you want to sign out?',
        'cancel': 'Cancel',
        'logging_out': 'Logging out...',
        'profile_updated_success': 'Profile updated successfully!',
        'profile_update_failed': 'Failed to update profile',
        'error_occurred': 'An error occurred: ',
        'save': 'Save',
        'choose_language': 'Choose Language',
        'close': 'Close',
        'faq_title': 'Frequently Asked Questions (FAQ)',
        'faq_q1': 'How do I use the meditation feature?',
        'faq_a1':
            'You can choose a meditation session from the Meditation page, then tap to start. Follow the breathing guidance shown on screen.',
        'faq_q2': 'How do I take the mental health test?',
        'faq_a2':
            'Open the Home page, then select "Mental Health Test" in Quick Access. Answer honestly to get accurate results.',
        'faq_q3': 'How do I change my password?',
        'faq_a3':
            'Open the Profile page, select "Privacy & Security", then enter your old and new passwords.',
        'faq_q4': 'How do I change my profile photo?',
        'faq_a4':
            'Open Profile, choose "Edit Profile", then tap the camera icon to pick a new photo from gallery or camera.',
        'faq_q5': 'Is my data secure?',
        'faq_a5':
            'Yes, we use strong encryption to protect your data. All information is stored securely and will not be shared with third parties.',
        'email_support': 'Email Support',
        'phone_label': 'Phone',
        'hours_label': 'Operating Hours',
        'hours_sub': 'Mon - Fri, 09:00 - 17:00',
        'contact_us': 'Contact Us',
        'emergency_help':
            'For emergency help, contact local mental health services or emergency hotlines.',
      };
    }

    if (code.startsWith('zh')) {
      return {
        'loading_profile': '正在加载个人资料...',
        'not_logged_in': '您尚未登录',
        'please_login': '请登录以访问个人资料',
        'login_now': '现在登录',
        'account_settings': '帐户设置',
        'edit_profile': '编辑个人资料',
        'edit_profile_sub': '更新您的信息',
        'privacy_security': '隐私与安全',
        'privacy_security_sub': '更改您的帐户密码',
        'language': '语言',
        'others': '其他',
        'help_support': '帮助与支持',
        'help_sub': '常见问题与支持联系方式',
        'about_app': '关于应用',
        'about_sub': '版本 1.0.0',
        'logout': '登出',
        'logout_confirm': '您确定要登出吗？',
        'cancel': '取消',
        'logging_out': '正在登出...',
        'profile_updated_success': '个人资料已更新！',
        'profile_update_failed': '更新个人资料失败',
        'error_occurred': '发生错误：',
        'save': '保存',
        'choose_language': '选择语言',
        'close': '关闭',
        'faq_title': '常见问题 (FAQ)',
        'faq_q1': '如何使用冥想功能？',
        'faq_a1': '您可以从“冥想”页面选择一个会话，然后点击开始。按照屏幕上的呼吸指导进行。',
        'faq_q2': '如何进行心理健康测试？',
        'faq_a2': '打开主页，然后在快速访问中选择“心理健康测试”。如实回答以获得准确结果。',
        'faq_q3': '如何更改密码？',
        'faq_a3': '打开个人资料页面，选择“隐私与安全”，然后输入旧密码和新密码。',
        'faq_q4': '如何更改个人资料照片？',
        'faq_a4': '打开个人资料，选择“编辑个人资料”，然后点击相机图标从相册或相机选择新照片。',
        'faq_q5': '我的数据安全吗？',
        'faq_a5': '是的，我们使用强加密来保护您的数据。所有信息都被安全存储，不会与第三方共享。',
        'email_support': '电子邮箱支持',
        'phone_label': '电话',
        'hours_label': '营业时间',
        'hours_sub': '周一至周五，09:00 - 17:00',
        'contact_us': '联系我们',
        'emergency_help': '如需紧急帮助，请联系当地心理健康服务或紧急热线。',
      };
    }

    if (code.startsWith('ar')) {
      return {
        'loading_profile': 'جارٍ تحميل الملف الشخصي...',
        'not_logged_in': 'أنت لم تقم بتسجيل الدخول',
        'please_login': 'يرجى تسجيل الدخول للوصول إلى ملفك الشخصي',
        'login_now': 'تسجيل الدخول الآن',
        'account_settings': 'إعدادات الحساب',
        'edit_profile': 'تعديل الملف الشخصي',
        'edit_profile_sub': 'قم بتحديث معلوماتك',
        'privacy_security': 'الخصوصية والأمان',
        'privacy_security_sub': 'تغيير كلمة مرور حسابك',
        'language': 'اللغة',
        'others': 'أخرى',
        'help_support': 'المساعدة والدعم',
        'help_sub': 'الأسئلة الشائعة وطرق التواصل',
        'about_app': 'عن التطبيق',
        'about_sub': 'الإصدار 1.0.0',
        'logout': 'تسجيل الخروج',
        'logout_confirm': 'هل أنت متأكد أنك تريد الخروج؟',
        'cancel': 'إلغاء',
        'logging_out': 'جارٍ تسجيل الخروج...',
        'profile_updated_success': 'تم تحديث الملف الشخصي بنجاح!',
        'profile_update_failed': 'فشل في تحديث الملف الشخصي',
        'error_occurred': 'حدث خطأ: ',
        'save': 'حفظ',
        'choose_language': 'اختر اللغة',
        'close': 'إغلاق',
        'faq_title': 'الأسئلة الشائعة (FAQ)',
        'faq_q1': 'كيف أستخدم ميزة التأمل؟',
        'faq_a1':
            'يمكنك اختيار جلسة من صفحة التأمل، ثم اضغط للبدء. اتبع إرشادات التنفس المعروضة على الشاشة.',
        'faq_q2': 'كيف أجري اختبار الصحة العقلية؟',
        'faq_a2':
            'افتح الصفحة الرئيسية، ثم اختر "اختبار الصحة العقلية" في الوصول السريع. أجب بصدق للحصول على نتائج دقيقة.',
        'faq_q3': 'كيف أغير كلمة المرور؟',
        'faq_a3':
            'افتح صفحة الملف الشخصي، واختر "الخصوصية والأمان"، ثم أدخل كلمة المرور القديمة والجديدة.',
        'faq_q4': 'كيف أغير صورة الملف الشخصي؟',
        'faq_a4':
            'افتح الملف الشخصي، اختر "تعديل الملف الشخصي"، ثم اضغط أيقونة الكاميرا لاختيار صورة جديدة من المعرض أو الكاميرا.',
        'faq_q5': 'هل بياناتي آمنة؟',
        'faq_a5':
            'نعم، نستخدم تشفيرًا قويًا لحماية بياناتك. يتم تخزين جميع المعلومات بأمان ولن تُشارك مع طرف ثالث.',
        'email_support': 'دعم البريد الإلكتروني',
        'phone_label': 'الهاتف',
        'hours_label': 'ساعات العمل',
        'hours_sub': 'من الإثنين إلى الجمعة، 09:00 - 17:00',
        'contact_us': 'اتصل بنا',
        'emergency_help':
            'للحصول على مساعدة طارئة، يرجى الاتصال بخدمات الصحة العقلية المحلية أو بخطوط الطوارئ.',
      };
    }

    // Default: Indonesian
    return {
      'loading_profile': 'Memuat profil...',
      'not_logged_in': 'Anda belum login',
      'please_login': 'Silakan login untuk mengakses profil',
      'login_now': 'Login Sekarang',
      'account_settings': 'Pengaturan Akun',
      'edit_profile': 'Edit Profil',
      'edit_profile_sub': 'Perbarui informasi Anda',
      'privacy_security': 'Privasi & Keamanan',
      'privacy_security_sub': 'Ganti password akun Anda',
      'language': 'Bahasa',
      'others': 'Lainnya',
      'help_support': 'Bantuan & Dukungan',
      'help_sub': 'FAQ dan kontak support',
      'about_app': 'Tentang Aplikasi',
      'about_sub': 'Versi 1.0.0',
      'logout': 'Logout',
      'logout_confirm': 'Apakah Anda yakin ingin keluar dari akun?',
      'cancel': 'Batal',
      'logging_out': 'Logging out...',
      'profile_updated_success': 'Profil berhasil diperbarui!',
      'profile_update_failed': 'Gagal memperbarui profil',
      'error_occurred': 'Terjadi kesalahan: ',
      'save': 'Simpan',
      'choose_language': 'Pilih Bahasa',
      'close': 'Tutup',
      'faq_title': 'Pertanyaan Umum (FAQ)',
      'faq_q1': 'Bagaimana cara menggunakan fitur meditasi?',
      'faq_a1':
          'Anda dapat memilih sesi meditasi dari halaman Meditasi, lalu klik untuk memulai. Ikuti panduan pernapasan yang muncul di layar.',
      'faq_q2': 'Bagaimana cara melakukan tes kesehatan mental?',
      'faq_a2':
          'Buka halaman Home, lalu pilih "Tes Kesehatan Mental" di bagian Akses Cepat. Jawab semua pertanyaan dengan jujur untuk mendapatkan hasil yang akurat.',
      'faq_q3': 'Bagaimana cara mengubah password?',
      'faq_a3':
          'Buka halaman Profil, pilih menu "Privasi & Keamanan", lalu masukkan password lama dan password baru yang ingin Anda gunakan.',
      'faq_q4': 'Bagaimana cara mengubah foto profil?',
      'faq_a4':
          'Buka halaman Profil, pilih menu "Edit Profil", lalu klik ikon kamera pada foto profil untuk memilih foto baru dari galeri atau kamera.',
      'faq_q5': 'Apakah data saya aman?',
      'faq_a5':
          'Ya, kami menggunakan enkripsi yang kuat untuk melindungi data Anda. Semua informasi disimpan dengan aman dan tidak akan dibagikan kepada pihak ketiga.',
      'email_support': 'Dukungan Email',
      'phone_label': 'Telepon',
      'hours_label': 'Jam Operasional',
      'hours_sub': 'Senin - Jumat, 09:00 - 17:00',
      'contact_us': 'Hubungi Kami',
      'emergency_help':
          'Untuk bantuan darurat, silakan hubungi layanan kesehatan mental terdekat atau hotline darurat.',
    };
  }

  @override
  Widget build(BuildContext context) {
    final languageService = Provider.of<LanguageService>(context);
    final L = _L(languageService);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: _backgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: _primaryGreen, strokeWidth: 3),
              const SizedBox(height: 20),
              Text(
                L['loading_profile']!,
                style: TextStyle(
                  color: _textSecondary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_currentUser == null) {
      return Scaffold(
        backgroundColor: _backgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: _primaryGreen.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person_off_outlined,
                  size: 80,
                  color: _primaryGreen.withOpacity(0.5),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                L['not_logged_in']!,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                L['please_login']!,
                style: TextStyle(fontSize: 16, color: _textSecondary),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 16,
                  ),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  L['login_now']!,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      );
    }

    String userName = _userData?['name'] ?? _currentUser?.displayName ?? 'User';
    String userEmail = _currentUser?.email ?? '';

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 🎨 Custom App Bar dengan Gradient
            SliverAppBar(
              expandedHeight: 280,
              floating: false,
              pinned: true,
              backgroundColor: _backgroundColor,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  children: [
                    // Gradient Background
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            _primaryGreen,
                            _primaryGreen.withOpacity(0.8),
                          ],
                        ),
                      ),
                    ),
                    // Decorative Circles
                    Positioned(
                      top: -50,
                      right: -50,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -30,
                      left: -30,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.05),
                        ),
                      ),
                    ),
                    // Profile Content
                    Positioned(
                      bottom: 20,
                      left: 0,
                      right: 0,
                      child: Column(
                        children: [
                          // Profile Picture dengan Border Emas
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 130,
                                height: 130,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      _accentGold,
                                      _accentGold.withOpacity(0.6),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _accentGold.withOpacity(0.4),
                                      blurRadius: 20,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: _backgroundColor,
                                  shape: BoxShape.circle,
                                ),
                                child: _currentUser?.photoURL != null
                                    ? ClipOval(
                                        child: Image.network(
                                          _currentUser!.photoURL!,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                                return _buildInitialsAvatar(
                                                  userName,
                                                );
                                              },
                                        ),
                                      )
                                    : _buildInitialsAvatar(userName),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Name
                          Text(
                            userName,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          // Email
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              userEmail,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 🎨 Profile Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const SizedBox(height: 4),

                    // Section Title
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        L['account_settings']!,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: _textPrimary,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Menu Items
                    _buildPremiumMenuItem(
                      icon: Icons.person_outline_rounded,
                      title: L['edit_profile']!,
                      subtitle: L['edit_profile_sub']!,
                      iconColor: _primaryGreen,
                      onTap: () {
                        _showEditProfileDialog();
                      },
                    ),

                    // _buildPremiumMenuItem(
                    //   icon: Icons.notifications_outlined,
                    //   title: 'Notifikasi',
                    //   subtitle: 'Atur preferensi notifikasi',
                    //   iconColor: Colors.orange,
                    //   onTap: () {
                    //     _showComingSoonSnackbar('Notifikasi');
                    //   },
                    // ),
                    _buildPremiumMenuItem(
                      icon: Icons.lock_outline_rounded,
                      title: L['privacy_security']!,
                      subtitle: L['privacy_security_sub']!,
                      iconColor: Colors.purple,
                      onTap: () {
                        _showChangePasswordDialog();
                      },
                    ),

                    Consumer<LanguageService>(
                      builder: (context, languageService, child) {
                        return _buildPremiumMenuItem(
                          icon: Icons.language_rounded,
                          title: L['language']!,
                          subtitle: languageService.getLanguageDisplayName(
                            languageService.currentLanguageCode,
                          ),
                          iconColor: Colors.blue,
                          onTap: () {
                            _showLanguageDialog();
                          },
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    // Section Title
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        L['others']!,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: _textPrimary,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    _buildPremiumMenuItem(
                      icon: Icons.help_outline_rounded,
                      title: L['help_support']!,
                      subtitle: L['help_sub']!,
                      iconColor: Colors.teal,
                      onTap: () {
                        _showHelpSupportDialog();
                      },
                    ),

                    _buildPremiumMenuItem(
                      icon: Icons.info_outline_rounded,
                      title: L['about_app']!,
                      subtitle: L['about_sub']!,
                      iconColor: Colors.indigo,
                      onTap: () {
                        _showAboutDialog();
                      },
                    ),

                    const SizedBox(height: 32),

                    // Logout Button dengan design premium
                    Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _logout,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.logout_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Logout',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialsAvatar(String name) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_primaryGreen, _primaryGreen.withOpacity(0.7)],
        ),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          _getInitials(name),
          style: const TextStyle(
            fontSize: 42,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _primaryGreen.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: _textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(color: _textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: _textSecondary.withOpacity(0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showComingSoonSnackbar(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature akan segera hadir!'),
        backgroundColor: _primaryGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showEditProfileDialog() {
    final languageService = Provider.of<LanguageService>(
      context,
      listen: false,
    );
    final L = _L(languageService);
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(
      text: _userData?['name'] ?? _currentUser?.displayName ?? '',
    );
    final ImagePicker picker = ImagePicker();
    XFile? selectedImage;
    String? currentPhotoUrl = _currentUser?.photoURL ?? _userData?['photoURL'];
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _cardColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: _primaryGreen.withOpacity(0.15),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _primaryGreen.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.person_outline_rounded,
                              color: _primaryGreen,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              L['edit_profile']!,
                              style: TextStyle(
                                color: _textPrimary,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.close, color: _textSecondary),
                            onPressed: isLoading
                                ? null
                                : () => Navigator.pop(dialogContext),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Photo Section
                      Center(
                        child: Stack(
                          children: [
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: _primaryGreen,
                                  width: 3,
                                ),
                                gradient:
                                    selectedImage != null ||
                                        currentPhotoUrl != null
                                    ? null
                                    : LinearGradient(
                                        colors: [
                                          _primaryGreen,
                                          _primaryGreen.withOpacity(0.7),
                                        ],
                                      ),
                              ),
                              child: selectedImage != null
                                  ? ClipOval(
                                      child: Image.file(
                                        File(selectedImage!.path),
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : currentPhotoUrl != null
                                  ? ClipOval(
                                      child: Image.network(
                                        currentPhotoUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return _buildInitialsAvatar(
                                                nameController.text,
                                              );
                                            },
                                      ),
                                    )
                                  : _buildInitialsAvatar(nameController.text),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: _primaryGreen,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: _cardColor,
                                    width: 3,
                                  ),
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  onPressed: isLoading
                                      ? null
                                      : () async {
                                          // Show options: Camera or Gallery
                                          final source =
                                              await showDialog<ImageSource>(
                                                context: context,
                                                builder: (context) =>
                                                    AlertDialog(
                                                      title: const Text(
                                                        'Pilih Sumber',
                                                      ),
                                                      content: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          ListTile(
                                                            leading: const Icon(
                                                              Icons.camera_alt,
                                                            ),
                                                            title: const Text(
                                                              'Kamera',
                                                            ),
                                                            onTap: () =>
                                                                Navigator.pop(
                                                                  context,
                                                                  ImageSource
                                                                      .camera,
                                                                ),
                                                          ),
                                                          ListTile(
                                                            leading: const Icon(
                                                              Icons
                                                                  .photo_library,
                                                            ),
                                                            title: const Text(
                                                              'Galeri',
                                                            ),
                                                            onTap: () =>
                                                                Navigator.pop(
                                                                  context,
                                                                  ImageSource
                                                                      .gallery,
                                                                ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                              );

                                          if (source != null) {
                                            final pickedFile = await picker
                                                .pickImage(
                                                  source: source,
                                                  imageQuality: 85,
                                                  maxWidth: 800,
                                                  maxHeight: 800,
                                                );

                                            if (pickedFile != null) {
                                              setState(() {
                                                selectedImage = pickedFile;
                                              });
                                            }
                                          }
                                        },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Name Field
                      Text(
                        'Nama',
                        style: TextStyle(
                          color: _textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: nameController,
                        enabled: !isLoading,
                        decoration: InputDecoration(
                          hintText: 'Masukkan nama Anda',
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Nama harus diisi';
                          }
                          if (value.trim().length < 2) {
                            return 'Nama minimal 2 karakter';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Buttons
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: isLoading
                                  ? null
                                  : () => Navigator.pop(dialogContext),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                    color: _textSecondary.withOpacity(0.3),
                                  ),
                                ),
                              ),
                              child: Text(
                                L['cancel']!,
                                style: TextStyle(
                                  color: _textSecondary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: isLoading
                                  ? null
                                  : () async {
                                      if (formKey.currentState!.validate()) {
                                        setState(() {
                                          isLoading = true;
                                        });

                                        try {
                                          final authService =
                                              Provider.of<AuthService>(
                                                context,
                                                listen: false,
                                              );

                                          String? photoUrl = currentPhotoUrl;

                                          if (selectedImage != null) {
                                            final uploadResult =
                                                await CloudinaryService.uploadImage(
                                                  imageFile: selectedImage!,
                                                  folder: 'user_profiles',
                                                );

                                            if (uploadResult['success'] ==
                                                true) {
                                              photoUrl =
                                                  uploadResult['url']
                                                      as String?;
                                            } else {
                                              if (context.mounted) {
                                                setState(() {
                                                  isLoading = false;
                                                });
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      uploadResult['message'] ??
                                                          'Gagal mengupload foto',
                                                    ),
                                                    backgroundColor: Colors.red,
                                                    behavior: SnackBarBehavior
                                                        .floating,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                    ),
                                                    margin:
                                                        const EdgeInsets.all(
                                                          16,
                                                        ),
                                                  ),
                                                );
                                              }
                                              return;
                                            }
                                          }

                                          // Update profil
                                          final success = await authService
                                              .updateUserProfile(
                                                uid: _currentUser!.uid,
                                                name: nameController.text
                                                    .trim(),
                                                photoURL: photoUrl,
                                              );

                                          if (context.mounted) {
                                            Navigator.pop(dialogContext);

                                            if (success) {
                                              // Reload user data
                                              await _loadUserData();

                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    L['profile_updated_success']!,
                                                  ),
                                                  backgroundColor:
                                                      _primaryGreen,
                                                  behavior:
                                                      SnackBarBehavior.floating,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                  margin: const EdgeInsets.all(
                                                    16,
                                                  ),
                                                ),
                                              );
                                            } else {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    L['profile_update_failed']!,
                                                  ),
                                                  backgroundColor: Colors.red,
                                                  behavior:
                                                      SnackBarBehavior.floating,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                  margin: const EdgeInsets.all(
                                                    16,
                                                  ),
                                                ),
                                              );
                                            }
                                          }
                                        } catch (e) {
                                          if (context.mounted) {
                                            setState(() {
                                              isLoading = false;
                                            });
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  '${L['error_occurred']!}$e',
                                                ),
                                                backgroundColor: Colors.red,
                                                behavior:
                                                    SnackBarBehavior.floating,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                margin: const EdgeInsets.all(
                                                  16,
                                                ),
                                              ),
                                            );
                                          }
                                        }
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _primaryGreen,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: isLoading
                                  ? SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                  : Text(
                                      L['save']!,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showLanguageDialog() {
    final languageService = Provider.of<LanguageService>(
      context,
      listen: false,
    );
    final L = _L(languageService);
    final currentLang = languageService.currentLanguageCode;

    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: _cardColor,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: _primaryGreen.withOpacity(0.15),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.language_rounded,
                    color: Colors.blue,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  L['choose_language']!,
                  style: TextStyle(
                    color: _textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                // Build language options dynamically, avoid duplicates
                Builder(
                  builder: (context) {
                    final allOptions = [
                      {
                        'code': 'system',
                        'name': languageService.getLanguageName('system'),
                        'flag': '🌐',
                      },
                      {
                        'code': 'id',
                        'name': languageService.getLanguageName('id'),
                        'flag': '🇮🇩',
                      },
                      {
                        'code': 'en',
                        'name': languageService.getLanguageName('en'),
                        'flag': '🇬🇧',
                      },
                      {
                        'code': 'zh',
                        'name': languageService.getLanguageName('zh'),
                        'flag': '🇨🇳',
                      },
                      {
                        'code': 'ar',
                        'name': languageService.getLanguageName('ar'),
                        'flag': '🇸🇦',
                      },
                    ];

                    final seen = <String>{};
                    final unique = allOptions.where((o) {
                      final c = o['code'] as String;
                      if (seen.contains(c)) return false;
                      seen.add(c);
                      return true;
                    }).toList();

                    return Column(
                      children: List<Widget>.generate(unique.length, (i) {
                        final opt = unique[i];
                        return Column(
                          children: [
                            _buildLanguageOption(
                              context: context,
                              languageService: languageService,
                              languageCode: opt['code'] as String,
                              languageName: opt['name'] as String,
                              flag: opt['flag'] as String,
                              isSelected:
                                  currentLang == (opt['code'] as String),
                            ),
                            const SizedBox(height: 12),
                          ],
                        );
                      }),
                    );
                  },
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                  ),
                  child: Text(
                    L['cancel']!,
                    style: TextStyle(
                      color: _textSecondary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
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

  Widget _buildLanguageOption({
    required BuildContext context,
    required LanguageService languageService,
    required String languageCode,
    required String languageName,
    required String flag,
    required bool isSelected,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? _primaryGreen.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? _primaryGreen : _textSecondary.withOpacity(0.2),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            await languageService.setLanguage(languageCode);
            if (context.mounted) {
              Navigator.pop(context);
              final snackText = languageCode == 'en'
                  ? 'Language changed to English'
                  : '$languageName telah dipilih';
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(snackText),
                  backgroundColor: _primaryGreen,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.all(16),
                ),
              );
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(flag, style: const TextStyle(fontSize: 32)),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    languageName,
                    style: TextStyle(
                      color: _textPrimary,
                      fontSize: 16,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ),
                if (isSelected)
                  Icon(Icons.check_circle, color: _primaryGreen, size: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showChangePasswordDialog() {
    final languageService = Provider.of<LanguageService>(
      context,
      listen: false,
    );
    final L = _L(languageService);
    final formKey = GlobalKey<FormState>();
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool isObscureCurrent = true;
    bool isObscureNew = true;
    bool isObscureConfirm = true;
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _cardColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: _primaryGreen.withOpacity(0.15),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.purple.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.lock_rounded,
                              color: Colors.purple,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              L['privacy_security']!,
                              style: TextStyle(
                                color: _textPrimary,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.close, color: _textSecondary),
                            onPressed: isLoading
                                ? null
                                : () => Navigator.pop(dialogContext),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Current Password
                      Text(
                        'Password Lama',
                        style: TextStyle(
                          color: _textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: currentPasswordController,
                        obscureText: isObscureCurrent,
                        enabled: !isLoading,
                        decoration: InputDecoration(
                          hintText: 'Masukkan password lama',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              isObscureCurrent
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: () {
                              setState(() {
                                isObscureCurrent = !isObscureCurrent;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password lama harus diisi';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // New Password
                      Text(
                        'Password Baru',
                        style: TextStyle(
                          color: _textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: newPasswordController,
                        obscureText: isObscureNew,
                        enabled: !isLoading,
                        decoration: InputDecoration(
                          hintText: 'Masukkan password baru (min. 6 karakter)',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              isObscureNew
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: () {
                              setState(() {
                                isObscureNew = !isObscureNew;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password baru harus diisi';
                          }
                          if (value.length < 6) {
                            return 'Password minimal 6 karakter';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Confirm Password
                      Text(
                        'Konfirmasi Password Baru',
                        style: TextStyle(
                          color: _textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: confirmPasswordController,
                        obscureText: isObscureConfirm,
                        enabled: !isLoading,
                        decoration: InputDecoration(
                          hintText: 'Ulangi password baru',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              isObscureConfirm
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: () {
                              setState(() {
                                isObscureConfirm = !isObscureConfirm;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Konfirmasi password harus diisi';
                          }
                          if (value != newPasswordController.text) {
                            return 'Password tidak sama';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Buttons
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: isLoading
                                  ? null
                                  : () => Navigator.pop(dialogContext),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                    color: _textSecondary.withOpacity(0.3),
                                  ),
                                ),
                              ),
                              child: Text(
                                L['cancel']!,
                                style: TextStyle(
                                  color: _textSecondary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: isLoading
                                  ? null
                                  : () async {
                                      if (formKey.currentState!.validate()) {
                                        setState(() {
                                          isLoading = true;
                                        });

                                        try {
                                          final authService =
                                              Provider.of<AuthService>(
                                                context,
                                                listen: false,
                                              );

                                          final result = await authService
                                              .changePassword(
                                                currentPassword:
                                                    currentPasswordController
                                                        .text,
                                                newPassword:
                                                    newPasswordController.text,
                                              );

                                          if (context.mounted) {
                                            Navigator.pop(dialogContext);

                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  result['success']
                                                      ? result['message']
                                                      : result['message'],
                                                ),
                                                backgroundColor:
                                                    result['success']
                                                    ? _primaryGreen
                                                    : Colors.red,
                                                behavior:
                                                    SnackBarBehavior.floating,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                margin: const EdgeInsets.all(
                                                  16,
                                                ),
                                              ),
                                            );
                                          }
                                        } catch (e) {
                                          if (context.mounted) {
                                            setState(() {
                                              isLoading = false;
                                            });
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  '${L['error_occurred']!}$e',
                                                ),
                                                backgroundColor: Colors.red,
                                                behavior:
                                                    SnackBarBehavior.floating,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                margin: const EdgeInsets.all(
                                                  16,
                                                ),
                                              ),
                                            );
                                          }
                                        }
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _primaryGreen,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: isLoading
                                  ? SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                  : Text(
                                      L['save']!,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showHelpSupportDialog() {
    final languageService = Provider.of<LanguageService>(
      context,
      listen: false,
    );
    final L = _L(languageService);

    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxHeight: 600),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: _cardColor,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.teal.withOpacity(0.15),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.teal.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.help_outline_rounded,
                        color: Colors.teal,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        L['help_support']!,
                        style: TextStyle(
                          color: _textPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: _textSecondary),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Content
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // FAQ Section
                        Text(
                          L['faq_title']!,
                          style: TextStyle(
                            color: _textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        _buildFAQItem(
                          question: L['faq_q1']!,
                          answer: L['faq_a1']!,
                        ),
                        const SizedBox(height: 12),

                        _buildFAQItem(
                          question: L['faq_q2']!,
                          answer: L['faq_a2']!,
                        ),
                        const SizedBox(height: 12),

                        _buildFAQItem(
                          question: L['faq_q3']!,
                          answer: L['faq_a3']!,
                        ),
                        const SizedBox(height: 12),

                        _buildFAQItem(
                          question: L['faq_q4']!,
                          answer: L['faq_a4']!,
                        ),
                        const SizedBox(height: 12),

                        _buildFAQItem(
                          question: L['faq_q5']!,
                          answer: L['faq_a5']!,
                        ),
                        const SizedBox(height: 24),

                        // Contact Support Section
                        Text(
                          L['contact_us']!,
                          style: TextStyle(
                            color: _textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        _buildContactItem(
                          icon: Icons.email_outlined,
                          title: L['email_support']!,
                          subtitle: 'bayu@gmail.com',
                          onTap: () {
                            // Bisa ditambahkan fungsi untuk membuka email client
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Email: bayu@gmail.com'),
                                backgroundColor: Colors.teal,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                margin: const EdgeInsets.all(16),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),

                        _buildContactItem(
                          icon: Icons.phone_outlined,
                          title: L['phone_label']!,
                          subtitle: '+62 0895-0909-0909',
                          onTap: () {
                            // Bisa ditambahkan fungsi untuk memanggil nomor
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  'Telepon: +62 812-3456-7890',
                                ),
                                backgroundColor: Colors.teal,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                margin: const EdgeInsets.all(16),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),

                        _buildContactItem(
                          icon: Icons.access_time_outlined,
                          title: L['hours_label']!,
                          subtitle: L['hours_sub']!,
                          onTap: null,
                        ),
                        const SizedBox(height: 24),

                        // Additional Info
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.teal.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.teal.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.teal,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  L['emergency_help']!,
                                  style: TextStyle(
                                    color: _textSecondary,
                                    fontSize: 13,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Close Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      L['close']!,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
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

  Widget _buildFAQItem({required String question, required String answer}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.teal.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.teal.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.help_outline, color: Colors.teal, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  question,
                  style: TextStyle(
                    color: _textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 28),
            child: Text(
              answer,
              style: TextStyle(
                color: _textSecondary,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.teal.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.teal.withOpacity(0.2)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.teal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: Colors.teal, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: _textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(color: _textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                if (onTap != null)
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: _textSecondary.withOpacity(0.5),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAboutDialog() {
    final languageService = Provider.of<LanguageService>(
      context,
      listen: false,
    );
    final L = _L(languageService);

    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: _cardColor,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: _primaryGreen.withOpacity(0.2),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_primaryGreen, _primaryGreen.withOpacity(0.8)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.self_improvement_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Serene',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  L['about_sub']!,
                  style: TextStyle(
                    fontSize: 14,
                    color: _textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Serene adalah aplikasi kesehatan mental yang membantu Anda menemukan ketenangan batin melalui meditasi, konseling, dan artikel edukatif.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: _textSecondary,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      L['close']!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
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
