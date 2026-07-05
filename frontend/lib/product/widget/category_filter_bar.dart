import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:nextgen/product/cubit/product_cubit.dart';
import 'package:nextgen/product/widget/custom_filter_chip.dart';

/// CategoryFilterBar — adapted from storex_customer's `ProductCategories`.
///
/// Renders a horizontal scrollable row of [CustomFilterChip] widgets.
/// Tapping a chip calls [ProductCubit.selectCategory] which re-fetches
/// the product list filtered by that category.
///
/// The chip list is driven by [ProductCubit.categories] so adding a new
/// category to the cubit constant automatically appears here.
///
/// Category → Icon mapping for a polished look:
/// ```
/// All        → Icons.grid_view_rounded
/// Drinks     → Icons.local_drink_outlined
/// Clothing   → Icons.checkroom_outlined
/// Groceries  → Icons.shopping_basket_outlined
/// ```
class CategoryFilterBar extends StatelessWidget {
  const CategoryFilterBar({super.key});

  static const _categoryIcons = <String, IconData>{
    'All': Icons.grid_view_rounded,
    'Drinks': Icons.local_drink_outlined,
    'Clothing': Icons.checkroom_outlined,
    'Groceries': Icons.shopping_basket_outlined,
  };

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductCubit, ProductState>(
      // Only rebuild when the selected category changes — not on every state
      buildWhen: (previous, current) {
        if (previous is ProductSuccess && current is ProductSuccess) {
          return previous.selectedCategory != current.selectedCategory;
        }
        return previous.runtimeType != current.runtimeType;
      },
      builder: (context, state) {
        final selectedCategory =
            state is ProductSuccess ? state.selectedCategory : 'All';

        return SizedBox(
          height: 48,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            itemCount: ProductCubit.categories.length,
            separatorBuilder: (_, __) => const Gap(8),
            itemBuilder: (context, index) {
              final category = ProductCubit.categories[index];
              final icon = _categoryIcons[category];
              final isSelected = selectedCategory == category;

              return CustomFilterChip(
                label: category,
                icon: icon,
                isSelected: isSelected,
                onTap: () {
                  // No-op if already selected — cubit handles this guard too
                  if (!isSelected) {
                    context.read<ProductCubit>().selectCategory(category);
                  }
                },
              );
            },
          ),
        );
      },
    );
  }
}
