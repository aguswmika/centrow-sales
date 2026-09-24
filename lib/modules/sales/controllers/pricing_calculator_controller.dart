import 'package:signals/signals.dart';
import 'package:centrow_sales/shared/result/result.dart';
import 'package:centrow_sales/shared/error/failure.dart';
import 'package:centrow_sales/shared/state/ui_state.dart';
import 'package:centrow_sales/modules/core/entities/uom.dart';
import 'package:centrow_sales/modules/core/repositories/uom_repository.dart';
import 'package:centrow_sales/modules/pc/entities/product_mapping.dart';
import 'package:centrow_sales/modules/pc/entities/treatment_method.dart';
import 'package:centrow_sales/modules/pc/repositories/treatment_method_repository.dart';
import 'package:centrow_sales/modules/sales/entities/pricing_detail.dart';
import 'package:centrow_sales/modules/sales/entities/pricing_preview.dart';
import 'package:centrow_sales/modules/sales/entities/product.dart';
import 'package:centrow_sales/modules/sales/repositories/pricing_repository.dart';
import 'package:centrow_sales/modules/sales/repositories/dtos/pricing_dto.dart';

class PricingTreatmentQuotaRow {
  final String treatmentMethodId;
  final String treatmentMethodName;
  final String treatmentMethodCode;
  final bool isRequired;
  final Signal<int> quota;

  PricingTreatmentQuotaRow({
    required this.treatmentMethodId,
    required this.treatmentMethodName,
    required this.treatmentMethodCode,
    this.isRequired = false,
    int initialQuota = 1,
  }) : quota = signal(initialQuota);

  void dispose() {
    quota.dispose();
  }
}

class PricingSupplyRow {
  final String id;
  final String title;
  final String code;
  final String uomCode;
  final int kind;

  final String? treatmentMethodId;
  final String? treatmentMethodName;
  final String? treatmentMethodCode;

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

  PricingSupplyRow({
    required this.id,
    required this.title,
    required this.code,
    required this.uomCode,
    required this.kind,
    this.treatmentMethodId,
    this.treatmentMethodName,
    this.treatmentMethodCode,
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
  final Signal<double> firstVisitMinutes;
  final Signal<double> routineMinutes;
  final Signal<double> hourlyRate;

  PricingWorkerRow({
    required this.id,
    required this.title,
    required this.code,
    required this.kind,
    double initialVisitFreq = 1.0,
    double initialFirstVisitMinutes = 0.0,
    double initialRoutineMinutes = 0.0,
    double initialHourlyRate = 0.0,
  }) : visitFreq = signal(initialVisitFreq),
       firstVisitMinutes = signal(initialFirstVisitMinutes),
       routineMinutes = signal(initialRoutineMinutes),
       hourlyRate = signal(initialHourlyRate);

  void dispose() {
    visitFreq.dispose();
    firstVisitMinutes.dispose();
    routineMinutes.dispose();
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
  final TreatmentMethodRepository? _treatmentMethodRepository;

  PricingCalculatorController(
    this._repository, [
    this._uomRepository,
    this._treatmentMethodRepository,
  ]);

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

  final supplies = ListSignal<PricingSupplyRow>([]);
  final workers = ListSignal<PricingWorkerRow>([]);
  final items = ListSignal<PricingItemRow>([]);
  final _treatmentQuotas = ListSignal<PricingTreatmentQuotaRow>([]);

  ListSignal<PricingTreatmentQuotaRow> get treatmentQuotas => _treatmentQuotas;
  ReadonlySignal<List<PricingTreatmentQuotaRow>> get readonlyTreatmentQuotas =>
      _treatmentQuotas.readonly();

  void addTreatmentQuota(TreatmentMethod method, {int quota = 1}) {
    if (_treatmentQuotas.any((q) => q.treatmentMethodId == method.id)) {
      return;
    }
    _treatmentQuotas.add(
      PricingTreatmentQuotaRow(
        treatmentMethodId: method.id,
        treatmentMethodName: method.name,
        treatmentMethodCode: method.code,
        isRequired: method.isRequired,
        initialQuota: quota > 0 ? quota : 1,
      ),
    );
  }

  void removeTreatmentQuota(String treatmentMethodId) {
    final index = _treatmentQuotas.indexWhere(
      (q) => q.treatmentMethodId == treatmentMethodId,
    );
    if (index != -1) {
      final removed = _treatmentQuotas.removeAt(index);
      removed.dispose();
    }
  }

  void updateTreatmentQuota(String treatmentMethodId, int newQuota) {
    final index = _treatmentQuotas.indexWhere(
      (q) => q.treatmentMethodId == treatmentMethodId,
    );
    if (index != -1 && newQuota >= 0) {
      _treatmentQuotas[index].quota.value = newQuota;
    }
  }

  void populateRequiredMethods(List<TreatmentMethod> methods) {
    for (final method in methods) {
      if (method.isRequired &&
          !_treatmentQuotas.any((q) => q.treatmentMethodId == method.id)) {
        _treatmentQuotas.add(
          PricingTreatmentQuotaRow(
            treatmentMethodId: method.id,
            treatmentMethodName: method.name,
            treatmentMethodCode: method.code,
            isRequired: true,
            initialQuota: 1,
          ),
        );
      }
    }
  }

  Future<void> populateRequiredMethodsFromRepo() async {
    if (_treatmentMethodRepository == null) return;
    final result = await _treatmentMethodRepository.getTreatmentMethods();
    if (result is Ok<List<TreatmentMethod>>) {
      populateRequiredMethods(result.value);
    }
  }

  void populateFromSupplies() {
    for (final supply in supplies) {
      final methodId = supply.treatmentMethodId;
      if (methodId != null &&
          methodId.isNotEmpty &&
          !_treatmentQuotas.any((q) => q.treatmentMethodId == methodId)) {
        _treatmentQuotas.add(
          PricingTreatmentQuotaRow(
            treatmentMethodId: methodId,
            treatmentMethodName:
                supply.treatmentMethodName ??
                supply.treatmentMethodCode ??
                methodId,
            treatmentMethodCode: supply.treatmentMethodCode ?? '',
            isRequired: true,
            initialQuota: 1,
          ),
        );
      }
    }
  }

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

  void addSupplyRow(ProductMapping mapping) {
    if (supplies.any((m) => m.id == mapping.productId)) return;
    supplies.add(
      PricingSupplyRow(
        id: mapping.productId,
        title: mapping.productName,
        code: mapping.productCode ?? '',
        uomCode: mapping.doseUnitCode,
        kind: 1,
        treatmentMethodId: mapping.treatmentMethodId,
        treatmentMethodName: mapping.treatmentMethodName,
        treatmentMethodCode: mapping.treatmentMethodCode,
        initialProductMappingId: mapping.id,
        initialDoseUsage: mapping.defaultDose ?? mapping.doseMinLimit,
        initialDoseUnitId: mapping.doseUnitId,
        doseMinLimit: mapping.doseMinLimit,
        doseMaxLimit: mapping.doseMaxLimit,
        contractMonthsRef: contractMonths,
      ),
    );
    if (mapping.treatmentMethodId.isNotEmpty) {
      addTreatmentQuota(
        TreatmentMethod(
          id: mapping.treatmentMethodId,
          code: mapping.treatmentMethodCode,
          name: mapping.treatmentMethodName ?? mapping.treatmentMethodCode,
          isRequired: true,
        ),
      );
    }
  }

  void addRow(Product product, int expectedKind) {
    if (product.kind != null && product.kind != expectedKind) {
      throw StateError('Cross section attempt');
    }

    if (expectedKind == 1 || expectedKind == 2) {
      if (supplies.any((m) => m.id == product.id)) return;
      supplies.add(
        PricingSupplyRow(
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
    for (final m in supplies) {
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
    for (final w in workers) {
      if (w.firstVisitMinutes.value < 0 || w.routineMinutes.value < 0) {
        const failure = UnknownFailure('Menit kerja tidak boleh negatif.');
        if (setOnPreview) {
          previewState.value = const UiFailure<PricingPreview>(failure);
        } else {
          submitState.value = const UiFailure<void>(failure);
        }
        return false;
      }
    }
    return true;
  }

  CreatePricingRequestDto _buildRequest() {
    final supplyDtos = supplies
        .map(
          (m) => PricingSupplyDto(
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
            firstVisitMinutes: l.firstVisitMinutes.value,
            routineMinutes: l.routineMinutes.value,
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

    final quotaDtos = _treatmentQuotas
        .map(
          (q) => PricingTreatmentQuotaDto(
            treatmentMethodId: q.treatmentMethodId,
            quota: q.quota.value,
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
      supplies: supplyDtos,
      workers: workerDtos,
      items: itemDtos,
      treatmentQuotas: quotaDtos,
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

      supplies.clear();
      for (final s in data.supplies) {
        supplies.add(
          PricingSupplyRow(
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
            initialFirstVisitMinutes: w.firstVisitMinutes,
            initialRoutineMinutes: w.routineMinutes,
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

      for (final q in _treatmentQuotas) {
        q.dispose();
      }
      _treatmentQuotas.clear();
      for (final q in data.treatmentQuotas) {
        _treatmentQuotas.add(
          PricingTreatmentQuotaRow(
            treatmentMethodId: q.treatmentMethodId,
            treatmentMethodName: q.treatmentMethodName,
            treatmentMethodCode: q.treatmentMethodCode,
            isRequired: q.isRequired,
            initialQuota: q.quota,
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
    submitState.value = const UiInitial();
    await Future<void>.delayed(Duration.zero);
    if (!_validateInputs(setOnPreview: false)) return;
    submitState.value = const UiLoading();
    final result = await _repository.savePricing(proposalId, _buildRequest());
    submitState.value = switch (result) {
      Ok(:final value) => UiSuccess(value),
      Err(:final failure) => UiFailure(failure),
    };
  }

  void dispose() {
    for (final supply in supplies) {
      supply.dispose();
    }
    supplies.dispose();

    for (final worker in workers) {
      worker.dispose();
    }
    workers.dispose();

    for (final item in items) {
      item.dispose();
    }
    items.dispose();

    for (final quota in _treatmentQuotas) {
      quota.dispose();
    }
    _treatmentQuotas.dispose();

    contractMonths.dispose();
    visitFrequency.dispose();
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
