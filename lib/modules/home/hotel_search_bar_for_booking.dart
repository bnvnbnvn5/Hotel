import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../language/appLocalizations.dart';

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
  // Tạo danh sách thời gian từ 6:00 AM đến 10:00 PM
  List<TimeOfDay> get timeOptions {
    List<TimeOfDay> options = [];
    for (int hour = 6; hour <= 22; hour++) {
      options.add(TimeOfDay(hour: hour, minute: 0));
    }
    return options;
  }
  DateTimeRange? selectedRange;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.initialDate ?? DateTime.now();
    selectedTime = widget.initialTime ?? _getNextAvailableTime();
    selectedHour = widget.initialHour ?? hourOptions[0];
  }

  // Lấy thời gian khả dụng tiếp theo
  TimeOfDay _getNextAvailableTime() {
    final now = DateTime.now();
    final currentTime = TimeOfDay.fromDateTime(now);
    
    // Tìm thời gian khả dụng đầu tiên
    for (var time in timeOptions) {
      final timeDateTime = DateTime(now.year, now.month, now.day, time.hour, time.minute);
      if (timeDateTime.isAfter(now)) {
        return time;
      }
    }
    
    // Nếu không có thời gian khả dụng hôm nay, trả về thời gian đầu tiên
    return timeOptions.first;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    bool canApply = (tabIndex == 0 && selectedDate != null && selectedTime != null && selectedHour != null)
      || (tabIndex == 1 && selectedRange != null);
    return Container(
      color: isDarkMode ? Colors.grey[900] : Colors.white,
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildTab(AppLocalizations(context).of("by_time"), 0, (fn) => setState(fn), isDarkMode),
                  SizedBox(width: 16),
                  _buildTab(AppLocalizations(context).of("by_date"), 1, (fn) => setState(fn), isDarkMode),
                ],
              ),
              SizedBox(height: 8),
              if (tabIndex == 0) ...[
                Center(
                  child: Text(AppLocalizations(context).of("select_time"), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: isDarkMode ? Colors.white : Colors.black)),
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(AppLocalizations(context).of("checkin_date").replaceAll("{date}", selectedDate != null
                      ? selectedDate!.day.toString().padLeft(2, '0') + '/' + selectedDate!.month.toString().padLeft(2, '0') + '/' + selectedDate!.year.toString()
                      : ''), style: TextStyle(fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black)),
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
                      color: isDarkMode ? Colors.blue.shade200 : Colors.orange.shade200,
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: isDarkMode ? Colors.blue : Colors.orange,
                      shape: BoxShape.circle,
                    ),
                    defaultTextStyle: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                    weekendTextStyle: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                    outsideTextStyle: TextStyle(color: isDarkMode ? Colors.grey[600] : Colors.grey),
                  ),
                ),
                SizedBox(height: 12),
                Text(AppLocalizations(context).of("checkin_time"), style: TextStyle(fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black)),
                Wrap(
                  spacing: 8,
                  children: timeOptions.map((t) {
                    final isSelected = t == selectedTime;
                    final now = DateTime.now();
                    final selectedDateTime = DateTime(selectedDate!.year, selectedDate!.month, selectedDate!.day, t.hour, t.minute);
                    final isPastTime = selectedDateTime.isBefore(now);
                    
                    return ChoiceChip(
                      label: Text(t.format(context)),
                      selected: isSelected,
                      onSelected: isPastTime ? null : (_) {
                        setState(() {
                          selectedTime = t;
                        });
                      },
                      selectedColor: isDarkMode ? Colors.blue.shade100 : Colors.orange.shade100,
                      labelStyle: TextStyle(
                        color: isPastTime 
                          ? (isDarkMode ? Colors.grey[600] : Colors.grey[400])
                          : (isSelected ? (isDarkMode ? Colors.blue : Colors.orange) : (isDarkMode ? Colors.white : Colors.black))
                      ),
                      backgroundColor: isPastTime 
                        ? (isDarkMode ? Colors.grey[900] : Colors.grey[200])
                        : (isDarkMode ? Colors.grey[800] : Colors.white),
                      disabledColor: isDarkMode ? Colors.grey[900] : Colors.grey[200],
                    );
                  }).toList(),
                ),
                SizedBox(height: 12),
                Text(AppLocalizations(context).of("usage_duration"), style: TextStyle(fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black)),
                Wrap(
                  spacing: 8,
                  children: hourOptions.map((h) {
                    final isSelected = h == selectedHour;
                    return ChoiceChip(
                      label: Text('$h ' + AppLocalizations(context).of("hour")),
                      selected: isSelected,
                      onSelected: (_) {
                        setState(() {
                          selectedHour = h;
                        });
                      },
                      selectedColor: isDarkMode ? Colors.blue.shade100 : Colors.orange.shade100,
                      labelStyle: TextStyle(color: isSelected ? (isDarkMode ? Colors.blue : Colors.orange) : (isDarkMode ? Colors.white : Colors.black)),
                      backgroundColor: isDarkMode ? Colors.grey[800] : Colors.white,
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
                    Text('Trả phòng: ${selectedRange != null ? DateFormat('dd/MM').format(selectedRange!.end) : ''}'),                  ],
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
                    child: Text(AppLocalizations(context).of("clear"), style: TextStyle(color: isDarkMode ? Colors.blue : Colors.teal)),
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
                      backgroundColor: canApply ? (isDarkMode ? Colors.blue : Colors.orange) : Colors.grey.shade300,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                    child: Text(AppLocalizations(context).of("apply")),
                  ),
                ],
              ),
              SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTab(String label, int idx, void Function(void Function()) setModalState, bool isDarkMode) {
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
            color: isSelected ? (isDarkMode ? Colors.blue : Colors.orange) : (isDarkMode ? Colors.grey[400] : Colors.grey),
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}