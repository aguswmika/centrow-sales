import 'package:flutter_test/flutter_test.dart';
import 'package:centrow_sales/modules/pc/entities/treatment_method.dart';

void main() {
  group('TreatmentMethod Entity', () {
    test('instantiates with defaults', () {
      const method = TreatmentMethod(
        id: 'tm-1',
        code: 'SPRAY',
        name: 'Spraying',
      );

      expect(method.id, 'tm-1');
      expect(method.code, 'SPRAY');
      expect(method.name, 'Spraying');
      expect(method.description, isNull);
      expect(method.isActive, true);
    });

    test('instantiates with explicit fields', () {
      const method = TreatmentMethod(
        id: 'tm-1',
        code: 'SPRAY',
        name: 'Spraying',
        description: 'Desc',
        isActive: true,
      );

      expect(method.description, 'Desc');
      expect(method.isActive, true);
    });

    test('copyWith updates fields', () {
      const method = TreatmentMethod(
        id: 'tm-1',
        code: 'SPRAY',
        name: 'Spraying',
      );

      final updated = method.copyWith(name: 'Spraying Pro');
      expect(updated.name, 'Spraying Pro');
      expect(updated.id, 'tm-1');
      expect(updated.code, 'SPRAY');
    });

    test('equality and hashCode', () {
      const method1 = TreatmentMethod(
        id: 'tm-1',
        code: 'SPRAY',
        name: 'Spraying',
      );
      const method2 = TreatmentMethod(
        id: 'tm-1',
        code: 'SPRAY',
        name: 'Spraying',
      );
      const method3 = TreatmentMethod(
        id: 'tm-2',
        code: 'MIST',
        name: 'Misting',
      );

      expect(method1, equals(method2));
      expect(method1.hashCode, equals(method2.hashCode));
      expect(method1, isNot(equals(method3)));
      expect(method1.hashCode, isNot(equals(method3.hashCode)));
    });

    test('toString representation', () {
      const method = TreatmentMethod(
        id: 'tm-1',
        code: 'SPRAY',
        name: 'Spraying',
      );

      expect(method.toString(), contains('TreatmentMethod('));
      expect(method.toString(), contains('SPRAY'));
    });
  });
}
