import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

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
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE hotels (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT, address TEXT, city TEXT, district TEXT, image TEXT, rating REAL, reviews INTEGER, price INTEGER,
            isNew INTEGER, isFlashSale INTEGER, isTopRated INTEGER
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
            room_id INTEGER, user TEXT, checkin TEXT, checkout TEXT, status TEXT
          );
        ''');
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
}