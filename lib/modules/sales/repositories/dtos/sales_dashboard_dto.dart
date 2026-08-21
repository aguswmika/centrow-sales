import 'package:centrow_sales/modules/sales/entities/sales_dashboard.dart';

class KpiMetricDto {
  final String label;
  final String value;
  final String subText;
  final bool? isPositive;
  final bool isWarning;

  KpiMetricDto({
    required this.label,
    required this.value,
    required this.subText,
    this.isPositive,
    required this.isWarning,
  });

  factory KpiMetricDto.fromJson(Map<String, dynamic> json) {
    return KpiMetricDto(
      label: json['label'] as String,
      value: json['value'] as String,
      subText: json['sub_text'] as String,
      isPositive: json['is_positive'] as bool?,
      isWarning: json['is_warning'] as bool,
    );
  }

  KpiMetric toEntity() => KpiMetric(
    label: label,
    value: value,
    subText: subText,
    isPositive: isPositive,
    isWarning: isWarning,
  );
}

class PipelineStageDto {
  final String name;
  final int count;
  final double percentage;
  final int colorHex;

  PipelineStageDto({
    required this.name,
    required this.count,
    required this.percentage,
    required this.colorHex,
  });

  factory PipelineStageDto.fromJson(Map<String, dynamic> json) {
    return PipelineStageDto(
      name: json['name'] as String,
      count: json['count'] as int,
      percentage: (json['percentage'] as num).toDouble(),
      colorHex: json['color_hex'] as int,
    );
  }

  PipelineStage toEntity() => PipelineStage(
    name: name,
    count: count,
    percentage: percentage,
    colorHex: colorHex,
  );
}

class ClientSegmentDto {
  final String name;
  final int count;
  final String badgeType;

  ClientSegmentDto({
    required this.name,
    required this.count,
    required this.badgeType,
  });

  factory ClientSegmentDto.fromJson(Map<String, dynamic> json) {
    return ClientSegmentDto(
      name: json['name'] as String,
      count: json['count'] as int,
      badgeType: json['badge_type'] as String,
    );
  }

  ClientSegment toEntity() =>
      ClientSegment(name: name, count: count, badgeType: badgeType);
}

class RecentProposalDto {
  final String id;
  final String code;
  final String clientName;
  final String serviceName;
  final String region;
  final String status;
  final String amount;

  RecentProposalDto({
    required this.id,
    required this.code,
    required this.clientName,
    required this.serviceName,
    required this.region,
    required this.status,
    required this.amount,
  });

  factory RecentProposalDto.fromJson(Map<String, dynamic> json) {
    return RecentProposalDto(
      id: json['id'] as String,
      code: json['code'] as String,
      clientName: json['client_name'] as String,
      serviceName: json['service_name'] as String,
      region: json['region'] as String,
      status: json['status'] as String,
      amount: json['amount'] as String,
    );
  }

  RecentProposal toEntity() => RecentProposal(
    id: id,
    code: code,
    clientName: clientName,
    serviceName: serviceName,
    region: region,
    status: status,
    amount: amount,
  );
}

class ExpiringContractDto {
  final String id;
  final String code;
  final String clientName;
  final String packageName;
  final String region;
  final String dueDate;
  final String amount;
  final bool isCritical;

  ExpiringContractDto({
    required this.id,
    required this.code,
    required this.clientName,
    required this.packageName,
    required this.region,
    required this.dueDate,
    required this.amount,
    required this.isCritical,
  });

  factory ExpiringContractDto.fromJson(Map<String, dynamic> json) {
    return ExpiringContractDto(
      id: json['id'] as String,
      code: json['code'] as String,
      clientName: json['client_name'] as String,
      packageName: json['package_name'] as String,
      region: json['region'] as String,
      dueDate: json['due_date'] as String,
      amount: json['amount'] as String,
      isCritical: json['is_critical'] as bool,
    );
  }

  ExpiringContract toEntity() => ExpiringContract(
    id: id,
    code: code,
    clientName: clientName,
    packageName: packageName,
    region: region,
    dueDate: dueDate,
    amount: amount,
    isCritical: isCritical,
  );
}

class SalesDashboardSummaryDto {
  final List<KpiMetricDto> kpis;
  final List<PipelineStageDto> pipelineStages;
  final List<ClientSegmentDto> clientSegments;
  final List<RecentProposalDto> recentProposals;
  final List<ExpiringContractDto> expiringContracts;
  final String userName;
  final String branchName;

  SalesDashboardSummaryDto({
    required this.kpis,
    required this.pipelineStages,
    required this.clientSegments,
    required this.recentProposals,
    required this.expiringContracts,
    required this.userName,
    required this.branchName,
  });

  factory SalesDashboardSummaryDto.fromJson(Map<String, dynamic> json) {
    return SalesDashboardSummaryDto(
      kpis: (json['kpis'] as List)
          .map((e) => KpiMetricDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      pipelineStages: (json['pipeline_stages'] as List)
          .map((e) => PipelineStageDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      clientSegments: (json['client_segments'] as List)
          .map((e) => ClientSegmentDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      recentProposals: (json['recent_proposals'] as List)
          .map((e) => RecentProposalDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      expiringContracts: (json['expiring_contracts'] as List)
          .map((e) => ExpiringContractDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      userName: json['user_name'] as String,
      branchName: json['branch_name'] as String,
    );
  }

  SalesDashboardSummary toEntity() => SalesDashboardSummary(
    kpis: kpis.map((e) => e.toEntity()).toList(),
    pipelineStages: pipelineStages.map((e) => e.toEntity()).toList(),
    clientSegments: clientSegments.map((e) => e.toEntity()).toList(),
    recentProposals: recentProposals.map((e) => e.toEntity()).toList(),
    expiringContracts: expiringContracts.map((e) => e.toEntity()).toList(),
    userName: userName,
    branchName: branchName,
  );
}
