import 'package:flutter_test/flutter_test.dart';
import 'package:centrow_sales/modules/core/repositories/dtos/auth_dto.dart';
import 'package:centrow_sales/modules/core/repositories/dtos/login_request_dto.dart';
import 'package:centrow_sales/modules/core/repositories/dtos/tenant_dto.dart';

void main() {
  group('DTO Tests', () {
    test('TenantDto serialization', () {
      final json = {'id': '1', 'name': 'Test', 'slug': 'test'};
      final dto = TenantDto.fromJson(json);
      expect(dto.id, '1');
      expect(dto.toJson(), json);
    });

    test('AuthDto nested structure', () {
      final json = {
        'user': {
          'id': 'u1',
          'name': 'User',
          'email': 'a@b.com',
          'role': 'admin',
          'branch': 'b1',
        },
        'token': 'abc',
      };
      final dto = AuthDto.fromJson(json);
      expect(dto.id, 'u1');
      expect(dto.token, 'abc');
    });

    test('LoginRequestDto serialization', () {
      const dto = LoginRequestDto(
        email: 'a@b.com',
        password: 'password',
        tenantId: 't1',
      );
      final json = dto.toJson();
      expect(json['email'], 'a@b.com');
      expect(json['tenant_id'], 't1');
    });
  });
}
