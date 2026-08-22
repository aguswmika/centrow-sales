import 'package:centrow_sales/modules/sales/entities/service.dart';
import 'package:centrow_sales/shared/result/result.dart';

abstract interface class ServiceRepository {
  Future<Result<List<Service>>> getServices({String? query});
}

class MockServiceRepositoryImpl implements ServiceRepository {
  static const List<Service> _mockServices = [
    Service(id: 'svc-1', code: 'TERMITE-01', name: 'Termite Protection Plan'),
    Service(
      id: 'svc-2',
      code: 'PEST-COM',
      name: 'Pest Control Full Commercial',
    ),
    Service(
      id: 'svc-3',
      code: 'DISINFECT',
      name: 'Disinfection & Sanitasi Ruang',
    ),
    Service(
      id: 'svc-4',
      code: 'RODENT',
      name: 'Rodent & Fly Integrated Control',
    ),
  ];

  @override
  Future<Result<List<Service>>> getServices({String? query}) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (query == null || query.isEmpty) {
      return const Ok(_mockServices);
    }
    final q = query.toLowerCase();
    final results = _mockServices
        .where(
          (s) =>
              s.name.toLowerCase().contains(q) ||
              s.code.toLowerCase().contains(q),
        )
        .toList();
    return Ok(results);
  }
}
