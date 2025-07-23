
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pizzapopan_pos/models/custom_pizza.dart';
import 'package:pizzapopan_pos/providers/order_history_provider.dart';
import 'package:provider/provider.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orderHistoryProvider = Provider.of<OrderHistoryProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Ordenes'),
      ),
      body: ListView.builder(
        itemCount: orderHistoryProvider.orders.length,
        itemBuilder: (context, index) {
          final order = orderHistoryProvider.orders[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Orden: ${order.id}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Fecha: ${DateFormat('dd/MM/yy, hh:mm a').format(order.date)}',
                  ),
                  if (order.address != null && order.address!.isNotEmpty)
                    Text('Dirección: ${order.address}'),
                  if (order.isPickup)
                    const Text('Tipo: Pickup'),
                  const Divider(),
                  ...order.items.map((item) {
                    return ListTile(
                      title: Text(item.product.name),
                      subtitle: item.product is CustomPizza ? Text((item.product as CustomPizza).description) : null,
                      trailing: Text('${item.quantity}'),
                    );
                  }).toList(),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Total: ${order.totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
