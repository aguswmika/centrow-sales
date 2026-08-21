import 'package:flutter_test/flutter_test.dart';
import 'package:centrow_sales/modules/sales/repositories/proposal_repository.dart';

void main() {
  group('MockProposalRepositoryImpl', () {
    late MockProposalRepositoryImpl repository;

    setUp(() {
      repository = MockProposalRepositoryImpl();
    });

    test('getProposals returns default 4 mock proposals', () async {
      final result = await repository.getProposals();
      expect(result.isOk, isTrue);
      final proposals = result.valueOrNull!;
      expect(proposals.length, 4);
      expect(proposals.map((p) => p.clientName), containsAll([
        'Villa Sari Dewi',
        'Hotel Surya Kuta',
        'Resto Warung Bumi',
        'Ayana Jimbaran Suite',
      ]));
    });

    test('getProposals filters by query', () async {
      final result = await repository.getProposals(query: 'Surya');
      expect(result.isOk, isTrue);
      final list = result.valueOrNull!;
      expect(list.length, 1);
      expect(list.first.clientName, 'Hotel Surya Kuta');
    });

    test('getProposals filters by status', () async {
      final result = await repository.getProposals(status: 'Dikirim');
      expect(result.isOk, isTrue);
      final list = result.valueOrNull!;
      expect(list.length, 1);
      expect(list.first.clientName, 'Villa Sari Dewi');
    });

    test('getProposalById returns proposal when found', () async {
      final result = await repository.getProposalById('pro-1');
      expect(result.isOk, isTrue);
      expect(result.valueOrNull!.code, 'PRO-2026-0042');
    });

    test('getProposalById returns Err when not found', () async {
      final result = await repository.getProposalById('invalid-id');
      expect(result.isErr, isTrue);
    });
  });
}
