import 'package:flutter/material.dart';
import 'hotel_search_bar.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:myapp/db_helper.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'map_screen.dart';

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
  }

  void _showTimePickerSheet() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
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
    return 'Chọn giờ nhận phòng';
  }

  void _openMap(String address) async {
    final query = Uri.encodeComponent(address);
    final googleUrl = 'https://www.google.com/maps/search/?api=1&query=$query';
    if (await canLaunch(googleUrl)) {
      await launch(googleUrl);
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Không tìm được vị trí trên bản đồ.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(name, style: TextStyle(color: Colors.black)),
        actions: [
          IconButton(icon: Icon(Icons.favorite_border, color: Colors.black), onPressed: () {}),
          IconButton(icon: Icon(Icons.share, color: Colors.black), onPressed: () {}),
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
                      Text('($reviews đánh giá)', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  SizedBox(height: 4),
                  Text(address, style: TextStyle(color: Colors.grey)),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.location_on, color: Colors.orange, size: 16),
                        onPressed: () => _openMapScreen(context, address, name),
                      ),
                      SizedBox(width: 4),
                      Text('Cách bạn 365m', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                  SizedBox(height: 16),
                  // Tiện ích
                  Text('Tiện ích khách sạn', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: utilities.map((u) => Padding(
                        padding: const EdgeInsets.only(right: 12.0),
                        child: Chip(label: Text(u)),
                      )).toList(),
                    ),
                  ),
                  SizedBox(height: 16),
                  // Giới thiệu
                  Text('Giới thiệu', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text(description),
                  SizedBox(height: 16),
                  // Giờ nhận phòng/trả phòng
                  Text('Giờ nhận phòng/trả phòng', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Table(
                    columnWidths: {0: FlexColumnWidth(2), 1: FlexColumnWidth(3)},
                    children: [
                      TableRow(children: [Text('Theo giờ'), Text('Từ 00:00 tới 23:00')]),
                      TableRow(children: [Text('Qua đêm'), Text('Từ 22:00 tới 12:00')]),
                      TableRow(children: [Text('Theo ngày'), Text('Từ 14:00 tới 12:00')]),
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
              color: Colors.white,
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
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(Icons.access_time, color: Colors.orange),
                          SizedBox(width: 8),
                          Text(infoText),
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
            color: Colors.white,
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
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                padding: EdgeInsets.symmetric(vertical: 18),
              ),
              child: Text('Chọn phòng', style: TextStyle(fontSize: 18)),
            ),
          ),
        ],
      ),
    );
  }
}

// RoomListScreen: hiển thị các class phòng theo thứ tự D, C, B, A, S
class RoomListScreen extends StatelessWidget {
  final Map<String, dynamic> hotel;
  final DateTime? selectedDate;
  final TimeOfDay? selectedTime;
  final int? selectedHour;
  final DateTimeRange? selectedRange;
  RoomListScreen({required this.hotel, this.selectedDate, this.selectedTime, this.selectedHour, this.selectedRange});

  @override
  Widget build(BuildContext context) {
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

    String nhanPhong = selectedRange != null
      ? DateFormat('dd/MM/yyyy').format(selectedRange!.start)
      : (selectedDate != null ? DateFormat('dd/MM/yyyy').format(selectedDate!) : '');
    String traPhong = selectedRange != null
      ? DateFormat('dd/MM/yyyy').format(selectedRange!.end)
      : (selectedDate != null && selectedHour != null
          ? DateFormat('dd/MM/yyyy').format(selectedDate!.add(Duration(hours: selectedHour!)))
          : '');

    // Tính thời gian checkin/checkout thực tế
    DateTime? checkin;
    DateTime? checkout;
    if (selectedRange != null) {
      checkin = selectedRange!.start;
      checkout = selectedRange!.end.add(const Duration(days: 1)); // checkout là ngày sau ngày cuối cùng
    } else if (selectedDate != null && selectedHour != null && selectedTime != null) {
      checkin = DateTime(selectedDate!.year, selectedDate!.month, selectedDate!.day, selectedTime!.hour, selectedTime!.minute);
      checkout = checkin.add(Duration(hours: selectedHour!));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Danh sách phòng'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.all(16),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(Icons.access_time, color: Colors.orange),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    infoText,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Thay đổi', style: TextStyle(color: Colors.orange)),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Text('Nhận phòng', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(nhanPhong),
                ],
              ),
              Icon(Icons.arrow_forward),
              Column(
                children: [
                  Text('Trả phòng', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(traPhong),
                ],
              ),
            ],
          ),
          SizedBox(height: 8),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: DBHelper.getRoomsByHotel(hotel['id']),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                final rooms = snapshot.data!;
                return ListView.builder(
                  itemCount: rooms.length,
                  itemBuilder: (context, index) {
                    final room = rooms[index];
                    return FutureBuilder<bool>(
                      future: (checkin != null && checkout != null)
                        ? DBHelper.isRoomAvailable(room['id'], checkin!, checkout!)
                        : Future.value(true),
                      builder: (context, snap) {
                        final available = snap.data ?? true;
                        return Card(
                          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                                child: Image.asset(room['image'] ?? 'assets/images/hotel_1.jpg', height: 140, width: double.infinity, fit: BoxFit.cover),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Class ${room['class']}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                    SizedBox(height: 4),
                                    Text('Phòng loại ${room['class']}'),
                                    SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Text('${room['price']}đ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.orange)),
                                        Spacer(),
                                        ElevatedButton(
                                          onPressed: available ? () async {
                                            // Đặt phòng: lưu vào bookings
                                            if (checkin != null && checkout != null) {
                                              await DBHelper.insertBooking({
                                                'room_id': room['id'],
                                                'user': 'User',
                                                'checkin': checkin!.toIso8601String(),
                                                'checkout': checkout!.toIso8601String(),
                                                'status': 'booked',
                                              });
                                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đặt phòng thành công!')));
                                              Navigator.pop(context);
                                            }
                                          } : null,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: available ? Colors.orange : Colors.grey,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                          ),
                                          child: Text(available ? 'Đặt phòng' : 'Hết phòng'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ConfirmBookingScreen: giao diện xác nhận và thanh toán
class ConfirmBookingScreen extends StatelessWidget {
  final Map<String, dynamic> hotel;
  final Map<String, dynamic> room;
  final DateTime? selectedDate;
  final TimeOfDay? selectedTime;
  final int? selectedHour;
  final DateTimeRange? selectedRange;
  ConfirmBookingScreen({required this.hotel, required this.room, this.selectedDate, this.selectedTime, this.selectedHour, this.selectedRange});

  @override
  Widget build(BuildContext context) {
    final DateTimeRange? selectedRange = this.selectedRange;
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

    String nhanPhong = selectedRange != null
      ? DateFormat('dd/MM/yyyy').format(selectedRange!.start)
      : (selectedDate != null ? DateFormat('dd/MM/yyyy').format(selectedDate!) : '');
    String traPhong = selectedRange != null
      ? DateFormat('dd/MM/yyyy').format(selectedRange!.end)
      : (selectedDate != null && selectedHour != null
          ? DateFormat('dd/MM/yyyy').format(selectedDate!.add(Duration(hours: selectedHour!)))
          : '');

    return Scaffold(
      appBar: AppBar(
        title: Text('Xác nhận và thanh toán'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Lựa chọn của bạn', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(room['image'], width: 80, height: 60, fit: BoxFit.cover),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(hotel['name'] ?? '', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(room['name'] ?? '', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(hotel['address'] ?? '', style: TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Column(
                          children: [
                            Icon(Icons.access_time, color: Colors.orange),
                            Text(infoText),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  Text('Người đặt phòng', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Số điện thoại'),
                          Text('+84 966040725', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('Họ tên'),
                          Text('User31', style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      TextButton(onPressed: () {}, child: Text('Sửa', style: TextStyle(color: Colors.orange))),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text('Ưu đãi', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text('Joy Xu\nĐể dùng bạn cần tích lũy ít nhất 50.000 Joy Xu', style: TextStyle(color: Colors.grey)),
                  SizedBox(height: 16),
                  Text('Chi tiết thanh toán', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Tiền phòng'),
                      Text('${room['price']}đ', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Tổng thanh toán', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('${room['price']}đ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.orange)),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text('Chính sách huỷ phòng', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text('Hủy miễn phí trước 23:00, 20/07/2025 đối với tất cả các phương thức thanh toán.'),
                  SizedBox(height: 4),
                  Text('Gợi ý nhỏ: Hãy lựa chọn phương thức thanh toán để xem chi tiết chính sách nhé.'),
                  SizedBox(height: 4),
                  Text('Tôi đồng ý với Điều khoản và Chính sách đặt phòng.', style: TextStyle(color: Colors.orange)),
                  SizedBox(height: 4),
                  Text('Dịch vụ hỗ trợ khách hàng - Liên hệ ngay', style: TextStyle(color: Colors.orange)),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      padding: EdgeInsets.symmetric(vertical: 18),
                    ),
                    child: Text('Đặt phòng', style: TextStyle(fontSize: 18)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              padding: EdgeInsets.symmetric(vertical: 12),
              elevation: 0,
            ),
            child: Text('Đặt phòng', style: TextStyle(fontSize: 18)),
          ),
        ),
      ),
    );
  }

  String _formatDateTime(BuildContext context, DateTime? date, TimeOfDay? time) {
    if (date == null || time == null) return '';
    final d = '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    final t = time.format(context);
    return '$t, $d';
  }

  String _formatCheckout(BuildContext context, DateTime? date, TimeOfDay? time, int? hour) {
    if (date == null || time == null || hour == null) return '';
    final dt = DateTime(date.year, date.month, date.day, time.hour, time.minute).add(Duration(hours: hour));
    final d = '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    final t = TimeOfDay(hour: dt.hour, minute: dt.minute).format(context);
    return '$t, $d';
  }
}

// Widget HotelSearchBarForBooking để trả về kết quả chọn ngày/giờ cho booking
class HotelSearchBarForBooking extends StatefulWidget {
  final DateTime? initialDate;
  final TimeOfDay? initialTime;
  final int? initialHour;
  const HotelSearchBarForBooking({Key? key, this.initialDate, this.initialTime, this.initialHour}) : super(key: key);

  @override
  State<HotelSearchBarForBooking> createState() => _HotelSearchBarForBookingState();
}

class _HotelSearchBarForBookingState extends State<HotelSearchBarForBooking> {
  int tabIndex = 0; // 0: Theo giờ, 1: Theo ngày
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  int? selectedHour;
  final List<int> hourOptions = [1, 2, 3, 4];
  final List<TimeOfDay> timeOptions = [
    TimeOfDay(hour: 15, minute: 0),
    TimeOfDay(hour: 16, minute: 0),
    TimeOfDay(hour: 17, minute: 0),
    TimeOfDay(hour: 18, minute: 0),
  ];
  DateTimeRange? selectedRange;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.initialDate ?? DateTime.now();
    selectedTime = widget.initialTime ?? timeOptions[0];
    selectedHour = widget.initialHour ?? hourOptions[0];
  }

  @override
  Widget build(BuildContext context) {
    bool canApply = (tabIndex == 0 && selectedDate != null && selectedTime != null && selectedHour != null)
      || (tabIndex == 1 && selectedRange != null);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTab('Theo giờ', 0),
              SizedBox(width: 16),
              _buildTab('Theo ngày', 1),
            ],
          ),
          SizedBox(height: 8),
          if (tabIndex == 0) ...[
            Center(
              child: Text('Chọn thời gian', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Nhận phòng ', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(selectedDate != null
                  ? selectedDate!.day.toString().padLeft(2, '0') + '/' + selectedDate!.month.toString().padLeft(2, '0') + '/' + selectedDate!.year.toString()
                  : ''),
              ],
            ),
            SizedBox(height: 8),
            TableCalendar(
              firstDay: DateTime.now(),
              lastDay: DateTime.now().add(Duration(days: 365)),
              focusedDay: selectedDate ?? DateTime.now(),
              selectedDayPredicate: (day) => selectedDate != null && isSameDay(day, selectedDate),
              calendarFormat: CalendarFormat.month,
              rangeSelectionMode: RangeSelectionMode.disabled,
              onDaySelected: (selected, _) {
                setState(() {
                  selectedDate = selected;
                });
              },
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Colors.orange.shade200,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            SizedBox(height: 12),
            Text('Giờ nhận phòng', style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 8,
              children: timeOptions.map((t) {
                final isSelected = t == selectedTime;
                return ChoiceChip(
                  label: Text(t.format(context)),
                  selected: isSelected,
                  onSelected: (_) {
                    setState(() {
                      selectedTime = t;
                    });
                  },
                  selectedColor: Colors.orange.shade100,
                  labelStyle: TextStyle(color: isSelected ? Colors.orange : Colors.black),
                );
              }).toList(),
            ),
            SizedBox(height: 12),
            Text('Số giờ sử dụng', style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 8,
              children: hourOptions.map((h) {
                final isSelected = h == selectedHour;
                return ChoiceChip(
                  label: Text('$h giờ'),
                  selected: isSelected,
                  onSelected: (_) {
                    setState(() {
                      selectedHour = h;
                    });
                  },
                  selectedColor: Colors.orange.shade100,
                  labelStyle: TextStyle(color: isSelected ? Colors.orange : Colors.black),
                );
              }).toList(),
            ),
          ] else ...[
            Center(
              child: Text('Chọn ngày', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            ),
            SizedBox(height: 8),
            TableCalendar(
              firstDay: DateTime.now(),
              lastDay: DateTime.now().add(Duration(days: 365)),
              focusedDay: selectedRange?.start ?? DateTime.now(),
              rangeStartDay: selectedRange?.start,
              rangeEndDay: selectedRange?.end,
              calendarFormat: CalendarFormat.month,
              rangeSelectionMode: RangeSelectionMode.toggledOn,
              onRangeSelected: (start, end, _) {
                setState(() {
                  if (start != null && end != null) {
                    selectedRange = DateTimeRange(start: start, end: end);
                  } else if (start != null) {
                    selectedRange = DateTimeRange(start: start, end: start);
                  } else {
                    selectedRange = null;
                  }
                });
              },
              selectedDayPredicate: (day) {
                if (selectedRange == null) return false;
                return day.isAfter(selectedRange!.start.subtract(Duration(days: 1))) &&
                       day.isBefore(selectedRange!.end.add(Duration(days: 1)));
              },
              calendarStyle: CalendarStyle(
                rangeHighlightColor: Colors.orange.shade100,
                rangeStartDecoration: BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                ),
                rangeEndDecoration: BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: Colors.orange.shade200,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Nhận phòng: ${selectedRange != null ? DateFormat('dd/MM').format(selectedRange!.start) : ''}'),
                Text('Trả phòng: ${selectedRange != null ? DateFormat('dd/MM').format(selectedRange!.end) : ''}'),
              ],
            ),
          ],
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Xóa', style: TextStyle(color: Colors.teal)),
              ),
              ElevatedButton(
                onPressed: canApply
                    ? () {
                        if (tabIndex == 0) {
                          Navigator.pop(context, {
                            'date': selectedDate,
                            'time': selectedTime,
                            'hour': selectedHour,
                          });
                        } else {
                          Navigator.pop(context, {
                            'range': selectedRange,
                          });
                        }
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: canApply ? Colors.orange : Colors.grey.shade300,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                child: Text('Áp dụng'),
              ),
            ],
          ),
          SizedBox(height: 8),
        ],
        ),
      ),
    );
  }

  Widget _buildTab(String label, int idx) {
    final isSelected = tabIndex == idx;
    return GestureDetector(
      onTap: () {
        setState(() {
          tabIndex = idx;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.orange : Colors.grey,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
} 