import 'package:equatable/equatable.dart';

/// Product data model — plain Dart class (no protobuf/gRPC).
/// Parsed from the backend's JSON response.
class Product extends Equatable {
  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.basePrice,
    required this.costPrice,
    required this.stockQuantity,
    required this.imageUrl,
    required this.createdAt,
  });

  final int id;
  final String name;
  final String category;
  final double basePrice;
  final double costPrice;
  final int stockQuantity;
  final String imageUrl;
  final DateTime createdAt;

  /// Calculates discount percentage relative to cost price.
  /// Returns null if there is no meaningful discount.
  int? get discountPercent {
    if (costPrice > 0 && basePrice < costPrice) {
      return ((costPrice - basePrice) / costPrice * 100).round();
    }
    return null;
  }

  /// True when the product has a discount worth showing.
  bool get hasDiscount => discountPercent != null && discountPercent! > 0;

  /// True when stock is exhausted.
  bool get isOutOfStock => stockQuantity <= 0;

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'] as int,
        name: json['name'] as String,
        category: json['category'] as String,
        basePrice: (json['base_price'] as num).toDouble(),
        costPrice: (json['cost_price'] as num).toDouble(),
        stockQuantity: json['stock_quantity'] as int,
        imageUrl: json['image_url'] as String? ?? '',
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'base_price': basePrice,
        'cost_price': costPrice,
        'stock_quantity': stockQuantity,
        'image_url': imageUrl,
        'created_at': createdAt.toIso8601String(),
      };

  @override
  List<Object?> get props =>
      [id, name, category, basePrice, costPrice, stockQuantity, imageUrl];
}

/// Paginated response envelope from GET /api/products.
class ProductListResponse {
  const ProductListResponse({required this.data, required this.total});

  final List<Product> data;
  final int total;

  factory ProductListResponse.fromJson(Map<String, dynamic> json) =>
      ProductListResponse(
        data: (json['data'] as List<dynamic>)
            .map((e) => Product.fromJson(e as Map<String, dynamic>))
            .toList(),
        total: json['total'] as int,
      );
}
