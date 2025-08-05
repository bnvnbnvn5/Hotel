import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:myapp/common/common.dart' as common;
import 'package:myapp/providers/theme_provider.dart';
import 'package:myapp/utils/enum.dart';
import 'package:myapp/motel_app.dart';
import 'package:provider/provider.dart';

class AppLocalizations {
  final BuildContext context;

  AppLocalizations(this.context);

  // Load dữ liệu ngôn ngữ khi khởi tạo
  Future<void> load() async {
    final List<Map<String, String>> allTexts = [];

    try {
      List<dynamic> jsonData = json.decode(
        await DefaultAssetBundle.of(context)
            .loadString('lib/language/lang/language_text.json'),
      );

      jsonData.forEach((value) {
        if (value is Map && value['text_id'] != null) {
          Map<String, String> texts = {
            'text_id': value['text_id'] ?? '',
            'en': value['en'] ?? '',
            'vi': value['vi'] ?? '',
          };
          allTexts.add(texts);
        }
      });
      common.allTexts = allTexts; // Lưu vào biến toàn cục
    } catch (e) {
      print('Error loading language data: $e');
      common.allTexts = []; // Đặt giá trị mặc định nếu lỗi
    }
  }

  String of(String textId, {bool listen = true}) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: listen);
    LanguageType _languageType = themeProvider.languageType ?? LanguageType.en;

    if (common.allTexts == null || common.allTexts!.isEmpty) {
      return '#Language is Empty#';
    }

    final index = common.allTexts!.indexWhere((element) => element['text_id'] == textId);
    if (index != -1) {
      final languageCode = _languageType.toString().split('.').last;
      final text = common.allTexts![index][languageCode] ?? '';
      return text.isNotEmpty ? text : '#Text is Empty#';
    }
    return '#Text not found#';
  }

  // Thêm method để reload language data
  Future<void> reload() async {
    await load();
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
  _AppLocalizationsDelegate();
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'vi'].contains(locale.languageCode); // Chỉ hỗ trợ en và vi
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    // Sử dụng context từ widget root (MotelApp)
    AppLocalizations localization = AppLocalizations(applicationcontext!);
    await localization.load();
    return localization;
  }

  @override
  bool shouldReload(LocalizationsDelegate<AppLocalizations> old) => false;
}