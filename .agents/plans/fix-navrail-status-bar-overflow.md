# Plan: Fix NavRail Sidebar Status Bar Overflow

## Goal
Prevent the tablet sidebar (`NavigationRail` in `NavRailShell`) and its leading logo from overflowing into and hitting the system status bar, ensuring seamless safe-area handling consistent with edge-to-edge tablet UI.

## Approach
Currently, `NavRailShell` renders `_buildNavRail` directly inside a `Row` without safe-area constraints. When the app runs edge-to-edge, the `leading` logo in the `NavigationRail` is positioned only `8.0` dp from the physical top edge of the screen, causing it to collide with the OS status bar icons and clock (as shown in the user's screenshot). In contrast, the child content (`CustomerPage`, `ProposalPage`, `ContractPage`) wraps its body in a `SafeArea`, creating a visual mismatch where the main content sits below the status bar while the sidebar logo penetrates into it.

We will wrap the `NavigationRail` inside a `Container` with `AppColors.surface` and a `SafeArea` with `right: false`.
- The `Container(color: AppColors.surface)` maintains edge-to-edge solid background behind the status bar and bottom navigation bar, matching standard Material / Centrow UI designs without creating an awkward gray gap at the top.
- The `SafeArea(right: false)` insets the rail content (`leading` logo at the top and `trailing` avatar button at the bottom) away from both the status bar and the bottom gesture / navigation bar, while allowing horizontal alignment against the right vertical divider.

We also add a widget test in `test/shared/widgets/nav_rail_shell_test.dart` asserting that the sidebar logo respects top safe area padding when running with physical insets.

## Affected Files
1. `lib/shared/widgets/nav_rail_shell.dart` - Wrap `NavigationRail` inside `Container(color: AppColors.surface, child: SafeArea(right: false, child: NavigationRail(...)))`.
2. `test/shared/widgets/nav_rail_shell_test.dart` - Add widget test verifying the logo is inset below the top status bar padding.

## Steps
1. In `lib/shared/widgets/nav_rail_shell.dart`, update `_buildNavRail(BuildContext context)` to wrap `NavigationRail` with `Container` and `SafeArea(right: false)`.
2. In `test/shared/widgets/nav_rail_shell_test.dart`, add a test case checking that when top safe-area padding is present, the sidebar's logo is positioned below the status bar.
3. Run `flutter test test/shared/widgets/nav_rail_shell_test.dart` to verify all test cases pass without regressions.

---

## Proposed Changes (Not Yet Applied)

### 1. `lib/shared/widgets/nav_rail_shell.dart`
Wrap `NavigationRail` in `Container(color: AppColors.surface)` and `SafeArea(right: false)`:

```diff
--- a/lib/shared/widgets/nav_rail_shell.dart
+++ b/lib/shared/widgets/nav_rail_shell.dart
@@ -148,6 +148,9 @@ class _NavRailShellState extends State<NavRailShell> {
   }

   Widget _buildNavRail(BuildContext context) {
+    return Container(
+      color: AppColors.surface,
+      child: SafeArea(
+        right: false,
+        child: NavigationRail(
       selectedIndex:
           widget.navigationShell?.currentIndex ?? widget.selectedIndex,
       onDestinationSelected: (idx) => _handleNavigation(context, idx),
@@ -230,6 +233,8 @@ class _NavRailShellState extends State<NavRailShell> {
         ),
       ],
     );
+      ),
+    );
   }

   Widget _buildBottomNav(BuildContext context) {
```

### 2. `test/shared/widgets/nav_rail_shell_test.dart`
Add test verifying that `NavigationRail` respects top status bar safe area:

```diff
--- a/test/shared/widgets/nav_rail_shell_test.dart
+++ b/test/shared/widgets/nav_rail_shell_test.dart
@@ -1,5 +1,6 @@
 import 'package:centrow_sales/modules/core/repositories/dtos/token_dto.dart';
 import 'package:flutter/material.dart';
+import 'package:flutter_svg/flutter_svg.dart';
 import 'package:flutter_test/flutter_test.dart';
 import 'package:shared_preferences/shared_preferences.dart';
 import 'package:centrow_sales/app/app.dart';
@@ -211,4 +212,28 @@ void main() {
       expect(find.text('Centrow Sales'), findsOneWidget);
     },
   );
+
+  testWidgets(
+    'NavRailShell respects top safe area padding to prevent status bar overlap',
+    (tester) async {
+      tester.view.physicalSize = const Size(1200, 900);
+      tester.view.devicePixelRatio = 1.0;
+      tester.view.padding = const FakeViewPadding(top: 40.0, bottom: 20.0);
+      addTearDown(tester.view.resetPhysicalSize);
+      addTearDown(tester.view.resetDevicePixelRatio);
+      addTearDown(tester.view.resetPadding);
+
+      final router = createRouter(initialLocation: '/customers');
+      await tester.pumpWidget(CentrowSalesApp(routerConfig: router));
+      await tester.pumpAndSettle();
+
+      expect(find.byType(NavigationRail), findsOneWidget);
+      final logoFinder = find.byWidgetPredicate(
+        (w) => w is SvgPicture,
+      );
+      expect(logoFinder, findsOneWidget);
+      final logoTopLeft = tester.getTopLeft(logoFinder);
+      expect(logoTopLeft.dy, greaterThanOrEqualTo(40.0));
+    },
+  );
 }
```

---

## Risks / Open Questions
- **Visual styling behind status bar**: Wrapping with `Container(color: AppColors.surface)` ensures the background behind the status bar on the left remains white (`AppColors.surface`), while the content below starts cleanly under the status bar. This mirrors the design of `_buildBottomNav` which wraps `BottomNavigationBar` in `Container(color: AppColors.surface, child: SafeArea(top: false, ...))`.
- **Landscape notches**: Using `SafeArea(right: false)` automatically accounts for left cutouts on tablets rotated into landscape mode without affecting horizontal alignment with `VerticalDivider`.

## Out of Scope
- Modifying individual pages' inner `SafeArea`s (`CustomerPage`, `ProposalPage`, `ContractPage`).
- Changing tablet breakpoint threshold (`720` dp).
