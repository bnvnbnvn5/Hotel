import 'package:flutter/material.dart';
import 'package:myapp/providers/theme_provider.dart';
import 'package:provider/provider.dart';
import '../../language/appLocalizations.dart';

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
          AppLocalizations(context).of('terms_privacy'),
          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              title: AppLocalizations(context).of('terms_of_use'),
              content: AppLocalizations(context).of('terms_of_use_content'),
              isDarkMode: isDarkMode,
            ),
            
            SizedBox(height: 24),
            
            _buildSection(
              title: AppLocalizations(context).of('privacy_policy'),
              content: AppLocalizations(context).of('privacy_policy_content'),
              isDarkMode: isDarkMode,
            ),
            
            SizedBox(height: 24),
            
            _buildSection(
              title: AppLocalizations(context).of('contact'),
              content: AppLocalizations(context).of('contact_content'),
              isDarkMode: isDarkMode,
            ),
            
            SizedBox(height: 24),
            
            _buildSection(
              title: AppLocalizations(context).of('cancellation_policy'),
              content: AppLocalizations(context).of('cancellation_policy_content'),
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