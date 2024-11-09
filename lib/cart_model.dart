import 'package:flutter/material.dart';
import 'product_model.dart';

class CartModel extends ChangeNotifier {
  List<Map<String, dynamic>> _cart = [];

  List<Map<String, dynamic>> get cart => _cart;

  void addToCart(Product product, int quantity) {
    if (quantity > 0) {
      _cart.add({'product': product, 'quantity': quantity});
      notifyListeners();
    }
  }

  double get totalCost {
    return _cart.fold(0, (sum, item) {
      return sum + (item['product'].price * item['quantity']);
    });
  }
}
