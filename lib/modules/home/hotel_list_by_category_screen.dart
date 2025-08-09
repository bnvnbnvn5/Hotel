import 'package:flutter/material.dart';
import '../../language/appLocalizations.dart';
import '../../db_helper.dart';
import '../../widgets/hotel_card.dart';
import 'booking_screen.dart';

class HotelListByCategoryScreen extends StatefulWidget {
  final String category; // 'flash_sale', 'top_rated', 'new_hotels'
  final String title;

  const HotelListByCategoryScreen({
    super.key,
    required this.category,
    required this.title,
  });

  @override
  State<HotelListByCategoryScreen> createState() => _HotelListByCategoryScreenState();
}

class _HotelListByCategoryScreenState extends State<HotelListByCategoryScreen> {
  List<Map<String, dynamic>> hotels = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHotels();
  }

  Future<void> _loadHotels() async {
    try {
      final allHotels = await DBHelper.getHotels();
      List<Map<String, dynamic>> filteredHotels = [];

      switch (widget.category) {
        case 'flash_sale':
          filteredHotels = allHotels.where((h) => h['isFlashSale'] == true).toList();
          break;
        case 'top_rated':
          filteredHotels = allHotels.where((h) => h['isTopRated'] == true).toList();
          break;
        case 'new_hotels':
          filteredHotels = allHotels.where((h) => h['isNew'] == true).toList();
          break;
        default:
          filteredHotels = allHotels;
      }

      setState(() {
        hotels = filteredHotels;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations(context).of('error_occurred')}: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.grey[50],
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
        foregroundColor: isDarkMode ? Colors.white : Colors.black,
        elevation: 1,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : hotels.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.hotel_outlined,
                        size: 80,
                        color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        AppLocalizations(context).of('no_hotels_found'),
                        style: TextStyle(
                          fontSize: 18,
                          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: hotels.length,
                    itemBuilder: (context, index) {
                      final hotel = hotels[index];
                      return HotelCard(
                        name: hotel['name'] ?? '',
                        address: hotel['address'] ?? '',
                        image: hotel['image'] ?? 'assets/images/hotel_1.jpg',
                        rating: hotel['rating']?.toDouble() ?? 0,
                        reviews: hotel['reviews'] ?? 0,
                        price: hotel['price'] ?? 0,
                        originalPrice: hotel['originalPrice'],
                        district: hotel['district'],
                        badge: hotel['isFlashSale'] == true
                            ? AppLocalizations(context).of('featured')
                            : null,
                        discountLabel: hotel['discountLabel'],
                        timeLabel: hotel['timeLabel'] ?? 
                            AppLocalizations(context).of('per_2_hours'),
                        cardHeight: 240,
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
                  ),
                ),
    );
  }
}