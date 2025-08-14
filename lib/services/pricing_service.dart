import 'package:flutter/material.dart';

class PricingService {
  // Bảng giá tùy biến theo từng khách sạn (theo id). Có thể bổ sung/ghi đè từ dữ liệu thật.
  // Mỗi khách sạn: hourlyRates (1-4h), extraHour, dailyPrice, weeklyDiscountPct
  static final Map<int, Map<String, dynamic>> hotelPricingTable = {
    // Ví dụ:  id: 1 dùng giá riêng
    // 1: {
    //   'hourlyRates': {1: 70000, 2: 130000, 3: 190000, 4: 240000},
    //   'extraHour': 60000,
    //   'dailyPrice': 950000,
    //   'weeklyDiscountPct': 10,
    // },
  };

  // Giá mặc định nếu khách sạn không có cấu hình riêng
  static const Map<int, int> defaultHourlyRates = {1: 60000, 2: 120000, 3: 180000, 4: 240000};
  static const int defaultExtraHour = 50000; // từ giờ thứ 5 trở đi
  static const int defaultDailyPrice = 960000; // 40k/giờ * 24 giờ
  static const int defaultWeeklyDiscountPct = 10; // giảm 10% khi >= 7 ngày

  static int _calculateHourlyPrice(int hours, Map<String, dynamic> pricing) {
    final hourlyRates = Map<int, int>.from(pricing['hourlyRates'] ?? defaultHourlyRates);
    final extraHour = pricing['extraHour'] as int? ?? defaultExtraHour;

    if (hours <= 0) return 0;
    if (hours <= 4) return hourlyRates[hours] ?? (hours * (hourlyRates[1] ?? 60000));

    int price = hourlyRates[4] ?? 240000;
    price += (hours - 4) * extraHour;
    return price;
  }

  static int _calculateDailyPrice(int days, Map<String, dynamic> pricing) {
    if (days <= 0) return 0;
    final int daily = pricing['dailyPrice'] as int? ?? defaultDailyPrice;
    final int weeklyDiscount = pricing['weeklyDiscountPct'] as int? ?? defaultWeeklyDiscountPct;

    int total = days * daily;
    if (days >= 7 && weeklyDiscount > 0) {
      total = (total * (100 - weeklyDiscount) / 100).round();
    }
    return total;
  }

  // API chính: tính tổng tiền theo lựa chọn
  static int calculateTotalPrice({
    required Map<String, dynamic> hotel,
    required Map<String, dynamic> room,
    DateTime? selectedDate,
    TimeOfDay? selectedTime,
    int? selectedHour,
    DateTimeRange? selectedRange,
  }) {
    // Lấy pricing theo khách sạn nếu có, không thì dùng default
    final int? hotelId = hotel['id'] as int?;
    final Map<String, dynamic> pricing = hotelId != null && hotelPricingTable.containsKey(hotelId)
        ? hotelPricingTable[hotelId]!
        : {};

    // Nếu theo ngày
    if (selectedRange != null) {
      final int days = selectedRange.end.difference(selectedRange.start).inDays + 1;
      return _calculateDailyPrice(days, pricing);
    }

    // Theo giờ
    final int hours = selectedHour ?? 2; // mặc định 2 giờ nếu thiếu
    return _calculateHourlyPrice(hours, pricing);
  }
}


