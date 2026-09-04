import 'package:dio/dio.dart';
import 'package:centrow_sales/shared/result/result.dart';
import 'package:centrow_sales/shared/error/failure.dart';
import 'package:centrow_sales/shared/network/dio_client.dart';
import 'package:centrow_sales/modules/sales/entities/pricing_detail.dart';
import 'package:centrow_sales/modules/sales/entities/pricing_preview.dart';
import 'dtos/pricing_preview_dto.dart';
import 'dtos/pricing_dto.dart';
import 'dtos/pricing_detail_dto.dart';

abstract class PricingRepository {
  Future<Result<void>> savePricing(
    String proposalId,
    CreatePricingRequestDto data,
  );
  Future<Result<PricingPreview>> previewPricing(
    String proposalId,
    CreatePricingRequestDto data,
  );
  Future<Result<PricingDetail>> getPricingDetail(String proposalId);
}

class PricingRepositoryImpl implements PricingRepository {
  final Dio _dio;

  PricingRepositoryImpl(this._dio);

  @override
  Future<Result<void>> savePricing(
    String proposalId,
    CreatePricingRequestDto data,
  ) async {
    try {
      await _dio.post<dynamic>(
        '/v1/sales/proposals/$proposalId/pricing',
        data: data.toJson(),
      );
      return const Ok(null);
    } on DioException catch (e) {
      return Err(mapDioException(e));
    } catch (e) {
      return Err(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<PricingPreview>> previewPricing(
    String proposalId,
    CreatePricingRequestDto data,
  ) async {
    try {
      final response = await _dio.post<dynamic>(
        '/v1/sales/proposals/$proposalId/pricing/preview',
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

  @override
  Future<Result<PricingDetail>> getPricingDetail(String proposalId) async {
    try {
      final response = await _dio.get<dynamic>(
        '/v1/sales/proposals/$proposalId/pricing',
      );
      final responseData = response.data;
      if (responseData is! Map || responseData['data'] is! Map) {
        return const Err(ServerFailure('Format respon kalkulasi tidak valid.'));
      }
      final dataMap = (responseData['data'] as Map).cast<String, dynamic>();
      return Ok(PricingDetailDto.fromJson(dataMap).toEntity());
    } on DioException catch (e) {
      return Err(mapDioException(e));
    } catch (e) {
      return Err(UnknownFailure(e.toString()));
    }
  }
}
