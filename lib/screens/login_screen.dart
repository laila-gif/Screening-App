// File: lib/screens/login_screen.dart
// 🔥 LOGIN SCREEN SUPER KEREN dengan GRADIENT & ANIMATIONS

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/language_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Map<String, String> _L() {
    final ls = Provider.of<LanguageService>(context, listen: false);
    String code = ls.currentLanguageCode == 'system'
        ? ls.currentLocale.languageCode
        : ls.currentLanguageCode;
    return {
      'title': code.startsWith('en')
          ? 'Welcome!'
          : code.startsWith('zh')
          ? '欢迎！'
          : code.startsWith('ar')
          ? 'مرحبًا!'
          : 'Selamat Datang!',
      'subtitle': code.startsWith('en')
          ? 'Login to continue your journey'
          : code.startsWith('zh')
          ? '登录以继续您的旅程'
          : code.startsWith('ar')
          ? 'تسجيل الدخول للمتابعة'
          : 'Login untuk melanjutkan perjalananmu',
      'email_label': code.startsWith('en')
          ? 'Email'
          : code.startsWith('zh')
          ? '电子邮件'
          : code.startsWith('ar')
          ? 'البريد الإلكتروني'
          : 'Email',
      'email_hint': code.startsWith('en')
          ? 'name@example.com'
          : code.startsWith('zh')
          ? 'name@contoh.com'
          : code.startsWith('ar')
          ? 'name@contoh.com'
          : 'nama@email.com',
      'password_label': code.startsWith('en')
          ? 'Password'
          : code.startsWith('zh')
          ? '密码'
          : code.startsWith('ar')
          ? 'كلمة المرور'
          : 'Password',
      'password_hint': code.startsWith('en')
          ? 'Enter your password'
          : code.startsWith('zh')
          ? '输入密码'
          : code.startsWith('ar')
          ? 'أدخل كلمة المرور'
          : 'Masukkan password',
      'forgot_password': code.startsWith('en')
          ? 'Forgot Password?'
          : code.startsWith('zh')
          ? '忘记密码？'
          : code.startsWith('ar')
          ? 'نسيت كلمة المرور؟'
          : 'Lupa Password?',
      'forgot_password_msg': code.startsWith('en')
          ? 'Forgot password feature coming soon!'
          : code.startsWith('zh')
          ? '忘记密码功能即将推出！'
          : code.startsWith('ar')
          ? 'ميزة استعادة كلمة المرور قادمة قريبًا!'
          : 'Fitur lupa password segera hadir!',
      'login_button': code.startsWith('en')
          ? 'LOGIN'
          : code.startsWith('zh')
          ? '登录'
          : code.startsWith('ar')
          ? 'تسجيل الدخول'
          : 'LOGIN',
      'login_success': code.startsWith('en')
          ? 'Login successful! Welcome back.'
          : code.startsWith('zh')
          ? '登录成功！欢迎回来。'
          : code.startsWith('ar')
          ? 'تم تسجيل الدخول بنجاح! مرحبًا بعودتك.'
          : 'Login berhasil! Selamat datang kembali.',
      'login_error': code.startsWith('en')
          ? 'An error occurred:'
          : code.startsWith('zh')
          ? '发生错误：'
          : code.startsWith('ar')
          ? 'حدث خطأ:'
          : 'Terjadi kesalahan:',
      'login_failed': code.startsWith('en')
          ? 'Login failed'
          : code.startsWith('zh')
          ? '登录失败'
          : code.startsWith('ar')
          ? 'فشل تسجيل الدخول'
          : 'Login gagal',
      'or': code.startsWith('en')
          ? 'or'
          : code.startsWith('zh')
          ? '或'
          : code.startsWith('ar')
          ? 'أو'
          : 'atau',
      'google_coming': code.startsWith('en')
          ? 'Google login coming soon!'
          : code.startsWith('zh')
          ? '谷歌登录即将推出！'
          : code.startsWith('ar')
          ? 'تسجيل الدخول عبر جوجل قادم قريبًا!'
          : 'Login dengan Google segera hadir!',
      'apple_coming': code.startsWith('en')
          ? 'Apple login coming soon!'
          : code.startsWith('zh')
          ? 'Apple 登录即将推出！'
          : code.startsWith('ar')
          ? 'تسجيل الدخول عبر Apple قادم قريبًا!'
          : 'Login dengan Apple segera hadir!',
      'no_account': code.startsWith('en')
          ? "Don't have an account?"
          : code.startsWith('zh')
          ? '还没有账号？'
          : code.startsWith('ar')
          ? 'ليس لديك حساب؟'
          : 'Belum punya akun? ',
      'register': code.startsWith('en')
          ? 'Register'
          : code.startsWith('zh')
          ? '注册'
          : code.startsWith('ar')
          ? 'سجل'
          : 'Daftar',
      'email_required': code.startsWith('en')
          ? 'Email cannot be empty'
          : code.startsWith('zh')
          ? '电子邮件不能为空'
          : code.startsWith('ar')
          ? 'لا يمكن ترك البريد الإلكتروني فارغًا'
          : 'Email tidak boleh kosong',
      'email_invalid': code.startsWith('en')
          ? 'Invalid email format'
          : code.startsWith('zh')
          ? '电子邮件格式无效'
          : code.startsWith('ar')
          ? 'تنسيق البريد الإلكتروني غير صالح'
          : 'Format email tidak valid',
      'password_required': code.startsWith('en')
          ? 'Password cannot be empty'
          : code.startsWith('zh')
          ? '密码不能为空'
          : code.startsWith('ar')
          ? 'لا يمكن ترك كلمة المرور فارغة'
          : 'Password tidak boleh kosong',
      'password_min': code.startsWith('en')
          ? 'Password must be at least 6 characters'
          : code.startsWith('zh')
          ? '密码至少6位'
          : code.startsWith('ar')
          ? 'كلمة المرور يجب أن تكون 6 أحرف على الأقل'
          : 'Password minimal 6 karakter',
    };
  }

  Future<void> _handleLogin() async {
    final L = _L();
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);

      final result = await authService.loginWithEmail(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      if (!mounted) return;

      if (result['success']) {
        _showCustomSnackBar(L['login_success']!, isError: false);

        await Future.delayed(const Duration(milliseconds: 800));
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else {
        _showCustomSnackBar(
          result['message'] ?? L['login_failed']!,
          isError: true,
        );
      }
    } catch (e) {
      if (!mounted) return;
      _showCustomSnackBar('${L['login_error']} $e', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showCustomSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message, style: const TextStyle(fontSize: 15)),
            ),
          ],
        ),
        backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: Duration(seconds: isError ? 3 : 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final L = _L();
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF4A90A4),
              const Color(0xFF5A7C5C),
              const Color(0xFF2D4A3E),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 60),

                        // Logo/Icon dengan Scale Animation
                        ScaleTransition(
                          scale: _scaleAnimation,
                          child: Center(
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 30,
                                    offset: const Offset(0, 15),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.self_improvement,
                                size: 60,
                                color: Color(0xFF2D4A3E),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Title
                        Text(
                          L['title']!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Subtitle
                        Text(
                          L['subtitle']!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w400,
                          ),
                        ),

                        const SizedBox(height: 50),

                        // Form Card
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 30,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(28),
                          child: Column(
                            children: [
                              // Email Field
                              _buildTextField(
                                controller: emailController,
                                label: L['email_label']!,
                                hint: L['email_hint']!,
                                icon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return L['email_required'];
                                  }
                                  if (!value.contains('@')) {
                                    return L['email_invalid'];
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 20),

                              // Password Field
                              _buildTextField(
                                controller: passwordController,
                                label: L['password_label']!,
                                hint: L['password_hint']!,
                                icon: Icons.lock_outline_rounded,
                                isPassword: true,
                                obscureText: _obscurePassword,
                                onTogglePassword: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return L['password_required'];
                                  }
                                  if (value.length < 6) {
                                    return L['password_min'];
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 16),

                              // Forgot Password
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: _isLoading
                                      ? null
                                      : () {
                                          _showCustomSnackBar(
                                            L['forgot_password_msg']!,
                                            isError: false,
                                          );
                                        },
                                  child: Text(
                                    L['forgot_password']!,
                                    style: TextStyle(
                                      color: const Color(
                                        0xFF2D4A3E,
                                      ).withOpacity(0.8),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 24),

                              // Login Button
                              Container(
                                width: double.infinity,
                                height: 56,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF4A90A4),
                                      Color(0xFF2D4A3E),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF2D4A3E,
                                      ).withOpacity(0.3),
                                      blurRadius: 15,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _handleLogin,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          height: 24,
                                          width: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 3,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Colors.white,
                                                ),
                                          ),
                                        )
                                      : Text(
                                          L['login_button']!,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            letterSpacing: 1.2,
                                          ),
                                        ),
                                ),
                              ),

                              const SizedBox(height: 20),

                              // Divider
                              Row(
                                children: [
                                  Expanded(
                                    child: Divider(
                                      color: Colors.grey.shade300,
                                      thickness: 1,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    child: Text(
                                      L['or']!,
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Divider(
                                      color: Colors.grey.shade300,
                                      thickness: 1,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 20),

                              // Social Login Buttons (Optional)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildSocialButton(
                                    icon: Icons.g_mobiledata_rounded,
                                    onTap: () {
                                      _showCustomSnackBar(
                                        L['google_coming']!,
                                        isError: false,
                                      );
                                    },
                                  ),
                                  const SizedBox(width: 16),
                                  _buildSocialButton(
                                    icon: Icons.apple,
                                    onTap: () {
                                      _showCustomSnackBar(
                                        L['apple_coming']!,
                                        isError: false,
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Register Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              L['no_account']!,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 15,
                              ),
                            ),
                            GestureDetector(
                              onTap: _isLoading
                                  ? null
                                  : () {
                                      Navigator.pushNamed(context, '/register');
                                    },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  L['register']!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onTogglePassword,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword && obscureText,
      keyboardType: keyboardType,
      enabled: !_isLoading,
      validator: validator,
      style: const TextStyle(fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF2D4A3E).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF2D4A3E)),
        ),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  obscureText
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: const Color(0xFF2D4A3E).withOpacity(0.6),
                ),
                onPressed: onTogglePassword,
              )
            : null,
        filled: true,
        fillColor: const Color(0xFF2D4A3E).withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: const Color(0xFF2D4A3E).withOpacity(0.1),
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF4A90A4), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, size: 32, color: const Color(0xFF2D4A3E)),
      ),
    );
  }
}
