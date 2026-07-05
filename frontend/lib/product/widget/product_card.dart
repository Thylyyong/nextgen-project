import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:nextgen/app/theme/theme.dart';
import 'package:nextgen/product/model/product_model.dart';
import 'package:nextgen/product/widget/discount_badge.dart';

/// ProductCard — adapted from storex_customer's `RetailCard`.
///
/// Displays a product with:
/// - Square product image (1:1 aspect ratio) with rounded top corners
/// - Discount badge overlaid on the image bottom-right when a discount exists
/// - Price row with optional strikethrough cost price
/// - Star rating placeholder + units sold
/// - Category badge chip
/// - Product name (2-line clamp)
///
/// Uses [CachedNetworkImage] for memory-efficient image loading.
class ProductCard extends StatelessWidget {
  const ProductCard({
    required this.product,
    super.key,
    this.onTap,
  });

  final Product product;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Product Image ────────────────────────────────────────────
              Stack(
                clipBehavior: Clip.none,
                children: [
                  AspectRatio(
                    aspectRatio: 1,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                      ),
                      child: product.imageUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: product.imageUrl,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: ColorTheme.neutral100,
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 1.5,
                                    color: ColorTheme.neutral300,
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) =>
                                  _buildImageFallback(context),
                            )
                          : _buildImageFallback(context),
                    ),
                  ),
                  // ── Discount badge ─────────────────────────────────────
                  if (product.hasDiscount)
                    Positioned(
                      bottom: -14,
                      right: 8,
                      child: DiscountBadge(product: product),
                    ),
                ],
              ),

              // ── Card body ────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 20, 8, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Price row ──────────────────────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '\$${product.basePrice.toStringAsFixed(2)}',
                            style: context.subtitleMedium.copyWith(
                              fontWeight: FontWeight.w700,
                              color: ColorTheme.neutral800,
                              height: 1,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (product.hasDiscount) ...[
                          const Gap(4),
                          Text(
                            '\$${product.costPrice.toStringAsFixed(2)}',
                            style: context.subtitleSmall.copyWith(
                              color: ColorTheme.neutral400,
                              decoration: TextDecoration.lineThrough,
                              height: 1,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const Gap(4),

                    // ── Stock status / rating ──────────────────────────────
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: ColorTheme.semanticYellow,
                          size: 14,
                        ),
                        const Gap(2),
                        Expanded(
                          child: Text(
                            product.isOutOfStock
                                ? 'Out of stock'
                                : '${product.stockQuantity} in stock',
                            style: context.subtitleSoSmall.copyWith(
                              color: product.isOutOfStock
                                  ? ColorTheme.semanticRed
                                  : ColorTheme.neutral600,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                    const Gap(6),

                    // ── Category badge ─────────────────────────────────────
                    _CategoryBadge(label: product.category),
                    const Gap(6),

                    // ── Product name ───────────────────────────────────────
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.subtitleSmall.copyWith(
                        color: ColorTheme.neutral600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageFallback(BuildContext context) {
    return Container(
      color: ColorTheme.neutral100,
      child: Center(
        child: Icon(
          Icons.shopping_bag_outlined,
          size: 40,
          color: ColorTheme.neutral300,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Internal category badge
// ─────────────────────────────────────────────
class _CategoryBadge extends StatelessWidget {
  const _CategoryBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF2D3243),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: context.subtitleSoSmall.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
      ),
    );
  }
}
