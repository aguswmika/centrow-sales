import 'package:flutter_test/flutter_test.dart';
import 'package:centrow_sales/shared/error/failure.dart';
import 'package:centrow_sales/shared/result/result.dart';
import 'package:centrow_sales/shared/state/ui_state.dart';
import 'package:centrow_sales/modules/sales/controllers/site_risk_controller.dart';
import 'package:centrow_sales/modules/sales/entities/site_risk.dart';
import 'package:centrow_sales/modules/sales/repositories/site_risk_repository.dart';

class FakeSiteRiskRepository implements SiteRiskRepository {
  Result<List<SiteRiskMaster>> masterRisksResult;
  Result<List<CustomerAddressRisk>> addressRisksResult;
  Result<List<CustomerAddressRisk>> updateAddressRisksResult;

  String? lastCustomerId;
  String? lastAddressId;
  List<String>? lastSiteRiskIds;
  List<String>? lastCustomRisks;

  FakeSiteRiskRepository({
    this.masterRisksResult = const Ok([]),
    this.addressRisksResult = const Ok([]),
    this.updateAddressRisksResult = const Ok([]),
  });

  @override
  Future<Result<List<SiteRiskMaster>>> getSiteRiskMasters() async {
    return masterRisksResult;
  }

  @override
  Future<Result<List<CustomerAddressRisk>>> getAddressRisks({
    required String customerId,
    required String addressId,
  }) async {
    lastCustomerId = customerId;
    lastAddressId = addressId;
    return addressRisksResult;
  }

  @override
  Future<Result<List<CustomerAddressRisk>>> updateAddressRisks({
    required String customerId,
    required String addressId,
    required List<String> siteRiskIds,
    required List<String> customRisks,
  }) async {
    lastCustomerId = customerId;
    lastAddressId = addressId;
    lastSiteRiskIds = siteRiskIds;
    lastCustomRisks = customRisks;
    return updateAddressRisksResult;
  }
}

void main() {
  late FakeSiteRiskRepository repository;
  late SiteRiskController controller;

  setUp(() {
    repository = FakeSiteRiskRepository();
    controller = SiteRiskController(repository);
  });

  tearDown(() {
    controller.dispose();
  });

  group('SiteRiskController - Initial State', () {
    test('has correct initial states', () {
      expect(
        controller.masterRisks.value,
        isA<UiInitial<List<SiteRiskMaster>>>(),
      );
      expect(
        controller.addressRisks.value,
        isA<UiInitial<List<CustomerAddressRisk>>>(),
      );
      expect(
        controller.saveState.value,
        isA<UiInitial<List<CustomerAddressRisk>>>(),
      );
      expect(controller.selectedSiteRiskIds.value, isEmpty);
      expect(controller.customRisks.value, isEmpty);
    });
  });

  group('SiteRiskController - loadMasterRisks', () {
    test('sets UiSuccess on successful fetch', () async {
      const masters = [
        SiteRiskMaster(id: 'm1', name: 'Master Risk 1'),
        SiteRiskMaster(id: 'm2', name: 'Master Risk 2'),
      ];
      repository.masterRisksResult = const Ok(masters);

      await controller.loadMasterRisks();

      final state = controller.masterRisks.value;
      expect(state, isA<UiSuccess<List<SiteRiskMaster>>>());
      expect((state as UiSuccess<List<SiteRiskMaster>>).data, masters);
    });

    test('sets UiFailure on repository error', () async {
      const failure = ServerFailure('Gagal memuat master risiko');
      repository.masterRisksResult = const Err(failure);

      await controller.loadMasterRisks();

      final state = controller.masterRisks.value;
      expect(state, isA<UiFailure<List<SiteRiskMaster>>>());
      expect((state as UiFailure<List<SiteRiskMaster>>).failure, failure);
    });
  });

  group('SiteRiskController - loadAddressRisks', () {
    test(
      'populates addressRisks, selectedSiteRiskIds, and customRisks on success',
      () async {
        const addressRisks = [
          CustomerAddressRisk(
            id: 'ar1',
            siteRiskId: 'm1',
            name: 'Master Risk 1',
            isCustom: false,
          ),
          CustomerAddressRisk(
            id: 'ar2',
            siteRiskId: 'm2',
            name: 'Master Risk 2',
            isCustom: false,
          ),
          CustomerAddressRisk(
            id: 'ar3',
            siteRiskId: null,
            name: 'Anjing galak',
            isCustom: true,
          ),
        ];
        repository.addressRisksResult = const Ok(addressRisks);

        await controller.loadAddressRisks('cust-1', 'addr-1');

        expect(repository.lastCustomerId, 'cust-1');
        expect(repository.lastAddressId, 'addr-1');

        final state = controller.addressRisks.value;
        expect(state, isA<UiSuccess<List<CustomerAddressRisk>>>());
        expect(
          (state as UiSuccess<List<CustomerAddressRisk>>).data,
          addressRisks,
        );

        expect(controller.selectedSiteRiskIds.value, {'m1', 'm2'});
        expect(controller.customRisks.value, ['Anjing galak']);
      },
    );

    test('sets UiFailure on error', () async {
      const failure = ServerFailure('Gagal memuat risiko alamat', 404);
      repository.addressRisksResult = const Err(failure);

      await controller.loadAddressRisks('cust-1', 'addr-1');

      final state = controller.addressRisks.value;
      expect(state, isA<UiFailure<List<CustomerAddressRisk>>>());
      expect((state as UiFailure<List<CustomerAddressRisk>>).failure, failure);
      expect(controller.selectedSiteRiskIds.value, isEmpty);
      expect(controller.customRisks.value, isEmpty);
    });
  });

  group('SiteRiskController - toggleMasterRisk', () {
    test('adds id when not present', () {
      controller.toggleMasterRisk('m1');
      expect(controller.selectedSiteRiskIds.value, {'m1'});

      controller.toggleMasterRisk('m2');
      expect(controller.selectedSiteRiskIds.value, {'m1', 'm2'});
    });

    test('removes id when already present', () {
      controller.toggleMasterRisk('m1');
      controller.toggleMasterRisk('m2');
      expect(controller.selectedSiteRiskIds.value, {'m1', 'm2'});

      controller.toggleMasterRisk('m1');
      expect(controller.selectedSiteRiskIds.value, {'m2'});

      controller.toggleMasterRisk('m2');
      expect(controller.selectedSiteRiskIds.value, isEmpty);
    });
  });

  group('SiteRiskController - addCustomRisk', () {
    test('adds trimmed custom risk', () {
      controller.addCustomRisk('   Tangga licin   ');
      expect(controller.customRisks.value, ['Tangga licin']);
    });

    test('ignores empty or whitespace-only name', () {
      controller.addCustomRisk('');
      controller.addCustomRisk('    ');
      expect(controller.customRisks.value, isEmpty);
    });

    test('ignores name exceeding 255 characters', () {
      final longName = 'a' * 256;
      controller.addCustomRisk(longName);
      expect(controller.customRisks.value, isEmpty);

      final validName = 'a' * 255;
      controller.addCustomRisk(validName);
      expect(controller.customRisks.value, [validName]);
    });

    test('ignores duplicate custom risk', () {
      controller.addCustomRisk('Tangga licin');
      controller.addCustomRisk('Tangga licin');
      expect(controller.customRisks.value, ['Tangga licin']);
    });
  });

  group('SiteRiskController - removeCustomRisk', () {
    test('removes item at given index', () {
      controller.addCustomRisk('Risk A');
      controller.addCustomRisk('Risk B');
      controller.addCustomRisk('Risk C');
      expect(controller.customRisks.value, ['Risk A', 'Risk B', 'Risk C']);

      controller.removeCustomRisk(1);
      expect(controller.customRisks.value, ['Risk A', 'Risk C']);
    });

    test('ignores negative or out of bounds index', () {
      controller.addCustomRisk('Risk A');
      controller.removeCustomRisk(-1);
      controller.removeCustomRisk(5);
      expect(controller.customRisks.value, ['Risk A']);
    });
  });

  group('SiteRiskController - saveAddressRisks', () {
    test(
      'calls repository with selected and custom risks and updates state on success',
      () async {
        controller.toggleMasterRisk('m1');
        controller.toggleMasterRisk('m2');
        controller.addCustomRisk('Custom Hazard');

        const savedRisks = [
          CustomerAddressRisk(
            id: 'ar1',
            siteRiskId: 'm1',
            name: 'Master 1',
            isCustom: false,
          ),
          CustomerAddressRisk(
            id: 'ar2',
            siteRiskId: 'm2',
            name: 'Master 2',
            isCustom: false,
          ),
          CustomerAddressRisk(
            id: 'ar3',
            siteRiskId: null,
            name: 'Custom Hazard',
            isCustom: true,
          ),
        ];
        repository.updateAddressRisksResult = const Ok(savedRisks);

        await controller.saveAddressRisks('cust-1', 'addr-1');

        expect(repository.lastCustomerId, 'cust-1');
        expect(repository.lastAddressId, 'addr-1');
        expect(repository.lastSiteRiskIds, containsAll(['m1', 'm2']));
        expect(repository.lastCustomRisks, ['Custom Hazard']);

        final saveState = controller.saveState.value;
        expect(saveState, isA<UiSuccess<List<CustomerAddressRisk>>>());
        expect(
          (saveState as UiSuccess<List<CustomerAddressRisk>>).data,
          savedRisks,
        );

        final addressRisks = controller.addressRisks.value;
        expect(addressRisks, isA<UiSuccess<List<CustomerAddressRisk>>>());
        expect(
          (addressRisks as UiSuccess<List<CustomerAddressRisk>>).data,
          savedRisks,
        );
      },
    );

    test(
      'sets saveState to UiFailure on failure without breaking selected risks',
      () async {
        controller.toggleMasterRisk('m1');
        controller.addCustomRisk('Custom Hazard');

        const failure = ServerFailure('Gagal menyimpan perubahan', 500);
        repository.updateAddressRisksResult = const Err(failure);

        await controller.saveAddressRisks('cust-1', 'addr-1');

        final saveState = controller.saveState.value;
        expect(saveState, isA<UiFailure<List<CustomerAddressRisk>>>());
        expect(
          (saveState as UiFailure<List<CustomerAddressRisk>>).failure,
          failure,
        );

        // Form selections are retained so the user doesn't lose their input
        expect(controller.selectedSiteRiskIds.value, {'m1'});
        expect(controller.customRisks.value, ['Custom Hazard']);
      },
    );
  });
}
