import 'package:flutter/material.dart';
import 'package:myapp/providers/theme_provider.dart';
import 'package:myapp/utils/enum.dart';
import 'package:provider/provider.dart';
import 'package:myapp/language/appLocalizations.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({Key? key}) : super(key: key);

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String _selectedLanguage = 'Tiếng Việt';

  final List<Map<String, dynamic>> _languages = [
    {'name': 'Tiếng Việt', 'code': 'vi', 'type': LanguageType.vi},
    {'name': 'English', 'code': 'en', 'type': LanguageType.en},
  ];

  @override
  void initState() {
    super.initState();
    _loadCurrentLanguage();
  }

  void _loadCurrentLanguage() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final currentLanguage = themeProvider.languageType;
    
    if (currentLanguage == LanguageType.vi) {
      _selectedLanguage = 'Tiếng Việt';
    } else {
      _selectedLanguage = 'English';
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = !themeProvider.isLightMode;
    
    // Update selected language based on current theme provider
    _loadCurrentLanguage();

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
      appBar: AppBar(
        backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDarkMode ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Ngôn ngữ',
          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
        ),
      ),
      body: ListView.builder(
        itemCount: _languages.length,
        itemBuilder: (context, index) {
          final language = _languages[index];
          final isSelected = language['name'] == _selectedLanguage;

          return Container(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[800] : Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: Icon(
                Icons.language,
                color: isSelected ? (isDarkMode ? Colors.white : Colors.black) : (isDarkMode ? Colors.grey[400] : Colors.grey[600]),
              ),
              title: Text(
                language['name']!,
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              trailing: isSelected ? Icon(
                Icons.check,
                color: isDarkMode ? Colors.white : Colors.black,
              ) : null,
              onTap: () async {
                setState(() {
                  _selectedLanguage = language['name']!;
                });
                
                // Cập nhật ngôn ngữ thông qua ThemeProvider
                final languageType = language['type'] as LanguageType;
                await themeProvider.updateLanguage(languageType);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Đã chọn ngôn ngữ: ${language['name']}'),
                    backgroundColor: Colors.green,
                  ),
                );
                
                Navigator.pop(context);
              },
            ),
          );
        },
      ),
    );
  }
}
