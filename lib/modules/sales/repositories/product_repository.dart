import 'package:dio/dio.dart';
import 'package:centrow_sales/shared/error/failure.dart';
import 'package:centrow_sales/shared/network/dio_client.dart';
import 'package:centrow_sales/shared/result/result.dart';
import 'package:centrow_sales/modules/sales/entities/product.dart';
import 'dtos/product_dto.dart';

abstract class ProductRepository {
  Future<Result<List<Product>>> getProducts({String? q, int? kind});
}

class ProductRepositoryImpl implements ProductRepository {
  final Dio _dio;

  ProductRepositoryImpl(this._dio);

  Dio get dio => _dio;

  @override
  Future<Result<List<Product>>> getProducts({String? q, int? kind}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (q != null && q.trim().isNotEmpty) {
        queryParams['q'] = q.trim();
      }
      if (kind != null) {
        queryParams['kind'] = kind;
      }

      final response = await _dio.get<dynamic>(
        '/v1/products',
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

      final products = items
          .map(
            (item) => ProductDto.fromJson(
              (item as Map).cast<String, dynamic>(),
            ).toEntity(requestedKind: kind),
          )
          .toList();

      return Ok(products);
    } on DioException catch (e) {
      return Err(_mapDioError(e));
    } catch (e) {
      return Err(UnknownFailure(e.toString()));
    }
  }

  Failure _mapDioError(DioException e) {
    final statusCode = e.response?.statusCode;
    final dynamic data = e.response?.data;
    String? message;

    if (data is Map) {
      message = (data['message'] ?? data['error'])?.toString();
    } else if (data is String && data.isNotEmpty) {
      message = data;
    }

    if (statusCode == 400) {
      return ServerFailure(message ?? 'Permintaan tidak valid.', 400);
    } else if (statusCode == 404) {
      return ServerFailure(message ?? 'Data produk tidak ditemukan.', 404);
    } else if (statusCode == 500) {
      return ServerFailure(message ?? 'Terjadi kesalahan pada server.', 500);
    }

    return mapDioException(e);
  }
}
