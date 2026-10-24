import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:centrow_sales/shared/error/failure.dart';
import 'package:centrow_sales/shared/network/dio_client.dart';
import 'package:centrow_sales/shared/result/result.dart';
import 'package:centrow_sales/modules/sales/entities/richtext_image.dart';
import 'package:centrow_sales/modules/sales/repositories/dtos/richtext_image_dto.dart';

abstract interface class RichtextImageRepository {
  Future<Result<RichtextImagePage>> getImages({
    String? keyword,
    int page = 1,
    int pageSize = 30,
  });

  Future<Result<RichtextImage>> uploadImage(String filePath);

  Future<Result<void>> deleteImage(String imageId);
}

class RichtextImageRepositoryImpl implements RichtextImageRepository {
  final Dio _dio;

  RichtextImageRepositoryImpl(this._dio);

  Dio get dio => _dio;

  @override
  Future<Result<RichtextImagePage>> getImages({
    String? keyword,
    int page = 1,
    int pageSize = 30,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'page_size': pageSize,
      };
      if (keyword != null && keyword.trim().isNotEmpty) {
        queryParams['keyword'] = keyword.trim();
      }
      final response = await _dio.get<dynamic>(
        '/v1/core/richtext-images',
        queryParameters: queryParams,
      );

      final dataMap = _extractDataMap(response.data);
      if (dataMap == null) {
        return const Err(
          ServerFailure('Format respon dari server tidak valid.'),
        );
      }

      final dto = RichtextImageListResponseDto.fromJson(dataMap);
      return Ok(
        RichtextImagePage(
          items: dto.items.map((e) => e.toEntity()).toList(),
          total: dto.total,
        ),
      );
    } on DioException catch (e) {
      return Err(_handleDioError(e));
    } catch (e) {
      return Err(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<RichtextImage>> uploadImage(String filePath) async {
    try {
      final compressedPath = await _compressImage(filePath);
      final filename = compressedPath.split('/').last;
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          compressedPath,
          filename: filename,
        ),
      });

      final response = await _dio.post<dynamic>(
        '/v1/core/richtext-images',
        data: formData,
      );

      final dataMap = _extractDataMap(response.data);
      if (dataMap == null) {
        return const Err(
          ServerFailure('Format respon dari server tidak valid.'),
        );
      }

      return Ok(RichtextImageDto.fromJson(dataMap).toEntity());
    } on DioException catch (e) {
      return Err(_handleDioError(e));
    } catch (e) {
      return Err(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteImage(String imageId) async {
    try {
      await _dio.delete<dynamic>('/v1/core/richtext-images/$imageId');
      return const Ok(null);
    } on DioException catch (e) {
      return Err(_handleDioError(e));
    } catch (e) {
      return Err(UnknownFailure(e.toString()));
    }
  }

  Map<String, dynamic>? _extractDataMap(dynamic responseData) {
    if (responseData is! Map) return null;
    if (responseData['data'] is Map) {
      return (responseData['data'] as Map).cast<String, dynamic>();
    }
    return responseData.cast<String, dynamic>();
  }

  Future<String> _compressImage(String filePath) async {
    try {
      final dir = File(filePath).parent.path;
      final targetPath =
          '$dir/${DateTime.now().millisecondsSinceEpoch}_compressed.jpg';
      final compressed = await FlutterImageCompress.compressAndGetFile(
        filePath,
        targetPath,
        quality: 70,
        minWidth: 1280,
        minHeight: 1280,
        format: CompressFormat.jpeg,
      );
      return compressed?.path ?? filePath;
    } catch (_) {
      return filePath;
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
    } else if (statusCode == 404) {
      return ServerFailure(message ?? 'Data tidak ditemukan.', 404);
    }

    return mapDioException(e);
  }
}
