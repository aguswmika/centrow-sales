import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:centrow_sales/app/di.dart';
import 'package:centrow_sales/modules/sales/controllers/site_risk_controller.dart';
import 'package:centrow_sales/modules/sales/entities/customer.dart';
import 'package:centrow_sales/modules/sales/entities/site_risk.dart';
import 'package:centrow_sales/shared/state/ui_state.dart';
import 'package:centrow_sales/shared/theme/app_colors.dart';
import 'package:centrow_sales/shared/theme/app_radius.dart';
import 'package:centrow_sales/shared/widgets/app_badge.dart';
import 'package:centrow_sales/shared/widgets/error_view.dart';

class SiteRiskAssessmentSheet extends StatefulWidget {
  final String customerId;
  final CustomerLocation location;
  final VoidCallback? onSaved;

  const SiteRiskAssessmentSheet({
    super.key,
    required this.customerId,
    required this.location,
    this.onSaved,
  });

  @override
  State<SiteRiskAssessmentSheet> createState() =>
      _SiteRiskAssessmentSheetState();
}

class _SiteRiskAssessmentSheetState extends State<SiteRiskAssessmentSheet> {
  late final SiteRiskController _controller;
  final TextEditingController _customRiskTextController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = getIt<SiteRiskController>();
    _controller.loadMasterRisks();
    _controller.loadAddressRisks(widget.customerId, widget.location.id ?? '');
  }

  @override
  void dispose() {
    _customRiskTextController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _handleAddCustomRisk() {
    final text = _customRiskTextController.text.trim();
    if (text.isNotEmpty) {
      _controller.addCustomRisk(text);
      _customRiskTextController.clear();
    }
  }

  Future<void> _handleSave() async {
    await _controller.saveAddressRisks(
      widget.customerId,
      widget.location.id ?? '',
    );
    if (!mounted) return;
    final state = _controller.saveState.value;
    if (state is UiSuccess) {
      widget.onSaved?.call();
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Penilaian risiko berhasil disimpan'),
          backgroundColor: AppColors.ok,
        ),
      );
    } else if (state case UiFailure(:final failure)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(failure.message),
          backgroundColor: AppColors.err,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final locationTitle = widget.location.label.isNotEmpty
        ? widget.location.label
        : 'Titik Servis';
    final locationSubtitle = widget.location.address.isNotEmpty
        ? widget.location.address
        : '-';

    return Material(
      color: AppColors.surface,
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(AppRadius.rLg),
      ),
      clipBehavior: Clip.antiAlias,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12.0, bottom: 8.0),
                width: 40.0,
                height: 4.0,
                decoration: BoxDecoration(
                  color: AppColors.borderStrong,
                  borderRadius: BorderRadius.circular(2.0),
                ),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Site Risk Assessment',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w700,
                            color: AppColors.text,
                          ),
                        ),
                        const SizedBox(height: 2.0),
                        Text(
                          '$locationTitle • $locationSubtitle',
                          style: GoogleFonts.inter(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: AppColors.muted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close_rounded,
                      color: AppColors.sec,
                      size: 20.0,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            const Divider(height: 1.0, color: AppColors.border),

            // Reactive Body Content
            Expanded(
              child: SignalBuilder(
                builder: (context) {
                  final masterRisksState = _controller.masterRisks.value;
                  final addressRisksState = _controller.addressRisks.value;
                  final saveState = _controller.saveState.value;

                  if (masterRisksState is UiLoading ||
                      masterRisksState is UiInitial ||
                      addressRisksState is UiLoading ||
                      addressRisksState is UiInitial) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (masterRisksState case UiFailure(:final failure)) {
                    return Center(
                      child: ErrorView(
                        message: failure.message,
                        onRetry: () {
                          _controller.loadMasterRisks();
                          _controller.loadAddressRisks(
                            widget.customerId,
                            widget.location.id ?? '',
                          );
                        },
                      ),
                    );
                  }

                  if (addressRisksState case UiFailure(:final failure)) {
                    return Center(
                      child: ErrorView(
                        message: failure.message,
                        onRetry: () {
                          _controller.loadMasterRisks();
                          _controller.loadAddressRisks(
                            widget.customerId,
                            widget.location.id ?? '',
                          );
                        },
                      ),
                    );
                  }

                  final masterList =
                      (masterRisksState as UiSuccess<List<SiteRiskMaster>>)
                          .data;
                  final addressList =
                      (addressRisksState
                              as UiSuccess<List<CustomerAddressRisk>>)
                          .data;
                  final selectedIds = _controller.selectedSiteRiskIds.value;
                  final customRisks = _controller.customRisks.value;

                  final masterIds = masterList.map((m) => m.id).toSet();
                  final retainedRisks = addressList
                      .where(
                        (r) =>
                            r.siteRiskId != null &&
                            !masterIds.contains(r.siteRiskId),
                      )
                      .toList();

                  return ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
                    children: [
                      // Inline Error Banner on Save Failure
                      if (saveState case UiFailure(:final failure))
                        Container(
                          margin: const EdgeInsets.only(bottom: 16.0),
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEE2E2),
                            borderRadius: AppRadius.borderMd,
                            border: Border.all(color: AppColors.err),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: AppColors.err,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  failure.message,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: AppColors.err,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Section 1: Master Risks
                      _buildSectionHeader(
                        title: 'Daftar Risiko Standar (Master)',
                        subtitle:
                            'Pilih bahaya keselamatan yang teridentifikasi di lokasi ini',
                        badgeText:
                            '${selectedIds.intersection(masterIds).length}/${masterList.length}',
                      ),
                      const SizedBox(height: 8.0),
                      if (masterList.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            'Tidak ada daftar risiko standar.',
                            style: GoogleFonts.inter(
                              fontSize: 13.0,
                              color: AppColors.muted,
                            ),
                          ),
                        )
                      else
                        for (final item in masterList)
                          _buildRiskCheckboxTile(
                            title: item.name,
                            isSelected: selectedIds.contains(item.id),
                            onChanged: (_) =>
                                _controller.toggleMasterRisk(item.id),
                          ),

                      // Section 2: Retained Risks
                      if (retainedRisks.isNotEmpty) ...[
                        const SizedBox(height: 20.0),
                        _buildSectionHeader(
                          title: 'Risiko Tersimpan Sebelumnya (Non-Master)',
                          subtitle:
                              'Risiko ini telah tercatat sebelumnya namun sudah tidak aktif di master',
                          badgeText:
                              '${selectedIds.intersection(retainedRisks.map((e) => e.siteRiskId!).toSet()).length}/${retainedRisks.length}',
                        ),
                        const SizedBox(height: 8.0),
                        for (final item in retainedRisks)
                          _buildRiskCheckboxTile(
                            title: item.name,
                            isSelected: selectedIds.contains(item.siteRiskId!),
                            onChanged: (_) =>
                                _controller.toggleMasterRisk(item.siteRiskId!),
                          ),
                      ],

                      // Section 3: Custom Risks
                      const SizedBox(height: 20.0),
                      _buildSectionHeader(
                        title: 'Risiko Kustom Tambahan',
                        subtitle:
                            'Tambahkan bahaya atau kendala spesifik lokasi lainnya',
                        badgeText: '${customRisks.length}',
                      ),
                      const SizedBox(height: 8.0),
                      if (customRisks.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: Text(
                            'Belum ada risiko kustom ditambahkan.',
                            style: GoogleFonts.inter(
                              fontSize: 13.0,
                              color: AppColors.muted,
                            ),
                          ),
                        )
                      else
                        for (int i = 0; i < customRisks.length; i++)
                          _buildCustomRiskItem(
                            name: customRisks[i],
                            onDelete: () => _controller.removeCustomRisk(i),
                          ),

                      const SizedBox(height: 12.0),
                      _buildAddCustomRiskInput(),
                      const SizedBox(height: 16.0),
                    ],
                  );
                },
              ),
            ),

            // Bottom Bar
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: SafeArea(
                top: false,
                child: SignalBuilder(
                  builder: (context) {
                    final isLoading = _controller.saveState.value is UiLoading;
                    return SizedBox(
                      width: double.infinity,
                      height: 48.0,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _handleSave,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.brand,
                          foregroundColor: Colors.white,
                          shape: const RoundedRectangleBorder(
                            borderRadius: AppRadius.borderMd,
                          ),
                          elevation: 0,
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 20.0,
                                height: 20.0,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.0,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Text(
                                'Simpan Penilaian',
                                style: GoogleFonts.inter(
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
    required String badgeText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                ),
              ),
            ),
            AppBadge.neutral(text: badgeText),
          ],
        ),
        const SizedBox(height: 2.0),
        Text(
          subtitle,
          style: GoogleFonts.inter(
            fontSize: 12.0,
            fontWeight: FontWeight.w400,
            color: AppColors.muted,
          ),
        ),
      ],
    );
  }

  Widget _buildRiskCheckboxTile({
    required String title,
    required bool isSelected,
    required ValueChanged<bool?> onChanged,
  }) {
    return InkWell(
      onTap: () => onChanged(!isSelected),
      borderRadius: AppRadius.borderMd,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 24.0,
              height: 24.0,
              child: Checkbox(
                value: isSelected,
                onChanged: onChanged,
                activeColor: AppColors.brand,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.0),
                ),
              ),
            ),
            const SizedBox(width: 10.0),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 2.0),
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 13.5,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected ? AppColors.text : AppColors.sec,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomRiskItem({
    required String name,
    required VoidCallback onDelete,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6.0),
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: AppColors.subtle,
        borderRadius: AppRadius.borderMd,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            size: 16.0,
            color: AppColors.brand,
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              name,
              style: GoogleFonts.inter(
                fontSize: 13.0,
                fontWeight: FontWeight.w500,
                color: AppColors.text,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.delete_outline_rounded,
              size: 18.0,
              color: AppColors.err,
            ),
            tooltip: 'Hapus Risiko Kustom',
            onPressed: onDelete,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            splashRadius: 18.0,
          ),
        ],
      ),
    );
  }

  Widget _buildAddCustomRiskInput() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _customRiskTextController,
            decoration: InputDecoration(
              hintText: 'Tambah risiko kustom...',
              hintStyle: GoogleFonts.inter(
                fontSize: 13.0,
                color: AppColors.muted,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 10.0,
              ),
              border: const OutlineInputBorder(
                borderRadius: AppRadius.borderMd,
                borderSide: BorderSide(color: AppColors.border),
              ),
              enabledBorder: const OutlineInputBorder(
                borderRadius: AppRadius.borderMd,
                borderSide: BorderSide(color: AppColors.border),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius: AppRadius.borderMd,
                borderSide: BorderSide(color: AppColors.brand, width: 1.5),
              ),
            ),
            style: GoogleFonts.inter(fontSize: 13.0, color: AppColors.text),
            onSubmitted: (_) => _handleAddCustomRisk(),
          ),
        ),
        const SizedBox(width: 8.0),
        FilledButton.icon(
          onPressed: _handleAddCustomRisk,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.brand,
            padding: const EdgeInsets.symmetric(
              horizontal: 14.0,
              vertical: 12.0,
            ),
            shape: const RoundedRectangleBorder(
              borderRadius: AppRadius.borderMd,
            ),
          ),
          icon: const Icon(Icons.add, size: 16.0),
          label: Text(
            'Tambah',
            style: GoogleFonts.inter(
              fontSize: 13.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
