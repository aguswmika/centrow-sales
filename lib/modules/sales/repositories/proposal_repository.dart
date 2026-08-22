import 'package:dio/dio.dart';
import 'package:centrow_sales/shared/network/dio_client.dart';
import 'package:centrow_sales/modules/sales/entities/create_proposal_input.dart';
import 'package:centrow_sales/shared/error/failure.dart';
import 'package:centrow_sales/shared/result/result.dart';
import 'package:centrow_sales/modules/sales/entities/proposal.dart';

abstract interface class ProposalRepository {
  Future<Result<List<Proposal>>> getProposals({String? query, String? status});

  Future<Result<Proposal>> getProposalById(String id);

  Future<Result<Proposal>> createProposal(CreateProposalInput input);
}

class MockProposalRepositoryImpl implements ProposalRepository {
  final List<Proposal> _proposals;

  @override
  Future<Result<Proposal>> createProposal(CreateProposalInput input) async {
    try {
      final newProposal = Proposal(
        id: "pro-${DateTime.now().millisecondsSinceEpoch}",
        code:
            "PRO-2026-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}",
        clientName: input.customerId,
        serviceName: input.serviceId,
        status: ProposalStatus.draft,
        date: input.proposalDate,
        validUntil: input.validUntil ?? "N/A",
        location: input.addressId ?? "N/A",
      );
      _proposals.add(newProposal);
      return Ok(newProposal);
    } catch (e) {
      return Err(ServerFailure(e.toString()));
    }
  }

  MockProposalRepositoryImpl({List<Proposal>? seedProposals})
    : _proposals = seedProposals ?? _defaultProposals;

  static final List<Proposal> _defaultProposals = [
    const Proposal(
      id: 'pro-1',
      code: 'PRO-2026-0042',
      clientName: 'Villa Sari Dewi',
      initials: 'VS',
      serviceName: 'Termite Protection Plan',
      status: ProposalStatus.dikirim,
      date: '12 Agt 2026',
      validUntil: '12 Sep 2026',
      location: 'Villa Utama Seminyak',
      version: '1',
      total: 8158500.0,
      shortAmount: 'Rp 8,15jt',
      cogs: 5480000.0,
      materialCost: 3710000.0,
      laborCost: 1650000.0,
      fuelCost: 120000.0,
      markup: 1370000.0,
      markupPercent: 25.0,
      servicePrice: 6850000.0,
      addon: 500000.0,
      subtotal: 7350000.0,
      tax: 808500.0,
      marginPct: 20.0,
      marginAmt: 1370000.0,
      shortMarginAmt: 'Rp 1,37jt',
      ppv: 1225000.0,
      ppm: 612500.0,
      items: [
        ProposalItem(
          id: 'item-1-1',
          title: 'Ficam W (25kg)',
          description:
              'Jumlah: 2 kg · Frekuensi Aplikasi: 1 · Biaya Satuan: Rp 380.000 / kg',
          category: ProposalItemCategory.persiapan,
          price: 760000.0,
        ),
        ProposalItem(
          id: 'item-1-2',
          title: 'Termidor SC (1L)',
          description:
              'Jumlah: 3 botol · Frekuensi Aplikasi: 1 · Biaya Satuan: Rp 650.000 / botol',
          category: ProposalItemCategory.persiapan,
          price: 1950000.0,
        ),
        ProposalItem(
          id: 'item-1-3',
          title: 'Solfac 10WP (1kg)',
          description:
              'Jumlah: 1 kg · Frekuensi Aplikasi: 2 · Biaya Satuan: Rp 290.000 / kg',
          category: ProposalItemCategory.persiapan,
          price: 580000.0,
        ),
        ProposalItem(
          id: 'item-1-4',
          title: 'Sprayer Solo 425 & Nozzle',
          description:
              'Jumlah: 1 unit · Frekuensi: 1 · Biaya Satuan: Rp 420.000 / unit',
          category: ProposalItemCategory.persiapan,
          price: 420000.0,
        ),
        ProposalItem(
          id: 'item-1-5',
          title: 'Teknisi Senior (Lead Operator)',
          description:
              '6 Kunjungan (4 jam pertama, 3 jam rutin) · Tarif: Rp 45.000 / jam',
          category: ProposalItemCategory.teknisi,
          price: 990000.0,
        ),
        ProposalItem(
          id: 'item-1-6',
          title: 'Teknisi Junior (Asisten Lapangan)',
          description:
              '6 Kunjungan (4 jam pertama, 3 jam rutin) · Tarif: Rp 30.000 / jam',
          category: ProposalItemCategory.teknisi,
          price: 660000.0,
        ),
        ProposalItem(
          id: 'item-1-7',
          title: 'Biaya Perjalanan Badung (BBM & Transport)',
          description: '6 Kunjungan × Rp 20.000 per visit',
          category: ProposalItemCategory.transport,
          price: 120000.0,
        ),
        ProposalItem(
          id: 'item-1-8',
          title: 'Pest Safety Training Kit (Add-on)',
          description: '1 Paket Modul Pelatihan & Keselamatan Kerja',
          category: ProposalItemCategory.transport,
          price: 500000.0,
        ),
      ],
    ),
    const Proposal(
      id: 'pro-2',
      code: 'PRO-2026-0041',
      clientName: 'Hotel Surya Kuta',
      initials: 'SK',
      serviceName: 'Pest Control Full Commercial',
      status: ProposalStatus.negosiasi,
      date: '10 Agt 2026',
      validUntil: '10 Sep 2026',
      location: 'Resort & Resto Kuta',
      version: '2',
      total: 12500000.0,
      shortAmount: 'Rp 12,5jt',
      cogs: 8200000.0,
      materialCost: 5400000.0,
      laborCost: 2500000.0,
      fuelCost: 300000.0,
      markup: 3060000.0,
      markupPercent: 30.0,
      servicePrice: 11260000.0,
      addon: 0.0,
      subtotal: 11260000.0,
      tax: 1240000.0,
      marginPct: 27.2,
      marginAmt: 3060000.0,
      shortMarginAmt: 'Rp 3,06jt',
      ppv: 1042000.0,
      ppm: 938000.0,
      items: [
        ProposalItem(
          id: 'item-2-1',
          title: 'Cislin 25 EC (1L)',
          description:
              'Jumlah: 4 botol · Frekuensi Aplikasi: 2 · Biaya Satuan: Rp 450.000 / botol',
          category: ProposalItemCategory.persiapan,
          price: 3600000.0,
        ),
        ProposalItem(
          id: 'item-2-2',
          title: 'Maxforce Forte Gel (30g)',
          description:
              'Jumlah: 6 tube · Frekuensi Aplikasi: 1 · Biaya Satuan: Rp 300.000 / tube',
          category: ProposalItemCategory.persiapan,
          price: 1800000.0,
        ),
        ProposalItem(
          id: 'item-2-3',
          title: 'Teknisi Senior & Tim Spraying',
          description: '12 Kunjungan (2 teknisi) · Tarif: Rp 50.000 / jam',
          category: ProposalItemCategory.teknisi,
          price: 2500000.0,
        ),
        ProposalItem(
          id: 'item-2-4',
          title: 'Biaya Logistik & Transport Kuta',
          description: '12 Kunjungan × Rp 25.000 per visit',
          category: ProposalItemCategory.transport,
          price: 300000.0,
        ),
      ],
    ),
    const Proposal(
      id: 'pro-3',
      code: 'PRO-2026-0040',
      clientName: 'Resto Warung Bumi',
      initials: 'WB',
      serviceName: 'Disinfection & Sanitasi Ruang',
      status: ProposalStatus.draft,
      date: '15 Agt 2026',
      validUntil: '15 Sep 2026',
      location: 'Restoran Denpasar',
      version: '1',
      total: 2200000.0,
      shortAmount: 'Rp 2,2jt',
      cogs: 1450000.0,
      materialCost: 950000.0,
      laborCost: 400000.0,
      fuelCost: 100000.0,
      markup: 531982.0,
      markupPercent: 36.0,
      servicePrice: 1981982.0,
      addon: 0.0,
      subtotal: 1981982.0,
      tax: 218018.0,
      marginPct: 26.8,
      marginAmt: 532000.0,
      shortMarginAmt: 'Rp 532rb',
      ppv: 1981982.0,
      ppm: 1981982.0,
      items: [
        ProposalItem(
          id: 'item-3-1',
          title: 'Desinfektan Broad Spectrum (5L)',
          description: 'Jumlah: 2 jerigen · Biaya Satuan: Rp 350.000 / jerigen',
          category: ProposalItemCategory.persiapan,
          price: 700000.0,
        ),
        ProposalItem(
          id: 'item-3-2',
          title: 'Masker Respirator & Sarung Tangan',
          description: '1 Set Perlengkapan K3 APD',
          category: ProposalItemCategory.persiapan,
          price: 250000.0,
        ),
        ProposalItem(
          id: 'item-3-3',
          title: 'Operator Fogging / ULV',
          description: '1 Hari Pengerjaan Sanitasi Lengkap',
          category: ProposalItemCategory.teknisi,
          price: 400000.0,
        ),
        ProposalItem(
          id: 'item-3-4',
          title: 'Transportasi Operasional Denpasar',
          description: 'Biaya BBM & Operasional',
          category: ProposalItemCategory.transport,
          price: 100000.0,
        ),
      ],
    ),
    const Proposal(
      id: 'pro-4',
      code: 'PRO-2026-0039',
      clientName: 'Ayana Jimbaran Suite',
      initials: 'AJ',
      serviceName: 'Rodent & Fly Integrated Control',
      status: ProposalStatus.disetujui,
      date: '05 Agt 2026',
      validUntil: '05 Sep 2026',
      location: 'Jimbaran Cliff Area',
      version: '1',
      total: 15800000.0,
      shortAmount: 'Rp 15,8jt',
      cogs: 10200000.0,
      materialCost: 6800000.0,
      laborCost: 3000000.0,
      fuelCost: 400000.0,
      markup: 4034234.0,
      markupPercent: 39.0,
      servicePrice: 14234234.0,
      addon: 0.0,
      subtotal: 14234234.0,
      tax: 1565766.0,
      marginPct: 28.3,
      marginAmt: 4030000.0,
      shortMarginAmt: 'Rp 4,03jt',
      ppv: 1186000.0,
      ppm: 1186000.0,
      items: [
        ProposalItem(
          id: 'item-4-1',
          title: 'Rodent Bait Station (Tamper-Resistant)',
          description: 'Jumlah: 20 unit · Biaya Satuan: Rp 180.000 / unit',
          category: ProposalItemCategory.persiapan,
          price: 3600000.0,
        ),
        ProposalItem(
          id: 'item-4-2',
          title: 'Racumin Pasta & Fly Trap Glue Board',
          description: 'Jumlah: 10 pack · Biaya Satuan: Rp 320.000 / pack',
          category: ProposalItemCategory.persiapan,
          price: 3200000.0,
        ),
        ProposalItem(
          id: 'item-4-3',
          title: 'Tim Ahli Pengendali Hama (2 Teknisi)',
          description: '12 Kunjungan Rutin & Inspeksi Komprehensif',
          category: ProposalItemCategory.teknisi,
          price: 3000000.0,
        ),
        ProposalItem(
          id: 'item-4-4',
          title: 'Biaya Perjalanan Jimbaran Area',
          description: '12 Kunjungan × Rp 33.333 per visit',
          category: ProposalItemCategory.transport,
          price: 400000.0,
        ),
      ],
    ),
  ];

  @override
  Future<Result<List<Proposal>>> getProposals({
    String? query,
    String? status,
  }) async {
    try {
      var filtered = List<Proposal>.from(_proposals);

      if (status != null &&
          status.trim().isNotEmpty &&
          status.trim().toLowerCase() != 'all' &&
          status.trim().toLowerCase() != 'semua') {
        final st = status.trim().toLowerCase();
        filtered = filtered.where((p) {
          return p.status.value.toLowerCase() == st ||
              p.status.displayName.toLowerCase() == st ||
              p.status.name.toLowerCase() == st;
        }).toList();
      }

      if (query != null && query.trim().isNotEmpty) {
        final q = query.trim().toLowerCase();
        filtered = filtered.where((p) {
          return p.clientName.toLowerCase().contains(q) ||
              p.code.toLowerCase().contains(q) ||
              p.serviceName.toLowerCase().contains(q) ||
              p.location.toLowerCase().contains(q);
        }).toList();
      }

      return Ok(filtered);
    } catch (e) {
      return Err(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<Proposal>> getProposalById(String id) async {
    try {
      final target = _proposals.firstWhere(
        (p) => p.id == id || p.code == id,
        orElse: () =>
            throw Exception('Proposal dengan ID $id tidak ditemukan.'),
      );
      return Ok(target);
    } catch (e) {
      return Err(ServerFailure(e.toString()));
    }
  }
}

class ProposalRepositoryImpl implements ProposalRepository {
  final Dio _dio;
  final MockProposalRepositoryImpl _mockFallback = MockProposalRepositoryImpl();

  ProposalRepositoryImpl(this._dio);

  @override
  Future<Result<List<Proposal>>> getProposals({String? query, String? status}) {
    return _mockFallback.getProposals(query: query, status: status);
  }

  @override
  Future<Result<Proposal>> getProposalById(String id) {
    return _mockFallback.getProposalById(id);
  }

  @override
  Future<Result<Proposal>> createProposal(CreateProposalInput input) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/v1/sales/proposals',
        data: input.toJson(),
      );
      final data = response.data?['data'] as Map<String, dynamic>?;
      if (data == null) {
        return const Err(ServerFailure('Invalid response data from server'));
      }
      // Map response to Proposal
      final proposal = Proposal(
        id: data['id'] as String? ?? '',
        code: data['code'] as String? ?? '',
        clientName: 'Unknown Client', // From mock UI until GET works
        serviceName: 'Unknown Service',
        status: ProposalStatus.draft,
        date: data['proposal_date'] as String? ?? '',
        validUntil: input.validUntil ?? 'N/A',
        location: input.addressId ?? 'N/A',
        total: (data['total_amount'] as num?)?.toDouble() ?? 0.0,
      );
      return Ok(proposal);
    } on DioException catch (e) {
      return Err(mapDioException(e));
    } catch (e) {
      return Err(UnknownFailure(e.toString()));
    }
  }
}
