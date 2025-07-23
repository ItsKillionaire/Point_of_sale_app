
import 'package:pizzapopan_pos/models/ingredient.dart';
import 'package:pizzapopan_pos/models/product.dart';
import 'package:pizzapopan_pos/models/product_category.dart';

class CustomPizza extends Product {
  final List<Ingredient> ingredients;

  CustomPizza({
    required String name,
    required String description,
    required double price,
    required String image,
    required ProductCategory category,
    required this.ingredients,
  }) : super(
          name: name,
          description: description,
          price: price,
          image: image,
          category: category,
        );
}
