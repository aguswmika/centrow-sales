import 'package:dio/dio.dart';
import 'package:centrow_sales/shared/error/failure.dart';
import 'package:centrow_sales/shared/network/dio_client.dart';
import 'package:centrow_sales/shared/result/result.dart';
import 'package:centrow_sales/modules/sales/entities/contract_addendum.dart';
import 'package:centrow_sales/modules/sales/repositories/dtos/contract_addendum_dto.dart';

abstract interface class ContractAddendumRepository {
  Future<Result<List<ContractAddendum>>> getAddendums(String contractId);
  Future<Result<ContractAddendum>> createAddendum(
    String contractId,
    CreateContractAddendumRequestDto request,
  );
}

class ContractAddendumRepositoryImpl implements ContractAddendumRepository {
  final Dio _dio;

  ContractAddendumRepositoryImpl(this._dio);

  @override
  Future<Result<List<ContractAddendum>>> getAddendums(String contractId) async {
    try {
      final response = await _dio.get<dynamic>(
        '/v1/sales/contracts/$contractId/addendums',
      );

      final responseData = response.data;
      List<dynamic> items = [];
      if (responseData is List) {
        items = responseData;
      } else if (responseData is Map) {
        final dataField = responseData['data'];
        if (dataField is List) {
          items = dataField;
        } else if (dataField is Map && dataField['items'] is List) {
          items = dataField['items'] as List<dynamic>;
        } else if (responseData['items'] is List) {
          items = responseData['items'] as List<dynamic>;
        }
      }

      final addendums = items
          .map(
            (item) => ContractAddendumDto.fromJson(
              (item as Map).cast<String, dynamic>(),
            ).toEntity(),
          )
          .toList();

      return Ok(addendums);
    } on DioException catch (e) {
      return Err(_handleDioError(e));
    } catch (e) {
      return Err(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<ContractAddendum>> createAddendum(
    String contractId,
    CreateContractAddendumRequestDto request,
  ) async {
    try {
      final response = await _dio.post<dynamic>(
        '/v1/sales/contracts/$contractId/addendums',
        data: request.toJson(),
      );

      final dataMap = _extractData(response.data);
      if (dataMap == null) {
        return const Err(
          ServerFailure('Format respon dari server tidak valid.'),
        );
      }

      return Ok(ContractAddendumDto.fromJson(dataMap).toEntity());
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
      return ServerFailure(msg ?? 'Permintaan addendum tidak valid.', 400);
    }
    if (code == 404) {
      return ServerFailure(msg ?? 'Kontrak tidak ditemukan.', 404);
    }
    if (code == 409) {
      return ServerFailure(
        msg ??
            'Kontrak telah diubah oleh pengguna lain. Silakan muat ulang dan coba lagi',
        409,
      );
    }
    if (code == 422) {
      return ServerFailure(msg ?? 'Data addendum tidak valid.', 422);
    }
    if (code == 500) {
      return ServerFailure(msg ?? 'Terjadi kesalahan pada server.', 500);
    }
    return mapDioException(e);
  }
}
