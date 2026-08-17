import 'package:dio/dio.dart';
import '../../../shared/error/failure.dart';
import '../../../shared/network/dio_client.dart';
import '../../../shared/result/result.dart';
import '../entities/sales_dashboard.dart';
import 'dtos/sales_dashboard_dto.dart';

const mockSalesDashboardSummary = SalesDashboardSummary(
  userName: 'Agus Widarmika',
  branchName: 'Bali & Nusa Tenggara',
  kpis: [
    KpiMetric(
      label: 'Proposal Aktif',
      value: '24',
      subText: '↑ 3 bulan ini',
      isPositive: true,
      isWarning: false,
    ),
    KpiMetric(
      label: 'Kontrak Berjalan',
      value: '148',
      subText: '3 jatuh tempo',
      isWarning: true,
    ),
    KpiMetric(
      label: 'Nilai Pipeline',
      value: 'Rp 84,5jt',
      subText: '↑ 12% vs bulan lalu',
      isPositive: true,
      isWarning: false,
    ),
    KpiMetric(
      label: 'Margin Rata-rata',
      value: '31,2%',
      subText: '↓ 0.8% target 32,0%',
      isPositive: false,
      isWarning: false,
    ),
  ],
  pipelineStages: [
    PipelineStage(
      name: 'Draft',
      count: 6,
      percentage: 1.0,
      colorHex: 0xFF93C5FD,
    ),
    PipelineStage(
      name: 'Dikirim',
      count: 8,
      percentage: 0.75,
      colorHex: 0xFF60A5FA,
    ),
    PipelineStage(
      name: 'Negosiasi',
      count: 5,
      percentage: 0.48,
      colorHex: 0xFF3B82F6,
    ),
    PipelineStage(
      name: 'Disetujui',
      count: 3,
      percentage: 0.28,
      colorHex: 0xFF1E40AF,
    ),
  ],
  clientSegments: [
    ClientSegment(name: 'Villa', count: 635, badgeType: 'brand'),
    ClientSegment(name: 'Hotel & Resort', count: 84, badgeType: 'info'),
    ClientSegment(name: 'Residensial', count: 76, badgeType: 'neutral'),
    ClientSegment(name: 'F&B / Resto', count: 60, badgeType: 'ok'),
  ],
  recentProposals: [
    RecentProposal(
      id: '1',
      code: 'PRO-2026-0042',
      clientName: 'Villa Sari Dewi',
      serviceName: 'Termite Protection',
      region: 'Badung',
      status: 'Dikirim',
      amount: 'Rp 4,8jt',
    ),
    RecentProposal(
      id: '2',
      code: 'PRO-2026-0041',
      clientName: 'Hotel Surya Kuta',
      serviceName: 'Pest Control Bulanan',
      region: 'Badung',
      status: 'Negosiasi',
      amount: 'Rp 12,5jt',
    ),
    RecentProposal(
      id: '3',
      code: 'PRO-2026-0040',
      clientName: 'Resto Bebek Tepi Sawah',
      serviceName: 'Rodent & Fly Control',
      region: 'Gianyar',
      status: 'Disetujui',
      amount: 'Rp 3,2jt',
    ),
    RecentProposal(
      id: '4',
      code: 'PRO-2026-0039',
      clientName: 'Residensial Sanur',
      serviceName: 'General Pest Control',
      region: 'Denpasar',
      status: 'Draft',
      amount: 'Rp 1,8jt',
    ),
  ],
  expiringContracts: [
    ExpiringContract(
      id: '1',
      code: 'KON-2024-0112',
      clientName: 'Villa Puri Tirtha',
      packageName: 'Termite 2 Thn',
      region: 'Gianyar',
      dueDate: '28 Agt 2026',
      amount: 'Rp 9,6jt',
      isCritical: true,
    ),
    ExpiringContract(
      id: '2',
      code: 'KON-2025-0089',
      clientName: 'Resort Maya Ubud',
      packageName: 'Full Pest 1 Thn',
      region: 'Gianyar',
      dueDate: '31 Agt 2026',
      amount: 'Rp 18,0jt',
      isCritical: true,
    ),
    ExpiringContract(
      id: '3',
      code: 'KON-2025-0104',
      clientName: 'Cafe del Mar',
      packageName: 'Kitchen Hygiene 6 Bln',
      region: 'Badung',
      dueDate: '05 Sep 2026',
      amount: 'Rp 6,5jt',
      isCritical: false,
    ),
  ],
);

abstract interface class SalesDashboardRepository {
  Future<Result<SalesDashboardSummary>> getDashboardSummary();
}

class SalesDashboardRepositoryImpl implements SalesDashboardRepository {
  final Dio? _dio;
  final bool useMock;

  SalesDashboardRepositoryImpl([this._dio, this.useMock = true]);

  @override
  Future<Result<SalesDashboardSummary>> getDashboardSummary() async {
    if (useMock || _dio == null) {
      await Future<void>.delayed(const Duration(milliseconds: 200));
      return const Ok(mockSalesDashboardSummary);
    }

    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/v1/sales/dashboard',
      );

      final dynamic responseData = response.data;
      final Map<String, dynamic> dataJson;

      if (responseData is Map<String, dynamic>) {
        if (responseData['data'] is Map<String, dynamic>) {
          dataJson = responseData['data'] as Map<String, dynamic>;
        } else {
          dataJson = responseData;
        }
      } else {
        return const Err(
          ServerFailure('Format respon dari server tidak valid.'),
        );
      }

      final dto = SalesDashboardSummaryDto.fromJson(dataJson);
      return Ok(dto.toEntity());
    } on DioException catch (e) {
      return Err(mapDioException(e));
    } catch (e) {
      return Err(UnknownFailure(e.toString()));
    }
  }
}
