import 'package:flutter/material.dart';
import '../models/products.dart';
import '../models/cart.dart';

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

  void removeFromCart(Product product) {
    final index = _items.indexWhere(
      (e) => e.product.name == product.name && e.product.id == product.id,
    );
    if (index != -1) {
      if (_items[index].quantity > 1) {
        _items[index].quantity--;
      } else {
        _items.removeAt(index);
      }
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
