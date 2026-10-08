## Purpose

Menyediakan sinkronisasi event data aplikasi yang terpusat untuk memperbarui master list dan detail panel secara real-time pada modul penjualan saat terjadi mutasi data.

## Requirements

### Requirement: Sinkronisasi Data Pelanggan
Sistem SHALL memperbarui daftar pelanggan dan detail pelanggan aktif secara otomatis setiap kali data pelanggan dibuat, diperbarui, atau dihapus.

#### Scenario: Pembaruan data pelanggan merefresh detail dan list
- **WHEN** pengguna menyimpan perubahan pada form edit pelanggan
- **THEN** sistem memancarkan event pembaruan pelanggan dan controller pelanggan aktif memuat ulang daftar pelanggan serta mem-fetch ulang detail pelanggan yang sedang dipilih

### Requirement: Sinkronisasi Kalkulasi Pricing Proposal
Sistem SHALL memperbarui nilai total proposal dan status pricing pada daftar proposal serta detail proposal aktif setiap kali kalkulasi pricing disimpan.

#### Scenario: Konfirmasi simpan kalkulasi merefresh proposal aktif
- **WHEN** pengguna mengonfirmasi dan menyimpan kalkulasi harga dari halaman pricing preview
- **THEN** sistem memancarkan event pembaruan pricing dan controller proposal aktif memuat ulang daftar proposal serta mem-fetch ulang detail proposal yang bersangkutan

### Requirement: Sinkronisasi Status dan Transisi Proposal
Sistem SHALL memperbarui tampilan proposal secara menyeluruh ketika proposal dikirim, disetujui, ditolak, dibatalkan, atau direvisi.

#### Scenario: Aksi status proposal merefresh tampilan secara konsisten
- **WHEN** status proposal berhasil diperbarui melalui aksi terima, tolak, kirim, batalkan, atau revisi
- **THEN** sistem memancarkan event pembaruan proposal dan controller proposal memuat ulang data proposal serta memperbarui status pelanggan terkait jika sedang dibuka

### Requirement: Sinkronisasi Pembuatan Kontrak
Sistem SHALL memperbarui status proposal dan daftar kontrak saat kontrak baru dibuat dari proposal.

#### Scenario: Kontrak dibuat merefresh proposal dan kontrak
- **WHEN** kontrak baru berhasil dibuat dari proposal
- **THEN** sistem memancarkan event pembuatan kontrak dan controller kontrak aktif memuat ulang daftar kontrak serta proposal terkait diperbarui dengan tautan kontrak
