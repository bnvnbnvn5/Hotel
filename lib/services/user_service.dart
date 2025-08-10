import '../db_helper.dart';
import 'local_storage_service.dart';

class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  late LocalStorageService _localStorage;
  bool _isInitialized = false;

  Future<void> _initializeLocalStorage() async {
    if (!_isInitialized) {
      _localStorage = await LocalStorageService.getInstance();
      _isInitialized = true;
    }
  }

  // Đăng ký user mới
  Future<int> registerUser(String email, String password, String name, String phone) async {
    try {
      // Khởi tạo local storage nếu cần
      await _initializeLocalStorage();
      
      // Kiểm tra email đã tồn tại chưa
      if (await DBHelper.emailExists(email)) {
        throw Exception('Email đã tồn tại');
      }

      // Tạo user mới
      Map<String, dynamic> userData = {
        'email': email,
        'password': password,
        'name': name,
        'phone': phone,
      };

      int userId = await DBHelper.insertUser(userData);
      
      // Lưu session
      await _localStorage.saveUserSession({
        'id': userId,
        'email': email,
        'name': name,
        'phone': phone,
      });

      return userId;
    } catch (e) {
      print('Error registering user: $e');
      rethrow;
    }
  }

  // Đăng nhập
  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      // Khởi tạo local storage nếu cần
      await _initializeLocalStorage();
      
      bool isValid = await DBHelper.validateUser(email, password);
      if (!isValid) {
        throw Exception('Email hoặc mật khẩu không đúng');
      }

      Map<String, dynamic>? user = await DBHelper.getUserByEmail(email);
      if (user != null) {
        // Lưu session
        await _localStorage.saveUserSession(user);
        return user;
      }
      return null;
    } catch (e) {
      print('Error logging in: $e');
      rethrow;
    }
  }

  // Đăng xuất
  Future<bool> logout() async {
    try {
      // Khởi tạo local storage nếu cần
      await _initializeLocalStorage();
      return await _localStorage.logout();
    } catch (e) {
      print('Error logging out: $e');
      return false;
    }
  }

  // Đổi mật khẩu
  Future<bool> changePassword(String email, String newPassword) async {
    try {
      await DBHelper.updatePassword(email, newPassword);
      return true;
    } catch (e) {
      print('Error changing password: $e');
      return false;
    }
  }

  // Cập nhật thông tin user
  Future<bool> updateUserProfile(int userId, Map<String, dynamic> userData) async {
    try {
      // Khởi tạo local storage nếu cần
      await _initializeLocalStorage();
      
      await DBHelper.updateUser(userId, userData);
      
      // Cập nhật session nếu cần
      if (await _localStorage.isLoggedIn()) {
        Map<String, dynamic>? currentSession = await _localStorage.getUserSession();
        if (currentSession != null) {
          currentSession.addAll(userData);
          await _localStorage.saveUserSession(currentSession);
        }
      }
      
      return true;
    } catch (e) {
      print('Error updating user profile: $e');
      return false;
    }
  }

  // Lấy thông tin user hiện tại
  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      // Khởi tạo local storage nếu cần
      await _initializeLocalStorage();
      
      if (await _localStorage.isLoggedIn()) {
        return await _localStorage.getUserSession();
      }
      return null;
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  // Kiểm tra trạng thái đăng nhập
  Future<bool> isLoggedIn() async {
    try {
      // Khởi tạo local storage nếu cần
      await _initializeLocalStorage();
      return await _localStorage.isLoggedIn();
    } catch (e) {
      return false;
    }
  }
}
