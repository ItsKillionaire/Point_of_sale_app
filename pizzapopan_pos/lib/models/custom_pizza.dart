
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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CustomPizza &&
        other.name == name &&
        _listEquals(other.ingredients, ingredients);
  }

  @override
  int get hashCode => name.hashCode ^ _listHashCode(ingredients);

  bool _listEquals(List<Ingredient> list1, List<Ingredient> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i].name != list2[i].name) return false;
    }
    return true;
  }

  int _listHashCode(List<Ingredient> list) {
    int hashCode = 0;
    for (var item in list) {
      hashCode ^= item.name.hashCode;
    }
    return hashCode;
  }
}
