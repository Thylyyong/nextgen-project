import 'package:nextgen/core/network/api_client.dart';
import 'package:nextgen/product/model/product_model.dart';

/// ProductService fetches products from the backend REST API.
///
/// The [category] parameter maps directly to the filter-chip selection:
/// - Empty string / "All" → returns all products
/// - "Drinks" / "Clothing" / "Groceries" → filtered by category
class ProductService {
  const ProductService({required ApiClient apiClient}) : _api = apiClient;

  final ApiClient _api;

  /// Fetches a page of products.
  ///
  /// [category] : filter value (empty = all)
  /// [page]     : 1-indexed page number
  /// [limit]    : items per page (max 100)
  Future<ProductListResponse> fetchProducts({
    String category = '',
    int page = 1,
    int limit = 20,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
      if (category.isNotEmpty && category != 'All') 'category': category,
    };

    final response = await _api.get<Map<String, dynamic>>(
      '/products',
      queryParameters: queryParams,
    );

    return ProductListResponse.fromJson(response.data!);
  }

  /// Fetches a single product by ID (requires auth token).
  Future<Product> fetchProductById(int id) async {
    final response = await _api.get<Map<String, dynamic>>('/products/$id');
    return Product.fromJson(response.data!);
  }
}
