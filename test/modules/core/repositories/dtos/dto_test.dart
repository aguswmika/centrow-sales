import 'package:flutter_test/flutter_test.dart';
import 'package:centrow_sales/modules/core/repositories/dtos/auth_dto.dart';
import 'package:centrow_sales/modules/core/repositories/dtos/login_request_dto.dart';
import 'package:centrow_sales/modules/core/repositories/dtos/user_me_dto.dart';

void main() {
  group('DTO Tests', () {
    test('AuthDto nested structure and toEntity', () {
      final json = {
        'user': {
          'id': 'u1',
          'name': 'User',
          'email': 'a@b.com',
          'role': 'super_admin',
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
      expect(user.role, 'super_admin');
      expect(user.roles, ['super_admin']);
      expect(user.branch, 'b1');
      expect(user.token, 'abc');
    });

    test('LoginRequestDto serialization', () {
      const dto = LoginRequestDto(email: 'a@b.com', password: 'password');
      final json = dto.toJson();
      expect(json, {'email': 'a@b.com', 'password': 'password'});
    });

    test(
      'UserMeDto.fromJson falls back to tenant_id when branch_id absent',
      () {
        final dto = UserMeDto.fromJson({
          'data': {
            'id': 'u-1',
            'tenant_id': 'legacy-branch-id',
            'name': 'Jane Doe',
            'email': 'sales@example.com',
          },
        });
        expect(dto.branchId, 'legacy-branch-id');
      },
    );

    test('UserMeDto.fromJson prefers branch_id over tenant_id', () {
      final dto = UserMeDto.fromJson({
        'data': {
          'id': 'u-1',
          'branch_id': 'new-branch-id',
          'tenant_id': 'legacy-branch-id',
          'name': 'Jane Doe',
          'email': 'sales@example.com',
        },
      });
      expect(dto.branchId, 'new-branch-id');
    });

    test('UserMeDto serialization and toEntity', () {
      final json = {
        'data': {
          'id': '5d3611bb-d413-4d03-95dc-57f1d1de572a',
          'branch_id': '8e4c1393-cdfb-4987-b842-a6653875435c',
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
      expect(dto.branchId, '8e4c1393-cdfb-4987-b842-a6653875435c');
      expect(dto.name, 'Jane Doe');
      expect(dto.email, 'sales@example.com');
      expect(dto.roles, ['sales']);
      expect(dto.position, 'Sales Executive');
      expect(dto.department, 'Sales');

      final user = dto.toEntity('jwt_token_123');
      expect(user.id, dto.id);
      expect(user.branchId, dto.branchId);
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
      expect(outJson['branch_id'], dto.branchId);
      expect(outJson['name'], dto.name);
      expect(outJson['email'], dto.email);
      expect(outJson['roles'], dto.roles);
      expect(outJson['position'], dto.position);
      expect(outJson['department'], dto.department);
    });

    test('AuthDto reads branch and company maps from API form', () {
      final dto = AuthDto.fromJson({
        'data': {
          'token': 't',
          'user': {'id': '1', 'name': 'A', 'email': 'a@b.c'},
          'branch': {'id': 'b1', 'name': 'Bali'},
          'company': {'id': 'c1', 'name': 'Centrow'},
        },
      });
      final user = dto.toEntity();
      expect(user.branchId, 'b1');
      expect(user.branchName, 'Bali');
      expect(user.companyId, 'c1');
      expect(user.companyName, 'Centrow');
    });

    test('AuthDto reads flat stored form', () {
      final dto = AuthDto.fromJson({
        'id': '1',
        'name': 'A',
        'email': 'a@b.c',
        'branch_id': 'b1',
        'branch_name': 'Bali',
        'company_id': 'c1',
        'company_name': 'Centrow',
        'token': 't',
      });
      expect(dto.branchId, 'b1');
      expect(dto.branchName, 'Bali');
      expect(dto.companyId, 'c1');
      expect(dto.companyName, 'Centrow');
      expect(AuthDto.fromJson(dto.toJson()).companyName, 'Centrow');
    });

    test('AuthDto defaults to empty when branch/company absent', () {
      final user = AuthDto.fromJson({
        'data': {
          'token': 't',
          'user': {'id': '1', 'branch': 'Bali'},
        },
      }).toEntity();
      expect(user.branch, 'Bali');
      expect(user.branchId, '');
      expect(user.branchName, '');
      expect(user.companyId, '');
      expect(user.companyName, '');
    });

    test('UserMeDto parses branch and company objects', () {
      final user = UserMeDto.fromJson({
        'data': {
          'id': '1',
          'name': 'A',
          'branch': {'id': 'b1', 'name': 'Bali'},
          'company': {'id': 'c1', 'name': 'Centrow'},
        },
      }).toEntity('t');
      expect(user.branchId, 'b1');
      expect(user.branchName, 'Bali');
      expect(user.companyId, 'c1');
      expect(user.companyName, 'Centrow');

      final bare = UserMeDto.fromJson({'id': '2'}).toEntity();
      expect(bare.branchName, '');
      expect(bare.companyId, '');
    });
  });
}
