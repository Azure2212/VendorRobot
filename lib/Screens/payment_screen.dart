import 'dart:async';

import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:untitled3/Enum/DeliveryRecordStatus.dart';
import 'package:untitled3/Services/DeliveryRecordService.dart';

import '../Enum/AllScreenInProject.dart';
import '../Services/ControlCamera.dart';
import '../Services/ProductService.dart';
import '../models/DeliveryRecord.dart';
import '../models/cart.dart';
import '../models/products.dart';
import '../providers/cart_provider.dart';
import 'cart_screen.dart';
import 'grid_screen.dart';
import 'order_screen.dart';

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
  late IO.Socket socket;
  Timer? _inactivityTimer;

  void _startInactivityTimer() {
    _inactivityTimer?.cancel();

    _inactivityTimer = Timer(const Duration(seconds: 30), () async {
      if (!mounted) return;

      // Show a blocking loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return WillPopScope(
            onWillPop: () async => false, // disable back button
            child: const AlertDialog(
              backgroundColor: Colors.white,
              title: Text(
                "System Restarting",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Please wait a moment, the system is restarting...",
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  CircularProgressIndicator(),
                ],
              ),
            ),
          );
        },
      );

      // ✅ Give UI time to render the dialog first
      await Future.delayed(const Duration(milliseconds: 100));

      if (mounted) {
        final cartProvider = Provider.of<CartProvider>(context, listen: false);
        cartProvider.clearCart();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const GridPage()),
        );
      }
    });
  }

  void _resetTimer() {
    _startInactivityTimer();
  }

  void _initSocket() {
    socket = IO.io(
      'https://hricameratest.onrender.com',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableReconnection()
          .disableAutoConnect()
          .build(),
    );

    socket.onConnect((_) {
      print('✅ Connected to server');
      socket.emit('join', {'room': robotId});
    });

    socket.on('TourchScreenAction', (data) async {
      // print('Received action: $data');
      if (data['Move2Page'] ==
          AllScreenInProject.ORDERSCREEN.toString().split('.').last) {
        if (mounted) {
          final int typeProduct = data['value'] != null ? data['value'] : 0;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => OrderScreen(typeProduct: typeProduct)),
          );
        }
      } else if (data['Move2Page'] ==
          AllScreenInProject.HOMEPAGESCREEN.toString().split('.').last) {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const GridPage()),
          );
        }
      } else if (data['Move2Page'] ==
          AllScreenInProject.CARTSCREEN.toString().split('.').last) {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const CartScreen()),
          );
        }
      }
    });

    socket.onConnectError((err) => print('⚠️ Connect error: $err'));
    socket.onDisconnect((_) => print('❌ Disconnected'));

    socket.connect();
  }

  @override
  void initState() {
    super.initState();
    _startInactivityTimer();
    _initSocket();
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

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: _resetTimer,
      onPanDown: (_) => _resetTimer(),
      child: Scaffold(
        appBar: AppBar(
          leadingWidth: 80, // make space for bigger button
          leading: Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const CartScreen()),
                );
              },
              icon: const Icon(Icons.arrow_back, size: 28), // bigger icon
              label: const Text(
                "",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
            ),
          ),
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
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  // user cannot tap outside to dismiss
                                  builder: (dialogContext) {
                                    Future.delayed(
                                      const Duration(seconds: 1),
                                      () async {
                                        await _handleConfirmRequest(
                                          cartProvider,
                                        );
                                        if (dialogContext.mounted) {
                                          Navigator.of(dialogContext).pop();
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
      ),
    );
  }
}
