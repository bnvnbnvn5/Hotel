import 'package:flutter/material.dart';
import '../../language/appLocalizations.dart';
import '../../db_helper.dart';
import 'package:intl/intl.dart';
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
              color: isDarkMode ? Colors.grey[700] : Colors.orange.shade50,
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
                    style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(AppLocalizations(context).of("change"), style: TextStyle(color: isDarkMode ? Colors.blue : Colors.orange)),
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