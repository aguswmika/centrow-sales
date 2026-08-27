import 'package:dio/dio.dart';
import 'package:centrow_sales/shared/error/failure.dart';
import 'package:centrow_sales/shared/result/result.dart';
import 'package:centrow_sales/modules/core/entities/uom.dart';
import 'package:centrow_sales/modules/core/repositories/dtos/uom_dto.dart';

abstract class UomRepository {
  Future<Result<List<Uom>>> getActiveUoms();
}

class UomRepositoryImpl implements UomRepository {
  final Dio _dio;

  UomRepositoryImpl(this._dio);

  @override
  Future<Result<List<Uom>>> getActiveUoms() async {
    try {
      final res = await _dio.get<Map<String, dynamic>>('/v1/uoms');
      final list = (res.data?['data'] as List).cast<Map<String, dynamic>>();
      return Ok(list.map(UomDto.fromJson).map((e) => e.toEntity()).toList());
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return const Err(ServerFailure('Sesi Anda telah berakhir.'));
      }
      if (e.response?.statusCode == 403) {
        return const Err(
          ServerFailure('Anda tidak memiliki akses (uom.view).'),
        );
      }
      return const Err(ServerFailure('Terjadi kesalahan pada server.'));
    } catch (e) {
      return Err(UnknownFailure(e.toString()));
    }
  }
}
