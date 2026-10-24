import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:centrow_sales/modules/sales/controllers/pricing_calculator_controller.dart';
import 'package:centrow_sales/modules/sales/entities/pricing_detail.dart';
import 'package:centrow_sales/modules/sales/entities/pricing_preview.dart';
import 'package:centrow_sales/modules/sales/entities/proposal.dart';
import 'package:centrow_sales/modules/sales/repositories/dtos/pricing_dto.dart';
import 'package:centrow_sales/modules/sales/repositories/pricing_repository.dart';
import 'package:centrow_sales/modules/sales/views/pages/pricing_preview_page.dart';
import 'package:centrow_sales/modules/sales/views/widgets/pricing_calculator/pricing_settings_card.dart';
import 'package:centrow_sales/shared/error/failure.dart';
import 'package:centrow_sales/shared/result/result.dart';
import 'package:centrow_sales/shared/widgets/app_button.dart';

class MockPricingRepository implements PricingRepository {
  int previewCallCount = 0;
  int saveCallCount = 0;

  @override
  Future<Result<void>> savePricing(
    String proposalId,
    CreatePricingRequestDto data,
  ) async {
    saveCallCount++;
    return const Ok(null);
  }

  @override
  Future<Result<PricingDetail>> getPricingDetail(String proposalId) async {
    return const Err(UnknownFailure('Not implemented'));
  }

  @override
  Future<Result<PricingPreview>> previewPricing(
    String proposalId,
    CreatePricingRequestDto data,
  ) async {
    previewCallCount++;
    return Ok(
      PricingPreview(
        suppliesCost: 100000.0,
        workerCost: 50000.0,
        fuelCost: 20000.0,
        totalCost: 170000.0,
        servicePrice: data.markupValue,
        addonAmount: 0.0,
        discountAmount: 0.0,
        subtotal: data.markupValue,
        taxPercentage: data.taxPercentage,
        taxAmount: data.markupValue * (data.taxPercentage / 100.0),
        totalAmount: data.markupValue * (1 + data.taxPercentage / 100.0),
        marginAmount: data.markupValue - 170000.0,
        marginPercent: data.markupValue > 0
            ? ((data.markupValue - 170000.0) / data.markupValue) * 100.0
            : 0.0,
        supplies: const [],
        workers: const [],
        items: const [],
      ),
    );
  }
}

void main() {
  late MockPricingRepository repository;
  late PricingCalculatorController controller;

  const sampleProposal = Proposal(
    id: 'prop-1',
    code: 'PROP-2026-0001',
    clientName: 'PT Sukses Bersama',
    serviceName: 'Commercial Pest Control',
    status: ProposalStatus.draft,
    date: '2026-09-01',
    validUntil: '2026-09-30',
    location: 'Jakarta',
    hasPricing: true,
  );

  const initialPreview = PricingPreview(
    suppliesCost: 100000.0,
    workerCost: 50000.0,
    fuelCost: 20000.0,
    totalCost: 170000.0,
    servicePrice: 500000.0,
    addonAmount: 0.0,
    discountAmount: 0.0,
    subtotal: 500000.0,
    taxPercentage: 11.0,
    taxAmount: 55000.0,
    totalAmount: 555000.0,
    marginAmount: 330000.0,
    marginPercent: 66.0,
    supplies: [],
    workers: [],
    items: [],
  );

  setUp(() {
    repository = MockPricingRepository();
    controller = PricingCalculatorController(repository);
    controller.totalVisits.value = 12;
    controller.markupPercent.value = 500000.0;
  });

  tearDown(() {
    controller.dispose();
  });

  Widget createWidget() {
    final router = GoRouter(
      initialLocation: '/preview',
      routes: [
        GoRoute(
          path: '/preview',
          builder: (context, state) => PricingPreviewPage(
            proposal: sampleProposal,
            preview: initialPreview,
            controller: controller,
            contractMonths: 12,
          ),
        ),
        GoRoute(
          path: '/proposals',
          builder: (context, state) =>
              const Scaffold(body: Text('Proposals Page')),
        ),
      ],
    );
    return MaterialApp.router(routerConfig: router);
  }

  testWidgets('renders PricingSettingsCard inside Ringkasan Kalkulasi', (
    tester,
  ) async {
    await tester.pumpWidget(createWidget());
    await tester.pumpAndSettle();

    expect(find.text('Ringkasan Kalkulasi'), findsOneWidget);
    expect(find.byType(PricingSettingsCard), findsOneWidget);
    expect(find.text('Pengaturan Penawaran & Pajak'), findsOneWidget);
    expect(find.text('Model & Nilai Penawaran'), findsOneWidget);
  });

  testWidgets(
    'editing offer changes bottom button to Kalkulasi Ulang, recalculating changes it to Konfirmasi & Simpan, editing again reverts to Kalkulasi Ulang',
    (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      // Controller markup is initially 500000.0 (>0), so button is initially Konfirmasi & Simpan
      expect(
        find.widgetWithText(AppButton, 'Konfirmasi & Simpan'),
        findsOneWidget,
      );
      expect(find.widgetWithText(AppButton, 'Kalkulasi Ulang'), findsNothing);

      // Find TextFormField for offer
      final offerInputFinder = find.byKey(const ValueKey('offer_value_3'));
      expect(offerInputFinder, findsOneWidget);
      expect(find.text('500.000'), findsOneWidget);

      // Edit the text
      await tester.enterText(offerInputFinder, '1000000');
      await tester.pumpAndSettle();

      // Formatted as currency with thousands separator!
      expect(find.text('1.000.000'), findsOneWidget);

      // No preview call on change!
      expect(repository.previewCallCount, 0);
      expect(controller.markupPercent.value, 1000000.0);

      // Now the button should have transitioned to Kalkulasi Ulang!
      final recalcButtonFinder = find.widgetWithText(
        AppButton,
        'Kalkulasi Ulang',
      );
      expect(recalcButtonFinder, findsOneWidget);
      expect(
        find.widgetWithText(AppButton, 'Konfirmasi & Simpan'),
        findsNothing,
      );

      // Tap Kalkulasi Ulang
      await tester.tap(recalcButtonFinder);
      await tester.pumpAndSettle();

      expect(repository.previewCallCount, 1);

      // After recalculation succeeds, button transforms to Konfirmasi & Simpan!
      expect(
        find.widgetWithText(AppButton, 'Konfirmasi & Simpan'),
        findsOneWidget,
      );
      expect(find.widgetWithText(AppButton, 'Kalkulasi Ulang'), findsNothing);

      // Edit again
      await tester.enterText(offerInputFinder, '2000000');
      await tester.pumpAndSettle();

      // Button reverts back to Kalkulasi Ulang!
      expect(find.widgetWithText(AppButton, 'Kalkulasi Ulang'), findsOneWidget);
      expect(
        find.widgetWithText(AppButton, 'Konfirmasi & Simpan'),
        findsNothing,
      );
    },
  );

  testWidgets('tapping Konfirmasi & Simpan submits pricing when valid', (
    tester,
  ) async {
    await tester.pumpWidget(createWidget());
    await tester.pumpAndSettle();

    expect(repository.saveCallCount, 0);

    final saveButtonFinder = find.widgetWithText(
      AppButton,
      'Konfirmasi & Simpan',
    );
    expect(saveButtonFinder, findsOneWidget);

    await tester.tap(saveButtonFinder);
    await tester.pumpAndSettle();

    expect(repository.saveCallCount, 1);
  });
}
