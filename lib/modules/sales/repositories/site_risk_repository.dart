import 'package:dio/dio.dart';
import 'package:centrow_sales/modules/sales/entities/site_risk.dart';
import 'package:centrow_sales/modules/sales/repositories/dtos/site_risk_dto.dart';
import 'package:centrow_sales/shared/error/failure.dart';
import 'package:centrow_sales/shared/network/dio_client.dart';
import 'package:centrow_sales/shared/result/result.dart';

abstract interface class SiteRiskRepository {
  Future<Result<List<SiteRiskMaster>>> getSiteRiskMasters();

  Future<Result<List<CustomerAddressRisk>>> getAddressRisks({
    required String customerId,
    required String addressId,
  });

  Future<Result<List<CustomerAddressRisk>>> updateAddressRisks({
    required String customerId,
    required String addressId,
    required List<String> siteRiskIds,
    required List<String> customRisks,
  });
}

extension SiteRiskRepositoryExt on SiteRiskRepository {
  Future<Result<List<SiteRiskMaster>>> getMasterRisks() => getSiteRiskMasters();
}

class SiteRiskRepositoryImpl implements SiteRiskRepository {
  final Dio _dio;

  SiteRiskRepositoryImpl(this._dio);

  Dio get dio => _dio;

  @override
  Future<Result<List<SiteRiskMaster>>> getSiteRiskMasters() async {
    try {
      final response = await _dio.get<dynamic>('/v1/sales/site-risks');

      final responseData = response.data;
      final Map<String, dynamic> dataMap;

      if (responseData is Map) {
        dataMap = responseData.cast<String, dynamic>();
      } else {
        return const Err(
          ServerFailure('Format respon dari server tidak valid.'),
        );
      }

      final listDto = SiteRiskMasterListResponseDto.fromJson(dataMap);
      final items = listDto.items.map((e) => e.toEntity()).toList();
      return Ok(items);
    } on DioException catch (e) {
      return Err(_handleDioError(e));
    } catch (e) {
      return Err(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<CustomerAddressRisk>>> getAddressRisks({
    required String customerId,
    required String addressId,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        '/v1/sales/customers/$customerId/addresses/$addressId/risks',
      );

      final responseData = response.data;
      final Map<String, dynamic> dataMap;

      if (responseData is Map) {
        dataMap = responseData.cast<String, dynamic>();
      } else {
        return const Err(
          ServerFailure('Format respon dari server tidak valid.'),
        );
      }

      final listDto = CustomerAddressRiskListResponseDto.fromJson(dataMap);
      final items = listDto.items.map((e) => e.toEntity()).toList();
      return Ok(items);
    } on DioException catch (e) {
      return Err(_handleDioError(e));
    } catch (e) {
      return Err(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<CustomerAddressRisk>>> updateAddressRisks({
    required String customerId,
    required String addressId,
    required List<String> siteRiskIds,
    required List<String> customRisks,
  }) async {
    try {
      final payload = UpdateAddressRisksPayload(
        siteRiskIds: siteRiskIds,
        customRisks: customRisks,
      );

      final response = await _dio.put<dynamic>(
        '/v1/sales/customers/$customerId/addresses/$addressId/risks',
        data: payload.toJson(),
      );

      final responseData = response.data;
      final Map<String, dynamic> dataMap;

      if (responseData is Map) {
        dataMap = responseData.cast<String, dynamic>();
      } else {
        return const Err(
          ServerFailure('Format respon dari server tidak valid.'),
        );
      }

      final listDto = CustomerAddressRiskListResponseDto.fromJson(dataMap);
      final items = listDto.items.map((e) => e.toEntity()).toList();
      return Ok(items);
    } on DioException catch (e) {
      return Err(_handleDioError(e));
    } catch (e) {
      return Err(UnknownFailure(e.toString()));
    }
  }

  Failure _handleDioError(DioException e) {
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
    } else if (statusCode == 401) {
      return ServerFailure(
        message ?? 'Anda harus login untuk mengakses resource ini.',
        401,
      );
    } else if (statusCode == 403) {
      return ServerFailure(
        message ?? 'Anda tidak memiliki izin untuk mengakses resource ini.',
        403,
      );
    } else if (statusCode == 404) {
      return ServerFailure(message ?? 'Data tidak ditemukan.', 404);
    } else if (statusCode == 500) {
      return ServerFailure(message ?? 'Terjadi kesalahan pada server.', 500);
    }

    return mapDioException(e);
  }
}
