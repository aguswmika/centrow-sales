import 'package:flutter_test/flutter_test.dart';
import 'package:centrow_sales/modules/sales/entities/contract_addendum.dart';

void main() {
  group('ContractAddendum Entity', () {
    test('formats positive visit delta and values correctly', () {
      const addendum = ContractAddendum(
        id: 'add-1',
        contractId: 'c-1',
        visitDelta: 2,
        oldTotalVisits: 10,
        newTotalVisits: 12,
        oldContractValue: 10000000.0,
        newContractValue: 12000000.0,
        reason: 'Penambahan area',
        createdBy: 'Admin',
        createdAt: '2026-03-01 10:00:00',
      );

      expect(addendum.formattedVisitDelta, '+2');
      expect(addendum.formattedOldContractValue, 'Rp 10.000.000');
      expect(addendum.formattedNewContractValue, 'Rp 12.000.000');
      expect(addendum.contractValueDelta, 2000000.0);
      expect(addendum.formattedContractValueDelta, '+Rp 2.000.000');
    });

    test('formats negative visit delta and values correctly', () {
      const addendum = ContractAddendum(
        id: 'add-2',
        contractId: 'c-1',
        visitDelta: -3,
        oldTotalVisits: 12,
        newTotalVisits: 9,
        oldContractValue: 12000000.0,
        newContractValue: 9000000.0,
      );

      expect(addendum.formattedVisitDelta, '-3');
      expect(addendum.contractValueDelta, -3000000.0);
      expect(addendum.formattedContractValueDelta, '-Rp 3.000.000');
    });

    test('formats zero delta value correctly', () {
      const addendum = ContractAddendum(
        id: 'add-3',
        contractId: 'c-1',
        visitDelta: 0,
        oldTotalVisits: 10,
        newTotalVisits: 10,
        oldContractValue: 10000000.0,
        newContractValue: 10000000.0,
      );

      expect(addendum.formattedVisitDelta, '0');
      expect(addendum.contractValueDelta, 0.0);
      expect(addendum.formattedContractValueDelta, 'Rp 0');
    });

    test('supports optional pricingId and defaults to null', () {
      const withoutPricing = ContractAddendum(
        id: 'add-default',
        contractId: 'c-1',
        visitDelta: 1,
        oldTotalVisits: 5,
        newTotalVisits: 6,
        oldContractValue: 1000,
        newContractValue: 2000,
      );
      expect(withoutPricing.pricingId, isNull);

      const withPricing = ContractAddendum(
        id: 'add-pricing',
        contractId: 'c-1',
        visitDelta: 1,
        oldTotalVisits: 5,
        newTotalVisits: 6,
        oldContractValue: 1000,
        newContractValue: 2000,
        pricingId: 'pricing-123',
      );
      expect(withPricing.pricingId, 'pricing-123');
      expect(withPricing.toString(), contains('pricingId: pricing-123'));
    });
  });
}
