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

    test('visitFrequencyLabel returns TOTAL KUNJUNGAN', () {
      expect(baseContract.visitFrequencyLabel, 'TOTAL KUNJUNGAN');
    });

    test('formattedVisitFrequency formats totalVisits correctly', () {
      final contractWithVisits = baseContract.copyWith(totalVisits: 12);
      expect(contractWithVisits.formattedVisitFrequency, '12x');

      const contractZeroVisits = baseContract;
      expect(contractZeroVisits.formattedVisitFrequency, '0x');
    });
  });

  group('ContractDetailDto total visits parsing and mapping', () {
    test('parses total_visits and maps to entity', () {
      final json = {
        'id': 'ctr-1',
        'code': 'CTR-001',
        'customer_id': 'cust-1',
        'service_id': 'srv-1',
        'category_id': 'cat-1',
        'start_date': '2026-01-01',
        'status': 'active',
        'total_visits': 12,
      };

      final dto = ContractDetailDto.fromJson(json);
      expect(dto.totalVisits, 12);

      final entity = dto.toEntity();
      expect(entity.totalVisits, 12);
      expect(entity.visitFrequencyLabel, 'TOTAL KUNJUNGAN');
      expect(entity.formattedVisitFrequency, '12x');
    });

    test('handles missing total_visits gracefully as null', () {
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
      expect(dto.totalVisits, isNull);

      final entity = dto.toEntity();
      expect(entity.totalVisits, isNull);
      expect(entity.visitFrequencyLabel, 'TOTAL KUNJUNGAN');
      expect(entity.formattedVisitFrequency, '0x');
    });
  });
}
