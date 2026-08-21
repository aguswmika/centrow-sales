import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:signals/signals_flutter.dart';
import 'package:centrow_sales/shared/theme/app_colors.dart';
import 'package:centrow_sales/shared/theme/app_radius.dart';
import 'package:centrow_sales/shared/widgets/app_badge.dart';
import 'package:centrow_sales/modules/sales/controllers/customer_form_controller.dart';
import 'package:centrow_sales/modules/sales/entities/create_customer_input.dart';
import 'package:centrow_sales/modules/sales/entities/customer.dart';

class Step3ContactsForm extends StatelessWidget {
  final CustomerFormController controller;
  final VoidCallback onPrev;
  final VoidCallback onSubmit;

  const Step3ContactsForm({
    super.key,
    required this.controller,
    required this.onPrev,
    required this.onSubmit,
  });

  static const List<CustomerContactRole> roleOptions = [
    CustomerContactRole.pic,
    CustomerContactRole.picBackup,
    CustomerContactRole.accounting,
    CustomerContactRole.signatory,
  ];

  @override
  Widget build(BuildContext context) {
    return Watch.builder(
      builder: (context) {
        final list = controller.contacts.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // List of Repeatable Contact Cards
            for (var i = 0; i < list.length; i++) ...[
              _buildContactCard(context, index: i, item: list[i]),
              const SizedBox(height: 16.0),
            ],

            // Add Contact Button
            InkWell(
              onTap: () => controller.addContact(),
              borderRadius: AppRadius.borderLg,
              child: Container(
                height: 48.0,
                decoration: BoxDecoration(
                  color: AppColors.brand05,
                  borderRadius: AppRadius.borderLg,
                  border: Border.all(
                    color: AppColors.brand,
                    width: 1.5,
                    strokeAlign: BorderSide.strokeAlignCenter,
                  ),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.person_add_alt_1_outlined,
                      size: 18.0,
                      color: AppColors.brand,
                    ),
                    const SizedBox(width: 8.0),
                    Text(
                      '+ Tambah Kontak Person Lain',
                      style: GoogleFonts.inter(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.brand,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24.0),
          ],
        );
      },
    );
  }

  Widget _buildContactCard(
    BuildContext context, {
    required int index,
    required CreateContactInput item,
  }) {
    final currentRole = CustomerContactRole.fromString(item.role);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderLg,
        border: Border.all(color: AppColors.border, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            offset: Offset(0, 1),
            blurRadius: 4.0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            decoration: const BoxDecoration(
              color: AppColors.subtle,
              border: Border(
                bottom: BorderSide(color: AppColors.border, width: 1.5),
              ),
            ),
            child: Row(
              children: [
                item.isPrimary
                    ? const AppBadge.brand(text: 'PIC Utama')
                    : const AppBadge.neutral(text: 'Sekunder'),
                const SizedBox(width: 10.0),
                Expanded(
                  child: Text(
                    'Kontak #${index + 1} (${item.name.isNotEmpty ? item.name : "Tanpa Nama"})',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (controller.contacts.value.length > 1)
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      size: 20.0,
                      color: AppColors.err,
                    ),
                    tooltip: 'Hapus Kontak Ini',
                    onPressed: () => controller.removeContact(index),
                  ),
              ],
            ),
          ),

          // Body
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Row 1: Nama & Jabatan
                _buildFieldRow(
                  context,
                  left: _buildTextField(
                    label: 'Nama Lengkap PIC',
                    isRequired: true,
                    value: item.name,
                    hint: 'cth: Budi Santoso',
                    onChanged: (v) =>
                        controller.updateContact(index, item.copyWith(name: v)),
                  ),
                  right: _buildTextField(
                    label: 'Jabatan / Posisi',
                    value: item.position,
                    hint: 'cth: General Manager',
                    onChanged: (v) => controller.updateContact(
                      index,
                      item.copyWith(position: v),
                    ),
                  ),
                ),
                const SizedBox(height: 14.0),

                // Row 2: Email, Phone, Peran PIC
                _buildFieldGrid3(
                  context,
                  c1: _buildTextField(
                    label: 'Email PIC',
                    value: item.email,
                    hint: 'cth: budi@customer.com',
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (v) => controller.updateContact(
                      index,
                      item.copyWith(email: v),
                    ),
                  ),
                  c2: _buildTextField(
                    label: 'Nomor HP / WhatsApp',
                    isRequired: true,
                    value: item.phone,
                    hint: '+62 812-3456-7890',
                    keyboardType: TextInputType.phone,
                    onChanged: (v) => controller.updateContact(
                      index,
                      item.copyWith(phone: v),
                    ),
                  ),
                  c3: _buildDropdownField<String>(
                    label: 'Peran PIC',
                    isRequired: true,
                    value: currentRole.value,
                    items: roleOptions
                        .map(
                          (r) => DropdownMenuItem<String>(
                            value: r.value,
                            child: Text(
                              r.displayName,
                              style: GoogleFonts.inter(
                                fontSize: 14.0,
                                color: AppColors.text,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      final selected = CustomerContactRole.fromString(
                        v ?? 'pic',
                      );
                      controller.updateContact(
                        index,
                        item.copyWith(role: selected.value),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 14.0),

                // Primary Toggle
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tandai sebagai Kontak Person Utama',
                      style: GoogleFonts.inter(
                        fontSize: 13.0,
                        fontWeight: FontWeight.w600,
                        color: AppColors.sec,
                      ),
                    ),
                    Switch.adaptive(
                      value: item.isPrimary,
                      activeTrackColor: AppColors.brand,
                      onChanged: (val) {
                        if (val) {
                          controller.setPrimaryContact(index);
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldRow(
    BuildContext context, {
    required Widget left,
    required Widget right,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [left, const SizedBox(height: 14.0), right],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: left),
            const SizedBox(width: 14.0),
            Expanded(child: right),
          ],
        );
      },
    );
  }

  Widget _buildFieldGrid3(
    BuildContext context, {
    required Widget c1,
    required Widget c2,
    required Widget c3,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 650) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              c1,
              const SizedBox(height: 14.0),
              c2,
              const SizedBox(height: 14.0),
              c3,
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: c1),
            const SizedBox(width: 12.0),
            Expanded(child: c2),
            const SizedBox(width: 12.0),
            Expanded(child: c3),
          ],
        );
      },
    );
  }

  Widget _buildTextField({
    required String label,
    bool isRequired = false,
    String? hint,
    String? value,
    TextInputType? keyboardType,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13.0,
                fontWeight: FontWeight.w600,
                color: AppColors.sec,
              ),
            ),
            if (isRequired) ...[
              const SizedBox(width: 4.0),
              Text(
                '*',
                style: GoogleFonts.inter(
                  fontSize: 13.0,
                  fontWeight: FontWeight.w700,
                  color: AppColors.err,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 6.0),
        TextFormField(
          initialValue: value,
          keyboardType: keyboardType,
          onChanged: onChanged,
          style: GoogleFonts.inter(
            fontSize: 14.0,
            color: AppColors.text,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(
              fontSize: 14.0,
              color: AppColors.muted,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14.0,
              vertical: 10.0,
            ),
            filled: true,
            fillColor: AppColors.surface,
            border: const OutlineInputBorder(
              borderRadius: AppRadius.borderMd,
              borderSide: BorderSide(color: AppColors.border, width: 1.5),
            ),
            enabledBorder: const OutlineInputBorder(
              borderRadius: AppRadius.borderMd,
              borderSide: BorderSide(color: AppColors.border, width: 1.5),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: AppRadius.borderMd,
              borderSide: BorderSide(color: AppColors.brand, width: 1.8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField<T>({
    required String label,
    bool isRequired = false,
    String? hint,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13.0,
                fontWeight: FontWeight.w600,
                color: AppColors.sec,
              ),
            ),
            if (isRequired) ...[
              const SizedBox(width: 4.0),
              Text(
                '*',
                style: GoogleFonts.inter(
                  fontSize: 13.0,
                  fontWeight: FontWeight.w700,
                  color: AppColors.err,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 6.0),
        DropdownButtonFormField<T>(
          initialValue: value,
          hint: hint != null
              ? Text(
                  hint,
                  style: GoogleFonts.inter(
                    fontSize: 14.0,
                    color: AppColors.muted,
                  ),
                )
              : null,
          isExpanded: true,
          items: items,
          onChanged: onChanged,
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.symmetric(
              horizontal: 14.0,
              vertical: 10.0,
            ),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: AppRadius.borderMd,
              borderSide: BorderSide(color: AppColors.border, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.borderMd,
              borderSide: BorderSide(color: AppColors.border, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadius.borderMd,
              borderSide: BorderSide(color: AppColors.brand, width: 1.8),
            ),
          ),
        ),
      ],
    );
  }
}
