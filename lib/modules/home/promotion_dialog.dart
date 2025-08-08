import 'package:flutter/material.dart';
import '../../language/appLocalizations.dart';

class PromotionDialog extends StatelessWidget {
  final Map<String, dynamic>? selectedPromotion;
  final Function(Map<String, dynamic>) onPromotionSelected;
  final bool isDarkMode;
  const PromotionDialog({Key? key, required this.selectedPromotion, required this.onPromotionSelected, required this.isDarkMode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(AppLocalizations(context).of("select_promotion"), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: isDarkMode ? Colors.white : Colors.black)),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.close, color: isDarkMode ? Colors.white : Colors.black),
              ),
            ],
          ),
          SizedBox(height: 16),
          _buildPromotionCard(context, 'SPECIAL OFFER - 10% OFF', '10% off up to 20K, minimum order 150K', 'Applies to all payment methods.', 20000),
          SizedBox(height: 12),
          _buildPromotionCard(context, 'HN EXPLOSIVE DEAL', '10K off, minimum order 100K', 'Applies to MoMo wallet, ZaloPay wallet, ShopeePay wallet, Credit card, ATM card.', 10000),
          SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildPromotionCard(BuildContext context, String title, String description, String applicability, int amount) {
    final isSelected = selectedPromotion != null && selectedPromotion!['amount'] == amount;
    return GestureDetector(
      onTap: () {
        onPromotionSelected({
          'title': title,
          'description': description,
          'applicability': applicability,
          'amount': amount,
        });
        Navigator.pop(context);
      },
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange.withOpacity(0.1) : (isDarkMode ? Colors.grey[800] : Colors.grey[50]),
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? Border.all(color: Colors.orange, width: 2) : null,
        ),
        child: Row(
          children: [
            Radio<int>(
              value: amount,
              groupValue: selectedPromotion?['amount'],
              onChanged: (value) {
                onPromotionSelected({
                  'title': title,
                  'description': description,
                  'applicability': applicability,
                  'amount': value!,
                });
                Navigator.pop(context);
              },
              activeColor: Colors.orange,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black)),
                  SizedBox(height: 4),
                  Text(description, style: TextStyle(color: isDarkMode ? Colors.grey[400] : Colors.grey[600], fontSize: 12)),
                  SizedBox(height: 4),
                  Text(applicability, style: TextStyle(color: isDarkMode ? Colors.grey[400] : Colors.grey[600], fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}