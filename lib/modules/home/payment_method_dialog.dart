import 'package:flutter/material.dart';
import '../../language/appLocalizations.dart';

class PaymentMethodDialog extends StatelessWidget {
  final String selectedPaymentMethod;
  final Function(String) onPaymentMethodSelected;
  final bool isDarkMode;
  const PaymentMethodDialog({Key? key, required this.selectedPaymentMethod, required this.onPaymentMethodSelected, required this.isDarkMode}) : super(key: key);

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
              Text(AppLocalizations(context).of("choose_payment_method"), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: isDarkMode ? Colors.white : Colors.black)),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.close, color: isDarkMode ? Colors.white : Colors.black),
              ),
            ],
          ),
          SizedBox(height: 16),
          _buildPaymentMethodCard(context, Icons.account_balance, AppLocalizations(context).of("bank_transfer"), 'Transfer money to our bank account', 'bank'),
          SizedBox(height: 12),
          _buildPaymentMethodCard(context, Icons.money, AppLocalizations(context).of("cash_payment"), 'Pay directly at the hotel', 'cash'),
          SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodCard(BuildContext context, IconData icon, String title, String description, String value) {
    final isSelected = selectedPaymentMethod == value;
    return GestureDetector(
      onTap: () {
        onPaymentMethodSelected(value);
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
            Radio<String>(
              value: value,
              groupValue: selectedPaymentMethod,
              onChanged: (newValue) {
                onPaymentMethodSelected(newValue!);
                Navigator.pop(context);
              },
              activeColor: Colors.orange,
            ),
            Icon(icon, color: Colors.orange),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black)),
                  Text(description, style: TextStyle(color: isDarkMode ? Colors.grey[400] : Colors.grey[600], fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}