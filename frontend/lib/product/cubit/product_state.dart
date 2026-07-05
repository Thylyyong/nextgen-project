part of 'product_cubit.dart';

/// Sealed base class for all product states.
/// Mirrors the State pattern used across storex_customer blocs.
abstract class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object?> get props => [];
}

/// Initial state — no data, no request made yet.
class ProductInitial extends ProductState {
  const ProductInitial();
}

/// Loading state — shown while fetching from the API.
class ProductLoading extends ProductState {
  const ProductLoading();
}

/// Success state — holds the fetched product list and selected category.
class ProductSuccess extends ProductState {
  const ProductSuccess({
    required this.products,
    required this.selectedCategory,
    required this.total,
  });

  final List<Product> products;
  final String selectedCategory;
  final int total;

  /// Creates a copy with selective overrides — useful for in-place updates.
  ProductSuccess copyWith({
    List<Product>? products,
    String? selectedCategory,
    int? total,
  }) {
    return ProductSuccess(
      products: products ?? this.products,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      total: total ?? this.total,
    );
  }

  @override
  List<Object?> get props => [products, selectedCategory, total];
}

/// Error state — shown when the API call fails.
class ProductError extends ProductState {
  const ProductError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
