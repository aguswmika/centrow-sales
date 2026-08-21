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
import 'package:centrow_sales/modules/sales/repositories/customer_repository.dart';

class CustomerFormController {
  final CustomerRepository _repository;
  final RegionRepository _regionRepository;

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
  ]) : _regionRepository = regionRepository ?? _resolveRegionRepository();

  static RegionRepository _resolveRegionRepository() {
    if (getIt.isRegistered<RegionRepository>()) {
      return getIt<RegionRepository>();
    }
    return const _DefaultRegionRepository();
  }

  ReadonlySignal<int> get currentStep => _currentStep;
  ReadonlySignal<UiState<Customer>> get submissionState => _submissionState;

  late final isStep1Valid = computed(
    () =>
        name.value.trim().isNotEmpty &&
        segmentId.value.trim().isNotEmpty &&
        phone.value.trim().isNotEmpty,
  );

  late final isStep2Valid = computed(
    () =>
        locations.value.isNotEmpty &&
        locations.value.any((l) => l.address.trim().isNotEmpty),
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
    final result = await _repository.getCustomerById(id);
    isLoadingData.value = false;

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
      riskNotes.value = customer.riskNotes;
      notes.value = customer.notes;

      final resolvedLocations = <CreateLocationInput>[];
      for (final l in customer.locations) {
        int? pId, rId, dId, vId;
        if (l.province.isNotEmpty) {
          final pRes = await _regionRepository.getProvinces();
          pId = pRes.valueOrNull
              ?.firstWhereOrNull(
                (e) => e.name.toLowerCase() == l.province.toLowerCase(),
              )
              ?.id;
          if (pId != null && l.regency.isNotEmpty) {
            final rRes = await _regionRepository.getRegencies(pId);
            rId = rRes.valueOrNull
                ?.firstWhereOrNull(
                  (e) => e.name.toLowerCase() == l.regency.toLowerCase(),
                )
                ?.id;
            if (rId != null && l.district.isNotEmpty) {
              final dRes = await _regionRepository.getDistricts(pId, rId);
              dId = dRes.valueOrNull
                  ?.firstWhereOrNull(
                    (e) => e.name.toLowerCase() == l.district.toLowerCase(),
                  )
                  ?.id;
              if (dId != null && l.village.isNotEmpty) {
                final vRes = await _regionRepository.getVillages(
                  pId,
                  rId,
                  dId,
                );
                vId = vRes.valueOrNull
                    ?.firstWhereOrNull(
                      (e) => e.name.toLowerCase() == l.village.toLowerCase(),
                    )
                    ?.id;
              }
            }
          }
        }
        resolvedLocations.add(
          CreateLocationInput(
            label: l.label,
            address: l.addressLine,
            province: l.province,
            regency: l.regency,
            district: l.district,
            village: l.village,
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

  void applyMapLocation(int index, double lat, double lng, String address, String? provinceName, String? regencyName, String? districtName, String? villageName) {
    final list = locations.value.toList();
    final item = list[index];

    String newLabel = item.label;
    if (newLabel.startsWith('Titik Servis #') || newLabel == 'Main Location' || newLabel.isEmpty) {
      final parts = address.split(',');
      if (parts.isNotEmpty) {
        newLabel = parts.first.trim();
      }
    }

    list[index] = item.copyWith(
      label: newLabel,
      latitude: lat,
      longitude: lng,
      address: address,
    );
    
    locations.value = list;
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
    riskNotes.dispose();
    notes.dispose();
    status.dispose();
    locations.dispose();
    contacts.dispose();
    _submissionState.dispose();
    isStep1Valid.dispose();
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
  ) async =>
      const Ok([]);

  @override
  Future<Result<List<Village>>> getVillages(
    int provinceId,
    int regencyId,
    int districtId,
  ) async =>
      const Ok([]);
}
