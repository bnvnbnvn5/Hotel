import 'package:flutter/material.dart';
import 'package:myapp/providers/theme_provider.dart';
import 'package:provider/provider.dart';

class FavoriteHotelsScreen extends StatefulWidget {
  const FavoriteHotelsScreen({Key? key}) : super(key: key);

  @override
  State<FavoriteHotelsScreen> createState() => _FavoriteHotelsScreenState();
}

class _FavoriteHotelsScreenState extends State<FavoriteHotelsScreen> {
  final List<Map<String, dynamic>> _favoriteHotels = [
    {
      'name': 'Grand Hotel Hanoi',
      'location': 'Hoàn Kiếm, Hà Nội',
      'rating': 4.5,
      'price': '2,500,000',
      'image': 'https://via.placeholder.com/150',
    },
    {
      'name': 'Luxury Resort Da Nang',
      'location': 'Sơn Trà, Đà Nẵng',
      'rating': 4.8,
      'price': '3,200,000',
      'image': 'https://via.placeholder.com/150',
    },
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
          'Khách sạn yêu thích',
          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
        ),
      ),
      body: _favoriteHotels.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 80,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[300],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Chưa có khách sạn yêu thích',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Bạn có thể thêm khách sạn vào danh sách yêu thích',
                    style: TextStyle(
                      color: isDarkMode ? Colors.grey[300] : Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: _favoriteHotels.length,
              itemBuilder: (context, index) {
                final hotel = _favoriteHotels[index];
                return Container(
                  margin: EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[800] : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16),
                    leading: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey[300],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          hotel['image'],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(Icons.hotel, color: Colors.grey[600]);
                          },
                        ),
                      ),
                    ),
                    title: Text(
                      hotel['name'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 4),
                        Text(
                          hotel['location'],
                          style: TextStyle(
                            color: isDarkMode ? Colors.grey[300] : Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.star, size: 16, color: Colors.orange),
                            SizedBox(width: 4),
                            Text(
                              '${hotel['rating']}',
                              style: TextStyle(
                                color: isDarkMode ? Colors.grey[300] : Colors.grey[600],
                              ),
                            ),
                            SizedBox(width: 16),
                            Text(
                              '${hotel['price']} VNĐ',
                              style: TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.favorite, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _favoriteHotels.removeAt(index);
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Đã xóa khỏi danh sách yêu thích'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
} 