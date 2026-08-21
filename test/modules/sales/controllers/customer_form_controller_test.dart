import 'package:flutter_test/flutter_test.dart';
import 'package:centrow_sales/modules/core/entities/region.dart';
import 'package:centrow_sales/modules/core/repositories/region_repository.dart';
import 'package:centrow_sales/modules/sales/controllers/customer_form_controller.dart';
import 'package:centrow_sales/modules/sales/entities/create_customer_input.dart';
import 'package:centrow_sales/modules/sales/entities/customer.dart';
import 'package:centrow_sales/modules/sales/entities/segment.dart';
import 'package:centrow_sales/modules/sales/repositories/customer_repository.dart';
import 'package:centrow_sales/shared/error/failure.dart';
import 'package:centrow_sales/shared/result/result.dart';
import 'package:centrow_sales/shared/state/ui_state.dart';

class FakeRegionRepository implements RegionRepository {
  List<Province> provinces = [];
  List<Regency> regencies = [];
  List<District> districts = [];
  List<Village> villages = [];

  @override
  Future<Result<List<Province>>> getProvinces() async => Ok(provinces);

  @override
  Future<Result<List<Regency>>> getRegencies(int provinceId) async =>
      Ok(regencies);

  @override
  Future<Result<List<District>>> getDistricts(
    int provinceId,
    int regencyId,
  ) async =>
      Ok(districts);

  @override
  Future<Result<List<Village>>> getVillages(
    int provinceId,
    int regencyId,
    int districtId,
  ) async =>
      Ok(villages);
}

class FakeCustomerRepository implements CustomerRepository {
  List<Customer> customers = [];
  bool shouldFailCreate = false;
  bool shouldFailUpdate = false;
  String? lastUpdatedId;
  CreateCustomerInput? lastUpdatedInput;
  List<Segment> initialSegments;
  bool failSegments;

  FakeCustomerRepository({
    List<Segment>? initialSegments,
    this.failSegments = false,
  }) : initialSegments = initialSegments ?? [];

  @override
  Future<Result<List<Customer>>> getCustomers({
    int page = 1,
    int pageSize = 20,
    String? query,
    String? segmentId,
    String? status,
  }) async {
    return Ok(customers);
  }

  @override
  Future<Result<Customer>> getCustomerById(String id) async {
    try {
      final found = customers.firstWhere((c) => c.id == id);
      return Ok(found);
    } catch (_) {
      return const Err(ServerFailure('Data tidak ditemukan', 404));
    }
  }

  @override
  Future<Result<Customer>> createCustomer(CreateCustomerInput input) async {
    if (shouldFailCreate) {
      return const Err(ServerFailure('Gagal membuat pelanggan', 400));
    }
    final created = Customer(
      id: 'c${customers.length + 1}',
      code: input.code.isNotEmpty ? input.code : 'CRM-0901',
      name: input.name,
      initials: input.name.isNotEmpty
          ? input.name.substring(0, 2).toUpperCase()
          : 'CP',
      segmentId: input.segmentId,
      segment: input.segment.isNotEmpty ? input.segment : 'Villa',
      status: 'active',
      phone: input.phone,
      phoneAlt: input.phoneAlt,
      email: input.email,
      riskNotes: input.riskNotes,
      notes: input.notes,
      locations: input.locations
          .map((l) => CustomerLocation(
                label: l.label,
                addressLine: l.address,
                isPrimary: l.isPrimary,
                areaSize: l.areaSize,
              ))
          .toList(),
      contacts: input.contacts
          .map((c) => CustomerContact(
                name: c.name,
                position: c.position,
                email: c.email,
                phone: c.phone,
                role: c.role,
                isPrimary: c.isPrimary,
              ))
          .toList(),
    );
    customers.add(created);
    return Ok(created);
  }

  @override
  Future<Result<Customer>> updateCustomer(
    String id,
    CreateCustomerInput input,
  ) async {
    lastUpdatedId = id;
    lastUpdatedInput = input;
    if (shouldFailUpdate) {
      return const Err(ServerFailure('Gagal memperbarui pelanggan', 400));
    }
    final existingIndex = customers.indexWhere((c) => c.id == id);
    final updated = Customer(
      id: id,
      code: input.code.isNotEmpty ? input.code : 'CRM-0901',
      name: input.name,
      initials: input.name.isNotEmpty
          ? input.name.substring(0, 2).toUpperCase()
          : 'CP',
      segmentId: input.segmentId,
      segment: input.segment.isNotEmpty ? input.segment : 'Villa',
      status: 'active',
      phone: input.phone,
      phoneAlt: input.phoneAlt,
      email: input.email,
      riskNotes: input.riskNotes,
      notes: input.notes,
      locations: input.locations
          .map((l) => CustomerLocation(
                label: l.label,
                addressLine: l.address,
                isPrimary: l.isPrimary,
                areaSize: l.areaSize,
              ))
          .toList(),
      contacts: input.contacts
          .map((c) => CustomerContact(
                name: c.name,
                position: c.position,
                email: c.email,
                phone: c.phone,
                role: c.role,
                isPrimary: c.isPrimary,
              ))
          .toList(),
    );
    if (existingIndex >= 0) {
      customers[existingIndex] = updated;
    } else {
      customers.add(updated);
    }
    return Ok(updated);
  }

  @override
  Future<Result<List<Segment>>> getSegments({
    int page = 1,
    int pageSize = 100,
    String? query,
  }) async {
    if (failSegments) {
      return const Err(ServerFailure('Segment load failed', 500));
    }
    return Ok(initialSegments);
  }
}

void main() {
  group('CustomerFormController', () {
    late FakeCustomerRepository repository;
    late CustomerFormController controller;

    setUp(() {
      repository = FakeCustomerRepository();
      controller = CustomerFormController(repository);
    });

    tearDown(() {
      controller.dispose();
    });

    test('initial state is cleared and default values are set', () {
      expect(controller.segmentsState.value, isA<UiInitial<List<Segment>>>());
      expect(controller.currentStep.value, 1);
      expect(controller.name.value, '');
      expect(controller.code.value, '');
      expect(controller.status.value, 'active');
      expect(controller.segmentId.value, '');
      expect(controller.segment.value, '');
      expect(controller.npwp.value, '');
      expect(controller.phone.value, '');
      expect(controller.phoneAlt.value, '');
      expect(controller.email.value, '');
      expect(controller.riskNotes.value, '');
      expect(controller.notes.value, '');

      expect(controller.locations.value.length, 1);
      expect(controller.locations.value.first.isPrimary, true);
      expect(controller.locations.value.first.address, '');

      expect(controller.contacts.value.length, 1);
      expect(controller.contacts.value.first.isPrimary, true);
      expect(controller.contacts.value.first.role, 'pic');
      expect(controller.contacts.value.first.name, '');

      expect(controller.isStep1Valid.value, false);
      expect(controller.isStep2Valid.value, false);
      expect(controller.isStep3Valid.value, false);
      expect(controller.submissionState.value, isA<UiInitial<Customer>>());
    });

    test('step navigation and validation gating across all 3 steps', () {
      // Step 1: name, segmentId, and phone are required
      expect(controller.nextStep(), false);
      expect(controller.currentStep.value, 1);

      controller.name.value = 'Villa Sari Dewi';
      expect(controller.nextStep(), false);

      controller.segmentId.value = '660e8400-e29b-41d4-a716-446655440001';
      expect(controller.nextStep(), false);

      controller.phone.value = '+62 812-3456-7890';
      expect(controller.isStep1Valid.value, true);

      // Advance to Step 2
      expect(controller.nextStep(), true);
      expect(controller.currentStep.value, 2);

      // Step 2: at least one location with non-empty address is required
      expect(controller.isStep2Valid.value, false);
      expect(controller.nextStep(), false);
      expect(controller.currentStep.value, 2);

      controller.updateLocation(
        0,
        controller.locations.value.first.copyWith(
          label: 'Villa Utama',
          address: 'Jl. Raya Seminyak No. 88',
        ),
      );
      expect(controller.isStep2Valid.value, true);

      // Advance to Step 3
      expect(controller.nextStep(), true);
      expect(controller.currentStep.value, 3);

      // Step 3: at least one contact with non-empty name and phone is required
      expect(controller.isStep3Valid.value, false);

      controller.updateContact(
        0,
        controller.contacts.value.first.copyWith(
          name: 'Budi Santoso',
          phone: '+62 812-3456-7890',
        ),
      );
      expect(controller.isStep3Valid.value, true);

      // Calling nextStep on step 3 returns true
      expect(controller.nextStep(), true);
      expect(controller.currentStep.value, 3);

      // Test prevStep
      controller.prevStep();
      expect(controller.currentStep.value, 2);
      controller.prevStep();
      expect(controller.currentStep.value, 1);
      controller.prevStep(); // Should not go below 1
      expect(controller.currentStep.value, 1);

      // Test setStep
      controller.setStep(3);
      expect(controller.currentStep.value, 3);
      controller.setStep(0); // Out of bounds, ignored
      expect(controller.currentStep.value, 3);
    });

    test('locations management: add, update, remove, set primary', () {
      expect(controller.locations.value.length, 1);

      controller.addLocation();
      expect(controller.locations.value.length, 2);
      expect(controller.locations.value[0].isPrimary, true);
      expect(controller.locations.value[1].isPrimary, false);

      controller.setPrimaryLocation(1);
      expect(controller.locations.value[0].isPrimary, false);
      expect(controller.locations.value[1].isPrimary, true);

      controller.updateLocation(
        1,
        controller.locations.value[1].copyWith(
          label: 'Gudang Logistik',
          address: 'Jl. Sunset Road No. 4',
          areaSize: 450,
        ),
      );
      expect(controller.locations.value[1].label, 'Gudang Logistik');
      expect(controller.primaryLocationSummary.value, 'Gudang Logistik (450 m²)');

      // Removing location at index 1 (which was primary) makes index 0 primary
      controller.removeLocation(1);
      expect(controller.locations.value.length, 1);
      expect(controller.locations.value[0].isPrimary, true);

      // Cannot remove last location
      controller.removeLocation(0);
      expect(controller.locations.value.length, 1);
    });

    test('contacts management: add, update, remove, set primary', () {
      expect(controller.contacts.value.length, 1);

      controller.addContact();
      expect(controller.contacts.value.length, 2);
      expect(controller.contacts.value[0].isPrimary, true);
      expect(controller.contacts.value[1].isPrimary, false);

      controller.setPrimaryContact(1);
      expect(controller.contacts.value[0].isPrimary, false);
      expect(controller.contacts.value[1].isPrimary, true);

      controller.updateContact(
        1,
        controller.contacts.value[1].copyWith(name: 'Sari Rahayu'),
      );
      expect(controller.contacts.value[1].name, 'Sari Rahayu');
      expect(controller.primaryContactName.value, 'Sari Rahayu');

      // Removing primary contact guarantees first remaining is primary
      controller.removeContact(1);
      expect(controller.contacts.value.length, 1);
      expect(controller.contacts.value[0].isPrimary, true);

      // Cannot remove last contact
      controller.removeContact(0);
      expect(controller.contacts.value.length, 1);
    });

    test('submit creates customer and updates submissionState on success', () async {
      controller.name.value = 'Restoran Mewah Jakarta';
      controller.code.value = 'CUST-003';
      controller.segmentId.value = '660e8400-e29b-41d4-a716-446655440012';
      controller.segment.value = 'Food & Beverage';
      controller.phone.value = '+62-21-555-9999';
      controller.updateLocation(
        0,
        controller.locations.value.first.copyWith(
          label: 'Main Location',
          address: 'Jl. Menteng Raya No. 42',
        ),
      );
      controller.updateContact(
        0,
        controller.contacts.value.first.copyWith(
          name: 'Eko Prasetyo',
          phone: '+62-21-555-9999',
          role: 'pic',
        ),
      );

      final created = await controller.submit();
      expect(created, isNotNull);
      expect(created?.name, 'Restoran Mewah Jakarta');
      expect(created?.code, 'CUST-003');
      expect(controller.submissionState.value, isA<UiSuccess<Customer>>());
      expect(
        controller.submissionState.value.dataOrNull?.name,
        'Restoran Mewah Jakarta',
      );
    });

    test('submit updates submissionState with UiFailure on failure', () async {
      repository.shouldFailCreate = true;
      controller.name.value = 'Invalid Customer';
      controller.segmentId.value = 'invalid-uuid';
      controller.phone.value = '+62';

      final created = await controller.submit();
      expect(created, isNull);
      expect(controller.submissionState.value, isA<UiFailure<Customer>>());
      expect(
        controller.submissionState.value.failureOrNull?.message,
        'Gagal membuat pelanggan',
      );
    });

    test('loadSegments transitions to UiSuccess', () async {
      final ctrl = CustomerFormController(FakeCustomerRepository(
        initialSegments: [const Segment(id: 's1', name: 'Villa')],
      ));
      await ctrl.loadSegments();
      expect(ctrl.segmentsState.value, isA<UiSuccess<List<Segment>>>());
      final data = (ctrl.segmentsState.value as UiSuccess<List<Segment>>).data;
      expect(data.length, 1);
      expect(data.first.name, 'Villa');
      ctrl.dispose();
    });

    test('loadSegments sets UiFailure on error', () async {
      final ctrl = CustomerFormController(FakeCustomerRepository(
        failSegments: true,
      ));
      await ctrl.loadSegments();
      expect(ctrl.segmentsState.value, isA<UiFailure<List<Segment>>>());
      ctrl.dispose();
    });

    test('loadInitialData populates all signals, locations, and contacts', () async {
      const existingCustomer = Customer(
        id: 'cust-123',
        code: 'CRM-1001',
        name: 'Grand Hotel Bali',
        initials: 'GH',
        segmentId: 'seg-hotel',
        segment: 'Hospitality',
        status: 'active',
        npwp: '01.234.567.8-999.000',
        phone: '+62 811 2233 4455',
        phoneAlt: '+62 811 2233 4456',
        email: 'info@grandhotelbali.com',
        riskNotes: 'VIP client, high volume',
        notes: 'Annual contract renewal every January',
        locations: [
          CustomerLocation(
            label: 'Main Resort Wing',
            addressLine: 'Jl. Pantai Kuta No. 99',
            province: 'Bali',
            regency: 'Badung',
            district: 'Kuta',
            village: 'Kuta',
            areaSize: 12000.0,
            latitude: -8.723,
            longitude: 115.169,
            isPrimary: true,
          ),
          CustomerLocation(
            label: 'Beach Club',
            addressLine: 'Jl. Pantai Kuta No. 100',
            province: 'Bali',
            regency: 'Badung',
            district: 'Kuta',
            village: 'Kuta',
            areaSize: 3500.0,
            isPrimary: false,
          ),
        ],
        contacts: [
          CustomerContact(
            name: 'Made Wijaya',
            position: 'General Manager',
            email: 'made@grandhotelbali.com',
            phone: '+62 811 2233 4455',
            role: 'pic',
            isPrimary: true,
          ),
          CustomerContact(
            name: 'Ketut Suardana',
            position: 'Chief Engineer',
            email: 'ketut@grandhotelbali.com',
            phone: '+62 811 2233 4457',
            role: 'pic_backup',
            isPrimary: false,
          ),
        ],
      );

      repository.customers.add(existingCustomer);

      expect(controller.customerId.value, isNull);
      expect(controller.isLoadingData.value, false);

      final loadFuture = controller.loadInitialData('cust-123');
      expect(controller.isLoadingData.value, true);
      expect(controller.customerId.value, 'cust-123');

      await loadFuture;
      expect(controller.isLoadingData.value, false);

      expect(controller.name.value, 'Grand Hotel Bali');
      expect(controller.code.value, 'CRM-1001');
      expect(controller.status.value, 'active');
      expect(controller.segmentId.value, 'seg-hotel');
      expect(controller.segment.value, 'Hospitality');
      expect(controller.npwp.value, '01.234.567.8-999.000');
      expect(controller.phone.value, '+62 811 2233 4455');
      expect(controller.phoneAlt.value, '+62 811 2233 4456');
      expect(controller.email.value, 'info@grandhotelbali.com');
      expect(controller.riskNotes.value, 'VIP client, high volume');
      expect(controller.notes.value, 'Annual contract renewal every January');

      // Verify locations mapped correctly
      expect(controller.locations.value.length, 2);
      final loc1 = controller.locations.value[0];
      expect(loc1.label, 'Main Resort Wing');
      expect(loc1.address, 'Jl. Pantai Kuta No. 99');
      expect(loc1.province, 'Bali');
      expect(loc1.regency, 'Badung');
      expect(loc1.district, 'Kuta');
      expect(loc1.village, 'Kuta');
      expect(loc1.areaSize, 12000.0);
      expect(loc1.latitude, -8.723);
      expect(loc1.longitude, 115.169);
      expect(loc1.isPrimary, true);

      final loc2 = controller.locations.value[1];
      expect(loc2.label, 'Beach Club');
      expect(loc2.address, 'Jl. Pantai Kuta No. 100');
      expect(loc2.isPrimary, false);

      // Verify contacts mapped correctly
      expect(controller.contacts.value.length, 2);
      final c1 = controller.contacts.value[0];
      expect(c1.name, 'Made Wijaya');
      expect(c1.position, 'General Manager');
      expect(c1.email, 'made@grandhotelbali.com');
      expect(c1.phone, '+62 811 2233 4455');
      expect(c1.role, 'pic');
      expect(c1.isPrimary, true);

      final c2 = controller.contacts.value[1];
      expect(c2.name, 'Ketut Suardana');
      expect(c2.position, 'Chief Engineer');
      expect(c2.email, 'ketut@grandhotelbali.com');
      expect(c2.phone, '+62 811 2233 4457');
      expect(c2.role, 'pic_backup');
      expect(c2.isPrimary, false);
    });

    test('loadInitialData resolves region IDs using RegionRepository', () async {
      final regionRepo = FakeRegionRepository()
        ..provinces = [const Province(id: 10, name: 'Bali')]
        ..regencies = [const Regency(id: 101, name: 'Badung')]
        ..districts = [
          const District(id: 1011, name: 'Kuta'),
        ]
        ..villages = [
          const Village(id: 10111, name: 'Seminyak'),
        ];

      final ctrl = CustomerFormController(repository, regionRepo);

      repository.customers.add(
        const Customer(
          id: 'cust-with-regions',
          code: 'CRM-1002',
          name: 'Villa Seminyak',
          initials: 'VS',
          segment: 'Villa',
          status: 'inactive',
          locations: [
            CustomerLocation(
              label: 'Villa 1',
              addressLine: 'Jl. Kayu Aya',
              province: 'Bali',
              regency: 'Badung',
              district: 'Kuta',
              village: 'Seminyak',
              isPrimary: true,
            ),
          ],
        ),
      );

      await ctrl.loadInitialData('cust-with-regions');

      expect(ctrl.status.value, 'inactive');
      expect(ctrl.locations.value.length, 1);
      final loc = ctrl.locations.value.first;
      expect(loc.provinceId, 10);
      expect(loc.regencyId, 101);
      expect(loc.districtId, 1011);
      expect(loc.villageId, 10111);

      ctrl.dispose();
    });

    test('loadInitialData handles not found gracefully', () async {
      await controller.loadInitialData('non-existent');
      expect(controller.isLoadingData.value, false);
      expect(controller.customerId.value, 'non-existent');
      expect(controller.name.value, '');
    });

    test('submit calls updateCustomer when customerId is set', () async {
      controller.customerId.value = 'cust-999';
      controller.name.value = 'Updated Name';
      controller.status.value = 'inactive';
      controller.segmentId.value = 'seg-1';
      controller.phone.value = '+62 812-0000';
      controller.updateLocation(
        0,
        controller.locations.value.first.copyWith(
          label: 'Updated Loc',
          address: 'Jl. Baru No. 1',
        ),
      );
      controller.updateContact(
        0,
        controller.contacts.value.first.copyWith(
          name: 'Updated Contact',
          phone: '+62 812-0000',
        ),
      );

      final updated = await controller.submit();
      expect(updated, isNotNull);
      expect(repository.lastUpdatedId, 'cust-999');
      expect(repository.lastUpdatedInput?.name, 'Updated Name');
      expect(repository.lastUpdatedInput?.status, 'inactive');
      expect(controller.submissionState.value, isA<UiSuccess<Customer>>());
    });

    test('submit in update mode sets UiFailure on update error', () async {
      repository.shouldFailUpdate = true;
      controller.customerId.value = 'cust-999';
      controller.name.value = 'Updated Name';
      controller.segmentId.value = 'seg-1';
      controller.phone.value = '+62 812-0000';

      final result = await controller.submit();
      expect(result, isNull);
      expect(controller.submissionState.value, isA<UiFailure<Customer>>());
      expect(
        controller.submissionState.value.failureOrNull?.message,
        'Gagal memperbarui pelanggan',
      );
    });
  });
}
