import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../../language/appLocalizations.dart';
import 'hotel_search_bar.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:myapp/db_helper.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'map_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../profile/terms_privacy_screen.dart';
import 'confirm_booking_screen.dart';
import 'room_list_screen.dart';
import 'hotel_search_bar_for_booking.dart';

class BookingScreen extends StatefulWidget {
  final Map<String, dynamic> hotel;
  const BookingScreen({Key? key, required this.hotel}) : super(key: key);

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  int? selectedHour;
  late List<String> images;
  int maxShowImages = 4;
  DateTimeRange? selectedRange;
  bool isFavorite = false;
  int? currentUserId;

  @override
  void initState() {
    super.initState();
    images = widget.hotel['images'] ?? [
      widget.hotel['image'] ?? 'assets/images/hotel_placeholder.jpg',
      'assets/images/hotel_2.png',
      'assets/images/hotel_3.png',
      'assets/images/hotel_4.png',
      'assets/images/hotel_5.png',
    ];
    _loadUserAndFavoriteStatus();
  }

  Future<void> _loadUserAndFavoriteStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('current_user_id');
    if (userId != null) {
      setState(() {
        currentUserId = userId;
      });
      // Kiểm tra trạng thái yêu thích
      final favorite = await DBHelper.isFavorite(userId, widget.hotel['id']);
      setState(() {
        isFavorite = favorite;
      });
    }
  }

  void _showTimePickerSheet() async {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: HotelSearchBarForBooking(
            initialDate: selectedDate,
            initialTime: selectedTime,
            initialHour: selectedHour,
          ),
        );
      },
    );
    if (result != null) {
      setState(() {
        if (result['range'] != null) {
          selectedRange = result['range'];
          selectedDate = null;
          selectedTime = null;
          selectedHour = null;
        } else {
          selectedDate = result['date'];
          selectedTime = result['time'];
          selectedHour = result['hour'];
          selectedRange = null;
        }
      });
    }
  }

  String get displayCheckin {
    if (selectedDate != null && selectedTime != null && selectedHour != null) {
      final dateStr = "${selectedDate!.day.toString().padLeft(2, '0')}/${selectedDate!.month.toString().padLeft(2, '0')}/${selectedDate!.year}";
      final timeStr = selectedTime!.format(context);
      return '$timeStr, $dateStr';
    }
    return AppLocalizations(context).of("select_checkin_time");
  }

  void _openMap(String address) async {
    final query = Uri.encodeComponent(address);
    final googleUrl = 'https://www.google.com/maps/search/?api=1&query=$query';
    if (await canLaunch(googleUrl)) {
      await launch(googleUrl);
    }
  }

  Future<void> _toggleFavorite() async {
    if (currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(AppLocalizations(context).of("please_login_to_add_favorite", listen: false))),
      );
      return;
    }

    try {
      if (isFavorite) {
        // Xóa khỏi yêu thích
        await DBHelper.removeFromFavorites(currentUserId!, widget.hotel['id']);
        setState(() {
          isFavorite = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations(context).of("removed_from_favorites", listen: false))),
        );
      } else {
        // Thêm vào yêu thích
        await DBHelper.addToFavorites(currentUserId!, widget.hotel['id']);
        setState(() {
          isFavorite = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations(context).of("added_to_favorites", listen: false))),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Có lỗi xảy ra: $e')),
      );
    }
  }

  void _openMapScreen(BuildContext context, String address, String? hotelName) async {
    print('Opening map for hotel: $hotelName, address: $address');
    print('Hotel data: ${widget.hotel}');
    
    // Kiểm tra xem hotel có lat/lng không
    if (widget.hotel['lat'] != null && widget.hotel['lng'] != null) {
      print('Using lat/lng from database: ${widget.hotel['lat']}, ${widget.hotel['lng']}');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MapScreen(
            lat: widget.hotel['lat'].toDouble(),
            lng: widget.hotel['lng'].toDouble(),
            hotelName: hotelName,
          ),
        ),
      );
    } else {
      print('No lat/lng found, using geocoding...');
      // Fallback: dùng geocoding nếu không có lat/lng
      try {
        List<Location> locations = await locationFromAddress(address);
        if (locations.isNotEmpty) {
          final loc = locations.first;
          print('Geocoding result: ${loc.latitude}, ${loc.longitude}');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MapScreen(lat: loc.latitude, lng: loc.longitude, hotelName: hotelName),
            ),
          );
        }
      } catch (e) {
        print('Geocoding error: $e');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations(context).of("location_not_found"))));
      }
    }
  }

  String _amenityKey(String name) {
    // Chuyển tên tiện ích sang key dạng amenity_xxx
    return 'amenity_' + name.toLowerCase()
      .replaceAll(' ', '_')
      .replaceAll('đ', 'd')
      .replaceAll('ơ', 'o')
      .replaceAll('ư', 'u')
      .replaceAll('ô', 'o')
      .replaceAll('ă', 'a')
      .replaceAll('â', 'a')
      .replaceAll('ê', 'e')
      .replaceAll('á', 'a')
      .replaceAll('à', 'a')
      .replaceAll('ả', 'a')
      .replaceAll('ã', 'a')
      .replaceAll('ạ', 'a')
      .replaceAll('é', 'e')
      .replaceAll('è', 'e')
      .replaceAll('ẻ', 'e')
      .replaceAll('ẽ', 'e')
      .replaceAll('ẹ', 'e')
      .replaceAll('í', 'i')
      .replaceAll('ì', 'i')
      .replaceAll('ỉ', 'i')
      .replaceAll('ĩ', 'i')
      .replaceAll('ị', 'i')
      .replaceAll('ó', 'o')
      .replaceAll('ò', 'o')
      .replaceAll('ỏ', 'o')
      .replaceAll('õ', 'o')
      .replaceAll('ọ', 'o')
      .replaceAll('ú', 'u')
      .replaceAll('ù', 'u')
      .replaceAll('ủ', 'u')
      .replaceAll('ũ', 'u')
      .replaceAll('ụ', 'u')
      .replaceAll('ý', 'y')
      .replaceAll('ỳ', 'y')
      .replaceAll('ỷ', 'y')
      .replaceAll('ỹ', 'y')
      .replaceAll('ỵ', 'y')
      .replaceAll(RegExp(r'[^a-z0-9_]'), '');
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    // Debug: in ra dữ liệu hotel
    print('Hotel data: ${widget.hotel}');
    
    final hotel = widget.hotel;
    final String name = hotel['name'] ?? 'Tên khách sạn';
    final String address = hotel['address'] ?? 'Địa chỉ';
    final double rating = hotel['rating']?.toDouble() ?? 4.9;
    final int reviews = hotel['reviews'] ?? 50;
    final int price = hotel['price'] ?? 200000;
    final int originalPrice = hotel['originalPrice'] ?? 250000;
    final List<String> utilities = hotel['utilities'] ?? [
      'Bồn tắm cổ đại', 'Phòng xông hơi khô', 'Sen Trần', 'Gương bên giường'
    ];
    final String description = hotel['description'] ?? 'Không phải khách sạn. Đây là một vũ trụ 39 phòng – 39 thế giới riêng biệt, nơi mỗi căn phòng đều có một câu chuyện riêng';

    String infoText;
    if (selectedRange != null) {
      int days = selectedRange!.end.difference(selectedRange!.start).inDays + 1;
      String start = DateFormat('dd/MM/yyyy').format(selectedRange!.start);
      String end = DateFormat('dd/MM/yyyy').format(selectedRange!.end);
      infoText = '$days ngày | $start - $end';
    } else {
      String hourText = selectedHour != null ? '${selectedHour.toString().padLeft(2, '0')} giờ' : '02 giờ';
      String timeText = (selectedTime != null && selectedDate != null)
          ? '${selectedTime!.format(context)}, ${DateFormat('dd/MM/yyyy').format(selectedDate!)}'
          : 'Chọn giờ nhận phòng';
      infoText = '$hourText | $timeText';
    }

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
      appBar: AppBar(
        backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDarkMode ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(name, style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : (isDarkMode ? Colors.white : Colors.black)
            ),
            onPressed: () => _toggleFavorite(),
          ),
          IconButton(
            icon: Icon(Icons.share, color: isDarkMode ? Colors.white : Colors.black), 
            onPressed: () {}
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ảnh khách sạn nhiều ảnh + số lượng ảnh còn lại
            SizedBox(
              height: 200,
              child: Stack(
                children: [
                  ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: images.length > maxShowImages ? maxShowImages : images.length,
                    itemBuilder: (context, index) {
                      if (index == maxShowImages - 1 && images.length > maxShowImages) {
                        return Stack(
                          children: [
                            Container(
                              margin: EdgeInsets.only(right: 8),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.asset(images[index], width: 180, height: 200, fit: BoxFit.cover),
                              ),
                            ),
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Center(
                                  child: Text(
                                    "+${images.length - maxShowImages + 1}",
                                    style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }
                      return Container(
                        margin: EdgeInsets.only(right: 8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.asset(images[index], width: 180, height: 200, fit: BoxFit.cover),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.orange, size: 20),
                      SizedBox(width: 4),
                      Text(rating.toString(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      SizedBox(width: 4),
                      Text('($reviews ${AppLocalizations(context).of("reviews_text")})', style: TextStyle(color: isDarkMode ? Colors.grey[400] : Colors.grey)),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: isDarkMode ? Colors.white : Colors.black)),
                  SizedBox(height: 4),
                  Text(address, style: TextStyle(color: isDarkMode ? Colors.grey[400] : Colors.grey)),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.location_on, color: Colors.orange, size: 16),
                        onPressed: () => _openMapScreen(context, address, name),
                      ),
                      SizedBox(width: 4),
                      Text(AppLocalizations(context).of("distance_from_you").replaceAll("{distance}", "365"), style: TextStyle(color: isDarkMode ? Colors.grey[400] : Colors.grey)),
                    ],
                  ),
                  SizedBox(height: 16),
                  // Tiện ích
                  Text(AppLocalizations(context).of("hotel_amenities"), style: TextStyle(fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black)),
                  SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: utilities.map((u) => Padding(
                        padding: const EdgeInsets.only(right: 12.0),
                        child: Chip(
                          label: Text(AppLocalizations(context).of(_amenityKey(u))),
                          backgroundColor: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                          labelStyle: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                        ),
                      )).toList(),
                    ),
                  ),
                  SizedBox(height: 16),
                  // Giới thiệu
                  Text(AppLocalizations(context).of("about"), style: TextStyle(fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black)),
                  SizedBox(height: 4),
                  Text(AppLocalizations(context).of("hotel_description"), style: TextStyle(color: isDarkMode ? Colors.grey[300] : Colors.black)),
                  SizedBox(height: 16),
                  // Giờ nhận phòng/trả phòng
                  Text(AppLocalizations(context).of("checkin_checkout_times"), style: TextStyle(fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black)),
                  SizedBox(height: 4),
                  Table(
                    columnWidths: {0: FlexColumnWidth(2), 1: FlexColumnWidth(3)},
                    children: [
                      TableRow(children: [
                        Text(AppLocalizations(context).of("by_hour"), style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
                        Text(AppLocalizations(context).of("from_to").replaceAll("{start}", "00:00").replaceAll("{end}", "23:00"), style: TextStyle(color: isDarkMode ? Colors.grey[300] : Colors.black))
                      ]),
                      TableRow(children: [
                        Text(AppLocalizations(context).of("overnight"), style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
                        Text(AppLocalizations(context).of("from_to").replaceAll("{start}", "22:00").replaceAll("{end}", "12:00"), style: TextStyle(color: isDarkMode ? Colors.grey[300] : Colors.black))
                      ]),
                      TableRow(children: [
                        Text(AppLocalizations(context).of("by_day"), style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
                        Text(AppLocalizations(context).of("from_to").replaceAll("{start}", "14:00").replaceAll("{end}", "12:00"), style: TextStyle(color: isDarkMode ? Colors.grey[300] : Colors.black))
                      ]),
                    ],
                  ),
                  SizedBox(height: 80), // Để tránh bị che bởi bottom bar
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[800] : Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _showTimePickerSheet,
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                          color: isDarkMode ? Colors.grey[700] : Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                            Icon(Icons.access_time, color: isDarkMode ? Colors.white : Colors.orange),
                          SizedBox(width: 8),
                            Text(
                              infoText,
                              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: isDarkMode ? Colors.grey[800] : Colors.white,
            child: ElevatedButton(
              onPressed: () {
                // Chuyển sang màn hình danh sách phòng, truyền thông tin thời gian và hotel
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RoomListScreen(
                      hotel: hotel,
                      selectedDate: selectedDate,
                      selectedTime: selectedTime,
                      selectedHour: selectedHour,
                      selectedRange: selectedRange,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isDarkMode ? Colors.blue : Colors.orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                padding: EdgeInsets.symmetric(vertical: 18),
              ),
              child: Text(AppLocalizations(context).of("select_room"), style: TextStyle(fontSize: 18, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
} 