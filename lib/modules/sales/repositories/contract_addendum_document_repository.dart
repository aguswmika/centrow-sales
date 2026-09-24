import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:centrow_sales/shared/error/failure.dart';
import 'package:centrow_sales/shared/network/dio_client.dart';
import 'package:centrow_sales/shared/result/result.dart';
import 'package:centrow_sales/modules/sales/entities/addendum_template.dart';
import 'package:centrow_sales/modules/sales/entities/contract_addendum_document.dart';
import 'package:centrow_sales/modules/sales/repositories/dtos/addendum_template_dto.dart';
import 'package:centrow_sales/modules/sales/repositories/dtos/contract_addendum_document_dto.dart';

abstract interface class ContractAddendumDocumentRepository {
  Future<Result<List<AddendumTemplate>>> getActiveTemplates();
  Future<Result<ContractAddendumDocument>> getDocument(
    String addendumId, {
    String? templateId,
  });
  Future<Result<ContractAddendumDocument>> saveDocument(
    String addendumId, {
    required Map<String, dynamic> content,
    String? templateId,
  });
  Future<Result<List<int>>> downloadPdf(
    String addendumId, {
    String? templateId,
  });
}

class ContractAddendumDocumentRepositoryImpl
    implements ContractAddendumDocumentRepository {
  final Dio _dio;

  ContractAddendumDocumentRepositoryImpl(this._dio);

  Dio get dio => _dio;

  @override
  Future<Result<List<AddendumTemplate>>> getActiveTemplates() async {
    try {
      final response = await _dio.get<dynamic>(
        '/v1/sales/addendum-templates/active',
      );

      final responseData = response.data;
      final List<dynamic> items;
      if (responseData is List) {
        items = responseData;
      } else if (responseData is Map) {
        final data = responseData['data'];
        if (data is List) {
          items = data;
        } else if (data is Map && data['items'] is List) {
          items = data['items'] as List<dynamic>;
        } else if (responseData['items'] is List) {
          items = responseData['items'] as List<dynamic>;
        } else {
          return const Err(
            ServerFailure('Format respon dari server tidak valid.'),
          );
        }
      } else {
        return const Err(
          ServerFailure('Format respon dari server tidak valid.'),
        );
      }

      final templates = items
          .map(
            (item) => AddendumTemplateDto.fromJson(
              (item as Map).cast<String, dynamic>(),
            ).toEntity(),
          )
          .toList();

      return Ok(templates);
    } on DioException catch (e) {
      return Err(_handleDioError(e));
    } catch (e) {
      return Err(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<ContractAddendumDocument>> getDocument(
    String addendumId, {
    String? templateId,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        if (templateId != null && templateId.isNotEmpty)
          'template_id': templateId,
      };

      final res = await _dio.get<dynamic>(
        '/v1/sales/contract-addendums/$addendumId/document',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      final responseData = res.data;
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

      final dto = ContractAddendumDocumentDto.fromJson(dataMap);
      return Ok(dto.toEntity());
    } on DioException catch (e) {
      return Err(_handleDioError(e));
    } catch (e) {
      return Err(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<ContractAddendumDocument>> saveDocument(
    String addendumId, {
    required Map<String, dynamic> content,
    String? templateId,
  }) async {
    try {
      final payload = <String, dynamic>{
        'content': content,
        if (templateId != null && templateId.isNotEmpty)
          'template_id': templateId,
      };

      final res = await _dio.put<dynamic>(
        '/v1/sales/contract-addendums/$addendumId/document',
        data: payload,
      );

      final responseData = res.data;
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

      final dto = ContractAddendumDocumentDto.fromJson(dataMap);
      return Ok(dto.toEntity());
    } on DioException catch (e) {
      return Err(_handleDioError(e));
    } catch (e) {
      return Err(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<int>>> downloadPdf(
    String addendumId, {
    String? templateId,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        if (templateId != null && templateId.isNotEmpty)
          'template_id': templateId,
      };

      final res = await _dio.get<dynamic>(
        '/v1/sales/contract-addendums/$addendumId/document/pdf',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
        options: Options(responseType: ResponseType.bytes),
      );

      final raw = res.data;
      if (raw == null) {
        return const Err(ServerFailure('File PDF kosong atau tidak valid.'));
      }

      final List<int> bytes;
      if (raw is List) {
        bytes = List<int>.from(raw);
      } else {
        return const Err(ServerFailure('File PDF kosong atau tidak valid.'));
      }

      if (bytes.isEmpty) {
        return const Err(ServerFailure('File PDF kosong atau tidak valid.'));
      }

      return Ok(bytes);
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map && data['message'] != null) {
        return Err(
          ServerFailure(data['message'] as String, e.response?.statusCode),
        );
      }
      if (data is List<int>) {
        try {
          final jsonStr = String.fromCharCodes(data);
          final decoded = jsonDecode(jsonStr) as Map<String, dynamic>?;
          if (decoded?['message'] != null) {
            return Err(
              ServerFailure(
                decoded!['message'] as String,
                e.response?.statusCode,
              ),
            );
          }
        } catch (_) {}
      }
      return Err(mapDioException(e));
    } catch (e) {
      return Err(UnknownFailure(e.toString()));
    }
  }

  Failure _handleDioError(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['message'] != null) {
      return ServerFailure(data['message'] as String, e.response?.statusCode);
    }
    return mapDioException(e);
  }
}
