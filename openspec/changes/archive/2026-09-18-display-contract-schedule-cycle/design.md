## Context

The backend system classifies contract visit quotas into two distinct cycles:
1. `Yearly` (`schedule_cycle = 1`): whole-lifetime quota for the contract duration.
2. `Monthly` (`schedule_cycle = 2`): recurring quota renewed every calendar month.

In `centrow-sales`, the `ContractCategory` and `Contract` entities do not currently parse or expose this cycle, resulting in generic "TOTAL KUNJUNGAN" labels in `ContractDetailPane` and no visual cycle indicator when selecting categories in `ContractFormBottomSheet`.

## Goals / Non-Goals

**Goals:**
- Define a `ContractScheduleCycle` enum in `lib/modules/sales/entities/contract_category.dart` (or shared contract entity) with `id`, `displayName` ('Tahunan' / 'Bulanan'), and `unitPeriod` ('tahun' / 'bulan').
- Parse `schedule_cycle` in `ContractCategoryDto` and `ContractDetailDto`, mapping it to `ContractCategory.scheduleCycle` and `Contract.scheduleCycle`.
- Render dynamic visit frequency labels in `ContractDetailPane`:
  - Monthly: "FREK. KUNJUNGAN (BULANAN)" with value "${c.totalVisits}x / bulan".
  - Yearly: "FREK. KUNJUNGAN (TAHUNAN)" with value "${c.totalVisits}x / tahun".
  - Unspecified/Null: fallback to "TOTAL KUNJUNGAN" with "${c.totalVisits}x".
- Render schedule cycle indicators in `ContractFormBottomSheet` category selector (e.g. `"${cat.name} · ${cat.scheduleCycle.displayName}"`).

**Non-Goals:**
- Creating or editing schedule cycles on individual contracts (contracts strictly inherit cycle from category).
- Modifying backend APIs or scheduling logic.

## Decisions

### 1. `ContractScheduleCycle` Enum Design
```dart
enum ContractScheduleCycle {
  yearly(1, 'Tahunan', 'tahun'),
  monthly(2, 'Bulanan', 'bulan');

  final int id;
  final String displayName;
  final String unitPeriod;

  const ContractScheduleCycle(this.id, this.displayName, this.unitPeriod);

  bool get isMonthly => this == ContractScheduleCycle.monthly;
  bool get isYearly => this == ContractScheduleCycle.yearly;

  static ContractScheduleCycle? fromDynamic(dynamic val) {
    if (val == null) return null;
    if (val is num) {
      if (val.toInt() == 2) return ContractScheduleCycle.monthly;
      if (val.toInt() == 1) return ContractScheduleCycle.yearly;
    }
    final s = val.toString().toLowerCase().trim();
    if (s == '2' || s == 'monthly' || s == 'bulanan') return ContractScheduleCycle.monthly;
    if (s == '1' || s == 'yearly' || s == 'tahunan') return ContractScheduleCycle.yearly;
    return null;
  }
}
```
*Rationale*: Handles both integer IDs and string descriptors gracefully. Returning nullable allows clean fallback for legacy data.

### 2. UI Representation in `ContractDetailPane`
Rather than hardcoding string checks in the widget, provide helper getters on `Contract`:
- `String get visitFrequencyLabel`:
  - `monthly` => `'FREK. KUNJUNGAN (BULANAN)'`
  - `yearly` => `'FREK. KUNJUNGAN (TAHUNAN)'`
  - `null` => `'TOTAL KUNJUNGAN'`
- `String get formattedVisitFrequency`:
  - `monthly` => `'$totalVisits x / bulan'`
  - `yearly` => `'$totalVisits x / tahun'`
  - `null` => `'$totalVisits x'`

### 3. UI Representation in `ContractFormBottomSheet`
In `AppSearchableSelector<ContractCategory>`:
- Display category option as `"${cat.name} (${cat.scheduleCycle?.displayName ?? 'Tahunan'})"` so sales users immediately know whether they are creating a monthly or yearly contract.

## Risks / Trade-offs

- **[Risk] Payload field naming mismatch**: Backend may supply `schedule_cycle` in category and either `schedule_cycle` or `category_schedule_cycle` in contract detail.
  - *Mitigation*: In `ContractDetailDto.fromJson`, inspect `json['schedule_cycle'] ?? json['category_schedule_cycle']`.
- **[Risk] Nullable legacy records**: Existing contract records created before schedule cycles may have null cycle.
  - *Mitigation*: Fall back to default behavior ("TOTAL KUNJUNGAN", "$totalVisits x") without throwing or breaking layout.
