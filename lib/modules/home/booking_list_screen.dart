import 'package:flutter/material.dart';
import 'package:myapp/db_helper.dart';
import 'package:myapp/providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../../language/appLocalizations.dart';

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
    final price = booking['price'] ?? 0;
    final checkin = booking['checkin'] != null 
        ? DateTime.parse(booking['checkin'])
        : null;
    final checkout = booking['checkout'] != null 
        ? DateTime.parse(booking['checkout'])
        : null;
    final status = booking['status'] ?? 'unknown';

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
                    label: 'Loại phòng',
                    value: 'Phòng $roomClass',
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    icon: Icons.attach_money,
                    label: 'Giá',
                    value: '${NumberFormat('#,###').format(price)} VNĐ',
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
                      label: 'Nhận phòng',
                      value: DateFormat('dd/MM/yyyy').format(checkin),
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      icon: Icons.logout,
                      label: 'Trả phòng',
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
        text = 'Đã đặt';
        break;
      case 'confirmed':
        color = Colors.blue;
        text = 'Đã xác nhận';
        break;
      case 'cancelled':
        color = Colors.red;
        text = 'Đã hủy';
        break;
      case 'completed':
        color = Colors.grey;
        text = 'Hoàn thành';
        break;
      default:
        color = Colors.orange;
        text = 'Chờ xử lý';
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
} 