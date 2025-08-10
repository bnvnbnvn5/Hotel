import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LocalStorageService {
  static LocalStorageService? _instance;
  static SharedPreferences? _preferences;

  LocalStorageService._internal();

  static Future<LocalStorageService> getInstance() async {
    if (_instance == null) {
      _instance = LocalStorageService._internal();
      _preferences = await SharedPreferences.getInstance();
    }
    return _instance!;
  }

  // Lấy SharedPreferences instance
  SharedPreferences get preferences => _preferences!;

  // Lưu user session
  Future<void> saveUserSession(Map<String, dynamic> userData) async {
    await _preferences!.setString('user_session', jsonEncode(userData));
    await _preferences!.setBool('is_logged_in', true);
    await _preferences!.setInt('user_id', userData['id']);
  }

  // Lấy user session
  Future<Map<String, dynamic>?> getUserSession() async {
    String? sessionData = _preferences!.getString('user_session');
    if (sessionData != null) {
      return jsonDecode(sessionData) as Map<String, dynamic>;
    }
    return null;
  }

  // Kiểm tra user đã đăng nhập chưa
  Future<bool> isLoggedIn() async {
    return _preferences!.getBool('is_logged_in') ?? false;
  }

  // Đăng xuất
  Future<bool> logout() async {
    await _preferences!.remove('user_session');
    await _preferences!.setBool('is_logged_in', false);
    await _preferences!.remove('user_id');
    return true;
  }

  // Lưu search history
  Future<void> saveSearchHistory(List<String> searches) async {
    await _preferences!.setStringList('search_history', searches);
  }

  // Lấy search history
  List<String> getSearchHistory() {
    return _preferences!.getStringList('search_history') ?? [];
  }

  // Lưu favorite hotels
  Future<void> saveFavoriteHotels(List<int> hotelIds) async {
    List<String> hotelIdsString = hotelIds.map((id) => id.toString()).toList();
    await _preferences!.setStringList('favorite_hotels', hotelIdsString);
  }

  // Lấy favorite hotels
  List<int> getFavoriteHotels() {
    List<String> hotelIdsString = _preferences!.getStringList('favorite_hotels') ?? [];
    return hotelIdsString.map((id) => int.parse(id)).toList();
  }

  // Lưu app settings
  Future<void> saveAppSettings(Map<String, dynamic> settings) async {
    await _preferences!.setString('app_settings', jsonEncode(settings));
  }

  // Lấy app settings
  Map<String, dynamic> getAppSettings() {
    String? settingsData = _preferences!.getString('app_settings');
    if (settingsData != null) {
      return jsonDecode(settingsData) as Map<String, dynamic>;
    }
    return {};
  }

  // Lưu thông tin đặt phòng tạm thời
  Future<void> saveTempBooking(Map<String, dynamic> bookingData) async {
    await _preferences!.setString('temp_booking', jsonEncode(bookingData));
  }

  // Lấy thông tin đặt phòng tạm thời
  Future<Map<String, dynamic>?> getTempBooking() async {
    String? tempBookingData = _preferences!.getString('temp_booking');
    if (tempBookingData != null) {
      return jsonDecode(tempBookingData) as Map<String, dynamic>;
    }
    return null;
  }

  // Xóa thông tin đặt phòng tạm thời
  Future<void> clearTempBooking() async {
    await _preferences!.remove('temp_booking');
  }
}
