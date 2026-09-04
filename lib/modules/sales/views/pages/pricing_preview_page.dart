import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:centrow_sales/shared/state/ui_state.dart';
import 'package:centrow_sales/shared/theme/app_colors.dart';
import 'package:centrow_sales/shared/theme/app_radius.dart';
import 'package:centrow_sales/shared/widgets/app_button.dart';
import 'package:centrow_sales/shared/widgets/toast.dart';
import 'package:centrow_sales/modules/sales/entities/pricing_preview.dart';
import 'package:centrow_sales/modules/sales/entities/proposal.dart';
import 'package:centrow_sales/modules/sales/controllers/pricing_calculator_controller.dart';
import 'package:centrow_sales/modules/sales/views/widgets/pricing_calculator/pricing_utils.dart';

class PricingPreviewPage extends StatefulWidget {
  final Proposal proposal;
  final PricingPreview preview;
  final PricingCalculatorController controller;
  final int contractMonths;

  const PricingPreviewPage({
    super.key,
    required this.proposal,
    required this.preview,
    required this.controller,
    required this.contractMonths,
  });

  @override
  State<PricingPreviewPage> createState() => _PricingPreviewPageState();
}

class _PricingPreviewPageState extends State<PricingPreviewPage> {
  late final void Function() _cleanupEffect;

  @override
  void initState() {
    super.initState();
    _cleanupEffect = effect(() {
      final state = widget.controller.submitState.value;
      if (!mounted) return;
      switch (state) {
        case UiFailure(:final failure):
          showAppToast(context, failure.message, isError: true);
        case UiSuccess():
          showAppToast(
            context,
            'Kalkulasi berhasil disimpan.',
            isSuccess: true,
          );
          context.goNamed(
            'proposals',
            extra: {'id': widget.proposal.id, 'refresh': true},
          );
        default:
          break;
      }
    });
  }

  @override
  void dispose() {
    _cleanupEffect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.preview;
    final pricePerMonth = widget.contractMonths > 0
        ? p.totalAmount / widget.contractMonths
        : 0.0;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildSection('Biaya Pokok (COGS)', [
                      buildSumRow('Bahan & Alat', formatRp(p.suppliesCost)),
                      buildSumRow('Tenaga Kerja', formatRp(p.workerCost)),
                      buildSumRow('BBM / Transport', formatRp(p.fuelCost)),
                      const Divider(height: 16.0, color: AppColors.border),
                      buildSumRow(
                        'Total COGS',
                        formatRp(p.totalCogs),
                        bold: true,
                      ),
                    ]),
                    if (p.supplies.isNotEmpty) ...[
                      const SizedBox(height: 12.0),
                      _buildSection('Rincian Bahan & Alat', [
                        for (final s in p.supplies)
                          buildSumRow(s.name, formatRp(s.lineTotal)),
                      ]),
                    ],
                    if (p.workers.isNotEmpty) ...[
                      const SizedBox(height: 12.0),
                      _buildSection('Rincian Tenaga Kerja', [
                        for (final w in p.workers)
                          buildSumRow(w.name, formatRp(w.lineTotal)),
                      ]),
                    ],
                    if (p.items.isNotEmpty) ...[
                      const SizedBox(height: 12.0),
                      _buildSection('Rincian Transport & Add-on', [
                        for (final i in p.items)
                          buildSumRow(i.name, formatRp(i.lineTotal)),
                      ]),
                    ],
                    const SizedBox(height: 12.0),
                    _buildSection('Harga & Margin', [
                      buildSumRow(
                        'Harga Pokok Layanan',
                        formatRp(p.servicePrice),
                        semiBold: true,
                      ),
                      buildSumRow('Add-on / Ekstra', formatRp(p.addonAmount)),
                      if (p.discountAmount > 0)
                        buildSumRow(
                          'Diskon Khusus',
                          '-${formatRp(p.discountAmount)}',
                        ),
                      const Divider(height: 16.0, color: AppColors.border),
                      buildSumRow(
                        'Subtotal (DPP)',
                        formatRp(p.subtotal),
                        semiBold: true,
                      ),
                      buildSumRow(
                        'PPN (${p.taxPercentage.toStringAsFixed(1)}%)',
                        formatRp(p.taxAmount),
                      ),
                      const Divider(height: 16.0, color: AppColors.border),
                      buildSumRow(
                        'Total Nilai Proposal',
                        formatRp(p.totalAmount),
                        bold: true,
                      ),
                    ]),
                    const SizedBox(height: 12.0),
                    _buildSection('Metrik Margin & Unit Rate', [
                      buildSumRow(
                        'Margin %',
                        '${p.marginPercent.toStringAsFixed(1)}%',
                        semiBold: true,
                      ),
                      buildSumRow('Nominal Margin', formatRp(p.marginAmount)),
                      const Divider(height: 16.0, color: AppColors.border),
                      buildSumRow('Harga per Bulan', formatRp(pricePerMonth)),
                    ]),
                    const SizedBox(height: 32.0),
                  ],
                ),
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
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
                'Ringkasan Kalkulasi',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                ),
              ),
              Text(
                widget.proposal.clientName,
                style: const TextStyle(fontSize: 12.0, color: AppColors.sec),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> rows) {
    return Container(
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border, width: 1.5),
        borderRadius: AppRadius.borderLg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 10.0),
          ...rows,
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: AppButton.secondary(
              text: 'Kembali & Edit',
              onPressed: () => context.pop(),
            ),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: SignalBuilder(
              builder: (context) {
                final isLoading =
                    widget.controller.submitState.value is UiLoading;
                return AppButton(
                  text: 'Konfirmasi & Simpan',
                  isLoading: isLoading,
                  onPressed: isLoading
                      ? null
                      : () =>
                            widget.controller.submitPricing(widget.proposal.id),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
