import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:gap/gap.dart';
import 'package:get_it/get_it.dart';
import 'package:nextgen/app/theme/theme.dart';
import 'package:nextgen/product/cubit/product_cubit.dart';
import 'package:nextgen/product/service/product_service.dart';
import 'package:nextgen/product/widget/category_filter_bar.dart';
import 'package:nextgen/product/widget/product_card.dart';
import 'package:nextgen/product/widget/product_shimmer.dart';

/// ProductPage is the main product listing screen.
///
/// Structure:
/// - Provides [ProductCubit] via [BlocProvider]
/// - Shows [ProductLoadingSkeleton] while fetching
/// - Shows [CategoryFilterBar] + [MasonryGridView] of [ProductCard] on success
/// - Shows error state with retry button on failure
///
/// Initial load fires immediately via [initState] in the inner stateful widget.
class ProductPage extends StatelessWidget {
  const ProductPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProductCubit(
        productService: GetIt.I<ProductService>(),
      )..loadProducts(), // Trigger initial fetch on creation
      child: const _ProductView(),
    );
  }
}

class _ProductView extends StatelessWidget {
  const _ProductView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorTheme.screenBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: 'Next',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF2D3243),
                ),
              ),
              TextSpan(
                text: 'Gen',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF9811E7),
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded,
                color: ColorTheme.neutral800),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined,
                color: ColorTheme.neutral800),
            onPressed: () {},
          ),
          const Gap(8),
        ],
      ),
      body: BlocBuilder<ProductCubit, ProductState>(
        builder: (context, state) {
          // ── Loading ────────────────────────────────────────────────────
          if (state is ProductLoading || state is ProductInitial) {
            return const ProductLoadingSkeleton();
          }

          // ── Error ──────────────────────────────────────────────────────
          if (state is ProductError) {
            return _ErrorView(
              message: state.message,
              onRetry: () => context.read<ProductCubit>().refresh(),
            );
          }

          // ── Success ────────────────────────────────────────────────────
          if (state is ProductSuccess) {
            return RefreshIndicator(
              color: ColorTheme.primary400,
              onRefresh: () => context.read<ProductCubit>().refresh(),
              child: CustomScrollView(
                slivers: [
                  // ── Category filter bar ────────────────────────────────
                  const SliverToBoxAdapter(
                    child: CategoryFilterBar(),
                  ),

                  // ── Results count ──────────────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                      child: Text(
                        '${state.total} product${state.total == 1 ? '' : 's'} found',
                        style: context.subtitleSmall.copyWith(
                          color: ColorTheme.neutral500,
                        ),
                      ),
                    ),
                  ),

                  // ── Empty state ────────────────────────────────────────
                  if (state.products.isEmpty)
                    SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.inventory_2_outlined,
                                size: 64, color: ColorTheme.neutral300),
                            const Gap(16),
                            Text(
                              'No products in this category',
                              style: context.subtitleMedium.copyWith(
                                color: ColorTheme.neutral500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    // ── Product grid (MasonryGridView) ─────────────────
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 12)
                          .copyWith(bottom: 24),
                      sliver: SliverMasonryGrid.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childCount: state.products.length,
                        itemBuilder: (context, index) {
                          final product = state.products[index];
                          return ProductCard(
                            product: product,
                            onTap: () {
                              // TODO: Navigate to product detail page
                            },
                          );
                        },
                      ),
                    ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Error view
// ─────────────────────────────────────────────
class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded, size: 64, color: ColorTheme.neutral300),
            const Gap(16),
            Text(
              'Something went wrong',
              style: context.titleSmall.copyWith(fontSize: 18),
            ),
            const Gap(8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: context.subtitleSmall
                  .copyWith(color: ColorTheme.neutral500),
            ),
            const Gap(24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorTheme.buttonPrimary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
