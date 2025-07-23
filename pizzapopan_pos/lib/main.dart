
import 'package:flutter/material.dart';
import 'package:pizzapopan_pos/providers/bill_provider.dart';
import 'package:pizzapopan_pos/providers/menu_provider.dart';
import 'package:pizzapopan_pos/providers/order_history_provider.dart';
import 'package:pizzapopan_pos/screens/home_screen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => BillProvider()),
        ChangeNotifierProvider(create: (context) => OrderHistoryProvider()),
        ChangeNotifierProvider(create: (context) => MenuProvider()),
      ],
      child: MaterialApp(
        title: 'Pizzapopan POS',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
