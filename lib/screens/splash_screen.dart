// File: lib/screens/splash_screen.dart
// ✅ SPLASH SCREEN YANG SUDAH DIPERBAIKI TOTAL

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../services/language_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeInAnimation;

  @override
  void initState() {
    super.initState();

    // Setup animation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeInAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    // Start animation
    _controller.forward();

    // Start navigation sequence after first frame so Navigator is ready.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startNavigationSequence();
    });
  }

  Future<void> _startNavigationSequence() async {
    try {
      // Ensure splash is visible for at least 3 seconds
      await Future.delayed(const Duration(seconds: 3));

      if (!mounted) return;

      // Check auth status and navigate accordingly
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        // User already logged in -> Home
        print('✅ User sudah login: ${currentUser.email}');
        if (!mounted) return;
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        // User not logged in -> Login
        print('❌ User belum login, redirect ke Login');
        if (!mounted) return;
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e, st) {
      // If navigation fails, log and stay on splash (user can restart app)
      print('Error during splash navigation: $e\n$st');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageService>(
      builder: (context, languageService, child) {
        // determine effective language code: if user chose 'system', use device locale
        String code = languageService.currentLanguageCode;
        if (code == 'system') {
          code = languageService.currentLocale.languageCode;
        }

        String title;
        String subtitle;

        if (code.startsWith('en')) {
          title = 'Welcome to Serene';
          subtitle =
              'Find inner calm and build positive habits.\nStart your mindfulness journey today.';
        } else if (code.startsWith('zh')) {
          title = '欢迎来到 Serene';
          subtitle = '寻找内心的平静，养成积极习惯。\n现在开始您的正念之旅。';
        } else if (code.startsWith('ar')) {
          title = 'مرحبًا بك في Serene';
          subtitle =
              'اكتشف هدوءك الداخلي وابنِ عادات إيجابية.\nابدأ رحلة اليقظة الذهنية الآن.';
        } else {
          // default to Indonesian
          title = 'Selamat Datang di Serene';
          subtitle =
              'Temukan ketenangan batin Anda dan bangun kebiasaan positif.\nMulailah perjalanan mindfulness Anda sekarang.';
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF8FBFB),
          body: SafeArea(
            child: FadeTransition(
              opacity: _fadeInAnimation,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 20.0,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Spacer(flex: 2),

                    // ✅ LOGO
                    Image.asset(
                      'assets/images/LOGO.webp',
                      height: 250,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 250,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.self_improvement,
                              color: Color(0xFF007A7C),
                              size: 100,
                            ),
                          ),
                        );
                      },
                    ),

                    const Spacer(flex: 1),

                    // ✅ JUDUL
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A3F42),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ✅ SUBJUDUL
                    Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 17,
                        color: Color(0xFF4A6B6D),
                        height: 1.6,
                      ),
                    ),

                    const Spacer(flex: 2),

                    // ✅ LOADING INDICATOR (menggantikan tombol)
                    const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF007A7C),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),
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
