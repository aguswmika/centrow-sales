## Context

Lihat `proposal.md` untuk motivasi dan latar belakang masalah.
Arsitektur saat ini menggunakan Flutter dengan layered architecture (`View -> Controller -> Repository -> Entity`), `signals` untuk state management di controller, dan `getIt` untuk service locator. Controller diregistrasikan sebagai `factory` di `app/di.dart`, sedangkan repository dan network client sebagai `lazySingleton`. Halaman utama dibungkus dalam `StatefulShellRoute.indexedStack` sehingga instance halaman tetap hidup di memori.

## Goals / Non-Goals

**Goals:**
- Menyediakan `DataSyncService` yang murni Dart di `lib/shared/sync/` untuk menyebarkan event mutasi data.
- Memastikan controller yang sedang aktif di memori (`CustomerController`, `ProposalController`, `ContractController`) otomatis me-reload master list dan detail data saat entitas terkait dimutasi.
- Menghentikan ketergantungan pada passing `extra: {'refresh': true}` lewat GoRouter.
- Memastikan tidak ada memory leak dengan membatalkan langganan event saat controller di-`dispose()`.

**Non-Goals:**
- Mengubah WebSocket atau SSE backend (sinkronisasi ini berbasis event lokal aplikasi atas aksi pengguna di perangkat).
- Mengubah arsitektur dasar `getIt` atau `signals`.

## Decisions

### 1. Pure Dart Stream-based / Signal-based Event Bus
- **Keputusan**: `DataSyncService` menggunakan `StreamController<DataSyncEvent>.broadcast()` atau kombinasi readonly `Signal<DataSyncEvent?>` murni Dart.
- **Rasional**: `lib/shared/` tidak boleh mengimpor Flutter widget untuk menjaga controllers tetap UI-free dan unit-testable sesuai aturan `AGENTS.md`.
- **Alternatif yang dipertimbangkan**:
  - *Navigator callbacks*: Rapuh ketika menggunakan nested routes / dialog / IndexedStack.
  - *InheritedWidget / Provider*: Melanggar pemisahan Controller dari Flutter widget.

### 2. Sealed Classes untuk Event Hirarki
- **Keputusan**: Mendefinisikan `sealed class DataSyncEvent` dengan turunan `CustomerSyncEvent`, `ProposalSyncEvent`, `PricingSyncEvent`, dan `ContractSyncEvent`.
- **Rasional**: Memungkinkan controller melakukan exhaustive pattern matching dengan `switch` expression Dart, aman dari typo dan tipe yang tidak terdefinisi.

### 3. Lifecycle-Aware Subscription di Controller
- **Keputusan**: Controller menerima `DataSyncService` melalui constructor injection. Langganan stream disimpan dalam `StreamSubscription` dan dibatalkan di method `dispose()`.
- **Rasional**: Mencegah memory leak saat halaman dan controller ditutup.

### 4. Re-fetch Detail Spesifik
- **Keputusan**: Saat event diterima, controller tidak hanya memanggil `loadX(isRefresh: true)` tetapi juga memeriksa apakah ID yang aktif sama dengan ID event; jika sama, memanggil `selectX(id)` untuk mem-fetch ulang data detail dari server.
- **Rasional**: Endpoint daftar (`getCustomers`, `getProposals`) hanya mengembalikan summary DTO, sedangkan detail pane membutuhkan data lengkap (locations, contacts, items).

## Risks / Trade-offs

- **[Panggilan API ganda jika mutasi cepat]** → Mitigasi: Controller memeriksa ID yang sedang aktif sebelum memicu `selectX(id)`, dan pemanggilan list menggunakan debouncing / status isRefresh.
- **[Cross-module cycle]** → Mitigasi: Event bus hanya one-way emit; handler hanya melakukan fetch query, tidak memancarkan event mutasi baru.
