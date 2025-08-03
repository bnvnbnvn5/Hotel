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
      version: 2, // Tăng version để thêm bảng users
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
            room_id INTEGER, user_id INTEGER, checkin TEXT, checkout TEXT, status TEXT
          );
        ''');
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            email TEXT UNIQUE, phone TEXT, password TEXT, name TEXT, 
            created_at TEXT, updated_at TEXT, is_active INTEGER DEFAULT 1
          );
        ''');
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
    return await dbClient.insert('bookings', booking);
  }
  
  static Future<List<Map<String, dynamic>>> getBookings() async {
    final dbClient = await db;
    return await dbClient.query('bookings');
  }

  static Future<bool> isRoomAvailable(int roomId, DateTime checkin, DateTime checkout) async {
    final dbClient = await db;
    // Lấy các booking trùng phòng và có thời gian giao với khoảng checkin-checkout
    final result = await dbClient.rawQuery('''
      SELECT * FROM bookings
      WHERE room_id = ?
        AND status = 'booked'
        AND NOT (
          checkout <= ? OR checkin >= ?
        )
    ''', [roomId, checkin.toIso8601String(), checkout.toIso8601String()]);
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
      SELECT b.*, h.name as hotel_name, h.address, r.class as room_class, r.price
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
}