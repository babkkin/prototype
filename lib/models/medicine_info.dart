class MedicineInfo {
  final String name;
  final String genericName;
  final List<String> brandNames;
  final String category;
  final String form;
  final List<String> commonStrengths;
  final String description;
  final List<String> commonUses;
  final String howItWorks;
  final List<String> commonSideEffects;
  final List<String> precautions;
  final String storage;

  const MedicineInfo({
    required this.name,
    required this.genericName,
    required this.brandNames,
    required this.category,
    required this.form,
    required this.commonStrengths,
    required this.description,
    required this.commonUses,
    required this.howItWorks,
    required this.commonSideEffects,
    required this.precautions,
    required this.storage,
  });

  factory MedicineInfo.fromJson(Map<String, dynamic> json) {
    List<String> strings(String key) =>
        (json[key] as List<dynamic>? ?? const []).map((e) => e.toString()).toList();

    return MedicineInfo(
      name: json['name']?.toString() ?? '',
      genericName: json['genericName']?.toString() ?? '',
      brandNames: strings('brandNames'),
      category: json['category']?.toString() ?? '',
      form: json['form']?.toString() ?? '',
      commonStrengths: strings('commonStrengths'),
      description: json['description']?.toString() ?? '',
      commonUses: strings('commonUses'),
      howItWorks: json['howItWorks']?.toString() ?? '',
      commonSideEffects: strings('commonSideEffects'),
      precautions: strings('precautions'),
      storage: json['storage']?.toString() ?? '',
    );
  }
}
