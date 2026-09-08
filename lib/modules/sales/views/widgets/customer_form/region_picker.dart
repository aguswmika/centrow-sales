import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:collection/collection.dart';
import 'package:centrow_sales/app/di.dart';
import 'package:centrow_sales/modules/core/entities/region.dart';
import 'package:centrow_sales/modules/core/repositories/region_repository.dart';
import 'package:centrow_sales/modules/sales/controllers/customer_form_controller.dart'
    show isRegionMatch;
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

  late CreateLocationInput _currentLocation;

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
    _currentLocation = widget.item;
    _fetchProvinces();
    _initCascadingData();
  }

  void _updateLocation(CreateLocationInput updated) {
    _currentLocation = updated;
    widget.onChanged(updated);
  }

  void _initCascadingData() {
    final provinceId = _currentLocation.provinceId;
    if (provinceId != null) {
      _fetchRegencies(provinceId);
      final regencyId = _currentLocation.regencyId;
      if (regencyId != null) {
        _fetchDistricts(provinceId, regencyId);
        final districtId = _currentLocation.districtId;
        if (districtId != null) {
          _fetchVillages(provinceId, regencyId, districtId);
        }
      }
    }
  }

  @override
  void didUpdateWidget(covariant RegionPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    _currentLocation = widget.item;
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
        if (_currentLocation.provinceId == null &&
            _currentLocation.province.isNotEmpty) {
          final matched = _provinces.firstWhereOrNull(
            (p) => isRegionMatch(p.name, _currentLocation.province),
          );
          if (matched != null) {
            _updateLocation(
              _currentLocation.copyWith(
                provinceId: matched.id,
                province: matched.name,
              ),
            );
            _fetchRegencies(matched.id);
          }
        }
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
        if (_currentLocation.regencyId == null &&
            _currentLocation.regency.isNotEmpty) {
          final matched = _regencies.firstWhereOrNull(
            (r) => isRegionMatch(r.name, _currentLocation.regency),
          );
          if (matched != null) {
            _updateLocation(
              _currentLocation.copyWith(
                regencyId: matched.id,
                regency: matched.name,
              ),
            );
            _fetchDistricts(provinceId, matched.id);
          }
        }
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
        if (_currentLocation.districtId == null &&
            _currentLocation.district.isNotEmpty) {
          final matched = _districts.firstWhereOrNull(
            (d) => isRegionMatch(d.name, _currentLocation.district),
          );
          if (matched != null) {
            _updateLocation(
              _currentLocation.copyWith(
                districtId: matched.id,
                district: matched.name,
              ),
            );
            _fetchVillages(provinceId, regencyId, matched.id);
          }
        }
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
        if (_currentLocation.villageId == null &&
            _currentLocation.village.isNotEmpty) {
          final matched = _villages.firstWhereOrNull(
            (v) => isRegionMatch(v.name, _currentLocation.village),
          );
          if (matched != null) {
            _updateLocation(
              _currentLocation.copyWith(
                villageId: matched.id,
                village: matched.name,
              ),
            );
          }
        }
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
    _updateLocation(
      CreateLocationInput(
        label: _currentLocation.label,
        address: _currentLocation.address,
        provinceId: provinceId,
        regencyId: null,
        districtId: null,
        villageId: null,
        province: province.name,
        regency: '',
        district: '',
        village: '',
        areaSize: _currentLocation.areaSize,
        latitude: _currentLocation.latitude,
        longitude: _currentLocation.longitude,
        isPrimary: _currentLocation.isPrimary,
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
    _updateLocation(
      CreateLocationInput(
        label: _currentLocation.label,
        address: _currentLocation.address,
        provinceId: _currentLocation.provinceId,
        regencyId: regencyId,
        districtId: null,
        villageId: null,
        province: _currentLocation.province,
        regency: regency.name,
        district: '',
        village: '',
        areaSize: _currentLocation.areaSize,
        latitude: _currentLocation.latitude,
        longitude: _currentLocation.longitude,
        isPrimary: _currentLocation.isPrimary,
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
    _updateLocation(
      CreateLocationInput(
        label: _currentLocation.label,
        address: _currentLocation.address,
        provinceId: _currentLocation.provinceId,
        regencyId: _currentLocation.regencyId,
        districtId: districtId,
        villageId: null,
        province: _currentLocation.province,
        regency: _currentLocation.regency,
        district: district.name,
        village: '',
        areaSize: _currentLocation.areaSize,
        latitude: _currentLocation.latitude,
        longitude: _currentLocation.longitude,
        isPrimary: _currentLocation.isPrimary,
      ),
    );
  }

  void _onVillageChanged(int villageId) {
    final village = _villages.firstWhere(
      (v) => v.id == villageId,
      orElse: () => Village(id: villageId, name: ''),
    );
    _updateLocation(
      _currentLocation.copyWith(villageId: villageId, village: village.name),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedProvinceId =
        _provinces.any((p) => p.id == _currentLocation.provinceId)
        ? _currentLocation.provinceId
        : _provinces
              .firstWhereOrNull(
                (p) => isRegionMatch(p.name, _currentLocation.province),
              )
              ?.id;
    final selectedRegencyId =
        _regencies.any((r) => r.id == _currentLocation.regencyId)
        ? _currentLocation.regencyId
        : _regencies
              .firstWhereOrNull(
                (r) => isRegionMatch(r.name, _currentLocation.regency),
              )
              ?.id;
    final selectedDistrictId =
        _districts.any((d) => d.id == _currentLocation.districtId)
        ? _currentLocation.districtId
        : _districts
              .firstWhereOrNull(
                (d) => isRegionMatch(d.name, _currentLocation.district),
              )
              ?.id;
    final selectedVillageId =
        _villages.any((v) => v.id == _currentLocation.villageId)
        ? _currentLocation.villageId
        : _villages
              .firstWhereOrNull(
                (v) => isRegionMatch(v.name, _currentLocation.village),
              )
              ?.id;

    final isProvinceDisabled = _isLoadingProvinces || _provinces.isEmpty;
    final isRegencyDisabled =
        _isLoadingRegencies ||
        _currentLocation.provinceId == null ||
        _regencies.isEmpty;
    final isDistrictDisabled =
        _isLoadingDistricts ||
        _currentLocation.regencyId == null ||
        _districts.isEmpty;
    final isVillageDisabled =
        _isLoadingVillages ||
        _currentLocation.districtId == null ||
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
