import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:centrow_sales/app/di.dart';
import 'package:centrow_sales/modules/pc/controllers/treatment_method_controller.dart';
import 'package:centrow_sales/modules/pc/entities/treatment_method.dart';
import 'package:centrow_sales/modules/pc/repositories/treatment_method_repository.dart';
import 'package:centrow_sales/modules/sales/views/widgets/treatment_method_picker_sheet.dart';
import 'package:centrow_sales/shared/error/failure.dart';
import 'package:centrow_sales/shared/result/result.dart';

class MockTreatmentMethodRepository implements TreatmentMethodRepository {
  List<TreatmentMethod> methods = [
    const TreatmentMethod(
      id: 'tm-1',
      code: 'SPRAY',
      name: 'Spraying',
      description: 'Penyemprotan larutan kimia secara merata',
    ),
    const TreatmentMethod(
      id: 'tm-2',
      code: 'BAIT',
      name: 'Baiting',
      description: 'Pemasangan umpan racun hama',
    ),
    const TreatmentMethod(id: 'tm-3', code: 'FOG', name: 'Fogging'),
  ];

  Result<List<TreatmentMethod>>? resultOverride;
  int getTreatmentMethodsCalls = 0;

  @override
  Future<Result<List<TreatmentMethod>>> getTreatmentMethods() async {
    getTreatmentMethodsCalls++;
    if (resultOverride != null) {
      return resultOverride!;
    }
    return Ok(methods);
  }
}

void main() {
  late MockTreatmentMethodRepository mockRepository;

  setUp(() {
    mockRepository = MockTreatmentMethodRepository();
    if (getIt.isRegistered<TreatmentMethodRepository>()) {
      getIt.unregister<TreatmentMethodRepository>();
    }
    if (getIt.isRegistered<TreatmentMethodController>()) {
      getIt.unregister<TreatmentMethodController>();
    }
    getIt.registerSingleton<TreatmentMethodRepository>(mockRepository);
    getIt.registerFactory<TreatmentMethodController>(
      () => TreatmentMethodController(getIt<TreatmentMethodRepository>()),
    );
  });

  tearDown(() {
    if (getIt.isRegistered<TreatmentMethodRepository>()) {
      getIt.unregister<TreatmentMethodRepository>();
    }
    if (getIt.isRegistered<TreatmentMethodController>()) {
      getIt.unregister<TreatmentMethodController>();
    }
  });

  testWidgets(
    'renders TreatmentMethodPickerSheet and displays treatment methods',
    (tester) async {
      TreatmentMethod? selectedMethod;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () async {
                    selectedMethod =
                        await showModalBottomSheet<TreatmentMethod>(
                          context: context,
                          builder: (_) => const TreatmentMethodPickerSheet(),
                        );
                  },
                  child: const Text('Open Picker'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Picker'));
      await tester.pumpAndSettle();

      expect(find.text('Pilih Metode Treatment'), findsOneWidget);
      expect(find.text('Spraying'), findsOneWidget);
      expect(find.text('SPRAY'), findsOneWidget);
      expect(
        find.text('Penyemprotan larutan kimia secara merata'),
        findsOneWidget,
      );

      expect(find.text('Baiting'), findsOneWidget);
      expect(find.text('BAIT'), findsOneWidget);
      expect(find.text('Pemasangan umpan racun hama'), findsOneWidget);

      expect(find.text('Fogging'), findsOneWidget);
      expect(find.text('FOG'), findsOneWidget);

      // Tap on Spraying
      await tester.tap(find.text('Spraying'));
      await tester.pumpAndSettle();

      expect(selectedMethod, isNotNull);
      expect(selectedMethod!.id, 'tm-1');
      expect(selectedMethod!.name, 'Spraying');
      expect(selectedMethod!.code, 'SPRAY');
    },
  );

  testWidgets(
    'renders empty placeholder when treatment methods list is empty',
    (tester) async {
      mockRepository.methods = [];

      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: TreatmentMethodPickerSheet())),
      );
      await tester.pumpAndSettle();

      expect(find.text('Tidak ada metode treatment ditemukan'), findsOneWidget);
    },
  );

  testWidgets('renders ErrorView and retries when repository fails', (
    tester,
  ) async {
    mockRepository.resultOverride = const Err(
      ServerFailure('Gagal memuat metode'),
    );

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: TreatmentMethodPickerSheet())),
    );
    await tester.pumpAndSettle();

    expect(find.text('Gagal memuat metode'), findsOneWidget);

    // Fix repository and retry
    mockRepository.resultOverride = null;
    await tester.tap(find.text('Coba Lagi'));
    await tester.pumpAndSettle();

    expect(find.text('Spraying'), findsOneWidget);
  });

  testWidgets('close button dismisses bottom sheet without selecting', (
    tester,
  ) async {
    TreatmentMethod? selectedMethod;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () async {
                  selectedMethod = await showModalBottomSheet<TreatmentMethod>(
                    context: context,
                    builder: (_) => const TreatmentMethodPickerSheet(),
                  );
                },
                child: const Text('Open Picker'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Picker'));
    await tester.pumpAndSettle();

    expect(find.text('Pilih Metode Treatment'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();

    expect(selectedMethod, isNull);
  });
}
