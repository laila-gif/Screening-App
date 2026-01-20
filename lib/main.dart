// File: lib/main.dart
// ✅ MAIN.DART YANG SUDAH DIPERBAIKI LENGKAP

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'dart:ui';

// Firebase imports
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Provider import
import 'package:provider/provider.dart';

// Services
import 'services/auth_service.dart';
import 'services/language_service.dart';

// Import screens
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/meditation_screen.dart';
import 'screens/counseling_screen.dart';
import 'screens/article_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';

void main() async {
  // ✅ PENTING: Inisialisasi Flutter binding
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // ✅ PENTING: Inisialisasi Firebase SEKALI SAJA
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized successfully');
  } catch (e) {
    // Jika error karena sudah diinisialisasi, abaikan
    if (e.toString().contains('duplicate-app')) {
      print('⚠️ Firebase already initialized');
    } else {
      print('❌ Firebase initialization error: $e');
      // Tetap lanjutkan app meskipun Firebase error
    }
  }

  runApp(const SereneApp());
}

class SereneApp extends StatelessWidget {
  const SereneApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ✅ Wrap dengan MultiProvider untuk state management
    return MultiProvider(
      providers: [
        // ✅ Provide AuthService ke seluruh app
        Provider<AuthService>(create: (_) => AuthService()),
        // ✅ Provide LanguageService ke seluruh app
        ChangeNotifierProvider<LanguageService>(
          create: (_) => LanguageService(),
        ),
      ],
      child: Consumer<LanguageService>(
        builder: (context, languageService, child) {
          return MaterialApp(
            title: 'Serene',
            debugShowCheckedModeBanner: false,
            locale: languageService.currentLocale,
            supportedLocales: const [
              Locale('id'), // Bahasa Indonesia
              Locale('en', 'US'),
              Locale('zh'), // Mandarin / Chinese
              Locale('ar'), // Arabic
            ],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            localeResolutionCallback: (deviceLocale, supportedLocales) {
              // Prioritize user selection from LanguageService when provided
              final selected = languageService.currentLanguageCode;

              if (selected == 'system') {
                if (deviceLocale != null) {
                  for (var s in supportedLocales) {
                    if (s.languageCode == deviceLocale.languageCode) return s;
                  }
                }
                return const Locale('en', 'US');
              }

              if (selected == 'en') return const Locale('en', 'US');
              if (selected == 'id') return const Locale('id');
              if (selected == 'zh') return const Locale('zh');
              if (selected == 'ar') return const Locale('ar');

              // Fallback
              return const Locale('en', 'US');
            },
            theme: ThemeData(
              primarySwatch: Colors.green,
              scaffoldBackgroundColor: const Color(0xFFE8E8E8),
              fontFamily: 'Roboto',
              textTheme: const TextTheme(
                headlineMedium: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
                bodyLarge: TextStyle(fontSize: 16, color: Color(0xFF1F2937)),
                bodyMedium: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
              ),
            ),
            // Set initial route
            initialRoute: '/splash',
            // Define all routes
            routes: {
              '/splash': (context) => const SplashScreen(),
              '/login': (context) => const LoginScreen(),
              '/register': (context) => const RegisterScreen(),
              '/home': (context) => const MainScreen(),
              '/meditation': (context) => const MeditationScreen(),
              '/counseling': (context) => const CounselingScreen(),
              '/article': (context) => ArticleScreen(),
              '/profile': (context) => const ProfileScreen(),
            },
            // Add onUnknownRoute to handle navigation errors
            onUnknownRoute: (settings) {
              print('⚠️ Unknown route: ${settings.name}');
              return MaterialPageRoute(
                builder: (context) => const LoginScreen(),
              );
            },
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                child: child!,
              );
            },
          );
        },
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const MeditationScreen(),
    const CounselingScreen(),
    ArticleScreen(),
    const ProfileScreen(),
  ];

  final List<IconData> _icons = [
    Icons.home_outlined,
    Icons.self_improvement_outlined,
    Icons.psychology_outlined,
    Icons.article_outlined,
    Icons.person_outline,
  ];
  // _labels will be computed in build() from LanguageService so they follow user choice

  final Color _navbarColor = const Color(0xFFEBE8DC);
  final Color _accentColor = const Color(0xFF5A7C5C);

  @override
  Widget build(BuildContext context) {
    final ls = Provider.of<LanguageService>(context, listen: false);
    final code = ls.currentLanguageCode == 'system'
        ? ls.currentLocale.languageCode
        : ls.currentLanguageCode;

    final List<String> labels = code.startsWith('en')
        ? ['Home', 'Meditation', 'Counseling', 'Articles', 'Profile']
        : code.startsWith('zh')
        ? ['首页', '冥想', '咨询', '文章', '个人资料']
        : code.startsWith('ar')
        ? ['الصفحة الرئيسية', 'تأمل', 'استشارات', 'مقالات', 'الملف']
        : ['Home', 'Meditasi', 'Konseling', 'Artikel', 'Profil'];

    return Scaffold(
      extendBody: true,
      body: _screens[_currentIndex],

      bottomNavigationBar: Container(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 65,
                decoration: BoxDecoration(
                  color: _navbarColor.withOpacity(0.92),
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(
                    color: _accentColor.withOpacity(0.25),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _accentColor.withOpacity(0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(_icons.length, (index) {
                    return _buildNavItem(index, _icons[index], labels[index]);
                  }),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;

    return Expanded(
      flex: isSelected ? 2 : 1,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _currentIndex = index;
          });
        },
        child: Container(
          color: Colors.transparent,
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? _accentColor.withOpacity(0.9)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(30),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: _accentColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    color: isSelected
                        ? Colors.white
                        : _accentColor.withOpacity(0.6),
                    size: 22,
                  ),

                  // ✅ FIX OVERFLOW: Gunakan Flexible untuk text
                  if (isSelected)
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 4.0),
                        child: Text(
                          label,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
