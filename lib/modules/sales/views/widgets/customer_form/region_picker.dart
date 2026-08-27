import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:centrow_sales/app/di.dart';
import 'package:centrow_sales/modules/core/entities/region.dart';
import 'package:centrow_sales/modules/core/repositories/region_repository.dart';
import 'package:centrow_sales/modules/sales/entities/create_customer_input.dart';
import 'package:centrow_sales/shared/theme/app_colors.dart';
import 'package:centrow_sales/shared/theme/app_radius.dart';

class RegionPicker extends StatefulWidget {
  final CreateLocationInput item;
  final ValueChanged<CreateLocationInput> onChanged;

  const RegionPicker({super.key, required this.item, required this.onChanged});

  @override
  State<RegionPicker> createState() => _RegionPickerState();
}

class _RegionPickerState extends State<RegionPicker> {
  final RegionRepository _regionRepository = getIt<RegionRepository>();

  List<Province> _provinces = [];
  List<Regency> _regencies = [];
  List<District> _districts = [];
  List<Village> _villages = [];

  bool _isLoadingProvinces = false;
  bool _isLoadingRegencies = false;
  bool _isLoadingDistricts = false;
  bool _isLoadingVillages = false;

  @override
  void initState() {
    super.initState();
    _fetchProvinces();
    _initCascadingData();
  }

  void _initCascadingData() {
    final provinceId = widget.item.provinceId;
    if (provinceId != null) {
      _fetchRegencies(provinceId);
      final regencyId = widget.item.regencyId;
      if (regencyId != null) {
        _fetchDistricts(provinceId, regencyId);
        final districtId = widget.item.districtId;
        if (districtId != null) {
          _fetchVillages(provinceId, regencyId, districtId);
        }
      }
    }
  }

  @override
  void didUpdateWidget(covariant RegionPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.item.provinceId != oldWidget.item.provinceId) {
      final provinceId = widget.item.provinceId;
      if (provinceId != null) {
        _fetchRegencies(provinceId);
      } else {
        setState(() {
          _regencies = [];
          _districts = [];
          _villages = [];
        });
      }
    }

    if (widget.item.regencyId != oldWidget.item.regencyId) {
      final provinceId = widget.item.provinceId;
      final regencyId = widget.item.regencyId;
      if (provinceId != null && regencyId != null) {
        _fetchDistricts(provinceId, regencyId);
      } else {
        setState(() {
          _districts = [];
          _villages = [];
        });
      }
    }

    if (widget.item.districtId != oldWidget.item.districtId) {
      final provinceId = widget.item.provinceId;
      final regencyId = widget.item.regencyId;
      final districtId = widget.item.districtId;
      if (provinceId != null && regencyId != null && districtId != null) {
        _fetchVillages(provinceId, regencyId, districtId);
      } else {
        setState(() {
          _villages = [];
        });
      }
    }
  }

  Future<void> _fetchProvinces() async {
    setState(() {
      _isLoadingProvinces = true;
    });
    final result = await _regionRepository.getProvinces();
    if (!mounted) return;
    setState(() {
      _isLoadingProvinces = false;
      if (result.isOk) {
        _provinces = result.valueOrNull ?? [];
      }
    });
  }

  Future<void> _fetchRegencies(int provinceId) async {
    setState(() {
      _isLoadingRegencies = true;
    });
    final result = await _regionRepository.getRegencies(provinceId);
    if (!mounted) return;
    setState(() {
      _isLoadingRegencies = false;
      if (result.isOk) {
        _regencies = result.valueOrNull ?? [];
      }
    });
  }

  Future<void> _fetchDistricts(int provinceId, int regencyId) async {
    setState(() {
      _isLoadingDistricts = true;
    });
    final result = await _regionRepository.getDistricts(provinceId, regencyId);
    if (!mounted) return;
    setState(() {
      _isLoadingDistricts = false;
      if (result.isOk) {
        _districts = result.valueOrNull ?? [];
      }
    });
  }

  Future<void> _fetchVillages(
    int provinceId,
    int regencyId,
    int districtId,
  ) async {
    setState(() {
      _isLoadingVillages = true;
    });
    final result = await _regionRepository.getVillages(
      provinceId,
      regencyId,
      districtId,
    );
    if (!mounted) return;
    setState(() {
      _isLoadingVillages = false;
      if (result.isOk) {
        _villages = result.valueOrNull ?? [];
      }
    });
  }

  void _onProvinceChanged(int provinceId) {
    final province = _provinces.firstWhere(
      (p) => p.id == provinceId,
      orElse: () => Province(id: provinceId, name: ''),
    );
    setState(() {
      _regencies = [];
      _districts = [];
      _villages = [];
    });
    widget.onChanged(
      CreateLocationInput(
        label: widget.item.label,
        address: widget.item.address,
        provinceId: provinceId,
        regencyId: null,
        districtId: null,
        villageId: null,
        province: province.name,
        regency: '',
        district: '',
        village: '',
        areaSize: widget.item.areaSize,
        latitude: widget.item.latitude,
        longitude: widget.item.longitude,
        isPrimary: widget.item.isPrimary,
      ),
    );
  }

  void _onRegencyChanged(int regencyId) {
    final regency = _regencies.firstWhere(
      (r) => r.id == regencyId,
      orElse: () => Regency(id: regencyId, name: ''),
    );
    setState(() {
      _districts = [];
      _villages = [];
    });
    widget.onChanged(
      CreateLocationInput(
        label: widget.item.label,
        address: widget.item.address,
        provinceId: widget.item.provinceId,
        regencyId: regencyId,
        districtId: null,
        villageId: null,
        province: widget.item.province,
        regency: regency.name,
        district: '',
        village: '',
        areaSize: widget.item.areaSize,
        latitude: widget.item.latitude,
        longitude: widget.item.longitude,
        isPrimary: widget.item.isPrimary,
      ),
    );
  }

  void _onDistrictChanged(int districtId) {
    final district = _districts.firstWhere(
      (d) => d.id == districtId,
      orElse: () => District(id: districtId, name: ''),
    );
    setState(() {
      _villages = [];
    });
    widget.onChanged(
      CreateLocationInput(
        label: widget.item.label,
        address: widget.item.address,
        provinceId: widget.item.provinceId,
        regencyId: widget.item.regencyId,
        districtId: districtId,
        villageId: null,
        province: widget.item.province,
        regency: widget.item.regency,
        district: district.name,
        village: '',
        areaSize: widget.item.areaSize,
        latitude: widget.item.latitude,
        longitude: widget.item.longitude,
        isPrimary: widget.item.isPrimary,
      ),
    );
  }

  void _onVillageChanged(int villageId) {
    final village = _villages.firstWhere(
      (v) => v.id == villageId,
      orElse: () => Village(id: villageId, name: ''),
    );
    widget.onChanged(
      CreateLocationInput(
        label: widget.item.label,
        address: widget.item.address,
        provinceId: widget.item.provinceId,
        regencyId: widget.item.regencyId,
        districtId: widget.item.districtId,
        villageId: villageId,
        province: widget.item.province,
        regency: widget.item.regency,
        district: widget.item.district,
        village: village.name,
        areaSize: widget.item.areaSize,
        latitude: widget.item.latitude,
        longitude: widget.item.longitude,
        isPrimary: widget.item.isPrimary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedProvinceId =
        _provinces.any((p) => p.id == widget.item.provinceId)
        ? widget.item.provinceId
        : null;
    final selectedRegencyId =
        _regencies.any((r) => r.id == widget.item.regencyId)
        ? widget.item.regencyId
        : null;
    final selectedDistrictId =
        _districts.any((d) => d.id == widget.item.districtId)
        ? widget.item.districtId
        : null;
    final selectedVillageId =
        _villages.any((v) => v.id == widget.item.villageId)
        ? widget.item.villageId
        : null;

    final isProvinceDisabled = _isLoadingProvinces || _provinces.isEmpty;
    final isRegencyDisabled =
        _isLoadingRegencies ||
        widget.item.provinceId == null ||
        _regencies.isEmpty;
    final isDistrictDisabled =
        _isLoadingDistricts ||
        widget.item.regencyId == null ||
        _districts.isEmpty;
    final isVillageDisabled =
        _isLoadingVillages ||
        widget.item.districtId == null ||
        _villages.isEmpty;

    final provinceHint = _isLoadingProvinces
        ? 'Memuat provinsi...'
        : (_provinces.isEmpty ? 'Pilih Provinsi' : 'Pilih Provinsi');

    final regencyHint = _isLoadingRegencies
        ? 'Memuat kabupaten/kota...'
        : (widget.item.provinceId == null
              ? 'Pilih provinsi terlebih dahulu'
              : (_regencies.isEmpty
                    ? 'Tidak ada kabupaten/kota'
                    : 'Pilih Kabupaten / Kota'));

    final districtHint = _isLoadingDistricts
        ? 'Memuat kecamatan...'
        : (widget.item.regencyId == null
              ? 'Pilih kabupaten/kota terlebih dahulu'
              : (_districts.isEmpty
                    ? 'Tidak ada kecamatan'
                    : 'Pilih Kecamatan'));

    final villageHint = _isLoadingVillages
        ? 'Memuat kelurahan/desa...'
        : (widget.item.districtId == null
              ? 'Pilih kecamatan terlebih dahulu'
              : (_villages.isEmpty
                    ? 'Tidak ada kelurahan/desa'
                    : 'Pilih Kelurahan / Desa'));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Row 1: Provinsi & Kabupaten / Kota
        _buildFieldRow(
          context,
          left: _buildDropdownField<int>(
            label: 'Provinsi',
            isRequired: true,
            hint: provinceHint,
            value: selectedProvinceId,
            items: _provinces
                .map(
                  (p) => DropdownMenuItem<int>(
                    value: p.id,
                    child: Text(
                      p.name,
                      style: GoogleFonts.inter(
                        fontSize: 14.0,
                        color: AppColors.text,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
            onChanged: isProvinceDisabled
                ? null
                : (v) {
                    if (v != null) {
                      _onProvinceChanged(v);
                    }
                  },
          ),
          right: _buildDropdownField<int>(
            label: 'Kabupaten / Kota',
            isRequired: true,
            hint: regencyHint,
            value: selectedRegencyId,
            items: _regencies
                .map(
                  (r) => DropdownMenuItem<int>(
                    value: r.id,
                    child: Text(
                      r.name,
                      style: GoogleFonts.inter(
                        fontSize: 14.0,
                        color: AppColors.text,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
            onChanged: isRegencyDisabled
                ? null
                : (v) {
                    if (v != null) {
                      _onRegencyChanged(v);
                    }
                  },
          ),
        ),
        const SizedBox(height: 14.0),

        // Row 2: Kecamatan & Kelurahan / Desa
        _buildFieldRow(
          context,
          left: _buildDropdownField<int>(
            label: 'Kecamatan',
            isRequired: true,
            hint: districtHint,
            value: selectedDistrictId,
            items: _districts
                .map(
                  (d) => DropdownMenuItem<int>(
                    value: d.id,
                    child: Text(
                      d.name,
                      style: GoogleFonts.inter(
                        fontSize: 14.0,
                        color: AppColors.text,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
            onChanged: isDistrictDisabled
                ? null
                : (v) {
                    if (v != null) {
                      _onDistrictChanged(v);
                    }
                  },
          ),
          right: _buildDropdownField<int>(
            label: 'Kelurahan / Desa',
            isRequired: true,
            hint: villageHint,
            value: selectedVillageId,
            items: _villages
                .map(
                  (v) => DropdownMenuItem<int>(
                    value: v.id,
                    child: Text(
                      v.name,
                      style: GoogleFonts.inter(
                        fontSize: 14.0,
                        color: AppColors.text,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
            onChanged: isVillageDisabled
                ? null
                : (v) {
                    if (v != null) {
                      _onVillageChanged(v);
                    }
                  },
          ),
        ),
      ],
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
            const SizedBox(width: 16.0),
            Expanded(child: right),
          ],
        );
      },
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
          key: ValueKey(value),
          initialValue: value,
          hint: hint != null
              ? Text(
                  hint,
                  style: GoogleFonts.inter(
                    fontSize: 14.0,
                    color: AppColors.muted,
                  ),
                  overflow: TextOverflow.ellipsis,
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
            disabledBorder: OutlineInputBorder(
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
