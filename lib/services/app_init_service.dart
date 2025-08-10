import 'dart:async';
import 'local_storage_service.dart';
import 'booking_service.dart';
import '../db_helper.dart';
import '../seed_data.dart';

class AppInitService {
  static final AppInitService _instance = AppInitService._internal();
  factory AppInitService() => _instance;

  late final LocalStorageService _localStorage;
  late final BookingService _bookingService;
  bool _isInitialized = false;

  AppInitService._internal();

  Future<void> _initializeServices() async {
    _localStorage = await LocalStorageService.getInstance();
    _bookingService = BookingService();
  }

  Future<void> initializeApp() async {
    if (_isInitialized) return;
    
    try {
      // Khởi tạo services
      await _initializeServices();
      
      // Khởi tạo database
      await DBHelper.db;
      
      // Kiểm tra xem database đã có dữ liệu chưa
      bool needsSeeding = await _checkIfNeedsSeeding();
      
      if (needsSeeding) {
        print('Seeding database...');
        await seedData();
        print('Database seeded successfully');
      }
      
      // Cập nhật trạng thái các booking đã hết hạn
      await _bookingService.updateAllExpiredBookings();
      
      // Khởi tạo timer để tự động cập nhật trạng thái booking
      _startAutoUpdateTimer();
      
      _isInitialized = true;
      print('App initialized successfully');
    } catch (e) {
      print('Error initializing app: $e');
      rethrow;
    }
  }

  Future<bool> _checkIfNeedsSeeding() async {
    try {
      // Kiểm tra xem có user nào trong database không
      final db = await DBHelper.db;
      final result = await db.query('users', limit: 1);
      return result.isEmpty;
    } catch (e) {
      print('Error checking if seeding is needed: $e');
      return true; // Nếu có lỗi, assume cần seeding
    }
  }

  // Timer tự động cập nhật trạng thái booking mỗi 5 phút
  void _startAutoUpdateTimer() {
    Timer.periodic(Duration(minutes: 5), (timer) async {
      try {
        await _bookingService.updateAllExpiredBookings();
      } catch (e) {
        print('Error in auto update timer: $e');
      }
    });
  }

  // Kiểm tra và khôi phục session nếu cần
  Future<bool> restoreUserSession() async {
    try {
      bool isLoggedIn = await _localStorage.isLoggedIn();
      if (isLoggedIn) {
        Map<String, dynamic>? userSession = await _localStorage.getUserSession();
        if (userSession != null) {
          // Kiểm tra user có tồn tại trong database không
          int? userId = userSession['id'];
          if (userId != null) {
            Map<String, dynamic>? user = await DBHelper.getUserById(userId);
            if (user != null) {
              return true; // Session hợp lệ
            }
          }
        }
        // Session không hợp lệ, xóa đi
        await _localStorage.logout();
      }
      return false;
    } catch (e) {
      print('Error restoring user session: $e');
      return false;
    }
  }
}
