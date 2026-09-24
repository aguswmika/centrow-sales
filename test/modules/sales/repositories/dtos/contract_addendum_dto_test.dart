import 'package:flutter_test/flutter_test.dart';
import 'package:centrow_sales/modules/sales/repositories/dtos/contract_addendum_dto.dart';

void main() {
  group('ContractAddendumDto', () {
    test('parses from snake_case json and maps to entity', () {
      final json = {
        'id': 'add-10',
        'contract_id': 'c-10',
        'visit_delta': 4,
        'old_total_visits': 12,
        'new_total_visits': 16,
        'old_contract_value': 12000000,
        'new_contract_value': 16000000,
        'pricing_id': 'price-10',
        'reason': 'Permintaan pelanggan',
        'created_by': 'Budi Sales',
        'created_at': '2026-03-10 14:00:00',
      };

      final dto = ContractAddendumDto.fromJson(json);
      expect(dto.id, 'add-10');
      expect(dto.contractId, 'c-10');
      expect(dto.visitDelta, 4);
      expect(dto.oldTotalVisits, 12);
      expect(dto.newTotalVisits, 16);
      expect(dto.oldContractValue, 12000000.0);
      expect(dto.newContractValue, 16000000.0);
      expect(dto.pricingId, 'price-10');
      expect(dto.reason, 'Permintaan pelanggan');
      expect(dto.createdBy, 'Budi Sales');
      expect(dto.createdAt, '2026-03-10 14:00:00');

      final entity = dto.toEntity();
      expect(entity.id, 'add-10');
      expect(entity.visitDelta, 4);
      expect(entity.pricingId, 'price-10');
      expect(entity.formattedVisitDelta, '+4');
    });

    test('parses nested creator and camelCase fallback correctly', () {
      final json = {
        'id': 'add-11',
        'contractId': 'c-11',
        'visitDelta': '-2',
        'oldTotalVisits': '10',
        'newTotalVisits': '8',
        'oldContractValue': '10000000.5',
        'newContractValue': '8000000.5',
        'pricingId': 'price-11',
        'creator': {'name': 'Supervisor User'},
        'createdAt': '2026-03-11',
      };

      final dto = ContractAddendumDto.fromJson(json);
      expect(dto.contractId, 'c-11');
      expect(dto.visitDelta, -2);
      expect(dto.oldTotalVisits, 10);
      expect(dto.newTotalVisits, 8);
      expect(dto.oldContractValue, 10000000.5);
      expect(dto.newContractValue, 8000000.5);
      expect(dto.pricingId, 'price-11');
      expect(dto.createdBy, 'Supervisor User');
      expect(dto.createdAt, '2026-03-11');
    });

    test('serializes to JSON correctly without pricing_id', () {
      const dto = ContractAddendumDto(
        id: 'add-1',
        contractId: 'c-1',
        visitDelta: 1,
        oldTotalVisits: 5,
        newTotalVisits: 6,
        oldContractValue: 5000000.0,
        newContractValue: 6000000.0,
        reason: 'Penyesuaian',
      );

      final json = dto.toJson();
      expect(json['id'], 'add-1');
      expect(json['contract_id'], 'c-1');
      expect(json['visit_delta'], 1);
      expect(json['reason'], 'Penyesuaian');
      expect(json.containsKey('pricing_id'), isFalse);
    });

    test('serializes to JSON correctly with pricing_id', () {
      const dto = ContractAddendumDto(
        id: 'add-2',
        contractId: 'c-2',
        visitDelta: 2,
        oldTotalVisits: 5,
        newTotalVisits: 7,
        oldContractValue: 5000000.0,
        newContractValue: 7000000.0,
        pricingId: 'price-99',
      );

      final json = dto.toJson();
      expect(json['pricing_id'], 'price-99');
    });
  });
}
