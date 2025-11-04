import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:untitled3/Screens/payment_screen.dart';
import 'package:untitled3/models/products.dart';
import 'package:untitled3/screens/cart_screen.dart';

import '../Enum/AllScreenInProject.dart';
import '../Services/ControlCamera.dart';
import '../models/cart.dart';
import '../providers/cart_provider.dart';
import '../widgets/category_tabs.dart';
import '../widgets/product_card.dart';

import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'grid_screen.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final beUrl = dotenv.env['BE_URL'] ?? "http://10.0.2.2:8000/robots/";
  final robotId = dotenv.env['ID_ROBOT'] ?? "1";

  List<Product> products = [];
  final Map<int, String> category = {0: "BEVERAGE", 1: "SNACK"};
  List<Product> ShowProducts = [];
  int selectedIndex = 0;
  late IO.Socket socket;
  Timer? _inactivityTimer;

  @override
  void initState() {
    super.initState();
    ControlCamera.callCameraAPI(action: 'start', IDDeliveryRecord: "None");
    _loadFakeData();
    _initSocket();
    _startInactivityTimer();
  }

  void _startInactivityTimer() {

    _inactivityTimer?.cancel();

    _inactivityTimer = Timer(const Duration(seconds: 5), () async {
      if (!mounted) return;

      // Show a blocking loading dialog
      showDialog(
        context: context,
        barrierDismissible: false, // prevents user from closing it
        builder: (context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      // Add a short delay to let the loading show before navigating
      await Future.delayed(const Duration(seconds: 1));

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

    socket.on('TourchScreenAction', (data) {
      // print('Received action: $data');
      if (data['Move2Page'] ==
          AllScreenInProject.HOMEPAGESCREEN.toString().split('.').last) {
        if (mounted) {
          socket.off('TourchScreenAction');
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
      } else if (data['Move2Page'] ==
          AllScreenInProject.PAYMENTSCREEN.toString().split('.').last) {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const PaymentScreen()),
          );
        }
      }
    });

    socket.onConnectError((err) => print('⚠️ Connect error: $err'));
    socket.onDisconnect((_) => print('❌ Disconnected'));

    socket.connect();
  }

  @override
  void dispose() {
    // socket.dispose();
    super.dispose();
    _inactivityTimer?.cancel();
  }

  Future<void> _loadFakeData() async {
    final jsonStr = await rootBundle.loadString('assets/data/fake_data.json');
    final Map<String, dynamic> data = jsonDecode(jsonStr);

    final List<Product> loadProducts = (data['inventory_items'] as List)
        .map((e) => Product.fromJson(e))
        .toList();

    setState(() {
      products = loadProducts;
    });
  }

  //real app use this function
  Future<void> _loadFakeData2() async {
    try {
      // Fetch robot data from API
      final response = await http.get(Uri.parse("$beUrl/robots/$robotId"));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        // Extract the inventory_items list
        final List<Product> loadProducts = (data['inventory_items'] as List)
            .map((e) => Product.fromJson(e))
            .toList();

        setState(() {
          products = loadProducts;
        });
      } else {
        print('Failed to load data from API: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    // Nếu chưa load xong JSON
    if (this.products.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // final currentCategory = this.products[selectedIndex];
    // final products = currentCategory;

    return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _resetTimer,
        onPanDown: (_) => _resetTimer(),
        child:  Scaffold(
      appBar: AppBar(
        title: const Text(
          "Choose Food",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Stack(
              alignment: Alignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const CartScreen()),
                    );
                  },
                  icon: const Icon(Icons.shopping_cart_outlined),
                  label: const Text('Cart'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
                // Số lượng sản phẩm nhỏ trên icon
                if (cartProvider.totalItems > 0)
                  Positioned(
                    right: 6,
                    top: 4,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        cartProvider.totalItems.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      body: Listener(
        onPointerDown: (_) => () {},
        behavior: HitTestBehavior.translucent,
        child: Column(
          children: [
            CategoryTabs(
              categories: category.values.toList(),
              selectedIndex: selectedIndex,
              onTap: (i) => setState(() => selectedIndex = i),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 3 / 4,
                ),
                // itemCount: products.length,
                itemCount: products
                    .where((p) => p.category == category[selectedIndex])
                    .length,
                itemBuilder: (context, index) {
                  final filteredProducts = products
                      .where((p) => p.category == category[selectedIndex])
                      .toList();
                  final p = filteredProducts[index];
                  return ProductCard(
                    product: p,
                    onAddToCart: (quantity) {
                      cartProvider.addToCart(p, quantity: quantity);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${p.name} added to cart'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ),);
  }
}
