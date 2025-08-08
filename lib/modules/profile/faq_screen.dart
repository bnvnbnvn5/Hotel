import 'package:flutter/material.dart';
import 'package:myapp/providers/theme_provider.dart';
import 'package:provider/provider.dart';
import '../../language/appLocalizations.dart';

class FAQScreen extends StatefulWidget {
  const FAQScreen({Key? key}) : super(key: key);

  @override
  State<FAQScreen> createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = !themeProvider.isLightMode;

    final List<Map<String, dynamic>> _faqs = [
      {
        'question': AppLocalizations(context).of('faq_question_1'),
        'answer': AppLocalizations(context).of('faq_answer_1'),
      },
      {
        'question': AppLocalizations(context).of('faq_question_2'),
        'answer': AppLocalizations(context).of('faq_answer_2'),
      },
      {
        'question': AppLocalizations(context).of('faq_question_3'),
        'answer': AppLocalizations(context).of('faq_answer_3'),
      },
      {
        'question': AppLocalizations(context).of('faq_question_4'),
        'answer': AppLocalizations(context).of('faq_answer_4'),
      },
      {
        'question': AppLocalizations(context).of('faq_question_5'),
        'answer': AppLocalizations(context).of('faq_answer_5'),
      },
    ];

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
          AppLocalizations(context).of('faq'),
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