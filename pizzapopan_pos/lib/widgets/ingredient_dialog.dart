
import 'package:flutter/material.dart';
import 'package:pizzapopan_pos/models/ingredient.dart';
import 'package:pizzapopan_pos/providers/menu_provider.dart';
import 'package:provider/provider.dart';

class IngredientDialog extends StatefulWidget {
  const IngredientDialog({super.key});

  @override
  State<IngredientDialog> createState() => _IngredientDialogState();
}

class _IngredientDialogState extends State<IngredientDialog> {
  late List<Ingredient> _ingredients;
  final List<Ingredient> _selectedIngredients = [];

  @override
  void initState() {
    super.initState();
    _ingredients = Provider.of<MenuProvider>(context, listen: false).pizzaIngredients;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Selecciona tus ingredientes'),
      content: Wrap(
        spacing: 8.0,
        runSpacing: 4.0,
        children: _ingredients.map((ingredient) {
          final isSelected = _selectedIngredients.contains(ingredient);
          return FilterChip(
            label: Text(ingredient.name),
            selected: isSelected,
            onSelected: (selected) {
              setState(() {
                if (selected) {
                  _selectedIngredients.add(ingredient);
                } else {
                  _selectedIngredients.remove(ingredient);
                }
              });
            },
          );
        }).toList(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, _selectedIngredients);
          },
          child: const Text('Agregar'),
        ),
      ],
    );
  }
}
