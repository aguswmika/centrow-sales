enum ProposalStatus {
  draft('Draft', 'neutral', 'draft'),
  dikirim('Dikirim', 'info', 'sent'),
  negosiasi('Negosiasi', 'warn', 'negotiation'),
  disetujui('Disetujui', 'ok', 'accepted'),
  ditolak('Ditolak', 'err', 'rejected');

  final String displayName;
  final String badgeType;
  final String value;

  const ProposalStatus(this.displayName, this.badgeType, this.value);

  static ProposalStatus fromString(String val) {
    final lower = val.toLowerCase().trim();
    for (final status in ProposalStatus.values) {
      if (status.value == lower ||
          status.name.toLowerCase() == lower ||
          status.displayName.toLowerCase() == lower) {
        return status;
      }
    }
    return ProposalStatus.draft;
  }
}

enum ProposalItemCategory {
  persiapan('persiapan', '1. Persiapan Bahan & Alat', 'cp-persiapan'),
  teknisi('teknisi', '2. Tenaga Kerja & Teknisi', 'cp-teknisi'),
  transport('transport', '3. Transport & Add-on', 'cp-items');

  final String value;
  final String displayName;
  final String tabKey;

  const ProposalItemCategory(this.value, this.displayName, this.tabKey);

  static ProposalItemCategory fromString(String val) {
    final lower = val.toLowerCase().trim();
    for (final cat in ProposalItemCategory.values) {
      if (cat.value == lower ||
          cat.name.toLowerCase() == lower ||
          cat.tabKey.toLowerCase() == lower ||
          cat.displayName.toLowerCase() == lower) {
        return cat;
      }
    }
    return ProposalItemCategory.persiapan;
  }
}

class ProposalItem {
  final String id;
  final String title;
  final String description;
  final ProposalItemCategory category;
  final double price;

  const ProposalItem({
    this.id = '',
    required this.title,
    this.description = '',
    required this.category,
    this.price = 0.0,
  });

  String get formattedPrice => _formatCurrency(price);

  ProposalItem copyWith({
    String? id,
    String? title,
    String? description,
    ProposalItemCategory? category,
    double? price,
  }) {
    return ProposalItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      price: price ?? this.price,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProposalItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          description == other.description &&
          category == other.category &&
          price == other.price;

  @override
  int get hashCode => Object.hash(id, title, description, category, price);

  @override
  String toString() =>
      'ProposalItem(id: $id, title: $title, category: ${category.value}, price: $price)';
}

class Proposal {
  final String id;
  final String code;
  final String clientName;
  final String serviceName;
  final ProposalStatus status;
  final String date;
  final String validUntil;
  final String location;
  final String version;
  final double cogs;
  final double materialCost;
  final double laborCost;
  final double fuelCost;
  final double markup;
  final double markupPercent;
  final double servicePrice;
  final double addon;
  final double subtotal;
  final double tax;
  final double total;
  final double marginPct;
  final double marginAmt;
  final double ppv;
  final double ppm;
  final List<ProposalItem> items;
  final String? notes;
  final String? sentAt;
  final String? decidedAt;
  final String? rejectionReason;
  final String? createdAt;
  final String? explicitInitials;
  final String? explicitShortAmount;
  final String? explicitShortMarginAmt;

  const Proposal({
    required this.id,
    required this.code,
    required this.clientName,
    required this.serviceName,
    required this.status,
    required this.date,
    required this.validUntil,
    required this.location,
    this.version = '1',
    this.cogs = 0.0,
    this.materialCost = 0.0,
    this.laborCost = 0.0,
    this.fuelCost = 0.0,
    this.markup = 0.0,
    this.markupPercent = 0.0,
    this.servicePrice = 0.0,
    this.addon = 0.0,
    this.subtotal = 0.0,
    this.tax = 0.0,
    this.total = 0.0,
    this.marginPct = 0.0,
    this.marginAmt = 0.0,
    this.ppv = 0.0,
    this.ppm = 0.0,
    this.items = const [],
    this.notes,
    this.sentAt,
    this.decidedAt,
    this.rejectionReason,
    this.createdAt,
    String? initials,
    String? shortAmount,
    String? shortMarginAmt,
  }) : explicitInitials = initials,
       explicitShortAmount = shortAmount,
       explicitShortMarginAmt = shortMarginAmt;

  String get initials {
    final exp = explicitInitials;
    if (exp != null && exp.isNotEmpty) return exp;
    final parts = clientName
        .trim()
        .split(' ')
        .where((e) => e.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'PR';
    if (parts.length == 1) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  String get formattedTotal => _formatCurrency(total);
  String get shortAmount => explicitShortAmount ?? _formatShortCurrency(total);

  String get formattedCogs => _formatCurrency(cogs);
  String get formattedMaterialCost => _formatCurrency(materialCost);
  String get formattedLaborCost => _formatCurrency(laborCost);
  String get formattedFuelCost => _formatCurrency(fuelCost);
  String get formattedMarkup {
    if (markupPercent > 0) {
      final pctStr = markupPercent % 1 == 0
          ? markupPercent.toInt().toString()
          : markupPercent.toStringAsFixed(1);
      return '+ ${_formatCurrency(markup)} ($pctStr%)';
    }
    return '+ ${_formatCurrency(markup)}';
  }

  String get formattedServicePrice => _formatCurrency(servicePrice);
  String get formattedAddon => _formatCurrency(addon);
  String get formattedSubtotal => _formatCurrency(subtotal);
  String get formattedTax => _formatCurrency(tax);
  String get formattedMarginPct => '${marginPct.toStringAsFixed(1)}%';
  String get formattedMarginAmt =>
      explicitShortMarginAmt ?? _formatShortCurrency(marginAmt);
  String get formattedPpv => _formatCurrency(ppv);
  String get formattedPpm => _formatCurrency(ppm);
  String get displayVersion => 'Versi $version';
  String get displayTitle => '$code · $clientName';
  String get badgeType => status.badgeType;

  List<ProposalItem> get persiapanItems =>
      items.where((i) => i.category == ProposalItemCategory.persiapan).toList();

  List<ProposalItem> get teknisiItems =>
      items.where((i) => i.category == ProposalItemCategory.teknisi).toList();

  List<ProposalItem> get transportItems =>
      items.where((i) => i.category == ProposalItemCategory.transport).toList();

  List<ProposalItem> getItemsByCategory(ProposalItemCategory category) =>
      items.where((i) => i.category == category).toList();

  Proposal copyWith({
    String? id,
    String? code,
    String? clientName,
    String? serviceName,
    ProposalStatus? status,
    String? date,
    String? validUntil,
    String? location,
    String? version,
    double? cogs,
    double? materialCost,
    double? laborCost,
    double? fuelCost,
    double? markup,
    double? markupPercent,
    double? servicePrice,
    double? addon,
    double? subtotal,
    double? tax,
    double? total,
    double? marginPct,
    double? marginAmt,
    double? ppv,
    double? ppm,
    List<ProposalItem>? items,
    String? notes,
    String? sentAt,
    String? decidedAt,
    String? rejectionReason,
    String? createdAt,
    String? initials,
    String? shortAmount,
    String? shortMarginAmt,
  }) {
    return Proposal(
      id: id ?? this.id,
      code: code ?? this.code,
      clientName: clientName ?? this.clientName,
      serviceName: serviceName ?? this.serviceName,
      status: status ?? this.status,
      date: date ?? this.date,
      validUntil: validUntil ?? this.validUntil,
      location: location ?? this.location,
      version: version ?? this.version,
      cogs: cogs ?? this.cogs,
      materialCost: materialCost ?? this.materialCost,
      laborCost: laborCost ?? this.laborCost,
      fuelCost: fuelCost ?? this.fuelCost,
      markup: markup ?? this.markup,
      markupPercent: markupPercent ?? this.markupPercent,
      servicePrice: servicePrice ?? this.servicePrice,
      addon: addon ?? this.addon,
      subtotal: subtotal ?? this.subtotal,
      tax: tax ?? this.tax,
      total: total ?? this.total,
      marginPct: marginPct ?? this.marginPct,
      marginAmt: marginAmt ?? this.marginAmt,
      ppv: ppv ?? this.ppv,
      ppm: ppm ?? this.ppm,
      items: items ?? this.items,
      notes: notes ?? this.notes,
      sentAt: sentAt ?? this.sentAt,
      decidedAt: decidedAt ?? this.decidedAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      createdAt: createdAt ?? this.createdAt,
      initials: initials ?? explicitInitials,
      shortAmount: shortAmount ?? explicitShortAmount,
      shortMarginAmt: shortMarginAmt ?? explicitShortMarginAmt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Proposal &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          code == other.code &&
          clientName == other.clientName &&
          serviceName == other.serviceName &&
          status == other.status &&
          date == other.date &&
          validUntil == other.validUntil &&
          location == other.location &&
          version == other.version &&
          cogs == other.cogs &&
          materialCost == other.materialCost &&
          laborCost == other.laborCost &&
          fuelCost == other.fuelCost &&
          markup == other.markup &&
          markupPercent == other.markupPercent &&
          servicePrice == other.servicePrice &&
          addon == other.addon &&
          subtotal == other.subtotal &&
          tax == other.tax &&
          total == other.total &&
          marginPct == other.marginPct &&
          marginAmt == other.marginAmt &&
          ppv == other.ppv &&
          ppm == other.ppm &&
          notes == other.notes &&
          sentAt == other.sentAt &&
          decidedAt == other.decidedAt &&
          rejectionReason == other.rejectionReason &&
          createdAt == other.createdAt;

  @override
  int get hashCode => Object.hashAll([
    id,
    code,
    clientName,
    serviceName,
    status,
    date,
    validUntil,
    location,
    version,
    cogs,
    materialCost,
    laborCost,
    fuelCost,
    markup,
    markupPercent,
    servicePrice,
    addon,
    subtotal,
    tax,
    total,
    marginPct,
    marginAmt,
    ppv,
    ppm,
    notes,
    sentAt,
    decidedAt,
    rejectionReason,
    createdAt,
  ]);

  @override
  String toString() =>
      "Proposal(id: $id, code: $code, clientName: $clientName, serviceName: $serviceName, status: ${status.name}, total: $total)";
}

String _formatCurrency(double amount) {
  if (amount == 0) return 'Rp 0';
  final isNegative = amount < 0;
  final absAmount = amount.abs();
  final intPart = absAmount.truncate();
  final formattedInt = intPart.toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (Match m) => '${m[1]}.',
  );
  return isNegative ? '-Rp $formattedInt' : 'Rp $formattedInt';
}

String _formatShortCurrency(double amount) {
  final isNegative = amount < 0;
  final absAmount = amount.abs();
  String result;
  if (absAmount >= 1000000000) {
    final b = absAmount / 1000000000;
    final formatted =
        (b % 1 == 0
                ? b.toInt().toString()
                : b
                      .toStringAsFixed(2)
                      .replaceAll(RegExp(r'0+$'), '')
                      .replaceAll(RegExp(r'\.$'), ''))
            .replaceAll('.', ',');
    result = 'Rp ${formatted}M';
  } else if (absAmount >= 1000000) {
    final m = absAmount / 1000000;
    final formatted =
        (m % 1 == 0
                ? m.toInt().toString()
                : m
                      .toStringAsFixed(2)
                      .replaceAll(RegExp(r'0+$'), '')
                      .replaceAll(RegExp(r'\.$'), ''))
            .replaceAll('.', ',');
    result = 'Rp ${formatted}jt';
  } else if (absAmount >= 1000) {
    final k = absAmount / 1000;
    final formatted =
        (k % 1 == 0
                ? k.toInt().toString()
                : k
                      .toStringAsFixed(1)
                      .replaceAll(RegExp(r'0+$'), '')
                      .replaceAll(RegExp(r'\.$'), ''))
            .replaceAll('.', ',');
    result = 'Rp ${formatted}rb';
  } else {
    result = _formatCurrency(amount);
  }
  return isNegative ? '-$result' : result;
}
