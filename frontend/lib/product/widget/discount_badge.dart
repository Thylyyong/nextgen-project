import 'package:flutter/material.dart';
import 'package:nextgen/product/model/product_model.dart';

/// DiscountBadge — adapted from storex_customer's `discount_badge.dart`.
///
/// Renders a circular red badge displaying the discount percentage.
/// Only call this widget when [product.hasDiscount] is true.
class DiscountBadge extends StatelessWidget {
  const DiscountBadge({required this.product, super.key});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final discount = product.discountPercent ?? 0;

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: const Color(0xFFE53935), // Vibrant red — matches storex
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          '-$discount%',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 9,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
      ),
    );
  }
}
