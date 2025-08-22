import 'package:flutter/material.dart';
import 'package:myapp/providers/theme_provider.dart';
import 'package:provider/provider.dart';
import '../../language/appLocalizations.dart';
import '../../routes/routes.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({Key? key}) : super(key: key);

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  bool _emailNotifications = true;
  bool _pushNotifications = true;
  bool _smsNotifications = false;

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
          AppLocalizations(context).of('account_settings_title'),
          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _buildSectionTitle(AppLocalizations(context).of('notifications'), isDarkMode),
          _buildSwitchTile(
            title: AppLocalizations(context).of('notification_email'),
            subtitle: AppLocalizations(context).of('notification_email_subtitle'),
            value: _emailNotifications,
            onChanged: (value) {
              setState(() {
                _emailNotifications = value;
              });
            },
            isDarkMode: isDarkMode,
          ),
          _buildSwitchTile(
            title: AppLocalizations(context).of('notification_push'),
            subtitle: AppLocalizations(context).of('notification_push_subtitle'),
            value: _pushNotifications,
            onChanged: (value) {
              setState(() {
                _pushNotifications = value;
              });
            },
            isDarkMode: isDarkMode,
          ),
          _buildSwitchTile(
            title: AppLocalizations(context).of('notification_sms'),
            subtitle: AppLocalizations(context).of('notification_sms_subtitle'),
            value: _smsNotifications,
            onChanged: (value) {
              setState(() {
                _smsNotifications = value;
              });
            },
            isDarkMode: isDarkMode,
          ),
          
          SizedBox(height: 24),
          
          _buildSectionTitle(AppLocalizations(context).of('security'), isDarkMode),
          _buildMenuItem(
            icon: Icons.lock,
            title: AppLocalizations(context).of('change_password'),
            onTap: () {
              Navigator.pushNamed(context, RoutesName.ChangePassword);
            },
            isDarkMode: isDarkMode,
          ),
          _buildMenuItem(
            icon: Icons.security,
            title: AppLocalizations(context).of('two_factor_auth'),
            onTap: () {
              // TODO: Navigate to 2FA screen
            },
            isDarkMode: isDarkMode,
          ),
          
          SizedBox(height: 24),
          
          _buildSectionTitle(AppLocalizations(context).of('data'), isDarkMode),
          _buildMenuItem(
            icon: Icons.download,
            title: AppLocalizations(context).of('export_data'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(AppLocalizations(context).of('feature_in_development'))),
              );
            },
            isDarkMode: isDarkMode,
          ),
          _buildMenuItem(
            icon: Icons.delete_forever,
            title: AppLocalizations(context).of('delete_account'),
            onTap: () {
              _showDeleteAccountDialog();
            },
            isDarkMode: isDarkMode,
            textColor: Colors.red,
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

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
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
          color: textColor ?? Colors.orange,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: textColor ?? (isDarkMode ? Colors.white : Colors.black),
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
        ),
        onTap: onTap,
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations(context).of('delete_account')),
          content: Text(AppLocalizations(context).of('delete_account_confirm')),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations(context).of('cancel')),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(AppLocalizations(context).of('feature_in_development'))),
                );
              },
              child: Text(AppLocalizations(context).of('delete'), style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
} 