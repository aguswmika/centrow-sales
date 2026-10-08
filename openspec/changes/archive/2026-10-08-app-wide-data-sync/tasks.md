## 1. Shared Data Sync Infrastructure

- [x] 1.1 Buat `DataSyncEvent` (sealed class: `CustomerSyncEvent`, `ProposalSyncEvent`, `PricingSyncEvent`, `ContractSyncEvent`) di `lib/shared/sync/data_sync_event.dart` dan verifikasi unit test kompilasi.
- [x] 1.2 Buat `DataSyncService` di `lib/shared/sync/data_sync_service.dart` dengan stream event bus broadcast dan verifikasi tes unit di `test/shared/sync/data_sync_service_test.dart` lulus.
- [x] 1.3 Daftarkan `DataSyncService` sebagai lazy singleton di `lib/app/di.dart`.

## 2. Event Producers (Emisi Event)

- [x] 2.1 Injeksikan `DataSyncService` ke `CustomerFormController` dan panggil `emit(CustomerSyncEvent(id, action))` saat `submit()` berhasil, verifikasi dengan unit test.
- [x] 2.2 Injeksikan `DataSyncService` ke `PricingCalculatorController` dan panggil `emit(PricingSyncEvent(proposalId))` saat `submitPricing()` berhasil, verifikasi dengan unit test.
- [x] 2.3 Injeksikan `DataSyncService` ke `ProposalController` dan panggil `emit(ProposalSyncEvent(proposalId, action))` pada mutasi status (accept, reject, send, cancel), verifikasi dengan unit test.
- [x] 2.4 Panggil `emit(ContractSyncEvent(contractId, proposalId: proposalId))` saat kontrak baru berhasil dibuat di bottom sheet kontrak.

## 3. Event Consumers (Sinkronisasi Otomatis)

- [x] 3.1 Perbarui `CustomerController` untuk berlangganan `DataSyncService`: otomatis memuat ulang `loadCustomers(isRefresh: true)` dan me-refresh `selectCustomer(id)` jika customer yang diubah sedang dibuka, dan batalkan langganan di `dispose()`.
- [x] 3.2 Perbarui `ProposalController` untuk berlangganan `DataSyncService`: otomatis memuat ulang `loadProposals(isRefresh: true)` dan me-refresh `selectProposal(id)` saat event `PricingSyncEvent` atau `ProposalSyncEvent` diterima, dan batalkan langganan di `dispose()`.
- [x] 3.3 Perbarui `ContractController` untuk berlangganan `DataSyncService`: otomatis memuat ulang `loadContracts(isRefresh: true)` saat event `ContractSyncEvent` diterima.

## 4. UI Clean-up & Verifikasi

- [x] 4.1 Bersihkan alur balik navigasi di `customer_page.dart` dan `proposal_page.dart` yang sebelumnya mengandalkan polling manual atau `extra: {'refresh': true}`.
- [x] 4.2 Jalankan `flutter analyze` dan seluruh test suite modul sales untuk memastikan bebas error dan semua test lulus.
