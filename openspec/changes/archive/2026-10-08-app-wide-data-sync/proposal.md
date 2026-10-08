## Why

Perubahan data di modul penjualan (seperti update pelanggan, kalkulasi pricing baru, perubahan status proposal, atau pembuatan kontrak) saat ini tidak otomatis memperbarui tampilan daftar (master list) maupun panel detail yang sedang aktif. Hal ini disebabkan karena antarmuka menggunakan `StatefulShellRoute.indexedStack` (halaman tetap hidup di memori) sementara aksi pembaruan hanya memanggil reload daftar secara lokal tanpa memperbarui state detail atau tidak terhubung lintas modul.

Perubahan ini memperkenalkan mekanisme sinkronisasi data global (`DataSyncService`) berbasis event di lapisan shared agar setiap mutasi data otomatis memicu pembaruan data segar pada controller aktif tanpa bergantung pada navigasi manual atau restart halaman.

## What Changes

- Menambahkan `DataSyncService` dan `DataSyncEvent` (sealed class) di `lib/shared/sync/` sebagai event bus sinkronisasi berbasis pure Dart.
- Mendaftarkan `DataSyncService` sebagai singleton di service locator `getIt`.
- Mengintegrasikan emisi event saat terjadi mutasi data:
  - `CustomerFormController`: memancarkan `CustomerSyncEvent` saat pelanggan berhasil dibuat atau diperbarui.
  - `PricingCalculatorController`: memancarkan `PricingSyncEvent` saat kalkulasi harga berhasil disimpan.
  - `ProposalController`: memancarkan `ProposalSyncEvent` saat proposal dikirim, disetujui, ditolak, dibatalkan, atau direvisi.
  - `ContractFormBottomSheet`: memancarkan `ContractSyncEvent` saat kontrak berhasil dibuat dari proposal.
- Mengintegrasikan konsumsi event pada controller aktif:
  - `CustomerController`: otomatis memuat ulang master list dan me-refresh detail pelanggan yang sedang dipilih saat menerima `CustomerSyncEvent` atau `ProposalSyncEvent`.
  - `ProposalController`: otomatis memuat ulang master list dan me-refresh detail proposal yang sedang dipilih saat menerima `PricingSyncEvent` atau `ProposalSyncEvent`.
  - `ContractController`: otomatis memuat ulang master list dan me-refresh detail kontrak saat menerima `ContractSyncEvent`.
- Menyederhanakan alur navigasi balik di UI agar tidak lagi bergantung pada passing parameter `extra: {'refresh': true}`.

## Capabilities

### New Capabilities
- `data-sync`: Layanan sinkronisasi data aplikasi yang mengoordinasikan pembaruan data master list dan detail panel secara reaktif saat terjadi mutasi data pada entitas Customer, Proposal, Pricing, dan Contract.

### Modified Capabilities
<!-- Tidak ada perubahan requirement spesifikasi fungsional bisnis yang sudah ada -->

## Impact

- **Kode yang terpengaruh**:
  - `lib/shared/sync/data_sync_service.dart` & `lib/shared/sync/data_sync_event.dart` (baru)
  - `lib/app/di.dart` (registrasi singleton dan factory controller)
  - `lib/modules/sales/controllers/customer_controller.dart`
  - `lib/modules/sales/controllers/customer_form_controller.dart`
  - `lib/modules/sales/controllers/proposal_controller.dart`
  - `lib/modules/sales/controllers/pricing_calculator_controller.dart`
  - `lib/modules/sales/controllers/contract_controller.dart`
  - `lib/modules/sales/views/pages/customer_page.dart`
  - `lib/modules/sales/views/pages/proposal_page.dart`
- **API & Dependencies**: Tidak ada penambahan dependensi pihak ketiga atau perubahan kontrak endpoint API backend.
