import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled3/widgets/item_selection.dart';
import 'package:untitled3/widgets/section_title.dart';

import '../providers/cart_provider.dart';
import 'grid_screen.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {

  final List<String> summaryOptions = [
    'Classroom 203',
    'Classroom 205',
    'Classroom 207',
  ];

  String selectedSummary = 'Classroom 207';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Choosing Delivery Address:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: DropdownButton<String>(
                          value: selectedSummary,
                          isExpanded: true,
                          items: summaryOptions.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Center(
                                child: Text(
                                  value,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedSummary = newValue!;
                            });
                          },
                        ),
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {_finishOrder(context);;},
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
                          'Confirm Request',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    // The image fills remaining space inside the column
                    Expanded(
                      child: Image.asset(
                        'assets/images/MSBMap.png',
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      backgroundColor: Colors.grey[100],
    );
  }

  void _finishOrder(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment Successful'),
        content: Text(
          'Thank you for your order! I will arrive at your location soon!',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Future.microtask(() {
                Navigator.pop(context);
              }).then((_) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const GridPage()),
                );
              });
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
