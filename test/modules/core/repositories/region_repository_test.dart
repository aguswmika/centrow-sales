import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:centrow_sales/modules/core/entities/region.dart';
import 'package:centrow_sales/modules/core/repositories/dtos/region_dto.dart';
import 'package:centrow_sales/modules/core/repositories/region_repository.dart';
import 'package:centrow_sales/shared/error/failure.dart';
import 'package:centrow_sales/shared/result/result.dart';

class MockAdapter implements HttpClientAdapter {
  ResponseBody Function(RequestOptions options)? handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (handler != null) {
      return handler!(options);
    }
    throw DioException(
      requestOptions: options,
      type: DioExceptionType.connectionError,
      error: 'No handler set',
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late Dio dio;
  late MockAdapter mockAdapter;
  late RegionRepositoryImpl repository;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'https://erp.nohama.id/api'));
    mockAdapter = MockAdapter();
    dio.httpClientAdapter = mockAdapter;
    repository = RegionRepositoryImpl(dio);
  });

  group('Region Entities and DTOs', () {
    test('RegionItemDto parsing and entity conversions', () {
      final json = {'id': 51, 'name': 'Bali'};
      final dto = RegionItemDto.fromJson(json);

      expect(dto.id, 51);
      expect(dto.name, 'Bali');
      expect(dto.toJson(), {'id': 51, 'name': 'Bali'});

      final province = dto.toProvince();
      expect(province, isA<Province>());
      expect(province.id, 51);
      expect(province.name, 'Bali');
      expect(province, equals(const Province(id: 51, name: 'Bali')));
      expect(province.copyWith(name: 'Bali Updated').name, 'Bali Updated');

      final regency = dto.toRegency();
      expect(regency, isA<Regency>());
      expect(regency.id, 51);
      expect(regency.name, 'Bali');
      expect(regency, equals(const Regency(id: 51, name: 'Bali')));
      expect(regency.copyWith(id: 52).id, 52);

      final district = dto.toDistrict();
      expect(district, isA<District>());
      expect(district.id, 51);
      expect(district.name, 'Bali');
      expect(district, equals(const District(id: 51, name: 'Bali')));
      expect(district.copyWith(name: 'Kuta').name, 'Kuta');

      final village = dto.toVillage();
      expect(village, isA<Village>());
      expect(village.id, 51);
      expect(village.name, 'Bali');
      expect(village, equals(const Village(id: 51, name: 'Bali')));
      expect(village.copyWith(id: 100).id, 100);
    });

    test('RegionListResponseDto parsing standard envelope', () {
      final json = {
        'data': [
          {'id': 1, 'name': 'Item 1'},
          {'id': 2, 'name': 'Item 2'},
        ],
      };
      final listDto = RegionListResponseDto.fromJson(json);
      expect(listDto.data.length, 2);
      expect(listDto.toProvinces().length, 2);
      expect(listDto.toRegencies().length, 2);
      expect(listDto.toDistricts().length, 2);
      expect(listDto.toVillages().length, 2);
    });
  });

  group('RegionRepositoryImpl - getProvinces', () {
    test('returns List<Province> on 200 OK', () async {
      mockAdapter.handler = (options) {
        expect(options.path, '/v1/provinces');
        final body = jsonEncode({
          'data': [
            {'id': 51, 'name': 'Bali'},
            {'id': 31, 'name': 'DKI Jakarta'},
          ],
        });
        return ResponseBody.fromString(
          body,
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      };

      final result = await repository.getProvinces();
      expect(result, isA<Ok<List<Province>>>());
      final provinces = (result as Ok<List<Province>>).value;
      expect(provinces.length, 2);
      expect(provinces[0].id, 51);
      expect(provinces[0].name, 'Bali');
      expect(provinces[1].id, 31);
      expect(provinces[1].name, 'DKI Jakarta');
    });

    test('returns ServerFailure on 500 error', () async {
      mockAdapter.handler = (options) {
        final body = jsonEncode({
          'message': 'Internal Server Error',
        });
        return ResponseBody.fromString(
          body,
          500,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      };

      final result = await repository.getProvinces();
      expect(result, isA<Err<List<Province>>>());
      final failure = (result as Err<List<Province>>).failure;
      expect(failure, isA<ServerFailure>());
      expect(failure.statusCode, 500);
    });
  });

  group('RegionRepositoryImpl - getRegencies', () {
    test('returns List<Regency> on 200 OK with query parameters', () async {
      mockAdapter.handler = (options) {
        expect(options.path, '/v1/regencies');
        expect(options.queryParameters, {'province_id': 51});
        final body = jsonEncode({
          'data': [
            {'id': 5101, 'name': 'Kab. Jembrana'},
            {'id': 5103, 'name': 'Kab. Badung'},
          ],
        });
        return ResponseBody.fromString(
          body,
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      };

      final result = await repository.getRegencies(51);
      expect(result, isA<Ok<List<Regency>>>());
      final regencies = (result as Ok<List<Regency>>).value;
      expect(regencies.length, 2);
      expect(regencies[0].id, 5101);
      expect(regencies[0].name, 'Kab. Jembrana');
      expect(regencies[1].id, 5103);
      expect(regencies[1].name, 'Kab. Badung');
    });

    test('returns ServerFailure on 404 Not Found', () async {
      mockAdapter.handler = (options) {
        final body = jsonEncode({
          'message': 'Province not found',
        });
        return ResponseBody.fromString(
          body,
          404,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      };

      final result = await repository.getRegencies(999);
      expect(result, isA<Err<List<Regency>>>());
      final failure = (result as Err<List<Regency>>).failure;
      expect(failure, isA<ServerFailure>());
      expect(failure.statusCode, 404);
    });
  });

  group('RegionRepositoryImpl - getDistricts', () {
    test('returns List<District> on 200 OK with query parameters', () async {
      mockAdapter.handler = (options) {
        expect(options.path, '/v1/districts');
        expect(options.queryParameters, {
          'province_id': 51,
          'regency_id': 5103,
        });
        final body = jsonEncode({
          'data': [
            {'id': 5103010, 'name': 'Kuta Selatan'},
            {'id': 5103020, 'name': 'Kuta'},
            {'id': 5103030, 'name': 'Kuta Utara'},
          ],
        });
        return ResponseBody.fromString(
          body,
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      };

      final result = await repository.getDistricts(51, 5103);
      expect(result, isA<Ok<List<District>>>());
      final districts = (result as Ok<List<District>>).value;
      expect(districts.length, 3);
      expect(districts[0].id, 5103010);
      expect(districts[0].name, 'Kuta Selatan');
      expect(districts[2].id, 5103030);
      expect(districts[2].name, 'Kuta Utara');
    });
  });

  group('RegionRepositoryImpl - getVillages', () {
    test('returns List<Village> on 200 OK with query parameters', () async {
      mockAdapter.handler = (options) {
        expect(options.path, '/v1/villages');
        expect(options.queryParameters, {
          'province_id': 51,
          'regency_id': 5103,
          'district_id': 5103030,
        });
        final body = jsonEncode({
          'data': [
            {'id': 5103030001, 'name': 'Kerobokan'},
            {'id': 5103030002, 'name': 'Kerobokan Kelod'},
            {'id': 5103030003, 'name': 'Tibubeneng'},
            {'id': 5103030004, 'name': 'Canggu'},
          ],
        });
        return ResponseBody.fromString(
          body,
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      };

      final result = await repository.getVillages(51, 5103, 5103030);
      expect(result, isA<Ok<List<Village>>>());
      final villages = (result as Ok<List<Village>>).value;
      expect(villages.length, 4);
      expect(villages[0].id, 5103030001);
      expect(villages[0].name, 'Kerobokan');
      expect(villages[2].id, 5103030003);
      expect(villages[2].name, 'Tibubeneng');
      expect(villages[3].id, 5103030004);
      expect(villages[3].name, 'Canggu');
    });

    test('returns NetworkFailure on connection error', () async {
      mockAdapter.handler = (options) {
        throw DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
        );
      };

      final result = await repository.getVillages(51, 5103, 5103030);
      expect(result, isA<Err<List<Village>>>());
      final failure = (result as Err<List<Village>>).failure;
      expect(failure, isA<NetworkFailure>());
    });
  });
}
