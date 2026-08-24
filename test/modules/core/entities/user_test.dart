import 'package:flutter_test/flutter_test.dart';
import 'package:centrow_sales/modules/core/entities/user.dart';

void main() {
  group('User Entity', () {
    test('constructs with all fields and properties', () {
      const user = User(
        id: 'u-1',
        tenantId: 't-1',
        name: 'Jane Doe',
        email: 'jane@example.com',
        roles: ['sales', 'admin'],
        position: 'Sales Executive',
        department: 'Sales',
        token: 'token-abc',
      );

      expect(user.id, 'u-1');
      expect(user.tenantId, 't-1');
      expect(user.name, 'Jane Doe');
      expect(user.email, 'jane@example.com');
      expect(user.roles, ['sales', 'admin']);
      expect(user.role, 'sales');
      expect(user.position, 'Sales Executive');
      expect(user.department, 'Sales');
      expect(user.token, 'token-abc');
      expect(user.getInitials(), 'JD');
      expect(user.initials, 'JD');
    });

    test('backward compatibility with role and branch named params', () {
      const user = User(
        id: 'u-2',
        name: 'Agus Mika',
        email: 'agus@centrow.id',
        role: 'sales',
        branch: 'Bali',
        token: 'token-xyz',
      );

      expect(user.role, 'sales');
      expect(user.roles, isEmpty);
      expect(user.branch, 'Bali');
      expect(user.getInitials(), 'AM');
    });

    test('getInitials variations', () {
      const u1 = User(id: '1', name: 'John Doe', email: 'j@d.com', token: 't');
      expect(u1.getInitials(), 'JD');

      const u2 = User(id: '2', name: 'Madonna', email: 'm@d.com', token: 't');
      expect(u2.getInitials(), 'MA');

      const u3 = User(id: '3', name: 'X', email: 'x@d.com', token: 't');
      expect(u3.getInitials(), 'X');

      const u4 = User(id: '4', name: '', email: 'e@d.com', token: 't');
      expect(u4.getInitials(), '');

      const u5 = User(
        id: '5',
        name: 'First Second Third',
        email: 'f@d.com',
        token: 't',
      );
      expect(u5.getInitials(), 'FS');
    });

    test('copyWith updates fields appropriately', () {
      const user = User(
        id: 'u-1',
        tenantId: 't-1',
        name: 'Jane Doe',
        email: 'jane@example.com',
        roles: ['sales'],
        position: 'Sales Executive',
        department: 'Sales',
        token: 'token-abc',
      );

      final updated = user.copyWith(
        name: 'Jane Smith',
        roles: ['manager'],
        position: 'Sales Manager',
      );

      expect(updated.name, 'Jane Smith');
      expect(updated.roles, ['manager']);
      expect(updated.role, 'manager');
      expect(updated.position, 'Sales Manager');
      expect(updated.id, 'u-1');
      expect(updated.tenantId, 't-1');
      expect(updated.email, 'jane@example.com');
      expect(updated.token, 'token-abc');
    });

    test('equality and hashCode', () {
      const user1 = User(
        id: 'u-1',
        tenantId: 't-1',
        name: 'Jane Doe',
        email: 'jane@example.com',
        roles: ['sales'],
        position: 'Sales Executive',
        department: 'Sales',
        token: 'token-abc',
      );

      const user2 = User(
        id: 'u-1',
        tenantId: 't-1',
        name: 'Jane Doe',
        email: 'jane@example.com',
        roles: ['sales'],
        position: 'Sales Executive',
        department: 'Sales',
        token: 'token-abc',
      );

      const user3 = User(
        id: 'u-2',
        tenantId: 't-1',
        name: 'Jane Doe',
        email: 'jane@example.com',
        roles: ['sales'],
        position: 'Sales Executive',
        department: 'Sales',
        token: 'token-abc',
      );

      expect(user1, equals(user2));
      expect(user1.hashCode, equals(user2.hashCode));
      expect(user1, isNot(equals(user3)));
      expect(user1.toString(), contains('Jane Doe'));
    });
  });
}
