# Plan: Align Pricing & Customer Code with Updated API Contracts

> Supersedes the earlier version of this plan.

## Goal

Update the pricing calculator DTO/controller/UI and the customer entity/DTO/repository to match the current API contracts (`pricings.md` and `customers.md`).

## Approach

After comparing both API docs against the Flutter implementation, I found **8 discrepancies** across pricing (5) and customers (3). Changes are bottom-up: Entity → DTO → Repository → Controller → View.

**Alternatives considered:**
- Breaking tool `PricingMaterialRow` into a separate class — rejected; shared class works, difference is only in the `total` formula.
- Keeping `tax_percent` name client-side and only mapping at serialization — rejected; cleaner to rename to `taxPercentage` throughout so it matches the API field name `tax_percentage`.

---

## Affected Files

| # | File | Change Type |
|---|------|-------------|
| 1 | `repositories/dtos/pricing_dto.dart` | Rename `taxPercent` → `taxPercentage` in field + JSON key; add `visitFrequency` to `PricingWorkerDto`; make `productId` nullable in `PricingItemDto` |
| 2 | `controllers/pricing_calculator_controller.dart` | Rename `taxPercent` → `taxPercentage`; fix tool `total` formula (amortize over contractMonths); pass `visitFrequency` per worker; pass `contractMonthsRef` to material rows |
| 3 | `views/widgets/pricing_calculator/pricing_margin_card.dart` | Use actual `visitFrequency`/`contractMonths` from controller; wrap in `SignalBuilder` |
| 4 | `views/widgets/pricing_calculator/pricing_cogs_card.dart` | Rename `taxPercent` → `taxPercentage` references |
| 5 | `entities/customer.dart` | Add `taxPercentage` field to `Customer` entity |
| 6 | `repositories/dtos/customer_dto.dart` | Parse `tax_percentage` in detail/list DTOs; send it in create/update request DTOs |
| 7 | `repositories/customer_repository.dart` | Parse PUT response with `CustomerDetailDto` instead of `CreateCustomerResponseDto` |
| 8 | `entities/create_customer_input.dart` | Add `taxPercentage` field to `CreateCustomerInput` |

---

## Steps

### Step 1 — Pricing DTO: Rename `taxPercent` → `taxPercentage`, add worker `visitFrequency`, fix item `productId` nullability

### Step 2 — Pricing Controller: Rename signal, fix tool total, send worker visit_frequency

### Step 3 — Pricing UI: Fix COGS card reference, fix Margin card divisors & reactivity

### Step 4 — Customer Entity: Add `taxPercentage`

### Step 5 — Customer DTO: Parse/send `tax_percentage`; fix PUT response parsing

### Step 6 — Customer Input Entity: Add `taxPercentage`

---

## Proposed Code (not yet applied)

### File 1: `lib/modules/sales/repositories/dtos/pricing_dto.dart`

Full replacement:

```dart
class CreatePricingRequestDto {
  final String customerId;
  final String serviceId;
  final int contractMonths;
  final int visitFrequency;
  final int markupType;
  final double markupValue;
  final double discountAmount;
  final double taxPercentage;
  final List<PricingMaterialDto> materials;
  final List<PricingWorkerDto> workers;
  final List<PricingItemDto> items;

  const CreatePricingRequestDto({
    required this.customerId,
    required this.serviceId,
    required this.contractMonths,
    required this.visitFrequency,
    required this.markupType,
    required this.markupValue,
    required this.discountAmount,
    required this.taxPercentage,
    required this.materials,
    required this.workers,
    required this.items,
  });

  Map<String, dynamic> toJson() => {
    'customer_id': customerId,
    'service_id': serviceId,
    'contract_months': contractMonths,
    'visit_frequency': visitFrequency,
    'markup_type': markupType,
    'markup_value': markupValue,
    'discount_amount': discountAmount,
    'tax_percentage': taxPercentage,
    'supplies': materials.map((e) => e.toJson()).toList(),
    'workers': workers.map((e) => e.toJson()).toList(),
    'items': items.map((e) => e.toJson()).toList(),
  };
}

class PricingMaterialDto {
  final int supplyType;
  final String? productMappingId;
  final String? productId;
  final String name;
  final String uomCode;
  final double? qty;
  final double? doseUsage;
  final String? doseUnitId;
  final double? applicationVolume;
  final String? applicationVolumeUnitId;
  final int frequency;

  const PricingMaterialDto({
    required this.supplyType,
    this.productMappingId,
    this.productId,
    required this.name,
    required this.uomCode,
    this.qty,
    this.doseUsage,
    this.doseUnitId,
    this.applicationVolume,
    this.applicationVolumeUnitId,
    required this.frequency,
  });

  Map<String, dynamic> toJson() => {
    'supply_type': supplyType,
    'name': name,
    'uom_code': uomCode,
    'frequency': frequency,
    if (supplyType == 1) ...{
      'product_mapping_id': productMappingId,
      'dose_usage': doseUsage,
      'dose_unit_id': doseUnitId,
      'application_volume': applicationVolume,
      'application_volume_unit_id': applicationVolumeUnitId,
    },
    if (supplyType == 2) ...{'product_id': productId, 'qty': qty},
  };
}

class PricingWorkerDto {
  final String positionName;
  final int? visitFrequency;
  final double firstVisitHours;
  final double routineHours;
  final double hourlyRate;

  const PricingWorkerDto({
    required this.positionName,
    this.visitFrequency,
    required this.firstVisitHours,
    required this.routineHours,
    required this.hourlyRate,
  });

  Map<String, dynamic> toJson() => {
    'position_name': positionName,
    'visit_frequency': visitFrequency,
    'first_visit_hours': firstVisitHours,
    'routine_hours': routineHours,
    'hourly_rate': hourlyRate,
  };
}

class PricingItemDto {
  final int itemType;
  final String? productId;
  final String name;
  final double qty;
  final int frequency;
  final double? unitPrice;

  const PricingItemDto({
    required this.itemType,
    this.productId,
    required this.name,
    required this.qty,
    required this.frequency,
    this.unitPrice,
  });

  Map<String, dynamic> toJson() => {
    'item_type': itemType,
    if (productId != null) 'product_id': productId,
    'name': name,
    'qty': qty,
    'frequency': frequency,
    if (unitPrice != null) 'unit_price': unitPrice,
  };
}
```

**Changes from current:**
- `CreatePricingRequestDto`: `taxPercent` → `taxPercentage`, JSON key `'tax_percent'` → `'tax_percentage'`
- `PricingWorkerDto`: added `int? visitFrequency` field + `'visit_frequency'` in `toJson()`
- `PricingItemDto`: `productId` changed from `String` (required) to `String?` (optional), conditionally included in JSON

---

### File 2: `lib/modules/sales/controllers/pricing_calculator_controller.dart`

**Diff 2a — Rename `taxPercent` → `taxPercentage`:**

```diff
-  static const double defaultTaxPercent = 0.0;
+  static const double defaultTaxPercentage = 0.0;

-  /// Tax (PPN) rate in percent, editable from the COGS card.
-  final taxPercent = signal<double>(defaultTaxPercent);
+  /// Tax (PPN) rate in percent, editable from the COGS card.
+  final taxPercentage = signal<double>(defaultTaxPercentage);
```

```diff
   late final ReadonlySignal<double> taxAmount = computed(
-    () => subtotal.value * (taxPercent.value / 100),
+    () => subtotal.value * (taxPercentage.value / 100),
   );
```

```diff
-    taxPercent.dispose();
+    taxPercentage.dispose();
```

**Diff 2b — Add `contractMonthsRef` to `PricingMaterialRow` and fix tool total:**

```diff
 class PricingMaterialRow {
   final String id;
   final String title;
   final String code;
   final String uomCode;
   final int kind;

   final double? doseMinLimit;
   final double? doseMaxLimit;
+  final ReadonlySignal<int?>? contractMonthsRef;

   final Signal<String> productMappingId;
   final Signal<double> doseUsage;
   final Signal<String> doseUnitId;
   final Signal<double> applicationVolume;
   final Signal<String> applicationVolumeUnitId;
   final Signal<double> freq;
   final Signal<double> unitCost;

-  late final ReadonlySignal<double> qty = computed(
-    () => doseUsage.value * applicationVolume.value,
-  );
+  late final ReadonlySignal<double> qty = computed(() {
+    if (kind == 2) return doseUsage.value; // tool: doseUsage holds qty
+    return doseUsage.value * applicationVolume.value;
+  });

-  late final ReadonlySignal<double> total = computed(
-    () =>
-        doseUsage.value * applicationVolume.value * freq.value * unitCost.value,
-  );
+  late final ReadonlySignal<double> total = computed(() {
+    if (kind == 2) {
+      // Tool: amortized over contract months
+      // line_total = (unit_cost × qty / contract_months) × frequency
+      final months = contractMonthsRef?.value ?? 12;
+      return (unitCost.value * doseUsage.value / months) * freq.value;
+    }
+    // Chemical: dose × volume × freq × unit_cost
+    return doseUsage.value * applicationVolume.value * freq.value * unitCost.value;
+  });

   PricingMaterialRow({
     required this.id,
     required this.title,
     required this.code,
     required this.uomCode,
     required this.kind,
     this.doseMinLimit,
     this.doseMaxLimit,
+    this.contractMonthsRef,
     String? initialProductMappingId,
```

**Diff 2c — Pass `contractMonthsRef` when adding rows:**

In `addMaterialRow`:
```diff
     materials.add(
       PricingMaterialRow(
         id: mapping.productId,
         title: mapping.productName,
         code: mapping.productCode ?? '',
         uomCode: mapping.doseUnitCode,
         kind: 1,
+        contractMonthsRef: contractMonths,
         initialProductMappingId: mapping.id,
```

In `addRow`, material section (kind == 1 || kind == 2):
```diff
       materials.add(
         PricingMaterialRow(
           id: product.id,
           title: product.name,
           code: product.code,
           uomCode: product.uomCode,
           kind: expectedKind,
+          contractMonthsRef: contractMonths,
           initialProductMappingId: expectedKind == 1 ? '' : product.id,
           initialUnitCost: product.cogs,
         ),
       );
```

**Diff 2d — Worker DTO includes visit_frequency + helper:**

Add helper method:
```dart
  int? _workerVisitFrequencyOverride(PricingWorkerRow w) {
    final headerFreq = visitFrequency.value ?? 12;
    final workerFreq = w.visitFreq.value.round();
    if (workerFreq == headerFreq || workerFreq <= 0) return null;
    return workerFreq;
  }
```

In `submitPricing`, update worker mapping:
```diff
     final workerDtos = workers
         .map(
           (l) => PricingWorkerDto(
             positionName: l.title,
+            visitFrequency: _workerVisitFrequencyOverride(l),
             firstVisitHours: l.firstVisitHours.value,
             routineHours: l.routineHours.value,
             hourlyRate: l.hourlyRate.value,
           ),
         )
         .toList();
```

**Diff 2e — DTO constructor uses `taxPercentage`:**

```diff
     final request = CreatePricingRequestDto(
       customerId: customerId,
       serviceId: serviceId,
       contractMonths: contractMonths.value ?? 12,
       visitFrequency: visitFrequency.value ?? 12,
       markupType: markupType.value,
       markupValue: markupPercent.value,
       discountAmount: discountAmount.value,
-      taxPercent: taxPercent.value,
+      taxPercentage: taxPercentage.value,
       materials: materialDtos,
       workers: workerDtos,
       items: itemDtos,
     );
```

---

### File 3: `lib/modules/sales/views/widgets/pricing_calculator/pricing_cogs_card.dart`

Rename references:
```diff
-                              initialValue: controller.taxPercent.value
+                              initialValue: controller.taxPercentage.value
                                   .toString(),
```

```diff
-                                controller.taxPercent.value =
+                                controller.taxPercentage.value =
                                     double.tryParse(val) ?? 0.0;
```

---

### File 4: `lib/modules/sales/views/widgets/pricing_calculator/pricing_margin_card.dart`

Wrap body in `SignalBuilder` and use dynamic divisors:

```diff
   @override
   Widget build(BuildContext context) {
-    final marginAmt = controller.marginAmount.value;
-    final subtotal = controller.subtotal.value;
-    final marginPct = subtotal > 0 ? (marginAmt / subtotal) * 100 : 0.0;
-
-    return Container(
+    return SignalBuilder(
+      builder: (context) {
+        final marginAmt = controller.marginAmount.value;
+        final subtotal = controller.subtotal.value;
+        final marginPct = subtotal > 0 ? (marginAmt / subtotal) * 100 : 0.0;
+        final vf = controller.visitFrequency.value ?? 1;
+        final cm = controller.contractMonths.value ?? 1;
+
+        return Container(
```

Replace hardcoded divisors:
```diff
-                formatRp(controller.grandTotal.value / 6),
+                formatRp(vf > 0 ? controller.grandTotal.value / vf : 0),
```

```diff
-                formatRp(controller.grandTotal.value / 12),
+                formatRp(cm > 0 ? controller.grandTotal.value / cm : 0),
```

Close the `SignalBuilder` at the end:
```diff
-    );
+        );
+      },
+    );
   }
```

---

### File 5: `lib/modules/sales/entities/customer.dart`

Add `taxPercentage` to `Customer`:

```diff
 class Customer {
   final String id;
   final String code;
   final String name;
   final String initials;
   final String segmentId;
   final String segment;
   final String status;
   final String npwp;
   final String phone;
   final String phoneAlt;
   final String email;
   final String scanCode;
+  final double taxPercentage;
   final String riskNotes;
   final String notes;
```

Constructor:
```diff
     this.scanCode = '',
+    this.taxPercentage = 0,
     this.riskNotes = '',
```

`copyWith`:
```diff
+    double? taxPercentage,
```
```diff
+      taxPercentage: taxPercentage ?? this.taxPercentage,
```

`==` and `hashCode` should include `taxPercentage` — add it to both.

---

### File 6: `lib/modules/sales/repositories/dtos/customer_dto.dart`

**6a — `CustomerDetailDto` parse `tax_percentage`:**

```diff
   final String scanCode;
+  final double taxPercentage;
   final String riskNotes;
```

In `fromJson`:
```diff
       scanCode: json['scan_code']?.toString() ?? '',
+      taxPercentage: (json['tax_percentage'] as num?)?.toDouble() ?? 0,
       riskNotes: json['risk_notes']?.toString() ?? '',
```

In `toEntity()`:
```diff
       scanCode: scanCode,
+      taxPercentage: taxPercentage,
       riskNotes: riskNotes,
```

**6b — `CreateCustomerRequestDto` send `tax_percentage`:**

```diff
 class CreateCustomerRequestDto {
   final String? code;
   final String name;
   final String segmentId;
   final String? npwpNumber;
   final String? email;
   final String? phone;
   final String? phoneAlt;
+  final double? taxPercentage;
   final String? riskNotes;
   final String? notes;
```

In `fromInput`:
```diff
+      taxPercentage: input.taxPercentage > 0 ? input.taxPercentage : null,
```

In `toJson`:
```diff
+    if (taxPercentage != null) map['tax_percentage'] = taxPercentage;
```

**6c — `UpdateCustomerRequestDto` send `tax_percentage`:**

Same pattern as Create — add `taxPercentage` field, populate from input, include in `toJson`.

**6d — Fix `updateCustomer` in repository to parse full detail response:**

```diff
-      final updatedDto = CreateCustomerResponseDto.fromJson(dataMap);
+      final updatedDto = CustomerDetailDto.fromJson(dataMap);
       return Ok(updatedDto.toEntity());
```

---

### File 7: `lib/modules/sales/entities/create_customer_input.dart`

Add `taxPercentage`:

```diff
 class CreateCustomerInput {
   final String name;
   final String code;
   final String status;
   final String segmentId;
   final String segment;
   final String npwp;
   final String phone;
   final String phoneAlt;
   final String email;
+  final double taxPercentage;
   final String riskNotes;
   final String notes;
```

Constructor:
```diff
+    this.taxPercentage = 0,
```

`copyWith`:
```diff
+    double? taxPercentage,
```
```diff
+      taxPercentage: taxPercentage ?? this.taxPercentage,
```

---

## Risks / Open Questions

1. **`tax_percentage` on Customer vs Pricing** — The customer has an informational `tax_percentage` (e.g. 11%). The pricing API requires `tax_percentage` in the request. The API doc says: _"has no automatic effect on Pricing calculations unless a caller explicitly copies it into a pricing request"_. So the UI should pre-fill the pricing's tax from the customer's `tax_percentage`, but they're independent after that. This plan only adds the field plumbing — the pre-fill UX can be a follow-up.

2. **Tool total amortization** — `line_total = (unit_cost × qty / contract_months) × frequency`. If `contractMonths` is `null` (user hasn't filled it), we default to 12. The server would reject `contract_months: 0` anyway.

3. **Worker `visitFreq` semantics** — The API wants `null` to use the header's frequency. The controller sends `null` if the worker's value matches the header. The local formula already uses the per-worker value for its own computation (unaffected).

4. **`PricingMarginCard` not reactive** — Currently reads `.value` outside `SignalBuilder`, so it only renders once. Fixed by wrapping in `SignalBuilder`.

5. **PUT customer response** — Currently parsed with `CreateCustomerResponseDto` (abbreviated fields only: id, code, name, initials, segment, status, createdAt). The API actually returns full detail. After this fix, the returned `Customer` entity from `updateCustomer` will have all fields populated — which may benefit the UI immediately refreshing the detail view without a separate GET.

## Out of Scope

- **Pre-filling pricing `taxPercentage` from the customer** — UX enhancement, not an API alignment issue.
- **Response parsing for pricing (GET detail)** — Current repo only does POST. Adding GET/PUT/DELETE is a separate feature.
- **Customer form UI for `taxPercentage`** — Adding a new text field in the customer form is a UI task; this plan only covers the data layer.
- **Duplicate-line validation** — Server-side; adding client-side is a UX enhancement.
