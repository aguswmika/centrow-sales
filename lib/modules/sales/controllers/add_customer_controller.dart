import 'package:signals/signals.dart';
import '../../../shared/result/result.dart';
import '../../../shared/state/ui_state.dart';
import '../entities/create_customer_input.dart';
import '../entities/customer.dart';
import '../entities/segment.dart';
import '../repositories/customer_repository.dart';

class AddCustomerController {
  final CustomerRepository _repository;

  final _segmentsState = signal<UiState<List<Segment>>>(const UiInitial());
  ReadonlySignal<UiState<List<Segment>>> get segmentsState => _segmentsState;

  final _currentStep = signal<int>(1);

  // Step 1 signals
  final name = signal<String>('');
  final code = signal<String>('');
  final segmentId = signal<String>('');
  final segment = signal<String>('');
  final regency = signal<String>('');
  final status = signal<String>('active');
  final scanCode = signal<String>('');
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
      roleBadge: 'brand',
      isPrimary: true,
      roleCode: 1,
    ),
  ]);

  final _submissionState = signal<UiState<Customer>>(const UiInitial());

  AddCustomerController(this._repository);

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
      return '${primary.label} ($areaStr ${primary.areaUnit})';
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
      regency: regency.value,
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
      role: 'Koordinator Lapangan',
      roleBadge: 'neutral',
      roleCode: CustomerContactRole.picBackup.code,
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

  Future<Customer?> submit() async {
    _submissionState.value = const UiLoading();
    final input = CreateCustomerInput(
      name: name.value.trim(),
      code: code.value.trim(),
      segmentId: segmentId.value.trim().isNotEmpty
          ? segmentId.value.trim()
          : '',
      segment: segment.value.trim(),
      regency: regency.value.trim(),
      status: status.value.trim(),
      scanCode: scanCode.value.trim(),
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

    final result = await _repository.createCustomer(input);
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

  void dispose() {
    _segmentsState.dispose();
    _currentStep.dispose();
    name.dispose();
    code.dispose();
    segmentId.dispose();
    segment.dispose();
    regency.dispose();
    status.dispose();
    scanCode.dispose();
    npwp.dispose();
    phone.dispose();
    phoneAlt.dispose();
    email.dispose();
    riskNotes.dispose();
    notes.dispose();
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
