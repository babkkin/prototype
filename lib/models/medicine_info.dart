class MedicineInfo {
  final String name;
  final String drugClass;
  final String usedFor;
  final String howItWorks;
  final List<String> commonSideEffects;
  final List<String> adverseEffects;
  final String warnings;
  final String olderAdultSafety;
  final String caregiverGuidance;
  final List<String> sources;

  const MedicineInfo({
    required this.name,
    this.drugClass = '',
    this.usedFor = '',
    this.howItWorks = '',
    this.commonSideEffects = const [],
    this.adverseEffects = const [],
    this.warnings = '',
    this.olderAdultSafety = '',
    this.caregiverGuidance = '',
    this.sources = const [],
  });

  /// True when the reference sheet has details for this medicine.
  bool get hasDetails =>
      drugClass.isNotEmpty ||
      usedFor.isNotEmpty ||
      howItWorks.isNotEmpty ||
      commonSideEffects.isNotEmpty ||
      adverseEffects.isNotEmpty ||
      warnings.isNotEmpty ||
      olderAdultSafety.isNotEmpty ||
      caregiverGuidance.isNotEmpty;

  factory MedicineInfo.fromJson(Map<String, dynamic> json) {
    List<String> list(String key) => (json[key] as List<dynamic>? ?? const [])
        .map((e) => e.toString())
        .toList();

    String text(String key) => json[key]?.toString() ?? '';

    return MedicineInfo(
      name: text('name'),
      drugClass: text('drugClass'),
      usedFor: text('usedFor'),
      howItWorks: text('howItWorks'),
      commonSideEffects: list('commonSideEffects'),
      adverseEffects: list('adverseEffects'),
      warnings: text('warnings'),
      olderAdultSafety: text('olderAdultSafety'),
      caregiverGuidance: text('caregiverGuidance'),
      sources: list('sources'),
    );
  }
}
