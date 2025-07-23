
import 'package:pizzapopan_pos/models/product.dart';

class OrderItem {
  final Product product;
  int quantity;

  OrderItem({
    required this.product,
    this.quantity = 1,
  });

  double get totalPrice => product.price * quantity;

  void increment() {
    quantity++;
  }

  void decrement() {
    quantity--;
  }
}

