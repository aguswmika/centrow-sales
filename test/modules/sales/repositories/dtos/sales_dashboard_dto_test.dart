import 'package:flutter_test/flutter_test.dart';
import 'package:centrow_sales/modules/sales/repositories/dtos/sales_dashboard_dto.dart';

void main() {
  test('SalesDashboardSummaryDto parses JSON correctly', () {
    final json = {
      'kpis': [
        {
          'label': 'Revenue',
          'value': '100',
          'sub_text': 'Total',
          'is_warning': false,
        },
      ],
      'pipeline_stages': [
        {'name': 'Lead', 'count': 5, 'percentage': 50.0, 'color_hex': 0xFF0000},
      ],
      'client_segments': [
        {'name': 'Enterprise', 'count': 10, 'badge_type': 'gold'},
      ],
      'recent_proposals': [
        {
          'id': '1',
          'code': 'P1',
          'client_name': 'C1',
          'service_name': 'S1',
          'region': 'R1',
          'status': 'Draft',
          'amount': '1000',
        },
      ],
      'expiring_contracts': [
        {
          'id': '1',
          'code': 'C1',
          'client_name': 'C1',
          'package_name': 'Basic',
          'region': 'R1',
          'due_date': '2026-01-01',
          'amount': '500',
          'is_critical': true,
        },
      ],
      'user_name': 'User',
      'branch_name': 'Branch',
    };

    final dto = SalesDashboardSummaryDto.fromJson(json);
    final entity = dto.toEntity();

    expect(entity.userName, 'User');
    expect(entity.kpis.length, 1);
    expect(entity.kpis[0].label, 'Revenue');
  });
}
