import 'package:flutter/material.dart';

class HotelListByAreaScreen extends StatelessWidget {
  final String city;
  final String district;
  final List<Map<String, dynamic>> allHotels;

  const HotelListByAreaScreen({
    Key? key,
    required this.city,
    required this.district,
    required this.allHotels,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final filteredHotels = allHotels.where((hotel) =>
      (hotel['city'] == city && hotel['district'] == district)
    ).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('$district, $city'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: filteredHotels.isEmpty
          ? Center(child: Text('Không có khách sạn nào ở khu vực này.'))
          : ListView.builder(
              itemCount: filteredHotels.length,
              itemBuilder: (context, index) {
                final hotel = filteredHotels[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        hotel['image'] ?? 'assets/images/hotel_1.jpg',
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(hotel['name'] ?? '', maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${hotel['district']}, ${hotel['city']}', style: TextStyle(fontSize: 12)),
                        Row(
                          children: [
                            Icon(Icons.star, size: 14, color: Colors.amber),
                            SizedBox(width: 2),
                            Text('${hotel['rating']} (${hotel['reviews']})', style: TextStyle(fontSize: 12)),
                          ],
                        ),
                        if (hotel['price'] != null)
                          Text('${hotel['price']}đ', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    trailing: Icon(Icons.chevron_right),
                    onTap: () {
                      // TODO: Chuyển sang trang chi tiết khách sạn nếu muốn
                    },
                  ),
                );
              },
            ),
    );
  }
} 