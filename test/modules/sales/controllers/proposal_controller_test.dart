import 'package:flutter_test/flutter_test.dart';
import 'package:centrow_sales/modules/sales/controllers/proposal_controller.dart';
import 'package:centrow_sales/modules/sales/entities/proposal.dart';
import 'package:centrow_sales/modules/sales/entities/proposal_status_result.dart';
import 'package:centrow_sales/modules/sales/repositories/proposal_repository.dart';
import 'package:centrow_sales/shared/error/failure.dart';
import 'package:centrow_sales/shared/result/result.dart';
import 'package:centrow_sales/shared/state/ui_state.dart';

class FakeProposalRepository implements ProposalRepository {
  List<Proposal> proposals;
  bool shouldFailGetProposals = false;
  bool shouldFailGetProposalById = false;
  bool shouldFailStatusTransition = false;

  @override
  Future<Result<Proposal>> createProposal(dynamic input) async {
    return const Err(ServerFailure('Not implemented'));
  }

  @override
  Future<Result<Proposal>> updateProposal(String id, dynamic input) async {
    return const Err(ServerFailure('Not implemented'));
  }

  @override
  Future<Result<Proposal>> reviseProposal(String id, dynamic input) async {
    return const Err(ServerFailure('Not implemented'));
  }

  @override
  Future<Result<ProposalStatusResult>> sendProposal(String id) async {
    if (shouldFailStatusTransition) {
      return const Err(ServerFailure('Gagal mengirim proposal'));
    }
    final idx = proposals.indexWhere((p) => p.id == id || p.code == id);
    if (idx != -1) {
      final updated = proposals[idx].copyWith(
        status: ProposalStatus.sent,
        sentAt: '2026-09-03 10:00:00',
      );
      proposals[idx] = updated;
    }
    return Ok(
      ProposalStatusResult(
        id: id,
        status: ProposalStatus.sent,
        sentAt: '2026-09-03 10:00:00',
      ),
    );
  }

  @override
  Future<Result<ProposalStatusResult>> acceptProposal(String id) async {
    if (shouldFailStatusTransition) {
      return const Err(ServerFailure('Gagal menerima proposal'));
    }
    final idx = proposals.indexWhere((p) => p.id == id || p.code == id);
    if (idx != -1) {
      final updated = proposals[idx].copyWith(
        status: ProposalStatus.accepted,
        decidedAt: '2026-09-03 11:00:00',
      );
      proposals[idx] = updated;
    }
    return Ok(
      ProposalStatusResult(
        id: id,
        status: ProposalStatus.accepted,
        decidedAt: '2026-09-03 11:00:00',
      ),
    );
  }

  @override
  Future<Result<ProposalStatusResult>> rejectProposal(
    String id,
    String reason,
  ) async {
    if (shouldFailStatusTransition) {
      return const Err(ServerFailure('Gagal menolak proposal'));
    }
    final idx = proposals.indexWhere((p) => p.id == id || p.code == id);
    if (idx != -1) {
      final updated = proposals[idx].copyWith(
        status: ProposalStatus.rejected,
        decidedAt: '2026-09-03 12:00:00',
        rejectionReason: reason,
      );
      proposals[idx] = updated;
    }
    return Ok(
      ProposalStatusResult(
        id: id,
        status: ProposalStatus.rejected,
        decidedAt: '2026-09-03 12:00:00',
        rejectionReason: reason,
      ),
    );
  }

  @override
  Future<Result<ProposalStatusResult>> expireProposal(String id) async {
    if (shouldFailStatusTransition) {
      return const Err(ServerFailure('Gagal menandai kedaluwarsa'));
    }
    final idx = proposals.indexWhere((p) => p.id == id || p.code == id);
    if (idx != -1) {
      final updated = proposals[idx].copyWith(
        status: ProposalStatus.expired,
        decidedAt: '2026-09-03 13:00:00',
      );
      proposals[idx] = updated;
    }
    return Ok(
      ProposalStatusResult(
        id: id,
        status: ProposalStatus.expired,
        decidedAt: '2026-09-03 13:00:00',
      ),
    );
  }

  @override
  Future<Result<ProposalStatusResult>> cancelProposal(String id) async {
    if (shouldFailStatusTransition) {
      return const Err(ServerFailure('Gagal membatalkan proposal'));
    }
    final idx = proposals.indexWhere((p) => p.id == id || p.code == id);
    if (idx != -1) {
      final updated = proposals[idx].copyWith(status: ProposalStatus.cancelled);
      proposals[idx] = updated;
    }
    return Ok(ProposalStatusResult(id: id, status: ProposalStatus.cancelled));
  }

  FakeProposalRepository({List<Proposal>? initialProposals})
    : proposals =
          initialProposals ??
          [
            const Proposal(
              id: 'p1',
              code: 'PRO-2026-0042',
              clientName: 'Villa Sari Dewi',
              serviceName: 'Termite Protection Plan',
              status: ProposalStatus.sent,
              date: '12 Agt 2026',
              validUntil: '12 Sep 2026',
              location: 'Villa Utama Seminyak',
              version: '1',
              total: 8158500.0,
              items: [
                ProposalItem(
                  id: 'item-1',
                  title: 'Ficam W',
                  category: ProposalItemCategory.persiapan,
                  price: 760000.0,
                ),
                ProposalItem(
                  id: 'item-2',
                  title: 'Teknisi Senior',
                  category: ProposalItemCategory.teknisi,
                  price: 990000.0,
                ),
                ProposalItem(
                  id: 'item-3',
                  title: 'Biaya Perjalanan Badung',
                  category: ProposalItemCategory.transport,
                  price: 120000.0,
                ),
              ],
            ),
            const Proposal(
              id: 'p2',
              code: 'PRO-2026-0041',
              clientName: 'Hotel Surya Kuta',
              serviceName: 'Pest Control Full Commercial',
              status: ProposalStatus.accepted,
              date: '10 Agt 2026',
              validUntil: '10 Sep 2026',
              location: 'Resort & Resto Kuta',
              version: '2',
              total: 12500000.0,
            ),
            const Proposal(
              id: 'p3',
              code: 'PRO-2026-0040',
              clientName: 'Resto Warung Bumi',
              serviceName: 'Disinfection & Sanitasi Ruang',
              status: ProposalStatus.draft,
              date: '15 Agt 2026',
              validUntil: '15 Sep 2026',
              location: 'Restoran Denpasar',
              version: '1',
              total: 2200000.0,
            ),
          ];

  @override
  Future<Result<List<Proposal>>> getProposals({
    String? query,
    String? status,
  }) async {
    if (shouldFailGetProposals) {
      return const Err(ServerFailure('Gagal memuat proposal'));
    }
    var list = List<Proposal>.from(proposals);
    if (status != null &&
        status.trim().isNotEmpty &&
        status.trim().toLowerCase() != 'all' &&
        status.trim().toLowerCase() != 'semua') {
      final st = status.trim().toLowerCase();
      list = list.where((p) {
        return p.status.value.toLowerCase() == st ||
            p.status.displayName.toLowerCase() == st ||
            p.status.name.toLowerCase() == st ||
            (p.status == ProposalStatus.sent &&
                (st == 'dikirim' || st == 'terkirim')) ||
            (p.status == ProposalStatus.accepted &&
                (st == 'disetujui' || st == 'diterima')) ||
            (p.status == ProposalStatus.rejected && st == 'ditolak');
      }).toList();
    }
    if (query != null && query.trim().isNotEmpty) {
      final q = query.trim().toLowerCase();
      list = list.where((p) {
        return p.clientName.toLowerCase().contains(q) ||
            p.code.toLowerCase().contains(q) ||
            p.serviceName.toLowerCase().contains(q) ||
            p.location.toLowerCase().contains(q);
      }).toList();
    }
    return Ok(list);
  }

  @override
  Future<Result<Proposal>> getProposalById(String id) async {
    if (shouldFailGetProposalById) {
      return const Err(ServerFailure('Gagal memuat detail'));
    }
    try {
      final target = proposals.firstWhere((p) => p.id == id || p.code == id);
      return Ok(target);
    } catch (_) {
      return const Err(ServerFailure('Proposal tidak ditemukan', 404));
    }
  }
}

void main() {
  group('ProposalController', () {
    late FakeProposalRepository repository;
    late ProposalController controller;

    setUp(() {
      repository = FakeProposalRepository();
      controller = ProposalController(repository);
    });

    tearDown(() {
      controller.dispose();
    });

    test('initial state is properly configured', () {
      expect(controller.proposalsState.value, isA<UiInitial<List<Proposal>>>());
      expect(controller.proposalDetailState.value, isA<UiInitial<Proposal>>());
      expect(controller.selectedProposalId.value, '');
      expect(controller.searchQuery.value, '');
      expect(controller.selectedStatus.value, 'all');
      expect(controller.activePricingTab.value, 0);
      expect(controller.filteredProposals.value, isEmpty);
      expect(controller.selectedProposal.value, isNull);
      expect(
        controller.actionState.value,
        isA<UiInitial<ProposalStatusResult>>(),
      );
    });

    test(
      'loadProposals populates list and selects first item by default',
      () async {
        await controller.loadProposals();

        expect(
          controller.proposalsState.value,
          isA<UiSuccess<List<Proposal>>>(),
        );
        final list = controller.filteredProposals.value;
        expect(list.length, 3);
        await controller.selectProposal('p1');
        expect(controller.selectedProposalId.value, 'p1');
        expect(
          controller.proposalDetailState.value,
          isA<UiSuccess<Proposal>>(),
        );
        expect(controller.selectedProposal.value?.id, 'p1');
        expect(
          controller.selectedProposal.value?.clientName,
          'Villa Sari Dewi',
        );
      },
    );

    test('loadProposals sets UiFailure on repository error', () async {
      repository.shouldFailGetProposals = true;
      await controller.loadProposals();

      expect(controller.proposalsState.value, isA<UiFailure<List<Proposal>>>());
      expect(controller.filteredProposals.value, isEmpty);
    });

    test(
      'selectProposal updates selectedProposalId and fetches detail',
      () async {
        await controller.loadProposals();

        await controller.selectProposal('p2');
        expect(controller.selectedProposalId.value, 'p2');
        expect(
          controller.proposalDetailState.value,
          isA<UiSuccess<Proposal>>(),
        );
        expect(controller.selectedProposal.value?.id, 'p2');
        expect(
          controller.selectedProposal.value?.clientName,
          'Hotel Surya Kuta',
        );
      },
    );

    test('selectProposal with empty id resets proposalDetailState', () async {
      await controller.loadProposals();

      await controller.selectProposal('');
      expect(controller.selectedProposalId.value, '');
      expect(controller.proposalDetailState.value, isA<UiInitial<Proposal>>());
    });

    test('selectProposal sets UiFailure when proposal is not found', () async {
      await controller.loadProposals();

      await controller.selectProposal('non-existent');
      expect(controller.selectedProposalId.value, 'non-existent');
      expect(controller.proposalDetailState.value, isA<UiFailure<Proposal>>());
    });

    test('filtering by search query updates filteredProposals', () async {
      await controller.loadProposals();

      controller.setSearchQuery('Surya');
      final result = controller.filteredProposals.value;
      expect(result.length, 1);
      expect(result.first.clientName, 'Hotel Surya Kuta');

      controller.setSearchQuery('PRO-2026-0040');
      final codeResult = controller.filteredProposals.value;
      expect(codeResult.length, 1);
      expect(codeResult.first.clientName, 'Resto Warung Bumi');
    });

    test('filtering by status updates filteredProposals', () async {
      await controller.loadProposals();

      controller.selectStatus('Draft');
      final draftList = controller.filteredProposals.value;
      expect(draftList.length, 1);
      expect(draftList.first.id, 'p3');

      controller.selectStatus('Dikirim');
      final sentList = controller.filteredProposals.value;
      expect(sentList.length, 1);
      expect(sentList.first.id, 'p1');
    });

    test(
      'activePricingTab and activePricingCategory behave correctly',
      () async {
        await controller.loadProposals();
        await controller.selectProposal('p1');

        expect(controller.activePricingTab.value, 0);
        expect(
          controller.activePricingCategory.value,
          ProposalItemCategory.persiapan,
        );
        expect(controller.activePricingItems.value.length, 1);
        expect(controller.activePricingItems.value.first.title, 'Ficam W');

        controller.setPricingTab(1);
        expect(
          controller.activePricingCategory.value,
          ProposalItemCategory.teknisi,
        );
        expect(controller.activePricingItems.value.length, 1);
        expect(
          controller.activePricingItems.value.first.title,
          'Teknisi Senior',
        );

        controller.setActivePricingTab(2);
        expect(
          controller.activePricingCategory.value,
          ProposalItemCategory.transport,
        );
        expect(controller.activePricingItems.value.length, 1);
        expect(
          controller.activePricingItems.value.first.title,
          'Biaya Perjalanan Badung',
        );

        controller.setPricingCategory(ProposalItemCategory.persiapan);
        expect(controller.activePricingTab.value, 0);

        controller.changeTab(1);
        expect(controller.activePricingTab.value, 1);
      },
    );

    group('Status transitions', () {
      test(
        'sendProposal transitions proposal to sent and sets sentAt',
        () async {
          await controller.loadProposals();
          await controller.selectProposal('p3'); // p3 is draft
          expect(
            controller.selectedProposal.value?.status,
            ProposalStatus.draft,
          );

          final result = await controller.sendProposal('p3');

          expect(result, isA<Ok<ProposalStatusResult>>());
          expect(
            controller.actionState.value,
            isA<UiSuccess<ProposalStatusResult>>(),
          );
          final current = controller.proposalDetailState.value.dataOrNull;
          expect(current?.status, ProposalStatus.sent);
          expect(current?.sentAt, '2026-09-03 10:00:00');
        },
      );

      test(
        'acceptProposal transitions proposal to accepted and sets decidedAt',
        () async {
          await controller.loadProposals();
          await controller.selectProposal('p1'); // p1 is sent (dikirim)
          expect(
            controller.selectedProposal.value?.status,
            ProposalStatus.sent,
          );

          final result = await controller.acceptProposal('p1');

          expect(result, isA<Ok<ProposalStatusResult>>());
          expect(
            controller.actionState.value,
            isA<UiSuccess<ProposalStatusResult>>(),
          );
          final current = controller.proposalDetailState.value.dataOrNull;
          expect(current?.status, ProposalStatus.accepted);
          expect(current?.decidedAt, '2026-09-03 11:00:00');
        },
      );

      test(
        'rejectProposal transitions proposal to rejected with reason and decidedAt',
        () async {
          await controller.loadProposals();
          await controller.selectProposal('p1');

          final result = await controller.rejectProposal(
            'p1',
            'Budget tidak mencukupi',
          );

          expect(result, isA<Ok<ProposalStatusResult>>());
          expect(
            controller.actionState.value,
            isA<UiSuccess<ProposalStatusResult>>(),
          );
          final current = controller.proposalDetailState.value.dataOrNull;
          expect(current?.status, ProposalStatus.rejected);
          expect(current?.decidedAt, '2026-09-03 12:00:00');
          expect(current?.rejectionReason, 'Budget tidak mencukupi');
        },
      );

      test(
        'expireProposal transitions proposal to expired and sets decidedAt',
        () async {
          await controller.loadProposals();
          await controller.selectProposal('p1');

          final result = await controller.expireProposal('p1');

          expect(result, isA<Ok<ProposalStatusResult>>());
          expect(
            controller.actionState.value,
            isA<UiSuccess<ProposalStatusResult>>(),
          );
          final current = controller.proposalDetailState.value.dataOrNull;
          expect(current?.status, ProposalStatus.expired);
          expect(current?.decidedAt, '2026-09-03 13:00:00');
        },
      );

      test('cancelProposal transitions proposal to cancelled', () async {
        await controller.loadProposals();
        await controller.selectProposal('p3'); // draft can be cancelled

        final result = await controller.cancelProposal('p3');

        expect(result, isA<Ok<ProposalStatusResult>>());
        expect(
          controller.actionState.value,
          isA<UiSuccess<ProposalStatusResult>>(),
        );
        final current = controller.proposalDetailState.value.dataOrNull;
        expect(current?.status, ProposalStatus.cancelled);
      });

      test(
        'failure transition sets actionState to UiFailure and preserves detail state',
        () async {
          await controller.loadProposals();
          await controller.selectProposal('p1');
          repository.shouldFailStatusTransition = true;

          final result = await controller.sendProposal('p1');

          expect(result, isA<Err<ProposalStatusResult>>());
          expect(
            controller.actionState.value,
            isA<UiFailure<ProposalStatusResult>>(),
          );
          // Detail state should NOT be mutated on failure
          final current = controller.proposalDetailState.value.dataOrNull;
          expect(current?.status, ProposalStatus.sent);
        },
      );

      test('resetActionState resets actionState back to UiInitial', () async {
        await controller.loadProposals();
        await controller.selectProposal('p3');
        await controller.sendProposal('p3');

        expect(
          controller.actionState.value,
          isA<UiSuccess<ProposalStatusResult>>(),
        );
        controller.resetActionState();
        expect(
          controller.actionState.value,
          isA<UiInitial<ProposalStatusResult>>(),
        );
      });
    });
  });
}
