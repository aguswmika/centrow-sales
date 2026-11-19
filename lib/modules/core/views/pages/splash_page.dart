import 'package:material_ui/material_ui.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:signals/signals_flutter.dart';
import 'package:centrow_sales/app/di.dart';
import 'package:centrow_sales/modules/core/controllers/splash_controller.dart';
import 'package:centrow_sales/shared/theme/app_colors.dart';

class SplashPage extends StatefulWidget {
  final SplashController? controller;

  const SplashPage({super.key, this.controller});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  late final SplashController _controller;
  late final EffectCleanup _cleanupEffect;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? getIt<SplashController>();
    _controller.checkSession();

    _cleanupEffect = effect(() {
      final target = _controller.targetRoute.value;
      if (target != null && mounted) {
        context.go(target);
      }
    });
  }

  @override
  void dispose() {
    _cleanupEffect();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              'assets/img/logo_filled.svg',
              width: 72.0,
              height: 72.0,
            ),
            const SizedBox(height: 12.0),
            Text(
              'Centrow Sales',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 24.0,
                fontWeight: FontWeight.w800,
                color: AppColors.text,
                letterSpacing: -0.72,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 4.0),
            Text(
              'ERP',
              style: GoogleFonts.inter(
                fontSize: 12.0,
                fontWeight: FontWeight.w500,
                color: AppColors.textMuted,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20.0),
            const SizedBox(
              width: 24.0,
              height: 24.0,
              child: CircularProgressIndicator(
                strokeWidth: 2.0,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.brand),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
