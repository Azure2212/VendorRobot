import 'dart:async';
import 'dart:convert';
import 'package:untitled3/screens/cart_screen.dart';
import 'package:untitled3/screens/grid_screen.dart';

import '../providers/cart_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:provider/provider.dart';

import '../models/category.dart';
import '../widgets/category_tabs.dart';
import '../widgets/product_card.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  List<Category> categories = [];
  int selectedIndex = 0;

  Timer? _inactivityTimer;

  @override
  void initState() {
    super.initState();
    _loadFakeData();
    _resetInactivityTimer();
  }

  // tranh leak nhieu lan
  @override
  void dispose() {
    _inactivityTimer?.cancel();
    super.dispose();
  }

  void _resetInactivityTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(const Duration(seconds: 5), () {
      //Bat su kien mount
      if (mounted) {
        debugPrint("5s inactivity detected");
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const GridPage()),
          (route) => false,
        );
      }
    });
  }

  void _onUserActivity() {
    _resetInactivityTimer();
  }

  Future<void> _loadFakeData() async {
    final jsonStr = await rootBundle.loadString('assets/data/fake_data.json');
    final Map<String, dynamic> data = jsonDecode(jsonStr);

    final List<Category> loadedCategories = (data['categories'] as List)
        .map((e) => Category.fromJson(e))
        .toList();

    setState(() {
      categories = loadedCategories;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    // Nếu chưa load xong JSON
    if (categories.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final currentCategory = categories[selectedIndex];
    final products = currentCategory.products;

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
                    right: 8,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
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
        onPointerDown: (_) => _onUserActivity(),
        behavior: HitTestBehavior.translucent,
        child: Column(
          children: [
            CategoryTabs(
              categories: categories.map((e) => e.name).toList(),
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
