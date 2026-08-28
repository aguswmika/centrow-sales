# Plan — Pricing calculator: customizable tax rate, remove area size

Status: **PROPOSED — NOT APPLIED**. Every code block below is a preview.

## Goal

In the pricing calculator, make the tax (PPN) rate user-editable instead of hardcoded 11%, and remove the "Luas Area Properti" (area size) input and its request fields.

## Research findings

Read: `lib/modules/sales/controllers/pricing_calculator_controller.dart`, `lib/modules/sales/repositories/dtos/pricing_dto.dart`, `lib/modules/sales/repositories/pricing_repository.dart`, `lib/modules/sales/views/pages/pricing_page.dart`, `lib/modules/sales/views/widgets/pricing_calculator/{pricing_cogs_card,pricing_margin_card,pricing_bottom_bar,pricing_utils}.dart`, the three pricing test files, plus `centrow/docs/api/pricings.md` and `centrow/docs/api/regency_configs.md` and the backend types (`internal/sales/handler/api/pricing_types.go`, `internal/sales/usecase/pricing/pricing.go`).

Confirmed:

1. **Tax is hardcoded client-side** — `pricing_calculator_controller.dart:233-235`: `taxAmount = subtotal * 0.11`.
2. **Area is sent but is not a documented request field** — the app sends `area_value` / `area_unit_id` (`pricing_dto.dart:33-34`). `docs/api/pricings.md` lists no area fields in the request body; `upsertPricingRequest` in the backend has no area fields either. `area_size` / `area_unit_id` appear only in the **response**, derived from the customer's primary address. So the current client payload fields are dead weight and silently dropped.
3. **The backend still computes tax at a fixed rate** — `internal/sales/usecase/pricing/pricing.go:21` `const ppnRate = 0.11`, and `upsertPricingRequest` has no tax field. See Risk 1.
4. **The COGS card is largely non-reactive today** — `PricingCogsCard` reads `controller.cogsMaterial.value` etc. directly inside `build()` of a `StatelessWidget`, outside any `SignalBuilder`, so those rows do not rebuild on change. Only the markup dropdown/suffix are wrapped. Pre-existing; see Step 4b.
5. `regency_configs.md` describes a per-regency flat surcharge applied to transport cost and a proposal-numbering code. Nothing in the calculator consumes it today — out of scope here (listed below).

## Approach

Keep the single source of truth in the controller: replace the hardcoded `0.11` with a `taxPercent` signal defaulting to `11.0` (exposed as `PricingCalculatorController.defaultTaxPercent`), and derive `taxAmount` from it. The COGS card gets a small percent input on the PPN row, following the exact pattern already used by the "Diskon Khusus" row, and that one row is wrapped in `SignalBuilder` so the amount updates live.

Area removal is a straight deletion across controller signals, the request DTO, and the param bar in `pricing_page.dart`. Because removing the area item makes the narrow and wide branches of `_buildParamBar` identical, the `LayoutBuilder` there collapses to a plain `Row`.

Alternative considered for tax: leave tax display-only at 11% and wait for backend support. Rejected — the request is explicitly to make it editable, and the client-side breakdown is what the salesperson shows the customer on the tablet. The persistence gap is flagged as Risk 1 rather than blocking the UI change.

## Affected files

| # | File | Change |
|---|------|--------|
| 1 | `lib/modules/sales/repositories/dtos/pricing_dto.dart` | remove `areaValue`/`areaUnitId` fields + JSON keys; add required `taxPercent` + `tax_percent` key |
| 2 | `lib/modules/sales/controllers/pricing_calculator_controller.dart` | remove area signals + dispose; add `defaultTaxPercent` const and `taxPercent` signal; `taxAmount` derives from it; update request build + dispose |
| 3 | `lib/modules/sales/views/pages/pricing_page.dart` | remove "Luas Area Properti" param item; collapse `_buildParamBar` `LayoutBuilder` to a `Row` |
| 4 | `lib/modules/sales/views/widgets/pricing_calculator/pricing_cogs_card.dart` | replace static PPN sum row with editable-rate row (4a); optional card-wide `SignalBuilder` (4b) |
| 5 | `test/modules/sales/repositories/dtos/pricing_dto_test.dart` | drop area assertions, assert `tax_percent` present and area keys absent |
| 6 | `test/modules/sales/repositories/pricing_repository_test.dart` | add `taxPercent` to the const DTO (required-field compile fix) |
| 7 | `test/modules/sales/controllers/pricing_calculator_controller_test.dart` | drop area set/assert; add default/custom/zero tax-rate assertions |

## Steps

1. `pricing_dto.dart` — remove area fields, add `taxPercent`.
2. `pricing_calculator_controller.dart` — add `defaultTaxPercent` + `taxPercent`, rewire `taxAmount`, remove area signals, update request + `dispose()`.
3. `pricing_page.dart` — remove the area param item and collapse `_buildParamBar`.
4. `pricing_cogs_card.dart` — 4a: editable PPN row. 4b (**needs approval**, optional): wrap the card body in one `SignalBuilder` to fix the pre-existing staleness of the COGS/subtotal rows.
5. Update the three test files (5–7 above).
6. Verify: `flutter analyze` (expect clean) and `flutter test test/modules/sales/controllers/pricing_calculator_controller_test.dart test/modules/sales/repositories/dtos/pricing_dto_test.dart test/modules/sales/repositories/pricing_repository_test.dart`.

## Proposed changes (not yet applied)

### 1. `lib/modules/sales/repositories/dtos/pricing_dto.dart`

Drops the two undocumented area request fields; adds the tax rate to the payload.

```diff
 class CreatePricingRequestDto {
   final String customerId;
   final String serviceId;
-  final double? areaValue;
-  final String? areaUnitId;
   final int contractMonths;
   final int visitFrequency;
   final int markupType;
   final double markupValue;
   final double discountAmount;
+  final double taxPercent;
   final List<PricingMaterialDto> materials;
   final List<PricingWorkerDto> workers;
   final List<PricingItemDto> items;
 
   const CreatePricingRequestDto({
     required this.customerId,
     required this.serviceId,
-    this.areaValue,
-    this.areaUnitId,
     required this.contractMonths,
     required this.visitFrequency,
     required this.markupType,
     required this.markupValue,
     required this.discountAmount,
+    required this.taxPercent,
     required this.materials,
     required this.workers,
     required this.items,
   });
 
   Map<String, dynamic> toJson() => {
     'customer_id': customerId,
     'service_id': serviceId,
-    if (areaValue != null) 'area_value': areaValue,
-    if (areaUnitId != null) 'area_unit_id': areaUnitId,
     'contract_months': contractMonths,
     'visit_frequency': visitFrequency,
     'markup_type': markupType,
     'markup_value': markupValue,
     'discount_amount': discountAmount,
+    'tax_percent': taxPercent,
     'supplies': materials.map((e) => e.toJson()).toList(),
     'workers': workers.map((e) => e.toJson()).toList(),
     'items': items.map((e) => e.toJson()).toList(),
   };
 }
```

### 2. `lib/modules/sales/controllers/pricing_calculator_controller.dart`

Single source of truth for the rate; `taxAmount` becomes a function of it.

```diff
-  final areaValue = signal<double?>(null);
-  final areaUnitId = signal<String?>(null);
   final contractMonths = signal<int?>(null);
   final visitFrequency = signal<int?>(null);
 
   final markupPercent = signal<double>(0.0);
   final markupType = signal<int>(1); // 1=percent, 2=nominal, 3=target price
   final discountAmount = signal<double>(0.0);
 
+  /// Default PPN rate in percent, used until the user overrides it.
+  static const double defaultTaxPercent = 11.0;
+
+  /// Tax (PPN) rate in percent, editable from the COGS card.
+  final taxPercent = signal<double>(defaultTaxPercent);
+
   final submitState = signal<UiState<void>>(const UiInitial());
```

```diff
   late final ReadonlySignal<double> taxAmount = computed(
-    () => subtotal.value * 0.11,
+    () => subtotal.value * (taxPercent.value / 100),
   );
```

```diff
     final request = CreatePricingRequestDto(
       customerId: customerId,
       serviceId: serviceId,
-      areaValue: areaValue.value,
-      areaUnitId: areaUnitId.value,
       contractMonths: contractMonths.value ?? 12,
       visitFrequency: visitFrequency.value ?? 12,
       markupType: markupType.value,
       markupValue: markupPercent.value,
       discountAmount: discountAmount.value,
+      taxPercent: taxPercent.value,
       materials: materialDtos,
       workers: workerDtos,
       items: itemDtos,
     );
```

```diff
-    areaValue.dispose();
-    areaUnitId.dispose();
     contractMonths.dispose();
     visitFrequency.dispose();
     markupPercent.dispose();
     markupType.dispose();
     discountAmount.dispose();
+    taxPercent.dispose();
     submitState.dispose();
```

### 3. `lib/modules/sales/views/pages/pricing_page.dart`

Removes the area input. With only two params left, both layout branches were identical, so the `LayoutBuilder` goes away.

```diff
   Widget _buildParamBar(BuildContext context) {
     return Container(
       color: AppColors.surface,
       padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
-      child: LayoutBuilder(
-        builder: (context, constraints) {
-          final isNarrow = constraints.maxWidth < 800;
-
-          if (isNarrow) {
-            return Column(
-              children: [
-                Row(
-                  children: [
-                    Expanded(
-                      child: _buildParamItem(
-                        'Luas Area Properti',
-                        _calcController.areaValue.value?.toString(),
-                        icon: Icons.square_foot,
-                        suffix: 'm²',
-                        keyboardType: TextInputType.number,
-                        onChanged: (val) => _calcController.areaValue.value =
-                            double.tryParse(val),
-                      ),
-                    ),
-                    const SizedBox(width: 12.0),
-                    Expanded(
-                      child: _buildParamItem(
-                        'Durasi Kontrak',
-                        _calcController.contractMonths.value?.toString(),
-                        icon: Icons.calendar_today,
-                        suffix: 'Bulan',
-                        keyboardType: TextInputType.number,
-                        onChanged: (val) =>
-                            _calcController.contractMonths.value = int.tryParse(
-                              val,
-                            ),
-                      ),
-                    ),
-                  ],
-                ),
-                const SizedBox(height: 12.0),
-                _buildParamItem(
-                  'Frekuensi Kunjungan',
-                  _calcController.visitFrequency.value?.toString(),
-                  icon: Icons.repeat,
-                  suffix: 'Visit',
-                  keyboardType: TextInputType.number,
-                  onChanged: (val) =>
-                      _calcController.visitFrequency.value = int.tryParse(val),
-                ),
-              ],
-            );
-          }
-
-          return Row(
-            children: [
-              Expanded(
-                child: _buildParamItem(
-                  'Luas Area Properti',
-                  _calcController.areaValue.value?.toString(),
-                  icon: Icons.square_foot,
-                  suffix: 'm²',
-                  keyboardType: TextInputType.number,
-                  onChanged: (val) =>
-                      _calcController.areaValue.value = double.tryParse(val),
-                ),
-              ),
-              const SizedBox(width: 12.0),
-              Expanded(
-                child: _buildParamItem(
-                  'Durasi Kontrak',
-                  _calcController.contractMonths.value?.toString(),
-                  icon: Icons.calendar_today,
-                  suffix: 'Bulan',
-                  keyboardType: TextInputType.number,
-                  onChanged: (val) =>
-                      _calcController.contractMonths.value = int.tryParse(val),
-                ),
-              ),
-              const SizedBox(width: 12.0),
-              Expanded(
-                child: _buildParamItem(
-                  'Frekuensi Kunjungan',
-                  _calcController.visitFrequency.value?.toString(),
-                  icon: Icons.repeat,
-                  suffix: 'Visit',
-                  keyboardType: TextInputType.number,
-                  onChanged: (val) =>
-                      _calcController.visitFrequency.value = int.tryParse(val),
-                ),
-              ),
-            ],
-          );
-        },
-      ),
+      child: Row(
+        children: [
+          Expanded(
+            child: _buildParamItem(
+              'Durasi Kontrak',
+              _calcController.contractMonths.value?.toString(),
+              icon: Icons.calendar_today,
+              suffix: 'Bulan',
+              keyboardType: TextInputType.number,
+              onChanged: (val) =>
+                  _calcController.contractMonths.value = int.tryParse(val),
+            ),
+          ),
+          const SizedBox(width: 12.0),
+          Expanded(
+            child: _buildParamItem(
+              'Frekuensi Kunjungan',
+              _calcController.visitFrequency.value?.toString(),
+              icon: Icons.repeat,
+              suffix: 'Visit',
+              keyboardType: TextInputType.number,
+              onChanged: (val) =>
+                  _calcController.visitFrequency.value = int.tryParse(val),
+            ),
+          ),
+        ],
+      ),
     );
   }
```

### 4a. `lib/modules/sales/views/widgets/pricing_calculator/pricing_cogs_card.dart`

Editable PPN rate. Styling mirrors the existing "Diskon Khusus" input; the row is wrapped in `SignalBuilder` so the amount tracks both the rate and the subtotal.

```diff
           buildSumRow(
             'Subtotal (DPP)',
             formatRp(controller.subtotal.value),
             semiBold: true,
           ),
-          buildSumRow('PPN', formatRp(controller.taxAmount.value)),
+
+          // PPN row — rate is user-editable, amount reacts to it.
+          SignalBuilder(
+            builder: (context) {
+              return Padding(
+                padding: const EdgeInsets.symmetric(vertical: 4.0),
+                child: Row(
+                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
+                  children: [
+                    Row(
+                      mainAxisSize: MainAxisSize.min,
+                      children: [
+                        const Text(
+                          'PPN',
+                          style: TextStyle(
+                            fontSize: 12.0,
+                            fontWeight: FontWeight.w500,
+                            color: AppColors.sec,
+                          ),
+                        ),
+                        const SizedBox(width: 10.0),
+                        SizedBox(
+                          width: 78.0,
+                          height: 34.0,
+                          child: TextFormField(
+                            initialValue: controller.taxPercent.value
+                                .toString(),
+                            textAlign: TextAlign.right,
+                            keyboardType: TextInputType.number,
+                            onChanged: (val) {
+                              controller.taxPercent.value =
+                                  double.tryParse(val) ?? 0.0;
+                            },
+                            style: const TextStyle(
+                              fontSize: 12.0,
+                              fontWeight: FontWeight.w600,
+                              color: AppColors.text,
+                            ),
+                            decoration: const InputDecoration(
+                              filled: true,
+                              fillColor: AppColors.subtle,
+                              contentPadding: EdgeInsets.symmetric(
+                                horizontal: 8.0,
+                              ),
+                              suffixText: '%',
+                              suffixStyle: TextStyle(
+                                fontSize: 11.0,
+                                fontWeight: FontWeight.w700,
+                                color: AppColors.muted,
+                              ),
+                              border: OutlineInputBorder(
+                                borderRadius: AppRadius.borderSm,
+                                borderSide: BorderSide(
+                                  color: AppColors.border,
+                                  width: 1.5,
+                                ),
+                              ),
+                              enabledBorder: OutlineInputBorder(
+                                borderRadius: AppRadius.borderSm,
+                                borderSide: BorderSide(
+                                  color: AppColors.border,
+                                  width: 1.5,
+                                ),
+                              ),
+                            ),
+                          ),
+                        ),
+                      ],
+                    ),
+                    Text(
+                      formatRp(controller.taxAmount.value),
+                      style: const TextStyle(
+                        fontSize: 12.0,
+                        fontWeight: FontWeight.w600,
+                        color: AppColors.text,
+                      ),
+                    ),
+                  ],
+                ),
+              );
+            },
+          ),
         ],
       ),
     );
```

### 4b. `pricing_cogs_card.dart` — optional, **needs approval**

Pre-existing issue (finding 4): the COGS/subtotal rows read signals outside any `SignalBuilder`, so they only refresh when the parent happens to rebuild. Without this, editing the PPN rate updates the PPN amount but "Subtotal (DPP)" above it can still show a stale figure. One wrapper fixes all rows; widget state (text fields) is preserved because element identity does not change.

```diff
   @override
   Widget build(BuildContext context) {
-    return Container(
+    return SignalBuilder(
+      builder: (context) => Container(
       padding: const EdgeInsets.all(14.0),
       ...
-    );
+      ),
+    );
   }
```

(Applied as a real edit this becomes a re-indent of the existing `Container(...)` subtree — mechanical, no logic change. Skip this step and 4a still works on its own.)

### 5. `test/modules/sales/repositories/dtos/pricing_dto_test.dart`

```diff
         const request = CreatePricingRequestDto(
           customerId: 'c1',
           serviceId: 's1',
-          areaValue: 500.0,
-          areaUnitId: 'uom-m2',
           contractMonths: 12,
           visitFrequency: 24,
           markupType: 1,
           markupValue: 20.0,
           discountAmount: 10000.0,
+          taxPercent: 11.0,
           materials: [material, tool],
           workers: [worker],
           items: [item],
         );
 
         final json = request.toJson();
 
         expect(json['customer_id'], 'c1');
         expect(json['service_id'], 's1');
-        expect(json['area_value'], 500.0);
-        expect(json['area_unit_id'], 'uom-m2');
         expect(json['contract_months'], 12);
         expect(json['visit_frequency'], 24);
         expect(json['markup_type'], 1);
         expect(json['markup_value'], 20.0);
         expect(json['discount_amount'], 10000.0);
+        expect(json['tax_percent'], 11.0);
+        expect(json.containsKey('area_value'), isFalse);
+        expect(json.containsKey('area_unit_id'), isFalse);
```

### 6. `test/modules/sales/repositories/pricing_repository_test.dart`

Compile fix for the new required field.

```diff
     markupType: 1,
     markupValue: 25.0,
     discountAmount: 0.0,
+    taxPercent: 11.0,
     materials: [
```

### 7. `test/modules/sales/controllers/pricing_calculator_controller_test.dart`

Computed-chain test — append rate cases after the existing margin assertion:

```diff
       // marginAmount = subtotal - cogsTotal = 330000 - 250000 = 80000
       expect(controller.marginAmount.value, 80000.0);
+
+      // Tax rate defaults to 11% and is customizable
+      expect(
+        controller.taxPercent.value,
+        PricingCalculatorController.defaultTaxPercent,
+      );
+
+      // 5% → 330000 * 0.05 = 16500
+      controller.taxPercent.value = 5.0;
+      expect(controller.taxAmount.value, 16500.0);
+      expect(controller.grandTotal.value, 346500.0);
+
+      // 0% → no tax, grandTotal equals subtotal
+      controller.taxPercent.value = 0.0;
+      expect(controller.taxAmount.value, 0.0);
+      expect(controller.grandTotal.value, 330000.0);
     });
```

Submit test — area out, tax in:

```diff
-      controller.areaValue.value = 500.0;
-      controller.areaUnitId.value = 'uom-m2';
       controller.contractMonths.value = 6;
       controller.visitFrequency.value = 4;
       controller.markupPercent.value = 15.0;
+      controller.taxPercent.value = 5.0;
```

```diff
       expect(repository.lastRequest!.serviceId, 'srv-1');
-      expect(repository.lastRequest!.areaValue, 500.0);
-      expect(repository.lastRequest!.areaUnitId, 'uom-m2');
       expect(repository.lastRequest!.contractMonths, 6);
       expect(repository.lastRequest!.visitFrequency, 4);
       expect(repository.lastRequest!.markupType, 1);
       expect(repository.lastRequest!.markupValue, 15.0);
+      expect(repository.lastRequest!.taxPercent, 5.0);
```

## Risks / open questions

1. **The backend ignores `tax_percent` today** (`ppnRate = 0.11` in `internal/sales/usecase/pricing/pricing.go:21`; no tax field in `upsertPricingRequest`). Consequence: a salesperson can set 5%, see the calculator total at 5%, save it, and the stored `tax_amount` / `total_amount` will come back at 11%. Options:
   - **(a) recommended** — ship the client change now, send `tax_percent` for forward compatibility, and open a follow-up in `centrow` to add `tax_percent` to the request/entity/migration + docs.
   - (b) omit `tax_percent` from the payload until the backend accepts it (editable rate stays purely a quoting aid).
   - (c) hold this change until the backend lands first.
   Please pick — the diffs above implement (a).

2. **Rate input validation is intentionally thin** — `double.tryParse(val) ?? 0.0`, same as the existing markup/discount inputs. A negative rate would produce a negative tax. Want a clamp to `0..100`, or keep parity with the existing fields?

3. **Nothing reads area from the pricing response.** Removal only touches the request path, so no display regresses; the customer's `area_size` still exists on customer/location entities and screens.

4. Step 4b touches rows outside the tax feature (only re-indentation + one wrapper). If you'd rather keep the diff surgical, decline it and the calculator keeps its current refresh behaviour.

## Out of scope

- Backend changes in `/Users/agus/Project/centrow` (tax rate field, migration, docs) — separate repo, listed as Risk 1 follow-up.
- `proposal_detail_pane.dart:707,778` — hardcodes the labels `"Sudah termasuk PPN 11%"` / `"PPN 11%"` while the amount comes from the API. Will need the same treatment once the backend returns a rate.
- `pricing_margin_card.dart:118,137` — "Harga per Kunjungan / Bulan" divide `grandTotal` by hardcoded `6` and `12` instead of `visitFrequency` / `contractMonths`. Separate bug.
- Regency surcharge from `regency_configs.md` — not wired into the calculator at all today.
- `PricingItemRow`/`kind` magic numbers (1/2/3/4/5) and the pre-existing non-reactive rows beyond Step 4b.
