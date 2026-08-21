import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:centrow_sales/shared/theme/app_colors.dart';
import 'package:centrow_sales/shared/theme/app_radius.dart';
import 'package:centrow_sales/shared/widgets/app_badge.dart';
import 'package:centrow_sales/shared/widgets/app_segmented_control.dart';
import 'package:centrow_sales/modules/sales/entities/proposal.dart';

class ProposalMasterList extends StatelessWidget {
  final List<Proposal> proposals;
  final String selectedProposalId;
  final String selectedStatus;
  final String searchQuery;
  final ValueChanged<String> onSelectProposal;
  final ValueChanged<String> onSelectStatus;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback? onCreateProposal;
  final Future<void> Function()? onRefresh;

  const ProposalMasterList({
    super.key,
    required this.proposals,
    required this.selectedProposalId,
    required this.selectedStatus,
    required this.searchQuery,
    required this.onSelectProposal,
    required this.onSelectStatus,
    required this.onSearchChanged,
    this.onCreateProposal,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      child: Column(
        children: [
          _buildHeader(context),
          const Divider(height: 1.0, thickness: 1.0, color: AppColors.border),
          Expanded(child: _buildList()),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 14.0, 16.0, 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Daftar Proposal',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 17.0,
              fontWeight: FontWeight.w800,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 2.0),
          Text(
            '${proposals.length} proposal aktif dalam pipeline penawaran',
            style: GoogleFonts.inter(
              fontSize: 12.0,
              fontWeight: FontWeight.w500,
              color: AppColors.muted,
            ),
          ),
          const SizedBox(height: 10.0),
          Row(
            children: [
              Expanded(
                child: Container(
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
                      hintText: 'Cari nama klien, kode proposal…',
                      hintStyle: GoogleFonts.inter(
                        fontSize: 13.0,
                        color: AppColors.muted,
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        size: 18.0,
                        color: AppColors.muted,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 10.0,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8.0),
              InkWell(
                onTap: onCreateProposal,
                borderRadius: AppRadius.borderMd,
                child: Container(
                  width: 42.0,
                  height: 42.0,
                  decoration: const BoxDecoration(
                    color: AppColors.brand,
                    borderRadius: AppRadius.borderMd,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x331E40AF),
                        offset: Offset(0, 2),
                        blurRadius: 6.0,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.add_rounded,
                      color: Colors.white,
                      size: 22.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10.0),
          AppSegmentedControl<String>(
            items: const [
              SegmentItem<String>(label: 'Semua', value: 'all'),
              SegmentItem<String>(label: 'Draft', value: 'Draft'),
              SegmentItem<String>(label: 'Dikirim', value: 'Dikirim'),
              SegmentItem<String>(label: 'Nego', value: 'Negosiasi'),
              SegmentItem<String>(label: 'Setuju', value: 'Disetujui'),
            ],
            selectedValue: selectedStatus,
            onValueChanged: onSelectStatus,
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    final Widget content;
    if (proposals.isEmpty) {
      content = CustomScrollView(
        slivers: [
          SliverFillRemaining(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.description_outlined,
                      size: 40.0,
                      color: AppColors.muted,
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      'Tidak ada proposal yang ditemukan',
                      style: GoogleFonts.inter(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      content = ListView.separated(
        padding: EdgeInsets.zero,
        itemCount: proposals.length,
        separatorBuilder: (context, index) =>
            const Divider(height: 1.0, thickness: 1.0, color: AppColors.border),
        itemBuilder: (context, index) {
          final p = proposals[index];
          final isSelected =
              p.id == selectedProposalId || p.code == selectedProposalId;
          final (avatarBg, avatarFg) = _getAvatarColors(p.status);

          return InkWell(
            onTap: () => onSelectProposal(p.id),
            child: Container(
              color: isSelected ? AppColors.brand05 : Colors.transparent,
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      width: 3.5,
                      color: isSelected ? AppColors.brand : Colors.transparent,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14.0,
                          vertical: 12.0,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40.0,
                              height: 40.0,
                              decoration: BoxDecoration(
                                color: avatarBg,
                                borderRadius: AppRadius.borderMd,
                              ),
                              child: Center(
                                child: Text(
                                  p.initials,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.w800,
                                    color: avatarFg,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12.0),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    p.clientName,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.text,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2.0),
                                  RichText(
                                    overflow: TextOverflow.ellipsis,
                                    text: TextSpan(
                                      style: GoogleFonts.inter(
                                        fontSize: 11.5,
                                        color: AppColors.muted,
                                      ),
                                      children: [
                                        TextSpan(text: '${p.code} · '),
                                        TextSpan(
                                          text: p.serviceName,
                                          style: GoogleFonts.inter(
                                            color: AppColors.sec,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8.0),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                AppBadge.fromType(
                                  p.status.badgeType,
                                  p.status.displayName,
                                ),
                                const SizedBox(height: 4.0),
                                Text(
                                  p.shortAmount,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.text,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    }

    if (onRefresh == null) return content;
    return RefreshIndicator(
      onRefresh: onRefresh!,
      color: AppColors.brand,
      child: content,
    );
  }

  (Color, Color) _getAvatarColors(ProposalStatus status) {
    switch (status) {
      case ProposalStatus.dikirim:
        return (AppColors.brand10, AppColors.brand);
      case ProposalStatus.negosiasi:
        return (const Color(0x24BC7B43), const Color(0xFF92580F));
      case ProposalStatus.draft:
        return (const Color(0x248C8E8B), AppColors.sec);
      case ProposalStatus.disetujui:
        return (const Color(0x1F10B981), const Color(0xFF059669));
      case ProposalStatus.ditolak:
        return (const Color(0x1FEF4444), const Color(0xFFDC2626));
    }
  }
}
