import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:signals/signals_flutter.dart';
import '../../../../app/di.dart';
import '../../../../shared/config/app_assets.dart';
import '../../../../shared/state/ui_state.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_dropdown.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/toast.dart';
import '../../controllers/login_controller.dart';
import '../../entities/tenant.dart';
import '../../entities/user.dart';

class LoginPage extends StatefulWidget {
  final LoginController? controller;

  const LoginPage({super.key, this.controller});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final LoginController _controller;
  late final EffectCleanup _cleanupEffect;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? getIt<LoginController>();
    _controller.loadTenants();

    _cleanupEffect = effect(() {
      final state = _controller.state.value;
      final tenantsState = _controller.tenantsState.value;
      if (!mounted) return;

      switch (tenantsState) {
        case UiFailure<List<Tenant>>(:final failure):
          showAppToast(
            context,
            'Gagal memuat cabang: ${failure.message}',
            isError: true,
          );
        default:
          break;
      }

      switch (state) {
        case UiFailure<User>(:final failure):
          showAppToast(context, failure.message, isError: true);
        case UiSuccess<User>():
          showAppToast(context, 'Berhasil masuk ke sistem.', isSuccess: true);
          context.go('/customers');
        default:
          break;
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
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildBrandHeader(),
                  const SizedBox(height: 24.0),
                  _buildLoginCard(context),
                  const SizedBox(height: 20.0),
                  _buildFooterMeta(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBrandHeader() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 52.0,
          height: 52.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: const [
              BoxShadow(
                color: Color(0x331E40AF),
                blurRadius: 12.0,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.0),
            child: SvgPicture.asset(
              AppAssets.logoFilled,
              width: 52.0,
              height: 52.0,
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 12.0),
        Text(
          'Centrow Sales',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 22.0,
            fontWeight: FontWeight.w800,
            color: AppColors.text,
            letterSpacing: -0.44,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 28.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22.0),
        border: Border.all(color: AppColors.border, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 16.0,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Watch.builder(
        builder: (BuildContext context) {
          final isObscured = _controller.obscurePassword.value;
          final loginState = _controller.state.value;
          final isLoading = loginState is UiLoading;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(
                label: 'Email / Nama Pengguna',
                hint: 'nama@nohama.id',
                prefixIcon: const Icon(
                  Icons.mail_outline_rounded,
                  size: 20,
                  color: AppColors.muted,
                ),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                onChanged: _controller.setEmail,
              ),
              const SizedBox(height: 16.0),
              AppTextField(
                label: 'Kata Sandi',
                hint: '••••••••',
                prefixIcon: const Icon(
                  Icons.lock_outline_rounded,
                  size: 20,
                  color: AppColors.muted,
                ),
                obscureText: isObscured,
                isPassword: false,
                suffixIcon: IconButton(
                  icon: Icon(
                    isObscured
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.muted,
                    size: 20,
                  ),
                  onPressed: _controller.togglePasswordVisibility,
                ),
                textInputAction: TextInputAction.done,
                onChanged: _controller.setPassword,
                onSubmitted: (_) => _controller.submitLogin(),
              ),
              const SizedBox(height: 16.0),
              Watch.builder(
                builder: (BuildContext context) {
                  final tenantsState = _controller.tenantsState.value;
                  final selectedTenantId = _controller.selectedTenantId.value;

                  return switch (tenantsState) {
                    UiLoading() => const AppDropdown<String>(
                      label: 'Cabang',
                      value: null,
                      items: [],
                      hint: 'Memuat cabang...',
                      enabled: false,
                      onChanged: null,
                    ),
                    UiSuccess(:final data) => AppDropdown<String>(
                      label: 'Cabang',
                      value: data.any((t) => t.id == selectedTenantId)
                          ? selectedTenantId
                          : (data.isNotEmpty ? data.first.id : null),
                      items: data
                          .map(
                            (t) => DropdownMenuItem<String>(
                              value: t.id,
                              child: Text(t.name),
                            ),
                          )
                          .toList(),
                      onChanged: (val) =>
                          val != null ? _controller.selectTenant(val) : null,
                    ),
                    UiFailure() => const AppDropdown<String>(
                      label: 'Cabang',
                      value: null,
                      items: [],
                      hint: 'Cabang tidak tersedia',
                      enabled: false,
                      onChanged: null,
                    ),
                    _ => const AppDropdown<String>(
                      label: 'Cabang',
                      value: null,
                      items: [],
                      hint: 'Tidak ada cabang tersedia',
                      enabled: false,
                      onChanged: null,
                    ),
                  };
                },
              ),
              const SizedBox(height: 22.0),
              AppButton(
                text: 'Login',
                height: 48.0,
                isLoading: isLoading,
                onPressed: _controller.isValid.value
                    ? _controller.submitLogin
                    : null,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFooterMeta() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 7.0,
          height: 7.0,
          decoration: const BoxDecoration(
            color: AppColors.ok,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6.0),
        Flexible(
          child: Text(
            'v1.0.0',
            style: GoogleFonts.inter(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: AppColors.muted,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
