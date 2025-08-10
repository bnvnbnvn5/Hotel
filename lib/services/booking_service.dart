import 'package:sqflite/sqflite.dart';
import '../db_helper.dart';
import 'local_storage_service.dart';
import 'dart:async';

class BookingService {
  static final BookingService _instance = BookingService._internal();
  factory BookingService() => _instance;
  BookingService._internal();

  late LocalStorageService _localStorage;
  bool _isInitialized = false;

  Future<void> _initializeLocalStorage() async {
    if (!_isInitialized) {
      _localStorage = await LocalStorageService.getInstance();
      _isInitialized = true;
    }
  }

  // Tạo đặt phòng mới
  Future<int> createBooking({
    required int roomId,
    required int userId,
    required DateTime checkin,
    required DateTime checkout,
    required String status,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      // Khởi tạo local storage nếu cần
      await _initializeLocalStorage();
      
      // Kiểm tra phòng có sẵn không
      bool isAvailable = await DBHelper.isRoomAvailable(roomId, checkin, checkout);
      if (!isAvailable) {
        throw Exception('Phòng không khả dụng trong thời gian này');
      }

      // Tạo booking data
      Map<String, dynamic> bookingData = {
        'room_id': roomId,
        'user_id': userId,
        'checkin': checkin.toIso8601String(),
        'checkout': checkout.toIso8601String(),
        'status': 'booked', // Luôn set status là 'booked' khi tạo mới
        'created_at': DateTime.now().toIso8601String(),
      };

      // Thêm dữ liệu bổ sung nếu có
      if (additionalData != null) {
        bookingData.addAll(additionalData);
      }

      // Lưu vào database
      int bookingId = await DBHelper.insertBooking(bookingData);

      // Lưu thông tin tạm thời để xử lý sau
      await _localStorage.saveTempBooking({
        'booking_id': bookingId,
        'room_id': roomId,
        'user_id': userId,
        'checkin': checkin.toIso8601String(),
        'checkout': checkout.toIso8601String(),
        'status': status,
      });

      // Lên lịch tự động cập nhật trạng thái khi hết thời gian
      _scheduleStatusUpdate(bookingId, checkout);

      return bookingId;
    } catch (e) {
      print('Error creating booking: $e');
      rethrow;
    }
  }

  // Lấy danh sách đặt phòng của user
  Future<List<Map<String, dynamic>>> getUserBookings(int userId) async {
    try {
      List<Map<String, dynamic>> bookings = await DBHelper.getUserBookings(userId);
      
      // Cập nhật trạng thái dựa trên thời gian hiện tại
      for (var booking in bookings) {
        booking['status'] = _getCurrentStatus(booking);
      }
      
      return bookings;
    } catch (e) {
      print('Error getting user bookings: $e');
      return [];
    }
  }

  // Lấy trạng thái hiện tại của booking
  String _getCurrentStatus(Map<String, dynamic> booking) {
    try {
      DateTime now = DateTime.now();
      DateTime checkin = DateTime.parse(booking['checkin']);
      DateTime checkout = DateTime.parse(booking['checkout']);
      String originalStatus = booking['status'];

      // Nếu đã checkout thì trạng thái là 'completed'
      if (now.isAfter(checkout)) {
        return 'completed';
      }
      
      // Nếu đang trong thời gian checkin-checkout thì trạng thái là 'active'
      if (now.isAfter(checkin) && now.isBefore(checkout)) {
        return 'active';
      }
      
      // Nếu chưa đến thời gian checkin và status là 'booked' thì giữ nguyên
      if (originalStatus == 'booked' || originalStatus == 'confirmed') {
        return originalStatus;
      }
      
      // Nếu status khác thì trả về 'unknown'
      return 'unknown';
    } catch (e) {
      print('Error getting current status: $e');
      return booking['status'] ?? 'unknown';
    }
  }

  // Cập nhật trạng thái booking
  Future<bool> updateBookingStatus(int bookingId, String newStatus) async {
    try {
      final dbClient = await DBHelper.db;
      await dbClient.update(
        'bookings',
        {'status': newStatus},
        where: 'id = ?',
        whereArgs: [bookingId],
      );
      return true;
    } catch (e) {
      print('Error updating booking status: $e');
      return false;
    }
  }

  // Hủy đặt phòng
  Future<bool> cancelBooking(int bookingId, int userId) async {
    try {
      // Khởi tạo local storage nếu cần
      await _initializeLocalStorage();
      
      // Kiểm tra xem user có quyền hủy booking này không
      final dbClient = await DBHelper.db;
      final result = await dbClient.query(
        'bookings',
        where: 'id = ? AND user_id = ?',
        whereArgs: [bookingId, userId],
      );

      if (result.isEmpty) {
        throw Exception('Không tìm thấy booking hoặc không có quyền hủy');
      }

      // Cập nhật trạng thái thành 'cancelled'
      await updateBookingStatus(bookingId, 'cancelled');
      
      // Xóa thông tin tạm thời
      await _localStorage.clearTempBooking();
      
      return true;
    } catch (e) {
      print('Error cancelling booking: $e');
      return false;
    }
  }

  // Lên lịch tự động cập nhật trạng thái
  void _scheduleStatusUpdate(int bookingId, DateTime checkout) {
    Timer.periodic(Duration(minutes: 1), (timer) async {
      try {
        DateTime now = DateTime.now();
        
        // Nếu đã qua thời gian checkout
        if (now.isAfter(checkout)) {
          // Cập nhật trạng thái thành 'completed'
          await updateBookingStatus(bookingId, 'completed');
          
          // Dừng timer
          timer.cancel();
        }
      } catch (e) {
        print('Error in status update timer: $e');
        timer.cancel();
      }
    });
  }

  // Kiểm tra phòng có sẵn trong khoảng thời gian
  Future<bool> checkRoomAvailability(int roomId, DateTime checkin, DateTime checkout) async {
    try {
      return await DBHelper.isRoomAvailable(roomId, checkin, checkout);
    } catch (e) {
      print('Error checking room availability: $e');
      return false;
    }
  }

  // Lấy thông tin chi tiết của booking
  Future<Map<String, dynamic>?> getBookingDetails(int bookingId) async {
    try {
      final dbClient = await DBHelper.db;
      final result = await dbClient.query(
        'bookings',
        where: 'id = ?',
        whereArgs: [bookingId],
      );

      if (result.isNotEmpty) {
        Map<String, dynamic> booking = result.first;
        // Cập nhật trạng thái hiện tại
        booking['status'] = _getCurrentStatus(booking);
        return booking;
      }
      return null;
    } catch (e) {
      print('Error getting booking details: $e');
      return null;
    }
  }

  // Lấy tất cả booking cần cập nhật trạng thái
  Future<List<Map<String, dynamic>>> getBookingsNeedingStatusUpdate() async {
    try {
      final dbClient = await DBHelper.db;
      DateTime now = DateTime.now();
      
      // Lấy các booking đã qua thời gian checkout nhưng chưa được cập nhật
      final result = await dbClient.rawQuery('''
        SELECT * FROM bookings 
        WHERE checkout <= ? AND status != 'completed'
      ''', [now.toIso8601String()]);
      
      return result;
    } catch (e) {
      print('Error getting bookings needing status update: $e');
      return [];
    }
  }

  // Cập nhật trạng thái tất cả booking cần thiết
  Future<void> updateAllExpiredBookings() async {
    try {
      List<Map<String, dynamic>> expiredBookings = await getBookingsNeedingStatusUpdate();
      
      print('Found ${expiredBookings.length} expired bookings to update');
      
      for (var booking in expiredBookings) {
        print('Updating booking ${booking['id']} from status ${booking['status']} to completed');
        await updateBookingStatus(booking['id'], 'completed');
      }
      
      print('Updated ${expiredBookings.length} expired bookings');
    } catch (e) {
      print('Error updating expired bookings: $e');
    }
  }
}
