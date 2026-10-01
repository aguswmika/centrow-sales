import 'package:collection/collection.dart';
import 'package:signals/signals.dart';
import 'package:centrow_sales/app/di.dart';
import 'package:centrow_sales/shared/result/result.dart';
import 'package:centrow_sales/shared/state/ui_state.dart';
import 'package:centrow_sales/modules/core/entities/region.dart';
import 'package:centrow_sales/modules/core/repositories/region_repository.dart';
import 'package:centrow_sales/modules/sales/entities/create_customer_input.dart';
import 'package:centrow_sales/modules/sales/entities/customer.dart';
import 'package:centrow_sales/modules/sales/entities/segment.dart';
import 'package:centrow_sales/modules/sales/entities/site_risk.dart';
import 'package:centrow_sales/modules/sales/repositories/customer_repository.dart';
import 'package:centrow_sales/modules/sales/repositories/site_risk_repository.dart';

/// Normalizes region names by removing common Indonesian administrative prefixes,
/// trailing tokens, and punctuation for resilient matching.
String normalizeRegionName(String name) {
  var cleaned = name.trim().toLowerCase();
  cleaned = cleaned.replaceAll(
    RegExp(
      r'^(kabupaten|kab\.|kab|kotamadya|kota adm\.|kota|adm\.|kecamatan|kec\.|kec|kelurahan|kel\.|kel|desa)\s+',
      caseSensitive: false,
    ),
    '',
  );
  // Remove punctuation (replacing with space to preserve token boundaries)
  cleaned = cleaned.replaceAll(RegExp(r'[^\w\s]'), ' ');
  cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();
  // Remove trailing words like city, regency, kabupaten, kecamatan, kelurahan, desa
  cleaned = cleaned.replaceAll(
    RegExp(
      r'\s+(city|regency|kabupaten|kecamatan|kelurahan|desa)$',
      caseSensitive: false,
    ),
    '',
  );
  return cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();
}

bool isRegionMatch(String apiName, String targetName) {
  final cleanApi = apiName.trim().toLowerCase();
  final cleanTarget = targetName.trim().toLowerCase();
  if (cleanApi.isEmpty || cleanTarget.isEmpty) {
    return false;
  }
  if (cleanApi == cleanTarget) {
    return true;
  }
  final normA = normalizeRegionName(apiName);
  final normT = normalizeRegionName(targetName);
  if (normA.isEmpty || normT.isEmpty) {
    return false;
  }
  if (normA == normT) {
    return true;
  }
  if (normA.contains(normT) || normT.contains(normA)) {
    return true;
  }
  return false;
}

/// Finds matching item from an address string by checking comma-separated segments or containment.
T? findRegionMatchFromAddress<T>({
  required List<T> items,
  required String Function(T) nameSelector,
  required String address,
}) {
  if (address.isEmpty || items.isEmpty) return null;

  // 1. Try matching against comma-separated address segments (e.g. "Dangin Puri Kangin", "Denpasar Utara", "Denpasar")
  final segments = address
      .split(RegExp(r'[,;/\n]'))
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toList();

  for (final seg in segments) {
    final match = items.firstWhereOrNull(
      (item) => isRegionMatch(nameSelector(item), seg),
    );
    if (match != null) return match;
  }

  // 2. Try whole-word / token containment in full address (longest normalized name first to avoid substrings)
  final sortedItems = items.toList()
    ..sort((a, b) => nameSelector(b).length.compareTo(nameSelector(a).length));

  for (final item in sortedItems) {
    final norm = normalizeRegionName(nameSelector(item));
    if (norm.length >= 3 && address.toLowerCase().contains(norm)) {
      return item;
    }
  }

  return null;
}

class CustomerFormController {
  final CustomerRepository _repository;
  final RegionRepository _regionRepository;
  final SiteRiskRepository _siteRiskRepository;

  final customerId = signal<String?>(null);
  final isLoadingData = signal<bool>(false);

  final _segmentsState = signal<UiState<List<Segment>>>(const UiInitial());
  ReadonlySignal<UiState<List<Segment>>> get segmentsState => _segmentsState;

  final _currentStep = signal<int>(1);

  // Step 1 signals
  final name = signal<String>('');
  final code = signal<String>('');
  final segmentId = signal<String>('');
  final segment = signal<String>('');
  final status = signal<String>('active');
  final npwp = signal<String>('');
  final phone = signal<String>('');
  final phoneAlt = signal<String>('');
  final email = signal<String>('');
  final taxPercentage = signal<double>(0.0);
  final riskNotes = signal<String>('');
  final notes = signal<String>('');

  // Step 2 & 3 signals
  final locations = signal<List<CreateLocationInput>>([
    const CreateLocationInput(
      label: 'Main Location',
      address: '',
      isPrimary: true,
    ),
  ]);

  final contacts = signal<List<CreateContactInput>>([
    const CreateContactInput(
      name: '',
      position: '',
      email: '',
      phone: '',
      role: 'pic',
      isPrimary: true,
    ),
  ]);

  final _submissionState = signal<UiState<Customer>>(const UiInitial());

  CustomerFormController(
    this._repository, [
    RegionRepository? regionRepository,
    SiteRiskRepository? siteRiskRepository,
  ]) : _regionRepository = regionRepository ?? _resolveRegionRepository(),
       _siteRiskRepository = siteRiskRepository ?? _resolveSiteRiskRepository();

  static RegionRepository _resolveRegionRepository() {
    if (getIt.isRegistered<RegionRepository>()) {
      return getIt<RegionRepository>();
    }
    return const _DefaultRegionRepository();
  }

  static SiteRiskRepository _resolveSiteRiskRepository() {
    if (getIt.isRegistered<SiteRiskRepository>()) {
      return getIt<SiteRiskRepository>();
    }
    return const _DefaultSiteRiskRepository();
  }

  ReadonlySignal<int> get currentStep => _currentStep;
  ReadonlySignal<UiState<Customer>> get submissionState => _submissionState;

  late final isStep1Valid = computed(
    () =>
        name.value.trim().isNotEmpty &&
        segmentId.value.trim().isNotEmpty &&
        phone.value.trim().isNotEmpty,
  );

  late final isPrimaryLocationSraFilled = computed(() {
    final list = locations.value;
    if (list.isEmpty) return false;
    final primary = list.firstWhere(
      (l) => l.isPrimary,
      orElse: () => list.first,
    );
    return primary.siteRiskIds.isNotEmpty || primary.customRisks.isNotEmpty;
  });

  late final isStep2Valid = computed(
    () =>
        locations.value.isNotEmpty &&
        locations.value.every(
          (l) =>
              l.address.trim().isNotEmpty &&
              l.provinceId != null &&
              l.regencyId != null &&
              l.districtId != null &&
              l.villageId != null,
        ) &&
        isPrimaryLocationSraFilled.value,
  );

  late final isStep3Valid = computed(
    () =>
        contacts.value.isNotEmpty &&
        contacts.value.any(
          (c) => c.name.trim().isNotEmpty && c.phone.trim().isNotEmpty,
        ),
  );

  late final primaryLocationSummary = computed(() {
    final list = locations.value;
    if (list.isEmpty) return '-';
    final primary = list.firstWhere(
      (l) => l.isPrimary,
      orElse: () => list.first,
    );
    if (primary.label.isEmpty) return '-';
    if (primary.areaSize != null && primary.areaSize! > 0) {
      final areaStr = primary.areaSize! % 1 == 0
          ? primary.areaSize!.toInt().toString()
          : primary.areaSize!.toString();
      return '${primary.label} ($areaStr m²)';
    }
    return primary.label;
  });

  late final primaryContactName = computed(() {
    final list = contacts.value;
    if (list.isEmpty) return '-';
    final primary = list.firstWhere(
      (c) => c.isPrimary,
      orElse: () => list.first,
    );
    return primary.name.isNotEmpty ? primary.name : '-';
  });

  void setStep(int step) {
    if (step >= 1 && step <= 3) {
      _currentStep.value = step;
    }
  }

  bool nextStep() {
    if (_currentStep.value == 1 && !isStep1Valid.value) return false;
    if (_currentStep.value == 2 && !isStep2Valid.value) return false;
    if (_currentStep.value < 3) {
      _currentStep.value++;
      return true;
    }
    return true;
  }

  void prevStep() {
    if (_currentStep.value > 1) {
      _currentStep.value--;
    }
  }

  void addLocation() {
    final newLoc = CreateLocationInput(
      label: 'Titik Servis #${locations.value.length + 1}',
      isPrimary: locations.value.isEmpty,
    );
    locations.value = [...locations.value, newLoc];
  }

  void removeLocation(int index) {
    if (locations.value.length <= 1) return;
    final list = locations.value.toList()..removeAt(index);
    if (!list.any((l) => l.isPrimary) && list.isNotEmpty) {
      list[0] = list[0].copyWith(isPrimary: true);
    }
    locations.value = list;
  }

  void setPrimaryLocation(int index) {
    final list = locations.value.toList();
    for (var i = 0; i < list.length; i++) {
      list[i] = list[i].copyWith(isPrimary: i == index);
    }
    locations.value = list;
  }

  void updateLocation(int index, CreateLocationInput location) {
    final list = locations.value.toList();
    list[index] = location;
    locations.value = list;
  }

  void updatePrimaryLocationSra({
    required List<String> siteRiskIds,
    required List<String> customRisks,
  }) {
    if (locations.value.isEmpty) return;
    final updated = List<CreateLocationInput>.from(locations.value);
    final primaryIdx = updated.indexWhere((l) => l.isPrimary);
    final targetIdx = primaryIdx >= 0 ? primaryIdx : 0;
    updated[targetIdx] = updated[targetIdx].copyWith(
      siteRiskIds: siteRiskIds,
      customRisks: customRisks,
    );
    locations.value = updated;
  }

  void addContact() {
    final newContact = CreateContactInput(
      name: '',
      role: 'pic_backup',
      isPrimary: contacts.value.isEmpty,
    );
    contacts.value = [...contacts.value, newContact];
  }

  void removeContact(int index) {
    if (contacts.value.length <= 1) return;
    final list = contacts.value.toList()..removeAt(index);
    if (!list.any((c) => c.isPrimary) && list.isNotEmpty) {
      list[0] = list[0].copyWith(isPrimary: true);
    }
    contacts.value = list;
  }

  void setPrimaryContact(int index) {
    final list = contacts.value.toList();
    for (var i = 0; i < list.length; i++) {
      list[i] = list[i].copyWith(isPrimary: i == index);
    }
    contacts.value = list;
  }

  void updateContact(int index, CreateContactInput contact) {
    final list = contacts.value.toList();
    list[index] = contact;
    contacts.value = list;
  }

  Future<void> loadInitialData(String id) async {
    customerId.value = id;
    isLoadingData.value = true;
    try {
      final result = await _repository.getCustomerById(id);

      if (result case Ok(value: final customer)) {
        name.value = customer.name;
        code.value = customer.code;
        segmentId.value = customer.segmentId;
        segment.value = customer.segment;
        status.value = customer.status;
        npwp.value = customer.npwp;
        phone.value = customer.phone;
        phoneAlt.value = customer.phoneAlt;
        email.value = customer.email;
        taxPercentage.value = customer.taxPercentage;
        riskNotes.value = customer.riskNotes;
        notes.value = customer.notes;

        final resolvedLocations = <CreateLocationInput>[];
        for (final l in customer.locations) {
          int? pId = l.provinceId;
          int? rId = l.regencyId;
          int? dId = l.districtId;
          int? vId = l.villageId;
          String pName = l.province;
          String rName = l.regency;
          String dName = l.district;
          String vName = l.village;

          // If IDs are missing from the customer record (e.g. legacy data), resolve via RegionRepository:
          final addr = l.addressLine;

          // 1. Province
          if (pId == null && pName.isNotEmpty) {
            final pRes = await _regionRepository.getProvinces();
            final matched = pRes.valueOrNull?.firstWhereOrNull(
              (e) => isRegionMatch(e.name, pName),
            );
            pId = matched?.id;
            if (matched != null && pName.isEmpty) {
              pName = matched.name;
            }
          }
          if (pId == null && addr.isNotEmpty) {
            final pRes = await _regionRepository.getProvinces();
            final matched = findRegionMatchFromAddress<Province>(
              items: pRes.valueOrNull ?? const <Province>[],
              nameSelector: (e) => e.name,
              address: addr,
            );
            if (matched != null) {
              pId = matched.id;
              pName = matched.name;
            }
          }
          if (pId != null && pName.isEmpty) {
            final pRes = await _regionRepository.getProvinces();
            final matched = pRes.valueOrNull?.firstWhereOrNull(
              (e) => e.id == pId,
            );
            if (matched != null) {
              pName = matched.name;
            }
          }

          // 2. Regency
          if (pId != null && rId == null && rName.isNotEmpty) {
            final rRes = await _regionRepository.getRegencies(pId);
            final matched = rRes.valueOrNull?.firstWhereOrNull(
              (e) => isRegionMatch(e.name, rName),
            );
            rId = matched?.id;
            if (matched != null && rName.isEmpty) {
              rName = matched.name;
            }
          }
          if (pId != null && rId == null && addr.isNotEmpty) {
            final rRes = await _regionRepository.getRegencies(pId);
            final matched = findRegionMatchFromAddress<Regency>(
              items: rRes.valueOrNull ?? const <Regency>[],
              nameSelector: (e) => e.name,
              address: addr,
            );
            if (matched != null) {
              rId = matched.id;
              rName = matched.name;
            }
          }
          if (pId != null && rId != null && rName.isEmpty) {
            final rRes = await _regionRepository.getRegencies(pId);
            final matched = rRes.valueOrNull?.firstWhereOrNull(
              (e) => e.id == rId,
            );
            if (matched != null) {
              rName = matched.name;
            }
          }

          // 3. District
          if (pId != null && rId != null && dId == null && dName.isNotEmpty) {
            final dRes = await _regionRepository.getDistricts(pId, rId);
            final matched = dRes.valueOrNull?.firstWhereOrNull(
              (e) => isRegionMatch(e.name, dName),
            );
            dId = matched?.id;
            if (matched != null && dName.isEmpty) {
              dName = matched.name;
            }
          }
          if (pId != null && rId != null && dId == null && addr.isNotEmpty) {
            final dRes = await _regionRepository.getDistricts(pId, rId);
            final matched = findRegionMatchFromAddress<District>(
              items: dRes.valueOrNull ?? const <District>[],
              nameSelector: (e) => e.name,
              address: addr,
            );
            if (matched != null) {
              dId = matched.id;
              dName = matched.name;
            }
          }
          if (pId != null && rId != null && dId != null && dName.isEmpty) {
            final dRes = await _regionRepository.getDistricts(pId, rId);
            final matched = dRes.valueOrNull?.firstWhereOrNull(
              (e) => e.id == dId,
            );
            if (matched != null) {
              dName = matched.name;
            }
          }

          // 4. Village
          if (pId != null &&
              rId != null &&
              dId != null &&
              vId == null &&
              vName.isNotEmpty) {
            final vRes = await _regionRepository.getVillages(pId, rId, dId);
            final matched = vRes.valueOrNull?.firstWhereOrNull(
              (e) => isRegionMatch(e.name, vName),
            );
            vId = matched?.id;
            if (matched != null && vName.isEmpty) {
              vName = matched.name;
            }
          }
          if (pId != null &&
              rId != null &&
              dId != null &&
              vId == null &&
              addr.isNotEmpty) {
            final vRes = await _regionRepository.getVillages(pId, rId, dId);
            final matched = findRegionMatchFromAddress<Village>(
              items: vRes.valueOrNull ?? const <Village>[],
              nameSelector: (e) => e.name,
              address: addr,
            );
            if (matched != null) {
              vId = matched.id;
              vName = matched.name;
            }
          }
          if (pId != null &&
              rId != null &&
              dId != null &&
              vId != null &&
              vName.isEmpty) {
            final vRes = await _regionRepository.getVillages(pId, rId, dId);
            final matched = vRes.valueOrNull?.firstWhereOrNull(
              (e) => e.id == vId,
            );
            if (matched != null) {
              vName = matched.name;
            }
          }

          resolvedLocations.add(
            CreateLocationInput(
              label: l.label,
              address: l.addressLine,
              province: pName.isNotEmpty ? pName : l.province,
              regency: rName.isNotEmpty ? rName : l.regency,
              district: dName.isNotEmpty ? dName : l.district,
              village: vName.isNotEmpty ? vName : l.village,
              provinceId: pId,
              regencyId: rId,
              districtId: dId,
              villageId: vId,
              areaSize: l.areaSize,
              latitude: l.latitude,
              longitude: l.longitude,
              isPrimary: l.isPrimary,
            ),
          );
        }

        if (resolvedLocations.isNotEmpty && customer.locations.isNotEmpty) {
          final primaryLoc =
              customer.locations.firstWhereOrNull((l) => l.isPrimary) ??
              customer.locations.first;
          final primaryAddressId = primaryLoc.id ?? customer.locations.first.id;
          if (primaryAddressId != null && primaryAddressId.isNotEmpty) {
            try {
              final risksResult = await _siteRiskRepository.getAddressRisks(
                customerId: id,
                addressId: primaryAddressId,
              );
              if (risksResult case Ok(value: final value)) {
                final siteRiskIds = value
                    .where((r) => !r.isCustom && r.siteRiskId != null)
                    .map((r) => r.siteRiskId!)
                    .toList();
                final customRisks = value
                    .where((r) => r.isCustom)
                    .map((r) => r.name)
                    .toList();

                final primaryIdx = resolvedLocations.indexWhere(
                  (l) => l.isPrimary,
                );
                final targetIdx = primaryIdx >= 0 ? primaryIdx : 0;
                resolvedLocations[targetIdx] = resolvedLocations[targetIdx]
                    .copyWith(
                      siteRiskIds: siteRiskIds,
                      customRisks: customRisks,
                    );
              }
            } catch (_) {
              // Gracefully ignore SRA load failure
            }
          }
        }
        locations.value = resolvedLocations;

        contacts.value = customer.contacts
            .map(
              (c) => CreateContactInput(
                name: c.name,
                position: c.position,
                email: c.email,
                phone: c.phone,
                role: c.role,
                isPrimary: c.isPrimary,
              ),
            )
            .toList();
      }
    } finally {
      isLoadingData.value = false;
    }
  }

  Future<Customer?> submit() async {
    _submissionState.value = const UiLoading();
    final input = CreateCustomerInput(
      name: name.value.trim(),
      code: code.value.trim(),
      status: status.value.trim(),
      segmentId: segmentId.value.trim().isNotEmpty
          ? segmentId.value.trim()
          : '',
      segment: segment.value.trim(),
      npwp: npwp.value.trim(),
      phone: phone.value.trim(),
      phoneAlt: phoneAlt.value.trim(),
      email: email.value.trim(),
      taxPercentage: taxPercentage.value,
      riskNotes: riskNotes.value.trim(),
      notes: notes.value.trim(),
      locations: locations.value
          .where(
            (l) => l.label.trim().isNotEmpty || l.address.trim().isNotEmpty,
          )
          .toList(),
      contacts: contacts.value.where((c) => c.name.trim().isNotEmpty).toList(),
    );

    final result = customerId.value != null
        ? await _repository.updateCustomer(customerId.value!, input)
        : await _repository.createCustomer(input);
    return switch (result) {
      Ok(:final value) => () {
        _submissionState.value = UiSuccess(value);
        return value;
      }(),
      Err(:final failure) => () {
        _submissionState.value = UiFailure(failure);
        return null;
      }(),
    };
  }

  Future<void> loadSegments() async {
    _segmentsState.value = const UiLoading();
    final result = await _repository.getSegments();
    _segmentsState.value = switch (result) {
      Ok(:final value) => UiSuccess<List<Segment>>(value),
      Err(:final failure) => UiFailure<List<Segment>>(failure),
    };
  }

  Future<void> applyMapLocation(
    int index,
    double lat,
    double lng,
    String address,
    String? provinceName,
    String? regencyName,
    String? districtName,
    String? villageName,
  ) async {
    final list = locations.value.toList();
    if (index >= list.length) return;
    final item = list[index];

    String newLabel = item.label;
    if (newLabel.startsWith('Titik Servis #') ||
        newLabel == 'Main Location' ||
        newLabel.isEmpty) {
      final parts = address.split(',');
      if (parts.isNotEmpty) {
        newLabel = parts.first.trim();
      }
    }

    String pName = (provinceName != null && provinceName.isNotEmpty)
        ? provinceName
        : item.province;
    String rName = (regencyName != null && regencyName.isNotEmpty)
        ? regencyName
        : item.regency;
    String dName = (districtName != null && districtName.isNotEmpty)
        ? districtName
        : item.district;
    String vName = (villageName != null && villageName.isNotEmpty)
        ? villageName
        : item.village;

    int? pId = item.provinceId;
    int? rId = item.regencyId;
    int? dId = item.districtId;
    int? vId = item.villageId;

    list[index] = item.copyWith(
      label: newLabel,
      latitude: lat,
      longitude: lng,
      address: address,
      province: pName,
      regency: rName,
      district: dName,
      village: vName,
    );
    locations.value = list;

    // Asynchronously resolve region IDs
    try {
      final pRes = await _regionRepository.getProvinces();
      final pList = pRes.valueOrNull ?? const <Province>[];
      final matchedP =
          (pName.isNotEmpty
              ? pList.firstWhereOrNull((p) => isRegionMatch(p.name, pName))
              : null) ??
          findRegionMatchFromAddress<Province>(
            items: pList,
            nameSelector: (p) => p.name,
            address: address,
          );
      if (matchedP != null) {
        pId = matchedP.id;
        pName = matchedP.name;

        final rRes = await _regionRepository.getRegencies(pId);
        final rList = rRes.valueOrNull ?? const <Regency>[];
        final matchedR =
            (rName.isNotEmpty
                ? rList.firstWhereOrNull((r) => isRegionMatch(r.name, rName))
                : null) ??
            findRegionMatchFromAddress<Regency>(
              items: rList,
              nameSelector: (r) => r.name,
              address: address,
            );
        if (matchedR != null) {
          rId = matchedR.id;
          rName = matchedR.name;

          final dRes = await _regionRepository.getDistricts(pId, rId);
          final dList = dRes.valueOrNull ?? const <District>[];
          final matchedD =
              (dName.isNotEmpty
                  ? dList.firstWhereOrNull((d) => isRegionMatch(d.name, dName))
                  : null) ??
              findRegionMatchFromAddress<District>(
                items: dList,
                nameSelector: (d) => d.name,
                address: address,
              );
          if (matchedD != null) {
            dId = matchedD.id;
            dName = matchedD.name;

            final vRes = await _regionRepository.getVillages(pId, rId, dId);
            final vList = vRes.valueOrNull ?? const <Village>[];
            final matchedV =
                (vName.isNotEmpty
                    ? vList.firstWhereOrNull(
                        (v) => isRegionMatch(v.name, vName),
                      )
                    : null) ??
                findRegionMatchFromAddress<Village>(
                  items: vList,
                  nameSelector: (v) => v.name,
                  address: address,
                );
            if (matchedV != null) {
              vId = matchedV.id;
              vName = matchedV.name;
            }
          }
        }
      }

      final updatedList = locations.value.toList();
      if (index < updatedList.length) {
        updatedList[index] = updatedList[index].copyWith(
          provinceId: pId,
          province: pName,
          regencyId: rId,
          regency: rName,
          districtId: dId,
          district: dName,
          villageId: vId,
          village: vName,
        );
        locations.value = updatedList;
      }
    } catch (_) {
      // Best-effort resolution
    }
  }

  void dispose() {
    _segmentsState.dispose();
    _currentStep.dispose();
    customerId.dispose();
    isLoadingData.dispose();
    status.dispose();
    name.dispose();
    code.dispose();
    segmentId.dispose();
    segment.dispose();
    npwp.dispose();
    phone.dispose();
    phoneAlt.dispose();
    email.dispose();
    taxPercentage.dispose();
    riskNotes.dispose();
    notes.dispose();
    locations.dispose();
    contacts.dispose();
    _submissionState.dispose();
    isStep1Valid.dispose();
    isPrimaryLocationSraFilled.dispose();
    isStep2Valid.dispose();
    isStep3Valid.dispose();
    primaryLocationSummary.dispose();
    primaryContactName.dispose();
  }
}

class _DefaultRegionRepository implements RegionRepository {
  const _DefaultRegionRepository();

  @override
  Future<Result<List<Province>>> getProvinces() async => const Ok([]);

  @override
  Future<Result<List<Regency>>> getRegencies(int provinceId) async =>
      const Ok([]);

  @override
  Future<Result<List<District>>> getDistricts(
    int provinceId,
    int regencyId,
  ) async => const Ok([]);

  @override
  Future<Result<List<Village>>> getVillages(
    int provinceId,
    int regencyId,
    int districtId,
  ) async => const Ok([]);
}

class _DefaultSiteRiskRepository implements SiteRiskRepository {
  const _DefaultSiteRiskRepository();

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
