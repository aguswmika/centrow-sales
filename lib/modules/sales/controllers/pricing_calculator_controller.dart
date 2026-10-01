import 'package:signals/signals.dart';
import 'package:centrow_sales/shared/state/ui_state.dart';
import 'package:centrow_sales/shared/error/failure.dart';
import 'package:centrow_sales/shared/result/result.dart';
import 'package:centrow_sales/modules/sales/entities/product.dart';
import 'package:centrow_sales/modules/pc/entities/product_mapping.dart';
import 'package:centrow_sales/modules/pc/entities/treatment_method.dart';
import 'package:centrow_sales/modules/core/entities/uom.dart';
import 'package:centrow_sales/modules/sales/entities/pricing_preview.dart';
import 'package:centrow_sales/modules/sales/entities/pricing_detail.dart';
import 'package:centrow_sales/modules/sales/repositories/dtos/pricing_dto.dart';
import 'package:centrow_sales/modules/sales/repositories/pricing_repository.dart';
import 'package:centrow_sales/modules/core/repositories/uom_repository.dart';
import 'package:centrow_sales/modules/pc/repositories/treatment_method_repository.dart';

class PricingSupplyRow {
  final String id;
  final String title;
  final String code;
  final String uomCode;
  final String? uomName;
  final int kind; // 1 = chemical, 2 = tool

  final Signal<String?> treatmentMethodId;
  final Signal<String?> treatmentMethodName;
  final Signal<String?> treatmentMethodCode;

  final Signal<String> areaKerja;
  final Signal<String> note;
  final Signal<int?> installedUnits;

  final double? doseMinLimit;
  final double? doseMaxLimit;
  final ReadonlySignal<int?>? contractMonthsRef;

  final Signal<String> productMappingId;
  final Signal<double> doseUsage;
  final Signal<String> doseUnitId;
  final Signal<double> applicationVolume;
  final Signal<String> applicationVolumeUnitId;
  final Signal<double> freq;
  final Signal<double> spkDoseUsage;
  Signal<double> get actualDosageUsage => spkDoseUsage;

  String get uomDisplayName =>
      (uomName != null && uomName!.isNotEmpty) ? uomName! : uomCode;

  late final ReadonlySignal<double> qty = computed(() {
    if (kind == 2) return doseUsage.value;
    return doseUsage.value * applicationVolume.value;
  });

  PricingSupplyRow({
    required this.id,
    required this.title,
    required this.code,
    required this.uomCode,
    this.uomName,
    required this.kind,
    String? initialTreatmentMethodId,
    String? initialTreatmentMethodName,
    String? initialTreatmentMethodCode,
    String? initialAreaKerja,
    String? initialNote,
    int? initialInstalledUnits,
    this.doseMinLimit,
    this.doseMaxLimit,
    this.contractMonthsRef,
    String? initialProductMappingId,
    double initialDoseUsage = 1.0,
    String initialDoseUnitId = '',
    double initialApplicationVolume = 1.0,
    String initialApplicationVolumeUnitId = '',
    double initialFreq = 1.0,
    double initialSpkDoseUsage = 1.0,
  }) : treatmentMethodId = signal(initialTreatmentMethodId),
       treatmentMethodName = signal(initialTreatmentMethodName),
       treatmentMethodCode = signal(initialTreatmentMethodCode),
       areaKerja = signal(initialAreaKerja ?? ''),
       note = signal(initialNote ?? ''),
       installedUnits = signal(initialInstalledUnits ?? (kind == 2 ? 1 : null)),
       productMappingId = signal(initialProductMappingId ?? id),
       doseUsage = signal(initialDoseUsage),
       doseUnitId = signal(initialDoseUnitId),
       applicationVolume = signal(initialApplicationVolume),
       applicationVolumeUnitId = signal(initialApplicationVolumeUnitId),
       freq = signal(initialFreq),
       spkDoseUsage = signal(initialSpkDoseUsage);

  void dispose() {
    treatmentMethodId.dispose();
    treatmentMethodName.dispose();
    treatmentMethodCode.dispose();
    areaKerja.dispose();
    note.dispose();
    installedUnits.dispose();
    productMappingId.dispose();
    doseUsage.dispose();
    doseUnitId.dispose();
    applicationVolume.dispose();
    applicationVolumeUnitId.dispose();
    freq.dispose();
    spkDoseUsage.dispose();
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
  final Signal<String> title;
  final String code;
  final int kind;

  final Signal<double> qty;
  final Signal<double> freq;
  final Signal<double> unitPrice;

  PricingItemRow({
    required this.id,
    String? title,
    String? initialTitle,
    required this.code,
    required this.kind,
    double initialQty = 1.0,
    double initialFreq = 1.0,
    double initialUnitPrice = 0.0,
  }) : title = signal(title ?? initialTitle ?? ''),
       qty = signal(initialQty),
       freq = signal(initialFreq),
       unitPrice = signal(initialUnitPrice);

  void dispose() {
    title.dispose();
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

  final treatmentMethods = ListSignal<TreatmentMethod>([]);
  final treatmentMethodState = signal<UiState<List<TreatmentMethod>>>(
    const UiInitial(),
  );

  Future<void> loadTreatmentMethods() async {
    if (_treatmentMethodRepository == null) return;
    treatmentMethodState.value = const UiLoading();
    final result = await _treatmentMethodRepository.getTreatmentMethods();
    treatmentMethodState.value = switch (result) {
      Ok(:final value) => () {
        treatmentMethods.value = value;
        return UiSuccess(value);
      }(),
      Err(:final failure) => UiFailure(failure),
    };
  }

  final supplies = ListSignal<PricingSupplyRow>([]);
  final workers = ListSignal<PricingWorkerRow>([]);
  final items = ListSignal<PricingItemRow>([]);

  final contractMonths = signal<int?>(null);
  final visitFrequency = signal<int?>(null);
  final totalVisits = signal<int?>(null);

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

  final _scheduleWorkOrderType = signal<int>(1);
  ReadonlySignal<int> get scheduleWorkOrderType => _scheduleWorkOrderType;

  void setContractMonths(int? months) {
    contractMonths.value = months;
    autoCalculateTotalVisits();
  }

  void setVisitFrequency(int? freq) {
    visitFrequency.value = freq;
    autoCalculateTotalVisits();
  }

  void setTotalVisits(int? visits) {
    totalVisits.value = visits;
  }

  void setScheduleWorkOrderType(int type) {
    _scheduleWorkOrderType.value = type;
  }

  void autoCalculateTotalVisits() {
    final months = contractMonths.value;
    final freq = visitFrequency.value;
    if (months != null && freq != null) {
      totalVisits.value = months * freq;
    } else {
      totalVisits.value = null;
    }
  }

  void addSupplyRow(ProductMapping mapping) {
    if (supplies.any((m) => m.id == mapping.productId)) return;
    supplies.add(
      PricingSupplyRow(
        id: mapping.productId,
        title: mapping.productName,
        code: mapping.productCode ?? '',
        uomCode: mapping.doseUnitCode,
        uomName: mapping.doseUnitName ?? mapping.doseUnitCode,
        kind: 1,
        initialTreatmentMethodId: mapping.treatmentMethodId,
        initialTreatmentMethodName: mapping.treatmentMethodName,
        initialTreatmentMethodCode: mapping.treatmentMethodCode,
        initialProductMappingId: mapping.id,
        initialDoseUsage: mapping.defaultDose ?? mapping.doseMinLimit,
        initialSpkDoseUsage: mapping.defaultDose ?? mapping.doseMinLimit,
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
      if (supplies.any((m) => m.id == product.id)) return;
      supplies.add(
        PricingSupplyRow(
          id: product.id,
          title: product.name,
          code: product.code,
          uomCode: product.uomCode,
          uomName: product.uomName.isNotEmpty
              ? product.uomName
              : product.uomCode,
          kind: expectedKind,
          initialProductMappingId: expectedKind == 1 ? '' : product.id,
          initialInstalledUnits: expectedKind == 2 ? 1 : null,
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

  void addCustomItem({
    String defaultTitle = 'Item Kustom',
    double initialPrice = 0.0,
  }) {
    final uniqueId = 'custom_${DateTime.now().microsecondsSinceEpoch}';
    items.add(
      PricingItemRow(
        id: uniqueId,
        title: defaultTitle,
        code: '',
        kind: 0,
        initialUnitPrice: initialPrice,
      ),
    );
  }

  int? _workerVisitFrequencyOverride(PricingWorkerRow w) {
    final workerFreq = w.visitFreq.value.round();
    if (workerFreq <= 0) return null;
    return workerFreq;
  }

  String? validateInputs() {
    final tv = totalVisits.value;
    if (tv == null || tv <= 0) {
      return 'Total kunjungan harus lebih dari 0.';
    }

    for (final m in supplies) {
      // Treatment method required on ALL supply lines
      if (m.treatmentMethodId.value == null ||
          m.treatmentMethodId.value!.isEmpty) {
        return 'Metode penanganan untuk ${m.title} wajib dipilih.';
      }
      if (m.kind == 1) {
        // Chemical: dose range
        if (m.doseMinLimit != null && m.doseUsage.value < m.doseMinLimit!) {
          return 'Dosis untuk ${m.title} tidak boleh kurang dari batas minimum (${m.doseMinLimit}).';
        }
        if (m.doseMaxLimit != null && m.doseUsage.value > m.doseMaxLimit!) {
          return 'Dosis untuk ${m.title} tidak boleh lebih dari batas maksimum (${m.doseMaxLimit}).';
        }
        // Chemical: SPK dose required
        if (m.spkDoseUsage.value <= 0) {
          return 'Dosis SPK untuk ${m.title} harus lebih dari 0.';
        }
      } else if (m.kind == 2) {
        // Tool
        if (m.doseUsage.value <= 0) {
          return 'Qty untuk ${m.title} harus lebih dari 0.';
        }
        final units = m.installedUnits.value;
        if (units == null || units <= 0) {
          return 'Jumlah unit terpasang untuk ${m.title} wajib diisi (> 0).';
        }
      }
    }
    for (final w in workers) {
      if (w.firstVisitMinutes.value < 0 || w.routineMinutes.value < 0) {
        return 'Menit kerja tidak boleh negatif.';
      }
    }
    for (final item in items) {
      if (item.kind == 0 && item.title.value.trim().isEmpty) {
        return 'Nama item kustom tidak boleh kosong.';
      }
    }
    return null;
  }

  bool _validateInputs({required bool setOnPreview}) {
    final err = validateInputs();
    if (err != null) {
      final failure = UnknownFailure(err);
      if (setOnPreview) {
        previewState.value = UiFailure<PricingPreview>(failure);
      } else {
        submitState.value = UiFailure<void>(failure);
      }
      return false;
    }
    return true;
  }

  CreatePricingRequestDto buildRequest() {
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
            treatmentMethodId: m.treatmentMethodId.value,
            areaKerja: m.areaKerja.value.trim().isEmpty
                ? null
                : m.areaKerja.value.trim(),
            note: m.note.value.trim().isEmpty ? null : m.note.value.trim(),
            installedUnits: m.kind == 2 ? m.installedUnits.value : null,
            spkDoseUsage: m.kind == 1 ? m.spkDoseUsage.value : null,
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
            itemType: (i.kind == 5 || i.kind == 0) ? 2 : 1,
            productId: i.kind == 0 ? null : (i.id.isNotEmpty ? i.id : null),
            name: i.title.value,
            qty: i.qty.value,
            frequency: i.freq.value.round(),
            unitPrice: (i.kind == 5 || i.kind == 0) ? i.unitPrice.value : null,
          ),
        )
        .toList();

    return CreatePricingRequestDto(
      contractMonths: contractMonths.value ?? 12,
      visitFrequency: visitFrequency.value ?? 1,
      totalVisits: totalVisits.value ?? 1,
      markupType: markupType.value,
      markupValue: markupPercent.value,
      discountAmount: discountAmount.value,
      taxPercentage: taxPercentage.value,
      scheduleWorkOrderType: _scheduleWorkOrderType.value,
      supplies: supplyDtos,
      workers: workerDtos,
      items: itemDtos,
    );
  }

  Future<void> previewPricing(String proposalId) async {
    previewState.value = const UiInitial();
    await Future<void>.delayed(Duration.zero);
    if (!_validateInputs(setOnPreview: true)) return;
    previewState.value = const UiLoading();
    final result = await _repository.previewPricing(proposalId, buildRequest());
    previewState.value = switch (result) {
      Ok(:final value) => UiSuccess(value),
      Err(:final failure) => UiFailure(failure),
    };
  }

  Future<void> loadExistingPricing(String proposalId) async {
    existingPricingState.value = const UiLoading();
    final result = await _repository.getPricingDetail(proposalId);

    if (result case Ok(:final value)) {
      final data = value;
      contractMonths.value = data.contractMonths;
      visitFrequency.value = data.visitFrequency;
      totalVisits.value = data.totalVisits;
      markupType.value = data.markupType;
      markupPercent.value = data.markupValue;
      discountAmount.value = data.discountAmount;
      taxPercentage.value = data.taxPercentage;
      _scheduleWorkOrderType.value = data.scheduleWorkOrderType;

      supplies.clear();
      for (final s in data.supplies) {
        supplies.add(
          PricingSupplyRow(
            id: s.productId ?? s.id,
            title: s.name,
            code: s.code,
            uomCode: s.uomCode,
            uomName: s.doseUnitName.isNotEmpty
                ? s.doseUnitName
                : (s.uomName.isNotEmpty ? s.uomName : s.uomCode),
            kind: s.supplyType,
            initialProductMappingId: s.productMappingId,
            initialDoseUsage: s.doseUsage ?? s.qty,
            initialSpkDoseUsage:
                s.actualDosageUsage ?? s.spkDoseUsage ?? (s.doseUsage ?? 1.0),
            initialDoseUnitId: s.doseUnitId,
            initialApplicationVolume: s.applicationVolume ?? 1.0,
            initialApplicationVolumeUnitId: s.applicationVolumeUnitId,
            initialFreq: s.frequency.toDouble(),
            initialTreatmentMethodId: s.treatmentMethodId,
            initialTreatmentMethodName: s.treatmentMethodName,
            initialTreatmentMethodCode: s.treatmentMethodCode,
            initialAreaKerja: s.areaKerja,
            initialNote: s.note,
            initialInstalledUnits: s.installedUnits,
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
            code: w.code,
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
        final isCustom =
            i.itemType == 2 && (i.productId == null || i.productId!.isEmpty);
        final itemKind = isCustom ? 0 : (i.itemType == 2 ? 5 : 3);
        items.add(
          PricingItemRow(
            id: i.productId ?? i.id,
            title: i.name,
            code: i.code,
            kind: itemKind,
            initialQty: i.qty,
            initialFreq: i.frequency.toDouble(),
            initialUnitPrice: (i.unitPrice != null && i.unitPrice! > 0)
                ? i.unitPrice!
                : (i.unitCost > 0 ? i.unitCost : 0.0),
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
    final result = await _repository.savePricing(proposalId, buildRequest());
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

    contractMonths.dispose();
    visitFrequency.dispose();
    totalVisits.dispose();
    markupPercent.dispose();
    markupType.dispose();
    discountAmount.dispose();
    taxPercentage.dispose();
    _scheduleWorkOrderType.dispose();
    previewState.dispose();
    submitState.dispose();
    existingPricingState.dispose();
    uomState.dispose();
    uoms.dispose();
    treatmentMethodState.dispose();
    treatmentMethods.dispose();
  }
}
