import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
import 'package:pizzapopan_pos/widgets/custom_notification.dart';
import 'package:pizzapopan_pos/widgets/ingredient_dialog.dart';
import 'package:pizzapopan_pos/widgets/split_view.dart';
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
  bool _isSearching = false;

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

  double _getFontSize(double baseSize) {
    return baseSize.sp.clamp(14.0, 22.0);
  }

  @override
  Widget build(BuildContext context) {
    final billProvider = Provider.of<BillProvider>(context);
    final orderHistoryProvider =
        Provider.of<OrderHistoryProvider>(context, listen: false);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/backgrounds/fondo_ladrillos.webp'),
            fit: BoxFit.cover,
          ),
        ),
        child: SplitView(
          left: _buildBillPanel(billProvider, orderHistoryProvider),
          right: _buildMenuPanel(),
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
                item.name
                    .toLowerCase()
                    .contains(_searchController.text.toLowerCase()))
            .toList();

        return Column(
          children: [
            // Category buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: ElevatedButton(
                      onPressed: () =>
                          setState(() => _selectedCategory = ProductCategory.pizzas),
                      child: Icon(Icons.local_pizza, size: _getFontSize(30)),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: ElevatedButton(
                      onPressed: () =>
                          setState(() => _selectedCategory = ProductCategory.boneless),
                      child: Icon(Icons.fastfood, size: _getFontSize(30)),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: ElevatedButton(
                      onPressed: () =>
                          setState(() => _selectedCategory = ProductCategory.bebidas),
                      child: Icon(Icons.local_bar, size: _getFontSize(30)),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: ElevatedButton(
                      onPressed: () =>
                          setState(() => _selectedCategory = ProductCategory.extras),
                      child: Icon(Icons.add, size: _getFontSize(30)),
                    ),
                  ),
                ),
                Flexible(child: _buildSearchWidget()),
              ],
            ),
            // Menu items
            Expanded(
              child: LayoutBuilder(builder: (context, constraints) {
                final crossAxisCount = (constraints.maxWidth / menuProvider.itemSize).floor();
                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount > 0 ? crossAxisCount : 1,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: filteredItems.length,
                  itemBuilder: (context, index) {
                    final product = filteredItems[index];
                    return GestureDetector(
                      onTap: () async {
                        if (product.name == 'Al gusto') {
                          final selectedIngredients =
                              await showDialog<List<Ingredient>>(
                            context: context,
                            builder: (context) => const IngredientDialog(),
                          );
                          if (selectedIngredients != null &&
                              selectedIngredients.isNotEmpty) {
                            final customPizza = CustomPizza(
                              name: 'Al gusto',
                              description: selectedIngredients
                                  .map((i) => i.name)
                                  .join(', '),
                              price: product.price,
                              image: product.image,
                              category: product.category,
                              ingredients: selectedIngredients,
                            );
                            Provider.of<BillProvider>(context, listen: false)
                                .addItem(customPizza);
                          }
                        } else {
                          Provider.of<BillProvider>(context, listen: false)
                              .addItem(product);
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
                              padding: const EdgeInsets.all(8.0),
                              child: Text(product.name,
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  style: TextStyle(fontSize: _getFontSize(16))),
                            ),
                            Text('\$${product.price.toStringAsFixed(2)}',
                                style: TextStyle(
                                    fontSize: _getFontSize(16),
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
            Slider(
              value: menuProvider.itemSize,
              min: 120,
              max: 300,
              onChanged: (double value) {
                menuProvider.setItemSize(value);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildSearchWidget() {
    return _isSearching
        ? Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Buscar',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        _isSearching = false;
                        _searchController.clear();
                      });
                    },
                  ),
                ),
              ),
            ),
          )
        : IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = true;
              });
            },
          );
  }

  Widget _buildBillPanel(
      BillProvider billProvider, OrderHistoryProvider orderHistoryProvider) {
    return Container(
      color: Colors.white.withOpacity(0.8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.history),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const OrderHistoryScreen()),
                  );
                },
              ),
              Text(
                'Cuenta',
                style: TextStyle(fontSize: _getFontSize(30), fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 48.w), // To balance the row with the IconButton
            ],
          ),
          Expanded(
            child: ListView.separated(
              itemCount: billProvider.items.length,
              separatorBuilder: (context, index) =>
                  const Divider(thickness: 1.5),
              itemBuilder: (context, index) {
                final item = billProvider.items[index];
                return GestureDetector(
                  onTap: () => billProvider.removeItem(item),
                  onLongPress: () => billProvider.removeItemCompletely(item),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: 16.w, vertical: 8.h),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.product.name,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  style: TextStyle(fontSize: _getFontSize(16))),
                              if (item.product is CustomPizza)
                                Text(
                                    (item.product as CustomPizza).description,
                                    style: TextStyle(fontSize: _getFontSize(12))),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 100.w, // Adjust width as needed
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: '${item.quantity}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: _getQuantityColor(item.quantity),
                                      fontSize: _getFontSize(16),
                                    ),
                                  ),
                                  TextSpan(
                                      text: ' x ',
                                      style: TextStyle(fontSize: _getFontSize(16))),
                                  TextSpan(
                                      text:
                                          '\$${item.totalPrice.toStringAsFixed(2)}',
                                      style: TextStyle(fontSize: _getFontSize(16))),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(thickness: 1.5),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Artículos:',
                      style: TextStyle(fontSize: _getFontSize(16)),
                    ),
                    Text(
                      '${billProvider.totalItems}',
                      style: TextStyle(fontSize: _getFontSize(16)),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total:',
                      style: TextStyle(
                          fontSize: _getFontSize(20), fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '\$${billProvider.totalPrice.toStringAsFixed(2)}',
                      style: TextStyle(
                          fontSize: _getFontSize(20), fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: SizedBox(
                    height: 60.h,
                    child: ElevatedButton(
                      onPressed: () async {
                        final result =
                            await showDialog<Map<String, dynamic>>(
                          context: context,
                          builder: (context) => AddressDialog(),
                        );
                        if (result != null) {
                          setState(() {
                            _address = result['address'];
                            _isPickup = result['isPickup'];
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            (_address != null || _isPickup) ? Colors.green : null,
                      ),
                      child: Icon(Icons.delivery_dining, size: _getFontSize(30)),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: SizedBox(
                    height: 60.h,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_address == null && !_isPickup) {
                          showCustomNotification(
                              context, 'Favor de agregar dirección',
                              isError: true);
                          // TODO: Add flickering animation to the address button
                        } else if (billProvider.items.isNotEmpty) {
                          final order = Order(
                            id: orderHistoryProvider.getNextOrderId(),
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

                          showCustomNotification(
                              context, 'Orden guardada e impresa (simulado).');
                        }
                      },
                      child: Icon(Icons.print, size: _getFontSize(30)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getQuantityColor(int quantity) {
    if (quantity <= 1) {
      return Colors.black;
    } else if (quantity <= 3) {
      return Colors.green;
    } else if (quantity <= 5) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
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
  bool _canSave = false;

  @override
  void initState() {
    super.initState();
    _addressController.addListener(() {
      setState(() {
        _canSave = _addressController.text.isNotEmpty || _isPickup;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.all(16.0),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _addressController,
            decoration: const InputDecoration(
              labelText: 'Dirección',
              border: OutlineInputBorder(),
            ),
            enabled: !_isPickup,
          ),
          Padding(
            padding: EdgeInsets.only(top: 8.0.h),
            child: CheckboxListTile(
              title: const Text('Pickup'),
              value: _isPickup,
              onChanged: (value) {
                setState(() {
                  _isPickup = value!;
                  _canSave = _addressController.text.isNotEmpty || _isPickup;
                });
              },
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _canSave
              ? () {
                  Navigator.pop(context, {
                    'address': _addressController.text,
                    'isPickup': _isPickup,
                  });
                }
              : null,
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}