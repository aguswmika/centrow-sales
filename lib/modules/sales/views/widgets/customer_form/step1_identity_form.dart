import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:centrow_sales/shared/theme/app_colors.dart';
import 'package:centrow_sales/shared/theme/app_radius.dart';
import 'package:centrow_sales/modules/sales/controllers/customer_form_controller.dart';
import 'package:centrow_sales/modules/sales/entities/segment.dart';
import 'package:signals/signals_flutter.dart';

class Step1IdentityForm extends StatelessWidget {
  final CustomerFormController controller;

  const Step1IdentityForm({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Watch.builder(
      builder: (context) {
        final segmentState = controller.segmentsState.value;
        final segmentList = segmentState.dataOrNull ?? <Segment>[];
        final isSegmentsLoading =
            segmentState.isLoading || segmentState.isInitial;
        final isSegmentDisabled = isSegmentsLoading || segmentList.isEmpty;

        final currentSegmentId = !isSegmentDisabled &&
                controller.segmentId.value.isNotEmpty &&
                segmentList.any((s) => s.id == controller.segmentId.value)
            ? controller.segmentId.value
            : null;

        final segmentHint = isSegmentsLoading
            ? 'Memuat segmen...'
            : (segmentList.isEmpty ? 'Tidak ada segmen' : 'Pilih Segmen Usaha');

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
        // Section 1: Identitas Pelanggan
        _buildSectionCard(
          icon: Icons.business_rounded,
          title: 'Identitas Pelanggan',
          children: [
            _buildFieldRow(
              context,
              left: _buildTextField(
                label: 'Nama Pelanggan / Entitas Usaha',
                isRequired: true,
                hint: 'cth: Villa Bali Resort',
                value: controller.name.value,
                onChanged: (v) => controller.name.value = v,
              ),
              right: _buildDropdownField<String>(
                label: 'Segmen Usaha',
                isRequired: true,
                hint: segmentHint,
                value: currentSegmentId,
                items: segmentList
                    .map(
                      (s) => DropdownMenuItem<String>(
                        value: s.id,
                        child: Text(
                          s.name,
                          style: GoogleFonts.inter(
                            fontSize: 14.0,
                            color: AppColors.text,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: isSegmentDisabled
                    ? null
                    : (v) {
                        if (v != null) {
                          controller.segmentId.value = v;
                          final match = segmentList.firstWhere(
                            (s) => s.id == v,
                            orElse: () => segmentList.first,
                          );
                          controller.segment.value = match.name;
                        }
                      },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16.0),

        // Section 2: Legalitas & Kontak Bisnis
        _buildSectionCard(
          icon: Icons.receipt_long_rounded,
          title: 'Legalitas & Kontak Bisnis',
          children: [
            _buildTextField(
              label: 'Nomor NPWP Badan / Pribadi',
              hint: '00.000.000.0-000.000',
              value: controller.npwp.value,
              onChanged: (v) => controller.npwp.value = v,
            ),
            const SizedBox(height: 16.0),
            _buildFieldRow(
              context,
              left: _buildTextField(
                label: 'Telepon Utama Perusahaan',
                isRequired: true,
                hint: '+62 812-xxxx-xxxx',
                keyboardType: TextInputType.phone,
                value: controller.phone.value,
                onChanged: (v) => controller.phone.value = v,
              ),
              right: _buildTextField(
                label: 'Telepon Alternatif',
                hint: '+62 811-xxxx-xxxx',
                keyboardType: TextInputType.phone,
                value: controller.phoneAlt.value,
                onChanged: (v) => controller.phoneAlt.value = v,
              ),
            ),
            const SizedBox(height: 16.0),
            _buildTextField(
              label: 'Email Resmi Bisnis',
              hint: 'contact@customer.com',
              keyboardType: TextInputType.emailAddress,
              value: controller.email.value,
              onChanged: (v) => controller.email.value = v,
            ),
          ],
        ),
        const SizedBox(height: 16.0),

        // Section 3: Catatan Internal & Risiko
        _buildSectionCard(
          icon: Icons.edit_note_rounded,
          title: 'Catatan Internal & Risiko',
          children: [
            _buildTextField(
              label: 'Site Risk Assessment',
              hint:
                  'Catatan kredit, komplain sebelumnya, atau syarat termin khusus…',
              maxLines: 3,
              value: controller.riskNotes.value,
              onChanged: (v) => controller.riskNotes.value = v,
            ),
            const SizedBox(height: 16.0),
            _buildTextField(
              label: 'Catatan Operasional & Akses Layanan',
              hint:
                  'Preferensi hari servis, akses gerbang, protokol keamanan lokasi…',
              maxLines: 3,
              value: controller.notes.value,
              onChanged: (v) => controller.notes.value = v,
            ),
          ],
        ),
        if (controller.customerId.value != null) ...[
          const SizedBox(height: 16.0),
          _buildSectionCard(
            icon: Icons.toggle_on_rounded,
            title: 'Status Pelanggan',
            children: [
              _buildDropdownField<String>(
                label: 'Status Pelanggan',
                isRequired: true,
                value: controller.status.value.toLowerCase() == 'inactive'
                    ? 'inactive'
                    : 'active',
                items: [
                  DropdownMenuItem<String>(
                    value: 'active',
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8.0,
                          height: 8.0,
                          decoration: const BoxDecoration(
                            color: AppColors.ok,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        Text(
                          'Aktif',
                          style: GoogleFonts.inter(
                            fontSize: 14.0,
                            color: AppColors.text,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  DropdownMenuItem<String>(
                    value: 'inactive',
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8.0,
                          height: 8.0,
                          decoration: const BoxDecoration(
                            color: AppColors.muted,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        Text(
                          'Non-Aktif',
                          style: GoogleFonts.inter(
                            fontSize: 14.0,
                            color: AppColors.text,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                onChanged: (v) {
                  if (v != null) {
                    controller.status.value = v;
                  }
                },
              ),
            ],
          ),
        ],
        const SizedBox(height: 24.0),
      ],
    );
      },
    );
  }

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
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
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 18.0,
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
                Icon(icon, size: 16.0, color: AppColors.brand),
                const SizedBox(width: 10.0),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15.0,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
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
            children: [left, const SizedBox(height: 16.0), right],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: left),
            const SizedBox(width: 16.0),
            Expanded(child: right),
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
    int maxLines = 1,
    TextInputType? keyboardType,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 13.0,
                  fontWeight: FontWeight.w600,
                  color: AppColors.sec,
                ),
                overflow: TextOverflow.ellipsis,
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
          maxLines: maxLines,
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
            contentPadding: EdgeInsets.symmetric(
              horizontal: 14.0,
              vertical: maxLines > 1 ? 12.0 : 10.0,
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
    ValueChanged<T?>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 13.0,
                  fontWeight: FontWeight.w600,
                  color: AppColors.sec,
                ),
                overflow: TextOverflow.ellipsis,
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
