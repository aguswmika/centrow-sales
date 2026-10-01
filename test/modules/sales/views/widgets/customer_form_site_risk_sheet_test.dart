import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:centrow_sales/modules/sales/entities/site_risk.dart';
import 'package:centrow_sales/modules/sales/repositories/site_risk_repository.dart';
import 'package:centrow_sales/modules/sales/views/widgets/customer_form/customer_form_site_risk_sheet.dart';
import 'package:centrow_sales/shared/error/failure.dart';
import 'package:centrow_sales/shared/result/result.dart';
import 'package:centrow_sales/shared/widgets/error_view.dart';

class MockSiteRiskRepo implements SiteRiskRepository {
  List<SiteRiskMaster> masters = const [
    SiteRiskMaster(id: 'm-1', name: 'Area licin'),
    SiteRiskMaster(id: 'm-2', name: 'Ruang terbatas'),
  ];

  Result<List<SiteRiskMaster>>? resultOverride;
  int getMastersCount = 0;

  @override
  Future<Result<List<SiteRiskMaster>>> getSiteRiskMasters() async {
    getMastersCount++;
    return resultOverride ?? Ok(masters);
  }

  @override
  Future<Result<List<CustomerAddressRisk>>> getAddressRisks({
    required String customerId,
    required String addressId,
  }) async => const Ok([]);

  @override
  Future<Result<List<CustomerAddressRisk>>> updateAddressRisks({
    required String customerId,
    required String addressId,
    required List<String> siteRiskIds,
    required List<String> customRisks,
  }) async => const Ok([]);
}

void main() {
  group('CustomerFormSiteRiskSheet', () {
    late MockSiteRiskRepo repo;

    setUp(() {
      repo = MockSiteRiskRepo();
    });

    Widget createTestWidget({
      List<String> initialSiteRiskIds = const [],
      List<String> initialCustomRisks = const [],
      void Function(List<String>, List<String>)? onApply,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: CustomerFormSiteRiskSheet(
            repository: repo,
            initialSiteRiskIds: initialSiteRiskIds,
            initialCustomRisks: initialCustomRisks,
            onApply: onApply ?? (_, _) {},
          ),
        ),
      );
    }

    testWidgets('loads and renders master risks and preselected items', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget(initialSiteRiskIds: ['m-1']));
      await tester.pumpAndSettle();

      expect(find.text('Site Risk Assessment (SRA)'), findsOneWidget);
      expect(find.text('Area licin'), findsOneWidget);
      expect(find.text('Ruang terbatas'), findsOneWidget);
      expect(find.text('1/2'), findsOneWidget); // badge
    });

    testWidgets('toggles master risk selection', (tester) async {
      List<String>? appliedIds;
      await tester.pumpWidget(
        createTestWidget(
          initialSiteRiskIds: ['m-1'],
          onApply: (ids, custom) => appliedIds = ids,
        ),
      );
      await tester.pumpAndSettle();

      // Deselect m-1
      await tester.tap(find.text('Area licin'));
      await tester.pumpAndSettle();
      expect(find.text('0/2'), findsOneWidget);

      // Select m-2
      await tester.tap(find.text('Ruang terbatas'));
      await tester.pumpAndSettle();
      expect(find.text('1/2'), findsOneWidget);

      await tester.tap(find.byKey(const Key('sra_apply_button')));
      await tester.pumpAndSettle();

      expect(appliedIds, ['m-2']);
    });

    testWidgets('adds and removes custom risks', (tester) async {
      List<String>? appliedCustom;
      await tester.pumpWidget(
        createTestWidget(
          initialCustomRisks: ['Risiko Awal'],
          onApply: (ids, custom) => appliedCustom = custom,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Risiko Awal'), findsOneWidget);
      expect(find.text('1'), findsOneWidget); // custom badge

      // Add custom risk
      await tester.enterText(
        find.widgetWithText(TextField, 'Tambah risiko kustom...'),
        'Risiko Baru',
      );
      await tester.tap(find.text('Tambah'));
      await tester.pumpAndSettle();

      expect(find.text('Risiko Baru'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);

      // Remove the first custom risk
      final deleteButtons = find.byTooltip('Hapus Risiko Kustom');
      expect(deleteButtons, findsNWidgets(2));
      await tester.tap(deleteButtons.first);
      await tester.pumpAndSettle();

      expect(find.text('Risiko Awal'), findsNothing);
      expect(find.text('Risiko Baru'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);

      await tester.tap(find.byKey(const Key('sra_apply_button')));
      await tester.pumpAndSettle();

      expect(appliedCustom, ['Risiko Baru']);
    });

    testWidgets('shows error view on failure and retries', (tester) async {
      repo.resultOverride = const Err(NetworkFailure('Koneksi terputus'));

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(ErrorView), findsOneWidget);
      expect(find.text('Koneksi terputus'), findsOneWidget);

      repo.resultOverride = null;
      await tester.tap(find.text('Coba Lagi'));
      await tester.pumpAndSettle();

      expect(find.byType(ErrorView), findsNothing);
      expect(find.text('Area licin'), findsOneWidget);
    });
  });
}
