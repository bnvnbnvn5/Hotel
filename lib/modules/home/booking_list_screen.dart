import 'package:flutter/material.dart';
import 'package:myapp/db_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

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
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Phòng đã đặt'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _currentUserId == null
              ? _buildLoginPrompt()
              : _bookings.isEmpty
                  ? _buildEmptyState()
                  : _buildBookingsList(),
    );
  }

  Widget _buildLoginPrompt() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.login,
            size: 64,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'Vui lòng đăng nhập để xem phòng đã đặt',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.hotel_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'Bạn chưa có phòng đã đặt nào',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Hãy đặt phòng để xem ở đây',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
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
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.hotel,
                    color: Colors.orange,
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
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        address,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: Colors.grey[600],
            ),
            SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
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