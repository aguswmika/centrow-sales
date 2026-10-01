import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:centrow_sales/app/di.dart';
import 'package:centrow_sales/modules/sales/controllers/contract_addendum_controller.dart';
import 'package:centrow_sales/modules/sales/controllers/pricing_calculator_controller.dart';
import 'package:centrow_sales/modules/sales/entities/contract.dart';
import 'package:centrow_sales/modules/sales/entities/contract_addendum.dart';
import 'package:centrow_sales/modules/sales/repositories/contract_addendum_repository.dart';
import 'package:centrow_sales/modules/sales/repositories/dtos/contract_addendum_dto.dart';
import 'package:centrow_sales/modules/sales/repositories/dtos/pricing_dto.dart';
import 'package:centrow_sales/modules/sales/repositories/pricing_repository.dart';
import 'package:centrow_sales/modules/sales/views/pages/contract_addendum_pricing_page.dart';
import 'package:centrow_sales/modules/sales/entities/pricing_preview.dart';
import 'package:centrow_sales/modules/sales/entities/pricing_detail.dart';
import 'package:centrow_sales/shared/error/failure.dart';
import 'package:centrow_sales/shared/result/result.dart';

class MockPricingRepository implements PricingRepository {
  @override
  Future<Result<void>> savePricing(
    String proposalId,
    CreatePricingRequestDto data,
  ) async => const Ok(null);

  @override
  Future<Result<PricingDetail>> getPricingDetail(String proposalId) async {
    return const Ok(
      PricingDetail(
        id: 'pricing-1',
        customerId: 'cust-1',
        serviceId: 'srv-1',
        contractMonths: 12,
        visitFrequency: 2,
        totalVisits: 24,
        markupType: 1,
        markupValue: 20,
        discountAmount: 0,
        taxPercentage: 11,
        supplies: [],
        workers: [],
        items: [],
      ),
    );
  }

  @override
  Future<Result<PricingPreview>> previewPricing(
    String proposalId,
    CreatePricingRequestDto data,
  ) async => const Err(ServerFailure('not implemented'));
}

class MockContractAddendumRepository implements ContractAddendumRepository {
  CreateContractAddendumRequestDto? lastRequest;

  @override
  Future<Result<List<ContractAddendum>>> getAddendums(
    String contractId,
  ) async => const Ok([]);

  @override
  Future<Result<ContractAddendum>> createAddendum(
    String contractId,
    CreateContractAddendumRequestDto request,
  ) async {
    lastRequest = request;
    return Ok(
      ContractAddendum(
        id: 'addendum-1',
        contractId: contractId,
        visitDelta: request.totalVisits - 12,
        oldTotalVisits: 12,
        newTotalVisits: request.totalVisits,
        oldContractValue: 12000000.0,
        newContractValue: 15000000.0,
        reason: request.reason,
      ),
    );
  }
}

void main() {
  const sampleContract = Contract(
    id: 'contract-123',
    code: 'CTR-2026-0001',
    customerId: 'cust-1',
    customerName: 'PT Sukses Mandiri',
    serviceId: 'srv-1',
    serviceName: 'Pest Control Commercial',
    categoryId: 'cat-1',
    categoryName: 'Commercial',
    status: ContractStatus.active,
    startDate: '2026-01-01',
    totalVisits: 12,
    contractValue: 12000000.0,
    sourceProposalId: 'prop-123',
  );

  late MockPricingRepository mockPricingRepo;
  late MockContractAddendumRepository mockAddendumRepo;

  setUp(() {
    getIt.reset();
    mockPricingRepo = MockPricingRepository();
    mockAddendumRepo = MockContractAddendumRepository();

    getIt.registerFactory<PricingCalculatorController>(
      () => PricingCalculatorController(mockPricingRepo),
    );
    getIt.registerFactory<ContractAddendumController>(
      () => ContractAddendumController(mockAddendumRepo),
    );
  });

  tearDown(() {
    getIt.reset();
  });

  Widget buildWidget({Contract contract = sampleContract}) {
    return MaterialApp(
      home: MediaQuery(
        data: const MediaQueryData(size: Size(1200, 900)),
        child: Scaffold(body: ContractAddendumPricingPage(contract: contract)),
      ),
    );
  }

  testWidgets('renders contract addendum pricing page header and fields', (
    tester,
  ) async {
    await tester.pumpWidget(buildWidget());
    await tester.pumpAndSettle();

    expect(find.text('Kalkulator Addendum Kontrak'), findsOneWidget);
    expect(find.text('CTR-2026-0001'), findsOneWidget);
    expect(find.text('PT Sukses Mandiri'), findsOneWidget);
    expect(find.text('Pest Control Commercial'), findsOneWidget);
    expect(find.text('Durasi Kontrak'), findsOneWidget);
    expect(find.text('Frek. Kunjungan'), findsOneWidget);
    expect(find.text('Total Kunjungan'), findsOneWidget);
    expect(find.text('Review & Terapkan Addendum'), findsOneWidget);
  });

  testWidgets('tapping Review & Terapkan Addendum opens review bottom sheet', (
    tester,
  ) async {
    await tester.pumpWidget(buildWidget());
    await tester.pumpAndSettle();

    final reviewButton = find.text('Review & Terapkan Addendum');
    await tester.ensureVisible(reviewButton);
    await tester.tap(reviewButton);
    await tester.pumpAndSettle();

    expect(find.text('Ringkasan Addendum'), findsOneWidget);
    expect(find.text('Nilai Kontrak Sebelumnya'), findsOneWidget);
    expect(find.text('Alasan Addendum'), findsOneWidget);
    expect(find.text('Terapkan Addendum'), findsOneWidget);
  });

  testWidgets(
    'submitting addendum calls createAddendum with full pricing request',
    (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      final reviewButton = find.text('Review & Terapkan Addendum');
      await tester.ensureVisible(reviewButton);
      await tester.tap(reviewButton);
      await tester.pumpAndSettle();

      final reasonInput = find.byType(TextField).last;
      await tester.enterText(reasonInput, 'Penambahan frekuensi kunjungan');
      await tester.pumpAndSettle();

      final submitButton = find.text('Terapkan Addendum');
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      expect(mockAddendumRepo.lastRequest, isNotNull);
      expect(
        mockAddendumRepo.lastRequest!.reason,
        'Penambahan frekuensi kunjungan',
      );
      expect(mockAddendumRepo.lastRequest!.totalVisits, 24);
    },
  );
}
