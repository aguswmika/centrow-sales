import 'package:flutter_test/flutter_test.dart';
import 'package:centrow_sales/modules/sales/entities/addendum_template.dart';
import 'package:centrow_sales/modules/sales/repositories/dtos/addendum_template_dto.dart';

void main() {
  group('AddendumTemplateDto', () {
    const testId = 'f47ac10b-58cc-4372-a567-0e02b2c3d479';
    const testTitle = 'Scope Change Addendum';

    test('fromJson parses JSON correctly', () {
      final json = {'id': testId, 'title': testTitle};

      final dto = AddendumTemplateDto.fromJson(json);

      expect(dto.id, testId);
      expect(dto.title, testTitle);
    });

    test('toEntity converts to AddendumTemplate correctly', () {
      const dto = AddendumTemplateDto(id: testId, title: testTitle);

      final entity = dto.toEntity();

      expect(entity, isA<AddendumTemplate>());
      expect(entity.id, testId);
      expect(entity.title, testTitle);
      expect(
        entity,
        equals(const AddendumTemplate(id: testId, title: testTitle)),
      );
    });

    test('toJson serializes to Map correctly', () {
      const dto = AddendumTemplateDto(id: testId, title: testTitle);

      final json = dto.toJson();

      expect(json, {'id': testId, 'title': testTitle});
    });
  });

  group('AddendumTemplate Entity', () {
    const testId = 'f47ac10b-58cc-4372-a567-0e02b2c3d479';
    const testTitle = 'Scope Change Addendum';

    test('supports value equality and hashCode', () {
      const template1 = AddendumTemplate(id: testId, title: testTitle);
      const template2 = AddendumTemplate(id: testId, title: testTitle);
      const template3 = AddendumTemplate(id: 'other-id', title: 'Other Title');

      expect(template1, equals(template2));
      expect(template1.hashCode, equals(template2.hashCode));
      expect(template1, isNot(equals(template3)));
    });

    test('toString returns formatted string representation', () {
      const template = AddendumTemplate(id: testId, title: testTitle);

      expect(
        template.toString(),
        'AddendumTemplate(id: $testId, title: $testTitle)',
      );
    });
  });
}
