import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:centrow_sales/app/di.dart';
import 'package:centrow_sales/modules/sales/entities/site_risk.dart';
import 'package:centrow_sales/modules/sales/repositories/site_risk_repository.dart';
import 'package:centrow_sales/shared/result/result.dart';
import 'package:centrow_sales/shared/theme/app_colors.dart';
import 'package:centrow_sales/shared/theme/app_radius.dart';
import 'package:centrow_sales/shared/widgets/app_badge.dart';
import 'package:centrow_sales/shared/widgets/error_view.dart';

class CustomerFormSiteRiskSheet extends StatefulWidget {
  final List<String> initialSiteRiskIds;
  final List<String> initialCustomRisks;
  final void Function(List<String> siteRiskIds, List<String> customRisks)
  onApply;
  final SiteRiskRepository? repository;

  const CustomerFormSiteRiskSheet({
    super.key,
    required this.initialSiteRiskIds,
    required this.initialCustomRisks,
    required this.onApply,
    this.repository,
  });

  @override
  State<CustomerFormSiteRiskSheet> createState() =>
      _CustomerFormSiteRiskSheetState();
}

class _CustomerFormSiteRiskSheetState extends State<CustomerFormSiteRiskSheet> {
  late final SiteRiskRepository _repository;
  final TextEditingController _customRiskTextController =
      TextEditingController();

  late Set<String> _selectedSiteRiskIds;
  late List<String> _customRisks;

  bool _isLoading = true;
  String? _errorMessage;
  List<SiteRiskMaster> _masterRisks = [];

  @override
  void initState() {
    super.initState();
    _selectedSiteRiskIds = widget.initialSiteRiskIds.toSet();
    _customRisks = List<String>.from(widget.initialCustomRisks);
    _repository =
        widget.repository ??
        (getIt.isRegistered<SiteRiskRepository>()
            ? getIt<SiteRiskRepository>()
            : const _DefaultSiteRiskRepo());
    _loadMasterRisks();
  }

  @override
  void dispose() {
    _customRiskTextController.dispose();
    super.dispose();
  }

  Future<void> _loadMasterRisks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _repository.getMasterRisks();
    if (!mounted) return;

    switch (result) {
      case Ok(:final value):
        setState(() {
          _masterRisks = value;
          _isLoading = false;
        });
      case Err(:final failure):
        setState(() {
          _errorMessage = failure.message;
          _isLoading = false;
        });
    }
  }

  void _toggleMasterRisk(String id) {
    setState(() {
      if (_selectedSiteRiskIds.contains(id)) {
        _selectedSiteRiskIds.remove(id);
      } else {
        _selectedSiteRiskIds.add(id);
      }
    });
  }

  void _handleAddCustomRisk() {
    final text = _customRiskTextController.text.trim();
    if (text.isEmpty || text.length > 255) return;
    if (!_customRisks.contains(text)) {
      setState(() {
        _customRisks.add(text);
      });
      _customRiskTextController.clear();
    }
  }

  void _handleRemoveCustomRisk(int index) {
    if (index < 0 || index >= _customRisks.length) return;
    setState(() {
      _customRisks.removeAt(index);
    });
  }

  void _handleApply() {
    widget.onApply(_selectedSiteRiskIds.toList(), _customRisks.toList());
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
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
                          'Site Risk Assessment (SRA)',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w700,
                            color: AppColors.text,
                          ),
                        ),
                        const SizedBox(height: 2.0),
                        Text(
                          'Pilih potensi risiko bahaya keselamatan kerja di lokasi servis ini.',
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

            // Body
            Expanded(child: _buildBody()),

            // Bottom Bar
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  width: double.infinity,
                  height: 48.0,
                  child: ElevatedButton(
                    key: const Key('sra_apply_button'),
                    onPressed: _handleApply,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brand,
                      foregroundColor: Colors.white,
                      shape: const RoundedRectangleBorder(
                        borderRadius: AppRadius.borderMd,
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Terapkan',
                      style: GoogleFonts.inter(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: ErrorView(message: _errorMessage!, onRetry: _loadMasterRisks),
      );
    }

    final masterList = _masterRisks;
    final masterIds = masterList.map((m) => m.id).toSet();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      children: [
        // Section 1: Master Risks
        _buildSectionHeader(
          title: 'Daftar Risiko Standar (Master)',
          subtitle:
              'Pilih bahaya keselamatan yang teridentifikasi di lokasi ini',
          badgeText:
              '${_selectedSiteRiskIds.intersection(masterIds).length}/${masterList.length}',
        ),
        const SizedBox(height: 8.0),
        if (masterList.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'Tidak ada daftar risiko standar.',
              style: GoogleFonts.inter(fontSize: 13.0, color: AppColors.muted),
            ),
          )
        else
          for (final item in masterList)
            _buildRiskCheckboxTile(
              title: item.name,
              isSelected: _selectedSiteRiskIds.contains(item.id),
              onChanged: (_) => _toggleMasterRisk(item.id),
            ),

        // Section 2: Custom Risks
        const SizedBox(height: 20.0),
        _buildSectionHeader(
          title: 'Risiko Kustom Tambahan',
          subtitle: 'Tambahkan bahaya atau kendala spesifik lokasi lainnya',
          badgeText: '${_customRisks.length}',
        ),
        const SizedBox(height: 8.0),
        if (_customRisks.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: Text(
              'Belum ada risiko kustom ditambahkan.',
              style: GoogleFonts.inter(fontSize: 13.0, color: AppColors.muted),
            ),
          )
        else
          for (int i = 0; i < _customRisks.length; i++)
            _buildCustomRiskItem(
              name: _customRisks[i],
              onDelete: () => _handleRemoveCustomRisk(i),
            ),

        const SizedBox(height: 12.0),
        _buildAddCustomRiskInput(),
        const SizedBox(height: 16.0),
      ],
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

class _DefaultSiteRiskRepo implements SiteRiskRepository {
  const _DefaultSiteRiskRepo();

  @override
  Future<Result<List<SiteRiskMaster>>> getSiteRiskMasters() async =>
      const Ok([]);

  @override
  Future<Result<List<CustomerAddressRisk>>> getAddressRisks({
    required String customerId,
    required String addressId,
  }) async => const Ok([]);

  @override
  Future<Result<List<CustomerAddressRisk>>> updateAddressRisks({
    required String customerId,
    required String addressId,
    required List<String> siteRiskIds,
    required List<String> customRisks,
  }) async => const Ok([]);
}
