import 'package:dio/dio.dart';
import '../../../shared/result/result.dart';
import '../../../shared/error/failure.dart';
import '../entities/customer.dart';

abstract interface class CustomerRepository {
  Future<Result<List<Customer>>> getCustomers({String? query, String? segment});
  Future<Result<Customer>> getCustomerById(String id);
}

const List<Customer> mockCustomers = [
  Customer(
    id: 'c1',
    code: 'CRM-0012',
    name: 'Villa Sari Dewi',
    initials: 'VS',
    segment: 'Villa',
    status: 'Aktif',
    regency: 'Kabupaten Badung, Bali',
    npwp: '12.345.678.9-567.000',
    phone: '+62 812-3456-7890',
    phoneAlt: '+62 811-9876-5432',
    email: 'contact@villasaridewi.com',
    scanCode: 'QR-VS-0012-BDG',
    riskNotes:
        'Tidak ada riwayat tunggakan bayar, pembayaran lancar (Termin Net 30).',
    notes:
        'Akses gerbang satpam 24 jam. Disarankan treatment sebelum tamu check-in (pukul 08:00 – 10:00 WITA).',
    locations: [
      CustomerLocation(
        isPrimary: true,
        label: 'Villa Utama & Club House',
        address: 'Jl. Raya Seminyak No. 88, Kuta, Badung, Bali 80361',
        area: '1.200 m²',
        district: 'Kecamatan Kuta · Kelurahan Seminyak',
        coords: '-8.6913, 115.1682',
      ),
      CustomerLocation(
        isPrimary: false,
        label: 'Gudang Logistik & Laundry Annex',
        address: 'Jl. Sunset Road Gg. Melati No. 4, Kuta, Badung',
        area: '450 m²',
        district: 'Kecamatan Kuta',
        coords: '-8.6980, 115.1740',
      ),
    ],
    contacts: [
      CustomerContact(
        name: 'Budi Santoso',
        initials: 'BS',
        position: 'General Manager',
        email: 'budi@villasaridewi.com',
        phone: '+62 812-3456-7890',
        role: 'Pengambil Keputusan',
        roleBadge: 'brand',
      ),
      CustomerContact(
        name: 'Sari Rahayu',
        initials: 'SR',
        position: 'Duty Manager Operasional',
        email: 'sari@villasaridewi.com',
        phone: '+62 811-9876-5432',
        role: 'Koordinator Lapangan',
        roleBadge: 'neutral',
      ),
      CustomerContact(
        name: 'Wayan Sudarta',
        initials: 'WS',
        position: 'Chief Engineering / SPV',
        email: 'wayan.eng@villasaridewi.com',
        phone: '+62 813-7788-9900',
        role: 'Teknis & Lapangan',
        roleBadge: 'neutral',
      ),
    ],
    proposals: [
      CustomerProposalSummary(
        title: 'Termite Protection Plan (2 Tahun)',
        code: 'PRO-2026-0042',
        date: '12 Agt 2026',
        amount: 'Rp 8.158.500',
        status: 'Dikirim',
        badgeType: 'info',
      ),
      CustomerProposalSummary(
        title: 'General Pest Control Rutin Bulanan',
        code: 'PRO-2025-0118',
        date: '15 Jan 2026',
        amount: 'Rp 4.500.000',
        status: 'Disetujui',
        badgeType: 'ok',
      ),
    ],
  ),
  Customer(
    id: 'c2',
    code: 'CRM-0084',
    name: 'Grand Hyatt Nusa Dua',
    initials: 'GH',
    segment: 'Hotel',
    status: 'Aktif',
    regency: 'Kabupaten Badung, Bali',
    npwp: '01.234.567.8-051.000',
    phone: '+62 361-771234',
    phoneAlt: '+62 812-4455-6677',
    email: 'procurement@grandhyattbali.com',
    scanCode: 'QR-GH-0084-ND',
    riskNotes:
        'Pelanggan korporat tier-A, proses approval PO membutuhkan waktu 14 hari kerja.',
    notes:
        'Akses melalui Loading Dock B. Wajib sertifikat safety dan APD lengkap bagi teknisi.',
    locations: [
      CustomerLocation(
        isPrimary: true,
        label: 'Area Utama Hotel & Resor',
        address: 'Kawasan Wisata Nusa Dua BTDC, Badung 80363',
        area: '45.000 m²',
        district: 'Kecamatan Kuta Selatan · Kelurahan Benoa',
        coords: '-8.8021, 115.2310',
      ),
    ],
    contacts: [
      CustomerContact(
        name: 'Michael Wong',
        initials: 'MW',
        position: 'Director of Operations',
        email: 'michael.wong@hyatt.com',
        phone: '+62 811-3882-990',
        role: 'Pengambil Keputusan',
        roleBadge: 'brand',
      ),
      CustomerContact(
        name: 'Ketut Astawa',
        initials: 'KA',
        position: 'Executive Housekeeper',
        email: 'ketut.astawa@hyatt.com',
        phone: '+62 812-3901-2233',
        role: 'Koordinator Lapangan',
        roleBadge: 'neutral',
      ),
    ],
    proposals: [
      CustomerProposalSummary(
        title: 'Integrated Pest Management Full Facility',
        code: 'PRO-2026-0038',
        date: '02 Agt 2026',
        amount: 'Rp 48.000.000',
        status: 'Negosiasi',
        badgeType: 'warn',
      ),
    ],
  ),
  Customer(
    id: 'c3',
    code: 'CRM-0201',
    name: 'Resto Warung Bumi',
    initials: 'WB',
    segment: 'Restoran',
    status: 'Aktif',
    regency: 'Kota Denpasar, Bali',
    npwp: '31.888.999.0-901.000',
    phone: '+62 361-223344',
    phoneAlt: '+62 819-3344-5566',
    email: 'operasional@warungbumi.co.id',
    scanCode: 'QR-WB-0201-DPS',
    riskNotes: 'Pembayaran tunai / transfer per invoice 14 hari lancar.',
    notes:
        'Jadwal servis rutin hanya boleh dilakukan setelah resto tutup (pukul 22:30 WITA).',
    locations: [
      CustomerLocation(
        isPrimary: true,
        label: 'Restoran Utama & Dapur Pusat',
        address: 'Jl. Teuku Umar Barat No. 12, Denpasar Barat',
        area: '320 m²',
        district: 'Kecamatan Denpasar Barat',
        coords: '-8.6791, 115.2014',
      ),
    ],
    contacts: [
      CustomerContact(
        name: 'Dewi Lestari',
        initials: 'DL',
        position: 'Owner & Managing Partner',
        email: 'dewi@warungbumi.co.id',
        phone: '+62 819-3344-5566',
        role: 'Pengambil Keputusan',
        roleBadge: 'brand',
      ),
      CustomerContact(
        name: 'Komang Sujana',
        initials: 'KS',
        position: 'Head Chef & Kitchen SPV',
        email: 'komang.kitchen@warungbumi.co.id',
        phone: '+62 812-4455-7788',
        role: 'Koordinator Lapangan',
        roleBadge: 'neutral',
      ),
    ],
    proposals: [
      CustomerProposalSummary(
        title: 'Food Safety Pest Prevention Contract 1 Th',
        code: 'PRO-2026-0029',
        date: '20 Jul 2026',
        amount: 'Rp 14.400.000',
        status: 'Disetujui',
        badgeType: 'ok',
      ),
    ],
  ),
  Customer(
    id: 'c4',
    code: 'CRM-0512',
    name: 'Puri Bali Residence',
    initials: 'PB',
    segment: 'Villa',
    status: 'Aktif',
    regency: 'Kabupaten Gianyar, Bali',
    npwp: '02.555.777.8-902.000',
    phone: '+62 361-975544',
    phoneAlt: '+62 813-8899-0011',
    email: 'estate@puribali-ubud.com',
    scanCode: 'QR-PB-0512-UBUD',
    riskNotes:
        'Cluster perumahan privat 12 unit villa sewa. Pembayaran via paguyuban estate.',
    notes:
        'Fogging nyamuk berkala wajib konfirmasi H-1 ke seluruh penghuni villa.',
    locations: [
      CustomerLocation(
        isPrimary: true,
        label: 'Kompleks Hunian & Area Taman',
        address: 'Jl. Raya Sayan No. 45, Ubud, Gianyar 80571',
        area: '8.500 m²',
        district: 'Kecamatan Ubud',
        coords: '-8.5123, 115.2456',
      ),
    ],
    contacts: [
      CustomerContact(
        name: 'Cynthia Tan',
        initials: 'CT',
        position: 'Estate Manager',
        email: 'cynthia@puribali-ubud.com',
        phone: '+62 813-8899-0011',
        role: 'Pengambil Keputusan',
        roleBadge: 'brand',
      ),
    ],
    proposals: [
      CustomerProposalSummary(
        title: 'Mosquito & Garden Pest Management (6 Bln)',
        code: 'PRO-2026-0015',
        date: '05 Jun 2026',
        amount: 'Rp 9.600.000',
        status: 'Disetujui',
        badgeType: 'ok',
      ),
    ],
  ),
  Customer(
    id: 'c5',
    code: 'CRM-0633',
    name: 'Starbucks Reserve Sunset',
    initials: 'SR',
    segment: 'Restoran',
    status: 'Aktif',
    regency: 'Kabupaten Badung, Bali',
    npwp: '01.000.222.3-091.000',
    phone: '+62 361-8475900',
    phoneAlt: '+62 811-1234-5678',
    email: 'store.sunset@map.co.id',
    scanCode: 'QR-SR-0633-KUTA',
    riskNotes:
        'Pelanggan jaringan F&B multinasional. Audit HACCP ketat per kuartal.',
    notes:
        'Teknisi wajib mengisi log book monitoring trap hama pada setiap kunjungan.',
    locations: [
      CustomerLocation(
        isPrimary: true,
        label: 'Store & Drive-thru Area',
        address: 'Jl. Sunset Road No. 89, Kuta, Badung',
        area: '650 m²',
        district: 'Kecamatan Kuta',
        coords: '-8.6945, 115.1762',
      ),
    ],
    contacts: [
      CustomerContact(
        name: 'Andi Prasetyo',
        initials: 'AP',
        position: 'Store Manager',
        email: 'andi.prasetyo@map.co.id',
        phone: '+62 811-1234-5678',
        role: 'Koordinator Lapangan',
        roleBadge: 'neutral',
      ),
      CustomerContact(
        name: 'Rina Melinda',
        initials: 'RM',
        position: 'Regional QA / QC',
        email: 'rina.qa@map.co.id',
        phone: '+62 812-9988-7766',
        role: 'Pengambil Keputusan',
        roleBadge: 'brand',
      ),
    ],
    proposals: [
      CustomerProposalSummary(
        title: 'Audit Pest Control Standar HACCP (1 Th)',
        code: 'PRO-2026-0044',
        date: '14 Agt 2026',
        amount: 'Rp 18.000.000',
        status: 'Draft',
        badgeType: 'neutral',
      ),
    ],
  ),
  Customer(
    id: 'c6',
    code: 'CRM-0710',
    name: 'RS Bali Mandara',
    initials: 'BM',
    segment: 'Komersial',
    status: 'Aktif',
    regency: 'Kota Denpasar, Bali',
    npwp: '00.123.456.7-903.000',
    phone: '+62 361-4490500',
    phoneAlt: '+62 813-3700-1122',
    email: 'sanitasi@rsbalimandara.go.id',
    scanCode: 'QR-BM-0710-DPS',
    riskNotes:
        'Instansi pelayanan kesehatan publik. Pembayaran APBD termin per triwulan.',
    notes:
        'Area rawat inap dan ICU menggunakan metode non-kimia (baiting & ultrasonic).',
    locations: [
      CustomerLocation(
        isPrimary: true,
        label: 'Gedung Pelayanan & Rawat Inap',
        address: 'Jl. Bypass Ngurah Rai No. 548, Sanur, Denpasar',
        area: '18.000 m²',
        district: 'Kecamatan Denpasar Selatan',
        coords: '-8.6956, 115.2534',
      ),
    ],
    contacts: [
      CustomerContact(
        name: 'dr. I Made Sukarta',
        initials: 'IS',
        position: 'Kepala Instalasi Sanitasi & K3RS',
        email: 'dr.sukarta@rsbalimandara.go.id',
        phone: '+62 813-3700-1122',
        role: 'Pengambil Keputusan',
        roleBadge: 'brand',
      ),
      CustomerContact(
        name: 'Ni Luh Putu Anggraini',
        initials: 'NA',
        position: 'Sanitarian Pelaksana',
        email: 'luh.sanitasi@rsbalimandara.go.id',
        phone: '+62 818-0555-4433',
        role: 'Koordinator Lapangan',
        roleBadge: 'neutral',
      ),
    ],
    proposals: [
      CustomerProposalSummary(
        title: 'Sanitasi Medis & Pengendalian Vektor RS',
        code: 'PRO-2026-0010',
        date: '10 Mei 2026',
        amount: 'Rp 36.000.000',
        status: 'Disetujui',
        badgeType: 'ok',
      ),
    ],
  ),
  Customer(
    id: 'c7',
    code: 'CRM-0842',
    name: 'Finns Beach Club Canggu',
    initials: 'FB',
    segment: 'Komersial',
    status: 'Aktif',
    regency: 'Kabupaten Badung, Bali',
    npwp: '02.999.888.7-052.000',
    phone: '+62 361-8446327',
    phoneAlt: '+62 812-3800-4499',
    email: 'ops@finnsbeachclub.com',
    scanCode: 'QR-FB-0842-CGU',
    riskNotes:
        'Beach club outdoor skala besar. High risk lalat dan burung camar.',
    notes:
        'Treatment area bar & kitchen jam 06:00 WITA. Area outdoor daytime non-toxic repellant.',
    locations: [
      CustomerLocation(
        isPrimary: true,
        label: 'Beach Club Front & Lagoon Pool Area',
        address: 'Jl. Pantai Berawa No. 99, Canggu, Kuta Utara',
        area: '12.000 m²',
        district: 'Kecamatan Kuta Utara',
        coords: '-8.6651, 115.1389',
      ),
    ],
    contacts: [
      CustomerContact(
        name: 'David Miller',
        initials: 'DM',
        position: 'General Manager Club Ops',
        email: 'david.m@finnsbeachclub.com',
        phone: '+62 812-3800-4499',
        role: 'Pengambil Keputusan',
        roleBadge: 'brand',
      ),
      CustomerContact(
        name: 'Gede Yudiarta',
        initials: 'GY',
        position: 'Facilities & Hygiene Manager',
        email: 'gede.y@finnsbeachclub.com',
        phone: '+62 813-5321-7788',
        role: 'Koordinator Lapangan',
        roleBadge: 'neutral',
      ),
    ],
    proposals: [
      CustomerProposalSummary(
        title: 'Fly & Vector Control High-Traffic Outdoor',
        code: 'PRO-2026-0046',
        date: '16 Agt 2026',
        amount: 'Rp 24.500.000',
        status: 'Negosiasi',
        badgeType: 'warn',
      ),
    ],
  ),
];

class CustomerRepositoryImpl implements CustomerRepository {
  final Dio _dio;
  final bool useMock;

  CustomerRepositoryImpl(this._dio, {this.useMock = true});

  Dio get dio => _dio;

  @override
  Future<Result<List<Customer>>> getCustomers({
    String? query,
    String? segment,
  }) async {
    if (useMock) {
      var results = mockCustomers;
      if (query != null && query.trim().isNotEmpty) {
        final q = query.trim().toLowerCase();
        results = results
            .where(
              (c) =>
                  c.name.toLowerCase().contains(q) ||
                  c.code.toLowerCase().contains(q) ||
                  c.regency.toLowerCase().contains(q),
            )
            .toList();
      }
      if (segment != null && segment != 'all') {
        results = results.where((c) => c.segment == segment).toList();
      }
      return Ok(results);
    }
    return const Err(UnknownFailure('Not implemented'));
  }

  @override
  Future<Result<Customer>> getCustomerById(String id) async {
    if (useMock) {
      try {
        return Ok(mockCustomers.firstWhere((c) => c.id == id));
      } catch (_) {
        return const Err(ServerFailure('Customer tidak ditemukan', 404));
      }
    }
    return const Err(UnknownFailure('Not implemented'));
  }
}
