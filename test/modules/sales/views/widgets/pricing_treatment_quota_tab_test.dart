import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:centrow_sales/app/di.dart';
import 'package:centrow_sales/modules/pc/entities/treatment_method.dart';
import 'package:centrow_sales/modules/pc/repositories/treatment_method_repository.dart';
import 'package:centrow_sales/modules/sales/controllers/pricing_calculator_controller.dart';
import 'package:centrow_sales/modules/sales/entities/pricing_detail.dart';
import 'package:centrow_sales/modules/sales/entities/pricing_preview.dart';
import 'package:centrow_sales/modules/sales/repositories/dtos/pricing_dto.dart';
import 'package:centrow_sales/modules/sales/repositories/pricing_repository.dart';
import 'package:centrow_sales/modules/sales/views/widgets/pricing_calculator/pricing_treatment_quota_tab.dart';
import 'package:centrow_sales/shared/error/failure.dart';
import 'package:centrow_sales/shared/result/result.dart';

class _FakePricingRepo implements PricingRepository {
  @override
  Future<Result<void>> savePricing(
    String id,
    CreatePricingRequestDto d,
  ) async => const Ok(null);
  @override
  Future<Result<PricingDetail>> getPricingDetail(String id) async =>
      const Err(UnknownFailure('Not implemented'));
  @override
  Future<Result<PricingPreview>> previewPricing(
    String id,
    CreatePricingRequestDto d,
  ) async => const Err(UnknownFailure('Not implemented'));
}

class _FakeTreatmentMethodRepo implements TreatmentMethodRepository {
  final List<TreatmentMethod> methods;
  _FakeTreatmentMethodRepo(this.methods);

  @override
  Future<Result<List<TreatmentMethod>>> getTreatmentMethods() async {
    return Ok(methods);
  }
}

void main() {
  late _FakePricingRepo pricingRepo;
  late _FakeTreatmentMethodRepo treatmentMethodRepo;
  late PricingCalculatorController controller;

  const methodsList = [
    TreatmentMethod(
      id: 'tm-req',
      code: 'SPRAY',
      name: 'Residual Spraying',
      isRequired: true,
    ),
    TreatmentMethod(
      id: 'tm-opt',
      code: 'BAIT',
      name: 'Gel Baiting',
      isRequired: false,
    ),
  ];

  setUp(() {
    pricingRepo = _FakePricingRepo();
    treatmentMethodRepo = _FakeTreatmentMethodRepo(methodsList);
    if (getIt.isRegistered<TreatmentMethodRepository>()) {
      getIt.unregister<TreatmentMethodRepository>();
    }
    getIt.registerSingleton<TreatmentMethodRepository>(treatmentMethodRepo);

    controller = PricingCalculatorController(
      pricingRepo,
      null,
      treatmentMethodRepo,
    );
  });

  tearDown(() {
    controller.dispose();
    if (getIt.isRegistered<TreatmentMethodRepository>()) {
      getIt.unregister<TreatmentMethodRepository>();
    }
  });

  Widget buildWidget({bool isReadOnly = false}) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: PricingTreatmentQuotaTab(
            controller: controller,
            isReadOnly: isReadOnly,
          ),
        ),
      ),
    );
  }

  testWidgets(
    'PricingTreatmentQuotaTab displays empty state and populates required methods',
    (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('Belum ada kuota treatment.'), findsOneWidget);
      expect(find.text('Tambah Metode'), findsOneWidget);
      expect(find.text('Isi Metode Wajib'), findsOneWidget);

      // Tap "Isi Metode Wajib"
      await tester.tap(find.text('Isi Metode Wajib'));
      await tester.pumpAndSettle();

      // The required method 'SPRAY' should now be populated
      expect(find.text('Residual Spraying'), findsOneWidget);
      expect(find.text('SPRAY'), findsOneWidget);
      expect(find.text('Wajib'), findsOneWidget);
      // Optional method should NOT be populated by "Isi Metode Wajib"
      expect(find.text('Gel Baiting'), findsNothing);
      expect(controller.treatmentQuotas.length, 1);
      expect(controller.treatmentQuotas.first.quota.value, 1);
    },
  );

  testWidgets(
    'PricingTreatmentQuotaTab allows adjusting quota and removing row',
    (tester) async {
      controller.addTreatmentQuota(
        const TreatmentMethod(
          id: 'tm-opt',
          code: 'BAIT',
          name: 'Gel Baiting',
          isRequired: false,
        ),
        quota: 3,
      );

      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('Gel Baiting'), findsOneWidget);
      expect(find.text('BAIT'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);

      // Increment quota via counter (+)
      await tester.tap(find.byIcon(Icons.add_rounded));
      await tester.pumpAndSettle();
      expect(controller.treatmentQuotas.first.quota.value, 4);

      // Remove row via close icon
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      expect(controller.treatmentQuotas.isEmpty, isTrue);
      expect(find.text('Gel Baiting'), findsNothing);
      expect(find.text('Belum ada kuota treatment.'), findsOneWidget);
    },
  );

  testWidgets(
    'PricingTreatmentQuotaTab populates from supplies when supplies are present',
    (tester) async {
      controller.supplies.add(
        PricingSupplyRow(
          id: 'p-1',
          title: 'Chemical Fog',
          code: 'CHM-FOG',
          uomCode: 'L',
          kind: 1,
          treatmentMethodId: 'tm-fog',
          treatmentMethodCode: 'FOG',
          treatmentMethodName: 'Thermal Fogging',
        ),
      );

      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(controller.treatmentQuotas.isEmpty, isTrue);

      await tester.tap(find.text('Isi Metode Wajib'));
      await tester.pumpAndSettle();

      expect(controller.treatmentQuotas.length, 1);
      expect(controller.treatmentQuotas.first.treatmentMethodId, 'tm-fog');
      expect(find.text('Thermal Fogging'), findsOneWidget);
      expect(find.text('FOG'), findsOneWidget);
    },
  );
}
