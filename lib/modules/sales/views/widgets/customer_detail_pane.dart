import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_radius.dart';
import '../../../../shared/widgets/app_badge.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../entities/customer.dart';
import 'customer_contacts_tab.dart';
import 'customer_info_tab.dart';
import 'customer_locations_tab.dart';
import 'customer_proposals_tab.dart';

class CustomerDetailPane extends StatelessWidget {
  final Customer? customer;
  final int activeTab;
  final ValueChanged<int> onTabChanged;
  final VoidCallback? onAddProposal;
  final VoidCallback? onEditData;

  const CustomerDetailPane({
    super.key,
    required this.customer,
    required this.activeTab,
    required this.onTabChanged,
    this.onAddProposal,
    this.onEditData,
  });

  static const List<String> tabTitles = [
    'Informasi Utama',
    'Lokasi & Titik Servis',
    'Kontak Person & PIC',
    'Riwayat Proposal',
  ];

  @override
  Widget build(BuildContext context) {
    final c = customer;
    if (c == null) {
      return Center(
        child: Text(
          'Pilih pelanggan dari daftar di sebelah kiri',
          style: GoogleFonts.inter(
            fontSize: 14.0,
            fontWeight: FontWeight.w500,
            color: AppColors.muted,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(c),
        _buildTabBar(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 20.0,
            ),
            child: _buildActiveTabContent(c),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(Customer customer) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1.5)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 560;

          final identity = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50.0,
                height: 50.0,
                decoration: const BoxDecoration(
                  color: AppColors.brand10,
                  borderRadius: AppRadius.borderLg,
                ),
                child: Center(
                  child: Text(
                    customer.initials,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w800,
                      color: AppColors.brand,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14.0),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.name,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 17.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.text,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4.0),
                    Wrap(
                      spacing: 6.0,
                      runSpacing: 4.0,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        AppBadge.brand(text: customer.segment),
                        AppBadge.ok(text: customer.status),
                        Text(
                          customer.code,
                          style: GoogleFonts.inter(
                            fontSize: 12.0,
                            fontWeight: FontWeight.w600,
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );

          final actions = Wrap(
            spacing: 10.0,
            runSpacing: 8.0,
            children: [
              AppButton.secondary(
                text: 'Buat Proposal',
                height: 38.0,
                isFullWidth: false,
                borderRadius: AppRadius.borderPill,
                icon: const Icon(
                  Icons.description_outlined,
                  size: 15,
                  color: AppColors.text,
                ),
                onPressed: onAddProposal ?? () {},
              ),
              AppButton(
                text: 'Edit Data',
                height: 38.0,
                isFullWidth: false,
                borderRadius: AppRadius.borderPill,
                icon: const Icon(
                  Icons.edit_outlined,
                  size: 15,
                  color: Colors.white,
                ),
                onPressed: onEditData ?? () {},
              ),
            ],
          );

          if (isNarrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [identity, const SizedBox(height: 12.0), actions],
            );
          }

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: identity),
              const SizedBox(width: 16.0),
              actions,
            ],
          );
        },
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      height: 44.0,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1.5)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: List.generate(tabTitles.length, (index) {
            final isSelected = index == activeTab;
            return InkWell(
              onTap: () => onTabChanged(index),
              child: Container(
                height: 44.0,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isSelected ? AppColors.brand : Colors.transparent,
                      width: 2.5,
                    ),
                  ),
                ),
                child: Text(
                  tabTitles[index],
                  style: GoogleFonts.inter(
                    fontSize: 13.5,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? AppColors.brand : AppColors.muted,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildActiveTabContent(Customer customer) {
    switch (activeTab) {
      case 0:
        return CustomerInfoTab(customer: customer);
      case 1:
        return CustomerLocationsTab(locations: customer.locations);
      case 2:
        return CustomerContactsTab(contacts: customer.contacts);
      case 3:
        return CustomerProposalsTab(proposals: customer.proposals);
      default:
        return CustomerInfoTab(customer: customer);
    }
  }
}
