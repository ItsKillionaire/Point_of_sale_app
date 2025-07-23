import 'package:flutter_test/flutter_test.dart';
import 'package:pizzapopan_pos/models/product.dart';
import 'package:pizzapopan_pos/models/product_category.dart';
import 'package:pizzapopan_pos/providers/bill_provider.dart';

void main() {
  group('BillProvider', () {
    late BillProvider billProvider;

    setUp(() {
      billProvider = BillProvider();
    });

    test('Initial values are correct', () {
      expect(billProvider.items, []);
      expect(billProvider.totalPrice, 0.0);
    });

    test('addItem adds a product to the bill', () {
      final product = Product(
        name: 'Test Pizza',
        description: 'A delicious test pizza',
        price: 10.0,
        image: 'test.png',
        category: ProductCategory.pizzas,
      );

      billProvider.addItem(product);

      expect(billProvider.items.length, 1);
      expect(billProvider.items[0].product, product);
      expect(billProvider.totalPrice, 10.0);
    });

    test('addItem increments the quantity of an existing product', () {
      final product = Product(
        name: 'Test Pizza',
        description: 'A delicious test pizza',
        price: 10.0,
        image: 'test.png',
        category: ProductCategory.pizzas,
      );

      billProvider.addItem(product);
      billProvider.addItem(product);

      expect(billProvider.items.length, 1);
      expect(billProvider.items[0].quantity, 2);
      expect(billProvider.totalPrice, 20.0);
    });

    test('removeItem decrements the quantity of a product', () {
      final product = Product(
        name: 'Test Pizza',
        description: 'A delicious test pizza',
        price: 10.0,
        image: 'test.png',
        category: ProductCategory.pizzas,
      );

      billProvider.addItem(product);
      billProvider.addItem(product);
      billProvider.removeItem(billProvider.items[0]);

      expect(billProvider.items.length, 1);
      expect(billProvider.items[0].quantity, 1);
      expect(billProvider.totalPrice, 10.0);
    });

    test('removeItem removes a product if the quantity is 1', () {
      final product = Product(
        name: 'Test Pizza',
        description: 'A delicious test pizza',
        price: 10.0,
        image: 'test.png',
        category: ProductCategory.pizzas,
      );

      billProvider.addItem(product);
      billProvider.removeItem(billProvider.items[0]);

      expect(billProvider.items.length, 0);
      expect(billProvider.totalPrice, 0.0);
    });

    test('removeItemCompletely removes a product from the bill', () {
      final product = Product(
        name: 'Test Pizza',
        description: 'A delicious test pizza',
        price: 10.0,
        image: 'test.png',
        category: ProductCategory.pizzas,
      );

      billProvider.addItem(product);
      billProvider.addItem(product);
      billProvider.removeItemCompletely(billProvider.items[0]);

      expect(billProvider.items.length, 0);
      expect(billProvider.totalPrice, 0.0);
    });

    test('clearBill removes all items from the bill', () {
      final product1 = Product(
        name: 'Test Pizza 1',
        description: 'A delicious test pizza',
        price: 10.0,
        image: 'test.png',
        category: ProductCategory.pizzas,
      );
      final product2 = Product(
        name: 'Test Pizza 2',
        description: 'A delicious test pizza',
        price: 12.0,
        image: 'test.png',
        category: ProductCategory.pizzas,
      );

      billProvider.addItem(product1);
      billProvider.addItem(product2);
      billProvider.clearBill();

      expect(billProvider.items.length, 0);
      expect(billProvider.totalPrice, 0.0);
    });
  });
}
