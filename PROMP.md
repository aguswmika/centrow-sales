# API Contract & Specifications: Pelanggan (Customer) Feature

Dokumen ini berisi spesifikasi lengkap API Request & Response yang dibutuhkan oleh aplikasi **Centrow Sales** (Flutter) pada halaman **Daftar & Detail Pelanggan (Customer Master-Detail)** untuk integrasi backend produksi.

---

## 1. Authentication & Common Headers

Setiap permintaan dari aplikasi Centrow Sales ke endpoint backend **wajib** menyertakan header berikut:

```http
Authorization: Bearer <jwt_access_token>
X-Tenant-ID: <tenant_id_or_slug>
X-App-Client: sales
X-Version: 1.0.0
Content-Type: application/json
Accept: application/json
```

### Penjelasan Header:
- `Authorization`: Bearer JWT token hasil autentikasi login pengguna.
- `X-Tenant-ID`: Identifier cabang / tenant aktif (contoh: `t_bali_01`).
- `X-App-Client`: Mengidentifikasi client pengirim request (`sales`). Backend menggunakan header ini untuk penegakan scope role/app, filter konfigurasi sales, audit trail, dan analitik.
- `X-Version`: Versi aplikasi klien (contoh: `1.0.0`) untuk pengecekan kompatibilitas API, deprecation warning, dan audit versi.
- `Content-Type`: Format payload body (`application/json`).
- `Accept`: Format response yang diharapkan (`application/json`).

---

## 2. Standard API Response Structure

Semua response backend mengikuti struktur standar konsisten:

```json
{
  "success": true,
  "message": "Deskripsi status operasi",
  "data": { ... },
  "meta": { ... },
  "errors": null
}
```

---

## 3. Endpoints

### 3.1. Get Customer List (Master List with Pagination & Filter)

Mengambil daftar pelanggan untuk kolom master di sebelah kiri dengan filter pencarian dan segmen usaha.

- **Method**: `GET`
- **Path**: `/api/v1/sales/customers`
- **Query Parameters**:

| Parameter | Type | Required | Default | Description |
|---|---|---|---|---|
| `q` | `string` | No | `""` | Kata kunci pencarian (Nama pelanggan, Kode CRM, NPWP, Telepon, Email, Wilayah) |
| `segment` | `string` | No | `all` | Filter segmen usaha: `all`, `Villa`, `Hotel`, `Restoran`, `Komersial`, `Residensial`, `Kesehatan`, `Pendidikan`, `Industri`, `Lainnya` |
| `status` | `string` | No | `all` | Filter status: `all`, `active`, `inactive` |
| `regency` | `string` | No | `all` | Filter wilayah kabupaten: `all`, `Badung`, `Denpasar`, `Gianyar`, `Tabanan`, `Klungkung`, dll. |
| `page` | `integer` | No | `1` | Nomor halaman (1-based index) |
| `limit` | `integer` | No | `20` | Jumlah item per halaman (max 100) |
| `sort_by` | `string` | No | `created_at` | Field sorting: `name`, `code`, `created_at`, `updated_at` |
| `sort_order` | `string` | No | `desc` | Urutan sorting: `asc`, `desc` |

#### Request Example:
```http
GET /api/v1/sales/customers?q=Dewi&segment=Villa&status=active&page=1&limit=20&sort_by=name&sort_order=asc HTTP/1.1
Host: api.centrow.id
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
X-Tenant-ID: t_bali_01
X-App-Client: sales
X-Version: 1.0.0
Accept: application/json
```

#### Response Example (`200 OK`):
```json
{
  "success": true,
  "message": "Daftar pelanggan berhasil dimuat",
  "data": [
    {
      "id": "c1",
      "code": "CRM-0012",
      "name": "Villa Sari Dewi",
      "initials": "VS",
      "segment": "Villa",
      "status": "Aktif",
      "regency": "Kab. Badung",
      "phone": "+62 812-3456-7890",
      "email": "contact@villasaridewi.com",
      "npwp": "12.345.678.9-567.000",
      "scan_code": "QR-VS-0012-BDG",
      "primary_address": "Jl. Pantai Berawa No. 88, Tibubeneng, Kuta Utara, Badung",
      "active_proposals_count": 2,
      "active_contracts_count": 1,
      "created_at": "2026-01-15T08:30:00.000Z",
      "updated_at": "2026-08-10T14:20:00.000Z"
    },
    {
      "id": "c2",
      "code": "CRM-0084",
      "name": "Grand Hyatt Nusa Dua",
      "initials": "GH",
      "segment": "Hotel",
      "status": "Aktif",
      "regency": "Kab. Badung",
      "phone": "+62 811-9876-5432",
      "email": "procurement@grandhyattnusa.com",
      "npwp": "01.234.567.8-901.000",
      "scan_code": "QR-GH-0084-BDG",
      "primary_address": "Kawasan Wisata Nusa Dua BTDC, Benoa, Badung",
      "active_proposals_count": 1,
      "active_contracts_count": 2,
      "created_at": "2026-02-01T09:15:00.000Z",
      "updated_at": "2026-08-12T10:00:00.000Z"
    },
    {
      "id": "c3",
      "code": "CRM-0201",
      "name": "Resto Warung Bumi",
      "initials": "WB",
      "segment": "Restoran",
      "status": "Aktif",
      "regency": "Kota Denpasar",
      "phone": "+62 813-2222-3333",
      "email": "ops@warungbumi.id",
      "npwp": "31.456.789.0-123.000",
      "scan_code": "QR-WB-0201-DPS",
      "primary_address": "Jl. Hayam Wuruk No. 45, Denpasar Timur",
      "active_proposals_count": 0,
      "active_contracts_count": 1,
      "created_at": "2026-03-10T11:00:00.000Z",
      "updated_at": "2026-07-28T16:45:00.000Z"
    },
    {
      "id": "c4",
      "code": "CRM-0512",
      "name": "Puri Bali Residence",
      "initials": "PB",
      "segment": "Villa",
      "status": "Aktif",
      "regency": "Kab. Gianyar",
      "phone": "+62 819-8765-4321",
      "email": "management@puribaliresidence.com",
      "npwp": "45.678.901.2-345.000",
      "scan_code": "QR-PB-0512-GNR",
      "primary_address": "Jl. Raya Ubud No. 12, Ubud, Gianyar",
      "active_proposals_count": 1,
      "active_contracts_count": 0,
      "created_at": "2026-04-18T10:20:00.000Z",
      "updated_at": "2026-08-05T09:10:00.000Z"
    },
    {
      "id": "c5",
      "code": "CRM-0633",
      "name": "Starbucks Reserve Sunset",
      "initials": "SR",
      "segment": "Restoran",
      "status": "Aktif",
      "regency": "Kab. Badung",
      "phone": "+62 821-4567-8901",
      "email": "facility@starbucksbali.co.id",
      "npwp": "02.345.678.9-012.000",
      "scan_code": "QR-SR-0633-BDG",
      "primary_address": "Jl. Sunset Road No. 77, Kuta, Badung",
      "active_proposals_count": 1,
      "active_contracts_count": 1,
      "created_at": "2026-05-02T13:40:00.000Z",
      "updated_at": "2026-08-01T11:25:00.000Z"
    },
    {
      "id": "c6",
      "code": "CRM-0710",
      "name": "RS Bali Mandara",
      "initials": "BM",
      "segment": "Komersial",
      "status": "Aktif",
      "regency": "Kota Denpasar",
      "phone": "+62 812-7777-8888",
      "email": "sanitasi@rsbalimandara.go.id",
      "npwp": "00.111.222.3-444.000",
      "scan_code": "QR-BM-0710-DPS",
      "primary_address": "Jl. Bypass Ngurah Rai No. 548, Sanur Kauh, Denpasar",
      "active_proposals_count": 1,
      "active_contracts_count": 2,
      "created_at": "2026-05-20T08:00:00.000Z",
      "updated_at": "2026-08-11T15:30:00.000Z"
    },
    {
      "id": "c7",
      "code": "CRM-0842",
      "name": "Finns Beach Club Canggu",
      "initials": "FB",
      "segment": "Komersial",
      "status": "Aktif",
      "regency": "Kab. Badung",
      "phone": "+62 811-3333-4444",
      "email": "operations@finnsbeachclub.com",
      "npwp": "56.789.012.3-456.000",
      "scan_code": "QR-FB-0842-BDG",
      "primary_address": "Jl. Pantai Berawa No. 99, Canggu, Badung",
      "active_proposals_count": 2,
      "active_contracts_count": 1,
      "created_at": "2026-06-05T14:10:00.000Z",
      "updated_at": "2026-08-14T17:00:00.000Z"
    }
  ],
  "meta": {
    "pagination": {
      "total_items": 7,
      "total_pages": 1,
      "current_page": 1,
      "limit": 20,
      "has_next_page": false,
      "has_prev_page": false
    },
    "segments_summary": {
      "all": 7,
      "Villa": 2,
      "Hotel": 1,
      "Restoran": 2,
      "Komersial": 2
    }
  },
  "errors": null
}
```

---

### 3.2. Get Customer Detail by ID (Master-Detail Right Pane)

Mengambil detail lengkap 1 pelanggan mencakup informasi utama, daftar lokasi servis, kontak person/PIC, dan riwayat proposal.

- **Method**: `GET`
- **Path**: `/api/v1/sales/customers/{id}`

#### Request Example:
```http
GET /api/v1/sales/customers/c1 HTTP/1.1
Host: api.centrow.id
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
X-Tenant-ID: t_bali_01
X-App-Client: sales
X-Version: 1.0.0
Accept: application/json
```

#### Response Example (`200 OK`):
```json
{
  "success": true,
  "message": "Detail pelanggan berhasil dimuat",
  "data": {
    "id": "c1",
    "code": "CRM-0012",
    "name": "Villa Sari Dewi",
    "initials": "VS",
    "segment": "Villa",
    "status": "Aktif",
    "regency": "Kabupaten Badung, Bali",
    "npwp": "12.345.678.9-567.000",
    "phone": "+62 812-3456-7890",
    "phone_alt": "+62 811-9876-5432",
    "email": "contact@villasaridewi.com",
    "scan_code": "QR-VS-0012-BDG",
    "risk_notes": "Tidak ada riwayat tunggakan bayar, pembayaran lancar (Termin Net 30).",
    "notes": "Akses gerbang satpam 24 jam. Disarankan treatment sebelum tamu check-in (pukul 08:00 – 10:00 WITA).",
    "created_at": "2026-01-15T08:30:00.000Z",
    "updated_at": "2026-08-10T14:20:00.000Z",
    "locations": [
      {
        "id": "loc_1",
        "customer_id": "c1",
        "is_primary": true,
        "label": "Villa Utama & Private Pool Area",
        "address": "Jl. Pantai Berawa No. 88, Gang Dewi Sari",
        "area": "Luas Area: 1.200 m² (2 Lantai, 6 Kamar Tidur)",
        "district": "Tibubeneng, Kuta Utara, Kab. Badung, Bali 80361",
        "coords": "-8.659821, 115.139842",
        "latitude": -8.659821,
        "longitude": 115.139842,
        "notes": "Fokus area: Taman belakang, deck kayu kolam renang (rawan rayap), kitchen & pantry."
      },
      {
        "id": "loc_2",
        "customer_id": "c1",
        "is_primary": false,
        "label": "Staff Quarters & Laundry Pavilion",
        "address": "Jl. Pantai Berawa No. 88B (Akses Pintu Samping)",
        "area": "Luas Area: 350 m² (1 Lantai)",
        "district": "Tibubeneng, Kuta Utara, Kab. Badung, Bali 80361",
        "coords": "-8.659910, 115.140015",
        "latitude": -8.659910,
        "longitude": 115.140015,
        "notes": "Fokus area: Tempat penyimpanan linen, saluran pembuangan air limbah, gudang logistik."
      }
    ],
    "contacts": [
      {
        "id": "pic_1",
        "customer_id": "c1",
        "name": "I Made Wijaya",
        "initials": "MW",
        "position": "General Manager & Operasional",
        "email": "gm@villasaridewi.com",
        "phone": "+62 812-3456-7890",
        "role": "Pengambil Keputusan",
        "role_badge": "brand",
        "is_primary": true
      },
      {
        "id": "pic_2",
        "customer_id": "c1",
        "name": "Ni Ketut Suartini",
        "initials": "KS",
        "position": "Finance & Purchasing Manager",
        "email": "finance@villasaridewi.com",
        "phone": "+62 813-9876-1234",
        "role": "Finance & Invoice",
        "role_badge": "neutral",
        "is_primary": false
      },
      {
        "id": "pic_3",
        "customer_id": "c1",
        "name": "Wayan Hendra",
        "initials": "WH",
        "position": "Chief Engineering & Maintenance",
        "email": "engineering@villasaridewi.com",
        "phone": "+62 818-0555-6677",
        "role": "PIC Lapangan",
        "role_badge": "info",
        "is_primary": false
      }
    ],
    "proposals": [
      {
        "id": "prop_1",
        "customer_id": "c1",
        "title": "Paket Integrated Pest & Rodent Management (1 Tahun)",
        "code": "PRO-2026-0042",
        "date": "14 Agu 2026",
        "amount": "Rp 12.000.000",
        "amount_raw": 12000000,
        "status": "Dikirim",
        "badge_type": "info",
        "valid_until": "2026-09-14T23:59:59.000Z"
      },
      {
        "id": "prop_2",
        "customer_id": "c1",
        "title": "Paket Termite Protection Plan 3 Tahun (Baiting + Barrier)",
        "code": "PRO-2026-0012",
        "date": "20 Jan 2026",
        "amount": "Rp 14.500.000",
        "amount_raw": 14500000,
        "status": "Disetujui",
        "badge_type": "ok",
        "valid_until": "2026-02-20T23:59:59.000Z"
      }
    ]
  },
  "errors": null
}
```

---

### 3.3. Create Customer (`POST /api/v1/sales/customers`)

Menambahkan pelanggan baru lengkap dengan lokasi awal dan PIC utama.

- **Method**: `POST`
- **Path**: `/api/v1/sales/customers`

#### Request Headers:
```http
POST /api/v1/sales/customers HTTP/1.1
Host: api.centrow.id
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
X-Tenant-ID: t_bali_01
X-App-Client: sales
X-Version: 1.0.0
Content-Type: application/json
Accept: application/json
```

#### Request Body (`POST /api/v1/sales/customers`):
```json
{
  "name": "Villa Kayu Manis Sanur",
  "segment": "Villa",
  "regency": "Kota Denpasar",
  "npwp": "11.222.333.4-555.000",
  "phone": "+62 812-9988-7766",
  "phone_alt": "+62 811-2233-4455",
  "email": "info@kayumanissanur.com",
  "risk_notes": "Klien baru, belum ada riwayat kredit.",
  "notes": "Akses kunci villa berada di pos satpam depan.",
  "locations": [
    {
      "is_primary": true,
      "label": "Main Villa & Garden",
      "address": "Jl. Danau Tamblingan No. 120",
      "area": "800 m²",
      "district": "Sanur, Denpasar Selatan",
      "coords": "-8.694821, 115.263842",
      "notes": "Pohon kamboja rawan ulat bulu & rayap tanah."
    }
  ],
  "contacts": [
    {
      "name": "Bpk. Made Dananjaya",
      "position": "Owner Representative",
      "email": "owner@kayumanissanur.com",
      "phone": "+62 812-9988-7766",
      "role": "Pengambil Keputusan",
      "role_badge": "brand",
      "is_primary": true
    }
  ]
}
```

#### Response Example (`201 Created`):
```json
{
  "success": true,
  "message": "Pelanggan baru berhasil ditambahkan",
  "data": {
    "id": "c8",
    "code": "CRM-0891",
    "name": "Villa Kayu Manis Sanur",
    "initials": "VK",
    "segment": "Villa",
    "status": "Aktif",
    "created_at": "2026-08-18T15:15:00.000Z"
  },
  "errors": null
}
```

---

## 4. Error Responses

Jika terjadi kesalahan, backend wajib mengembalikan status HTTP yang sesuai beserta format error standar:

### 4.1. Validation Error (`422 Unprocessable Entity`)
```json
{
  "success": false,
  "message": "Validasi input gagal",
  "data": null,
  "errors": [
    {
      "field": "name",
      "message": "Nama pelanggan wajib diisi minimal 3 karakter"
    },
    {
      "field": "email",
      "message": "Format email bisnis tidak valid"
    }
  ]
}
```

### 4.2. Unauthorized (`401 Unauthorized`)
```json
{
  "success": false,
  "message": "Sesi login telah berakhir, silakan login kembali",
  "data": null,
  "errors": [
    {
      "code": "ERR_TOKEN_EXPIRED",
      "message": "Token expired"
    }
  ]
}
```

### 4.3. Not Found (`404 Not Found`)
```json
{
  "success": false,
  "message": "Data pelanggan dengan ID tersebut tidak ditemukan",
  "data": null,
  "errors": null
}
```

---

## 5. Dart / Flutter Mapping Recommendations

| JSON Key | Dart Entity Field | Type |
|---|---|---|
| `id` | `id` | `String` |
| `code` | `code` | `String` |
| `name` | `name` | `String` |
| `initials` | `initials` | `String` |
| `segment` | `segment` | `String` |
| `status` | `status` | `String` |
| `regency` | `regency` | `String` |
| `npwp` | `npwp` | `String` |
| `phone` | `phone` | `String` |
| `phone_alt` | `phoneAlt` | `String` |
| `email` | `email` | `String` |
| `scan_code` | `scanCode` | `String` |
| `risk_notes` | `riskNotes` | `String` |
| `notes` | `notes` | `String` |
| `locations` | `locations` | `List<CustomerLocation>` |
| `contacts` | `contacts` | `List<CustomerContact>` |
| `proposals` | `proposals` | `List<CustomerProposalSummary>` |
