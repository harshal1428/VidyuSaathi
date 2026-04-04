class DepartmentModel {
  final String id;
  final String name;
  final String shortName;
  final List<String> categories;
  final List<Map<String, dynamic>> hierarchy;
  final Map<String, int> slaConfig;

  DepartmentModel({
    required this.id,
    required this.name,
    required this.shortName,
    required this.categories,
    required this.hierarchy,
    required this.slaConfig,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'shortName': shortName,
      'categories': categories,
      'hierarchy': hierarchy,
      'slaConfig': slaConfig,
    };
  }

  factory DepartmentModel.fromMap(Map<String, dynamic> map) {
    return DepartmentModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      shortName: map['shortName'] ?? '',
      categories: List<String>.from(map['categories'] ?? []),
      hierarchy: List<Map<String, dynamic>>.from(map['hierarchy'] ?? []),
      slaConfig: Map<String, int>.from(map['slaConfig'] ?? {}),
    );
  }
}
