import 'package:flutter_test/flutter_test.dart';
import 'package:centrow_sales/modules/sales/entities/contract.dart';
import 'package:centrow_sales/modules/sales/repositories/dtos/contract_dto.dart';

void main() {
  group('ContractFormRequestDto', () {
    const inputWithAllFields = ContractFormInput(
      categoryId: 'cat-1',
      startDate: '2026-06-01',
      endDate: '2026-12-31',
      firstInvoiceDate: '2026-06-05',
      signedDate: '2026-06-01',
      paymentTypeId: 1,
      notes: 'Test contract notes',
      contractTemplateId: 'tmpl-abc',
    );

    test(
      'toCreateJson excludes end_date and includes contract_template_id',
      () {
        final dto = ContractFormRequestDto.fromInput(inputWithAllFields);
        final json = dto.toCreateJson();

        expect(json.containsKey('end_date'), isFalse);
        expect(json['contract_template_id'], 'tmpl-abc');
        expect(json['category_id'], 'cat-1');
        expect(json['start_date'], '2026-06-01');
        expect(json['signed_date'], '2026-06-01');
        expect(json['first_invoice_date'], '2026-06-05');
        expect(json['payment_type_id'], 1);
        expect(json['notes'], 'Test contract notes');
      },
    );

    test(
      'toUpdateJson excludes contract_template_id and includes end_date',
      () {
        final dto = ContractFormRequestDto.fromInput(inputWithAllFields);
        final json = dto.toUpdateJson();

        expect(json.containsKey('contract_template_id'), isFalse);
        expect(json['end_date'], '2026-12-31');
        expect(json['category_id'], 'cat-1');
        expect(json['start_date'], '2026-06-01');
        expect(json['signed_date'], '2026-06-01');
        expect(json['first_invoice_date'], '2026-06-05');
        expect(json['payment_type_id'], 1);
        expect(json['notes'], 'Test contract notes');
      },
    );

    test('toUpdateJson omits end_date if null or empty', () {
      const inputWithoutEndDate = ContractFormInput(
        categoryId: 'cat-1',
        startDate: '2026-06-01',
        endDate: null,
        signedDate: '2026-06-01',
        paymentTypeId: 1,
        notes: 'Notes',
      );
      final dto = ContractFormRequestDto.fromInput(inputWithoutEndDate);
      final json = dto.toUpdateJson();

      expect(json.containsKey('end_date'), isFalse);
      expect(json.containsKey('contract_template_id'), isFalse);
    });
  });

  group('ContractDetailDto', () {
    test('fromJson parses scheduleWorkOrderType and maps it to entity', () {
      final json = {
        'id': 'ctr-1',
        'code': 'CTR-001',
        'customer_id': 'cust-1',
        'customer_name': 'PT Maju Terus',
        'service_id': 'srv-1',
        'service_name': 'General Pest Control',
        'category_id': 'cat-1',
        'category_name': 'Kategori A',
        'start_date': '2026-01-01',
        'contract_value': 12000000.0,
        'payment_type': 'monthly',
        'status': 'active',
        'schedule_work_order_type': 1,
      };

      final dto = ContractDetailDto.fromJson(json);
      expect(dto.scheduleWorkOrderType, 1);
      expect(dto.toEntity().scheduleWorkOrderType, 1);
    });

    test('fromJson scheduleWorkOrderType is null when field is absent', () {
      final json = {
        'id': 'ctr-2',
        'code': 'CTR-002',
        'customer_id': 'cust-2',
        'customer_name': 'PT Baik Sekali',
        'service_id': 'srv-2',
        'service_name': 'Rodent Control',
        'category_id': 'cat-2',
        'category_name': 'Kategori B',
        'start_date': '2026-02-01',
        'contract_value': 8000000.0,
        'payment_type': 'full',
        'status': 'draft',
        // schedule_work_order_type intentionally omitted
      };

      final dto = ContractDetailDto.fromJson(json);
      expect(dto.scheduleWorkOrderType, isNull);
      expect(dto.toEntity().scheduleWorkOrderType, isNull);
    });
  });
}
