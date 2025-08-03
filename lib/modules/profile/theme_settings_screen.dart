import 'package:flutter/material.dart';
import 'package:myapp/providers/theme_provider.dart';
import 'package:provider/provider.dart';

class ThemeSettingsScreen extends StatefulWidget {
  const ThemeSettingsScreen({Key? key}) : super(key: key);

  @override
  State<ThemeSettingsScreen> createState() => _ThemeSettingsScreenState();
}

class _ThemeSettingsScreenState extends State<ThemeSettingsScreen> {
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
          'Giao diện',
          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _buildThemeOption(
            title: 'Chế độ sáng',
            subtitle: 'Giao diện sáng',
            icon: Icons.wb_sunny,
            isSelected: themeProvider.isLightMode,
            isDarkMode: isDarkMode,
            onTap: () {
              themeProvider.setLightMode();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Đã chuyển sang chế độ sáng'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
          ),
          
          SizedBox(height: 12),
          
          _buildThemeOption(
            title: 'Chế độ tối',
            subtitle: 'Giao diện tối',
            icon: Icons.nightlight_round,
            isSelected: !themeProvider.isLightMode,
            isDarkMode: isDarkMode,
            onTap: () {
              themeProvider.setDarkMode();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Đã chuyển sang chế độ tối'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
          ),
          
          SizedBox(height: 24),
          
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[800] : Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Thông tin',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Chế độ sáng/tối sẽ thay đổi toàn bộ giao diện ứng dụng. Bạn có thể chọn chế độ phù hợp với môi trường xung quanh.',
                  style: TextStyle(
                    color: isDarkMode ? Colors.grey[300] : Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required bool isDarkMode,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: isSelected ? Border.all(color: Colors.orange, width: 2) : null,
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? Colors.orange : (isDarkMode ? Colors.grey[400] : Colors.grey[600]),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: isDarkMode ? Colors.grey[300] : Colors.grey[600],
            fontSize: 12,
          ),
        ),
        trailing: isSelected ? Icon(
          Icons.check_circle,
          color: Colors.orange,
        ) : null,
        onTap: onTap,
      ),
    );
  }
} 