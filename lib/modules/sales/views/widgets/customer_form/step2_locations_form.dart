import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:signals/signals_flutter.dart';
import 'package:centrow_sales/shared/theme/app_colors.dart';
import 'package:centrow_sales/shared/theme/app_radius.dart';
import 'package:centrow_sales/shared/widgets/app_badge.dart';
import 'package:centrow_sales/modules/sales/controllers/customer_form_controller.dart';
import 'package:centrow_sales/modules/sales/entities/create_customer_input.dart';
import 'package:centrow_sales/modules/sales/views/widgets/customer_form/region_picker.dart';
import 'package:centrow_sales/modules/sales/views/widgets/customer_form/map_picker_dialog.dart';

class Step2LocationsForm extends StatelessWidget {
  final CustomerFormController controller;

  const Step2LocationsForm({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Watch.builder(
      builder: (context) {
        final list = controller.locations.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // List of Repeatable Cards
            for (var i = 0; i < list.length; i++) ...[
              _buildLocationCard(context, index: i, item: list[i]),
              const SizedBox(height: 16.0),
            ],

            // Add Location Button
            InkWell(
              onTap: () => controller.addLocation(),
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
                      Icons.add_location_alt_outlined,
                      size: 18.0,
                      color: AppColors.brand,
                    ),
                    const SizedBox(width: 8.0),
                    Text(
                      '+ Tambah Alamat / Titik Servis Lain',
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
          ],
        );
      },
    );
  }

  Widget _buildLocationCard(
    BuildContext context, {
    required int index,
    required CreateLocationInput item,
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
                    ? const AppBadge.brand(text: 'Lokasi Utama')
                    : const AppBadge.neutral(text: 'Sekunder'),
                const SizedBox(width: 10.0),
                Expanded(
                  child: Text(
                    'Titik Servis #${index + 1} (${item.label.isNotEmpty ? item.label : "Tanpa Label"})',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (controller.locations.value.length > 1)
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      size: 20.0,
                      color: AppColors.err,
                    ),
                    tooltip: 'Hapus Alamat Ini',
                    onPressed: () => controller.removeLocation(index),
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
                // Row 1: Label & Alamat
                _buildFieldRow(
                  context,
                  left: _buildTextField(
                    label: 'Label Nama Lokasi',
                    isRequired: true,
                    value: item.label,
                    hint: 'cth: Main Resort / Warehouse',
                    onChanged: (v) => controller.updateLocation(
                      index,
                      item.copyWith(label: v),
                    ),
                  ),
                  right: Column(
                    children: [
                      _buildTextField(
                        label: 'Alamat Lengkap',
                        isRequired: true,
                        value: item.address,
                        hint: 'cth: Jalan Pantai Kuta, Badung',
                        onChanged: (v) => controller.updateLocation(
                          index,
                          item.copyWith(address: v),
                        ),
                        suffixIcon: IconButton(
                          tooltip: 'Cari di Peta',
                          icon: const Icon(Icons.map_outlined, color: AppColors.brand),
                          onPressed: () async {
                            final result = await Navigator.of(context).push<dynamic>(
                              MaterialPageRoute(builder: (_) => const MapPickerDialog()),
                            );
                            if (result != null && result is MapLocationResult) {
                              controller.applyMapLocation(index, result.lat, result.lng, result.address, result.province, result.regency, result.district, result.village);
                            }
                          },
                        ),
                      ),
                      if (item.latitude != null && item.longitude != null)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Lat: ${item.latitude}, Lng: ${item.longitude}',
                            style: GoogleFonts.inter(
                              fontSize: 12.0,
                              color: AppColors.muted,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 14.0),

                // Region Picker (Provinsi, Kabupaten/Kota, Kecamatan, Kelurahan/Desa)
                RegionPicker(
                  item: item,
                  onChanged: (updatedItem) =>
                      controller.updateLocation(index, updatedItem),
                ),
                const SizedBox(height: 14.0),

                // Row 3: Luas Area Properti
                _buildTextField(
                  label: 'Luas Area Properti',
                  value: item.areaSize != null
                      ? (item.areaSize! % 1 == 0
                            ? item.areaSize!.toInt().toString()
                            : item.areaSize!.toString())
                      : '',
                  hint: 'cth: 2500',
                  keyboardType: TextInputType.number,
                  onChanged: (v) => controller.updateLocation(
                    index,
                    item.copyWith(areaSize: double.tryParse(v)),
                  ),
                ),
                const SizedBox(height: 14.0),

                // Primary Toggle
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tandai sebagai Lokasi Servis & Penagihan Utama',
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
                          controller.setPrimaryLocation(index);
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

  Widget _buildTextField({
    required String label,
    bool isRequired = false,
    String? hint,
    required String value,
    TextInputType keyboardType = TextInputType.text,
    required ValueChanged<String> onChanged,
    Widget? suffixIcon,
  }) {
    return _ControlledTextField(
      label: label,
      isRequired: isRequired,
      hint: hint,
      value: value,
      keyboardType: keyboardType,
      onChanged: onChanged,
      suffixIcon: suffixIcon,
    );
  }
}

class _ControlledTextField extends StatefulWidget {
  final String label;
  final bool isRequired;
  final String? hint;
  final String value;
  final TextInputType keyboardType;
  final ValueChanged<String> onChanged;
  final Widget? suffixIcon;

  const _ControlledTextField({
    required this.label,
    this.isRequired = false,
    this.hint,
    required this.value,
    this.keyboardType = TextInputType.text,
    required this.onChanged,
    this.suffixIcon,
  });

  @override
  State<_ControlledTextField> createState() => _ControlledTextFieldState();
}

class _ControlledTextFieldState extends State<_ControlledTextField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant _ControlledTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value && _controller.text != widget.value) {
      _controller.value = _controller.value.copyWith(
        text: widget.value,
        selection: TextSelection.collapsed(offset: widget.value.length),
        composing: TextRange.empty,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              widget.label,
              style: GoogleFonts.inter(
                fontSize: 13.0,
                fontWeight: FontWeight.w600,
                color: AppColors.sec,
              ),
            ),
            if (widget.isRequired) ...[
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
          controller: _controller,
          keyboardType: widget.keyboardType,
          onChanged: widget.onChanged,
          style: GoogleFonts.inter(
            fontSize: 14.0,
            color: AppColors.text,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: GoogleFonts.inter(
              fontSize: 14.0,
              color: AppColors.muted,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14.0,
              vertical: 10.0,
            ),
            suffixIcon: widget.suffixIcon,
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
}
