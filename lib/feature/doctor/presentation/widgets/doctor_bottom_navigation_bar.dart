import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class DoctorBottomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  const DoctorBottomNavigationBar({
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
            color: const Color(0xFF112028), // Clinical dark teal/slate matching mockup accents
            borderRadius: BorderRadius.circular(34),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF112028).withOpacity(0.25),
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
              color: const Color(0xFF2DD4BF).withOpacity(0.12),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavItem(0, 'Beranda', Icons.home_rounded),
              _buildNavItem(1, 'Pasien', Icons.people_rounded),
              _buildNavItem(2, 'Konsultasi', Icons.chat_bubble_rounded),
              _buildNavItem(3, 'Profil', Icons.person_rounded),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, String label, IconData icon) {
    final bool isSelected = selectedIndex == index;
    
    // Active clinical styling (Teal/Cyan accents)
    final Color activeBgColor = const Color(0xFF2DD4BF).withOpacity(0.12);
    final Color activeIconColor = const Color(0xFF2DD4BF);
    final Color activeTextColor = const Color(0xFF2DD4BF);
    
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
