import 'package:dio/dio.dart';
import '../../../shared/error/failure.dart';
import '../../../shared/network/dio_client.dart';
import '../../../shared/result/result.dart';
import '../entities/create_customer_input.dart';
import '../entities/customer.dart';
import '../entities/segment.dart';
import 'dtos/customer_dto.dart';
import 'dtos/segment_dto.dart';

abstract interface class CustomerRepository {
  Future<Result<List<Customer>>> getCustomers({
    int page = 1,
    int pageSize = 20,
    String? query,
    String? segmentId,
    String? status,
  });

  Future<Result<List<Segment>>> getSegments({
    int page = 1,
    int pageSize = 100,
    String? query,
  });

  Future<Result<Customer>> getCustomerById(String id);

  Future<Result<Customer>> createCustomer(CreateCustomerInput input);

  Future<Result<Customer>> updateCustomer(
    String id,
    CreateCustomerInput input,
  );
}

class CustomerRepositoryImpl implements CustomerRepository {
  final Dio _dio;

  CustomerRepositoryImpl(this._dio);

  Dio get dio => _dio;

  @override
  Future<Result<List<Customer>>> getCustomers({
    int page = 1,
    int pageSize = 20,
    String? query,
    String? segmentId,
    String? status,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'page': page,
        'page_size': pageSize,
      };

      if (query != null && query.trim().isNotEmpty) {
        queryParameters['q'] = query.trim();
      }

      if (segmentId != null &&
          segmentId.trim().isNotEmpty &&
          segmentId != 'all') {
        queryParameters['segment_id'] = segmentId.trim();
      }

      if (status != null && status.trim().isNotEmpty && status != 'all') {
        queryParameters['status'] = status.trim();
      }

      final response = await _dio.get<dynamic>(
        '/v1/sales/customers',
        queryParameters: queryParameters,
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

      final listResponseDto = CustomerListResponseDto.fromJson(dataMap);
      final customers = listResponseDto.items.map((e) => e.toEntity()).toList();
      return Ok(customers);
    } on DioException catch (e) {
      return Err(_handleDioError(e));
    } catch (e) {
      return Err(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<Segment>>> getSegments({
    int page = 1,
    int pageSize = 100,
    String? query,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'page': page,
        'page_size': pageSize,
      };

      if (query != null && query.trim().isNotEmpty) {
        queryParameters['q'] = query.trim();
      }

      final response = await _dio.get<dynamic>(
        '/v1/sales/segments',
        queryParameters: queryParameters,
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

      final listResponseDto = SegmentListResponseDto.fromJson(dataMap);
      final segments = listResponseDto.items.map((e) => e.toEntity()).toList();
      return Ok(segments);
    } on DioException catch (e) {
      return Err(_handleDioError(e));
    } catch (e) {
      return Err(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<Customer>> getCustomerById(String id) async {
    try {
      final response = await _dio.get<dynamic>('/v1/sales/customers/$id');

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

      final detailDto = CustomerDetailDto.fromJson(dataMap);
      return Ok(detailDto.toEntity());
    } on DioException catch (e) {
      return Err(_handleDioError(e));
    } catch (e) {
      return Err(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<Customer>> createCustomer(CreateCustomerInput input) async {
    try {
      final requestDto = CreateCustomerRequestDto.fromInput(input);

      final response = await _dio.post<dynamic>(
        '/v1/sales/customers',
        data: requestDto.toJson(),
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

      final createdDto = CreateCustomerResponseDto.fromJson(dataMap);
      return Ok(createdDto.toEntity());
    } on DioException catch (e) {
      return Err(_handleDioError(e));
    } catch (e) {
      return Err(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<Customer>> updateCustomer(
    String id,
    CreateCustomerInput input,
  ) async {
    try {
      final requestDto = UpdateCustomerRequestDto.fromInput(input);

      final response = await _dio.put<dynamic>(
        '/v1/sales/customers/$id',
        data: requestDto.toJson(),
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

      final updatedDto = CreateCustomerResponseDto.fromJson(dataMap);
      return Ok(updatedDto.toEntity());
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
      return ServerFailure(message ?? 'Data tidak ditemukan.', 404);
    } else if (statusCode == 500) {
      return ServerFailure(message ?? 'Terjadi kesalahan pada server.', 500);
    }

    return mapDioException(e);
  }
}
