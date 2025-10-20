import 'package:flutter/material.dart';

import '../models/cart.dart';
import '../models/products.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  int get totalItems => _items.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice => _items.fold(0, (sum, item) => sum + item.totalPrice);

  void addToCart(Product product, {int quantity = 1}) {
    final index = _items.indexWhere(
      (e) => e.product.name == product.name && e.product.id == product.id,
    );
    if (index != -1) {
      _items[index].quantity += quantity;
    } else {
      _items.add(CartItem(product: product, quantity: quantity));
    }
    notifyListeners();
  }

  void removeFromCart(Product product, {bool isRemoveItem = false}) {
    final index = _items.indexWhere(
      (e) => e.product.name == product.name && e.product.id == product.id,
    );
    if (index != -1) {
      if (_items[index].quantity > 1 && !isRemoveItem) {
        _items[index].quantity--;
      } else if (isRemoveItem) {
        _items.removeAt(index);
      } else {
        print('Could not remove item at index');
      }
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
