import 'package:dio/dio.dart';
import 'package:centrow_sales/shared/error/failure.dart';
import 'package:centrow_sales/shared/network/dio_client.dart';
import 'package:centrow_sales/shared/result/result.dart';
import 'package:centrow_sales/modules/pc/entities/treatment_method.dart';
import 'dtos/treatment_method_dto.dart';

abstract interface class TreatmentMethodRepository {
  Future<Result<List<TreatmentMethod>>> getTreatmentMethods();
}

class TreatmentMethodRepositoryImpl implements TreatmentMethodRepository {
  final Dio _dio;

  TreatmentMethodRepositoryImpl(this._dio);

  Dio get dio => _dio;

  @override
  Future<Result<List<TreatmentMethod>>> getTreatmentMethods() async {
    try {
      final response = await _dio.get<dynamic>('/v1/pc/treatment-methods');

      final responseData = response.data;
      List<dynamic> items = [];
      if (responseData is List) {
        items = responseData;
      } else if (responseData is Map) {
        final dataField = responseData['data'];
        if (dataField is List) {
          items = dataField;
        } else if (dataField is Map && dataField['items'] is List) {
          items = dataField['items'] as List<dynamic>;
        } else if (responseData['items'] is List) {
          items = responseData['items'] as List<dynamic>;
        }
      }

      final methods = items
          .map(
            (item) => TreatmentMethodDto.fromJson(
              (item as Map).cast<String, dynamic>(),
            ).toEntity(),
          )
          .toList();

      return Ok(methods);
    } on DioException catch (e) {
      return Err(mapDioException(e));
    } catch (e) {
      return Err(UnknownFailure(e.toString()));
    }
  }
}
