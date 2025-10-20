import 'package:flutter/material.dart';
import 'package:untitled3/widgets/item_selection.dart';
import 'package:untitled3/widgets/section_title.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedMethod = 'cash';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Order Summary ---
            SectionTitle(title: 'Order Sumary'),
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildSummaryRow('Subtotal', '\$120.00'),
                  const SizedBox(height: 8),
                  _buildSummaryRow('Shipping Fee', '\$5.00'),
                  const Divider(height: 20, color: Colors.grey),
                  _buildSummaryRow(
                    'Total',
                    '\$125.00',
                    isTotal: true,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
            ),

            // --- Payment Method ---
            SectionTitle(title: 'Payment Method'),
            const SizedBox(height: 8),
            ItemSelection(
              icon: Icons.money,
              title: 'Cash on Delivery',
              value: 'cash',
              selected: _selectedMethod == 'cash',
              onSelect: () => {setState(() => _selectedMethod = 'cash')},
            ),
            ItemSelection(
              icon: Icons.credit_card,
              title: 'Credit/Debit Card',
              value: 'card',
              selected: _selectedMethod == 'card',
              onSelect: () => {setState(() => _selectedMethod = 'card')},
            ),
            ItemSelection(
              icon: Icons.account_balance_wallet,
              title: 'E-Wallet',
              value: 'wallet',
              images: ['assets/images/momo.png', 'assets/images/zaloPay.png'],
              selected: _selectedMethod == 'wallet',
              onSelect: () => {setState(() => _selectedMethod = 'wallet')},
            ),

            const SizedBox(height: 24),

            // --- Payment Button ---
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _handlePayment(context);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 20,
                  ),
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Confirm Payment',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.grey[100],
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isTotal = false,
    Color? color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 18 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w400,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 18 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: color ?? Colors.black87,
          ),
        ),
      ],
    );
  }

  void _handlePayment(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment Successful'),
        content: Text(
          'You have paid using: ${_selectedMethod.toUpperCase()}.\nThank you for your order!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
