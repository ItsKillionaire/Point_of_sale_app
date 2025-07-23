
import 'package:pizzapopan_pos/models/product_category.dart';

class Product {
  final String name;
  final String description;
  final double price;
  final String image;
  final ProductCategory category;

  Product({
    required this.name,
    required this.description,
    required this.price,
    required this.image,
    required this.category,
  });

  factory Product.fromJson(Map<String, dynamic> json, ProductCategory category, [double? price]) {
    return Product(
      name: json['name'],
      description: json['description'],
      price: price ?? json['price'],
      image: json['image'],
      category: category,
    );
  }
}

