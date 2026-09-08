import 'package:dio/dio.dart';
import 'package:centrow_sales/shared/error/failure.dart';
import 'package:centrow_sales/shared/network/dio_client.dart';
import 'package:centrow_sales/shared/result/result.dart';
import 'package:centrow_sales/modules/sales/entities/contract.dart';
import 'package:centrow_sales/modules/sales/repositories/dtos/contract_dto.dart';

abstract interface class ContractRepository {
  Future<Result<List<Contract>>> getContracts({String? query, int? status});
  Future<Result<Contract>> getContractById(String id);
  Future<Result<Contract>> createContractFromProposal(
    String proposalId,
    ContractFormInput input,
  );
  Future<Result<ContractStatusResult>> updateContract(
    String id,
    ContractFormInput input,
  );
  Future<Result<void>> deleteContract(String id);
  Future<Result<ContractStatusResult>> activateContract(String id);
  Future<Result<ContractStatusResult>> suspendContract(String id);
  Future<Result<ContractStatusResult>> terminateContract(
    String id,
    String reason,
  );
  Future<Result<ContractStatusResult>> cancelContract(String id);
}

class ContractRepositoryImpl implements ContractRepository {
  final Dio _dio;
  ContractRepositoryImpl(this._dio);

  @override
  Future<Result<List<Contract>>> getContracts({
    String? query,
    int? status,
  }) async {
    try {
      final params = <String, dynamic>{};
      if (query != null && query.trim().isNotEmpty) params['q'] = query.trim();
      if (status != null && status >= 1 && status <= 6) {
        params['status'] = status;
      }

      final response = await _dio.get<dynamic>(
        '/v1/sales/contracts',
        queryParameters: params,
      );
      final dataMap = _extractData(response.data);
      if (dataMap == null) {
        return const Err(
          ServerFailure('Format respon dari server tidak valid.'),
        );
      }
      return Ok(ContractListResponseDto.fromJson(dataMap).toEntity());
    } on DioException catch (e) {
      return Err(_handleDioError(e));
    } catch (e) {
      return Err(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<Contract>> getContractById(String id) async {
    try {
      final response = await _dio.get<dynamic>('/v1/sales/contracts/$id');
      final dataMap = _extractData(response.data);
      if (dataMap == null) {
        return const Err(
          ServerFailure('Format respon dari server tidak valid.'),
        );
      }
      return Ok(ContractDetailDto.fromJson(dataMap).toEntity());
    } on DioException catch (e) {
      return Err(_handleDioError(e));
    } catch (e) {
      return Err(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<Contract>> createContractFromProposal(
    String proposalId,
    ContractFormInput input,
  ) async {
    try {
      final response = await _dio.post<dynamic>(
        '/v1/sales/proposals/$proposalId/contract',
        data: ContractFormRequestDto.fromInput(input).toJson(),
      );
      final dataMap = _extractData(response.data);
      if (dataMap == null) {
        return const Err(
          ServerFailure('Format respon dari server tidak valid.'),
        );
      }
      return Ok(CreateContractResponseDto.fromJson(dataMap).toEntity());
    } on DioException catch (e) {
      return Err(_handleDioError(e));
    } catch (e) {
      return Err(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<ContractStatusResult>> updateContract(
    String id,
    ContractFormInput input,
  ) async {
    try {
      final response = await _dio.put<dynamic>(
        '/v1/sales/contracts/$id',
        data: ContractFormRequestDto.fromInput(input).toJson(),
      );
      final dataMap = _extractData(response.data);
      if (dataMap == null) {
        return const Err(
          ServerFailure('Format respon dari server tidak valid.'),
        );
      }
      return Ok(ContractStatusResponseDto.fromJson(dataMap).toEntity());
    } on DioException catch (e) {
      return Err(_handleDioError(e));
    } catch (e) {
      return Err(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteContract(String id) async {
    try {
      await _dio.delete<dynamic>('/v1/sales/contracts/$id');
      return const Ok(null);
    } on DioException catch (e) {
      return Err(_handleDioError(e));
    } catch (e) {
      return Err(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<ContractStatusResult>> activateContract(String id) =>
      _callTransition('/v1/sales/contracts/$id/activate');

  @override
  Future<Result<ContractStatusResult>> suspendContract(String id) =>
      _callTransition('/v1/sales/contracts/$id/suspend');

  @override
  Future<Result<ContractStatusResult>> terminateContract(
    String id,
    String reason,
  ) => _callTransition(
    '/v1/sales/contracts/$id/terminate',
    data: {'reason': reason.trim()},
  );

  @override
  Future<Result<ContractStatusResult>> cancelContract(String id) =>
      _callTransition('/v1/sales/contracts/$id/cancel');

  // ─────────────────────────────────────────────────────────────────────────

  Future<Result<ContractStatusResult>> _callTransition(
    String path, {
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await _dio.post<dynamic>(path, data: data);
      final dataMap = _extractData(response.data);
      if (dataMap == null) {
        return const Err(
          ServerFailure('Format respon dari server tidak valid.'),
        );
      }
      return Ok(ContractStatusResponseDto.fromJson(dataMap).toEntity());
    } on DioException catch (e) {
      return Err(_handleDioError(e));
    } catch (e) {
      return Err(UnknownFailure(e.toString()));
    }
  }

  Map<String, dynamic>? _extractData(dynamic raw) {
    if (raw is Map) {
      if (raw['data'] is Map) {
        return (raw['data'] as Map).cast<String, dynamic>();
      }
      return raw.cast<String, dynamic>();
    }
    return null;
  }

  Failure _handleDioError(DioException e) {
    final code = e.response?.statusCode;
    final data = e.response?.data;
    String? msg;
    if (data is Map) {
      msg = (data['message'] ?? data['error'])?.toString();
    } else if (data is String && data.isNotEmpty) {
      msg = data;
    }

    if (code == 400) {
      return ServerFailure(msg ?? 'Permintaan tidak valid.', 400);
    }
    if (code == 404) {
      return ServerFailure(msg ?? 'Kontrak tidak ditemukan.', 404);
    }
    if (code == 409) {
      return ServerFailure(
        msg ?? 'Kontrak sudah dibuat untuk proposal ini.',
        409,
      );
    }
    if (code == 500) {
      return ServerFailure(msg ?? 'Terjadi kesalahan pada server.', 500);
    }
    return mapDioException(e);
  }
}
