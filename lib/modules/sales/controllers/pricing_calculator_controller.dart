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

  final Signal<String> productMappingId;
  final Signal<double> doseUsage;
  final Signal<String> doseUnitId;
  final Signal<double> applicationVolume;
  final Signal<String> applicationVolumeUnitId;
  final Signal<double> freq;
  final Signal<double> unitCost;

  late final ReadonlySignal<double> qty = computed(
    () => doseUsage.value * applicationVolume.value,
  );

  late final ReadonlySignal<double> total = computed(
    () =>
        doseUsage.value * applicationVolume.value * freq.value * unitCost.value,
  );

  PricingMaterialRow({
    required this.id,
    required this.title,
    required this.code,
    required this.uomCode,
    required this.kind,
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

class PricingLaborRow {
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

  PricingLaborRow({
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
  final labors = ListSignal<PricingLaborRow>([]);
  final items = ListSignal<PricingItemRow>([]);

  final areaValue = signal<double?>(null);
  final areaUnitId = signal<String?>(null);
  final contractMonths = signal<int?>(null);
  final visitFrequency = signal<int?>(null);

  final markupPercent = signal<double>(0.0);
  final discountAmount = signal<double>(0.0);

  final submitState = signal<UiState<void>>(const UiInitial());

  // Computed signals
  late final ReadonlySignal<double> cogsMaterial = computed(
    () => materials.fold(0.0, (sum, r) => sum + r.total.value),
  );

  late final ReadonlySignal<double> cogsLabor = computed(
    () => labors.fold(0.0, (sum, r) => sum + r.total.value),
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
    () => cogsMaterial.value + cogsLabor.value + cogsTransport.value,
  );

  late final ReadonlySignal<double> markupAmount = computed(
    () => cogsTotal.value * (markupPercent.value / 100),
  );

  late final ReadonlySignal<double> servicePrice = computed(
    () => cogsTotal.value + markupAmount.value,
  );

  late final ReadonlySignal<double> subtotal = computed(
    () => servicePrice.value + addonCost.value - discountAmount.value,
  );

  late final ReadonlySignal<double> taxAmount = computed(
    () => subtotal.value * 0.11,
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
        ),
      );
    } else if (expectedKind == 4) {
      labors.add(
        PricingLaborRow(
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

  Future<void> submitPricing(String customerId, String serviceId) async {
    for (final m in materials) {
      if (m.doseUsage.value <= 0) {
        submitState.value = UiFailure(
          UnknownFailure('Dosis untuk ${m.title} harus lebih dari 0.'),
        );
        return;
      }
    }

    submitState.value = const UiLoading();

    final materialDtos = materials
        .map(
          (m) => PricingMaterialDto(
            productMappingId: m.productMappingId.value.isNotEmpty
                ? m.productMappingId.value
                : m.id,
            name: m.title,
            uomCode: m.uomCode,
            doseUsage: m.doseUsage.value,
            doseUnitId: m.doseUnitId.value,
            applicationVolume: m.applicationVolume.value,
            applicationVolumeUnitId: m.applicationVolumeUnitId.value,
            frequency: m.freq.value.round(),
          ),
        )
        .toList();

    final laborDtos = labors
        .map(
          (l) => PricingLaborDto(
            positionName: l.title,
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
      areaValue: areaValue.value,
      areaUnitId: areaUnitId.value,
      contractMonths: contractMonths.value ?? 12,
      visitFrequency: visitFrequency.value ?? 12,
      markupType: 1,
      markupValue: markupPercent.value,
      discountAmount: discountAmount.value,
      materials: materialDtos,
      labors: laborDtos,
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

    for (final labor in labors) {
      labor.dispose();
    }
    labors.dispose();

    for (final item in items) {
      item.dispose();
    }
    items.dispose();

    areaValue.dispose();
    areaUnitId.dispose();
    contractMonths.dispose();
    visitFrequency.dispose();
    markupPercent.dispose();
    discountAmount.dispose();
    submitState.dispose();
    uomState.dispose();
    uoms.dispose();
  }
}
