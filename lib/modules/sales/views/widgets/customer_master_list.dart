import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_radius.dart';
import '../../../../shared/widgets/app_badge.dart';
import '../../../../shared/widgets/app_segmented_control.dart';
import '../../entities/customer.dart';
import '../../entities/segment.dart';

class CustomerMasterList extends StatelessWidget {
  final List<Customer> customers;
  final List<Segment> segments;
  final String selectedCustomerId;
  final String selectedSegment;
  final String searchQuery;
  final ValueChanged<String> onSelectCustomer;
  final ValueChanged<String> onSelectSegment;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback? onAddCustomer;
  final Future<void> Function()? onRefresh;

  const CustomerMasterList({
    super.key,
    required this.customers,
    required this.segments,
    required this.selectedCustomerId,
    required this.selectedSegment,
    required this.searchQuery,
    required this.onSelectCustomer,
    required this.onSelectSegment,
    required this.onSearchChanged,
    this.onAddCustomer,
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
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Daftar Pelanggan',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16.5,
              fontWeight: FontWeight.w800,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 2.0),
          Text(
            '${customers.length} entitas pelanggan terdaftar',
            style: GoogleFonts.inter(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: AppColors.muted,
            ),
          ),
          const SizedBox(height: 12.0),
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
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                      color: AppColors.text,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Cari nama, kode, wilayah…',
                      hintStyle: GoogleFonts.inter(
                        fontSize: 13.5,
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
                onTap: onAddCustomer ?? () => context.push('/customers/create'),
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
          const SizedBox(height: 12.0),
          AppSegmentedControl<String>(
            items: [
              const SegmentItem<String>(label: 'Semua', value: 'all'),
              ...segments.map(
                (s) => SegmentItem<String>(label: s.name, value: s.id),
              ),
            ],
            selectedValue: selectedSegment,
            onValueChanged: onSelectSegment,
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    final Widget content;
    if (customers.isEmpty) {
      content = CustomScrollView(
        slivers: [
          SliverFillRemaining(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  'Tidak ada pelanggan',
                  style: GoogleFonts.inter(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.muted,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      content = ListView.separated(
        padding: EdgeInsets.zero,
        itemCount: customers.length,
        separatorBuilder: (context, index) =>
            const Divider(height: 1.0, thickness: 1.0, color: AppColors.border),
        itemBuilder: (context, index) {
          final c = customers[index];
          final isSelected = c.id == selectedCustomerId;
          final (avatarBg, avatarFg) = _getSegmentAvatarColors(c.segment);
          final isStatusActive =
              c.status.toLowerCase() == 'active' ||
              c.status.toLowerCase() == 'aktif';
          final regencyText = c.regency.isNotEmpty ? c.regency : '-';
          final initialsText = c.initials.isNotEmpty
              ? c.initials
              : (c.name.isNotEmpty
                    ? c.name
                          .substring(0, c.name.length >= 2 ? 2 : 1)
                          .toUpperCase()
                    : 'CP');

          return InkWell(
            onTap: () => onSelectCustomer(c.id),
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
                          vertical: 13.0,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44.0,
                              height: 44.0,
                              decoration: BoxDecoration(
                                color: avatarBg,
                                borderRadius: AppRadius.borderMd,
                              ),
                              child: Center(
                                child: Text(
                                  initialsText,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w700,
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
                                    c.name,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.text,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 3.0),
                                  Text(
                                    '${c.code} · ${c.segment} · $regencyText',
                                    style: GoogleFonts.inter(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.muted,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8.0),
                            isStatusActive
                                ? const AppBadge.ok(text: 'Aktif')
                                : const AppBadge.neutral(text: 'Non-Aktif'),
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

  (Color, Color) _getSegmentAvatarColors(String segment) {
    switch (segment.toLowerCase()) {
      case 'villa':
        return (AppColors.brand10, AppColors.brand);
      case 'hotel':
        return (const Color(0x1F10B981), const Color(0xFF059669));
      case 'restoran' || 'resto':
        return (const Color(0x24BC7B43), const Color(0xFF92580F));
      case 'komersial' || 'lainnya':
        return (const Color(0x1F8B5CF6), const Color(0xFF7C3AED));
      default:
        return (AppColors.brand10, AppColors.brand);
    }
  }
}
