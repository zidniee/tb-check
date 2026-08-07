import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// Animated search bar with debounced input for education content search.
///
/// Calls [onSearch] after a 500ms debounce to avoid excessive API calls.
class EducationSearchBar extends StatefulWidget {
  final ValueChanged<String> onSearch;
  final String? initialValue;

  const EducationSearchBar({
    super.key,
    required this.onSearch,
    this.initialValue,
  });

  @override
  State<EducationSearchBar> createState() => _EducationSearchBarState();
}

class _EducationSearchBarState extends State<EducationSearchBar> {
  late final TextEditingController _controller;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      widget.onSearch(value.trim());
    });
    setState(() {}); // Refresh clear button visibility
  }

  void _onClear() {
    _controller.clear();
    _debounceTimer?.cancel();
    widget.onSearch('');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _controller,
        onChanged: _onChanged,
        style: AppTextStyles.bodyMedium.copyWith(
          fontSize: 14,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: 'Cari tanaman, senyawa, atau topik...',
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.textSecondary,
            size: 20,
          ),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded, size: 18),
                  color: AppColors.textSecondary,
                  onPressed: _onClear,
                )
              : null,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}
