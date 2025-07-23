
import 'package:pizzapopan_pos/models/order_item.dart';

class Order {
  final String id;
  final List<OrderItem> items;
  final double totalPrice;
  final DateTime date;
  final String? address;
  final bool isPickup;

  Order({
    required this.id,
    required this.items,
    required this.totalPrice,
    required this.date,
    this.address,
    this.isPickup = false,
  });
}
