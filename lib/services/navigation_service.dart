import 'package:flutter/material.dart';
import '../modules/home/booking_screen.dart';
import '../modules/home/confirm_booking_screen.dart';
import '../modules/home/map_screen.dart';
import '../modules/home/image_gallery_screen.dart';
import '../modules/home/hotel_list_by_category_screen.dart';
import '../modules/home/hotel_search_screen.dart';
import '../modules/home/hotel_list_by_area_screen.dart';
import '../modules/profile/terms_privacy_screen.dart';

class NavigationService {
  static final NavigationService _instance = NavigationService._internal();
  factory NavigationService() => _instance;
  NavigationService._internal();

  // Navigate to home screen with specific tab
  static void navigateToHomeWithTab(BuildContext context, int tabIndex) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/home',
      (route) => false, // Clear all routes
      arguments: {'tab': tabIndex},
    );
  }

  // Navigate to home screen and preserve stack
  static void navigateToHomePreserveStack(BuildContext context, int tabIndex) {
    Navigator.pushReplacementNamed(
      context,
      '/home',
      arguments: {'tab': tabIndex},
    );
  }

  // Pop back to home if exists, then navigate
  static void popToHomeAndNavigate(BuildContext context, int tabIndex) {
    Navigator.popUntil(context, (route) => route.settings.name == '/home');
    Navigator.pushReplacementNamed(
      context,
      '/home',
      arguments: {'tab': tabIndex},
    );
  }

  // Simple pop back
  static void popBack(BuildContext context) {
    Navigator.pop(context);
  }

  // Navigate to booking screen
  static void navigateToBooking(BuildContext context, Map<String, dynamic> hotel) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookingScreen(hotel: hotel),
      ),
    );
  }

  // Navigate to confirm booking screen
  static void navigateToConfirmBooking(
    BuildContext context,
    Map<String, dynamic> hotel,
    Map<String, dynamic> room,
    {
      DateTime? selectedDate,
      TimeOfDay? selectedTime,
      int? selectedHour,
      DateTimeRange? selectedRange,
    }
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ConfirmBookingScreen(
          hotel: hotel,
          room: room,
          selectedDate: selectedDate,
          selectedTime: selectedTime,
          selectedHour: selectedHour,
          selectedRange: selectedRange,
        ),
      ),
    );
  }

  // Navigate to login screen
  static void navigateToLogin(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login',
      (route) => false,
    );
  }

  // Navigate to profile screen
  static void navigateToProfile(BuildContext context) {
    Navigator.pushNamed(context, '/profile');
  }

  // Navigate to bookings list
  static void navigateToBookings(BuildContext context) {
    Navigator.pushNamed(context, '/bookings');
  }

  // Navigate to map screen
  static void navigateToMap(BuildContext context, Map<String, dynamic> hotel) {
    // Extract lat and lng from hotel data
    final double lat = hotel['lat']?.toDouble() ?? 0.0;
    final double lng = hotel['lng']?.toDouble() ?? 0.0;
    final String? hotelName = hotel['name'];
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MapScreen(
          lat: lat,
          lng: lng,
          hotelName: hotelName,
        ),
      ),
    );
  }

  // Navigate to image gallery
  static void navigateToImageGallery(BuildContext context, List<String> images, int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ImageGalleryScreen(images: images, initialIndex: initialIndex),
      ),
    );
  }

  // Navigate to hotel list by category
  static void navigateToHotelListByCategory(BuildContext context, String category) {
    // Map category to title
    String title;
    switch (category) {
      case 'flash_sale':
        title = 'Khuyến mãi đặc biệt';
        break;
      case 'top_rated':
        title = 'Khách sạn được đánh giá cao';
        break;
      case 'new_hotels':
        title = 'Khách sạn mới';
        break;
      default:
        title = 'Danh sách khách sạn';
    }
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => HotelListByCategoryScreen(
          category: category,
          title: title,
        ),
      ),
    );
  }

  // Navigate to hotel search
  static void navigateToHotelSearch(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => HotelSearchScreen(),
      ),
    );
  }

  // Navigate to hotel list by area
  static void navigateToHotelListByArea(BuildContext context, String city, String district) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => HotelListByAreaScreen(city: city, district: district),
      ),
    );
  }

  // Navigate to terms and privacy
  static void navigateToTermsPrivacy(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TermsPrivacyScreen(),
      ),
    );
  }

  // Navigate to booked rooms tab (tab index 1 in HomeScreen)
  static void navigateToBookedRoomsTab(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/home',
      (route) => false, // Clear all routes
      arguments: {'tab': 1}, // Tab index 1 = "Phòng đã đặt"
    );
  }
}
// Import statements for the classes used above

