import 'package:dio/dio.dart';
import 'package:centrow_sales/shared/result/result.dart';
import 'package:centrow_sales/shared/error/failure.dart';
import 'dtos/pricing_dto.dart';

abstract class PricingRepository {
  Future<Result<void>> savePricing(CreatePricingRequestDto data);
}

class PricingRepositoryImpl implements PricingRepository {
  final Dio _dio;

  PricingRepositoryImpl(this._dio);

  @override
  Future<Result<void>> savePricing(CreatePricingRequestDto data) async {
    try {
      await _dio.post<dynamic>('/sales/pricings', data: data.toJson());
      return const Ok(null);
    } on DioException catch (e) {
      return Err(ServerFailure(e.message ?? 'Error'));
    } catch (e) {
      return Err(UnknownFailure(e.toString()));
    }
  }
}
