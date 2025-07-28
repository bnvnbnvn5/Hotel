import 'package:myapp/db_helper.dart';

Future<void> seedData() async {
  // Seed hotel
  final hotels = [
    {
      'name': 'Khách sạn Sapa View',
      'address': 'Số 1 Fansipan, Sapa',
      'city': 'Hà Nội',
      'district': 'Đống Đa',
      'image': 'assets/images/hotel_1.jpg',
      'rating': 4.8,
      'reviews': 120,
      'price': 350000,
      'isTopRated': true,
    },
    {
      'name': 'Khách sạn Hồ Gươm',
      'address': '36 Lê Thái Tổ, Hoàn Kiếm',
      'city': 'Hà Nội',
      'district': 'Ba Đình',
      'image': 'assets/images/hotel_3.png',
      'rating': 4.7,
      'reviews': 80,
      'price': 400000,
      'isFlashSale': true,
    },
    {
      'name': 'Melon Hotel - Hà Đông',
      'address': '12 Nguyễn Trãi, Hà Đông',
      'city': 'Hà Nội',
      'district': 'Hà Đông',
      'image': 'assets/images/room_1.jpg',
      'rating': 4.9,
      'reviews': 60,
      'price': 200000,
      'isFlashSale': true,
      'isNew': true,
    },
    {
      'name': 'Yên Hoa Hotel 2',
      'address': '45 Yên Hoa, Cầu Giấy',
      'city': 'Hà Nội',
      'district': 'Cầu Giấy',
      'image': 'assets/images/room_2.jpg',
      'rating': 4.6,
      'reviews': 429,
      'price': 280000,
      'isFlashSale': true,
    },
    {
      'name': 'New Apart Hotel',
      'address': '88 Láng Hạ, Đống Đa',
      'city': 'Hà Nội',
      'district': 'Đống Đa',
      'image': 'assets/images/hotel_Type_1.jpg',
      'rating': 5.0,
      'reviews': 10,
      'price': 350000,
      'isNew': true,
    },
    {
      'name': 'Cozy Oasis',
      'address': '22 Trần Duy Hưng, Cầu Giấy',
      'city': 'Hà Nội',
      'district': 'Cầu Giấy',
      'image': 'assets/images/hotel_Type_2.jpg',
      'rating': 4.9,
      'reviews': 5,
      'price': 200000,
      'isNew': true,
    },
    {
      'name': 'A25 Hotel',
      'address': '25 Lê Văn Lương, Thanh Xuân',
      'city': 'Hà Nội',
      'district': 'Thanh Xuân',
      'image': 'assets/images/hotel_Type_3.jpg',
      'rating': 5.0,
      'reviews': 1,
      'price': 245000,
      'isNew': true,
    },
    {
      'name': 'Trần Gia 2',
      'address': '99 Nguyễn Văn Cừ, Long Biên',
      'city': 'Hà Nội',
      'district': 'Long Biên',
      'image': 'assets/images/hotel_Type_4.jpg',
      'rating': 4.8,
      'reviews': 2563,
      'price': 200000,
      'isTopRated': true,
    },
    {
      'name': 'Hoa Nam Hotel - Việt',
      'address': '12 Lý Thường Kiệt, Hoàn Kiếm',
      'city': 'Hà Nội',
      'district': 'Hoàn Kiếm',
      'image': 'assets/images/hotel_Type_5.jpg',
      'rating': 5.0,
      'reviews': 3,
      'price': 280000,
      'isTopRated': true,
    },
    {
      'name': 'Nguyễn Anh',
      'address': '33 Phạm Hùng, Nam Từ Liêm',
      'city': 'Hà Nội',
      'district': 'Nam Từ Liêm',
      'image': 'assets/images/hotel_Type_6.jpg',
      'rating': 4.9,
      'reviews': 3337,
      'price': 200000,
      'isTopRated': true,
    },
    {
      'name': 'Flash Sale Hotel 1',
      'address': '123 Đường Số 1, Quận 1',
      'city': 'Hồ Chí Minh',
      'district': 'Quận 1',
      'image': 'assets/images/hotel_Type_7.jpg',
      'rating': 4.5,
      'reviews': 100,
      'price': 250000,
      'isFlashSale': true,
    },
    {
      'name': 'Flash Sale Hotel 2',
      'address': '456 Đường Số 2, Quận 3',
      'city': 'Hồ Chí Minh',
      'district': 'Quận 3',
      'image': 'assets/images/hotel_Type_8.jpg',
      'rating': 4.7,
      'reviews': 80,
      'price': 220000,
      'isFlashSale': true,
    },
    {
      'name': 'Top Rated Hotel 1',
      'address': '789 Đường Số 3, Đống Đa',
      'city': 'Hà Nội',
      'district': 'Đống Đa',
      'image': 'assets/images/hotel_Type_9.jpg',
      'rating': 5.0,
      'reviews': 200,
      'price': 350000,
      'isTopRated': true,
    },
    {
      'name': 'Top Rated Hotel 2',
      'address': '321 Đường Số 4, Ba Đình',
      'city': 'Hà Nội',
      'district': 'Ba Đình',
      'image': 'assets/images/hotel_room_2.jpg',
      'rating': 4.9,
      'reviews': 150,
      'price': 320000,
      'isTopRated': true,
    },
    {
      'name': 'New Hotel 1',
      'address': '12 Đường Mới, Cầu Giấy',
      'city': 'Hà Nội',
      'district': 'Cầu Giấy',
      'image': 'assets/images/hotel_room_1.jpg',
      'rating': 4.8,
      'reviews': 10,
      'price': 280000,
      'isNew': true,
    },
    {
      'name': 'New Hotel 2',
      'address': '34 Đường Mới, Quận 1',
      'city': 'Hồ Chí Minh',
      'district': 'Quận 1',
      'image': 'assets/images/hotel_room_3.jpg',
      'rating': 4.6,
      'reviews': 8,
      'price': 260000,
      'isNew': true,
    },
  ];

  // Insert hotels and track their IDs
  final hotelIds = <int>[];
  for (final h in hotels) {
    final id = await DBHelper.insertHotel(h);
    hotelIds.add(id);
  }

  // Seed rooms for each hotel with class A and B
  final rooms = <Map<String, dynamic>>[];
  for (var i = 0; i < hotelIds.length; i++) {
    final hotelId = hotelIds[i];
    final hotelPrice = hotels[i]['price'] as int;
    rooms.add({
      'hotel_id': hotelId,
      'class': 'A',
      'price': hotelPrice, // Class A uses hotel's base price
      'status': 'available',
      'image': 'assets/images/room_1.jpg',
    });
    rooms.add({
      'hotel_id': hotelId,
      'class': 'B',
      'price': (hotelPrice * 0.9).round(), // Class B is 90% of hotel's base price
      'status': 'available',
      'image': 'assets/images/room_2.jpg',
    });
  }

  for (final r in rooms) {
    await DBHelper.insertRoom(r);
  }
}