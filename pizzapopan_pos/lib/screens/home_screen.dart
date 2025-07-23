import 'package:flutter/material.dart';
import 'package:pizzapopan_pos/models/custom_pizza.dart';
import 'package:pizzapopan_pos/models/ingredient.dart';
import 'package:pizzapopan_pos/models/order.dart';
import 'package:pizzapopan_pos/models/order_item.dart';
import 'package:pizzapopan_pos/models/product.dart';
import 'package:pizzapopan_pos/models/product_category.dart';
import 'package:pizzapopan_pos/providers/bill_provider.dart';
import 'package:pizzapopan_pos/providers/menu_provider.dart';
import 'package:pizzapopan_pos/providers/order_history_provider.dart';
import 'package:pizzapopan_pos/screens/order_history_screen.dart';
import 'package:pizzapopan_pos/widgets/ingredient_dialog.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ProductCategory _selectedCategory = ProductCategory.pizzas;
  final _searchController = TextEditingController();
  String? _address;
  bool _isPickup = false;

  @override
  void initState() {
    super.initState();
    Provider.of<MenuProvider>(context, listen: false).loadMenu();
    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final billProvider = Provider.of<BillProvider>(context);
    final orderHistoryProvider = Provider.of<OrderHistoryProvider>(context, listen: false);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/backgrounds/fondo_ladrillos.webp'),
            fit: BoxFit.cover,
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 600) {
              // Wide screen layout
              return Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: _buildBillPanel(billProvider, orderHistoryProvider),
                  ),
                  Expanded(
                    flex: 2,
                    child: _buildMenuPanel(),
                  ),
                ],
              );
            } else {
              // Narrow screen layout
              return Column(
                children: [
                  Expanded(
                    flex: 1,
                    child: _buildBillPanel(billProvider, orderHistoryProvider),
                  ),
                  Expanded(
                    flex: 2,
                    child: _buildMenuPanel(),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildMenuPanel() {
    return Consumer<MenuProvider>(
      builder: (context, menuProvider, child) {
        final filteredItems = menuProvider.menuItems
            .where((item) =>
                item.category == _selectedCategory &&
                item.name.toLowerCase().contains(_searchController.text.toLowerCase()))
            .toList();

        return Column(
          children: [
            // Category buttons
            Wrap(
              alignment: WrapAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => setState(() => _selectedCategory = ProductCategory.pizzas),
                  child: const Text('Pizzas'),
                ),
                ElevatedButton(
                  onPressed: () => setState(() => _selectedCategory = ProductCategory.boneless),
                  child: const Text('Boneless'),
                ),
                ElevatedButton(
                  onPressed: () => setState(() => _selectedCategory = ProductCategory.bebidas),
                  child: const Text('Bebidas'),
                ),
                ElevatedButton(
                  onPressed: () => setState(() => _selectedCategory = ProductCategory.extras),
                  child: const Text('Extras'),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  labelText: 'Buscar',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
            // Menu items
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.8,
                ),
                itemCount: filteredItems.length,
                itemBuilder: (context, index) {
                  final product = filteredItems[index];
                  return GestureDetector(
                    onTap: () async {
                      if (product.name == 'Pizza al gusto') {
                        final selectedIngredients = await showDialog<List<Ingredient>>(
                          context: context,
                          builder: (context) => const IngredientDialog(),
                        );
                        if (selectedIngredients != null && selectedIngredients.isNotEmpty) {
                          final customPizza = CustomPizza(
                            name: 'Pizza al gusto',
                            description: selectedIngredients.map((i) => i.name).join(', '),
                            price: product.price,
                            image: product.image,
                            category: product.category,
                            ingredients: selectedIngredients,
                          );
                          Provider.of<BillProvider>(context, listen: false).addItem(customPizza);
                        }
                      } else {
                        Provider.of<BillProvider>(context, listen: false).addItem(product);
                      }
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: [
                          Expanded(
                            child: Image.asset(
                              product.image,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Text(product.name, textAlign: TextAlign.center),
                          ),
                          Text('\$${product.price.toStringAsFixed(2)}'),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBillPanel(BillProvider billProvider, OrderHistoryProvider orderHistoryProvider) {
    return Container(
      color: Colors.white.withOpacity(0.8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Cuenta',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.history),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const OrderHistoryScreen()),
                  );
                },
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: billProvider.items.length,
              itemBuilder: (context, index) {
                final item = billProvider.items[index];
                return GestureDetector(
                  onTap: () => billProvider.removeItem(item),
                  onLongPress: () => billProvider.removeItemCompletely(item),
                  child: ListTile(
                    title: Text(item.product.name),
                    subtitle: item.product is CustomPizza ? Text((item.product as CustomPizza).description) : null,
                    trailing: Text('${item.quantity} x \$${item.product.price.toStringAsFixed(2)}'),
                  ),
                );
              },
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  '\$${billProvider.totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () async {
                  final result = await showDialog<Map<String, dynamic>>(
                    context: context,
                    builder: (context) => const AddressDialog(),
                  );
                  if (result != null) {
                    setState(() {
                      _address = result['address'];
                      _isPickup = result['isPickup'];
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: (_address != null || _isPickup) ? Colors.green : null,
                ),
                child: const Text('Dirección'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_address == null && !_isPickup) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Favor de agregar dirección'),
                      ),
                    );
                    // TODO: Add flickering animation to the address button
                  } else if (billProvider.items.isNotEmpty) {
                    final order = Order(
                      id: DateTime.now().toIso8601String(),
                      items: billProvider.items.map((orderItem) {
                        return OrderItem(
                          product: orderItem.product,
                          quantity: orderItem.quantity,
                        );
                      }).toList(),
                      totalPrice: billProvider.totalPrice,
                      date: DateTime.now(),
                      address: _address,
                      isPickup: _isPickup,
                    );

                    orderHistoryProvider.addOrder(order);
                    billProvider.clearBill();
                    setState(() {
                      _address = null;
                      _isPickup = false;
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Orden guardada e impresa (simulado).'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
                child: const Text('Imprimir'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AddressDialog extends StatefulWidget {
  const AddressDialog({super.key});

  @override
  State<AddressDialog> createState() => _AddressDialogState();
}

class _AddressDialogState extends State<AddressDialog> {
  final _addressController = TextEditingController();
  bool _isPickup = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Dirección'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _addressController,
            decoration: const InputDecoration(
              labelText: 'Dirección',
            ),
            enabled: !_isPickup,
          ),
          CheckboxListTile(
            title: const Text('Pickup'),
            value: _isPickup,
            onChanged: (value) {
              setState(() {
                _isPickup = value!;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, {
              'address': _addressController.text,
              'isPickup': _isPickup,
            });
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}