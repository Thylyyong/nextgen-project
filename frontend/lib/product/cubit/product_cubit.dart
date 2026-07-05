import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nextgen/product/model/product_model.dart';
import 'package:nextgen/product/service/product_service.dart';

part 'product_state.dart';

/// ProductCubit manages the product listing state.
///
/// Responsibilities:
/// - Fetch products from [ProductService] on demand
/// - Track the currently selected category filter chip
/// - Emit loading/success/error states for the UI to react to
class ProductCubit extends Cubit<ProductState> {
  ProductCubit({required ProductService productService})
      : _service = productService,
        super(const ProductInitial());

  final ProductService _service;

  // The full list of supported filter-chip categories.
  // "All" is the default and maps to an unfiltered query.
  static const categories = ['All', 'Drinks', 'Clothing', 'Groceries'];

  // ── Load products ──────────────────────────────────────────────────────────

  /// Fetches products for the given [category].
  /// Emits [ProductLoading] → [ProductSuccess] or [ProductError].
  Future<void> loadProducts({String category = 'All'}) async {
    emit(const ProductLoading());
    try {
      final result = await _service.fetchProducts(category: category);
      emit(
        ProductSuccess(
          products: result.data,
          selectedCategory: category,
          total: result.total,
        ),
      );
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  // ── Select category chip ───────────────────────────────────────────────────

  /// Called when the user taps a [CustomFilterChip] in [CategoryFilterBar].
  ///
  /// If the same category is already selected, this is a no-op.
  /// Otherwise, re-fetches with the new filter — mirrors storex's
  /// `SelectCategoryEvent` pattern.
  Future<void> selectCategory(String category) async {
    final current = state;
    if (current is ProductSuccess && current.selectedCategory == category) {
      return; // Already selected — skip redundant fetch
    }
    await loadProducts(category: category);
  }

  // ── Refresh ────────────────────────────────────────────────────────────────

  /// Re-fetches with the currently selected category (e.g. on pull-to-refresh).
  Future<void> refresh() async {
    final current = state;
    final category =
        current is ProductSuccess ? current.selectedCategory : 'All';
    await loadProducts(category: category);
  }
}
