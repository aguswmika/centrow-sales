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

  @override
  Future<Result<List<Province>>> getProvinces() async {
    getProvincesCallCount++;
    return Ok(provinces);
  }

  @override
  Future<Result<List<Regency>>> getRegencies(int provinceId) async {
    getRegenciesCalls.add(provinceId);
    return Ok(regencies);
  }

  @override
  Future<Result<List<District>>> getDistricts(
    int provinceId,
    int regencyId,
  ) async {
    getDistrictsCalls.add((provinceId, regencyId));
    return Ok(districts);
  }

  @override
  Future<Result<List<Village>>> getVillages(
    int provinceId,
    int regencyId,
    int districtId,
  ) async {
    getVillagesCalls.add((provinceId, regencyId, districtId));
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
          child: RegionPicker(
            item: item,
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }

  testWidgets('fetches provinces on initState when item is empty', (
    tester,
  ) async {
    CreateLocationInput location = const CreateLocationInput();

    await tester.pumpWidget(
      createWidget(
        item: location,
        onChanged: (val) => location = val,
      ),
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

    await tester.pumpWidget(
      createWidget(
        item: location,
        onChanged: (_) {},
      ),
    );
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

  testWidgets('changing Regency resets district & village and fetches Districts', (
    tester,
  ) async {
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
  });

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

    expect(mockRepository.getVillagesCalls.contains((51, 5103, 5103020)), isTrue);
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

  testWidgets('didUpdateWidget triggers cascading fetch when provinceId changes externally', (
    tester,
  ) async {
    CreateLocationInput location = const CreateLocationInput();

    late void Function(void Function()) parentSetState;

    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, setState) {
          parentSetState = setState;
          return MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: RegionPicker(
                  item: location,
                  onChanged: (_) {},
                ),
              ),
            ),
          );
        },
      ),
    );
    await tester.pumpAndSettle();

    expect(mockRepository.getRegenciesCalls, isEmpty);

    parentSetState(() {
      location = const CreateLocationInput(
        provinceId: 51,
        province: 'Bali',
      );
    });
    await tester.pumpAndSettle();

    expect(mockRepository.getRegenciesCalls, [51]);
  });
}
