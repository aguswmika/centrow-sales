import 'package:flutter_test/flutter_test.dart';
import 'package:centrow_sales/modules/sales/entities/contract_addendum_document.dart';
import 'package:centrow_sales/modules/sales/repositories/dtos/contract_addendum_document_dto.dart';

void main() {
  group('ContractAddendumDocumentDto', () {
    const testDocId = 'doc-123';
    const testAddendumId = 'addendum-456';
    const testTemplateId = 'tmpl-789';
    const testTitle = 'Addendum Title';
    const testSource = 'document';
    const testUpdatedAt = '2026-09-22T10:00:00.000Z';
    final testContent = {
      'type': 'doc',
      'content': [
        {'type': 'paragraph', 'text': 'Clause 1'},
      ],
    };

    test('fromJson parses complete JSON correctly', () {
      final json = {
        'document_id': testDocId,
        'addendum_id': testAddendumId,
        'template_id': testTemplateId,
        'title': testTitle,
        'source': testSource,
        'content': testContent,
        'updated_at': testUpdatedAt,
      };

      final dto = ContractAddendumDocumentDto.fromJson(json);

      expect(dto.documentId, testDocId);
      expect(dto.addendumId, testAddendumId);
      expect(dto.templateId, testTemplateId);
      expect(dto.title, testTitle);
      expect(dto.source, testSource);
      expect(dto.content, testContent);
      expect(dto.updatedAt, testUpdatedAt);
    });

    test('fromJson handles null document_id and updated_at', () {
      final json = {
        'document_id': null,
        'addendum_id': testAddendumId,
        'template_id': testTemplateId,
        'title': testTitle,
        'source': 'template',
        'content': testContent,
        'updated_at': null,
      };

      final dto = ContractAddendumDocumentDto.fromJson(json);

      expect(dto.documentId, isNull);
      expect(dto.addendumId, testAddendumId);
      expect(dto.templateId, testTemplateId);
      expect(dto.title, testTitle);
      expect(dto.source, 'template');
      expect(dto.content, testContent);
      expect(dto.updatedAt, isNull);
    });

    test('fromJson handles missing content gracefully', () {
      final json = {
        'document_id': null,
        'addendum_id': testAddendumId,
        'template_id': testTemplateId,
        'title': testTitle,
        'source': 'template',
      };

      final dto = ContractAddendumDocumentDto.fromJson(json);

      expect(dto.content, <String, dynamic>{});
    });

    test('toEntity converts to ContractAddendumDocument correctly', () {
      final dto = ContractAddendumDocumentDto(
        documentId: testDocId,
        addendumId: testAddendumId,
        templateId: testTemplateId,
        title: testTitle,
        source: testSource,
        content: testContent,
        updatedAt: testUpdatedAt,
      );

      final entity = dto.toEntity();

      expect(entity, isA<ContractAddendumDocument>());
      expect(entity.documentId, testDocId);
      expect(entity.addendumId, testAddendumId);
      expect(entity.templateId, testTemplateId);
      expect(entity.title, testTitle);
      expect(entity.source, testSource);
      expect(entity.content, testContent);
      expect(entity.updatedAt, testUpdatedAt);
    });

    test('toJson serializes to Map correctly', () {
      final dto = ContractAddendumDocumentDto(
        documentId: testDocId,
        addendumId: testAddendumId,
        templateId: testTemplateId,
        title: testTitle,
        source: testSource,
        content: testContent,
        updatedAt: testUpdatedAt,
      );

      final json = dto.toJson();

      expect(json, {
        'document_id': testDocId,
        'addendum_id': testAddendumId,
        'template_id': testTemplateId,
        'title': testTitle,
        'source': testSource,
        'content': testContent,
        'updated_at': testUpdatedAt,
      });
    });
  });

  group('ContractAddendumDocument Entity', () {
    const testDocId = 'doc-123';
    const testAddendumId = 'addendum-456';
    const testTemplateId = 'tmpl-789';
    const testTitle = 'Addendum Title';

    test(
      'isSaved returns true when source is document even if documentId is null',
      () {
        const doc = ContractAddendumDocument(
          documentId: null,
          addendumId: testAddendumId,
          templateId: testTemplateId,
          title: testTitle,
          source: 'document',
          content: {},
        );

        expect(doc.isSaved, isTrue);
      },
    );

    test(
      'isSaved returns true when documentId is not null even if source is template',
      () {
        const doc = ContractAddendumDocument(
          documentId: testDocId,
          addendumId: testAddendumId,
          templateId: testTemplateId,
          title: testTitle,
          source: 'template',
          content: {},
        );

        expect(doc.isSaved, isTrue);
      },
    );

    test(
      'isSaved returns false when source is template and documentId is null',
      () {
        const doc = ContractAddendumDocument(
          documentId: null,
          addendumId: testAddendumId,
          templateId: testTemplateId,
          title: testTitle,
          source: 'template',
          content: {},
        );

        expect(doc.isSaved, isFalse);
      },
    );

    test('supports value equality and hashCode', () {
      const doc1 = ContractAddendumDocument(
        documentId: testDocId,
        addendumId: testAddendumId,
        templateId: testTemplateId,
        title: testTitle,
        source: 'document',
        content: {
          'type': 'doc',
          'content': [
            {'text': 'Hello'},
          ],
        },
        updatedAt: '2026-09-22T10:00:00Z',
      );

      const doc2 = ContractAddendumDocument(
        documentId: testDocId,
        addendumId: testAddendumId,
        templateId: testTemplateId,
        title: testTitle,
        source: 'document',
        content: {
          'type': 'doc',
          'content': [
            {'text': 'Hello'},
          ],
        },
        updatedAt: '2026-09-22T10:00:00Z',
      );

      const doc3 = ContractAddendumDocument(
        documentId: 'other-id',
        addendumId: testAddendumId,
        templateId: testTemplateId,
        title: testTitle,
        source: 'document',
        content: {},
      );

      expect(doc1, equals(doc2));
      expect(doc1.hashCode, equals(doc2.hashCode));
      expect(doc1, isNot(equals(doc3)));
    });

    test('toString returns formatted string representation', () {
      const doc = ContractAddendumDocument(
        documentId: testDocId,
        addendumId: testAddendumId,
        templateId: testTemplateId,
        title: testTitle,
        source: 'document',
        content: {},
        updatedAt: '2026-09-22T10:00:00Z',
      );

      expect(
        doc.toString(),
        'ContractAddendumDocument(documentId: $testDocId, addendumId: $testAddendumId, templateId: $testTemplateId, title: $testTitle, source: document, updatedAt: 2026-09-22T10:00:00Z)',
      );
    });
  });
}
