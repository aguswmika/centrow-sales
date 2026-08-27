import 'package:dio/dio.dart';
import 'package:centrow_sales/shared/error/failure.dart';
import 'package:centrow_sales/shared/network/dio_client.dart';
import 'package:centrow_sales/shared/result/result.dart';
import 'package:centrow_sales/modules/pc/entities/product_mapping.dart';
import 'dtos/product_mapping_dto.dart';

abstract interface class ProductMappingRepository {
  Future<Result<List<ProductMapping>>> getProductMappings({
    String? treatmentMethodId,
    String? keyword,
  });
}

class ProductMappingRepositoryImpl implements ProductMappingRepository {
  final Dio _dio;

  ProductMappingRepositoryImpl(this._dio);

  Dio get dio => _dio;

  @override
  Future<Result<List<ProductMapping>>> getProductMappings({
    String? treatmentMethodId,
    String? keyword,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (treatmentMethodId != null && treatmentMethodId.trim().isNotEmpty) {
        queryParams['treatment_method_id'] = treatmentMethodId.trim();
      }
      if (keyword != null && keyword.trim().isNotEmpty) {
        queryParams['keyword'] = keyword.trim();
      }

      final response = await _dio.get<dynamic>(
        '/v1/pc/product-mappings',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

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

      final mappings = items
          .map(
            (item) => ProductMappingDto.fromJson(
              (item as Map).cast<String, dynamic>(),
            ).toEntity(),
          )
          .toList();

      return Ok(mappings);
    } on DioException catch (e) {
      return Err(mapDioException(e));
    } catch (e) {
      return Err(UnknownFailure(e.toString()));
    }
  }
}
