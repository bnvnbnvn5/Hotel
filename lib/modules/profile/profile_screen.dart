import 'package:flutter/material.dart';
import 'package:myapp/db_helper.dart';
import 'package:myapp/providers/theme_provider.dart';
import 'package:myapp/language/appLocalizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'edit_profile_screen.dart';
import 'favorite_hotels_screen.dart';
import 'account_settings_screen.dart';
import 'notifications_screen.dart';
import 'language_screen.dart';
import 'theme_settings_screen.dart';
import 'region_screen.dart';
import 'faq_screen.dart';
import 'terms_privacy_screen.dart';
import 'contact_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('current_user_id');
      
      if (userId != null) {
        final user = await DBHelper.getUserById(userId);
        setState(() {
          _currentUser = user; // user có thể là null, nhưng điều này ổn vì _currentUser là nullable
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_user_id');
    await prefs.remove('user_email');
    
    // Navigate to login screen
    Navigator.pushNamedAndRemoveUntil(
      context, 
      '/login', 
      (route) => false
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Đăng xuất'),
          content: Text('Bạn có chắc chắn muốn đăng xuất?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _logout();
              },
              child: Text('Đăng xuất', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = !themeProvider.isLightMode;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header với thông tin user
            Container(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  // Avatar
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: (isDarkMode ? Colors.orange : Colors.black).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Icon(
                      Icons.person,
                      size: 30,
                      color: isDarkMode ? Colors.orange : Colors.black,
                    ),
                  ),
                  SizedBox(width: 16),
                  // Thông tin user
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _currentUser?['name'] ?? 'User${_currentUser?['id'] ?? ''}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          _currentUser?['phone'] ?? '+84 966040725',
                          style: TextStyle(
                            color: isDarkMode ? Colors.grey[300] : Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Nút edit
                  IconButton(
                    onPressed: () {
                      if (_currentUser != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditProfileScreen(user: _currentUser),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Không tìm thấy thông tin người dùng')),
                        );
                      }
                    },
                    icon: Icon(
                      Icons.edit,
                      color: isDarkMode ? Colors.orange : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            
            // Menu items
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 16),
                children: [
                  // Trang của tôi
                  _buildSectionTitle('Trang của tôi', isDarkMode),
                  _buildMenuItem(
                    icon: Icons.favorite_border,
                    title: 'Khách sạn yêu thích',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FavoriteHotelsScreen(),
                        ),
                      );
                    },
                    isDarkMode: isDarkMode,
                  ),
                  
                  SizedBox(height: 24),
                  
                  // Cài đặt
                  _buildSectionTitle('Cài đặt', isDarkMode),
                  _buildMenuItem(
                    icon: Icons.settings,
                    title: 'Thiết lập tài khoản',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AccountSettingsScreen(),
                        ),
                      );
                    },
                    isDarkMode: isDarkMode,
                  ),
                  _buildMenuItem(
                    icon: Icons.notifications,
                    title: 'Thông báo',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => NotificationsScreen(),
                        ),
                      );
                    },
                    isDarkMode: isDarkMode,
                  ),
                  _buildMenuItem(
                    icon: Icons.language,
                    title: 'Ngôn ngữ',
                    subtitle: 'Tiếng Việt',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LanguageScreen(),
                        ),
                      );
                    },
                    isDarkMode: isDarkMode,
                  ),
                  _buildMenuItem(
                    icon: Icons.palette,
                    title: 'Giao diện',
                    subtitle: isDarkMode ? 'Chế độ tối' : 'Chế độ sáng',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ThemeSettingsScreen(),
                        ),
                      );
                    },
                    isDarkMode: isDarkMode,
                  ),
                  _buildMenuItem(
                    icon: Icons.location_on,
                    title: 'Khu vực',
                    subtitle: 'Hà Nội',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RegionScreen(),
                        ),
                      );
                    },
                    isDarkMode: isDarkMode,
                  ),
                  
                  SizedBox(height: 24),
                  
                  // Thông tin
                  _buildSectionTitle('Thông tin', isDarkMode),
                  _buildMenuItem(
                    icon: Icons.help_outline,
                    title: 'Hỏi đáp',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FAQScreen(),
                        ),
                      );
                    },
                    isDarkMode: isDarkMode,
                  ),
                  _buildMenuItem(
                    icon: Icons.security,
                    title: 'Điều khoản & Chính sách bảo mật',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TermsPrivacyScreen(),
                        ),
                      );
                    },
                    isDarkMode: isDarkMode,
                  ),
                  _buildMenuItem(
                    icon: Icons.info_outline,
                    title: 'Phiên bản',
                    subtitle: '15.70.0',
                    onTap: null,
                    isDarkMode: isDarkMode,
                  ),
                  _buildMenuItem(
                    icon: Icons.phone,
                    title: 'Liên hệ',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ContactScreen(),
                        ),
                      );
                    },
                    isDarkMode: isDarkMode,
                  ),
                  _buildMenuItem(
                    icon: Icons.logout,
                    title: 'Đăng xuất',
                    onTap: _showLogoutDialog,
                    isDarkMode: isDarkMode,
                    textColor: Colors.red,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(context, isDarkMode),
    );
  }

  Widget _buildSectionTitle(String title, bool isDarkMode) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: isDarkMode ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
    required bool isDarkMode,
    Color? textColor,
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
          color: textColor ?? (isDarkMode ? Colors.orange : Colors.black),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: textColor ?? (isDarkMode ? Colors.white : Colors.black),
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: subtitle != null ? Text(
          subtitle,
          style: TextStyle(
            color: isDarkMode ? Colors.orange : Colors.black,
            fontSize: 12,
          ),
        ) : null,
        trailing: onTap != null ? Icon(
          Icons.chevron_right,
          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
        ) : null,
        onTap: onTap,
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, bool isDarkMode) {
    return BottomNavigationBar(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
      selectedItemColor: isDarkMode ? Colors.orange : Colors.black,
      unselectedItemColor: isDarkMode ? Colors.white70 : Colors.grey,
      currentIndex: 2, // 2 là index của Profile
      onTap: (index) {
        if (index == 0) {
          Navigator.pushReplacementNamed(context, '/home');
        } else if (index == 1) {
          Navigator.pushReplacementNamed(context, '/booking');
        }
        // index 2 là profile, không cần chuyển
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Trang chủ',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.book),
          label: 'Đã đặt',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Cá nhân',
        ),
      ],
    );
  }
}
