import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/app_assets.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';

class NavRailShell extends StatelessWidget {
  final Widget child;
  final int selectedIndex;
  final ValueChanged<int>? onDestinationSelected;
  final String userInitials;
  final StatefulNavigationShell? navigationShell;

  const NavRailShell({
    super.key,
    required this.child,
    this.selectedIndex = 0,
    this.onDestinationSelected,
    this.userInitials = 'AG',
    this.navigationShell,
  });

  void _handleNavigation(BuildContext context, int index) {
    if (navigationShell != null) {
      navigationShell!.goBranch(
        index,
        initialLocation: index == navigationShell!.currentIndex,
      );
      return;
    }
    if (onDestinationSelected != null) {
      onDestinationSelected!(index);
      return;
    }
    if (index == selectedIndex) return;

    switch (index) {
      case 0:
        context.go('/dashboard');
        break;
      case 1:
        context.go('/pelanggan');
        break;
      case 2:
        context.go('/proposal');
        break;
      case 3:
        context.go('/kontrak');
        break;
      case 4:
        context.go('/harga');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.sizeOf(context).width >= 720;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: isTablet
          ? Row(
              children: [
                _buildNavRail(context),
                const VerticalDivider(
                  width: 1.5,
                  thickness: 1.5,
                  color: AppColors.border,
                ),
                Expanded(child: child),
              ],
            )
          : child,
      bottomNavigationBar: isTablet ? null : _buildBottomNav(context),
    );
  }

  Widget _buildNavRail(BuildContext context) {
    return NavigationRail(
      selectedIndex: navigationShell?.currentIndex ?? selectedIndex,
      onDestinationSelected: (idx) => _handleNavigation(context, idx),
      backgroundColor: AppColors.surface,
      minWidth: 72.0,
      labelType: NavigationRailLabelType.all,
      selectedLabelTextStyle: GoogleFonts.inter(
        fontSize: 10.5,
        fontWeight: FontWeight.w700,
        color: AppColors.brand,
      ),
      unselectedLabelTextStyle: GoogleFonts.inter(
        fontSize: 10.5,
        fontWeight: FontWeight.w500,
        color: AppColors.muted,
      ),
      selectedIconTheme: const IconThemeData(
        color: AppColors.brand,
        size: 22.0,
      ),
      unselectedIconTheme: const IconThemeData(
        color: AppColors.muted,
        size: 22.0,
      ),
      useIndicator: true,
      indicatorColor: AppColors.brand10,
      leading: Padding(
        padding: const EdgeInsets.only(bottom: 12.0, top: 8.0),
        child: SizedBox(
          width: 44.0,
          height: 44.0,
          child: ClipRRect(
            borderRadius: AppRadius.borderSm,
            child: SvgPicture.asset(
              AppAssets.logoFilled,
              width: 44.0,
              height: 44.0,
            ),
          ),
        ),
      ),
      trailing: Padding(
        padding: const EdgeInsets.only(top: 24.0, bottom: 16.0),
        child: Container(
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
      ),
      destinations: const [
        NavigationRailDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home_rounded),
          label: Text('Beranda'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.people_outline_rounded),
          selectedIcon: Icon(Icons.people_rounded),
          label: Text('Pelanggan'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.description_outlined),
          selectedIcon: Icon(Icons.description_rounded),
          label: Text('Proposal'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.folder_outlined),
          selectedIcon: Icon(Icons.folder_rounded),
          label: Text('Kontrak'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.calculate_outlined),
          selectedIcon: Icon(Icons.calculate_rounded),
          label: Text('Harga'),
        ),
      ],
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
          currentIndex: navigationShell?.currentIndex ?? selectedIndex,
          onTap: (idx) => _handleNavigation(context, idx),
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
