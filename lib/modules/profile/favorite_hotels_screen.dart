import 'package:flutter/material.dart';
import 'package:myapp/providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:myapp/db_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../language/appLocalizations.dart';
import '../home/booking_screen.dart';

class FavoriteHotelsScreen extends StatefulWidget {
  const FavoriteHotelsScreen({Key? key}) : super(key: key);

  @override
  State<FavoriteHotelsScreen> createState() => _FavoriteHotelsScreenState();
}

class _FavoriteHotelsScreenState extends State<FavoriteHotelsScreen> {
  List<Map<String, dynamic>> _favoriteHotels = [];
  bool _isLoading = true;
  int? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadFavoriteHotels();
  }

  Future<void> _loadFavoriteHotels() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('current_user_id');
    
    if (userId != null) {
      setState(() {
        _currentUserId = userId;
      });
      
      final hotels = await DBHelper.getFavoriteHotels(userId);
      setState(() {
        _favoriteHotels = hotels;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _removeFromFavorites(int hotelId) async {
    if (_currentUserId == null) return;
    
    try {
      await DBHelper.removeFromFavorites(_currentUserId!, hotelId);
      await _loadFavoriteHotels(); // Reload danh sách
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã xóa khỏi danh sách yêu thích')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Có lỗi xảy ra: $e')),
      );
    }
  }

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
          AppLocalizations(context).of("favorite_hotels_title"),
          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _favoriteHotels.isEmpty
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
                        AppLocalizations(context).of("no_favorite_hotels_yet"),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        AppLocalizations(context).of("can_add_hotels_to_favorites"),
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
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BookingScreen(hotel: hotel),
                        ),
                      );
                    },
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
                          child: Image.asset(
                            hotel['image'] ?? 'assets/images/hotel_1.jpg',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(Icons.hotel, color: Colors.grey[600]);
                            },
                          ),
                        ),
                      ),
                      title: Text(
                        hotel['name'] ?? 'Tên khách sạn',
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
                            hotel['address'] ?? 'Địa chỉ',
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
                                '${hotel['rating'] ?? 0}',
                                style: TextStyle(
                                  color: isDarkMode ? Colors.grey[300] : Colors.grey[600],
                                ),
                              ),
                              SizedBox(width: 16),
                              Text(
                                '${hotel['price'] ?? 0} VNĐ',
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
                        onPressed: () => _removeFromFavorites(hotel['id']),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
} 