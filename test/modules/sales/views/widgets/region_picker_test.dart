import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:centrow_sales/app/di.dart';
import 'package:centrow_sales/modules/core/entities/region.dart';
import 'package:centrow_sales/modules/core/repositories/region_repository.dart';
import 'package:centrow_sales/modules/sales/entities/create_customer_input.dart';
import 'package:centrow_sales/modules/sales/views/widgets/customer_form/region_picker.dart';
import 'package:centrow_sales/shared/result/result.dart';

class MockRegionRepository implements RegionRepository {
  List<Province> provinces = const [
    Province(id: 51, name: 'Bali'),
    Province(id: 31, name: 'DKI Jakarta'),
  ];
  List<Regency> regencies = const [
    Regency(id: 5101, name: 'Kab. Jembrana'),
    Regency(id: 5103, name: 'Kab. Badung'),
  ];
  List<District> districts = const [
    District(id: 5103010, name: 'Kuta Selatan'),
    District(id: 5103020, name: 'Kuta'),
  ];
  List<Village> villages = const [
    Village(id: 5103020001, name: 'Kuta'),
    Village(id: 5103020002, name: 'Legian'),
    Village(id: 5103020003, name: 'Seminyak'),
  ];

  int getProvincesCallCount = 0;
  List<int> getRegenciesCalls = [];
  List<(int, int)> getDistrictsCalls = [];
  List<(int, int, int)> getVillagesCalls = [];

  Future<Result<List<Province>>> Function()? onGetProvinces;
  Future<Result<List<Regency>>> Function(int provinceId)? onGetRegencies;
  Future<Result<List<District>>> Function(int provinceId, int regencyId)?
  onGetDistricts;
  Future<Result<List<Village>>> Function(
    int provinceId,
    int regencyId,
    int districtId,
  )?
  onGetVillages;

  @override
  Future<Result<List<Province>>> getProvinces() async {
    getProvincesCallCount++;
    if (onGetProvinces != null) {
      return onGetProvinces!();
    }
    return Ok(provinces);
  }

  @override
  Future<Result<List<Regency>>> getRegencies(int provinceId) async {
    getRegenciesCalls.add(provinceId);
    if (onGetRegencies != null) {
      return onGetRegencies!(provinceId);
    }
    return Ok(regencies);
  }

  @override
  Future<Result<List<District>>> getDistricts(
    int provinceId,
    int regencyId,
  ) async {
    getDistrictsCalls.add((provinceId, regencyId));
    if (onGetDistricts != null) {
      return onGetDistricts!(provinceId, regencyId);
    }
    return Ok(districts);
  }

  @override
  Future<Result<List<Village>>> getVillages(
    int provinceId,
    int regencyId,
    int districtId,
  ) async {
    getVillagesCalls.add((provinceId, regencyId, districtId));
    if (onGetVillages != null) {
      return onGetVillages!(provinceId, regencyId, districtId);
    }
    return Ok(villages);
  }
}

void main() {
  late MockRegionRepository mockRepository;

  setUp(() {
    mockRepository = MockRegionRepository();
    if (getIt.isRegistered<RegionRepository>()) {
      getIt.unregister<RegionRepository>();
    }
    getIt.registerSingleton<RegionRepository>(mockRepository);
  });

  tearDown(() {
    if (getIt.isRegistered<RegionRepository>()) {
      getIt.unregister<RegionRepository>();
    }
  });

  Widget createWidget({
    required CreateLocationInput item,
    required ValueChanged<CreateLocationInput> onChanged,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: RegionPicker(item: item, onChanged: onChanged),
        ),
      ),
    );
  }

  testWidgets('fetches provinces on initState when item is empty', (
    tester,
  ) async {
    CreateLocationInput location = const CreateLocationInput();

    await tester.pumpWidget(
      createWidget(item: location, onChanged: (val) => location = val),
    );
    await tester.pumpAndSettle();

    expect(mockRepository.getProvincesCallCount, 1);
    expect(mockRepository.getRegenciesCalls, isEmpty);
    expect(find.text('Provinsi'), findsOneWidget);
    expect(find.text('Kabupaten / Kota'), findsOneWidget);
    expect(find.text('Kecamatan'), findsOneWidget);
    expect(find.text('Kelurahan / Desa'), findsOneWidget);
  });

  testWidgets('initializes cascading data when item already has IDs', (
    tester,
  ) async {
    const location = CreateLocationInput(
      provinceId: 51,
      province: 'Bali',
      regencyId: 5103,
      regency: 'Kab. Badung',
      districtId: 5103020,
      district: 'Kuta',
      villageId: 5103020003,
      village: 'Seminyak',
    );

    await tester.pumpWidget(createWidget(item: location, onChanged: (_) {}));
    await tester.pumpAndSettle();

    expect(mockRepository.getProvincesCallCount, 1);
    expect(mockRepository.getRegenciesCalls, [51]);
    expect(mockRepository.getDistrictsCalls, [(51, 5103)]);
    expect(mockRepository.getVillagesCalls, [(51, 5103, 5103020)]);

    expect(find.text('Bali'), findsOneWidget);
    expect(find.text('Kab. Badung'), findsOneWidget);
    expect(find.text('Kuta'), findsOneWidget);
    expect(find.text('Seminyak'), findsOneWidget);
  });

  testWidgets('changing Province resets lower regions and fetches Regencies', (
    tester,
  ) async {
    CreateLocationInput location = const CreateLocationInput(
      provinceId: 31,
      province: 'DKI Jakarta',
      regencyId: 3101,
      regency: 'Kepulauan Seribu',
    );

    CreateLocationInput? updatedLocation;

    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, setState) {
          return MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: RegionPicker(
                  item: location,
                  onChanged: (val) {
                    updatedLocation = val;
                    setState(() {
                      location = val;
                    });
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
    await tester.pumpAndSettle();

    // Tap on Province dropdown
    await tester.tap(find.byType(DropdownButtonFormField<int>).at(0));
    await tester.pumpAndSettle();

    // Select Bali
    await tester.tap(find.text('Bali').last);
    await tester.pumpAndSettle();

    expect(updatedLocation, isNotNull);
    expect(updatedLocation!.provinceId, 51);
    expect(updatedLocation!.province, 'Bali');
    expect(updatedLocation!.regencyId, isNull);
    expect(updatedLocation!.regency, '');
    expect(updatedLocation!.districtId, isNull);
    expect(updatedLocation!.district, '');
    expect(updatedLocation!.villageId, isNull);
    expect(updatedLocation!.village, '');

    expect(mockRepository.getRegenciesCalls.contains(51), isTrue);
  });

  testWidgets(
    'changing Regency resets district & village and fetches Districts',
    (tester) async {
      CreateLocationInput location = const CreateLocationInput(
        provinceId: 51,
        province: 'Bali',
      );

      CreateLocationInput? updatedLocation;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return MaterialApp(
              home: Scaffold(
                body: SingleChildScrollView(
                  child: RegionPicker(
                    item: location,
                    onChanged: (val) {
                      updatedLocation = val;
                      setState(() {
                        location = val;
                      });
                    },
                  ),
                ),
              ),
            );
          },
        ),
      );
      await tester.pumpAndSettle();

      // Tap on Regency dropdown
      await tester.tap(find.byType(DropdownButtonFormField<int>).at(1));
      await tester.pumpAndSettle();

      // Select Badung
      await tester.tap(find.text('Kab. Badung').last);
      await tester.pumpAndSettle();

      expect(updatedLocation, isNotNull);
      expect(updatedLocation!.provinceId, 51);
      expect(updatedLocation!.regencyId, 5103);
      expect(updatedLocation!.regency, 'Kab. Badung');
      expect(updatedLocation!.districtId, isNull);
      expect(updatedLocation!.district, '');
      expect(updatedLocation!.villageId, isNull);
      expect(updatedLocation!.village, '');

      expect(mockRepository.getDistrictsCalls.contains((51, 5103)), isTrue);
    },
  );

  testWidgets('changing District resets village and fetches Villages', (
    tester,
  ) async {
    CreateLocationInput location = const CreateLocationInput(
      provinceId: 51,
      province: 'Bali',
      regencyId: 5103,
      regency: 'Kab. Badung',
    );

    CreateLocationInput? updatedLocation;

    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, setState) {
          return MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: RegionPicker(
                  item: location,
                  onChanged: (val) {
                    updatedLocation = val;
                    setState(() {
                      location = val;
                    });
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
    await tester.pumpAndSettle();

    // Tap on District dropdown
    await tester.tap(find.byType(DropdownButtonFormField<int>).at(2));
    await tester.pumpAndSettle();

    // Select Kuta
    await tester.tap(find.text('Kuta').last);
    await tester.pumpAndSettle();

    expect(updatedLocation, isNotNull);
    expect(updatedLocation!.provinceId, 51);
    expect(updatedLocation!.regencyId, 5103);
    expect(updatedLocation!.districtId, 5103020);
    expect(updatedLocation!.district, 'Kuta');
    expect(updatedLocation!.villageId, isNull);
    expect(updatedLocation!.village, '');

    expect(
      mockRepository.getVillagesCalls.contains((51, 5103, 5103020)),
      isTrue,
    );
  });

  testWidgets('changing Village updates villageId and village name', (
    tester,
  ) async {
    CreateLocationInput location = const CreateLocationInput(
      provinceId: 51,
      province: 'Bali',
      regencyId: 5103,
      regency: 'Kab. Badung',
      districtId: 5103020,
      district: 'Kuta',
    );

    CreateLocationInput? updatedLocation;

    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, setState) {
          return MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: RegionPicker(
                  item: location,
                  onChanged: (val) {
                    updatedLocation = val;
                    setState(() {
                      location = val;
                    });
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
    await tester.pumpAndSettle();

    // Tap on Village dropdown
    await tester.tap(find.byType(DropdownButtonFormField<int>).at(3));
    await tester.pumpAndSettle();

    // Select Seminyak
    await tester.tap(find.text('Seminyak').last);
    await tester.pumpAndSettle();

    expect(updatedLocation, isNotNull);
    expect(updatedLocation!.provinceId, 51);
    expect(updatedLocation!.regencyId, 5103);
    expect(updatedLocation!.districtId, 5103020);
    expect(updatedLocation!.villageId, 5103020003);
    expect(updatedLocation!.village, 'Seminyak');
  });

  testWidgets(
    'didUpdateWidget triggers cascading fetch when provinceId changes externally',
    (tester) async {
      CreateLocationInput location = const CreateLocationInput();

      late void Function(void Function()) parentSetState;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            parentSetState = setState;
            return MaterialApp(
              home: Scaffold(
                body: SingleChildScrollView(
                  child: RegionPicker(item: location, onChanged: (_) {}),
                ),
              ),
            );
          },
        ),
      );
      await tester.pumpAndSettle();

      expect(mockRepository.getRegenciesCalls, isEmpty);

      parentSetState(() {
        location = const CreateLocationInput(provinceId: 51, province: 'Bali');
      });
      await tester.pumpAndSettle();

      expect(mockRepository.getRegenciesCalls, [51]);
    },
  );

  testWidgets(
    'auto-resolves missing region IDs by normalized name when option lists load',
    (tester) async {
      CreateLocationInput location = const CreateLocationInput(
        province: 'Bali',
        regency: 'Badung', // Note: mock repo has 'Kab. Badung' (id: 5103)
        district: 'Kuta', // id: 5103020
        village: 'Seminyak', // id: 5103020003
      );

      CreateLocationInput? lastUpdated;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return MaterialApp(
              home: Scaffold(
                body: SingleChildScrollView(
                  child: RegionPicker(
                    item: location,
                    onChanged: (val) {
                      lastUpdated = val;
                      setState(() {
                        location = val;
                      });
                    },
                  ),
                ),
              ),
            );
          },
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Bali'), findsOneWidget);
      expect(find.text('Kab. Badung'), findsOneWidget);
      expect(find.text('Kuta'), findsOneWidget);
      expect(find.text('Seminyak'), findsOneWidget);

      expect(lastUpdated, isNotNull);
      expect(lastUpdated!.provinceId, 51);
      expect(lastUpdated!.regencyId, 5103);
      expect(lastUpdated!.districtId, 5103020);
      expect(lastUpdated!.villageId, 5103020003);
    },
  );

  testWidgets(
    'shows loading placeholder and disables regency dropdown while regencies are loading for selected province',
    (tester) async {
      final regencyCompleter = Completer<Result<List<Regency>>>();
      mockRepository.onGetRegencies = (_) => regencyCompleter.future;

      const location = CreateLocationInput(provinceId: 51, province: 'Bali');

      await tester.pumpWidget(createWidget(item: location, onChanged: (_) {}));
      await tester.pump();

      expect(find.text('Bali'), findsOneWidget);
      expect(find.text('Memuat kabupaten/kota...'), findsOneWidget);
      expect(find.text('Pilih provinsi terlebih dahulu'), findsNothing);

      // Verify regency dropdown is disabled while loading
      final regencyFinder = find.byType(DropdownButtonFormField<int>).at(1);
      final DropdownButtonFormField<int> regencyWidget = tester.widget(
        regencyFinder,
      );
      expect(regencyWidget.onChanged, isNull);

      // Complete fetch
      regencyCompleter.complete(Ok(mockRepository.regencies));
      await tester.pumpAndSettle();

      expect(find.text('Pilih Kabupaten / Kota'), findsOneWidget);
      final DropdownButtonFormField<int> enabledWidget = tester.widget(
        regencyFinder,
      );
      expect(enabledWidget.onChanged, isNotNull);
    },
  );

  testWidgets(
    'shows loading placeholder for district when regency is selected and options are loading',
    (tester) async {
      final districtCompleter = Completer<Result<List<District>>>();
      mockRepository.onGetDistricts = (_, _) => districtCompleter.future;

      const location = CreateLocationInput(
        provinceId: 51,
        province: 'Bali',
        regencyId: 5103,
        regency: 'Kab. Badung',
      );

      await tester.pumpWidget(createWidget(item: location, onChanged: (_) {}));
      await tester.pump();

      expect(find.text('Kab. Badung'), findsOneWidget);
      expect(find.text('Memuat kecamatan...'), findsOneWidget);
      expect(find.text('Pilih kabupaten/kota terlebih dahulu'), findsNothing);

      // Verify district dropdown is disabled while loading
      final districtFinder = find.byType(DropdownButtonFormField<int>).at(2);
      final DropdownButtonFormField<int> districtWidget = tester.widget(
        districtFinder,
      );
      expect(districtWidget.onChanged, isNull);

      // Complete fetch
      districtCompleter.complete(Ok(mockRepository.districts));
      await tester.pumpAndSettle();

      expect(find.text('Pilih Kecamatan'), findsOneWidget);
      final DropdownButtonFormField<int> enabledWidget = tester.widget(
        districtFinder,
      );
      expect(enabledWidget.onChanged, isNotNull);
    },
  );

  testWidgets(
    'shows loading placeholder for village when district is selected and options are loading',
    (tester) async {
      final villageCompleter = Completer<Result<List<Village>>>();
      mockRepository.onGetVillages = (_, _, _) => villageCompleter.future;

      const location = CreateLocationInput(
        provinceId: 51,
        province: 'Bali',
        regencyId: 5103,
        regency: 'Kab. Badung',
        districtId: 5103020,
        district: 'Kuta',
      );

      await tester.pumpWidget(createWidget(item: location, onChanged: (_) {}));
      await tester.pump();

      expect(find.text('Kuta'), findsOneWidget);
      expect(find.text('Memuat kelurahan/desa...'), findsOneWidget);
      expect(find.text('Pilih kecamatan terlebih dahulu'), findsNothing);

      // Verify village dropdown is disabled while loading
      final villageFinder = find.byType(DropdownButtonFormField<int>).at(3);
      final DropdownButtonFormField<int> villageWidget = tester.widget(
        villageFinder,
      );
      expect(villageWidget.onChanged, isNull);

      // Complete fetch
      villageCompleter.complete(Ok(mockRepository.villages));
      await tester.pumpAndSettle();

      expect(find.text('Pilih Kelurahan / Desa'), findsOneWidget);
      final DropdownButtonFormField<int> enabledWidget = tester.widget(
        villageFinder,
      );
      expect(enabledWidget.onChanged, isNotNull);
    },
  );

  testWidgets(
    'didUpdateWidget triggers cascading fetch when regencyId changes externally',
    (tester) async {
      CreateLocationInput location = const CreateLocationInput(
        provinceId: 51,
        province: 'Bali',
      );

      late void Function(void Function()) parentSetState;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            parentSetState = setState;
            return MaterialApp(
              home: Scaffold(
                body: SingleChildScrollView(
                  child: RegionPicker(item: location, onChanged: (_) {}),
                ),
              ),
            );
          },
        ),
      );
      await tester.pumpAndSettle();

      expect(mockRepository.getDistrictsCalls, isEmpty);

      parentSetState(() {
        location = const CreateLocationInput(
          provinceId: 51,
          province: 'Bali',
          regencyId: 5103,
          regency: 'Kab. Badung',
        );
      });
      await tester.pumpAndSettle();

      expect(mockRepository.getDistrictsCalls.contains((51, 5103)), isTrue);
      expect(find.text('Kab. Badung'), findsOneWidget);
    },
  );

  testWidgets(
    'didUpdateWidget triggers cascading fetch when districtId changes externally',
    (tester) async {
      CreateLocationInput location = const CreateLocationInput(
        provinceId: 51,
        province: 'Bali',
        regencyId: 5103,
        regency: 'Kab. Badung',
      );

      late void Function(void Function()) parentSetState;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            parentSetState = setState;
            return MaterialApp(
              home: Scaffold(
                body: SingleChildScrollView(
                  child: RegionPicker(item: location, onChanged: (_) {}),
                ),
              ),
            );
          },
        ),
      );
      await tester.pumpAndSettle();

      expect(mockRepository.getVillagesCalls, isEmpty);

      parentSetState(() {
        location = const CreateLocationInput(
          provinceId: 51,
          province: 'Bali',
          regencyId: 5103,
          regency: 'Kab. Badung',
          districtId: 5103020,
          district: 'Kuta',
        );
      });
      await tester.pumpAndSettle();

      expect(
        mockRepository.getVillagesCalls.contains((51, 5103, 5103020)),
        isTrue,
      );
      expect(find.text('Kuta'), findsOneWidget);
    },
  );

  testWidgets('dropdowns show disabled hints when parents are not selected', (
    tester,
  ) async {
    const location = CreateLocationInput();

    await tester.pumpWidget(createWidget(item: location, onChanged: (_) {}));
    await tester.pumpAndSettle();

    expect(find.text('Pilih provinsi terlebih dahulu'), findsOneWidget);
    expect(find.text('Pilih kabupaten/kota terlebih dahulu'), findsOneWidget);
    expect(find.text('Pilih kecamatan terlebih dahulu'), findsOneWidget);

    // Verify all dependent dropdowns are disabled
    final regencyField = tester.widget<DropdownButtonFormField<int>>(
      find.byType(DropdownButtonFormField<int>).at(1),
    );
    final districtField = tester.widget<DropdownButtonFormField<int>>(
      find.byType(DropdownButtonFormField<int>).at(2),
    );
    final villageField = tester.widget<DropdownButtonFormField<int>>(
      find.byType(DropdownButtonFormField<int>).at(3),
    );

    expect(regencyField.onChanged, isNull);
    expect(districtField.onChanged, isNull);
    expect(villageField.onChanged, isNull);
  });

  testWidgets(
    'auto-resolves missing region IDs from addressLine when loading options',
    (tester) async {
      mockRepository.regencies = [
        const Regency(id: 5171, name: 'KOTA DENPASAR'),
        const Regency(id: 5103, name: 'KABUPATEN BADUNG'),
      ];
      mockRepository.districts = [
        const District(id: 5171010, name: 'Denpasar Utara'),
      ];
      mockRepository.villages = [
        const Village(id: 5171010001, name: 'Dangin Puri Kangin'),
      ];

      const location = CreateLocationInput(
        provinceId: 51,
        province: 'BALI',
        address:
            'SMA Negeri 1 Denpasar, Jalan Kamboja, Dangin Puri Kangin, Denpasar Utara, Denpasar, Bali, 80233',
      );

      CreateLocationInput? updated;
      await tester.pumpWidget(
        createWidget(item: location, onChanged: (loc) => updated = loc),
      );
      await tester.pumpAndSettle();

      expect(find.text('Bali'), findsOneWidget);
      expect(find.text('KOTA DENPASAR'), findsOneWidget);
      expect(find.text('Denpasar Utara'), findsOneWidget);
      expect(find.text('Dangin Puri Kangin'), findsOneWidget);

      expect(updated, isNotNull);
      expect(updated?.regencyId, 5171);
      expect(updated?.districtId, 5171010);
      expect(updated?.villageId, 5171010001);
    },
  );
}
