import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:centrow_sales/shared/error/failure.dart';
import 'package:centrow_sales/shared/network/dio_client.dart';
import 'package:centrow_sales/shared/result/result.dart';
import 'package:centrow_sales/modules/sales/entities/proposal_document.dart';
import 'package:centrow_sales/modules/sales/repositories/dtos/proposal_document_dto.dart';

abstract interface class ProposalDocumentRepository {
  Future<Result<ProposalDocument>> getDocument(
    String proposalId, {
    bool fromTemplate = false,
  });

  Future<Result<ProposalDocument>> saveDocument(
    String proposalId,
    Map<String, dynamic> content,
  );

  Future<Result<List<int>>> downloadPdf(String proposalId);
}

class ProposalDocumentRepositoryImpl implements ProposalDocumentRepository {
  final Dio _dio;

  ProposalDocumentRepositoryImpl(this._dio);

  Dio get dio => _dio;

  @override
  Future<Result<ProposalDocument>> getDocument(
    String proposalId, {
    bool fromTemplate = false,
  }) async {
    try {
      final res = await _dio.get<dynamic>(
        '/v1/sales/proposals/$proposalId/document',
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

      final dto = ProposalDocumentDto.fromJson(dataMap);
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
  Future<Result<ProposalDocument>> saveDocument(
    String proposalId,
    Map<String, dynamic> content,
  ) async {
    try {
      final res = await _dio.put<dynamic>(
        '/v1/sales/proposals/$proposalId/document',
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

      final dto = ProposalDocumentDto.fromJson(dataMap);
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
  Future<Result<List<int>>> downloadPdf(String proposalId) async {
    try {
      final res = await _dio.get<List<int>>(
        '/v1/sales/proposals/$proposalId/document/pdf',
        options: Options(responseType: ResponseType.bytes),
      );
      final bytes = res.data;
      if (bytes == null || bytes.isEmpty) {
        return const Err(ServerFailure('File PDF kosong atau tidak valid.'));
      }
      return Ok(bytes);
    } on DioException catch (e) {
      // The error body may be JSON even for binary endpoint
      final data = e.response?.data;
      if (data is Map && data['message'] != null) {
        return Err(
          ServerFailure(data['message'] as String, e.response?.statusCode),
        );
      }
      if (data is List<int>) {
        // Try to parse JSON from bytes
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
