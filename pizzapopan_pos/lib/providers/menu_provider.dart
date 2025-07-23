import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pizzapopan_pos/models/ingredient.dart';
import 'package:pizzapopan_pos/models/product.dart';
import 'package:pizzapopan_pos/models/product_category.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MenuProvider with ChangeNotifier {
  static const double pizzaPrice = 110.00;
  static const double bonelessPrice = 110.00;

  List<Product> _menuItems = [];
  List<Ingredient> _pizzaIngredients = [];
  double _itemSize = 180.0;

  List<Product> get menuItems => _menuItems;
  List<Ingredient> get pizzaIngredients => _pizzaIngredients;
  double get itemSize => _itemSize;

  MenuProvider() {
    _loadItemSize();
  }

  Future<void> _loadItemSize() async {
    final prefs = await SharedPreferences.getInstance();
    _itemSize = prefs.getDouble('itemSize') ?? 180.0;
    notifyListeners();
  }

  Future<void> setItemSize(double size) async {
    final prefs = await SharedPreferences.getInstance();
    _itemSize = size;
    await prefs.setDouble('itemSize', size);
    notifyListeners();
  }

  Future<void> loadMenu() async {
    final String response = await rootBundle.loadString('assets/menu.json');
    final data = await json.decode(response);

    _menuItems = [];

    for (var itemData in data['pizzas']) {
      _menuItems.add(Product.fromJson(itemData, ProductCategory.pizzas, pizzaPrice));
    }

    for (var itemData in data['boneless']) {
      _menuItems.add(Product.fromJson(itemData, ProductCategory.boneless, bonelessPrice));
    }

    for (var itemData in data['bebidas']) {
      _menuItems.add(Product.fromJson(itemData, ProductCategory.bebidas));
    }

    for (var itemData in data['extras']) {
      _menuItems.add(Product.fromJson(itemData, ProductCategory.extras));
    }

    _pizzaIngredients = [];
    for (var ingredientData in data['ingredients']) {
      _pizzaIngredients.add(Ingredient.fromJson(ingredientData));
    }
    notifyListeners();
  }
}