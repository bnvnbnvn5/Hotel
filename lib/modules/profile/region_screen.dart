import 'package:flutter/material.dart';
import 'package:myapp/providers/theme_provider.dart';
import 'package:provider/provider.dart';

class RegionScreen extends StatefulWidget {
  const RegionScreen({Key? key}) : super(key: key);

  @override
  State<RegionScreen> createState() => _RegionScreenState();
}

class _RegionScreenState extends State<RegionScreen> {
  String _selectedRegion = 'Hà Nội';

  final List<Map<String, String>> _regions = [
    {'name': 'Hà Nội', 'code': 'HN'},
    {'name': 'TP. Hồ Chí Minh', 'code': 'HCM'},
    {'name': 'Đà Nẵng', 'code': 'DN'},
    {'name': 'Hải Phòng', 'code': 'HP'},
    {'name': 'Cần Thơ', 'code': 'CT'},
    {'name': 'Nha Trang', 'code': 'NT'},
    {'name': 'Phú Quốc', 'code': 'PQ'},
    {'name': 'Sapa', 'code': 'SP'},
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
          'Khu vực',
          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
        ),
      ),
      body: ListView.builder(
        itemCount: _regions.length,
        itemBuilder: (context, index) {
          final region = _regions[index];
          final isSelected = region['name'] == _selectedRegion;

          return Container(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[800] : Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: Icon(
                Icons.location_on,
                color: isSelected ? Colors.orange : (isDarkMode ? Colors.grey[400] : Colors.grey[600]),
              ),
              title: Text(
                region['name']!,
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
                  _selectedRegion = region['name']!;
                });
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Đã chọn khu vực: ${region['name']}'),
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