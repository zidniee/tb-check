import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// Segmented filter tabs for content type selection.
///
/// Shows three options: "Semua", "Artikel", "Video".
/// Active tab is highlighted with the primary color.
class ContentTypeFilter extends StatelessWidget {
  final String? activeFilter; // null = all
  final ValueChanged<String?> onFilterChanged;

  const ContentTypeFilter({
    super.key,
    required this.activeFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildTab(
          label: 'Semua',
          icon: Icons.grid_view_rounded,
          isActive: activeFilter == null,
          onTap: () => onFilterChanged(null),
        ),
        const SizedBox(width: 8),
        _buildTab(
          label: 'Artikel',
          icon: Icons.article_rounded,
          isActive: activeFilter == 'article',
          onTap: () => onFilterChanged('article'),
        ),
        const SizedBox(width: 8),
        _buildTab(
          label: 'Video',
          icon: Icons.play_circle_outline_rounded,
          isActive: activeFilter == 'video',
          onTap: () => onFilterChanged('video'),
        ),
      ],
    );
  }

  Widget _buildTab({
    required String label,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: isActive ? AppColors.primary : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isActive ? AppColors.primary : AppColors.border,
              ),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: isActive ? Colors.white : AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: AppTextStyles.labelMedium.copyWith(
                    fontSize: 12,
                    color: isActive ? Colors.white : AppColors.textSecondary,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
