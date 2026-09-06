import 'package:dio/dio.dart';
import 'package:centrow_sales/shared/error/failure.dart';
import 'package:centrow_sales/shared/network/dio_client.dart';
import 'package:centrow_sales/shared/result/result.dart';
import 'package:centrow_sales/modules/sales/entities/contract_category.dart';
import 'package:centrow_sales/modules/sales/repositories/dtos/contract_category_dto.dart';

abstract interface class ContractCategoryRepository {
  Future<Result<List<ContractCategory>>> getContractCategories({String? query});
}

class ContractCategoryRepositoryImpl implements ContractCategoryRepository {
  final Dio _dio;
  ContractCategoryRepositoryImpl(this._dio);

  @override
  Future<Result<List<ContractCategory>>> getContractCategories({
    String? query,
  }) async {
    try {
      final params = <String, dynamic>{'page_size': 100};
      if (query != null && query.trim().isNotEmpty) params['q'] = query.trim();

      final response = await _dio.get<dynamic>(
        '/v1/sales/contract-categories',
        queryParameters: params,
      );

      final raw = response.data;
      final dataField = (raw is Map) ? raw['data'] : null;
      final itemsList = (dataField is Map) ? dataField['items'] : null;

      if (itemsList is! List) {
        return const Err(
          ServerFailure('Format respon dari server tidak valid.'),
        );
      }

      final categories = itemsList
          .map(
            (e) => ContractCategoryDto.fromJson(
              (e as Map).cast<String, dynamic>(),
            ),
          )
          .map((dto) => dto.toEntity())
          .toList();
      return Ok(categories);
    } on DioException catch (e) {
      return Err(mapDioException(e));
    } catch (e) {
      return Err(UnknownFailure(e.toString()));
    }
  }
}
