import 'package:dio/dio.dart';
import '../../../shared/error/failure.dart';
import '../../../shared/network/dio_client.dart';
import '../../../shared/result/result.dart';
import '../entities/tenant.dart';
import '../entities/user.dart';
import 'dtos/auth_dto.dart';
import 'dtos/login_request_dto.dart';
import 'dtos/tenant_dto.dart';

abstract interface class AuthRepository {
  Future<Result<List<Tenant>>> getPublicTenants();
  Future<Result<User>> login({
    required String email,
    required String password,
    required String tenantId,
  });
}

class AuthRepositoryImpl implements AuthRepository {
  final Dio _dio;

  AuthRepositoryImpl(this._dio);

  @override
  Future<Result<List<Tenant>>> getPublicTenants() async {
    try {
      final response = await _dio.get<dynamic>('/v1/tenants/public');
      final dynamic responseData = response.data;
      final List<dynamic> data;
      if (responseData is Map) {
        data = (responseData['data'] as List<dynamic>?) ?? [];
      } else if (responseData is List) {
        data = responseData;
      } else {
        data = [];
      }

      final tenants = data
          .map(
            (e) => TenantDto.fromJson(
              (e as Map).cast<String, dynamic>(),
            ).toEntity(),
          )
          .toList();
      return Ok(tenants);
    } on DioException catch (e) {
      return Err(mapDioException(e));
    } catch (e) {
      return Err(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<User>> login({
    required String email,
    required String password,
    required String tenantId,
  }) async {
    try {
      final requestDto = LoginRequestDto(
        email: email,
        password: password,
        tenantId: tenantId,
      );

      final response = await _dio.post<dynamic>(
        '/v1/auth/login',
        data: requestDto.toJson(),
      );

      final dynamic responseData = response.data;
      final Map<String, dynamic> dataMap;
      if (responseData is Map) {
        dataMap = responseData.cast<String, dynamic>();
      } else {
        return const Err(
          ServerFailure('Format respon dari server tidak valid.'),
        );
      }

      final dto = AuthDto.fromJson(dataMap);
      return Ok(dto.toEntity());
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      if (statusCode == 400) {
        return Err(
          ServerFailure(
            (e.response?.data?['message'] as String?) ??
                'Data login tidak valid.',
            400,
          ),
        );
      } else if (statusCode == 401) {
        return Err(
          ServerFailure(
            (e.response?.data?['message'] as String?) ??
                'Email atau kata sandi salah.',
            401,
          ),
        );
      } else if (statusCode == 403) {
        return const Err(
          ServerFailure('Akun ini tidak memiliki akses ke aplikasi ini.', 403),
        );
      } else if (statusCode == 500) {
        return Err(
          ServerFailure(
            (e.response?.data?['message'] as String?) ??
                'Terjadi kesalahan pada server.',
            500,
          ),
        );
      }

      return Err(mapDioException(e));
    } catch (e) {
      return Err(UnknownFailure(e.toString()));
    }
  }
}
