import 'package:flutter/material.dart';
import 'package:myapp/providers/theme_provider.dart';
import 'package:provider/provider.dart';

class FAQScreen extends StatefulWidget {
  const FAQScreen({Key? key}) : super(key: key);

  @override
  State<FAQScreen> createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
  final List<Map<String, dynamic>> _faqs = [
    {
      'question': 'Làm thế nào để đặt phòng?',
      'answer': 'Bạn có thể đặt phòng bằng cách tìm kiếm khách sạn, chọn ngày check-in/check-out và thanh toán trực tuyến.',
    },
    {
      'question': 'Có thể hủy đặt phòng không?',
      'answer': 'Có, bạn có thể hủy đặt phòng trong vòng 24 giờ trước ngày check-in. Một số khách sạn có chính sách hủy khác nhau.',
    },
    {
      'question': 'Thanh toán có an toàn không?',
      'answer': 'Chúng tôi sử dụng các phương thức thanh toán an toàn và mã hóa SSL để bảo vệ thông tin của bạn.',
    },
    {
      'question': 'Làm thế nào để liên hệ hỗ trợ?',
      'answer': 'Bạn có thể liên hệ chúng tôi qua hotline, email hoặc chat trực tuyến trong ứng dụng.',
    },
    {
      'question': 'Có thể đặt phòng cho người khác không?',
      'answer': 'Có, bạn có thể đặt phòng cho người khác bằng cách nhập thông tin của họ trong quá trình đặt phòng.',
    },
  ];

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
          'Hỏi đáp',
          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
        ),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: _faqs.length,
        itemBuilder: (context, index) {
          final faq = _faqs[index];
          return _buildFAQItem(
            question: faq['question'],
            answer: faq['answer'],
            isDarkMode: isDarkMode,
          );
        },
      ),
    );
  }

  Widget _buildFAQItem({
    required String question,
    required String answer,
    required bool isDarkMode,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        iconColor: Colors.orange,
        collapsedIconColor: isDarkMode ? Colors.grey[400] : Colors.grey[600],
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              answer,
              style: TextStyle(
                color: isDarkMode ? Colors.grey[300] : Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 