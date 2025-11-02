import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:untitled3/Enum/DeliveryRecordStatus.dart';
import 'package:untitled3/Services/DeliveryRecordService.dart';

import '../Services/ControlCamera.dart';
import '../models/DeliveryRecord.dart';
import '../models/cart.dart';
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

  final beUrl = dotenv.env['BE_URL'] ?? "http://10.0.2.2:8000/";
  final robotId = dotenv.env['ID_ROBOT'] ?? "1";

  String selectedSummary = 'Classroom 207';

  final ScrollController _scrollController = ScrollController();
  bool _showScrollButton = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 50) {
        if (_showScrollButton) {
          setState(() => _showScrollButton = false);
        }
      } else {
        if (!_showScrollButton) {
          setState(() => _showScrollButton = true);
        }
      }
    });
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _handleConfirmRequest(CartProvider cartProvider) async {
    if (cartProvider.items.isEmpty) return;
    List<String> inventoryIds = [];
    List<String> quantity = [];

    for (CartItem item in cartProvider.items) {
      inventoryIds.add(item.product.id.toString());
      quantity.add(item.quantity.toString());
    }

    DeliveryRecord record = DeliveryRecord(
      robotId: robotId.toString(),
      address: selectedSummary,
      status: DeliveryRecordStatus.WAITING.toString().split('.').last,
      message: "Created successful!",
      inventoryIds: inventoryIds.join(', '),
      quantity: quantity.join(', '),
      createdAt: DateTime.now(),
      lastUpdatedAt: DateTime.now(),
    );

    // try {
    //   print(jsonEncode(record.toJson()));
    //   final response = await http.post(
    //     Uri.parse("$beUrl/deliveryRecord/"),
    //     headers: {
    //       "Content-Type": "application/json",
    //     },
    //     body: jsonEncode(record.toJson()), // serialize your DeliveryRecord
    //   );
    //
    //   if (response.statusCode == 200 || response.statusCode == 201) {
    //     print("Delivery record sent successfully!");
    //     print(response.body);
    //   } else {
    //     print("Failed to send delivery record: ${response.statusCode}");
    //     print(response.body);
    //   }
    // } catch (e) {
    //   print("Error sending delivery record: $e");
    // }
    // List<DeliveryRecord> allDeliveryRecord = await DeliveryRecordService.getAllRecordByRobotID();
    // print(allDeliveryRecord.length);
    ControlCamera.callCameraAPI(action: 'stop', IDDeliveryRecord: '1');
    cartProvider.clearCart();
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Choosing Delivery Address:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
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
                            onPressed: () {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                // user cannot tap outside to dismiss
                                builder: (dialogContext) {
                                  Future.delayed(
                                    const Duration(seconds: 1), () async {
                                      await _handleConfirmRequest(cartProvider);
                                      if (dialogContext.mounted) {
                                        Navigator.of(
                                          dialogContext,
                                        ).pop();
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => const GridPage(),
                                          ),
                                        );
                                      }
                                    },
                                  );

                                  return AlertDialog(
                                    title: const Text('Booking Confirmed'),
                                    content: const Text(
                                      'Thank you for your booking, products will transfer to your address soon',
                                    ),
                                    actions: [
                                      // TextButton(
                                      //   onPressed: () async {
                                      //     await _handleConfirmRequest(
                                      //       cartProvider,
                                      //     );
                                      //
                                      //     if (dialogContext.mounted) {
                                      //       Navigator.of(dialogContext).pop();
                                      //       Navigator.pushReplacement(
                                      //         context,
                                      //         MaterialPageRoute(
                                      //           builder: (_) =>
                                      //               const GridPage(),
                                      //         ),
                                      //       );
                                      //     }
                                      //   },
                                      //   child: const Text('OK'),
                                      // ),
                                    ],
                                  );
                                },
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 20,
                              ),
                              backgroundColor: Colors.redAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Confirm Booking',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
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

          AnimatedOpacity(
            opacity: _showScrollButton ? 1 : 0,
            duration: const Duration(milliseconds: 300),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: ElevatedButton(
                  onPressed: _scrollToBottom,
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(16),
                  ),
                  child: const Icon(Icons.arrow_downward),
                ),
              ),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.grey[100],
    );
  }
}
