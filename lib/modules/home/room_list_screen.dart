import 'package:flutter/material.dart';
import '../../language/appLocalizations.dart';
import '../../db_helper.dart';
import 'package:intl/intl.dart';
import '../../services/pricing_service.dart';
import 'confirm_booking_screen.dart';

class RoomListScreen extends StatelessWidget {
  final Map<String, dynamic> hotel;
  final DateTime? selectedDate;
  final TimeOfDay? selectedTime;
  final int? selectedHour;
  final DateTimeRange? selectedRange;
  const RoomListScreen({Key? key, required this.hotel, this.selectedDate, this.selectedTime, this.selectedHour, this.selectedRange}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
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
        title: Text(AppLocalizations(context).of("room_list")),
        backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
        foregroundColor: isDarkMode ? Colors.white : Colors.black,
        elevation: 0.5,
      ),
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.all(16),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[700] : Colors.blue.shade50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(Icons.access_time, color: isDarkMode ? Colors.yellow : Colors.blue),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    infoText,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(AppLocalizations(context).of("change"), style: TextStyle(color: isDarkMode ? Colors.blue : Colors.blue)),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Text(AppLocalizations(context).of("checkin"), style: TextStyle(fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black)),
                  Text(nhanPhong, style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
                ],
              ),
              Icon(Icons.arrow_forward, color: isDarkMode ? Colors.white : Colors.black),
              Column(
                children: [
                  Text(AppLocalizations(context).of("checkout"), style: TextStyle(fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black)),
                  Text(traPhong, style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
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
                          color: isDarkMode ? Colors.grey[800] : Colors.white,
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
                                    Text('Class ${room['class']}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: isDarkMode ? Colors.white : Colors.black)),
                                    SizedBox(height: 4),
                                    Text('Phòng loại ${room['class']}', style: TextStyle(color: isDarkMode ? Colors.grey[300] : Colors.grey[600])),
                                    SizedBox(height: 8),
                                      Row(
                                      children: [
                                        Text('${NumberFormat('#,###').format(_previewPrice(context, hotel, room))}đ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: isDarkMode ? Colors.yellow : Colors.blue)),
                                        Spacer(),
                                        ElevatedButton(
                                          onPressed: available ? () {
                                            // Chuyển đến màn hình xác nhận đặt phòng
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => ConfirmBookingScreen(
                                                  hotel: hotel,
                                                  room: room,
                                                  selectedDate: selectedDate,
                                                  selectedTime: selectedTime,
                                                  selectedHour: selectedHour,
                                                  selectedRange: selectedRange,
                                                ),
                                              ),
                                            );
                                          } : null,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: available ? (isDarkMode ? Colors.blue : Colors.blue) : Colors.grey,
                                            foregroundColor: Colors.white,
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

  int _previewPrice(BuildContext context, Map<String, dynamic> hotel, Map<String, dynamic> room) {
    // Tính nhanh giá hiển thị trước theo lựa chọn thời gian đã chọn ở màn trước
    final RouteSettings? settings = ModalRoute.of(context)?.settings;
    // Không có access trực tiếp selections ở đây, nên dùng tham số của widget
    return PricingService.calculateTotalPrice(
      hotel: hotel,
      room: room,
      selectedDate: selectedDate,
      selectedTime: selectedTime,
      selectedHour: selectedHour,
      selectedRange: selectedRange,
    );
  }
} 