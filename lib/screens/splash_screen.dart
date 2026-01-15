// File: lib/screens/splash_screen.dart
// ✅ SPLASH SCREEN YANG SUDAH DIPERBAIKI TOTAL

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
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

    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    // Start animation
    _controller.forward();
    
    // ✅ CEK AUTH STATUS SETELAH 3 DETIK
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Tunggu 3 detik untuk animasi splash
    await Future.delayed(const Duration(seconds: 3));
    
    if (!mounted) return;
    
    // ✅ CEK: Apakah user sudah login?
    User? currentUser = FirebaseAuth.instance.currentUser;
    
    if (currentUser != null) {
      // ✅ User SUDAH LOGIN → Langsung ke Home
      print('✅ User sudah login: ${currentUser.email}');
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      // ❌ User BELUM LOGIN → Ke Login Screen
      print('❌ User belum login, redirect ke Login');
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFB),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeInAnimation,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
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
                const Text(
                  'Selamat Datang di Serene',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A3F42), 
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 12),

                // ✅ SUBJUDUL
                const Text(
                  'Temukan ketenangan batin Anda dan bangun kebiasaan positif.\nMulailah perjalanan mindfulness Anda sekarang.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17,
                    color: Color(0xFF4A6B6D), 
                    height: 1.6,
                  ),
                ),

                const Spacer(flex: 2),

                // ✅ LOADING INDICATOR (menggantikan tombol)
                const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF007A7C)),
                  ),
                ),
                
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}