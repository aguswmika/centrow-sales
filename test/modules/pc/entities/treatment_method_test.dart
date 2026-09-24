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
      expect(method.isRequired, false);
      expect(method.isActive, true);
    });

    test('instantiates with explicit isRequired', () {
      const method = TreatmentMethod(
        id: 'tm-1',
        code: 'SPRAY',
        name: 'Spraying',
        description: 'Desc',
        isRequired: true,
        isActive: true,
      );

      expect(method.isRequired, true);
    });

    test('copyWith updates isRequired and other fields', () {
      const method = TreatmentMethod(
        id: 'tm-1',
        code: 'SPRAY',
        name: 'Spraying',
        isRequired: false,
      );

      final updated = method.copyWith(isRequired: true);
      expect(updated.isRequired, true);
      expect(updated.id, 'tm-1');
      expect(updated.code, 'SPRAY');
      expect(updated.name, 'Spraying');
    });

    test('equality and hashCode include isRequired', () {
      const method1 = TreatmentMethod(
        id: 'tm-1',
        code: 'SPRAY',
        name: 'Spraying',
        isRequired: false,
      );
      const method2 = TreatmentMethod(
        id: 'tm-1',
        code: 'SPRAY',
        name: 'Spraying',
        isRequired: false,
      );
      const method3 = TreatmentMethod(
        id: 'tm-1',
        code: 'SPRAY',
        name: 'Spraying',
        isRequired: true,
      );

      expect(method1, equals(method2));
      expect(method1.hashCode, equals(method2.hashCode));
      expect(method1, isNot(equals(method3)));
      expect(method1.hashCode, isNot(equals(method3.hashCode)));
    });

    test('toString includes isRequired', () {
      const method = TreatmentMethod(
        id: 'tm-1',
        code: 'SPRAY',
        name: 'Spraying',
        isRequired: true,
      );

      expect(method.toString(), contains('isRequired: true'));
    });
  });
}
