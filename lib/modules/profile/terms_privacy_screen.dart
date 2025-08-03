import 'package:flutter/material.dart';
import 'package:myapp/providers/theme_provider.dart';
import 'package:provider/provider.dart';

class TermsPrivacyScreen extends StatefulWidget {
  const TermsPrivacyScreen({Key? key}) : super(key: key);

  @override
  State<TermsPrivacyScreen> createState() => _TermsPrivacyScreenState();
}

class _TermsPrivacyScreenState extends State<TermsPrivacyScreen> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = !themeProvider.isLightMode;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
      appBar: AppBar(
        backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDarkMode ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Điều khoản & Chính sách bảo mật',
          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              title: 'Điều khoản sử dụng',
              content: '''
1. Chấp nhận điều khoản
Khi sử dụng ứng dụng này, bạn đồng ý tuân thủ các điều khoản và điều kiện được nêu trong tài liệu này.

2. Sử dụng dịch vụ
- Bạn phải cung cấp thông tin chính xác khi đăng ký
- Không được sử dụng dịch vụ cho mục đích bất hợp pháp
- Không được chia sẻ tài khoản với người khác

3. Thanh toán
- Tất cả giá cả đều được hiển thị bằng VNĐ
- Thanh toán được thực hiện qua các cổng thanh toán an toàn
- Chúng tôi không lưu trữ thông tin thẻ tín dụng của bạn

4. Hủy đặt phòng
- Chính sách hủy phụ thuộc vào từng khách sạn
- Một số đặt phòng có thể không được hoàn tiền
- Vui lòng kiểm tra chính sách hủy trước khi đặt phòng
              ''',
              isDarkMode: isDarkMode,
            ),
            
            SizedBox(height: 24),
            
            _buildSection(
              title: 'Chính sách bảo mật',
              content: '''
1. Thu thập thông tin
Chúng tôi thu thập các thông tin sau:
- Thông tin cá nhân (tên, email, số điện thoại)
- Thông tin đặt phòng
- Dữ liệu sử dụng ứng dụng

2. Sử dụng thông tin
Thông tin được sử dụng để:
- Cung cấp dịch vụ đặt phòng
- Gửi thông báo và cập nhật
- Cải thiện trải nghiệm người dùng
- Tuân thủ yêu cầu pháp lý

3. Bảo mật dữ liệu
- Chúng tôi sử dụng mã hóa SSL để bảo vệ dữ liệu
- Thông tin được lưu trữ an toàn
- Chỉ nhân viên được ủy quyền mới có thể truy cập

4. Chia sẻ thông tin
Chúng tôi không bán, trao đổi hoặc chuyển giao thông tin cá nhân của bạn cho bên thứ ba mà không có sự đồng ý của bạn, trừ khi:
- Được yêu cầu bởi pháp luật
- Bảo vệ quyền và tài sản của chúng tôi
- Thực hiện dịch vụ cho bạn
              ''',
              isDarkMode: isDarkMode,
            ),
            
            SizedBox(height: 24),
            
            _buildSection(
              title: 'Liên hệ',
              content: '''
Nếu bạn có bất kỳ câu hỏi nào về điều khoản sử dụng hoặc chính sách bảo mật, vui lòng liên hệ với chúng tôi:

Email: support@hotelapp.com
Điện thoại: 1900-1234
Địa chỉ: 123 Đường ABC, Quận 1, TP.HCM

Chúng tôi sẽ phản hồi trong vòng 24 giờ làm việc.
              ''',
              isDarkMode: isDarkMode,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String content,
    required bool isDarkMode,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? Colors.grey[300] : Colors.grey[600],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
} 