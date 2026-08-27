import 'package:flutter_test/flutter_test.dart';
import 'package:centrow_sales/modules/pc/entities/product_mapping.dart';

void main() {
  group('ProductMapping Entity', () {
    test('instantiates with all required and optional properties', () {
      const mapping = ProductMapping(
        id: 'pm-1',
        productId: 'prod-1',
        productCode: 'PRD-01',
        productName: 'Termiticide X',
        pestId: 'pest-1',
        pestCode: 'PST-01',
        pestName: 'Rayap Kayu Kering',
        treatmentMethodId: 'tm-1',
        treatmentMethodCode: 'SPRAY',
        treatmentMethodName: 'Spraying',
        doseMinLimit: 5.0,
        doseMaxLimit: 15.0,
        doseUnitId: 'du-1',
        doseUnitCode: 'ML',
        doseUnitName: 'Mililiter',
        defaultDose: 10.0,
        notes: 'Gunakan sarung tangan saat aplikasi',
        isActive: true,
      );

      expect(mapping.id, 'pm-1');
      expect(mapping.productId, 'prod-1');
      expect(mapping.productCode, 'PRD-01');
      expect(mapping.productName, 'Termiticide X');
      expect(mapping.pestId, 'pest-1');
      expect(mapping.pestCode, 'PST-01');
      expect(mapping.pestName, 'Rayap Kayu Kering');
      expect(mapping.treatmentMethodId, 'tm-1');
      expect(mapping.treatmentMethodCode, 'SPRAY');
      expect(mapping.treatmentMethodName, 'Spraying');
      expect(mapping.doseMinLimit, 5.0);
      expect(mapping.doseMaxLimit, 15.0);
      expect(mapping.doseUnitId, 'du-1');
      expect(mapping.doseUnitCode, 'ML');
      expect(mapping.doseUnitName, 'Mililiter');
      expect(mapping.defaultDose, 10.0);
      expect(mapping.notes, 'Gunakan sarung tangan saat aplikasi');
      expect(mapping.isActive, true);
    });

    test('default value for isActive is true', () {
      const mapping = ProductMapping(
        id: 'pm-2',
        productId: 'prod-2',
        productName: 'Rodenticide Y',
        pestId: 'pest-2',
        pestName: 'Tikus Got',
        treatmentMethodId: 'tm-2',
        treatmentMethodCode: 'BAIT',
        doseMinLimit: 1.0,
        doseMaxLimit: 3.0,
        doseUnitId: 'du-2',
        doseUnitCode: 'GR',
      );

      expect(mapping.isActive, true);
      expect(mapping.productCode, isNull);
      expect(mapping.pestCode, isNull);
      expect(mapping.treatmentMethodName, isNull);
      expect(mapping.doseUnitName, isNull);
      expect(mapping.defaultDose, isNull);
      expect(mapping.notes, isNull);
    });
  });
}
