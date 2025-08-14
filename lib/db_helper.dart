import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class DBHelper {
  static Database? _db;

  static Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await initDb();
    return _db!;
  }

  static Future<Database> initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'hotel_app.db');
    return await openDatabase(
      path,
      version: 3, // Tăng version để thêm bảng favorite_hotels
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE hotels (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT, address TEXT, city TEXT, district TEXT, image TEXT, rating REAL, reviews INTEGER, price INTEGER,
            isNew INTEGER, isFlashSale INTEGER, isTopRated INTEGER, lat REAL, lng REAL
          );
        ''');
        await db.execute('''
          CREATE TABLE rooms (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            hotel_id INTEGER, class TEXT, price INTEGER, status TEXT, image TEXT
          );
        ''');
        await db.execute('''
          CREATE TABLE bookings (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            room_id INTEGER, user_id INTEGER, checkin TEXT, checkout TEXT, status TEXT, created_at TEXT
          );
        ''');
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            email TEXT UNIQUE, phone TEXT, password TEXT, name TEXT, 
            created_at TEXT, updated_at TEXT, is_active INTEGER DEFAULT 1
          );
        ''');
        await createFavoriteHotelsTable(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // Thêm bảng users nếu upgrade từ version 1
          await db.execute('''
            CREATE TABLE users (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              email TEXT UNIQUE, phone TEXT, password TEXT, name TEXT, 
              created_at TEXT, updated_at TEXT, is_active INTEGER DEFAULT 1
            );
          ''');
        }
        if (oldVersion < 3) {
          // Thêm bảng favorite_hotels nếu upgrade từ version < 3
          await createFavoriteHotelsTable(db);
        }
      },
    );
  }

  // CRUD cho hotels
  static Future<int> insertHotel(Map<String, dynamic> hotel) async {
    final dbClient = await db;
    // Chuyển đổi bool sang int cho các trường mới
    final data = Map<String, dynamic>.from(hotel);
    data['isNew'] = (hotel['isNew'] == true) ? 1 : 0;
    data['isFlashSale'] = (hotel['isFlashSale'] == true) ? 1 : 0;
    data['isTopRated'] = (hotel['isTopRated'] == true) ? 1 : 0;
    return await dbClient.insert('hotels', data);
  }
  
  static Future<List<Map<String, dynamic>>> getHotels() async {
    final dbClient = await db;
    final result = await dbClient.query('hotels');
    // Chuyển đổi int sang bool cho các trường mới
    return result.map((h) {
      final map = Map<String, dynamic>.from(h);
      map['isNew'] = (h['isNew'] ?? 0) == 1;
      map['isFlashSale'] = (h['isFlashSale'] ?? 0) == 1;
      map['isTopRated'] = (h['isTopRated'] ?? 0) == 1;
      return map;
    }).toList();
  }

  // CRUD cho rooms
  static Future<int> insertRoom(Map<String, dynamic> room) async {
    final dbClient = await db;
    return await dbClient.insert('rooms', room);
  }
  
  static Future<List<Map<String, dynamic>>> getRoomsByHotel(int hotelId) async {
    final dbClient = await db;
    return await dbClient.query('rooms', where: 'hotel_id = ?', whereArgs: [hotelId]);
  }

  // CRUD cho bookings
  static Future<int> insertBooking(Map<String, dynamic> booking) async {
    final dbClient = await db;
    final data = Map<String, dynamic>.from(booking);
    data['created_at'] = DateTime.now().toIso8601String();
    return await dbClient.insert('bookings', data);
  }
  
  static Future<List<Map<String, dynamic>>> getBookings() async {
    final dbClient = await db;
    return await dbClient.query('bookings');
  }

  static Future<bool> isRoomAvailable(int roomId, DateTime checkin, DateTime checkout) async {
    final dbClient = await db;
    DateTime now = DateTime.now();
    
    // Lấy các booking trùng phòng và có thời gian giao với khoảng checkin-checkout
    // Chỉ xem xét các booking có trạng thái active (đang sử dụng hoặc đã đặt)
    // Loại trừ các booking đã hoàn thành, hủy bỏ hoặc hết hạn
    final result = await dbClient.rawQuery('''
      SELECT * FROM bookings
      WHERE room_id = ?
        AND status IN ('booked', 'active', 'confirmed')
        AND NOT (
          checkout <= ? OR checkin >= ?
        )
    ''', [roomId, checkin.toIso8601String(), checkout.toIso8601String()]);
    
    // Debug: in ra thông tin để kiểm tra
    print('Checking room $roomId availability for $checkin to $checkout (current time: $now)');
    print('Found ${result.length} conflicting bookings:');
    for (var booking in result) {
      print('  Booking ID: ${booking['id']}, Status: ${booking['status']}, Checkin: ${booking['checkin']}, Checkout: ${booking['checkout']}');
    }
    
    return result.isEmpty;
  }

  // CRUD cho users
  static String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  static Future<int> insertUser(Map<String, dynamic> user) async {
    final dbClient = await db;
    final data = Map<String, dynamic>.from(user);
    data['password'] = _hashPassword(user['password']);
    data['created_at'] = DateTime.now().toIso8601String();
    data['updated_at'] = DateTime.now().toIso8601String();
    return await dbClient.insert('users', data);
  }

  static Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final dbClient = await db;
    final result = await dbClient.query(
      'users',
      where: 'email = ? AND is_active = 1',
      whereArgs: [email],
    );
    return result.isNotEmpty ? result.first : null;
  }

  static Future<Map<String, dynamic>?> getUserById(int id) async {
    final dbClient = await db;
    final result = await dbClient.query(
      'users',
      where: 'id = ? AND is_active = 1',
      whereArgs: [id],
    );
    return result.isNotEmpty ? result.first : null;
  }

  static Future<bool> validateUser(String email, String password) async {
    final user = await getUserByEmail(email);
    if (user == null) return false;
    return user['password'] == _hashPassword(password);
  }

  static Future<bool> emailExists(String email) async {
    final user = await getUserByEmail(email);
    return user != null;
  }

  static Future<void> updatePassword(String email, String newPassword) async {
    final dbClient = await db;
    await dbClient.update(
      'users',
      {
        'password': _hashPassword(newPassword),
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'email = ?',
      whereArgs: [email],
    );
  }

  static Future<List<Map<String, dynamic>>> getUserBookings(int userId) async {
    final dbClient = await db;
    return await dbClient.rawQuery('''
      SELECT b.*, h.id as hotel_id, h.name as hotel_name, h.address, r.id as room_id, r.class as room_class, r.price
      FROM bookings b
      JOIN rooms r ON b.room_id = r.id
      JOIN hotels h ON r.hotel_id = h.id
      WHERE b.user_id = ?
      ORDER BY b.created_at DESC
    ''', [userId]);
  }

  static Future<void> updateUser(int userId, Map<String, dynamic> userData) async {
    final dbClient = await db;
    final data = Map<String, dynamic>.from(userData);
    data['updated_at'] = DateTime.now().toIso8601String();
    await dbClient.update(
      'users',
      data,
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  // Thêm bảng favorite_hotels
  static Future<void> createFavoriteHotelsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS favorite_hotels (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        hotel_id INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id),
        FOREIGN KEY (hotel_id) REFERENCES hotels (id),
        UNIQUE(user_id, hotel_id)
      )
    ''');
  }

  // Thêm khách sạn vào danh sách yêu thích
  static Future<bool> addToFavorites(int userId, int hotelId) async {
    try {
      final dbClient = await db;
      await dbClient.insert('favorite_hotels', {
        'user_id': userId,
        'hotel_id': hotelId,
        'created_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      print('Error adding to favorites: $e');
      return false;
    }
  }

  // Xóa khách sạn khỏi danh sách yêu thích
  static Future<bool> removeFromFavorites(int userId, int hotelId) async {
    try {
      final dbClient = await db;
      await dbClient.delete(
        'favorite_hotels',
        where: 'user_id = ? AND hotel_id = ?',
        whereArgs: [userId, hotelId],
      );
      return true;
    } catch (e) {
      print('Error removing from favorites: $e');
      return false;
    }
  }

  // Kiểm tra xem khách sạn có trong danh sách yêu thích không
  static Future<bool> isFavorite(int userId, int hotelId) async {
    try {
      final dbClient = await db;
      final result = await dbClient.query(
        'favorite_hotels',
        where: 'user_id = ? AND hotel_id = ?',
        whereArgs: [userId, hotelId],
      );
      return result.isNotEmpty;
    } catch (e) {
      print('Error checking favorite: $e');
      return false;
    }
  }

  // Lấy danh sách khách sạn yêu thích của user
  static Future<List<Map<String, dynamic>>> getFavoriteHotels(int userId) async {
    try {
      final dbClient = await db;
      final result = await dbClient.rawQuery('''
        SELECT h.*, fh.created_at as favorite_date
        FROM hotels h
        INNER JOIN favorite_hotels fh ON h.id = fh.hotel_id
        WHERE fh.user_id = ?
        ORDER BY fh.created_at DESC
      ''', [userId]);
      return result;
    } catch (e) {
      print('Error getting favorite hotels: $e');
      return [];
    }
  }
}