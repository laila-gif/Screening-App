import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/language_service.dart';

class ArticleDetailScreen extends StatelessWidget {
  final Map<String, dynamic> article;

  const ArticleDetailScreen({Key? key, required this.article})
    : super(key: key);

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

        String localizedField(String base) {
          final key = '${base}_$langShort';
          if (article.containsKey(key) &&
              (article[key] is String) &&
              (article[key] as String).isNotEmpty) {
            return article[key] as String;
          }
          // fallback to generic key
          return (article[base] is String) ? (article[base] as String) : '';
        }

        final displayTitle = localizedField('title');
        final displayContent = localizedField('content');

        return Scaffold(
          // --- WARNA BACKGROUND DIUBAH AGAR SERASI ---
          backgroundColor: const Color(0xFFF5EFD0),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: Text(
              displayTitle,
              style: const TextStyle(color: Colors.black87, fontSize: 16),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black87),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayTitle,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      article['imagePath'],
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: (article['color'] as Color).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            article['icon'] as IconData,
                            color: article['color'] as Color,
                            size: 80,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    displayContent,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
