# Plan — Relayout the pricing param bar (Durasi Kontrak / Frekuensi Kunjungan)

Status: **PROPOSED — NOT APPLIED**. Revision 2.
Follows `.kiro/plans/pricing-custom-tax-remove-area.md` (applied), which removed the third param.

> **Revision note.** Revision 1 justified an inline label with a brand-coloured icon by citing
> `design/kalkulator.html`. That file is an **outdated design version** and is not a source of truth —
> it still shows Luas Area Properti, a hardcoded PPN 11%, client-typed chemical `qty`, client-supplied
> `unit_cost`, and a 300px right-hand summary sidebar, none of which match the current app or
> `centrow/docs/api/pricings.md`. This revision is grounded in the live Flutter code and the current
> API docs only. The recommendation changed as a result.

## Goal

With only `Durasi Kontrak` and `Frekuensi Kunjungan` left in the top bar, stop each field stretching across half the screen, and bring the two inputs in line with the app's shared field system.

## Research findings (live code)

1. **Why it looks wrong.** `_buildParamBar` (`pricing_page.dart:217`) puts two `Expanded` items in a `Row`, so each 2-digit numeric input is ~460px wide on a tablet.
2. **The app's field convention is label-above.** `app_text_field.dart:175-207`, `app_dropdown.dart:95-120` and `app_searchable_selector.dart:89` all render `Column(label, SizedBox(height: AppSpacing.labelGap), field)` with `AppTypography.bodySm(color: sec, fontWeight: w600)`. No icon inside the label. An inline label here would be the odd one out.
3. **The param bar hand-rolls its input and loses behaviour.** `_buildParamItem` builds its own 44px `Container` + borderless `TextFormField` with `AppRadius.borderSm` and **no focus state**. `AppTextField` gives `AppRadius.borderMd`, `fillColor: AppColors.subtle`, a brand focus border (`app_text_field.dart:150-170`), `prefixIcon`/`suffixIcon` slots, `inputFormatters`, and typography tokens.
4. **Precedent for a labeled numeric field** is `step2_locations_form.dart:222-233` (`_buildTextField` → `AppTextField`, `keyboardType: TextInputType.number`).
5. `AppTextField` exposes `suffixIcon` as a `Widget` (no `suffixText`), so the `Bulan` / `Visit` units become a `Text` widget in that slot.
6. **No test covers this page** — there is no `pricing_page` widget test, so no test updates are implied.
7. **A third param is still missing on API grounds, not design grounds.** `centrow/docs/api/regency_configs.md` (implemented server-side) defines a per-regency `surcharge_amount` intended for transport cost. Nothing in the Flutter calculator consumes it. See Out of scope.

## Options considered

**Option A — recommended: keep label-above, swap the bespoke input for `AppTextField`, size items and `Wrap` them.** Fixes the stretch, removes ~40 lines of hand-rolled input, and inherits focus states and tokens. Vertical footprint stays as-is (label above), consistent with every other form in the app.

**Option B — inline label (recommended in revision 1). Rejected.** It contradicts finding 2; the only support for it was the outdated HTML.

**Option C — minimal: `Expanded` → `SizedBox(width: 220)`.** 4-line diff, zero risk, but keeps the hand-rolled input and its missing focus state.

**Option D — fold both params into the page header.** Saves the whole row but crowds a header already holding 3 badges + 2 buttons, and would want the header's dead `onPressed: () {}` Simpan button removed first.

## Affected files

| # | File | Change |
|---|------|--------|
| 1 | `lib/modules/sales/views/pages/pricing_page.dart` | add 3 imports; `_buildParamBar`: `Row`+`Expanded` → `Wrap`; `_buildParamItem`: hand-rolled box → `AppTextField` in a fixed-width `SizedBox` |

No controller, DTO, DI, router or test changes.

## Steps

1. Add imports: `flutter/services.dart` (for `FilteringTextInputFormatter`), `shared/widgets/app_text_field.dart`, `shared/theme/app_typography.dart`.
2. `_buildParamBar`: `Wrap(spacing: 16, runSpacing: 12)` holding the two `_buildParamItem` calls directly (no `Expanded`, no manual `SizedBox` separator).
3. `_buildParamItem`: return `SizedBox(width: 260, child: AppTextField(...))`; drop the `keyboardType` parameter (always numeric here) and make `suffix` required.
4. Verify: `flutter analyze` clean; visually confirm two items on one row at tablet width and a clean wrap below ~560px; confirm the focus ring now appears on tap.

## Proposed changes (not yet applied)

### 1a. Imports

```diff
 import 'package:flutter/material.dart';
+import 'package:flutter/services.dart';
 import 'package:go_router/go_router.dart';
 import 'package:google_fonts/google_fonts.dart';
 import 'package:signals_flutter/signals_flutter.dart';
 import 'package:centrow_sales/app/di.dart';
@@
 import 'package:centrow_sales/shared/theme/app_colors.dart';
 import 'package:centrow_sales/shared/theme/app_radius.dart';
+import 'package:centrow_sales/shared/theme/app_typography.dart';
 import 'package:centrow_sales/shared/widgets/app_button.dart';
+import 'package:centrow_sales/shared/widgets/app_text_field.dart';
 import 'package:centrow_sales/shared/widgets/error_view.dart';
```

`AppRadius` stays — still used by `_buildBadge`.

### 1b. `_buildParamBar`

`Row`+`Expanded` → `Wrap`, so items keep their natural width and wrap instead of stretching.

```diff
   Widget _buildParamBar(BuildContext context) {
     return Container(
       color: AppColors.surface,
       padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
-      child: Row(
+      child: Wrap(
+        spacing: 16.0,
+        runSpacing: 12.0,
         children: [
-          Expanded(
-            child: _buildParamItem(
-              'Durasi Kontrak',
-              _calcController.contractMonths.value?.toString(),
-              icon: Icons.calendar_today,
-              suffix: 'Bulan',
-              keyboardType: TextInputType.number,
-              onChanged: (val) =>
-                  _calcController.contractMonths.value = int.tryParse(val),
-            ),
+          _buildParamItem(
+            'Durasi Kontrak',
+            _calcController.contractMonths.value?.toString(),
+            icon: Icons.calendar_today,
+            suffix: 'Bulan',
+            onChanged: (val) =>
+                _calcController.contractMonths.value = int.tryParse(val),
           ),
-          const SizedBox(width: 12.0),
-          Expanded(
-            child: _buildParamItem(
-              'Frekuensi Kunjungan',
-              _calcController.visitFrequency.value?.toString(),
-              icon: Icons.repeat,
-              suffix: 'Visit',
-              keyboardType: TextInputType.number,
-              onChanged: (val) =>
-                  _calcController.visitFrequency.value = int.tryParse(val),
-            ),
+          _buildParamItem(
+            'Frekuensi Kunjungan',
+            _calcController.visitFrequency.value?.toString(),
+            icon: Icons.repeat,
+            suffix: 'Visit',
+            onChanged: (val) =>
+                _calcController.visitFrequency.value = int.tryParse(val),
           ),
         ],
       ),
     );
   }
```

### 1c. `_buildParamItem`

Hand-rolled box → shared `AppTextField`. Keeps label-above per finding 2; gains focus state, tokens, and digit filtering.

```diff
   Widget _buildParamItem(
     String label,
     String? initialValue, {
     required IconData icon,
-    String? suffix,
-    TextInputType keyboardType = TextInputType.text,
+    required String suffix,
     ValueChanged<String>? onChanged,
   }) {
-    return Column(
-      crossAxisAlignment: CrossAxisAlignment.start,
-      children: [
-        Text(
-          label,
-          style: const TextStyle(
-            fontSize: 12.0,
-            fontWeight: FontWeight.w600,
-            color: AppColors.sec,
-          ),
-        ),
-        const SizedBox(height: 6.0),
-        Container(
-          height: 44.0,
-          padding: const EdgeInsets.symmetric(horizontal: 12.0),
-          decoration: BoxDecoration(
-            color: AppColors.subtle,
-            border: Border.all(color: AppColors.border, width: 1.5),
-            borderRadius: AppRadius.borderSm,
-          ),
-          child: Row(
-            children: [
-              Icon(icon, size: 16.0, color: AppColors.muted),
-              const SizedBox(width: 8.0),
-              Expanded(
-                child: TextFormField(
-                  initialValue: initialValue,
-                  keyboardType: keyboardType,
-                  onChanged: onChanged,
-                  style: const TextStyle(
-                    fontSize: 13.0,
-                    fontWeight: FontWeight.w600,
-                    color: AppColors.text,
-                  ),
-                  decoration: InputDecoration(
-                    border: InputBorder.none,
-                    enabledBorder: InputBorder.none,
-                    focusedBorder: InputBorder.none,
-                    errorBorder: InputBorder.none,
-                    disabledBorder: InputBorder.none,
-                    filled: false,
-                    contentPadding: EdgeInsets.zero,
-                    isDense: true,
-                    suffixText: suffix,
-                    suffixStyle: const TextStyle(
-                      fontSize: 13.0,
-                      fontWeight: FontWeight.w600,
-                      color: AppColors.sec,
-                    ),
-                  ),
-                ),
-              ),
-            ],
-          ),
-        ),
-      ],
+    return SizedBox(
+      width: 260.0,
+      child: AppTextField(
+        label: label,
+        initialValue: initialValue,
+        keyboardType: TextInputType.number,
+        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
+        prefixIcon: Icon(icon, size: 16.0, color: AppColors.muted),
+        suffixIcon: Text(
+          suffix,
+          style: AppTypography.bodySm(
+            color: AppColors.sec,
+            fontWeight: FontWeight.w600,
+          ),
+        ),
+        onChanged: onChanged,
+      ),
     );
   }
```

Geometry: two 260px items, 16px apart = 536px — fits any tablet width; wraps to two rows below ~560px instead of overflowing.

### Option C fallback — if you'd rather change almost nothing

Applied to both items; `_buildParamItem` untouched.

```diff
-          Expanded(
-            child: _buildParamItem(
+          SizedBox(
+            width: 220.0,
+            child: _buildParamItem(
```

## Risks / open questions

1. **Visual delta from adopting `AppTextField`:** radius goes `borderSm` → `borderMd`, height 44 → ~48 (contentPadding 12 + text), and a brand focus ring appears. That is the point — it matches every other field in the app — but it is a visible change, not pixel-identical to today.
2. **`digitsOnly` is new behaviour.** Both params are integers (`int.tryParse`), so this only blocks input that was already discarded. Say the word if you'd rather not filter.
3. Both fields still start empty and silently fall back to `12` / `12` at submit (`contractMonths.value ?? 12`). A relayout does not fix that; the fix would be real defaults, possibly via the existing `CounterInput` stepper (`pricing_material_tab.dart:191,220,383`).
4. `AppTextField` is a `StatefulWidget` using `initialValue`, so it will not re-seed from the signal on rebuild — same limitation as the current code, no regression.

## Out of scope

- **Regency surcharge param** (`centrow/docs/api/regency_configs.md`: per-regency `surcharge_amount` for transport). Adding it needs a repository, controller state and a change to the COGS chain. It is the one thing that would legitimately re-fill this bar, so if you want it, this relayout should be designed for three fields instead of two — otherwise the bar gets laid out twice.
- The header's mock `AppButton` with `onPressed: () {}` (duplicates the working bottom-bar Simpan).
- Migrating this file's remaining raw `16.0`/`12.0` literals to `AppSpacing` tokens.
- `pricing_margin_card.dart` dividing `grandTotal` by hardcoded `6` / `12` instead of `visitFrequency` / `contractMonths`.
- **`design/*.html` is stale relative to the app** (old params, hardcoded tax, different summary layout). Refreshing or retiring those files is its own task; they should not be used as a spec in the meantime.
