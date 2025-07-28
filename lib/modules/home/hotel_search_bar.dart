import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:myapp/db_helper.dart';
import 'booking_screen.dart';

class HotelSearchBar extends StatefulWidget {
  const HotelSearchBar({Key? key}) : super(key: key);

  @override
  State<HotelSearchBar> createState() => _HotelSearchBarState();
}

class _HotelSearchBarState extends State<HotelSearchBar> with SingleTickerProviderStateMixin {
  int tabIndex = 0; // 0: Theo giờ, 1: Theo ngày
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  int? selectedHour;
  DateTimeRange? selectedRange;
  String searchText = '';

  final List<int> hourOptions = [1, 2, 3, 4];
  final List<TimeOfDay> timeOptions = [
    TimeOfDay(hour: 15, minute: 0),
    TimeOfDay(hour: 16, minute: 0),
    TimeOfDay(hour: 17, minute: 0),
    TimeOfDay(hour: 18, minute: 0),
  ];

  String get displayCheckin {
    if (tabIndex == 0) {
      if (selectedDate != null && selectedTime != null && selectedHour != null) {
        final dateStr = DateFormat('dd/MM').format(selectedDate!);
        final timeStr = selectedTime!.format(context);
        return '$timeStr, $dateStr';
      }
      return 'Bất kỳ';
    } else {
      if (selectedRange != null) {
        final start = DateFormat('dd/MM').format(selectedRange!.start);
        final end = DateFormat('dd/MM').format(selectedRange!.end);
        return '$start - $end';
      }
      return 'Bất kỳ';
    }
  }

  void _showTimePickerSheet() async {
    DateTime? tempDate = selectedDate ?? DateTime.now();
    TimeOfDay? tempTime = selectedTime ?? timeOptions[0];
    int? tempHour = selectedHour ?? hourOptions[0];
    DateTimeRange? tempRange = selectedRange;
    bool canApply = false;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            canApply = (tabIndex == 0 && tempDate != null && tempTime != null && tempHour != null)
              || (tabIndex == 1 && tempRange != null);
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildTab('Theo giờ', 0, setModalState),
                      SizedBox(width: 16),
                      _buildTab('Theo ngày', 1, setModalState),
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
                        Text(tempDate != null
                          ? tempDate!.day.toString().padLeft(2, '0') + '/' + tempDate!.month.toString().padLeft(2, '0') + '/' + tempDate!.year.toString()
                          : ''),
                      ],
                    ),
                    SizedBox(height: 8),
                    TableCalendar(
                      firstDay: DateTime.now(),
                      lastDay: DateTime.now().add(Duration(days: 365)),
                      focusedDay: tempDate ?? DateTime.now(),
                      selectedDayPredicate: (day) => tempDate != null && isSameDay(day, tempDate),
                      calendarFormat: CalendarFormat.month,
                      rangeSelectionMode: RangeSelectionMode.disabled,
                      onDaySelected: (selected, _) {
                        setModalState(() {
                          tempDate = selected;
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
                        final isSelected = t == tempTime;
                        return ChoiceChip(
                          label: Text(t.format(context)),
                          selected: isSelected,
                          onSelected: (_) {
                            setModalState(() {
                              tempTime = t;
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
                        final isSelected = h == tempHour;
                        return ChoiceChip(
                          label: Text('$h giờ'),
                          selected: isSelected,
                          onSelected: (_) {
                            setModalState(() {
                              tempHour = h;
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
                      focusedDay: tempRange?.start ?? DateTime.now(),
                      rangeStartDay: tempRange?.start,
                      rangeEndDay: tempRange?.end,
                      calendarFormat: CalendarFormat.month,
                      rangeSelectionMode: RangeSelectionMode.toggledOn,
                      onRangeSelected: (start, end, _) {
                        setModalState(() {
                          if (start != null && end != null) {
                            tempRange = DateTimeRange(start: start, end: end);
                          } else if (start != null) {
                            tempRange = DateTimeRange(start: start, end: start);
                          } else {
                            tempRange = null;
                          }
                        });
                      },
                      selectedDayPredicate: (day) {
                        if (tempRange == null) return false;
                        return day.isAfter(tempRange!.start.subtract(Duration(days: 1))) &&
                               day.isBefore(tempRange!.end.add(Duration(days: 1)));
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
                        Text('Nhận phòng: ${tempRange != null ? DateFormat('dd/MM').format(tempRange!.start) : ''}'),
                        Text('Trả phòng: ${tempRange != null ? DateFormat('dd/MM').format(tempRange!.end) : ''}'),
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
                                setState(() {
                                  if (tabIndex == 0) {
                                    selectedDate = tempDate;
                                    selectedTime = tempTime;
                                    selectedHour = tempHour;
                                  } else {
                                    selectedRange = tempRange;
                                  }
                                });
                                Navigator.pop(context);
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
            );
          },
        );
      },
    );
  }

  Widget _buildTab(String label, int idx, void Function(void Function()) setModalState) {
    final isSelected = tabIndex == idx;
    return GestureDetector(
      onTap: () {
        setModalState(() {
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          margin: EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Tabs
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildTab('Theo giờ', 0, (fn) => setState(fn)),
                    SizedBox(width: 24),
                    _buildTab('Theo ngày', 1, (fn) => setState(fn)),
                  ],
                ),
                SizedBox(height: 16),
                // Search box
                TextField(
                  onChanged: (value) => setState(() => searchText = value),
                  decoration: InputDecoration(
                    hintText: 'Tìm địa điểm, khách sạn',
                    prefixIcon: Icon(Icons.search),
                    suffixIcon: Icon(Icons.send, color: Colors.grey),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 8),
                  ),
                ),
                SizedBox(height: 16),
                // Nhận phòng
                GestureDetector(
                  onTap: _showTimePickerSheet,
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Text('Nhận phòng', style: TextStyle(fontWeight: FontWeight.bold)),
                        Spacer(),
                        Text(displayCheckin, style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                        Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),
                // Nút tìm kiếm
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text('Tìm kiếm', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Kết quả tìm kiếm khách sạn
        Expanded(
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: DBHelper.getHotels(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
              final hotels = snapshot.data!;
              final filteredHotels = hotels.where((hotel) {
                final q = searchText.toLowerCase();
                return hotel['name']?.toLowerCase().contains(q) == true ||
                  hotel['address']?.toLowerCase().contains(q) == true ||
                  hotel['city']?.toLowerCase().contains(q) == true ||
                  hotel['district']?.toLowerCase().contains(q) == true;
              }).toList();
              if (filteredHotels.isEmpty) return Center(child: Text('Không tìm thấy khách sạn phù hợp.'));
              return ListView.builder(
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
                      subtitle: Text('${hotel['district']}, ${hotel['city']}'),
                      trailing: Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BookingScreen(hotel: hotel),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
} 