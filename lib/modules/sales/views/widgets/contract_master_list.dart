import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:centrow_sales/shared/theme/app_colors.dart';
import 'package:centrow_sales/shared/theme/app_radius.dart';
import 'package:centrow_sales/shared/widgets/app_badge.dart';
import 'package:centrow_sales/shared/widgets/app_segmented_control.dart';
import 'package:centrow_sales/modules/sales/entities/contract.dart';

class ContractMasterList extends StatelessWidget {
  final List<Contract> contracts;
  final String selectedContractId;
  final String searchQuery;
  final int? selectedStatus;
  final ValueChanged<String> onSelectContract;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<int?> onStatusChanged;
  final Future<void> Function()? onRefresh;

  const ContractMasterList({
    super.key,
    required this.contracts,
    required this.selectedContractId,
    required this.searchQuery,
    required this.selectedStatus,
    required this.onSelectContract,
    required this.onSearchChanged,
    required this.onStatusChanged,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      child: Column(
        children: [
          _buildHeader(),
          const Divider(height: 1.0, thickness: 1.0, color: AppColors.border),
          Expanded(child: _buildList()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 14.0, 16.0, 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Daftar Kontrak',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 17.0,
              fontWeight: FontWeight.w800,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 2.0),
          Text(
            '${contracts.length} kontrak',
            style: GoogleFonts.inter(
              fontSize: 12.0,
              fontWeight: FontWeight.w500,
              color: AppColors.muted,
            ),
          ),
          const SizedBox(height: 10.0),
          _buildSearchBox(),
          const SizedBox(height: 10.0),
          _buildStatusFilters(),
        ],
      ),
    );
  }

  Widget _buildSearchBox() {
    return Container(
      height: 42.0,
      decoration: BoxDecoration(
        color: AppColors.subtle,
        borderRadius: AppRadius.borderMd,
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      child: TextField(
        onChanged: onSearchChanged,
        style: GoogleFonts.inter(
          fontSize: 13.0,
          fontWeight: FontWeight.w500,
          color: AppColors.text,
        ),
        decoration: InputDecoration(
          hintText: 'Cari kode atau nama klien…',
          hintStyle: GoogleFonts.inter(fontSize: 13.0, color: AppColors.muted),
          prefixIcon: const Icon(
            Icons.search_rounded,
            size: 18.0,
            color: AppColors.muted,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
        ),
      ),
    );
  }

  Widget _buildStatusFilters() {
    return AppSegmentedControl<int?>(
      isScrollable: true,
      items: const [
        SegmentItem<int?>(label: 'Semua', value: null),
        SegmentItem<int?>(label: 'Draf', value: 1),
        SegmentItem<int?>(label: 'Aktif', value: 2),
        SegmentItem<int?>(label: 'Ditangguhkan', value: 3),
        SegmentItem<int?>(label: 'Diterminasi', value: 5),
        SegmentItem<int?>(label: 'Dibatalkan', value: 6),
      ],
      selectedValue: selectedStatus,
      onValueChanged: onStatusChanged,
    );
  }

  Widget _buildList() {
    if (contracts.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.description_outlined,
              size: 48.0,
              color: AppColors.muted,
            ),
            const SizedBox(height: 12.0),
            Text(
              'Belum ada kontrak.',
              style: GoogleFonts.inter(
                fontSize: 14.0,
                fontWeight: FontWeight.w500,
                color: AppColors.muted,
              ),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: onRefresh ?? () async {},
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        itemCount: contracts.length,
        separatorBuilder: (context, index) =>
            const Divider(height: 1.0, thickness: 1.0, color: AppColors.border),
        itemBuilder: (context, index) {
          final contract = contracts[index];
          return _ContractListTile(
            contract: contract,
            isSelected: contract.id == selectedContractId,
            onTap: () => onSelectContract(contract.id),
          );
        },
      ),
    );
  }
}

class _ContractListTile extends StatelessWidget {
  final Contract contract;
  final bool isSelected;
  final VoidCallback onTap;

  const _ContractListTile({
    required this.contract,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final status = contract.status;
    final initials = contract.customerName.isNotEmpty
        ? contract.customerName.substring(0, 1).toUpperCase()
        : 'K';
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        color: isSelected
            ? AppColors.brand.withValues(alpha: 0.06)
            : Colors.transparent,
        child: Row(
          children: [
            Container(
              width: 36.0,
              height: 36.0,
              decoration: BoxDecoration(
                color: AppColors.brand.withValues(alpha: 0.10),
                borderRadius: AppRadius.borderMd,
              ),
              child: Center(
                child: Text(
                  initials,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w700,
                    color: AppColors.brand,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contract.customerName.isNotEmpty
                        ? contract.customerName
                        : contract.code,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    contract.code,
                    style: GoogleFonts.inter(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w500,
                      color: AppColors.muted,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8.0),
            AppBadge.fromType(status.badgeType, status.displayName),
          ],
        ),
      ),
    );
  }
}
