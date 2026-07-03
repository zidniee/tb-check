import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class PatientBottomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  const PatientBottomNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent, // Allows underlying page content to scroll behind
      padding: const EdgeInsets.only(
        left: 20.0,
        right: 20.0,
        bottom: 20.0,
        top: 8.0,
      ),
      child: SafeArea(
        top: false,
        child: Container(
          height: 68,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          decoration: BoxDecoration(
            color: const Color(0xFF1E2D3D), // Modern slate dark blue matching premium dashboard accent
            borderRadius: BorderRadius.circular(34),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1E2D3D).withOpacity(0.22),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: Colors.white.withOpacity(0.08),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavItem(0, 'Beranda', Icons.home_rounded),
              _buildNavItem(1, 'Skrining', Icons.medical_services_rounded),
              _buildNavItem(2, 'Edukasi', Icons.school_rounded),
              _buildNavItem(3, 'Profil', Icons.person_rounded),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, String label, IconData icon) {
    final bool isSelected = selectedIndex == index;
    
    // Active styling
    final Color activeBgColor = Colors.white.withOpacity(0.12);
    final Color activeIconColor = Colors.white;
    final Color activeTextColor = Colors.white;
    
    // Inactive styling
    final Color inactiveIconColor = Colors.white.withOpacity(0.4);

    return GestureDetector(
      onTap: () => onTabSelected(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: isSelected ? activeBgColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? activeIconColor : inactiveIconColor,
              size: 22,
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOutCubic,
              child: isSelected
                  ? Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        label,
                        style: AppTextStyles.labelMedium.copyWith(
                          color: activeTextColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        softWrap: false,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
