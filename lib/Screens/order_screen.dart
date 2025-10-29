import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:provider/provider.dart';
import 'package:untitled3/models/products.dart';
import 'package:untitled3/screens/cart_screen.dart';

import '../Enum/AllScreenInProject.dart';
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
  List<Product> products = [];
  int selectedIndex = 0;
  late IO.Socket socket;
  Timer? _inactivityTimer;

  @override
  void initState() {
    super.initState();
    _loadFakeData();
    _initSocket();
    // _resetInactivityTimer();
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
      socket.emit('join', {'room': '100'});
    });

    socket.on('TourchScreenAction', (data) {
      // print('Received action: $data');
      if (data['Move2Page'] ==
          AllScreenInProject.HOMEPAGESCREEN.toString().split('.').last) {
        if (mounted) {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const GridPage()));
        }
      }
    });

    socket.onConnectError((err) => print('⚠️ Connect error: $err'));
    socket.onDisconnect((_) => print('❌ Disconnected'));

    socket.connect();
  }

  @override
  void dispose() {
    socket.dispose();
    super.dispose();
  }

  Future<void> _loadFakeData() async {
    final jsonStr = await rootBundle.loadString('assets/data/fake_data.json');
    final Map<String, dynamic> data = jsonDecode(jsonStr);

    final List<Product> loadProducts = (data['products'] as List)
        .map((e) => Product.fromJson(e))
        .toList();

    setState(() {
      products = loadProducts;
    });
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

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Choose Food",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Stack(
              alignment: Alignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
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
              categories: this.products.map((e) => e.name).toList(),
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
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final p = products[index];
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
    );
  }
}
