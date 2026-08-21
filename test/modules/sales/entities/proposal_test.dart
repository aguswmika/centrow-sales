import 'package:flutter_test/flutter_test.dart';
import 'package:centrow_sales/modules/sales/entities/proposal.dart';

void main() {
  group('ProposalStatus', () {
    test('fromString parses correctly', () {
      expect(ProposalStatus.fromString('draft'), ProposalStatus.draft);
      expect(ProposalStatus.fromString('Dikirim'), ProposalStatus.dikirim);
      expect(ProposalStatus.fromString('Negosiasi'), ProposalStatus.negosiasi);
      expect(ProposalStatus.fromString('Disetujui'), ProposalStatus.disetujui);
      expect(ProposalStatus.fromString('accepted'), ProposalStatus.disetujui);
      expect(ProposalStatus.fromString('unknown'), ProposalStatus.draft);
    });

    test('badgeType returns appropriate variant string', () {
      expect(ProposalStatus.draft.badgeType, 'neutral');
      expect(ProposalStatus.dikirim.badgeType, 'info');
      expect(ProposalStatus.negosiasi.badgeType, 'warn');
      expect(ProposalStatus.disetujui.badgeType, 'ok');
      expect(ProposalStatus.ditolak.badgeType, 'err');
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
        status: ProposalStatus.dikirim,
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
}
