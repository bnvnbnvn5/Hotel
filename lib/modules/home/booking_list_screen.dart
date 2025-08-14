import 'package:flutter/material.dart';
import 'package:myapp/db_helper.dart';
import 'package:myapp/providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../../language/appLocalizations.dart';
import '../../services/pricing_service.dart';

class BookingListScreen extends StatefulWidget {
  const BookingListScreen({Key? key}) : super(key: key);

  @override
  State<BookingListScreen> createState() => _BookingListScreenState();
}

class _BookingListScreenState extends State<BookingListScreen> {
  List<Map<String, dynamic>> _bookings = [];
  bool _isLoading = true;
  int? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('current_user_id');
      
      if (userId != null) {
        _currentUserId = userId;
        final bookings = await DBHelper.getUserBookings(userId);
        setState(() {
          _bookings = bookings;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = !themeProvider.isLightMode;
    
    return SafeArea(
      child: Column(
        children: [
          // Custom AppBar
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: isDarkMode ? Colors.grey[900] : Colors.white,
            child: Row(
              children: [
                Text(
                  AppLocalizations(context).of("booked_rooms_title"),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _currentUserId == null
                    ? _buildLoginPrompt()
                    : _bookings.isEmpty
                        ? _buildEmptyState()
                        : _buildBookingsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginPrompt() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDarkMode = !themeProvider.isLightMode;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.login,
            size: 64,
            color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            AppLocalizations(context).of("please_login_to_view_bookings"),
            style: TextStyle(
              fontSize: 16,
              color: isDarkMode ? Colors.grey[300] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDarkMode = !themeProvider.isLightMode;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.hotel_outlined,
            size: 64,
            color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            AppLocalizations(context).of("no_booked_rooms"),
            style: TextStyle(
              fontSize: 16,
              color: isDarkMode ? Colors.grey[300] : Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            AppLocalizations(context).of("book_room_to_see_here"),
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingsList() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _bookings.length,
      itemBuilder: (context, index) {
        final booking = _bookings[index];
        return _buildBookingCard(booking);
      },
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDarkMode = !themeProvider.isLightMode;
    
    final hotelName = booking['hotel_name'] ?? 'Khách sạn không xác định';
    final address = booking['address'] ?? 'Địa chỉ không xác định';
    final roomClass = booking['room_class'] ?? 'N/A';
    final checkin = booking['checkin'] != null 
        ? DateTime.parse(booking['checkin'])
        : null;
    final checkout = booking['checkout'] != null 
        ? DateTime.parse(booking['checkout'])
        : null;
    final status = booking['status'] ?? 'unknown';
    
    // Tính giá thực tế dựa trên thời gian checkin/checkout
    final int actualPrice = _calculateActualPrice(booking, checkin, checkout);

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 2,
      color: isDarkMode ? Colors.grey[800] : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                                 Container(
                   width: 60,
                   height: 60,
                   decoration: BoxDecoration(
                     color: isDarkMode ? Colors.grey[700] : Colors.grey[200],
                     borderRadius: BorderRadius.circular(8),
                   ),
                   child: Icon(
                     Icons.hotel,
                     color: isDarkMode ? Colors.white : Colors.black,
                     size: 30,
                   ),
                 ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                                             Text(
                         hotelName,
                         style: TextStyle(
                           fontSize: 16,
                           fontWeight: FontWeight.bold,
                           color: isDarkMode ? Colors.white : Colors.black,
                         ),
                       ),
                       SizedBox(height: 4),
                       Text(
                         address,
                         style: TextStyle(
                           fontSize: 14,
                           color: isDarkMode ? Colors.grey[300] : Colors.grey[600],
                         ),
                       ),
                    ],
                  ),
                ),
                _buildStatusChip(status),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    icon: Icons.bed,
                    label: AppLocalizations(context).of("room_type"),
                    value: AppLocalizations(context).of("room") + ' $roomClass',
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    icon: Icons.attach_money,
                    label: AppLocalizations(context).of("price"),
                    value: '${NumberFormat('#,###').format(actualPrice)} ${AppLocalizations(context).of("vnd")}',
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            if (checkin != null && checkout != null)
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      icon: Icons.login,
                      label: AppLocalizations(context).of("checkin"),
                      value: DateFormat('dd/MM/yyyy').format(checkin),
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      icon: Icons.logout,
                      label: AppLocalizations(context).of("checkout"),
                      value: DateFormat('dd/MM/yyyy').format(checkout),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDarkMode = !themeProvider.isLightMode;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
            SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String text;
    
    switch (status.toLowerCase()) {
      case 'booked':
        color = Colors.green;
        text = AppLocalizations(context).of("status_booked");
        break;
      case 'confirmed':
        color = Colors.blue;
        text = AppLocalizations(context).of("status_confirmed");
        break;
      case 'cancelled':
        color = Colors.red;
        text = AppLocalizations(context).of("status_cancelled");
        break;
      case 'completed':
        color = Colors.grey;
        text = AppLocalizations(context).of("status_completed");
        break;
      default:
        color = Colors.orange;
        text = AppLocalizations(context).of("status_pending");
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
  
  int _calculateActualPrice(Map<String, dynamic> booking, DateTime? checkin, DateTime? checkout) {
    if (checkin == null || checkout == null) {
      return booking['price'] ?? 0; // Fallback về giá cũ nếu không có thời gian
    }
    
    // Tạo dữ liệu hotel và room từ booking
    final Map<String, dynamic> hotel = {
      'id': booking['hotel_id'] ?? 1,
      'name': booking['hotel_name'] ?? '',
      'address': booking['address'] ?? '',
    };
    
    final Map<String, dynamic> room = {
      'id': booking['room_id'] ?? 1,
      'class': booking['room_class'] ?? 'A',
      'price': booking['price'] ?? 0,
    };
    
    // Tính thời gian sử dụng
    final Duration duration = checkout.difference(checkin);
    final int totalHours = duration.inHours;
    final int totalDays = duration.inDays;
    
    // Nếu thời gian >= 24 giờ, tính theo ngày
    if (totalDays >= 1) {
      final DateTimeRange selectedRange = DateTimeRange(
        start: checkin,
        end: checkout.subtract(Duration(hours: 1)), // Trừ 1 giờ để tính đúng ngày
      );
      
      return PricingService.calculateTotalPrice(
        hotel: hotel,
        room: room,
        selectedRange: selectedRange,
      );
    } else {
      // Tính theo giờ
      return PricingService.calculateTotalPrice(
        hotel: hotel,
        room: room,
        selectedHour: totalHours > 0 ? totalHours : 1,
        selectedDate: checkin,
        selectedTime: TimeOfDay.fromDateTime(checkin),
      );
    }
  }
} 