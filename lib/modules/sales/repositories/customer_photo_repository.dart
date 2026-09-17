import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:centrow_sales/shared/error/failure.dart';
import 'package:centrow_sales/shared/network/dio_client.dart';
import 'package:centrow_sales/shared/result/result.dart';
import 'package:centrow_sales/modules/sales/entities/customer_photo.dart';
import 'package:centrow_sales/modules/sales/repositories/dtos/customer_photo_dto.dart';

abstract interface class CustomerPhotoRepository {
  Future<Result<List<CustomerPhoto>>> getPhotos(String customerId);

  Future<Result<CustomerPhoto>> uploadPhoto(String customerId, String filePath);

  Future<Result<void>> deletePhoto(String customerId, String photoId);
}

class CustomerPhotoRepositoryImpl implements CustomerPhotoRepository {
  final Dio _dio;

  CustomerPhotoRepositoryImpl(this._dio);

  Dio get dio => _dio;

  @override
  Future<Result<List<CustomerPhoto>>> getPhotos(String customerId) async {
    try {
      final response = await _dio.get<dynamic>(
        '/v1/sales/customers/$customerId/photos',
      );

      final responseData = response.data;
      final Map<String, dynamic> dataMap;

      if (responseData is Map) {
        if (responseData['data'] is Map) {
          dataMap = (responseData['data'] as Map).cast<String, dynamic>();
        } else {
          dataMap = responseData.cast<String, dynamic>();
        }
      } else {
        return const Err(
          ServerFailure('Format respon dari server tidak valid.'),
        );
      }

      final listResponseDto = CustomerPhotoListResponseDto.fromJson(dataMap);
      final photos = listResponseDto.items.map((e) => e.toEntity()).toList();
      return Ok(photos);
    } on DioException catch (e) {
      return Err(_handleDioError(e));
    } catch (e) {
      return Err(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<CustomerPhoto>> uploadPhoto(
    String customerId,
    String filePath,
  ) async {
    try {
      final compressedPath = await _compressPhoto(filePath);
      final filename = compressedPath.split('/').last;
      final formData = FormData.fromMap({
        'photo': await MultipartFile.fromFile(
          compressedPath,
          filename: filename,
        ),
      });

      final response = await _dio.post<dynamic>(
        '/v1/sales/customers/$customerId/photos',
        data: formData,
      );

      final responseData = response.data;
      final Map<String, dynamic> dataMap;

      if (responseData is Map) {
        if (responseData['data'] is Map) {
          dataMap = (responseData['data'] as Map).cast<String, dynamic>();
        } else {
          dataMap = responseData.cast<String, dynamic>();
        }
      } else {
        return const Err(
          ServerFailure('Format respon dari server tidak valid.'),
        );
      }

      final photoDto = CustomerPhotoDto.fromJson(dataMap);
      return Ok(photoDto.toEntity());
    } on DioException catch (e) {
      return Err(_handleDioError(e));
    } catch (e) {
      return Err(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> deletePhoto(String customerId, String photoId) async {
    try {
      await _dio.delete<dynamic>(
        '/v1/sales/customers/$customerId/photos/$photoId',
      );
      return const Ok(null);
    } on DioException catch (e) {
      return Err(_handleDioError(e));
    } catch (e) {
      return Err(UnknownFailure(e.toString()));
    }
  }

  Future<String> _compressPhoto(String filePath) async {
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
    } else if (statusCode == 403) {
      return ServerFailure(
        message ?? 'Anda tidak memiliki izin untuk mengakses resource ini.',
        403,
      );
    } else if (statusCode == 404) {
      return ServerFailure(message ?? 'Data tidak ditemukan.', 404);
    }

    return mapDioException(e);
  }
}
