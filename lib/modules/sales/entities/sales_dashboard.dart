class KpiMetric {
  final String label;
  final String value;
  final String subText;
  final bool? isPositive;
  final bool isWarning;

  const KpiMetric({
    required this.label,
    required this.value,
    required this.subText,
    this.isPositive,
    this.isWarning = false,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KpiMetric &&
          runtimeType == other.runtimeType &&
          label == other.label &&
          value == other.value &&
          subText == other.subText &&
          isPositive == other.isPositive &&
          isWarning == other.isWarning;

  @override
  int get hashCode =>
      Object.hash(runtimeType, label, value, subText, isPositive, isWarning);

  @override
  String toString() =>
      'KpiMetric(label: $label, value: $value, subText: $subText, isPositive: $isPositive, isWarning: $isWarning)';
}

class PipelineStage {
  final String name;
  final int count;
  final double percentage;
  final int colorHex;

  const PipelineStage({
    required this.name,
    required this.count,
    required this.percentage,
    required this.colorHex,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PipelineStage &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          count == other.count &&
          percentage == other.percentage &&
          colorHex == other.colorHex;

  @override
  int get hashCode =>
      Object.hash(runtimeType, name, count, percentage, colorHex);

  @override
  String toString() =>
      'PipelineStage(name: $name, count: $count, percentage: $percentage, colorHex: $colorHex)';
}

class ClientSegment {
  final String name;
  final int count;
  final String badgeType;

  const ClientSegment({
    required this.name,
    required this.count,
    required this.badgeType,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClientSegment &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          count == other.count &&
          badgeType == other.badgeType;

  @override
  int get hashCode => Object.hash(runtimeType, name, count, badgeType);

  @override
  String toString() =>
      'ClientSegment(name: $name, count: $count, badgeType: $badgeType)';
}

class RecentProposal {
  final String id;
  final String code;
  final String clientName;
  final String serviceName;
  final String region;
  final String status;
  final String amount;

  const RecentProposal({
    required this.id,
    required this.code,
    required this.clientName,
    required this.serviceName,
    required this.region,
    required this.status,
    required this.amount,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecentProposal &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          code == other.code &&
          clientName == other.clientName &&
          serviceName == other.serviceName &&
          region == other.region &&
          status == other.status &&
          amount == other.amount;

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    code,
    clientName,
    serviceName,
    region,
    status,
    amount,
  );

  @override
  String toString() =>
      'RecentProposal(id: $id, code: $code, clientName: $clientName, serviceName: $serviceName, region: $region, status: $status, amount: $amount)';
}

class ExpiringContract {
  final String id;
  final String code;
  final String clientName;
  final String packageName;
  final String region;
  final String dueDate;
  final String amount;
  final bool isCritical;

  const ExpiringContract({
    required this.id,
    required this.code,
    required this.clientName,
    required this.packageName,
    required this.region,
    required this.dueDate,
    required this.amount,
    this.isCritical = false,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExpiringContract &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          code == other.code &&
          clientName == other.clientName &&
          packageName == other.packageName &&
          region == other.region &&
          dueDate == other.dueDate &&
          amount == other.amount &&
          isCritical == other.isCritical;

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    code,
    clientName,
    packageName,
    region,
    dueDate,
    amount,
    isCritical,
  );

  @override
  String toString() =>
      'ExpiringContract(id: $id, code: $code, clientName: $clientName, packageName: $packageName, region: $region, dueDate: $dueDate, amount: $amount, isCritical: $isCritical)';
}

class SalesDashboardSummary {
  final List<KpiMetric> kpis;
  final List<PipelineStage> pipelineStages;
  final List<ClientSegment> clientSegments;
  final List<RecentProposal> recentProposals;
  final List<ExpiringContract> expiringContracts;
  final String userName;
  final String branchName;

  const SalesDashboardSummary({
    required this.kpis,
    required this.pipelineStages,
    required this.clientSegments,
    required this.recentProposals,
    required this.expiringContracts,
    required this.userName,
    required this.branchName,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SalesDashboardSummary &&
          runtimeType == other.runtimeType &&
          kpis == other.kpis &&
          pipelineStages == other.pipelineStages &&
          clientSegments == other.clientSegments &&
          recentProposals == other.recentProposals &&
          expiringContracts == other.expiringContracts &&
          userName == other.userName &&
          branchName == other.branchName;

  @override
  int get hashCode => Object.hash(
    runtimeType,
    kpis,
    pipelineStages,
    clientSegments,
    recentProposals,
    expiringContracts,
    userName,
    branchName,
  );

  @override
  String toString() =>
      'SalesDashboardSummary(kpis: $kpis, pipelineStages: $pipelineStages, clientSegments: $clientSegments, recentProposals: $recentProposals, expiringContracts: $expiringContracts, userName: $userName, branchName: $branchName)';
}
