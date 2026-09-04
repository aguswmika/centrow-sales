import 'package:signals/signals.dart';
import 'package:centrow_sales/shared/result/result.dart';
import 'package:centrow_sales/shared/error/failure.dart';
import 'package:centrow_sales/shared/state/ui_state.dart';
import 'package:centrow_sales/modules/core/entities/uom.dart';
import 'package:centrow_sales/modules/core/repositories/uom_repository.dart';
import 'package:centrow_sales/modules/pc/entities/product_mapping.dart';
import 'package:centrow_sales/modules/sales/entities/pricing_detail.dart';
import 'package:centrow_sales/modules/sales/entities/pricing_preview.dart';
import 'package:centrow_sales/modules/sales/entities/product.dart';
import 'package:centrow_sales/modules/sales/repositories/pricing_repository.dart';
import 'package:centrow_sales/modules/sales/repositories/dtos/pricing_dto.dart';

class PricingMaterialRow {
  final String id;
  final String title;
  final String code;
  final String uomCode;
  final int kind;

  final double? doseMinLimit;
  final double? doseMaxLimit;
  final ReadonlySignal<int?>? contractMonthsRef;

  final Signal<String> productMappingId;
  final Signal<double> doseUsage;
  final Signal<String> doseUnitId;
  final Signal<double> applicationVolume;
  final Signal<String> applicationVolumeUnitId;
  final Signal<double> freq;

  late final ReadonlySignal<double> qty = computed(() {
    if (kind == 2) return doseUsage.value;
    return doseUsage.value * applicationVolume.value;
  });

  PricingMaterialRow({
    required this.id,
    required this.title,
    required this.code,
    required this.uomCode,
    required this.kind,
    this.doseMinLimit,
    this.doseMaxLimit,
    this.contractMonthsRef,
    String? initialProductMappingId,
    double initialDoseUsage = 1.0,
    String initialDoseUnitId = '',
    double initialApplicationVolume = 1.0,
    String initialApplicationVolumeUnitId = '',
    double initialFreq = 1.0,
  }) : productMappingId = signal(initialProductMappingId ?? id),
       doseUsage = signal(initialDoseUsage),
       doseUnitId = signal(initialDoseUnitId),
       applicationVolume = signal(initialApplicationVolume),
       applicationVolumeUnitId = signal(initialApplicationVolumeUnitId),
       freq = signal(initialFreq);

  void dispose() {
    productMappingId.dispose();
    doseUsage.dispose();
    doseUnitId.dispose();
    applicationVolume.dispose();
    applicationVolumeUnitId.dispose();
    freq.dispose();
  }
}

class PricingWorkerRow {
  final String id;
  final String title;
  final String code;
  final int kind;

  final Signal<double> visitFreq;
  final Signal<double> firstVisitHours;
  final Signal<double> routineHours;
  final Signal<double> hourlyRate;

  PricingWorkerRow({
    required this.id,
    required this.title,
    required this.code,
    required this.kind,
    double initialVisitFreq = 1.0,
    double initialFirstVisitHours = 0.0,
    double initialRoutineHours = 0.0,
    double initialHourlyRate = 0.0,
  }) : visitFreq = signal(initialVisitFreq),
       firstVisitHours = signal(initialFirstVisitHours),
       routineHours = signal(initialRoutineHours),
       hourlyRate = signal(initialHourlyRate);

  void dispose() {
    visitFreq.dispose();
    firstVisitHours.dispose();
    routineHours.dispose();
    hourlyRate.dispose();
  }
}

class PricingItemRow {
  final String id;
  final String title;
  final String code;
  final int kind;

  final Signal<double> qty;
  final Signal<double> freq;
  final Signal<double> unitPrice;

  PricingItemRow({
    required this.id,
    required this.title,
    required this.code,
    required this.kind,
    double initialQty = 1.0,
    double initialFreq = 1.0,
    double initialUnitPrice = 0.0,
  }) : qty = signal(initialQty),
       freq = signal(initialFreq),
       unitPrice = signal(initialUnitPrice);

  void dispose() {
    qty.dispose();
    freq.dispose();
    unitPrice.dispose();
  }
}

class PricingCalculatorController {
  final PricingRepository _repository;
  final UomRepository? _uomRepository;

  PricingCalculatorController(this._repository, [this._uomRepository]);

  final uoms = ListSignal<Uom>([]);
  final uomState = signal<UiState<List<Uom>>>(const UiInitial());

  Future<void> loadUoms() async {
    if (_uomRepository == null) return;
    uomState.value = const UiLoading();
    final result = await _uomRepository.getActiveUoms();
    uomState.value = switch (result) {
      Ok(:final value) => () {
        uoms.value = value;
        return UiSuccess(value);
      }(),
      Err(:final failure) => UiFailure(failure),
    };
  }

  final materials = ListSignal<PricingMaterialRow>([]);
  final workers = ListSignal<PricingWorkerRow>([]);
  final items = ListSignal<PricingItemRow>([]);

  final contractMonths = signal<int?>(null);
  final visitFrequency = signal<int?>(null);

  final markupPercent = signal<double>(0.0);
  final markupType = signal<int>(1); // 1=percent, 2=nominal, 3=target price
  final discountAmount = signal<double>(0.0);

  /// Default PPN rate in percent, used until the user overrides it.
  static const double defaultTaxPercentage = 0.0;

  /// Tax (PPN) rate in percent, editable from the COGS card.
  final taxPercentage = signal<double>(defaultTaxPercentage);

  final previewState = signal<UiState<PricingPreview>>(const UiInitial());
  final submitState = signal<UiState<void>>(const UiInitial());
  final existingPricingState = signal<UiState<PricingDetail>>(
    const UiInitial(),
  );

  void addMaterialRow(ProductMapping mapping) {
    if (materials.any((m) => m.id == mapping.productId)) return;
    materials.add(
      PricingMaterialRow(
        id: mapping.productId,
        title: mapping.productName,
        code: mapping.productCode ?? '',
        uomCode: mapping.doseUnitCode,
        kind: 1,
        initialProductMappingId: mapping.id,
        initialDoseUsage: mapping.defaultDose ?? mapping.doseMinLimit,
        initialDoseUnitId: mapping.doseUnitId,
        doseMinLimit: mapping.doseMinLimit,
        doseMaxLimit: mapping.doseMaxLimit,
        contractMonthsRef: contractMonths,
      ),
    );
  }

  void addRow(Product product, int expectedKind) {
    if (product.kind != null && product.kind != expectedKind) {
      throw StateError('Cross section attempt');
    }

    if (expectedKind == 1 || expectedKind == 2) {
      if (materials.any((m) => m.id == product.id)) return;
      materials.add(
        PricingMaterialRow(
          id: product.id,
          title: product.name,
          code: product.code,
          uomCode: product.uomCode,
          kind: expectedKind,
          initialProductMappingId: expectedKind == 1 ? '' : product.id,
          contractMonthsRef: contractMonths,
        ),
      );
    } else if (expectedKind == 4) {
      workers.add(
        PricingWorkerRow(
          id: product.id,
          title: product.name,
          code: product.code,
          kind: expectedKind,
          initialHourlyRate: product.cogs,
        ),
      );
    } else if (expectedKind == 3 || expectedKind == 5) {
      if (items.any((i) => i.id == product.id)) return;
      items.add(
        PricingItemRow(
          id: product.id,
          title: product.name,
          code: product.code,
          kind: expectedKind,
          initialUnitPrice: product.cogs,
        ),
      );
    }
  }

  int? _workerVisitFrequencyOverride(PricingWorkerRow w) {
    final workerFreq = w.visitFreq.value.round();
    if (workerFreq <= 0) return null;
    return workerFreq;
  }

  bool _validateInputs({required bool setOnPreview}) {
    for (final m in materials) {
      if (m.kind == 1) {
        // Chemical
        if (m.doseMinLimit != null && m.doseUsage.value < m.doseMinLimit!) {
          final failure = UnknownFailure(
            'Dosis untuk ${m.title} tidak boleh kurang dari batas minimum (${m.doseMinLimit}).',
          );
          if (setOnPreview) {
            previewState.value = UiFailure(failure);
          } else {
            submitState.value = UiFailure(failure);
          }
          return false;
        }
        if (m.doseMaxLimit != null && m.doseUsage.value > m.doseMaxLimit!) {
          final failure = UnknownFailure(
            'Dosis untuk ${m.title} tidak boleh lebih dari batas maksimum (${m.doseMaxLimit}).',
          );
          if (setOnPreview) {
            previewState.value = UiFailure(failure);
          } else {
            submitState.value = UiFailure(failure);
          }
          return false;
        }
      } else if (m.kind == 2) {
        // Tool
        if (m.doseUsage.value <= 0) {
          final failure = UnknownFailure(
            'Qty untuk ${m.title} harus lebih dari 0.',
          );
          if (setOnPreview) {
            previewState.value = UiFailure(failure);
          } else {
            submitState.value = UiFailure(failure);
          }
          return false;
        }
      }
    }
    return true;
  }

  CreatePricingRequestDto _buildRequest() {
    final materialDtos = materials
        .map(
          (m) => PricingMaterialDto(
            supplyType: m.kind,
            productMappingId: m.kind == 1
                ? (m.productMappingId.value.isNotEmpty
                      ? m.productMappingId.value
                      : null)
                : null,
            productId: m.kind == 2 ? m.id : null,
            name: m.title,
            uomCode: m.uomCode,
            qty: m.kind == 2 ? m.doseUsage.value : null,
            doseUsage: m.kind == 1 ? m.doseUsage.value : null,
            doseUnitId: m.kind == 1 ? m.doseUnitId.value : null,
            applicationVolume: m.kind == 1 ? m.applicationVolume.value : null,
            applicationVolumeUnitId: m.kind == 1
                ? m.applicationVolumeUnitId.value
                : null,
            frequency: m.freq.value.round(),
          ),
        )
        .toList();

    final workerDtos = workers
        .map(
          (l) => PricingWorkerDto(
            productId: l.id,
            visitFrequency: _workerVisitFrequencyOverride(l),
            firstVisitHours: l.firstVisitHours.value,
            routineHours: l.routineHours.value,
          ),
        )
        .toList();

    final itemDtos = items
        .map(
          (i) => PricingItemDto(
            itemType: i.kind == 5 ? 2 : 1,
            productId: i.id,
            name: i.title,
            qty: i.qty.value,
            frequency: i.freq.value.round(),
            unitPrice: i.kind == 5 ? i.unitPrice.value : null,
          ),
        )
        .toList();

    return CreatePricingRequestDto(
      contractMonths: contractMonths.value ?? 12,
      visitFrequency: visitFrequency.value ?? 1,
      markupType: markupType.value,
      markupValue: markupPercent.value,
      discountAmount: discountAmount.value,
      taxPercentage: taxPercentage.value,
      materials: materialDtos,
      workers: workerDtos,
      items: itemDtos,
    );
  }

  Future<void> previewPricing(String proposalId) async {
    previewState.value = const UiInitial();
    await Future<void>.delayed(Duration.zero);
    if (!_validateInputs(setOnPreview: true)) return;
    previewState.value = const UiLoading();
    final result = await _repository.previewPricing(
      proposalId,
      _buildRequest(),
    );
    previewState.value = switch (result) {
      Ok(:final value) => UiSuccess(value),
      Err(:final failure) => UiFailure(failure),
    };
  }

  Future<void> loadExistingPricing(String proposalId) async {
    existingPricingState.value = const UiLoading();
    final result = await _repository.getPricingDetail(proposalId);

    if (result.isOk) {
      final data = result.valueOrNull!;
      contractMonths.value = data.contractMonths;
      visitFrequency.value = data.visitFrequency;
      markupType.value = data.markupType;
      markupPercent.value = data.markupValue;
      discountAmount.value = data.discountAmount;
      taxPercentage.value = data.taxPercentage;

      materials.clear();
      for (final s in data.supplies) {
        materials.add(
          PricingMaterialRow(
            id: s.productId ?? s.id,
            title: s.name,
            code: '',
            uomCode: s.uomCode,
            kind: s.supplyType,
            initialProductMappingId: s.productMappingId,
            initialDoseUsage: s.doseUsage ?? s.qty,
            initialDoseUnitId: s.doseUnitId,
            initialApplicationVolume: s.applicationVolume ?? 1.0,
            initialApplicationVolumeUnitId: s.applicationVolumeUnitId,
            initialFreq: s.frequency.toDouble(),
            contractMonthsRef: contractMonths,
          ),
        );
      }

      workers.clear();
      for (final w in data.workers) {
        workers.add(
          PricingWorkerRow(
            id: w.productId,
            title: w.positionName,
            code: '',
            kind: 4,
            initialVisitFreq: (w.visitFrequency ?? 1).toDouble(),
            initialFirstVisitHours: w.firstVisitHours,
            initialRoutineHours: w.routineHours,
            initialHourlyRate: w.hourlyRate,
          ),
        );
      }

      items.clear();
      for (final i in data.items) {
        items.add(
          PricingItemRow(
            id: i.productId ?? i.id,
            title: i.name,
            code: '',
            kind: i.itemType == 2 ? 5 : 3,
            initialQty: i.qty,
            initialFreq: i.frequency.toDouble(),
            initialUnitPrice: i.unitPrice ?? 0.0,
          ),
        );
      }
    }

    existingPricingState.value = switch (result) {
      Ok(:final value) => UiSuccess(value),
      Err(:final failure) => UiFailure(failure),
    };
  }

  Future<void> submitPricing(String proposalId) async {
    submitState.value = const UiLoading();
    final result = await _repository.savePricing(proposalId, _buildRequest());
    submitState.value = switch (result) {
      Ok(:final value) => UiSuccess(value),
      Err(:final failure) => UiFailure(failure),
    };
  }

  void dispose() {
    for (final material in materials) {
      material.dispose();
    }
    materials.dispose();

    for (final worker in workers) {
      worker.dispose();
    }
    workers.dispose();

    for (final item in items) {
      item.dispose();
    }
    items.dispose();

    contractMonths.dispose();
    markupPercent.dispose();
    markupType.dispose();
    discountAmount.dispose();
    taxPercentage.dispose();
    previewState.dispose();
    submitState.dispose();
    existingPricingState.dispose();
    uomState.dispose();
    uoms.dispose();
  }
}
