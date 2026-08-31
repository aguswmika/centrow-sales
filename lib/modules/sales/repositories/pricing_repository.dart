import 'package:dio/dio.dart';
import 'package:centrow_sales/shared/result/result.dart';
import 'package:centrow_sales/shared/error/failure.dart';
import 'package:centrow_sales/shared/network/dio_client.dart';
import 'package:centrow_sales/modules/sales/entities/pricing_preview.dart';
import 'dtos/pricing_preview_dto.dart';
import 'dtos/pricing_dto.dart';

abstract class PricingRepository {
  Future<Result<void>> savePricing(CreatePricingRequestDto data);
  Future<Result<PricingPreview>> previewPricing(CreatePricingRequestDto data);
}

class PricingRepositoryImpl implements PricingRepository {
  final Dio _dio;

  PricingRepositoryImpl(this._dio);

  @override
  Future<Result<void>> savePricing(CreatePricingRequestDto data) async {
    try {
      await _dio.post<dynamic>('/v1/sales/pricings', data: data.toJson());
      return const Ok(null);
    } on DioException catch (e) {
      return Err(mapDioException(e));
    } catch (e) {
      return Err(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<PricingPreview>> previewPricing(
    CreatePricingRequestDto data,
  ) async {
    try {
      final response = await _dio.post<dynamic>(
        '/v1/sales/pricings/preview',
        data: data.toJson(),
      );
      final responseData = response.data;
      if (responseData is! Map || responseData['data'] is! Map) {
        return const Err(ServerFailure('Format respon preview tidak valid.'));
      }
      final dataMap = (responseData['data'] as Map).cast<String, dynamic>();
      return Ok(PricingPreviewDto.fromJson(dataMap).toEntity());
    } on DioException catch (e) {
      return Err(mapDioException(e));
    } catch (e) {
      return Err(UnknownFailure(e.toString()));
    }
  }
}
