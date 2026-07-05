import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:nextgen/app/theme/theme.dart';

/// CustomFilterChip — adapted from storex_customer's `custom_filter_chip.dart`.
///
/// Renders a pill-shaped selection chip with:
/// - Double-border ring on selected state (outer border + dark fill)
/// - Optional leading or trailing [IconData]
/// - Smooth implicit color transitions via [AnimatedContainer]
///
/// Usage:
/// ```dart
/// CustomFilterChip(
///   label: 'Drinks',
///   isSelected: true,
///   onTap: () => cubit.selectCategory('Drinks'),
///   icon: Icons.local_drink,
/// )
/// ```
class CustomFilterChip extends StatelessWidget {
  const CustomFilterChip({
    required this.label,
    required this.onTap,
    super.key,
    this.icon,
    this.isSelected = false,
    this.isTrailingIcon = false,
  });

  final String label;
  final IconData? icon;
  final bool isSelected;

  /// When true, the icon appears after the label; when false, it appears before.
  final bool isTrailingIcon;
  final VoidCallback onTap;

  // Brand dark navy — matches storex's `darkNavy` constant
  static const _darkNavy = Color(0xFF2D3243);
  static const _borderGrey = ColorTheme.neutral200;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeInOut,
        // ── Outer ring (selection indicator) ─────────────────────────
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: isSelected ? _darkNavy : Colors.transparent,
          ),
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeInOut,
          // ── Inner pill (fill) ─────────────────────────────────────
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: isSelected ? _darkNavy : Colors.white,
            borderRadius: BorderRadius.circular(100),
            border: isSelected ? null : Border.all(color: _borderGrey),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: _darkNavy.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Leading icon ─────────────────────────────────────
              if (!isTrailingIcon && icon != null) ...[
                Icon(icon, size: 14, color: isSelected ? Colors.white : _darkNavy),
                const Gap(6),
              ],
              // ── Label ────────────────────────────────────────────
              Text(
                label,
                style: context.subtitleSmall.copyWith(
                  color: isSelected ? Colors.white : _darkNavy,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
              // ── Trailing icon ─────────────────────────────────────
              if (isTrailingIcon && icon != null) ...[
                const Gap(6),
                Icon(icon, size: 14, color: isSelected ? Colors.white : _darkNavy),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
