import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:gap/gap.dart';
import 'package:shimmer/shimmer.dart';

/// ProductLoadingSkeleton — adapted from storex_customer's `ProductLoadingSkeleton`.
///
/// Displayed while the API request is in-flight.
/// Shows:
/// - A row of shimmer filter chip skeletons
/// - A 2-column MasonryGridView of shimmer product card skeletons
///
/// The shimmer animates from grey.shade400 → grey.shade200,
/// matching storex's exact shimmer colors.
class ProductLoadingSkeleton extends StatelessWidget {
  const ProductLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade400,
      highlightColor: Colors.grey.shade200,
      child: Column(
        children: <Widget>[
          const Gap(12),
          // ── Filter chip skeleton row ───────────────────────────────────
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: List.generate(
                5,
                (index) => Container(
                  width: 88,
                  height: 36,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
            ),
          ),
          const Gap(12),
          // ── Product card skeleton grid ─────────────────────────────────
          Expanded(
            child: MasonryGridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              padding: const EdgeInsets.symmetric(horizontal: 12)
                  .copyWith(bottom: 12),
              itemCount: 10,
              itemBuilder: (context, index) => _SkeletonCard(index: index),
            ),
          ),
        ],
      ),
    );
  }
}

/// A single skeleton card — alternates heights to simulate MasonryGrid layout.
class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    // Alternate image heights for a realistic masonry feel
    final imageHeight = index.isEven ? 190.0 : 160.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image placeholder
        Container(
          height: imageHeight,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        // Price placeholder
        Container(
          height: 14,
          margin: const EdgeInsets.only(top: 8),
          width: 80,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        // Rating placeholder
        Container(
          height: 10,
          margin: const EdgeInsets.only(top: 6),
          width: 110,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        // Badge placeholder
        Container(
          height: 20,
          width: 60,
          margin: const EdgeInsets.only(top: 6),
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        // Name placeholder (2 lines)
        Container(
          height: 12,
          margin: const EdgeInsets.only(top: 6),
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        Container(
          height: 12,
          margin: const EdgeInsets.only(top: 4),
          width: 90,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ],
    );
  }
}
