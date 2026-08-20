import 'package:flutter_test/flutter_test.dart';
import 'package:centrow_sales/modules/sales/controllers/add_customer_controller.dart';
import 'package:centrow_sales/modules/sales/entities/create_customer_input.dart';
import 'package:centrow_sales/modules/sales/entities/customer.dart';
import 'package:centrow_sales/modules/sales/entities/segment.dart';
import 'package:centrow_sales/modules/sales/repositories/customer_repository.dart';
import 'package:centrow_sales/shared/error/failure.dart';
import 'package:centrow_sales/shared/result/result.dart';
import 'package:centrow_sales/shared/state/ui_state.dart';

class FakeCustomerRepository implements CustomerRepository {
  List<Customer> customers = [];
  bool shouldFailCreate = false;
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
      status: input.status.isNotEmpty ? input.status : 'active',
      regency: input.regency,
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
                regency: l.regency,
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
  group('AddCustomerController', () {
    late FakeCustomerRepository repository;
    late AddCustomerController controller;

    setUp(() {
      repository = FakeCustomerRepository();
      controller = AddCustomerController(repository);
    });

    tearDown(() {
      controller.dispose();
    });

    test('initial state is cleared and default values are set', () {
      expect(controller.segmentsState.value, isA<UiInitial<List<Segment>>>());
      expect(controller.currentStep.value, 1);
      expect(controller.name.value, '');
      expect(controller.code.value, '');
      expect(controller.segmentId.value, '');
      expect(controller.segment.value, '');
      expect(controller.regency.value, '');
      expect(controller.status.value, 'active');
      expect(controller.scanCode.value, '');
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
      final ctrl = AddCustomerController(FakeCustomerRepository(
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
      final ctrl = AddCustomerController(FakeCustomerRepository(
        failSegments: true,
      ));
      await ctrl.loadSegments();
      expect(ctrl.segmentsState.value, isA<UiFailure<List<Segment>>>());
      ctrl.dispose();
    });
  });
}
