import 'package:flutter/material.dart';
import 'package:myapp/providers/theme_provider.dart';
import 'package:provider/provider.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({Key? key}) : super(key: key);

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String _selectedLanguage = 'Tiếng Việt';

  final List<Map<String, String>> _languages = [
    {'name': 'Tiếng Việt', 'code': 'vi'},
    {'name': 'English', 'code': 'en'},
  ];

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = !themeProvider.isLightMode;

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
                color: isSelected ? Colors.orange : (isDarkMode ? Colors.grey[400] : Colors.grey[600]),
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
                color: Colors.orange,
              ) : null,
              onTap: () {
                setState(() {
                  _selectedLanguage = language['name']!;
                });
                
                // TODO: Implement language change
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Đã chọn ngôn ngữ: ${language['name']}'),
                    backgroundColor: Colors.orange,
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
