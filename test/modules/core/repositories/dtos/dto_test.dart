import 'package:flutter_test/flutter_test.dart';
import 'package:centrow_sales/modules/core/repositories/dtos/auth_dto.dart';
import 'package:centrow_sales/modules/core/repositories/dtos/login_request_dto.dart';
import 'package:centrow_sales/modules/core/repositories/dtos/tenant_dto.dart';
import 'package:centrow_sales/modules/core/repositories/dtos/user_me_dto.dart';

void main() {
  group('DTO Tests', () {
    test('TenantDto serialization', () {
      final json = {'id': '1', 'name': 'Test', 'slug': 'test'};
      final dto = TenantDto.fromJson(json);
      expect(dto.id, '1');
      expect(dto.toJson(), json);
    });

    test('AuthDto nested structure and toEntity', () {
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

      final user = dto.toEntity();
      expect(user.id, 'u1');
      expect(user.name, 'User');
      expect(user.email, 'a@b.com');
      expect(user.role, 'admin');
      expect(user.roles, ['admin']);
      expect(user.branch, 'b1');
      expect(user.token, 'abc');
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

    test('UserMeDto serialization and toEntity', () {
      final json = {
        'data': {
          'id': '5d3611bb-d413-4d03-95dc-57f1d1de572a',
          'tenant_id': '8e4c1393-cdfb-4987-b842-a6653875435c',
          'name': 'Jane Doe',
          'email': 'sales@example.com',
          'roles': ['sales'],
          'position': 'Sales Executive',
          'department': 'Sales',
        },
        'is_error': false,
        'http_status': 200,
      };
      final dto = UserMeDto.fromJson(json);
      expect(dto.id, '5d3611bb-d413-4d03-95dc-57f1d1de572a');
      expect(dto.tenantId, '8e4c1393-cdfb-4987-b842-a6653875435c');
      expect(dto.name, 'Jane Doe');
      expect(dto.email, 'sales@example.com');
      expect(dto.roles, ['sales']);
      expect(dto.position, 'Sales Executive');
      expect(dto.department, 'Sales');

      final user = dto.toEntity('jwt_token_123');
      expect(user.id, dto.id);
      expect(user.tenantId, dto.tenantId);
      expect(user.name, dto.name);
      expect(user.email, dto.email);
      expect(user.roles, ['sales']);
      expect(user.role, 'sales');
      expect(user.position, 'Sales Executive');
      expect(user.department, 'Sales');
      expect(user.token, 'jwt_token_123');
      expect(user.getInitials(), 'JD');

      final outJson = dto.toJson();
      expect(outJson['id'], dto.id);
      expect(outJson['tenant_id'], dto.tenantId);
      expect(outJson['name'], dto.name);
      expect(outJson['email'], dto.email);
      expect(outJson['roles'], dto.roles);
      expect(outJson['position'], dto.position);
      expect(outJson['department'], dto.department);
    });
  });
}
