import 'package:flutter_test/flutter_test.dart';
import 'package:centrow_sales/shared/sync/data_sync_event.dart';
import 'package:centrow_sales/shared/sync/data_sync_service.dart';

void main() {
  group('DataSyncService', () {
    late DataSyncService service;

    setUp(() {
      service = DataSyncServiceImpl();
    });

    tearDown(() {
      service.dispose();
    });

    test('emits and receives CustomerSyncEvent', () async {
      final events = <DataSyncEvent>[];
      final sub = service.events.listen(events.add);

      service.emit(const CustomerSyncEvent('c1'));
      await pumpEventQueue();

      expect(events.length, 1);
      expect(events.first, isA<CustomerSyncEvent>());
      expect((events.first as CustomerSyncEvent).customerId, 'c1');
      expect((events.first as CustomerSyncEvent).action, SyncAction.updated);

      await sub.cancel();
    });

    test(
      'emits and receives ProposalSyncEvent, PricingSyncEvent, ContractSyncEvent',
      () async {
        final events = <DataSyncEvent>[];
        final sub = service.events.listen(events.add);

        service.emit(const ProposalSyncEvent('p1', customerId: 'c1'));
        service.emit(const PricingSyncEvent('p1'));
        service.emit(const ContractSyncEvent('k1', proposalId: 'p1'));
        await pumpEventQueue();

        expect(events.length, 3);
        expect(events[0], isA<ProposalSyncEvent>());
        expect(events[1], isA<PricingSyncEvent>());
        expect(events[2], isA<ContractSyncEvent>());

        await sub.cancel();
      },
    );

    test('supports multiple subscribers (broadcast)', () async {
      final list1 = <DataSyncEvent>[];
      final list2 = <DataSyncEvent>[];

      final sub1 = service.events.listen(list1.add);
      final sub2 = service.events.listen(list2.add);

      service.emit(const CustomerSyncEvent('c2', action: SyncAction.created));
      await pumpEventQueue();

      expect(list1.length, 1);
      expect(list2.length, 1);

      await sub1.cancel();
      await sub2.cancel();
    });
  });
}
