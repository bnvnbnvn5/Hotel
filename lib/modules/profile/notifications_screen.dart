import 'package:flutter/material.dart';
import 'package:myapp/providers/theme_provider.dart';
import 'package:provider/provider.dart';
import '../../language/appLocalizations.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _bookingNotifications = true;
  bool _promotionNotifications = true;
  bool _newsNotifications = false;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;

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
          AppLocalizations(context).of('notifications'),
          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _buildSectionTitle(AppLocalizations(context).of('notification_type'), isDarkMode),
          _buildSwitchTile(
            title: AppLocalizations(context).of('booking_notification'),
            subtitle: AppLocalizations(context).of('booking_notification_subtitle'),
            value: _bookingNotifications,
            onChanged: (value) {
              setState(() {
                _bookingNotifications = value;
              });
            },
            isDarkMode: isDarkMode,
          ),
          _buildSwitchTile(
            title: AppLocalizations(context).of('promotion_notification'),
            subtitle: AppLocalizations(context).of('promotion_notification_subtitle'),
            value: _promotionNotifications,
            onChanged: (value) {
              setState(() {
                _promotionNotifications = value;
              });
            },
            isDarkMode: isDarkMode,
          ),
          _buildSwitchTile(
            title: AppLocalizations(context).of('news_notification'),
            subtitle: AppLocalizations(context).of('news_notification_subtitle'),
            value: _newsNotifications,
            onChanged: (value) {
              setState(() {
                _newsNotifications = value;
              });
            },
            isDarkMode: isDarkMode,
          ),
          
          SizedBox(height: 24),
          
          _buildSectionTitle(AppLocalizations(context).of('sound_settings'), isDarkMode),
          _buildSwitchTile(
            title: AppLocalizations(context).of('sound'),
            subtitle: AppLocalizations(context).of('sound_subtitle'),
            value: _soundEnabled,
            onChanged: (value) {
              setState(() {
                _soundEnabled = value;
              });
            },
            isDarkMode: isDarkMode,
          ),
          _buildSwitchTile(
            title: AppLocalizations(context).of('vibration'),
            subtitle: AppLocalizations(context).of('vibration_subtitle'),
            value: _vibrationEnabled,
            onChanged: (value) {
              setState(() {
                _vibrationEnabled = value;
              });
            },
            isDarkMode: isDarkMode,
          ),
          
          SizedBox(height: 24),
          
          _buildSectionTitle(AppLocalizations(context).of('recent_notifications'), isDarkMode),
          _buildNotificationItem(
            title: AppLocalizations(context).of('success_booking'),
            subtitle: AppLocalizations(context).of('success_booking_subtitle'),
            time: AppLocalizations(context).of('hours_ago').replaceAll('{hours}', '2'),
            isDarkMode: isDarkMode,
          ),
          _buildNotificationItem(
            title: AppLocalizations(context).of('promotion_new'),
            subtitle: AppLocalizations(context).of('promotion_new_subtitle'),
            time: AppLocalizations(context).of('days_ago').replaceAll('{days}', '1'),
            isDarkMode: isDarkMode,
          ),
          _buildNotificationItem(
            title: AppLocalizations(context).of('app_update'),
            subtitle: AppLocalizations(context).of('app_update_subtitle'),
            time: AppLocalizations(context).of('days_ago').replaceAll('{days}', '2'),
            isDarkMode: isDarkMode,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDarkMode) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8, top: 16),
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

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool isDarkMode,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: SwitchListTile(
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
        value: value,
        onChanged: onChanged,
        activeColor: Colors.orange,
      ),
    );
  }

  Widget _buildNotificationItem({
    required String title,
    required String subtitle,
    required String time,
    required bool isDarkMode,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            Icons.notifications,
            color: Colors.orange,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: isDarkMode ? Colors.grey[300] : Colors.grey[600],
                fontSize: 12,
              ),
            ),
            SizedBox(height: 4),
            Text(
              time,
              style: TextStyle(
                color: isDarkMode ? Colors.grey[400] : Colors.grey[500],
                fontSize: 10,
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(
            Icons.more_vert,
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
          ),
          onPressed: () {
            // TODO: Show notification options
          },
        ),
      ),
    );
  }
} 