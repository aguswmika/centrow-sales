import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:centrow_sales/app/di.dart';
import 'package:centrow_sales/modules/sales/controllers/pricing_calculator_controller.dart';
import 'package:centrow_sales/modules/sales/controllers/proposal_controller.dart';
import 'package:centrow_sales/modules/sales/views/widgets/pricing_calculator_view.dart';
import 'package:centrow_sales/shared/state/ui_state.dart';
import 'package:centrow_sales/shared/theme/app_colors.dart';
import 'package:centrow_sales/shared/theme/app_radius.dart';
import 'package:centrow_sales/shared/widgets/app_button.dart';
import 'package:centrow_sales/shared/widgets/error_view.dart';
import 'package:centrow_sales/modules/sales/entities/proposal.dart';

class PricingPage extends StatefulWidget {
  final String proposalId;
  final Proposal? initialProposal;

  const PricingPage({
    super.key,
    required this.proposalId,
    this.initialProposal,
  });

  @override
  State<PricingPage> createState() => _PricingPageState();
}

class _PricingPageState extends State<PricingPage> {
  late final ProposalController _controller;
  late final PricingCalculatorController _calcController;

  @override
  void initState() {
    super.initState();
    _controller = getIt<ProposalController>();
    _calcController = getIt<PricingCalculatorController>();
    _controller.loadProposalDetail(widget.proposalId).then((_) {
      final state = _controller.proposalDetailState.value;
      if (state is UiSuccess<Proposal>) {
        if (state.data.hasPricing) {
          _calcController.loadExistingPricing(widget.proposalId);
        }
      }
    });
    _calcController.loadUoms();
  }

  @override
  void dispose() {
    _calcController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SignalBuilder(
          builder: (context) {
            final state = _controller.proposalDetailState.value;
            return switch (state) {
              UiInitial() || UiLoading() => const Center(
                child: CircularProgressIndicator(color: AppColors.brand),
              ),
              UiFailure(:final failure) => Center(
                child: ErrorView(
                  message: failure.message,
                  onRetry: () =>
                      _controller.loadProposalDetail(widget.proposalId),
                ),
              ),
              UiSuccess(:final data) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildPageHeader(context, data),
                  if (!data.status.canEditPricing) _buildReadOnlyBanner(data),
                  _buildParamBar(context, enabled: data.status.canEditPricing),
                  const Divider(
                    height: 1.5,
                    thickness: 1.5,
                    color: AppColors.border,
                  ),
                  Expanded(
                    child: PricingCalculatorView(
                      proposal: data,
                      calculatorController: _calcController,
                      isReadOnly: !data.status.canEditPricing,
                    ),
                  ),
                ],
              ),
            };
          },
        ),
      ),
    );
  }

  Widget _buildReadOnlyBanner(Proposal proposal) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      decoration: const BoxDecoration(
        color: Color(0x24BC7B43),
        border: Border(
          bottom: BorderSide(color: Color(0x4DBC7B43), width: 1.0),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.lock_outline, size: 20.0, color: Color(0xFF92580F)),
          const SizedBox(width: 10.0),
          Expanded(
            child: Text(
              'Proposal ini berstatus ${proposal.status.displayName}. Kalkulasi harga terkunci dan tidak dapat diubah.',
              style: GoogleFonts.inter(
                fontSize: 13.0,
                color: const Color(0xFF92580F),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageHeader(BuildContext context, Proposal data) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                onPressed: () => context.pop(),
                color: AppColors.text,
              ),
              const SizedBox(width: 8.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kalkulator Harga & Biaya Layanan',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 6.0),
                  Row(
                    children: [
                      _buildBadge(
                        data.clientName,
                        Icons.business,
                        AppColors.brand,
                        AppColors.brand10,
                      ),
                      const SizedBox(width: 8.0),
                      _buildBadge(
                        data.code,
                        Icons.tag,
                        AppColors.text,
                        AppColors.border,
                      ),
                      const SizedBox(width: 8.0),
                      _buildBadge(
                        data.serviceName,
                        Icons.verified_user,
                        AppColors.ok,
                        AppColors.ok.withValues(alpha: 0.1),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              AppButton.secondary(
                text: 'Batal',
                isFullWidth: false,
                height: 40.0,
                onPressed: () => context.pop(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, IconData icon, Color color, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppRadius.borderSm,
      ),
      child: Row(
        children: [
          Icon(icon, size: 12.0, color: color),
          const SizedBox(width: 4.0),
          Text(
            text,
            style: TextStyle(
              fontSize: 11.0,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParamBar(BuildContext context, {bool enabled = true}) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
      child: Row(
        children: [
          Expanded(
            child: _buildParamItem(
              'Durasi Kontrak',
              _calcController.contractMonths.value?.toString(),
              icon: Icons.calendar_today,
              suffix: 'Bulan',
              keyboardType: TextInputType.number,
              enabled: enabled,
              onChanged: (val) =>
                  _calcController.contractMonths.value = int.tryParse(val),
            ),
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: _buildParamItem(
              'Frek. Kunjungan',
              _calcController.visitFrequency.value?.toString(),
              icon: Icons.refresh,
              suffix: 'Kali',
              keyboardType: TextInputType.number,
              enabled: enabled,
              onChanged: (val) =>
                  _calcController.visitFrequency.value = int.tryParse(val),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParamItem(
    String label,
    String? initialValue, {
    required IconData icon,
    String? suffix,
    TextInputType keyboardType = TextInputType.text,
    ValueChanged<String>? onChanged,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12.0,
            fontWeight: FontWeight.w600,
            color: AppColors.sec,
          ),
        ),
        const SizedBox(height: 6.0),
        Container(
          height: 44.0,
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          decoration: BoxDecoration(
            color: enabled
                ? AppColors.subtle
                : AppColors.border.withValues(alpha: 0.3),
            border: Border.all(color: AppColors.border, width: 1.5),
            borderRadius: AppRadius.borderSm,
          ),
          child: Row(
            children: [
              Icon(icon, size: 16.0, color: AppColors.muted),
              const SizedBox(width: 8.0),
              Expanded(
                child: TextFormField(
                  initialValue: initialValue,
                  keyboardType: keyboardType,
                  enabled: enabled,
                  onChanged: onChanged,
                  style: TextStyle(
                    fontSize: 13.0,
                    fontWeight: FontWeight.w600,
                    color: enabled ? AppColors.text : AppColors.muted,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    filled: false,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                    suffixText: suffix,
                    suffixStyle: const TextStyle(
                      fontSize: 13.0,
                      fontWeight: FontWeight.w600,
                      color: AppColors.sec,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
