import 'package:flutter_test/flutter_test.dart';
import 'package:centrow_sales/modules/sales/entities/contract.dart';
import 'package:centrow_sales/modules/sales/repositories/dtos/contract_dto.dart';

void main() {
  group('Contract entity visit frequency helpers', () {
    const baseContract = Contract(
      id: 'ctr-1',
      code: 'CTR-001',
      customerId: 'cust-1',
      serviceId: 'srv-1',
      categoryId: 'cat-1',
      status: ContractStatus.active,
      startDate: '2026-01-01',
    );

    group('visitFrequencyLabel', () {
      test('returns monthly label when scheduleCycle is monthly', () {
        final contract = baseContract.copyWith(
          scheduleCycle: ContractScheduleCycle.monthly,
        );
        expect(contract.visitFrequencyLabel, 'FREK. KUNJUNGAN (BULANAN)');
      });

      test('returns yearly label when scheduleCycle is yearly', () {
        final contract = baseContract.copyWith(
          scheduleCycle: ContractScheduleCycle.yearly,
        );
        expect(contract.visitFrequencyLabel, 'FREK. KUNJUNGAN (TAHUNAN)');
      });

      test('returns total kunjungan label when scheduleCycle is null', () {
        const contract = baseContract;
        expect(contract.visitFrequencyLabel, 'TOTAL KUNJUNGAN');
      });
    });

    group('formattedVisitFrequency', () {
      test('returns dash when totalVisits is null regardless of cycle', () {
        final contractMonthly = baseContract.copyWith(
          scheduleCycle: ContractScheduleCycle.monthly,
          totalVisits: null,
        );
        expect(contractMonthly.formattedVisitFrequency, '-');

        final contractYearly = baseContract.copyWith(
          scheduleCycle: ContractScheduleCycle.yearly,
          totalVisits: null,
        );
        expect(contractYearly.formattedVisitFrequency, '-');

        const contractNullCycle = baseContract;
        expect(contractNullCycle.formattedVisitFrequency, '-');
      });

      test('formats monthly frequency correctly', () {
        final contract = baseContract.copyWith(
          scheduleCycle: ContractScheduleCycle.monthly,
          totalVisits: 4,
        );
        expect(contract.formattedVisitFrequency, '4 x / bulan');
      });

      test('formats yearly frequency correctly', () {
        final contract = baseContract.copyWith(
          scheduleCycle: ContractScheduleCycle.yearly,
          totalVisits: 24,
        );
        expect(contract.formattedVisitFrequency, '24 x / tahun');
      });

      test(
        'formats fallback frequency correctly when scheduleCycle is null',
        () {
          final contract = baseContract.copyWith(totalVisits: 12);
          expect(contract.formattedVisitFrequency, '12x');
        },
      );
    });

    group('copyWith scheduleCycle', () {
      test('updates scheduleCycle', () {
        final contract = baseContract.copyWith(
          scheduleCycle: ContractScheduleCycle.monthly,
        );
        expect(contract.scheduleCycle, ContractScheduleCycle.monthly);

        final updated = contract.copyWith(
          scheduleCycle: ContractScheduleCycle.yearly,
        );
        expect(updated.scheduleCycle, ContractScheduleCycle.yearly);
      });
    });
  });

  group('ContractDetailDto schedule cycle parsing and mapping', () {
    test('parses schedule_cycle = 2 as monthly', () {
      final json = {
        'id': 'ctr-1',
        'code': 'CTR-001',
        'customer_id': 'cust-1',
        'service_id': 'srv-1',
        'category_id': 'cat-1',
        'start_date': '2026-01-01',
        'status': 'active',
        'schedule_cycle': 2,
        'total_visits': 3,
      };

      final dto = ContractDetailDto.fromJson(json);
      expect(dto.scheduleCycle, 2);

      final entity = dto.toEntity();
      expect(entity.scheduleCycle, ContractScheduleCycle.monthly);
      expect(entity.visitFrequencyLabel, 'FREK. KUNJUNGAN (BULANAN)');
      expect(entity.formattedVisitFrequency, '3 x / bulan');
    });

    test('falls back to category_schedule_cycle = 1 as yearly', () {
      final json = {
        'id': 'ctr-2',
        'code': 'CTR-002',
        'customer_id': 'cust-1',
        'service_id': 'srv-1',
        'category_id': 'cat-1',
        'start_date': '2026-01-01',
        'status': 'draft',
        'category_schedule_cycle': 1,
        'total_visits': 12,
      };

      final dto = ContractDetailDto.fromJson(json);
      expect(dto.scheduleCycle, 1);

      final entity = dto.toEntity();
      expect(entity.scheduleCycle, ContractScheduleCycle.yearly);
      expect(entity.visitFrequencyLabel, 'FREK. KUNJUNGAN (TAHUNAN)');
      expect(entity.formattedVisitFrequency, '12 x / tahun');
    });

    test('handles missing schedule_cycle gracefully as null', () {
      final json = {
        'id': 'ctr-3',
        'code': 'CTR-003',
        'customer_id': 'cust-1',
        'service_id': 'srv-1',
        'category_id': 'cat-1',
        'start_date': '2026-01-01',
        'status': 'active',
      };

      final dto = ContractDetailDto.fromJson(json);
      expect(dto.scheduleCycle, isNull);

      final entity = dto.toEntity();
      expect(entity.scheduleCycle, isNull);
      expect(entity.visitFrequencyLabel, 'TOTAL KUNJUNGAN');
      expect(entity.formattedVisitFrequency, '-');
    });
  });

  group('ContractListItemDto schedule cycle parsing and mapping', () {
    test('parses schedule_cycle and maps to entity', () {
      final json = {
        'id': 'ctr-1',
        'code': 'CTR-001',
        'customer_id': 'cust-1',
        'customer_name': 'PT Centrow',
        'service_id': 'srv-1',
        'service_name': 'Pest Control',
        'category_id': 'cat-1',
        'category_name': 'Commercial',
        'start_date': '2026-01-01',
        'contract_value': 1000000,
        'payment_type': 'full',
        'status': 'active',
        'schedule_cycle': 2,
      };

      final dto = ContractListItemDto.fromJson(json);
      expect(dto.scheduleCycle, 2);

      final entity = dto.toEntity();
      expect(entity.scheduleCycle, ContractScheduleCycle.monthly);
    });

    test('parses category_schedule_cycle as fallback and maps to entity', () {
      final json = {
        'id': 'ctr-2',
        'code': 'CTR-002',
        'customer_id': 'cust-1',
        'customer_name': 'PT Centrow',
        'service_id': 'srv-1',
        'service_name': 'Pest Control',
        'category_id': 'cat-1',
        'category_name': 'Commercial',
        'start_date': '2026-01-01',
        'contract_value': 1000000,
        'payment_type': 'full',
        'status': 'active',
        'category_schedule_cycle': 1,
      };

      final dto = ContractListItemDto.fromJson(json);
      expect(dto.scheduleCycle, 1);

      final entity = dto.toEntity();
      expect(entity.scheduleCycle, ContractScheduleCycle.yearly);
    });
  });
}
