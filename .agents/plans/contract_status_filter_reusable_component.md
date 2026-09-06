# Implementation Plan: Contract Status Filter Reusable Component Based on Proposal Page

## Goal
Standardize the master list status filter bar between Proposal Page and Contract Page by making it a reusable component based on `AppSegmentedControl` from `proposal_master_list.dart`, adding scrollable support for multiple/longer statuses, and wiring it up to reactive filtering in `ContractController`.

## Approach
1. **Enhance `AppSegmentedControl<T>` (`lib/shared/widgets/app_segmented_control.dart`)**:
   - Add optional `isScrollable: bool = false` (and optional `padding: EdgeInsetsGeometry`).
   - When `isScrollable: false` (default): keep existing proportional layout with smooth sliding pill indicator (used by Proposal and Customer pages).
   - When `isScrollable: true`: render inside a `SingleChildScrollView(scrollDirection: Axis.horizontal)` with animated pill styling on the active segment, preventing label truncation when displaying 6 or more items with long words (e.g., "Ditangguhkan", "Diterminasi", "Dibatalkan").
   - Maintain identical styling across modes: `AppColors.subtle` background, `AppColors.border` with 1.5px stroke, `AppRadius.borderMd`, `AppColors.surface` pill with subtle shadow, `AppColors.brand` active text color, and `AppColors.sec` inactive text color.

2. **Update `ContractMasterList` (`lib/modules/sales/views/widgets/contract_master_list.dart`)**:
   - Replace the `FilterChip` implementation in `_buildStatusFilters()` with `AppSegmentedControl<int?>` configured with `isScrollable: true`.
   - Use `SegmentItem<int?>` definitions matching the 6 statuses:
     - `null` -> 'Semua'
     - `1` -> 'Draf'
     - `2` -> 'Aktif'
     - `3` -> 'Ditangguhkan'
     - `5` -> 'Diterminasi'
     - `6` -> 'Dibatalkan'

3. **Update `ContractController` & `ContractPage` (`lib/modules/sales/controllers/contract_controller.dart` & `contract_page.dart`)**:
   - Add a `filteredContracts` computed signal in `ContractController` (mirroring `ProposalController.filteredProposals` and `CustomerController.filteredCustomers`) that filters by search query and `_selectedStatus`.
   - Update `ContractPage` to consume `_controller.filteredContracts.value`, enabling instant reactive filtering when users click status segments or type search terms.

4. **Testing**:
   - Add widget tests for `AppSegmentedControl` covering both fixed and scrollable modes.
   - Add widget tests for `ContractMasterList` verifying status filtering and selection behavior.
   - Add unit tests for `ContractController` verifying `filteredContracts` behavior across statuses.

---

## Affected Files
1. `lib/shared/widgets/app_segmented_control.dart` (enhance with `isScrollable` option)
2. `lib/modules/sales/views/widgets/contract_master_list.dart` (switch from `FilterChip` to `AppSegmentedControl<int?>`)
3. `lib/modules/sales/controllers/contract_controller.dart` (add reactive `filteredContracts` computed signal)
4. `lib/modules/sales/views/pages/contract_page.dart` (use `filteredContracts` signal)
5. `test/shared/widgets/app_segmented_control_test.dart` (new widget test)
6. `test/modules/sales/views/widgets/contract_master_list_test.dart` (new widget test)
7. `test/modules/sales/controllers/contract_controller_test.dart` (new unit test for filtering)

---

## Proposed Changes (Not Yet Applied)

### 1. `lib/shared/widgets/app_segmented_control.dart`
Enhance `AppSegmentedControl<T>` to support `isScrollable`:

```diff
--- a/lib/shared/widgets/app_segmented_control.dart
+++ b/lib/shared/widgets/app_segmented_control.dart
@@ -17,12 +17,14 @@ class AppSegmentedControl<T> extends StatelessWidget {
   final double height;
   final Duration animationDuration;
   final Curve animationCurve;
+  final bool isScrollable;

   const AppSegmentedControl({
     super.key,
     required this.items,
     required this.selectedValue,
     required this.onValueChanged,
+    this.isScrollable = false,
     this.height = 36.0,
     this.animationDuration = const Duration(milliseconds: 220),
     this.animationCurve = Curves.easeInOutCubic,
@@ -34,6 +36,10 @@ class AppSegmentedControl<T> extends StatelessWidget {
     );
     final validIndex = selectedIndex >= 0 ? selectedIndex : 0;

+    if (isScrollable) {
+      return _buildScrollable(context);
+    }
+
     return Container(
       height: height,
       padding: const EdgeInsets.all(3.0),
@@ -109,4 +115,62 @@ class AppSegmentedControl<T> extends StatelessWidget {
         },
       ),
     );
   }
+
+  Widget _buildScrollable(BuildContext context) {
+    return Container(
+      height: height,
+      padding: const EdgeInsets.all(3.0),
+      decoration: BoxDecoration(
+        color: AppColors.subtle,
+        borderRadius: AppRadius.borderMd,
+        border: Border.all(color: AppColors.border, width: 1.5),
+      ),
+      child: SingleChildScrollView(
+        scrollDirection: Axis.horizontal,
+        child: Row(
+          mainAxisSize: MainAxisSize.min,
+          children: items.map((item) {
+            final isSelected = item.value == selectedValue;
+            return Padding(
+              padding: const EdgeInsets.symmetric(horizontal: 2.0),
+              child: Material(
+                color: Colors.transparent,
+                child: InkWell(
+                  onTap: () => onValueChanged(item.value),
+                  borderRadius: AppRadius.borderSm,
+                  child: AnimatedContainer(
+                    duration: animationDuration,
+                    curve: animationCurve,
+                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
+                    alignment: Alignment.center,
+                    decoration: BoxDecoration(
+                      color: isSelected ? AppColors.surface : Colors.transparent,
+                      borderRadius: AppRadius.borderSm,
+                      boxShadow: isSelected
+                          ? const [
+                              BoxShadow(
+                                color: Color(0x14000000),
+                                offset: Offset(0, 1.5),
+                                blurRadius: 4.0,
+                              ),
+                            ]
+                          : null,
+                    ),
+                    child: Text(
+                      item.label,
+                      style: GoogleFonts.inter(
+                        fontSize: 12.0,
+                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
+                        color: isSelected ? AppColors.brand : AppColors.sec,
+                      ),
+                    ),
+                  ),
+                ),
+              ),
+            );
+          }).toList(),
+        ),
+      ),
+    );
+  }
 }
```

---

### 2. `lib/modules/sales/views/widgets/contract_master_list.dart`
Switch from `FilterChip` to `AppSegmentedControl<int?>`:

```diff
--- a/lib/modules/sales/views/widgets/contract_master_list.dart
+++ b/lib/modules/sales/views/widgets/contract_master_list.dart
@@ -2,6 +2,7 @@ import 'package:flutter/material.dart';
 import 'package:google_fonts/google_fonts.dart';
 import 'package:centrow_sales/shared/theme/app_colors.dart';
 import 'package:centrow_sales/shared/theme/app_radius.dart';
+import 'package:centrow_sales/shared/widgets/app_segmented_control.dart';
 import 'package:centrow_sales/shared/widgets/app_badge.dart';
 import 'package:centrow_sales/modules/sales/entities/contract.dart';
 
@@ -107,37 +108,18 @@ class ContractMasterList extends StatelessWidget {
   }

   Widget _buildStatusFilters() {
-    const statuses = [
-      (null, 'Semua'),
-      (1, 'Draf'),
-      (2, 'Aktif'),
-      (3, 'Ditangguhkan'),
-      (5, 'Diterminasi'),
-      (6, 'Dibatalkan'),
-    ];
-    return SingleChildScrollView(
-      scrollDirection: Axis.horizontal,
-      child: Row(
-        children: statuses.map((s) {
-          final isSelected = selectedStatus == s.$1;
-          return Padding(
-            padding: const EdgeInsets.only(right: 6.0),
-            child: FilterChip(
-              label: Text(
-                s.$2,
-                style: GoogleFonts.inter(
-                  fontSize: 12.0,
-                  fontWeight: FontWeight.w600,
-                  color: isSelected ? AppColors.brand : AppColors.muted,
-                ),
-              ),
-              selected: isSelected,
-              onSelected: (_) => onStatusChanged(s.$1),
-              showCheckmark: false,
-              backgroundColor: AppColors.subtle,
-              selectedColor: AppColors.brand.withValues(alpha: 0.12),
-              side: BorderSide(
-                color: isSelected ? AppColors.brand : AppColors.border,
-                width: 1.5,
-              ),
-            ),
-          );
-        }).toList(),
-      ),
+    return AppSegmentedControl<int?>(
+      isScrollable: true,
+      items: const [
+        SegmentItem<int?>(label: 'Semua', value: null),
+        SegmentItem<int?>(label: 'Draf', value: 1),
+        SegmentItem<int?>(label: 'Aktif', value: 2),
+        SegmentItem<int?>(label: 'Ditangguhkan', value: 3),
+        SegmentItem<int?>(label: 'Diterminasi', value: 5),
+        SegmentItem<int?>(label: 'Dibatalkan', value: 6),
+      ],
+      selectedValue: selectedStatus,
+      onValueChanged: onStatusChanged,
     );
   }
```

---

### 3. `lib/modules/sales/controllers/contract_controller.dart`
Add `filteredContracts` computed signal:

```diff
--- a/lib/modules/sales/controllers/contract_controller.dart
+++ b/lib/modules/sales/controllers/contract_controller.dart
@@ -32,6 +32,38 @@ class ContractController {
   final _selectedStatus = signal<int?>(null);
   ReadonlySignal<int?> get selectedStatus => _selectedStatus;
 
+  late final filteredContracts = computed<List<Contract>>(() {
+    final state = _contractsState.value;
+    if (state is! UiSuccess<List<Contract>>) return <Contract>[];
+
+    var list = state.data;
+    final q = _searchQuery.value.trim().toLowerCase();
+    if (q.isNotEmpty) {
+      list = list
+          .where(
+            (c) =>
+                c.code.toLowerCase().contains(q) ||
+                c.customerName.toLowerCase().contains(q) ||
+                c.serviceName.toLowerCase().contains(q) ||
+                c.categoryName.toLowerCase().contains(q),
+          )
+          .toList();
+    }
+    final status = _selectedStatus.value;
+    if (status != null) {
+      list = list.where((c) {
+        return switch (status) {
+          1 => c.status == ContractStatus.draft,
+          2 => c.status == ContractStatus.active,
+          3 => c.status == ContractStatus.suspended,
+          4 => c.status == ContractStatus.expired,
+          5 => c.status == ContractStatus.terminated,
+          6 => c.status == ContractStatus.cancelled,
+          _ => true,
+        };
+      }).toList();
+    }
+    return list;
+  });
+
   late final selectedContract = computed<Contract?>(() {
     final id = _selectedContractId.value;
     if (id.isEmpty) return null;
@@ -48,6 +80,7 @@ class ContractController {
   void dispose() {
     _isDisposed = true;
     _contractsState.dispose();
     _contractDetailState.dispose();
     _actionState.dispose();
     _selectedContractId.dispose();
     _searchQuery.dispose();
     _selectedStatus.dispose();
+    filteredContracts.dispose();
     selectedContract.dispose();
   }
```

---

### 4. `lib/modules/sales/views/pages/contract_page.dart`
Connect `filteredContracts` in `ContractPage`:

```diff
--- a/lib/modules/sales/views/pages/contract_page.dart
+++ b/lib/modules/sales/views/pages/contract_page.dart
@@ -53,7 +53,7 @@ class _ContractPageState extends State<ContractPage> {
 
   Widget _buildSplitContent(BuildContext context) {
     final isTablet = MediaQuery.sizeOf(context).width >= 720;
-    final contracts = _controller.contractsState.value.dataOrNull ?? [];
+    final contracts = _controller.filteredContracts.value;
     final selectedId = _controller.selectedContractId.value;
     final selectedContract = _controller.selectedContract.value;
     final detailState = _controller.contractDetailState.value;
```

---

### 5. `test/shared/widgets/app_segmented_control_test.dart` (New File)
Test `AppSegmentedControl` in both standard fixed-width mode and scrollable mode:
- Selection changes on tap
- Correct rendering of labels
- Sliding pill and scrollable containers

### 6. `test/modules/sales/views/widgets/contract_master_list_test.dart` (New File)
Test `ContractMasterList`:
- Renders header with count
- Renders search input and triggers callback
- Renders `AppSegmentedControl<int?>` and changes status on tap
- Renders contract list items and selection state
- Renders empty placeholder when list is empty

---

## Verification Steps
1. Run `flutter test test/shared/widgets/app_segmented_control_test.dart` to verify `AppSegmentedControl` in both modes.
2. Run `flutter test test/modules/sales/views/widgets/contract_master_list_test.dart` to verify status segment clicks and master list behavior.
3. Run `flutter test test/modules/sales/views/widgets/proposal_master_list_test.dart` to ensure zero regression on Proposal page.
4. Run `flutter test` across the entire project.

## Out of Scope
- Changing proposal status keys/enums (proposal continues using string keys 'all', 'draft', etc.).
- Modifying backend contract status APIs.
- Detail pane alterations.
