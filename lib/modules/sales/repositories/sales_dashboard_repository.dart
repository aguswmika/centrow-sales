import 'package:dio/dio.dart';
import '../../../shared/error/failure.dart';
import '../../../shared/network/dio_client.dart';
import '../../../shared/result/result.dart';
import '../entities/sales_dashboard.dart';
import 'dtos/sales_dashboard_dto.dart';

abstract interface class SalesDashboardRepository {
  Future<Result<SalesDashboardSummary>> getDashboardSummary();
}

class SalesDashboardRepositoryImpl implements SalesDashboardRepository {
  final Dio _dio;

  SalesDashboardRepositoryImpl(this._dio);

  @override
  Future<Result<SalesDashboardSummary>> getDashboardSummary() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/v1/sales/dashboard',
      );

      final dynamic responseData = response.data;
      final Map<String, dynamic> dataJson;

      if (responseData is Map<String, dynamic>) {
        if (responseData['data'] is Map<String, dynamic>) {
          dataJson = responseData['data'] as Map<String, dynamic>;
        } else {
          dataJson = responseData;
        }
      } else {
        return const Err(
          ServerFailure('Format respon dari server tidak valid.'),
        );
      }

      final dto = SalesDashboardSummaryDto.fromJson(dataJson);
      return Ok(dto.toEntity());
    } on DioException catch (e) {
      return Err(mapDioException(e));
    } catch (e) {
      return Err(UnknownFailure(e.toString()));
    }
  }
}
