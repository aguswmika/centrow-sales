import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:centrow_sales/modules/sales/controllers/pricing_calculator_controller.dart';
import 'package:centrow_sales/modules/sales/repositories/pricing_repository.dart';
import 'package:centrow_sales/modules/sales/views/widgets/pricing_calculator/pricing_material_tab.dart';

class _FakePricingRepository implements PricingRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

PricingSupplyRow _chemicalRow({
  String? treatmentMethodId,
  String? treatmentMethodName,
  String? treatmentMethodCode,
}) {
  return PricingSupplyRow(
    id: 'prod-1',
    title: 'Chemical A',
    code: 'CHEM-A',
    uomCode: 'ML',
    uomName: 'Mililiter',
    kind: 1,
    initialTreatmentMethodId: treatmentMethodId,
    initialTreatmentMethodName: treatmentMethodName,
    initialTreatmentMethodCode: treatmentMethodCode,
  );
}

Future<void> _pumpMaterialTab(WidgetTester tester, PricingSupplyRow row) async {
  tester.view.physicalSize = const Size(1200, 900);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final controller = PricingCalculatorController(_FakePricingRepository());
  controller.supplies.add(row);

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: PricingSupplyTab(controller: controller),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  const warningLabel = '+ Pilih Metode (Wajib)';

  testWidgets(
    'row restored with method id only shows "Metode terpilih" badge',
    (tester) async {
      await _pumpMaterialTab(tester, _chemicalRow(treatmentMethodId: 'tm-1'));

      expect(find.text('Metode terpilih'), findsOneWidget);
      expect(find.text(warningLabel), findsNothing);
    },
  );

  testWidgets('row restored with method name shows name badge and no warning', (
    tester,
  ) async {
    await _pumpMaterialTab(
      tester,
      _chemicalRow(
        treatmentMethodId: 'tm-1',
        treatmentMethodName: 'Cold Fog',
        treatmentMethodCode: 'CF',
      ),
    );

    expect(find.text('Cold Fog'), findsOneWidget);
    expect(find.text('Metode terpilih'), findsNothing);
    expect(find.text(warningLabel), findsNothing);
  });

  testWidgets('row with method id and only code shows code badge', (
    tester,
  ) async {
    await _pumpMaterialTab(
      tester,
      _chemicalRow(treatmentMethodId: 'tm-1', treatmentMethodCode: 'CF'),
    );

    expect(find.text('CF'), findsOneWidget);
    expect(find.text(warningLabel), findsNothing);
  });

  testWidgets('row without method id shows required warning', (tester) async {
    await _pumpMaterialTab(tester, _chemicalRow());

    expect(find.text(warningLabel), findsOneWidget);
    expect(find.text('Metode terpilih'), findsNothing);
  });
}
