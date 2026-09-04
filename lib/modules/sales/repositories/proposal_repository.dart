import 'package:dio/dio.dart';
import 'package:centrow_sales/shared/error/failure.dart';
import 'package:centrow_sales/shared/network/dio_client.dart';
import 'package:centrow_sales/shared/result/result.dart';
import 'package:centrow_sales/modules/sales/entities/create_proposal_input.dart';
import 'package:centrow_sales/modules/sales/entities/update_proposal_input.dart';
import 'package:centrow_sales/modules/sales/entities/proposal.dart';
import 'package:centrow_sales/modules/sales/entities/proposal_status_result.dart';
import 'package:centrow_sales/modules/sales/repositories/dtos/proposal_dto.dart';

abstract interface class ProposalRepository {
  Future<Result<List<Proposal>>> getProposals({String? query, String? status});

  Future<Result<Proposal>> getProposalById(String id);

  Future<Result<Proposal>> createProposal(CreateProposalInput input);

  Future<Result<Proposal>> updateProposal(String id, UpdateProposalInput data);
  Future<Result<Proposal>> reviseProposal(String id, UpdateProposalInput data);

  Future<Result<ProposalStatusResult>> sendProposal(String id);
  Future<Result<ProposalStatusResult>> acceptProposal(String id);
  Future<Result<ProposalStatusResult>> rejectProposal(String id, String reason);
  Future<Result<ProposalStatusResult>> expireProposal(String id);
  Future<Result<ProposalStatusResult>> cancelProposal(String id);
}

class ProposalRepositoryImpl implements ProposalRepository {
  final Dio _dio;

  ProposalRepositoryImpl(this._dio);

  Dio get dio => _dio;

  @override
  Future<Result<List<Proposal>>> getProposals({
    String? query,
    String? status,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (query != null && query.trim().isNotEmpty) {
        queryParams['q'] = query.trim();
      }
      final statusInt = _mapStatusToInt(status);
      if (statusInt != null) {
        queryParams['status'] = statusInt;
      }

      final response = await _dio.get<dynamic>(
        '/v1/sales/proposals',
        queryParameters: queryParams,
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

      final listResponseDto = ProposalListResponseDto.fromJson(dataMap);
      final proposals = listResponseDto.items.map((e) => e.toEntity()).toList();
      return Ok(proposals);
    } on DioException catch (e) {
      return Err(_handleDioError(e));
    } catch (e) {
      return Err(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<Proposal>> getProposalById(String id) async {
    try {
      final response = await _dio.get<dynamic>('/v1/sales/proposals/$id');

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

      final detailDto = ProposalDetailDto.fromJson(dataMap);
      return Ok(detailDto.toEntity());
    } on DioException catch (e) {
      return Err(_handleDioError(e));
    } catch (e) {
      return Err(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<Proposal>> createProposal(CreateProposalInput input) async {
    try {
      final response = await _dio.post<dynamic>(
        '/v1/sales/proposals',
        data: input.toJson(),
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

      final createdDto = CreateProposalResponseDto.fromJson(dataMap);
      return Ok(createdDto.toEntity());
    } on DioException catch (e) {
      return Err(_handleDioError(e));
    } catch (e) {
      return Err(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<Proposal>> updateProposal(
    String id,
    UpdateProposalInput input,
  ) async {
    try {
      final response = await _dio.put<dynamic>(
        '/v1/sales/proposals/$id',
        data: input.toJson(),
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
      final updatedDto = ProposalDetailDto.fromJson(dataMap);
      return Ok(updatedDto.toEntity());
    } on DioException catch (e) {
      return Err(_handleDioError(e));
    } catch (e) {
      return Err(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<Proposal>> reviseProposal(
    String id,
    UpdateProposalInput data,
  ) async {
    try {
      final response = await _dio.post<dynamic>(
        '/v1/sales/proposals/$id/revise',
        data: data.toJson(),
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
      final detailDto = ProposalDetailDto.fromJson(dataMap);
      return Ok(detailDto.toEntity());
    } on DioException catch (e) {
      return Err(_handleDioError(e));
    } catch (e) {
      return Err(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<ProposalStatusResult>> sendProposal(String id) async {
    return _callStatusTransition('/v1/sales/proposals/$id/send');
  }

  @override
  Future<Result<ProposalStatusResult>> acceptProposal(String id) async {
    return _callStatusTransition('/v1/sales/proposals/$id/accept');
  }

  @override
  Future<Result<ProposalStatusResult>> rejectProposal(
    String id,
    String reason,
  ) async {
    return _callStatusTransition(
      '/v1/sales/proposals/$id/reject',
      data: {'reason': reason.trim()},
    );
  }

  @override
  Future<Result<ProposalStatusResult>> expireProposal(String id) async {
    return _callStatusTransition('/v1/sales/proposals/$id/expire');
  }

  @override
  Future<Result<ProposalStatusResult>> cancelProposal(String id) async {
    return _callStatusTransition('/v1/sales/proposals/$id/cancel');
  }

  Future<Result<ProposalStatusResult>> _callStatusTransition(
    String path, {
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await _dio.post<dynamic>(path, data: data);
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
      final dto = ProposalStatusResponseDto.fromJson(dataMap);
      return Ok(dto.toEntity());
    } on DioException catch (e) {
      return Err(_handleDioError(e));
    } catch (e) {
      return Err(UnknownFailure(e.toString()));
    }
  }

  int? _mapStatusToInt(String? status) {
    if (status == null) return null;
    final s = status.trim().toLowerCase();
    if (s.isEmpty || s == 'all' || s == 'semua') return null;

    final asInt = int.tryParse(s);
    if (asInt != null && asInt >= 1 && asInt <= 6) {
      return asInt;
    }

    return switch (s) {
      'draft' || 'draf' => 1,
      'sent' || 'dikirim' || 'terkirim' => 2,
      'accepted' || 'disetujui' || 'diterima' => 3,
      'rejected' || 'ditolak' => 4,
      'expired' || 'kedaluwarsa' || 'kadaluarsa' => 5,
      'cancelled' || 'canceled' || 'dibatalkan' => 6,
      _ => null,
    };
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
      return ServerFailure(message ?? 'Proposal tidak ditemukan.', 404);
    } else if (statusCode == 500) {
      return ServerFailure(message ?? 'Terjadi kesalahan pada server.', 500);
    }

    return mapDioException(e);
  }
}
