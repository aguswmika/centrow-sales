import 'package:centrow_sales/modules/sales/entities/contract_addendum.dart';
import 'package:centrow_sales/modules/sales/repositories/dtos/pricing_dto.dart';

class ContractAddendumDto {
  final String id;
  final String contractId;
  final int visitDelta;
  final int oldTotalVisits;
  final int newTotalVisits;
  final double oldContractValue;
  final double newContractValue;
  final String? pricingId;
  final String? reason;
  final String? createdBy;
  final String? createdAt;

  const ContractAddendumDto({
    required this.id,
    required this.contractId,
    required this.visitDelta,
    required this.oldTotalVisits,
    required this.newTotalVisits,
    required this.oldContractValue,
    required this.newContractValue,
    this.pricingId,
    this.reason,
    this.createdBy,
    this.createdAt,
  });

  factory ContractAddendumDto.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic val) {
      if (val is num) return val.toInt();
      if (val is String) return int.tryParse(val) ?? 0;
      return 0;
    }

    double parseDouble(dynamic val) {
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val) ?? 0.0;
      return 0.0;
    }

    String? parseCreatedBy(dynamic json) {
      if (json['created_by_name'] != null) {
        return json['created_by_name'].toString();
      }
      final creator = json['creator'];
      if (creator is Map && creator['name'] != null) {
        return creator['name'].toString();
      }
      if (json['created_by'] != null) {
        return json['created_by'].toString();
      }
      return null;
    }

    return ContractAddendumDto(
      id: json['id']?.toString() ?? '',
      contractId:
          json['contract_id']?.toString() ??
          json['contractId']?.toString() ??
          '',
      visitDelta: parseInt(json['visit_delta'] ?? json['visitDelta']),
      oldTotalVisits: parseInt(
        json['old_total_visits'] ?? json['oldTotalVisits'],
      ),
      newTotalVisits: parseInt(
        json['new_total_visits'] ?? json['newTotalVisits'],
      ),
      oldContractValue: parseDouble(
        json['old_contract_value'] ?? json['oldContractValue'],
      ),
      newContractValue: parseDouble(
        json['new_contract_value'] ?? json['newContractValue'],
      ),
      pricingId:
          json['pricing_id']?.toString() ?? json['pricingId']?.toString(),
      reason: json['reason']?.toString(),
      createdBy: parseCreatedBy(json),
      createdAt:
          json['created_at']?.toString() ?? json['createdAt']?.toString(),
    );
  }

  ContractAddendum toEntity() => ContractAddendum(
    id: id,
    contractId: contractId,
    visitDelta: visitDelta,
    oldTotalVisits: oldTotalVisits,
    newTotalVisits: newTotalVisits,
    oldContractValue: oldContractValue,
    newContractValue: newContractValue,
    pricingId: pricingId,
    reason: reason,
    createdBy: createdBy,
    createdAt: createdAt,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'contract_id': contractId,
    'visit_delta': visitDelta,
    'old_total_visits': oldTotalVisits,
    'new_total_visits': newTotalVisits,
    'old_contract_value': oldContractValue,
    'new_contract_value': newContractValue,
    if (pricingId != null) 'pricing_id': pricingId,
    if (reason != null) 'reason': reason,
    if (createdBy != null) 'created_by': createdBy,
    if (createdAt != null) 'created_at': createdAt,
  };
}

class CreateContractAddendumRequestDto {
  final int contractMonths;
  final int visitFrequency;
  final int totalVisits;
  final int markupType;
  final double markupValue;
  final double discountAmount;
  final double taxPercentage;
  final List<PricingSupplyDto> supplies;
  final List<PricingWorkerDto> workers;
  final List<PricingItemDto> items;
  final String? reason;
  final int scheduleWorkOrderType;

  const CreateContractAddendumRequestDto({
    required this.contractMonths,
    required this.visitFrequency,
    required this.totalVisits,
    required this.markupType,
    required this.markupValue,
    required this.discountAmount,
    required this.taxPercentage,
    required this.supplies,
    required this.workers,
    required this.items,
    this.reason,
    this.scheduleWorkOrderType = 1,
  });

  factory CreateContractAddendumRequestDto.fromPricingRequest(
    CreatePricingRequestDto pricing, {
    String? reason,
  }) {
    return CreateContractAddendumRequestDto(
      contractMonths: pricing.contractMonths,
      visitFrequency: pricing.visitFrequency,
      totalVisits: pricing.totalVisits,
      markupType: pricing.markupType,
      markupValue: pricing.markupValue,
      discountAmount: pricing.discountAmount,
      taxPercentage: pricing.taxPercentage,
      supplies: pricing.supplies,
      workers: pricing.workers,
      items: pricing.items,
      reason: reason,
      scheduleWorkOrderType: pricing.scheduleWorkOrderType,
    );
  }

  Map<String, dynamic> toJson() => {
    'contract_months': contractMonths,
    'visit_frequency': visitFrequency,
    'total_visits': totalVisits,
    'markup_type': markupType,
    'markup_value': markupValue,
    'discount_amount': discountAmount,
    'tax_percentage': taxPercentage,
    'schedule_work_order_type': scheduleWorkOrderType,
    'supplies': supplies.map((e) => e.toJson()).toList(),
    'workers': workers.map((e) => e.toJson()).toList(),
    'items': items.map((e) => e.toJson()).toList(),
    if (reason != null && reason!.trim().isNotEmpty) 'reason': reason!.trim(),
  };
}
