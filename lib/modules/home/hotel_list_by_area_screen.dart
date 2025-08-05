import 'package:flutter/material.dart';
import '../../language/appLocalizations.dart';
import 'booking_screen.dart';
import 'package:myapp/db_helper.dart';
import 'package:myapp/widgets/hotel_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HotelListByAreaScreen extends StatefulWidget {
  final String city;
  final String district;

  const HotelListByAreaScreen({
    Key? key,
    required this.city,
    required this.district,
  }) : super(key: key);

  @override
  State<HotelListByAreaScreen> createState() => _HotelListByAreaScreenState();
}

class _HotelListByAreaScreenState extends State<HotelListByAreaScreen> {
  int? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('current_user_id');
    setState(() {
      _currentUserId = userId;
    });
  }

  Future<void> _handleFavoriteChanged(int hotelId, bool isFavorite) async {
    if (_currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations(context).of("please_login_to_add_favorite"))),
      );
      return;
    }

    try {
      if (isFavorite) {
        await DBHelper.addToFavorites(_currentUserId!, hotelId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations(context).of("added_to_favorites"))),
        );
      } else {
        await DBHelper.removeFromFavorites(_currentUserId!, hotelId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations(context).of("removed_from_favorites"))),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Có lỗi xảy ra: $e')),
      );
    }
  }

  Widget _buildHotelCard(Map<String, dynamic> hotel) {
    return FutureBuilder<bool>(
      future: _currentUserId != null 
        ? DBHelper.isFavorite(_currentUserId!, hotel['id'])
        : Future.value(false),
      builder: (context, snapshot) {
        final isFavorite = snapshot.data ?? false;
        return HotelCard(
          name: hotel['name'] ?? '',
          address: hotel['address'] ?? '',
          image: hotel['image'] ?? 'assets/images/hotel_1.jpg',
          rating: hotel['rating']?.toDouble() ?? 0,
          reviews: hotel['reviews'] ?? 0,
          price: hotel['price'] ?? 0,
          originalPrice: hotel['originalPrice'],
          district: hotel['district'],
          badge: hotel['isFlashSale'] == true ? AppLocalizations(context).of("featured") : null,
          discountLabel: hotel['discountLabel'],
          timeLabel: hotel['timeLabel'] ?? AppLocalizations(context).of("per_hour"),
          isFavorite: isFavorite,
          onFavoriteChanged: (favorite) => _handleFavoriteChanged(hotel['id'], favorite),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BookingScreen(hotel: hotel),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.district}, ${widget.city}'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: Icon(Icons.home, color: Colors.orange),
            onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                         tooltip: AppLocalizations(context).of("go_home"),
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: DBHelper.getHotels(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
          final filteredHotels = snapshot.data!
            .where((hotel) => hotel['city'] == widget.city && hotel['district'] == widget.district)
            .toList();
          if (filteredHotels.isEmpty) return Center(child: Text(AppLocalizations(context).of("no_hotels_in_area")));
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredHotels.length,
            itemBuilder: (context, index) {
              final hotel = filteredHotels[index];
              return _buildHotelCard(hotel);
            },
          );
        },
      ),
    );
  }
} 