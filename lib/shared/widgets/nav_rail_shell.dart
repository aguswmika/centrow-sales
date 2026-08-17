import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';

class NavRailShell extends StatelessWidget {
  final Widget child;
  final int selectedIndex;
  final ValueChanged<int>? onDestinationSelected;
  final String userInitials;

  const NavRailShell({
    super.key,
    required this.child,
    this.selectedIndex = 0,
    this.onDestinationSelected,
    this.userInitials = 'AG',
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTabletOrDesktop = constraints.maxWidth >= 720;

        if (isTabletOrDesktop) {
          return Scaffold(
            backgroundColor: AppColors.bg,
            body: Row(
              children: [
                _buildNavRail(context),
                const VerticalDivider(
                  width: 1.5,
                  thickness: 1.5,
                  color: AppColors.border,
                ),
                Expanded(child: child),
              ],
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.bg,
          body: child,
          bottomNavigationBar: _buildBottomNav(context),
        );
      },
    );
  }

  Widget _buildNavRail(BuildContext context) {
    return Container(
      width: 72.0,
      color: AppColors.surface,
      child: SafeArea(
        right: false,
        child: Column(
          children: [
            const SizedBox(height: 12.0),
            // Logo 'C' icon
            Container(
              width: 44.0,
              height: 44.0,
              decoration: const BoxDecoration(
                color: AppColors.brand,
                borderRadius: AppRadius.borderSm,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x331E40AF),
                    blurRadius: 8.0,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  'C',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20.0,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            _buildRailItem(
              index: 0,
              icon: Icons.home_outlined,
              selectedIcon: Icons.home_rounded,
              label: 'Beranda',
            ),
            _buildRailItem(
              index: 1,
              icon: Icons.people_outline_rounded,
              selectedIcon: Icons.people_rounded,
              label: 'Pelanggan',
            ),
            _buildRailItem(
              index: 2,
              icon: Icons.description_outlined,
              selectedIcon: Icons.description_rounded,
              label: 'Proposal',
            ),
            _buildRailItem(
              index: 3,
              icon: Icons.folder_outlined,
              selectedIcon: Icons.folder_rounded,
              label: 'Kontrak',
            ),
            _buildRailItem(
              index: 4,
              icon: Icons.calculate_outlined,
              selectedIcon: Icons.calculate_rounded,
              label: 'Harga',
            ),
            const Spacer(),
            // Avatar Button
            Container(
              width: 40.0,
              height: 40.0,
              decoration: BoxDecoration(
                color: AppColors.brand10,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.brand, width: 1.5),
              ),
              child: Center(
                child: Text(
                  userInitials,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.0,
                    fontWeight: FontWeight.w700,
                    color: AppColors.brand,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }

  Widget _buildRailItem({
    required int index,
    required IconData icon,
    required IconData selectedIcon,
    required String label,
  }) {
    final isSelected = selectedIndex == index;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: InkWell(
        onTap: () => onDestinationSelected?.call(index),
        borderRadius: AppRadius.borderSm,
        child: Container(
          width: 58.0,
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.brand10 : Colors.transparent,
            borderRadius: AppRadius.borderSm,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSelected ? selectedIcon : icon,
                size: 22.0,
                color: isSelected ? AppColors.brand : AppColors.muted,
              ),
              const SizedBox(height: 3.0),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 10.5,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? AppColors.brand : AppColors.muted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border, width: 1.5)),
      ),
      child: SafeArea(
        top: false,
        child: BottomNavigationBar(
          currentIndex: selectedIndex,
          onTap: onDestinationSelected,
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.brand,
          unselectedItemColor: AppColors.muted,
          elevation: 0,
          selectedLabelStyle: GoogleFonts.inter(
            fontSize: 11.0,
            fontWeight: FontWeight.w700,
          ),
          unselectedLabelStyle: GoogleFonts.inter(
            fontSize: 11.0,
            fontWeight: FontWeight.w500,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Beranda',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_outline_rounded),
              activeIcon: Icon(Icons.people_rounded),
              label: 'Pelanggan',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.description_outlined),
              activeIcon: Icon(Icons.description_rounded),
              label: 'Proposal',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.folder_outlined),
              activeIcon: Icon(Icons.folder_rounded),
              label: 'Kontrak',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calculate_outlined),
              activeIcon: Icon(Icons.calculate_rounded),
              label: 'Harga',
            ),
          ],
        ),
      ),
    );
  }
}
