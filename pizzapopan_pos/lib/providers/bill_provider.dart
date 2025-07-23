import 'package:flutter/material.dart';
import 'package:pizzapopan_pos/models/custom_pizza.dart';
import 'package:pizzapopan_pos/models/order_item.dart';
import 'package:pizzapopan_pos/models/product.dart';

class BillProvider with ChangeNotifier {
  final List<OrderItem> _items = [];

  List<OrderItem> get items => _items;

  double get totalPrice {
    return _items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  int get totalItems {
    return _items.fold(0, (sum, item) => sum + item.quantity);
  }

  void addItem(Product product) {
    if (product is CustomPizza) {
      final existingItemIndex = _items.indexWhere(
          (item) => item.product is CustomPizza && item.product == product);

      if (existingItemIndex != -1) {
        _items[existingItemIndex].increment();
      } else {
        _items.add(OrderItem(product: product));
      }
    } else {
      final existingItemIndex = _items.indexWhere((item) => item.product.name == product.name);

      if (existingItemIndex != -1) {
        _items[existingItemIndex].increment();
      } else {
        _items.add(OrderItem(product: product));
      }
    }

    notifyListeners();
  }

  void removeItem(OrderItem item) {
    final existingItemIndex = _items.indexWhere((i) => i.product.name == item.product.name);

    if (existingItemIndex != -1) {
      _items[existingItemIndex].decrement();
      if (_items[existingItemIndex].quantity <= 0) {
        _items.removeAt(existingItemIndex);
      }
    }

    notifyListeners();
  }

  void removeItemCompletely(OrderItem item) {
    _items.removeWhere((i) => i.product.name == item.product.name);
    notifyListeners();
  }

  void clearBill() {
    _items.clear();
    notifyListeners();
  }
}