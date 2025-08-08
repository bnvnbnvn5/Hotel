import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../language/appLocalizations.dart';
import '../../db_helper.dart';
import 'package:intl/intl.dart';
import 'package:flutter/gestures.dart';
import '../profile/terms_privacy_screen.dart';
import 'promotion_dialog.dart';
import 'payment_method_dialog.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';

// ConfirmBookingScreen: giao diện xác nhận và thanh toán
class ConfirmBookingScreen extends StatefulWidget {
  final Map<String, dynamic> hotel;
  final Map<String, dynamic> room;
  final DateTime? selectedDate;
  final TimeOfDay? selectedTime;
  final int? selectedHour;
  final DateTimeRange? selectedRange;
  ConfirmBookingScreen({required this.hotel, required this.room, this.selectedDate, this.selectedTime, this.selectedHour, this.selectedRange});

  @override
  State<ConfirmBookingScreen> createState() => _ConfirmBookingScreenState();
}

class _ConfirmBookingScreenState extends State<ConfirmBookingScreen> {
  Map<String, dynamic>? selectedPromotion;
  String selectedPaymentMethod = 'bank'; // 'bank' hoặc 'cash'
  bool agreedToTerms = false;
  Map<String, dynamic>? currentUser;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final currentUserId = prefs.getInt('current_user_id');
    if (currentUserId != null) {
      final user = await DBHelper.getUserById(currentUserId);
      setState(() {
        currentUser = user;
      });
    }
  }

  void _showPromotionsDialog(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) => PromotionDialog(
        selectedPromotion: selectedPromotion,
        isDarkMode: isDarkMode,
        onPromotionSelected: (promo) {
          setState(() {
            selectedPromotion = promo;
          });
        },
      ),
    );
  }

  void _showPaymentMethodDialog(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) => PaymentMethodDialog(
        selectedPaymentMethod: selectedPaymentMethod,
        isDarkMode: isDarkMode,
        onPaymentMethodSelected: (method) {
          setState(() {
            selectedPaymentMethod = method;
          });
        },
      ),
    );
  }

  Future<void> _processBooking(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentUserId = prefs.getInt('current_user_id');
      DateTime? checkin;
      DateTime? checkout;
      if (widget.selectedRange != null) {
        checkin = widget.selectedRange!.start;
        checkout = widget.selectedRange!.end.add(const Duration(days: 1));
      } else if (widget.selectedDate != null && widget.selectedHour != null && widget.selectedTime != null) {
        checkin = DateTime(widget.selectedDate!.year, widget.selectedDate!.month, widget.selectedDate!.day, widget.selectedTime!.hour, widget.selectedTime!.minute);
        checkout = checkin.add(Duration(hours: widget.selectedHour!));
      }
      if (checkin != null && checkout != null) {
        await DBHelper.insertBooking({
          'room_id': widget.room['id'],
          'user_id': currentUserId ?? 1,
          'checkin': checkin.toIso8601String(),
          'checkout': checkout.toIso8601String(),
          'status': 'booked',
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations(context).of("booking_successful", listen: false))),
        );
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/home',
          (route) => false,
          arguments: {'tab': 1},
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final DateTimeRange? selectedRange = widget.selectedRange;
    
    String infoText;
    if (selectedRange != null) {
      int days = selectedRange.end.difference(selectedRange.start).inDays + 1;
      String start = DateFormat('dd/MM/yyyy').format(selectedRange.start);
      String end = DateFormat('dd/MM/yyyy').format(selectedRange.end);
      infoText = '$days ngày | $start - $end';
    } else {
      String hourText = widget.selectedHour != null ? '${widget.selectedHour.toString().padLeft(2, '0')} giờ' : '02 giờ';
      String timeText = (widget.selectedTime != null && widget.selectedDate != null)
          ? '${widget.selectedTime!.format(context)}, ${DateFormat('dd/MM/yyyy').format(widget.selectedDate!)}'
          : AppLocalizations(context).of("select_checkin_time");
      infoText = '$hourText | $timeText';
    }

    String nhanPhong = selectedRange != null
      ? DateFormat('dd/MM/yyyy').format(selectedRange.start)
      : (widget.selectedDate != null ? DateFormat('dd/MM/yyyy').format(widget.selectedDate!) : '');
    String traPhong = selectedRange != null
      ? DateFormat('dd/MM/yyyy').format(selectedRange.end)
      : (widget.selectedDate != null && widget.selectedHour != null
          ? DateFormat('dd/MM/yyyy').format(widget.selectedDate!.add(Duration(hours: widget.selectedHour!)))
          : '');

    // Tính toán giá sau khi áp dụng ưu đãi
    int originalPrice = widget.room['price'] ?? 300000;
    int discountAmount = selectedPromotion != null ? (selectedPromotion!['amount'] ?? 0) : 0;
    int finalPrice = originalPrice - discountAmount;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
      appBar: AppBar(
        title: Text(AppLocalizations(context).of("confirm_and_pay")),
        backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
        foregroundColor: isDarkMode ? Colors.white : Colors.black,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Lựa chọn của bạn
                  Text(AppLocalizations(context).of("your_choice"), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: isDarkMode ? Colors.white : Colors.black)),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.grey[800] : Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            widget.room['image'] ?? 'assets/images/room_a.jpg',
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.hotel['name'] ?? 'Hotel Name',
                                style: TextStyle(fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black),
                              ),
                              SizedBox(height: 4),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  widget.room['class'] != null ? widget.room['class'].toString().toUpperCase() : 'DELUXE ROOM',
                                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                widget.hotel['address'] ?? 'Address',
                                style: TextStyle(color: isDarkMode ? Colors.grey[400] : Colors.grey[600], fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  // Thời gian đặt phòng
                  Row(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.access_time, color: Colors.white, size: 24),
                            SizedBox(height: 4),
                            Text(
                              widget.selectedHour != null ? '${widget.selectedHour.toString().padLeft(2, '0')} giờ' : '02 giờ',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${AppLocalizations(context).of("checkin")}: $nhanPhong${widget.selectedTime != null ? ' - ${widget.selectedTime!.format(context)}' : ''}',
                              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '${AppLocalizations(context).of("checkout")}: $traPhong${widget.selectedTime != null && widget.selectedHour != null ? ' - ${TimeOfDay.fromDateTime((widget.selectedDate ?? DateTime.now()).add(Duration(hours: widget.selectedHour ?? 2))).format(context)}' : ''}',
                              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  // Ưu đãi
                  Text(AppLocalizations(context).of("promotions"), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDarkMode ? Colors.white : Colors.black)),
                  SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => _showPromotionsDialog(context),
                    child: Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.grey[800] : Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.card_giftcard, color: Colors.orange),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              selectedPromotion != null 
                                ? '${selectedPromotion!['title']} - ${selectedPromotion!['amount']}₫'
                                : AppLocalizations(context).of("choose_promotion"),
                              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios, color: isDarkMode ? Colors.grey[400] : Colors.grey[600], size: 16),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  // Chi tiết thanh toán
                  Text(AppLocalizations(context).of("payment_details"), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDarkMode ? Colors.white : Colors.black)),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.grey[800] : Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(AppLocalizations(context).of("room_price"), style: TextStyle(color: isDarkMode ? Colors.grey[400] : Colors.grey[600])),
                                SizedBox(width: 4),
                                Icon(Icons.info_outline, color: isDarkMode ? Colors.grey[400] : Colors.grey[600], size: 16),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  '${originalPrice}₫',
                                  style: TextStyle(
                                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text('${finalPrice}₫', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(AppLocalizations(context).of("total_payment"), style: TextStyle(fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black)),
                            Text('${finalPrice}₫', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.orange)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Người đặt phòng
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(AppLocalizations(context).of("booker_information"), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDarkMode ? Colors.white : Colors.black)),
                      TextButton(
                        onPressed: () {},
                        child: Text(AppLocalizations(context).of("edit"), style: TextStyle(color: Colors.orange)),
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.grey[800] : Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(AppLocalizations(context).of("phone_number"), style: TextStyle(color: isDarkMode ? Colors.grey[400] : Colors.grey[600])),
                            Text(currentUser?['phone'] ?? '+84 966040725', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(AppLocalizations(context).of("full_name"), style: TextStyle(color: isDarkMode ? Colors.grey[400] : Colors.grey[600])),
                            Text(currentUser?['name'] ?? 'User31', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
                  // Chính sách huỷ phòng
                  Text(AppLocalizations(context).of("cancellation_policy"), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDarkMode ? Colors.white : Colors.black)),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.grey[800] : Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations(context).of("flash_sale_cancellation_policy"),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Checkbox(
                              value: agreedToTerms,
                              onChanged: (value) {
                                setState(() {
                                  agreedToTerms = value ?? false;
                                });
                              },
                              activeColor: Colors.orange,
                            ),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                                  children: [
                                    TextSpan(text: '${AppLocalizations(context).of("i_agree_with")} '),
                                    TextSpan(
                                      text: AppLocalizations(context).of("terms_and_booking_policy"),
                                      style: TextStyle(
                                        color: Colors.orange,
                                        decoration: TextDecoration.underline,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => TermsPrivacyScreen(),
                                            ),
                                          );
                                        },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
                  // Chọn phương thức thanh toán
                  // GestureDetector(
                  //   onTap: () => _showPaymentMethodDialog(context),
                  //   child: Container(
                  //     padding: EdgeInsets.all(12),
                  //     decoration: BoxDecoration(
                  //       color: isDarkMode ? Colors.grey[800] : Colors.grey[50],
                  //       borderRadius: BorderRadius.circular(12),
                  //     ),
                  //     child: Row(
                  //       children: [
                  //         Icon(Icons.account_balance_wallet, color: Colors.orange),
                  //         SizedBox(width: 12),
                  //         Expanded(
                  //           child: Text(
                  //             selectedPaymentMethod == 'bank' 
                  //               ? AppLocalizations(context).of("bank_transfer")
                  //               : AppLocalizations(context).of("cash_payment"),
                  //             style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                  //           ),
                  //         ),
                  //         Icon(Icons.arrow_forward_ios, color: isDarkMode ? Colors.grey[400] : Colors.grey[600], size: 16),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                  SizedBox(height: 100), // Space for bottom bar
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        color: isDarkMode ? Colors.grey[900] : Colors.white,
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => _showPaymentMethodDialog(context),
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[800] : Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.account_balance_wallet, color: Colors.orange),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        selectedPaymentMethod == 'bank'
                            ? AppLocalizations(context).of("bank_transfer")
                            : AppLocalizations(context).of("cash_payment"),
                        style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, color: isDarkMode ? Colors.grey[400] : Colors.grey[600], size: 16),
                  ],
                ),
              ),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(AppLocalizations(context).of("total_payment"), style: TextStyle(color: isDarkMode ? Colors.grey[400] : Colors.grey[600])),
                      Text('${finalPrice}₫', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: isDarkMode ? Colors.white : Colors.black)),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: agreedToTerms ? () => _processBooking(context) : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: agreedToTerms ? Colors.orange : Colors.grey,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                  child: Text(AppLocalizations(context).of("book_room")),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  // ... các hàm phụ ...
}