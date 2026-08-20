import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/di.dart';
import '../../modules/core/repositories/auth_repository.dart';
import '../config/app_assets.dart';
import '../network/auth_token_holder.dart';
import '../result/result.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';

class NavRailShell extends StatefulWidget {
  final Widget child;
  final int selectedIndex;
  final ValueChanged<int>? onDestinationSelected;
  final String? userInitials;
  final StatefulNavigationShell? navigationShell;

  const NavRailShell({
    super.key,
    required this.child,
    this.selectedIndex = 0,
    this.onDestinationSelected,
    this.userInitials,
    this.navigationShell,
  });

  @override
  State<NavRailShell> createState() => _NavRailShellState();
}

class _NavRailShellState extends State<NavRailShell> {
  @override
  void initState() {
    super.initState();
    _fetchMeIfNeeded();
  }

  Future<void> _fetchMeIfNeeded() async {
    if (AuthTokenHolder.instance.hasToken && AuthTokenHolder.instance.currentUser == null) {
      if (getIt.isRegistered<AuthRepository>()) {
        final result = await getIt<AuthRepository>().getMe();
        if (result is Ok && mounted) {
          await AuthTokenHolder.instance.saveUser(result.valueOrNull!);
          setState(() {});
        }
      }
    }
  }

  void _handleNavigation(BuildContext context, int index) {
    if (widget.navigationShell != null) {
      widget.navigationShell!.goBranch(
        index,
        initialLocation: index == widget.navigationShell!.currentIndex,
      );
      return;
    }
    if (widget.onDestinationSelected != null) {
      widget.onDestinationSelected!(index);
      return;
    }
    if (index == widget.selectedIndex) return;

    switch (index) {
      case 0:
        context.go('/customers');
        break;
      case 1:
        context.go('/proposals');
        break;
      case 2:
        context.go('/contracts');
        break;
      case 3:
        context.go('/pricings');
        break;
    }
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderLg),
        backgroundColor: AppColors.surface,
        title: Row(
          children: [
            const Icon(Icons.logout_rounded, color: AppColors.err, size: 22.0),
            const SizedBox(width: 10.0),
            Text(
              'Konfirmasi Keluar',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16.0,
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              ),
            ),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin keluar dari akun ini?',
          style: GoogleFonts.inter(fontSize: 14.0, color: AppColors.sec),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(
              'Batal',
              style: GoogleFonts.inter(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: AppColors.muted,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.err,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: const RoundedRectangleBorder(
                borderRadius: AppRadius.borderMd,
              ),
            ),
            onPressed: () async {
              Navigator.of(dialogContext).pop(true);
              await AuthTokenHolder.instance.clear();
              if (context.mounted) {
                context.go('/login');
              }
            },
            child: Text(
              'Ya, Keluar',
              style: GoogleFonts.inter(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
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
                Expanded(child: widget.child),
              ],
            )
          : widget.child,
      bottomNavigationBar: isTablet ? null : _buildBottomNav(context),
    );
  }

  Widget _buildNavRail(BuildContext context) {
    return NavigationRail(
      selectedIndex: widget.navigationShell?.currentIndex ?? widget.selectedIndex,
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
        child: Theme(
          data: Theme.of(context).copyWith(
            hoverColor: Colors.transparent,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: PopupMenuButton<String>(
            tooltip: 'Profil Pengguna',
            offset: const Offset(48.0, 0.0),
            shape: const RoundedRectangleBorder(
              borderRadius: AppRadius.borderMd,
              side: BorderSide(color: AppColors.border, width: 1.5),
            ),
            elevation: 4.0,
            color: AppColors.surface,
            onSelected: (value) {
              if (value == 'logout') {
                _showLogoutConfirmation(context);
              }
            },
            itemBuilder: (context) {
              final user = AuthTokenHolder.instance.currentUser;
              final name = (user?.name.isNotEmpty == true)
                  ? user!.name
                  : (user?.email.isNotEmpty == true ? user!.email.split('@').first : 'Pengguna');
              final email = (user?.email.isNotEmpty == true) ? user!.email : '-';
              final role = (user?.role.isNotEmpty == true)
                  ? user!.role
                  : (user?.roles.isNotEmpty == true ? user!.roles.first : 'Sales');

              return [
                PopupMenuItem<String>(
                  enabled: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(height: 2.0),
                      Text(
                        email,
                        style: GoogleFonts.inter(
                          fontSize: 11.5,
                          color: AppColors.muted,
                        ),
                      ),
                      const SizedBox(height: 6.0),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6.0,
                          vertical: 2.0,
                        ),
                        decoration: const BoxDecoration(
                          color: AppColors.brand10,
                          borderRadius: AppRadius.borderSm,
                        ),
                        child: Text(
                          role.toUpperCase(),
                          style: GoogleFonts.inter(
                            fontSize: 10.0,
                            fontWeight: FontWeight.w700,
                            color: AppColors.brand,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                PopupMenuItem<String>(
                  value: 'logout',
                  child: Row(
                    children: [
                      const Icon(
                        Icons.logout_rounded,
                        size: 18.0,
                        color: AppColors.err,
                      ),
                      const SizedBox(width: 10.0),
                      Text(
                        'Keluar',
                        style: GoogleFonts.inter(
                          fontSize: 13.0,
                          fontWeight: FontWeight.w600,
                          color: AppColors.err,
                        ),
                      ),
                    ],
                  ),
                ),
              ];
            },
            child: Container(
              width: 40.0,
              height: 40.0,
              decoration: BoxDecoration(
                color: AppColors.brand10,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.brand, width: 1.5),
              ),
              child: Center(
                child: (widget.userInitials ?? AuthTokenHolder.instance.userInitials).isNotEmpty
                    ? Text(
                        widget.userInitials ?? AuthTokenHolder.instance.userInitials,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13.0,
                          fontWeight: FontWeight.w700,
                          color: AppColors.brand,
                        ),
                      )
                    : const Icon(
                        Icons.person_rounded,
                        size: 20.0,
                        color: AppColors.brand,
                      ),
              ),
            ),
          ),
        ),
      ),
      destinations: const [
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
          currentIndex: widget.navigationShell?.currentIndex ?? widget.selectedIndex,
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
