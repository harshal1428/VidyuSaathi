class ComplaintTypeModel {
  final String id;
  final String category;
  final String subtype;
  final String priority;
  final int slaHours;
  final List<String> keywords;
  final List<String> synonyms;
  final String departmentId;

  ComplaintTypeModel({
    required this.id,
    required this.category,
    required this.subtype,
    required this.priority,
    required this.slaHours,
    required this.keywords,
    required this.synonyms,
    required this.departmentId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'subtype': subtype,
      'priority': priority,
      'slaHours': slaHours,
      'keywords': keywords,
      'synonyms': synonyms,
      'departmentId': departmentId,
    };
  }

  factory ComplaintTypeModel.fromMap(Map<String, dynamic> map) {
    return ComplaintTypeModel(
      id: map['id'] ?? '',
      category: map['category'] ?? '',
      subtype: map['subtype'] ?? '',
      priority: map['priority'] ?? 'Medium',
      slaHours: map['slaHours'] ?? 0,
      keywords: List<String>.from(map['keywords'] ?? []),
      synonyms: List<String>.from(map['synonyms'] ?? []),
      departmentId: map['departmentId'] ?? '',
    );
  }
}
