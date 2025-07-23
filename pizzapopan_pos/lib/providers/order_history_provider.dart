
import 'package:flutter/material.dart';
import 'package:pizzapopan_pos/models/order.dart';

class OrderHistoryProvider with ChangeNotifier {
  final List<Order> _orders = [];

  List<Order> get orders => _orders;

  void addOrder(Order order) {
    _orders.insert(0, order); // Add to the beginning of the list
    notifyListeners();
  }
}
