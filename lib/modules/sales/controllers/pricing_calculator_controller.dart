import 'dart:math' as math;
import 'package:signals/signals.dart';
import 'package:centrow_sales/shared/result/result.dart';
import 'package:centrow_sales/shared/error/failure.dart';
import 'package:centrow_sales/shared/state/ui_state.dart';
import 'package:centrow_sales/modules/core/entities/uom.dart';
import 'package:centrow_sales/modules/core/repositories/uom_repository.dart';
import 'package:centrow_sales/modules/pc/entities/product_mapping.dart';
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
  final Signal<double> unitCost;

  late final ReadonlySignal<double> qty = computed(() {
    if (kind == 2) return doseUsage.value;
    return doseUsage.value * applicationVolume.value;
  });

  late final ReadonlySignal<double> total = computed(() {
    if (kind == 2) {
      final months = contractMonthsRef?.value ?? 12;
      return (unitCost.value * doseUsage.value / months) * freq.value;
    }
    return doseUsage.value *
        applicationVolume.value *
        freq.value *
        unitCost.value;
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
    double initialUnitCost = 0.0,
  }) : productMappingId = signal(initialProductMappingId ?? id),
       doseUsage = signal(initialDoseUsage),
       doseUnitId = signal(initialDoseUnitId),
       applicationVolume = signal(initialApplicationVolume),
       applicationVolumeUnitId = signal(initialApplicationVolumeUnitId),
       freq = signal(initialFreq),
       unitCost = signal(initialUnitCost);

  void dispose() {
    productMappingId.dispose();
    doseUsage.dispose();
    doseUnitId.dispose();
    applicationVolume.dispose();
    applicationVolumeUnitId.dispose();
    freq.dispose();
    unitCost.dispose();
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

  late final ReadonlySignal<double> total = computed(
    () =>
        firstVisitHours.value * hourlyRate.value +
        math.max(0.0, visitFreq.value - 1.0) *
            routineHours.value *
            hourlyRate.value,
  );

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
  final Signal<double> unitCost;
  final Signal<double> unitPrice;

  late final ReadonlySignal<double> total = computed(
    () =>
        qty.value * freq.value * (kind == 5 ? unitPrice.value : unitCost.value),
  );

  PricingItemRow({
    required this.id,
    required this.title,
    required this.code,
    required this.kind,
    double initialQty = 1.0,
    double initialFreq = 1.0,
    double initialUnitCost = 0.0,
    double initialUnitPrice = 0.0,
  }) : qty = signal(initialQty),
       freq = signal(initialFreq),
       unitCost = signal(initialUnitCost),
       unitPrice = signal(initialUnitPrice);

  void dispose() {
    qty.dispose();
    freq.dispose();
    unitCost.dispose();
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

  final submitState = signal<UiState<void>>(const UiInitial());

  // Computed signals
  late final ReadonlySignal<double> cogsMaterial = computed(
    () => materials.fold(0.0, (sum, r) => sum + r.total.value),
  );

  late final ReadonlySignal<double> cogsWorker = computed(
    () => workers.fold(0.0, (sum, r) => sum + r.total.value),
  );

  late final ReadonlySignal<double> cogsTransport = computed(
    () => items
        .where((r) => r.kind == 3)
        .fold(0.0, (sum, r) => sum + r.total.value),
  );

  late final ReadonlySignal<double> addonCost = computed(
    () => items
        .where((r) => r.kind == 5)
        .fold(0.0, (sum, r) => sum + r.total.value),
  );

  late final ReadonlySignal<double> cogsTotal = computed(
    () => cogsMaterial.value + cogsWorker.value + cogsTransport.value,
  );

  late final ReadonlySignal<double> servicePrice = computed(() {
    final cogs = cogsTotal.value;
    return switch (markupType.value) {
      1 => cogs * (1 + markupPercent.value / 100),
      2 => cogs + markupPercent.value,
      3 => markupPercent.value,
      _ => cogs,
    };
  });

  late final ReadonlySignal<double> markupAmount = computed(
    () => servicePrice.value - cogsTotal.value,
  );

  late final ReadonlySignal<double> subtotal = computed(
    () => servicePrice.value + addonCost.value - discountAmount.value,
  );

  late final ReadonlySignal<double> taxAmount = computed(
    () => subtotal.value * (taxPercentage.value / 100),
  );

  late final ReadonlySignal<double> grandTotal = computed(
    () => subtotal.value + taxAmount.value,
  );

  late final ReadonlySignal<double> marginAmount = computed(
    () => subtotal.value - cogsTotal.value,
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
        initialUnitCost: mapping.unitPrice,
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
          initialUnitCost: product.cogs,
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
          initialUnitCost: product.cogs,
          initialUnitPrice: product.cogs,
        ),
      );
    }
  }

  int? _workerVisitFrequencyOverride(PricingWorkerRow w) {
    final headerFreq = visitFrequency.value ?? 12;
    final workerFreq = w.visitFreq.value.round();
    if (workerFreq == headerFreq || workerFreq <= 0) return null;
    return workerFreq;
  }

  Future<void> submitPricing(String customerId, String serviceId) async {
    submitState.value = const UiInitial();
    // Yield a tick so that signals can dispatch the initial state
    // before potentially updating to UiFailure immediately.
    await Future<void>.delayed(Duration.zero);

    for (final m in materials) {
      if (m.kind == 1) {
        // Chemical
        if (m.doseMinLimit != null && m.doseUsage.value < m.doseMinLimit!) {
          submitState.value = UiFailure(
            UnknownFailure(
              'Dosis untuk ${m.title} tidak boleh kurang dari batas minimum (${m.doseMinLimit}).',
            ),
          );
          return;
        }
        if (m.doseMaxLimit != null && m.doseUsage.value > m.doseMaxLimit!) {
          submitState.value = UiFailure(
            UnknownFailure(
              'Dosis untuk ${m.title} tidak boleh lebih dari batas maksimum (${m.doseMaxLimit}).',
            ),
          );
          return;
        }
      } else if (m.kind == 2) {
        // Tool
        if (m.doseUsage.value <= 0) {
          submitState.value = UiFailure(
            UnknownFailure('Qty untuk ${m.title} harus lebih dari 0.'),
          );
          return;
        }
      }
    }

    submitState.value = const UiLoading();

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
            positionName: l.title,
            visitFrequency: _workerVisitFrequencyOverride(l),
            firstVisitHours: l.firstVisitHours.value,
            routineHours: l.routineHours.value,
            hourlyRate: l.hourlyRate.value,
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

    final request = CreatePricingRequestDto(
      customerId: customerId,
      serviceId: serviceId,
      contractMonths: contractMonths.value ?? 12,
      visitFrequency: visitFrequency.value ?? 12,
      markupType: markupType.value,
      markupValue: markupPercent.value,
      discountAmount: discountAmount.value,
      taxPercentage: taxPercentage.value,
      materials: materialDtos,
      workers: workerDtos,
      items: itemDtos,
    );

    final result = await _repository.savePricing(request);

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
    visitFrequency.dispose();
    markupPercent.dispose();
    markupType.dispose();
    discountAmount.dispose();
    taxPercentage.dispose();
    submitState.dispose();
    uomState.dispose();
    uoms.dispose();
  }
}
