import 'package:dio/dio.dart';
import 'package:centrow_sales/modules/sales/entities/service.dart';
import 'package:centrow_sales/shared/network/dio_client.dart';
import 'package:centrow_sales/shared/result/result.dart';
import 'package:centrow_sales/shared/error/failure.dart';

abstract interface class ServiceRepository {
  Future<Result<List<Service>>> getServices({String? query});
}

class ServiceRepositoryImpl implements ServiceRepository {
  final Dio _dio;

  ServiceRepositoryImpl(this._dio);

  @override
  Future<Result<List<Service>>> getServices({String? query}) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/v1/services',
        queryParameters: query != null ? {'q': query} : null,
      );

      final responseData = response.data ?? {};
      final dataField = responseData['data'];

      List<dynamic> items = [];
      if (dataField is List) {
        items = dataField;
      } else if (dataField is Map && dataField['items'] is List) {
        items = dataField['items'] as List<dynamic>;
      } else if (responseData['items'] is List) {
        items = responseData['items'] as List<dynamic>;
      }

      final services = items
          .map((item) => Service.fromJson(item as Map<String, dynamic>))
          .toList();

      return Ok(services);
    } on DioException catch (e) {
      return Err(mapDioException(e));
    } catch (e) {
      return Err(UnknownFailure(e.toString()));
    }
  }
}
