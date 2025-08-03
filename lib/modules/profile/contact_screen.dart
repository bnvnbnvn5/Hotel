import 'package:flutter/material.dart';
import 'package:myapp/providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({Key? key}) : super(key: key);

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final List<Map<String, dynamic>> _contactMethods = [
    {
      'title': 'Hotline',
      'subtitle': '1900-1234',
      'icon': Icons.phone,
      'action': 'call',
      'data': 'tel:19001234',
    },
    {
      'title': 'Email',
      'subtitle': 'support@hotelapp.com',
      'icon': Icons.email,
      'action': 'email',
      'data': 'mailto:support@hotelapp.com',
    },
    {
      'title': 'Website',
      'subtitle': 'www.hotelapp.com',
      'icon': Icons.language,
      'action': 'web',
      'data': 'https://www.hotelapp.com',
    },
    {
      'title': 'Facebook',
      'subtitle': 'HotelApp Vietnam',
      'icon': Icons.facebook,
      'action': 'web',
      'data': 'https://facebook.com/hotelapp',
    },
  ];

  final List<Map<String, dynamic>> _officeInfo = [
    {
      'title': 'Trụ sở chính',
      'address': '123 Đường ABC, Quận 1, TP.HCM',
      'phone': '028-1234-5678',
      'hours': '8:00 - 18:00 (Thứ 2 - Thứ 6)',
    },
    {
      'title': 'Văn phòng Hà Nội',
      'address': '456 Đường XYZ, Hoàn Kiếm, Hà Nội',
      'phone': '024-9876-5432',
      'hours': '8:00 - 18:00 (Thứ 2 - Thứ 6)',
    },
  ];

  Future<void> _launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể mở liên kết')),
      );
    }
  }

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
          'Liên hệ',
          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Liên hệ trực tiếp', isDarkMode),
            ..._contactMethods.map((method) => _buildContactMethod(
              title: method['title'],
              subtitle: method['subtitle'],
              icon: method['icon'],
              onTap: () => _launchUrl(method['data']),
              isDarkMode: isDarkMode,
            )),
            
            SizedBox(height: 24),
            
            _buildSectionTitle('Văn phòng', isDarkMode),
            ..._officeInfo.map((office) => _buildOfficeInfo(
              title: office['title'],
              address: office['address'],
              phone: office['phone'],
              hours: office['hours'],
              isDarkMode: isDarkMode,
            )),
            
            SizedBox(height: 24),
            
            _buildSectionTitle('Thông tin khác', isDarkMode),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[800] : Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Thời gian hỗ trợ',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Thứ 2 - Thứ 6: 8:00 - 18:00\nThứ 7: 8:00 - 12:00\nChủ nhật: Nghỉ',
                    style: TextStyle(
                      color: isDarkMode ? Colors.grey[300] : Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDarkMode) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: isDarkMode ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  Widget _buildContactMethod({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    required bool isDarkMode,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: Colors.orange,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: isDarkMode ? Colors.grey[300] : Colors.grey[600],
            fontSize: 12,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildOfficeInfo({
    required String title,
    required String address,
    required String phone,
    required String hours,
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
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.location_on, size: 16, color: Colors.orange),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  address,
                  style: TextStyle(
                    color: isDarkMode ? Colors.grey[300] : Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.phone, size: 16, color: Colors.orange),
              SizedBox(width: 8),
              Text(
                phone,
                style: TextStyle(
                  color: isDarkMode ? Colors.grey[300] : Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.access_time, size: 16, color: Colors.orange),
              SizedBox(width: 8),
              Text(
                hours,
                style: TextStyle(
                  color: isDarkMode ? Colors.grey[300] : Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
} 