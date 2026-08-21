import 'package:dio/dio.dart';
import '../../../shared/error/failure.dart';
import '../../../shared/network/dio_client.dart';
import '../../../shared/result/result.dart';
import '../entities/region.dart';
import 'dtos/region_dto.dart';

abstract interface class RegionRepository {
  Future<Result<List<Province>>> getProvinces();
  Future<Result<List<Regency>>> getRegencies(int provinceId);
  Future<Result<List<District>>> getDistricts(int provinceId, int regencyId);
  Future<Result<List<Village>>> getVillages(
    int provinceId,
    int regencyId,
    int districtId,
  );
}

class RegionRepositoryImpl implements RegionRepository {
  final Dio _dio;

  RegionRepositoryImpl(this._dio);

  Dio get dio => _dio;

  @override
  Future<Result<List<Province>>> getProvinces() async {
    try {
      final response = await _dio.get<dynamic>('/v1/provinces');
      final responseData = response.data;
      final RegionListResponseDto dtoList;

      if (responseData is Map<String, dynamic>) {
        dtoList = RegionListResponseDto.fromJson(responseData);
      } else if (responseData is Map) {
        dtoList = RegionListResponseDto.fromJson(
          responseData.cast<String, dynamic>(),
        );
      } else if (responseData is List) {
        dtoList = RegionListResponseDto.fromList(responseData);
      } else {
        return const Err(
          ServerFailure('Format respon dari server tidak valid.'),
        );
      }

      return Ok(dtoList.toProvinces());
    } on DioException catch (e) {
      return Err(_handleDioError(e));
    } catch (e) {
      return Err(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<Regency>>> getRegencies(int provinceId) async {
    try {
      final response = await _dio.get<dynamic>(
        '/v1/regencies',
        queryParameters: <String, dynamic>{
          'province_id': provinceId,
        },
      );
      final responseData = response.data;
      final RegionListResponseDto dtoList;

      if (responseData is Map<String, dynamic>) {
        dtoList = RegionListResponseDto.fromJson(responseData);
      } else if (responseData is Map) {
        dtoList = RegionListResponseDto.fromJson(
          responseData.cast<String, dynamic>(),
        );
      } else if (responseData is List) {
        dtoList = RegionListResponseDto.fromList(responseData);
      } else {
        return const Err(
          ServerFailure('Format respon dari server tidak valid.'),
        );
      }

      return Ok(dtoList.toRegencies());
    } on DioException catch (e) {
      return Err(_handleDioError(e));
    } catch (e) {
      return Err(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<District>>> getDistricts(
    int provinceId,
    int regencyId,
  ) async {
    try {
      final response = await _dio.get<dynamic>(
        '/v1/districts',
        queryParameters: <String, dynamic>{
          'province_id': provinceId,
          'regency_id': regencyId,
        },
      );
      final responseData = response.data;
      final RegionListResponseDto dtoList;

      if (responseData is Map<String, dynamic>) {
        dtoList = RegionListResponseDto.fromJson(responseData);
      } else if (responseData is Map) {
        dtoList = RegionListResponseDto.fromJson(
          responseData.cast<String, dynamic>(),
        );
      } else if (responseData is List) {
        dtoList = RegionListResponseDto.fromList(responseData);
      } else {
        return const Err(
          ServerFailure('Format respon dari server tidak valid.'),
        );
      }

      return Ok(dtoList.toDistricts());
    } on DioException catch (e) {
      return Err(_handleDioError(e));
    } catch (e) {
      return Err(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<Village>>> getVillages(
    int provinceId,
    int regencyId,
    int districtId,
  ) async {
    try {
      final response = await _dio.get<dynamic>(
        '/v1/villages',
        queryParameters: <String, dynamic>{
          'province_id': provinceId,
          'regency_id': regencyId,
          'district_id': districtId,
        },
      );
      final responseData = response.data;
      final RegionListResponseDto dtoList;

      if (responseData is Map<String, dynamic>) {
        dtoList = RegionListResponseDto.fromJson(responseData);
      } else if (responseData is Map) {
        dtoList = RegionListResponseDto.fromJson(
          responseData.cast<String, dynamic>(),
        );
      } else if (responseData is List) {
        dtoList = RegionListResponseDto.fromList(responseData);
      } else {
        return const Err(
          ServerFailure('Format respon dari server tidak valid.'),
        );
      }

      return Ok(dtoList.toVillages());
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
    } else if (statusCode == 404) {
      return ServerFailure(message ?? 'Data wilayah tidak ditemukan.', 404);
    } else if (statusCode == 500) {
      return ServerFailure(message ?? 'Terjadi kesalahan pada server.', 500);
    }

    return mapDioException(e);
  }
}
