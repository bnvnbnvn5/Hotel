import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
    bool canApply = false;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            canApply = tempDate != null && tempTime != null && tempHour != null;
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 12),
                  Text('Chọn thời gian', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  SizedBox(height: 12),
                  // Ngày
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Nhận phòng', style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(width: 8),
                      Text(DateFormat('dd/MM/yyyy').format(tempDate ?? DateTime.now())),
                    ],
                  ),
                  SizedBox(height: 8),
                  // Calendar
                  CalendarDatePicker(
                    initialDate: tempDate ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(Duration(days: 365)),
                    onDateChanged: (date) {
                      setModalState(() {
                        tempDate = date;
                      });
                    },
                  ),
                  SizedBox(height: 8),
                  // Giờ nhận phòng
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text('Giờ nhận phòng', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
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
                  SizedBox(height: 8),
                  // Số giờ sử dụng
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text('Số giờ sử dụng', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
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
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('Xóa'),
                      ),
                      ElevatedButton(
                        onPressed: canApply
                            ? () {
                                setState(() {
                                  selectedDate = tempDate;
                                  selectedTime = tempTime;
                                  selectedHour = tempHour;
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
                  SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showDateRangeSheet() async {
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
            canApply = tempRange != null;
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 12),
                  Text('Chọn thời gian', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  SizedBox(height: 12),
                  // Ngày
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Nhận phòng', style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(width: 8),
                      if (tempRange != null)
                        Text(DateFormat('dd/MM/yyyy').format(tempRange!.start)),
                      if (tempRange == null)
                        Text('Bất kỳ'),
                    ],
                  ),
                  SizedBox(height: 8),
                  // Calendar Range Picker
                  CalendarDatePicker(
                    initialDate: tempRange?.start ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(Duration(days: 365)),
                    onDateChanged: (date) {
                      setModalState(() {
                        if (tempRange == null || date.isBefore(tempRange?.start ?? date)) {
                          tempRange = DateTimeRange(start: date, end: date);
                        } else {
                          tempRange = DateTimeRange(start: tempRange!.start, end: date);
                        }
                      });
                    },
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('Xóa'),
                      ),
                      ElevatedButton(
                        onPressed: canApply
                            ? () {
                                setState(() {
                                  selectedRange = tempRange;
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
                  SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
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
                _buildTab('Theo giờ', 0, Icons.hourglass_bottom),
                SizedBox(width: 24),
                _buildTab('Theo ngày', 1, Icons.apartment),
              ],
            ),
            SizedBox(height: 16),
            // Search box
            TextField(
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
              onTap: () {
                if (tabIndex == 0) {
                  _showTimePickerSheet();
                } else {
                  _showDateRangeSheet();
                }
              },
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
    );
  }

  Widget _buildTab(String label, int idx, IconData icon) {
    final isSelected = tabIndex == idx;
    return GestureDetector(
      onTap: () {
        setState(() {
          tabIndex = idx;
        });
      },
      child: Column(
        children: [
          Icon(icon, color: isSelected ? Colors.orange : Colors.grey),
          SizedBox(height: 4),
          Text(label, style: TextStyle(color: isSelected ? Colors.orange : Colors.grey, fontWeight: FontWeight.bold)),
          if (isSelected)
            Container(height: 2, width: 40, color: Colors.orange, margin: EdgeInsets.only(top: 2)),
        ],
      ),
    );
  }
} 