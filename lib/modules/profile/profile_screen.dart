import 'package:flutter/material.dart';
import 'package:myapp/db_helper.dart';
import 'package:myapp/providers/theme_provider.dart';
import 'package:myapp/language/appLocalizations.dart';
import 'package:myapp/utils/enum.dart';
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
import 'contact_screen.dart';
import 'terms_privacy_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _currentUser;
  bool _isLoading = true;
  String _selectedLanguage = 'Tiếng Việt';
  String _selectedRegion = 'Hà Nội';

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final savedRegion = prefs.getString('selected_region') ?? 'Hà Nội';
    
    // Get language from ThemeProvider
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final currentLanguage = themeProvider.languageType;
    
    setState(() {
      _selectedLanguage = currentLanguage == LanguageType.vi ? 'Tiếng Việt' : 'English';
      _selectedRegion = savedRegion;
    });
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
          title: Text(AppLocalizations(context).of("logout")),
          content: Text(AppLocalizations(context).of("confirm_logout")),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations(context).of("cancel")),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _logout();
              },
              child: Text(AppLocalizations(context).of("logout"), style: TextStyle(color: Colors.red)),
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

    return SafeArea(
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
                      color: isDarkMode ? Colors.grey[700] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Icon(
                      Icons.person,
                      size: 30,
                      color: isDarkMode ? Colors.white : Colors.black,
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
                    onPressed: () async {
                      if (_currentUser != null) {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditProfileScreen(user: _currentUser),
                          ),
                        );
                        // Reload user data if profile was updated
                        if (result == true) {
                          await _loadUserData();
                          setState(() {}); // Force rebuild UI
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Không tìm thấy thông tin người dùng')),
                        );
                      }
                    },
                    icon: Icon(
                      Icons.edit,
                      color: isDarkMode ? Colors.white : Colors.black,
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
                  _buildSectionTitle(AppLocalizations(context).of("my_page"), isDarkMode),
                  _buildMenuItem(
                    icon: Icons.favorite_border,
                    title: AppLocalizations(context).of("favorite_hotels"),
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
                  _buildSectionTitle(AppLocalizations(context).of("settings"), isDarkMode),
                  _buildMenuItem(
                    icon: Icons.settings,
                    title: AppLocalizations(context).of("account_settings"),
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
                    title: AppLocalizations(context).of("notifications"),
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
                    title: AppLocalizations(context).of("language"),
                    subtitle: _selectedLanguage,
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LanguageScreen(),
                        ),
                      );
                      // Reload settings after returning from language screen
                      await _loadSettings();
                      setState(() {}); // Force rebuild UI
                    },
                    isDarkMode: isDarkMode,
                  ),
                  _buildMenuItem(
                    icon: Icons.palette,
                    title: AppLocalizations(context).of("interface"),
                    subtitle: isDarkMode ? AppLocalizations(context).of("dark_mode") : AppLocalizations(context).of("light_mode"),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ThemeSettingsScreen(),
                        ),
                      );
                      // Force rebuild UI after theme change
                      setState(() {});
                    },
                    isDarkMode: isDarkMode,
                  ),
                  _buildMenuItem(
                    icon: Icons.location_on,
                    title: AppLocalizations(context).of("region"),
                    subtitle: _selectedRegion,
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RegionScreen(),
                        ),
                      );
                      // Reload settings after returning from region screen
                      await _loadSettings();
                      setState(() {}); // Force rebuild UI
                    },
                    isDarkMode: isDarkMode,
                  ),
                  
                  SizedBox(height: 24),
                  
                  // Thông tin
                  _buildSectionTitle(AppLocalizations(context).of('information'), isDarkMode),
                  _buildMenuItem(
                    icon: Icons.help_outline,
                    title: AppLocalizations(context).of('faq'),
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
                    title: AppLocalizations(context).of('terms_privacy'),
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
                    title: AppLocalizations(context).of('version'),
                    subtitle: '15.70.0',
                    onTap: null,
                    isDarkMode: isDarkMode,
                  ),
                  _buildMenuItem(
                    icon: Icons.phone,
                    title: AppLocalizations(context).of('contact'),
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
                    title: AppLocalizations(context).of('logout'),
                    onTap: _showLogoutDialog,
                    isDarkMode: isDarkMode,
                    textColor: Colors.red,
                  ),
                ],
              ),
            ),
          ],
        ),
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
          color: textColor ?? (isDarkMode ? Colors.white : Colors.black),
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
            color: isDarkMode ? Colors.grey[300] : Colors.grey[600],
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
}
