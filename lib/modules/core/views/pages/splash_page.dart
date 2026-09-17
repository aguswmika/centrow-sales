import 'package:flutter/material.dart';
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
      backgroundColor: AppColors.brand,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            Container(
              width: 96.0,
              height: 96.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24.0),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 16.0,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24.0),
                child: Image.asset(
                  'assets/img/app_icon_full.png',
                  width: 96.0,
                  height: 96.0,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            Text(
              'Centrow Sales',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 26.0,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Mobile ERP & POS',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14.0,
                fontWeight: FontWeight.w500,
                color: Colors.white.withAlpha(204),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: 24.0,
              height: 24.0,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.white.withAlpha(204),
                ),
              ),
            ),
            const SizedBox(height: 48.0),
          ],
        ),
      ),
    );
  }
}
