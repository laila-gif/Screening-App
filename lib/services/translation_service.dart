import 'dart:convert';
import 'package:http/http.dart' as http;

class TranslationService {
  // Uses LibreTranslate public instance. Replace endpoint if you have a private one.
  static const String _endpoint = 'https://libretranslate.de/translate';

  /// Translate [text] into [targetLang] (e.g. 'en','zh','ar','id').
  /// Returns original text on failure.
  static Future<String> translate(String text, String targetLang) async {
    if (text.trim().isEmpty) return text;
    try {
      final resp = await http
          .post(
            Uri.parse(_endpoint),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'q': text,
              'source': 'auto',
              'target': targetLang,
              'format': 'text',
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (resp.statusCode == 200) {
        final body = jsonDecode(resp.body);
        return (body['translatedText'] as String?) ?? text;
      }
    } catch (_) {}
    return text;
  }
}
