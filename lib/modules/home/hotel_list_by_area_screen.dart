import 'package:flutter/material.dart';
import 'booking_screen.dart';
import 'package:myapp/db_helper.dart';
import 'package:myapp/widgets/hotel_card.dart';

class HotelListByAreaScreen extends StatelessWidget {
  final String city;
  final String district;

  const HotelListByAreaScreen({
    Key? key,
    required this.city,
    required this.district,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$district, $city'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: Icon(Icons.home, color: Colors.orange),
            onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
            tooltip: 'Về trang chủ',
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: DBHelper.getHotels(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
          final filteredHotels = snapshot.data!
            .where((hotel) => hotel['city'] == city && hotel['district'] == district)
            .toList();
          if (filteredHotels.isEmpty) return Center(child: Text('Không có khách sạn nào ở khu vực này.'));
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredHotels.length,
            itemBuilder: (context, index) {
              final hotel = filteredHotels[index];
              return HotelCard(
                name: hotel['name'] ?? '',
                address: hotel['address'] ?? '',
                image: hotel['image'] ?? 'assets/images/hotel_1.jpg',
                rating: hotel['rating']?.toDouble() ?? 0,
                reviews: hotel['reviews'] ?? 0,
                price: hotel['price'] ?? 0,
                originalPrice: hotel['originalPrice'],
                district: hotel['district'],
                badge: hotel['isFlashSale'] == true ? 'Nổi bật' : null,
                discountLabel: hotel['discountLabel'],
                timeLabel: hotel['timeLabel'] ?? '/ 2 giờ',
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
        },
      ),
    );
  }
} 