import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:centrow_sales/shared/error/failure.dart';
import 'package:centrow_sales/shared/network/dio_client.dart';
import 'package:centrow_sales/shared/result/result.dart';
import 'package:centrow_sales/modules/sales/entities/contract_document.dart';
import 'package:centrow_sales/modules/sales/repositories/dtos/contract_document_dto.dart';

abstract interface class ContractDocumentRepository {
  Future<Result<ContractDocument>> getDocument(
    String contractId, {
    bool fromTemplate = false,
  });

  Future<Result<ContractDocument>> saveDocument(
    String contractId,
    Map<String, dynamic> content,
  );

  Future<Result<List<int>>> downloadPdf(String contractId);
}

class ContractDocumentRepositoryImpl implements ContractDocumentRepository {
  final Dio _dio;

  ContractDocumentRepositoryImpl(this._dio);

  Dio get dio => _dio;

  @override
  Future<Result<ContractDocument>> getDocument(
    String contractId, {
    bool fromTemplate = false,
  }) async {
    try {
      final res = await _dio.get<dynamic>(
        '/v1/sales/contracts/$contractId/document',
        queryParameters: fromTemplate ? {'from_template': true} : null,
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

      final dto = ContractDocumentDto.fromJson(dataMap);
      return Ok(dto.toEntity());
    } on DioException catch (e) {
      if (e.response?.statusCode == 400 &&
          e.response?.data is Map &&
          e.response?.data['message'] != null) {
        return Err(ServerFailure(e.response!.data['message'] as String));
      }
      return Err(mapDioException(e));
    } catch (e) {
      return Err(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<ContractDocument>> saveDocument(
    String contractId,
    Map<String, dynamic> content,
  ) async {
    try {
      final res = await _dio.put<dynamic>(
        '/v1/sales/contracts/$contractId/document',
        data: {'content': content},
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

      final dto = ContractDocumentDto.fromJson(dataMap);
      return Ok(dto.toEntity());
    } on DioException catch (e) {
      if (e.response?.data is Map && e.response?.data['message'] != null) {
        return Err(ServerFailure(e.response!.data['message'] as String));
      }
      return Err(mapDioException(e));
    } catch (e) {
      return Err(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<int>>> downloadPdf(String contractId) async {
    try {
      final res = await _dio.get<List<int>>(
        '/v1/sales/contracts/$contractId/document/pdf',
        options: Options(responseType: ResponseType.bytes),
      );
      final bytes = res.data;
      if (bytes == null || bytes.isEmpty) {
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
}
