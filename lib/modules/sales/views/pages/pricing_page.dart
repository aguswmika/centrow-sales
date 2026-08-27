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

  const PricingPage({super.key, required this.proposalId});

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
    _controller.loadProposalDetail(widget.proposalId);
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
        child: Watch.builder(
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
                  _buildParamBar(context),
                  const Divider(
                    height: 1.5,
                    thickness: 1.5,
                    color: AppColors.border,
                  ),
                  Expanded(
                    child: PricingCalculatorView(
                      proposal: data,
                      calculatorController: _calcController,
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
              const SizedBox(width: 12.0),
              AppButton(
                text: 'Simpan Kalkulasi',
                icon: const Icon(Icons.save_outlined, size: 18),
                isFullWidth: false,
                height: 40.0,
                onPressed: () {}, // Mock save
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

  Widget _buildParamBar(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 800;

          if (isNarrow) {
            return Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildParamItem(
                        'Luas Area Properti',
                        _calcController.areaValue.value?.toString(),
                        icon: Icons.square_foot,
                        suffix: 'm²',
                        keyboardType: TextInputType.number,
                        onChanged: (val) => _calcController.areaValue.value =
                            double.tryParse(val),
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: _buildParamItem(
                        'Durasi Kontrak',
                        _calcController.contractMonths.value?.toString(),
                        icon: Icons.calendar_today,
                        suffix: 'Bulan',
                        keyboardType: TextInputType.number,
                        onChanged: (val) =>
                            _calcController.contractMonths.value = int.tryParse(
                              val,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12.0),
                _buildParamItem(
                  'Frekuensi Kunjungan',
                  _calcController.visitFrequency.value?.toString(),
                  icon: Icons.repeat,
                  suffix: 'Visit',
                  keyboardType: TextInputType.number,
                  onChanged: (val) =>
                      _calcController.visitFrequency.value = int.tryParse(val),
                ),
              ],
            );
          }

          return Row(
            children: [
              Expanded(
                child: _buildParamItem(
                  'Luas Area Properti',
                  _calcController.areaValue.value?.toString(),
                  icon: Icons.square_foot,
                  suffix: 'm²',
                  keyboardType: TextInputType.number,
                  onChanged: (val) =>
                      _calcController.areaValue.value = double.tryParse(val),
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: _buildParamItem(
                  'Durasi Kontrak',
                  _calcController.contractMonths.value?.toString(),
                  icon: Icons.calendar_today,
                  suffix: 'Bulan',
                  keyboardType: TextInputType.number,
                  onChanged: (val) =>
                      _calcController.contractMonths.value = int.tryParse(val),
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: _buildParamItem(
                  'Frekuensi Kunjungan',
                  _calcController.visitFrequency.value?.toString(),
                  icon: Icons.repeat,
                  suffix: 'Visit',
                  keyboardType: TextInputType.number,
                  onChanged: (val) =>
                      _calcController.visitFrequency.value = int.tryParse(val),
                ),
              ),
            ],
          );
        },
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
            color: AppColors.subtle,
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
                  onChanged: onChanged,
                  style: const TextStyle(
                    fontSize: 13.0,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
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
