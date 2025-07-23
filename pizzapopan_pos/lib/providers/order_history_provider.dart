import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pizzapopan_pos/models/order.dart';

class OrderHistoryProvider with ChangeNotifier {
  final List<Order> _orders = [];
  int _lastOrderNumber = 0;
  String _lastOrderDate = '';

  List<Order> get orders => _orders;

  void addOrder(Order order) {
    _orders.insert(0, order); // Add to the beginning of the list
    notifyListeners();
  }

  String getNextOrderId() {
    final now = DateTime.now();
    final today = DateFormat('ddMMyy').format(now);

    if (_lastOrderDate == today) {
      _lastOrderNumber++;
    } else {
      _lastOrderNumber = 1;
      _lastOrderDate = today;
    }

    return '${_lastOrderNumber.toString().padLeft(2, '0')}-$today';
  }
}