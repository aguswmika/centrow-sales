import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:centrow_sales/app/di.dart';
import 'package:centrow_sales/modules/sales/controllers/contract_addendum_controller.dart';
import 'package:centrow_sales/modules/sales/controllers/pricing_calculator_controller.dart';
import 'package:centrow_sales/modules/sales/entities/contract.dart';
import 'package:centrow_sales/modules/sales/repositories/dtos/contract_addendum_dto.dart';
import 'package:centrow_sales/modules/sales/views/widgets/pricing_calculator/pricing_tabs.dart';
import 'package:centrow_sales/modules/sales/views/widgets/pricing_calculator/pricing_material_tab.dart';
import 'package:centrow_sales/modules/sales/views/widgets/pricing_calculator/pricing_worker_tab.dart';
import 'package:centrow_sales/modules/sales/views/widgets/pricing_calculator/pricing_item_tab.dart';
import 'package:centrow_sales/modules/sales/views/widgets/pricing_calculator/pricing_settings_card.dart';
import 'package:centrow_sales/shared/result/result.dart';
import 'package:centrow_sales/shared/state/ui_state.dart';
import 'package:centrow_sales/shared/theme/app_colors.dart';
import 'package:centrow_sales/shared/theme/app_radius.dart';
import 'package:centrow_sales/shared/widgets/app_button.dart';
import 'package:centrow_sales/shared/widgets/app_text_field.dart';
import 'package:centrow_sales/shared/widgets/toast.dart';

class ContractAddendumPricingPage extends StatefulWidget {
  final Contract contract;

  const ContractAddendumPricingPage({super.key, required this.contract});

  @override
  State<ContractAddendumPricingPage> createState() =>
      _ContractAddendumPricingPageState();
}

class _ContractAddendumPricingPageState
    extends State<ContractAddendumPricingPage> {
  late final PricingCalculatorController _calcController;
  late final ContractAddendumController _addendumController;

  late final TextEditingController _contractMonthsCtrl;
  late final TextEditingController _visitFrequencyCtrl;
  late final TextEditingController _totalVisitsCtrl;

  int _activeTab = 0;

  @override
  void initState() {
    super.initState();
    _calcController = getIt<PricingCalculatorController>();
    _addendumController = getIt<ContractAddendumController>();

    _calcController.setScheduleWorkOrderType(
      widget.contract.scheduleWorkOrderType ?? 1,
    );

    _contractMonthsCtrl = TextEditingController(
      text: _calcController.contractMonths.value?.toString() ?? '',
    );
    _visitFrequencyCtrl = TextEditingController(
      text: _calcController.visitFrequency.value?.toString() ?? '',
    );
    _totalVisitsCtrl = TextEditingController(
      text: widget.contract.totalVisits?.toString() ?? '',
    );

    _calcController.loadUoms();
    _calcController.loadTreatmentMethods();

    final sourceProposalId = widget.contract.sourceProposalId;
    if (sourceProposalId != null && sourceProposalId.isNotEmpty) {
      _calcController.loadExistingPricing(sourceProposalId).then((_) {
        if (mounted) {
          _contractMonthsCtrl.text =
              _calcController.contractMonths.value?.toString() ?? '';
          _visitFrequencyCtrl.text =
              _calcController.visitFrequency.value?.toString() ?? '';
          _totalVisitsCtrl.text =
              _calcController.totalVisits.value?.toString() ??
              widget.contract.totalVisits?.toString() ??
              '';
        }
      });
    } else {
      if (widget.contract.totalVisits != null) {
        _calcController.setTotalVisits(widget.contract.totalVisits);
      }
    }
  }

  @override
  void dispose() {
    _contractMonthsCtrl.dispose();
    _visitFrequencyCtrl.dispose();
    _totalVisitsCtrl.dispose();
    _calcController.dispose();
    _addendumController.dispose();
    super.dispose();
  }

  void _syncTotalVisitsText() {
    final visits = _calcController.totalVisits.value;
    final newText = visits?.toString() ?? '';
    if (_totalVisitsCtrl.text != newText) {
      _totalVisitsCtrl.text = newText;
    }
  }

  void _openReviewSheet() {
    final err = _calcController.validateInputs();
    if (err != null) {
      showAppToast(context, err, isError: true);
      return;
    }

    showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddendumReviewBottomSheet(
        contract: widget.contract,
        calcController: _calcController,
        addendumController: _addendumController,
      ),
    ).then((result) {
      if (result == true && mounted) {
        Navigator.of(context).pop(true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildPageHeader(context),
            _buildParamBar(context),
            const Divider(height: 1.5, thickness: 1.5, color: AppColors.border),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PricingTabs(
                      activeTab: _activeTab,
                      onTabChanged: (index) {
                        setState(() => _activeTab = index);
                      },
                      controller: _calcController,
                    ),
                    Container(
                      color: AppColors.surface,
                      child: _buildTabContent(),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: PricingSettingsCard(
                        controller: _calcController,
                        isReadOnly: false,
                      ),
                    ),
                    const SizedBox(height: 32.0),
                  ],
                ),
              ),
            ),
            _buildBottomActionBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_activeTab) {
      case 0:
        return PricingSupplyTab(controller: _calcController, isReadOnly: false);
      case 1:
        return PricingWorkerTab(controller: _calcController, isReadOnly: false);
      case 2:
        return PricingItemTab(controller: _calcController, isReadOnly: false);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildPageHeader(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                  onPressed: () => context.pop(),
                  color: AppColors.text,
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kalkulator Addendum Kontrak',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18.0,
                          fontWeight: FontWeight.w700,
                          color: AppColors.text,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6.0),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildBadge(
                              widget.contract.customerName.isNotEmpty
                                  ? widget.contract.customerName
                                  : 'Pelanggan',
                              Icons.business,
                              AppColors.brand,
                              AppColors.brand10,
                            ),
                            const SizedBox(width: 8.0),
                            _buildBadge(
                              widget.contract.code,
                              Icons.tag,
                              AppColors.text,
                              AppColors.border,
                            ),
                            const SizedBox(width: 8.0),
                            _buildBadge(
                              widget.contract.serviceName.isNotEmpty
                                  ? widget.contract.serviceName
                                  : 'Layanan',
                              Icons.verified_user,
                              AppColors.ok,
                              AppColors.ok.withValues(alpha: 0.1),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12.0),
          AppButton.secondary(
            text: 'Batal',
            isFullWidth: false,
            height: 40.0,
            onPressed: () => context.pop(),
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
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: _buildParamItem(
              'Durasi Kontrak',
              controller: _contractMonthsCtrl,
              icon: Icons.calendar_today,
              suffix: 'Bulan',
              keyboardType: TextInputType.number,
              onChanged: (val) {
                _calcController.setContractMonths(int.tryParse(val));
                _syncTotalVisitsText();
              },
            ),
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: _buildParamItem(
              'Frek. Kunjungan',
              controller: _visitFrequencyCtrl,
              icon: Icons.refresh,
              suffix: 'Kali',
              keyboardType: TextInputType.number,
              onChanged: (val) {
                _calcController.setVisitFrequency(int.tryParse(val));
                _syncTotalVisitsText();
              },
            ),
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: _buildParamItem(
              'Total Kunjungan',
              controller: _totalVisitsCtrl,
              icon: Icons.numbers,
              suffix: 'Kunjungan',
              keyboardType: TextInputType.number,
              onChanged: (val) {
                _calcController.setTotalVisits(int.tryParse(val));
              },
            ),
          ),
          const SizedBox(width: 16.0),
          SignalBuilder(
            builder: (context) {
              final selected = _calcController.scheduleWorkOrderType.value;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Jenis Penjadwalan',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w600,
                      color: AppColors.muted,
                    ),
                  ),
                  const SizedBox(height: 6.0),
                  Row(
                    children: [
                      _buildWorkOrderToggleButton(
                        label: 'Routine',
                        value: 1,
                        selected: selected,
                        onTap: () =>
                            _calcController.setScheduleWorkOrderType(1),
                      ),
                      const SizedBox(width: 4.0),
                      _buildWorkOrderToggleButton(
                        label: 'Station',
                        value: 2,
                        selected: selected,
                        onTap: () =>
                            _calcController.setScheduleWorkOrderType(2),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWorkOrderToggleButton({
    required String label,
    required int value,
    required int selected,
    required VoidCallback onTap,
  }) {
    final isActive = selected == value;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40.0,
        padding: const EdgeInsets.symmetric(horizontal: 14.0),
        decoration: BoxDecoration(
          color: isActive ? AppColors.brand : AppColors.subtle,
          border: Border.all(
            color: isActive ? AppColors.brand : AppColors.border,
            width: 1.5,
          ),
          borderRadius: AppRadius.borderSm,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13.0,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : AppColors.muted,
          ),
        ),
      ),
    );
  }

  Widget _buildParamItem(
    String label, {
    required TextEditingController controller,
    required IconData icon,
    required String suffix,
    required TextInputType keyboardType,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12.0,
            fontWeight: FontWeight.w600,
            color: AppColors.muted,
          ),
        ),
        const SizedBox(height: 6.0),
        Container(
          height: 40.0,
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
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
                  controller: controller,
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

  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: AppButton(
        text: 'Review & Terapkan Addendum',
        icon: const Icon(Icons.arrow_forward, size: 18, color: Colors.white),
        onPressed: _openReviewSheet,
      ),
    );
  }
}

class AddendumReviewBottomSheet extends StatefulWidget {
  final Contract contract;
  final PricingCalculatorController calcController;
  final ContractAddendumController addendumController;

  const AddendumReviewBottomSheet({
    super.key,
    required this.contract,
    required this.calcController,
    required this.addendumController,
  });

  @override
  State<AddendumReviewBottomSheet> createState() =>
      _AddendumReviewBottomSheetState();
}

class _AddendumReviewBottomSheetState extends State<AddendumReviewBottomSheet> {
  late final TextEditingController _reasonController;

  @override
  void initState() {
    super.initState();
    _reasonController = TextEditingController();
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final pricingReq = widget.calcController.buildRequest();
    final addendumReq = CreateContractAddendumRequestDto.fromPricingRequest(
      pricingReq,
      reason: _reasonController.text.trim().isNotEmpty
          ? _reasonController.text.trim()
          : null,
    );

    final res = await widget.addendumController.createAddendum(
      widget.contract.id,
      addendumReq,
    );

    if (!mounted) return;

    switch (res) {
      case Ok():
        Navigator.of(context).pop(true);
      case Err(:final failure):
        showAppToast(context, failure.message, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final oldVisits = widget.contract.totalVisits ?? 0;
    final newVisits = widget.calcController.totalVisits.value ?? oldVisits;
    final visitDelta = newVisits - oldVisits;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        20,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ringkasan Addendum',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () => Navigator.of(context).pop(false),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.subtle,
              borderRadius: AppRadius.borderSm,
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                _buildSummaryRow(
                  label: 'Total Kunjungan',
                  value: '$oldVisits → $newVisits ($newVisits kali)',
                  badge: visitDelta != 0
                      ? '${visitDelta > 0 ? '+' : ''}$visitDelta'
                      : '0',
                  badgeColor: visitDelta >= 0 ? AppColors.ok : AppColors.warn,
                ),
                const Divider(height: 20, color: AppColors.border),
                _buildSummaryRow(
                  label: 'Nilai Kontrak Sebelumnya',
                  value: widget.contract.formattedValue,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Alasan Addendum',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 6),
          AppTextField(
            controller: _reasonController,
            hint: 'Masukkan alasan perubahan kontrak (opsional)...',
            maxLines: 3,
          ),
          const SizedBox(height: 24),
          SignalBuilder(
            builder: (context) {
              final isLoading =
                  widget.addendumController.createState.value is UiLoading;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppButton(
                    text: 'Terapkan Addendum',
                    isLoading: isLoading,
                    onPressed: isLoading ? null : _submit,
                  ),
                  const SizedBox(height: 12),
                  AppButton.secondary(
                    text: 'Kembali Edit',
                    onPressed: isLoading
                        ? null
                        : () => Navigator.of(context).pop(false),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow({
    required String label,
    required String value,
    String? badge,
    Color? badgeColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            color: AppColors.muted,
          ),
        ),
        Row(
          children: [
            Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              ),
            ),
            if (badge != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: (badgeColor ?? AppColors.brand).withValues(alpha: 0.1),
                  borderRadius: AppRadius.borderSm,
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: badgeColor ?? AppColors.brand,
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
