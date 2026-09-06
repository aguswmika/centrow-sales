import 'package:flutter_test/flutter_test.dart';
import 'package:centrow_sales/modules/sales/entities/proposal.dart';
import 'package:centrow_sales/modules/sales/entities/proposal_status_result.dart';
import 'package:centrow_sales/modules/sales/repositories/dtos/proposal_dto.dart';

void main() {
  group('ProposalStatus', () {
    test('all 6 enum values exist with correct properties', () {
      expect(ProposalStatus.values, [
        ProposalStatus.draft,
        ProposalStatus.sent,
        ProposalStatus.accepted,
        ProposalStatus.rejected,
        ProposalStatus.expired,
        ProposalStatus.cancelled,
      ]);

      expect(ProposalStatus.draft.displayName, 'Draf');
      expect(ProposalStatus.draft.badgeType, 'neutral');
      expect(ProposalStatus.draft.value, 'draft');

      expect(ProposalStatus.sent.displayName, 'Terkirim');
      expect(ProposalStatus.sent.badgeType, 'info');
      expect(ProposalStatus.sent.value, 'sent');

      expect(ProposalStatus.accepted.displayName, 'Diterima');
      expect(ProposalStatus.accepted.badgeType, 'ok');
      expect(ProposalStatus.accepted.value, 'accepted');

      expect(ProposalStatus.rejected.displayName, 'Ditolak');
      expect(ProposalStatus.rejected.badgeType, 'err');
      expect(ProposalStatus.rejected.value, 'rejected');

      expect(ProposalStatus.expired.displayName, 'Kedaluwarsa');
      expect(ProposalStatus.expired.badgeType, 'warn');
      expect(ProposalStatus.expired.value, 'expired');

      expect(ProposalStatus.cancelled.displayName, 'Dibatalkan');
      expect(ProposalStatus.cancelled.badgeType, 'neutral');
      expect(ProposalStatus.cancelled.value, 'cancelled');
    });

    test('backward compatibility getters point to correct statuses', () {
      expect(ProposalStatus.dikirim, ProposalStatus.sent);
      expect(ProposalStatus.disetujui, ProposalStatus.accepted);
      expect(ProposalStatus.ditolak, ProposalStatus.rejected);
      expect(ProposalStatus.negosiasi, ProposalStatus.sent);
    });

    test('state machine boolean flags work correctly', () {
      // isDraft
      expect(ProposalStatus.draft.isDraft, isTrue);
      expect(ProposalStatus.sent.isDraft, isFalse);

      // isSent
      expect(ProposalStatus.sent.isSent, isTrue);
      expect(ProposalStatus.accepted.isSent, isFalse);

      // isAccepted
      expect(ProposalStatus.accepted.isAccepted, isTrue);
      expect(ProposalStatus.draft.isAccepted, isFalse);

      // isRejected
      expect(ProposalStatus.rejected.isRejected, isTrue);
      expect(ProposalStatus.draft.isRejected, isFalse);

      // isExpired
      expect(ProposalStatus.expired.isExpired, isTrue);
      expect(ProposalStatus.draft.isExpired, isFalse);

      // isCancelled
      expect(ProposalStatus.cancelled.isCancelled, isTrue);
      expect(ProposalStatus.draft.isCancelled, isFalse);

      // isTerminal
      expect(ProposalStatus.draft.isTerminal, isFalse);
      expect(ProposalStatus.sent.isTerminal, isFalse);
      expect(ProposalStatus.accepted.isTerminal, isTrue);
      expect(ProposalStatus.rejected.isTerminal, isTrue);
      expect(ProposalStatus.expired.isTerminal, isTrue);
      expect(ProposalStatus.cancelled.isTerminal, isTrue);

      // canEdit
      expect(ProposalStatus.draft.canEdit, isTrue);
      expect(ProposalStatus.sent.canEdit, isFalse);
      expect(ProposalStatus.accepted.canEdit, isFalse);

      // canEditPricing (only draft can edit pricing directly)
      expect(ProposalStatus.draft.canEditPricing, isTrue);
      expect(ProposalStatus.sent.canEditPricing, isFalse);
      expect(ProposalStatus.accepted.canEditPricing, isFalse);
      expect(ProposalStatus.rejected.canEditPricing, isFalse);
      expect(ProposalStatus.expired.canEditPricing, isFalse);
      expect(ProposalStatus.cancelled.canEditPricing, isFalse);

      // canEditDocument (blocked only when expired or cancelled)
      expect(ProposalStatus.draft.canEditDocument, isTrue);
      expect(ProposalStatus.sent.canEditDocument, isTrue);
      expect(ProposalStatus.accepted.canEditDocument, isTrue);
      expect(ProposalStatus.rejected.canEditDocument, isTrue);
      expect(ProposalStatus.expired.canEditDocument, isFalse);
      expect(ProposalStatus.cancelled.canEditDocument, isFalse);

      // canRevise
      expect(ProposalStatus.draft.canRevise, isFalse);
      expect(ProposalStatus.sent.canRevise, isTrue);
      expect(ProposalStatus.accepted.canRevise, isFalse);
      expect(ProposalStatus.rejected.canRevise, isTrue);
      expect(ProposalStatus.expired.canRevise, isTrue);
      expect(ProposalStatus.cancelled.canRevise, isFalse);

      // canSend
      expect(ProposalStatus.draft.canSend, isTrue);
      expect(ProposalStatus.sent.canSend, isFalse);
      expect(ProposalStatus.accepted.canSend, isFalse);

      // canAccept
      expect(ProposalStatus.sent.canAccept, isTrue);
      expect(ProposalStatus.draft.canAccept, isFalse);
      expect(ProposalStatus.accepted.canAccept, isFalse);

      // canReject
      expect(ProposalStatus.sent.canReject, isTrue);
      expect(ProposalStatus.draft.canReject, isFalse);

      // canExpire
      expect(ProposalStatus.sent.canExpire, isTrue);
      expect(ProposalStatus.draft.canExpire, isFalse);

      // canCancel
      expect(ProposalStatus.draft.canCancel, isTrue);
      expect(ProposalStatus.sent.canCancel, isTrue);
      expect(ProposalStatus.accepted.canCancel, isFalse);
      expect(ProposalStatus.rejected.canCancel, isFalse);
      expect(ProposalStatus.expired.canCancel, isFalse);
      expect(ProposalStatus.cancelled.canCancel, isFalse);
    });

    test('fromString parses English and Indonesian names correctly', () {
      expect(ProposalStatus.fromString('draft'), ProposalStatus.draft);
      expect(ProposalStatus.fromString('draf'), ProposalStatus.draft);
      expect(ProposalStatus.fromString('sent'), ProposalStatus.sent);
      expect(ProposalStatus.fromString('dikirim'), ProposalStatus.sent);
      expect(ProposalStatus.fromString('terkirim'), ProposalStatus.sent);
      expect(ProposalStatus.fromString('negotiation'), ProposalStatus.sent);
      expect(ProposalStatus.fromString('negosiasi'), ProposalStatus.sent);
      expect(ProposalStatus.fromString('accepted'), ProposalStatus.accepted);
      expect(ProposalStatus.fromString('disetujui'), ProposalStatus.accepted);
      expect(ProposalStatus.fromString('diterima'), ProposalStatus.accepted);
      expect(ProposalStatus.fromString('rejected'), ProposalStatus.rejected);
      expect(ProposalStatus.fromString('ditolak'), ProposalStatus.rejected);
      expect(ProposalStatus.fromString('expired'), ProposalStatus.expired);
      expect(ProposalStatus.fromString('kedaluwarsa'), ProposalStatus.expired);
      expect(ProposalStatus.fromString('kadaluarsa'), ProposalStatus.expired);
      expect(ProposalStatus.fromString('cancelled'), ProposalStatus.cancelled);
      expect(ProposalStatus.fromString('canceled'), ProposalStatus.cancelled);
      expect(ProposalStatus.fromString('dibatalkan'), ProposalStatus.cancelled);
      expect(ProposalStatus.fromString('unknown_status'), ProposalStatus.draft);
    });

    test('fromInt maps integers correctly', () {
      expect(ProposalStatus.fromInt(1), ProposalStatus.draft);
      expect(ProposalStatus.fromInt(2), ProposalStatus.sent);
      expect(ProposalStatus.fromInt(3), ProposalStatus.accepted);
      expect(ProposalStatus.fromInt(4), ProposalStatus.rejected);
      expect(ProposalStatus.fromInt(5), ProposalStatus.expired);
      expect(ProposalStatus.fromInt(6), ProposalStatus.cancelled);
      expect(ProposalStatus.fromInt(99), ProposalStatus.draft);
    });
  });

  group('ProposalItemCategory', () {
    test('fromString parses category names and tabs', () {
      expect(
        ProposalItemCategory.fromString('persiapan'),
        ProposalItemCategory.persiapan,
      );
      expect(
        ProposalItemCategory.fromString('cp-teknisi'),
        ProposalItemCategory.teknisi,
      );
      expect(
        ProposalItemCategory.fromString('transport'),
        ProposalItemCategory.transport,
      );
      expect(
        ProposalItemCategory.fromString('unknown'),
        ProposalItemCategory.persiapan,
      );
    });
  });

  group('Proposal and ProposalItem entities', () {
    test('Proposal calculates initials and formats fields correctly', () {
      const item1 = ProposalItem(
        id: 'i1',
        title: 'Bahan A',
        description: 'Desc A',
        category: ProposalItemCategory.persiapan,
        price: 500000.0,
      );
      const item2 = ProposalItem(
        id: 'i2',
        title: 'Teknisi A',
        description: 'Desc B',
        category: ProposalItemCategory.teknisi,
        price: 300000.0,
      );

      const proposal = Proposal(
        id: 'p1',
        code: 'PRO-2026-0001',
        clientName: 'Bali Paradise Resort',
        serviceName: 'Full Pest Control',
        status: ProposalStatus.sent,
        date: '10 Agt 2026',
        validUntil: '10 Sep 2026',
        location: 'Kuta, Bali',
        version: '2',
        total: 880000.0,
        cogs: 500000.0,
        markup: 300000.0,
        markupPercent: 60.0,
        servicePrice: 800000.0,
        subtotal: 800000.0,
        tax: 80000.0,
        marginPct: 37.5,
        marginAmt: 300000.0,
        ppv: 440000.0,
        ppm: 220000.0,
        items: [item1, item2],
      );

      expect(proposal.initials, 'BP');
      expect(proposal.formattedTotal, 'Rp 880.000');
      expect(proposal.formattedMarkup, '+ Rp 300.000 (60%)');
      expect(proposal.formattedMarginPct, '37.5%');
      expect(proposal.displayVersion, 'Versi 2');
      expect(proposal.displayTitle, 'PRO-2026-0001 · Bali Paradise Resort');
      expect(proposal.persiapanItems.length, 1);
      expect(proposal.teknisiItems.length, 1);
      expect(proposal.transportItems.length, 0);
      expect(item1.formattedPrice, 'Rp 500.000');
    });

    test('copyWith works correctly', () {
      const proposal = Proposal(
        id: 'p1',
        code: 'PRO-2026-0001',
        clientName: 'Client A',
        serviceName: 'Service A',
        status: ProposalStatus.draft,
        date: '01 Agt 2026',
        validUntil: '01 Sep 2026',
        location: 'Location A',
      );

      final updated = proposal.copyWith(
        status: ProposalStatus.disetujui,
        clientName: 'Client B',
      );

      expect(updated.status, ProposalStatus.disetujui);
      expect(updated.clientName, 'Client B');
      expect(updated.code, 'PRO-2026-0001');
    });
  });

  group('ProposalStatusResult', () {
    test('instantiation and equality check', () {
      const result1 = ProposalStatusResult(
        id: 'prop-123',
        status: ProposalStatus.sent,
        statusLabel: 'Terkirim',
        sentAt: '2026-09-03T10:00:00Z',
      );

      const result2 = ProposalStatusResult(
        id: 'prop-123',
        status: ProposalStatus.sent,
        statusLabel: 'Terkirim',
        sentAt: '2026-09-03T10:00:00Z',
      );

      expect(result1, equals(result2));
      expect(result1.hashCode, equals(result2.hashCode));
      expect(result1.toString(), contains('prop-123'));
      expect(result1.toString(), contains('sent'));
    });
  });

  group('ProposalStatusResponseDto', () {
    test('fromJson and toEntity map all fields accurately', () {
      final json = {
        'id': 'prop-456',
        'status': 'rejected',
        'status_label': 'Ditolak',
        'sent_at': '2026-09-01T10:00:00Z',
        'decided_at': '2026-09-02T12:00:00Z',
        'rejection_reason': 'Harga terlalu tinggi',
      };

      final dto = ProposalStatusResponseDto.fromJson(json);
      expect(dto.id, 'prop-456');
      expect(dto.status, 'rejected');
      expect(dto.statusLabel, 'Ditolak');
      expect(dto.sentAt, '2026-09-01T10:00:00Z');
      expect(dto.decidedAt, '2026-09-02T12:00:00Z');
      expect(dto.rejectionReason, 'Harga terlalu tinggi');

      final entity = dto.toEntity();
      expect(entity.id, 'prop-456');
      expect(entity.status, ProposalStatus.rejected);
      expect(entity.statusLabel, 'Ditolak');
      expect(entity.sentAt, '2026-09-01T10:00:00Z');
      expect(entity.decidedAt, '2026-09-02T12:00:00Z');
      expect(entity.rejectionReason, 'Harga terlalu tinggi');
    });
  });
}
